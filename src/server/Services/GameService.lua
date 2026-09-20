--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local HttpService=game:GetService("HttpService")
local Config=require(ReplicatedStorage.Shared.Config)
local Util=require(ReplicatedStorage.Shared.Util)
local Data=require(script.Parent.DataService)
local GameService={Market={}, ActiveJobs={}, Auctions={}}
local notify: RemoteEvent; local sync: RemoteEvent
local function netWorth(d:any): number
	local total=d.Cash
	for _,v in ipairs(d.Vehicles) do total += v.Value or 0 end
	for id,p in pairs(d.Properties) do if p.Owned then total += p.Value or (Config.Houses[id] and Config.Houses[id].Value or 0) end end
	return math.floor(total)
end
local function public(d:any): any return {Cash=d.Cash,Gems=d.Gems,CareerXP=d.CareerXP,CareerLevel=d.CareerLevel,Needs=d.Needs,Vehicles=d.Vehicles,Properties=d.Properties,Furniture=d.Furniture,Quests=d.Quests,DailyRewards=d.DailyRewards,LoginStreak=d.LoginStreak,Statistics=d.Statistics,TutorialStep=d.TutorialStep,NetWorth=netWorth(d),Market=GameService.Market,Auctions=GameService.Auctions} end
function GameService.Push(p:Player) local d=Data.Get(p); if d then sync:FireClient(p,public(d)) end end
local function award(p:Player,cash:number,xp:number,reason:string)
	local d=Data.Get(p); if not d then return end; d.Cash+=cash; d.CareerXP+=xp; d.CareerLevel=Util.levelFromXP(d.CareerXP); d.Statistics.Earned+=cash; d.Quests.Daily.Earn+=cash
	notify:FireClient(p,{Kind="Reward",Text=string.format("+$%d  +%d XP\n%s",cash,xp,reason)}); GameService.Push(p)
end
local function rarity(): any local roll=math.random(1,1000); local n=0; for _,r in ipairs(Config.Rarities) do n+=r.Weight;if roll<=n then return r end end return Config.Rarities[1] end
function GameService.RefreshMarket()
	table.clear(GameService.Market)
	for i=1,5 do local model=Config.Vehicles[math.random(#Config.Vehicles)]; local r=rarity(); local condition=math.random(25,68); local value=math.floor(model.BaseValue*r.Multiplier*(.45+condition/180)); local price=math.floor(value*math.random(52,82)/100)
		table.insert(GameService.Market,{OfferId=HttpService:GenerateGUID(false),Model=model.Id,Name=model.Name,Rarity=r.Name,Price=price,EstimatedLow=math.floor(value*.85),EstimatedHigh=math.floor(value*1.25),Condition=condition})
	end
	for _,p in ipairs(Players:GetPlayers()) do GameService.Push(p) end
end
local function startJob(p:Player,id:string)
	local d=Data.Get(p); local cfg=Config.Jobs[id]; if not d or not cfg then return end
	if d.CareerLevel<cfg.Unlock then notify:FireClient(p,{Kind="Error",Text="Unlocks at Career Level "..cfg.Unlock});return end
	GameService.ActiveJobs[p]={Id=id,Stage=1,Started=os.clock()}; notify:FireClient(p,{Kind="Quest",Text=cfg.Name.." started — follow the glowing marker!"})
end
local function jobTarget(p:Player,id:string)
	local state=GameService.ActiveJobs[p]; if not state or state.Id~=id then startJob(p,id); return end
	local d=Data.Get(p); local cfg=Config.Jobs[id]; local elapsed=math.max(8,os.clock()-state.Started); local performance=math.clamp(1.25-((elapsed-8)/120),.8,1.25); local job=d.Jobs[id]; job.Streak+=1; local pay=math.floor(cfg.BasePay*(1+(job.Level-1)*.08)*performance*(1+math.min(job.Streak,10)*.02)); job.XP+=cfg.XP; job.Level=math.floor(job.XP/250)+1; d.Statistics.JobsCompleted+=1; d.Quests.Daily.Jobs+=1; d.Quests.Weekly.Jobs+=1; GameService.ActiveJobs[p]=nil; award(p,pay,cfg.Career,"JOB COMPLETE — "..cfg.Name)
	if d.TutorialStep==1 then d.TutorialStep=2; notify:FireClient(p,{Kind="Big",Text="FIRST PAYCHECK!\nVisit the Used Car Market."}) end
end
local function buyMarket(p:Player,offerId:string)
	local d=Data.Get(p); if not d then return end; local index,offer
	for i,v in ipairs(GameService.Market) do if v.OfferId==offerId then index=i;offer=v;break end end
	if not offer or d.Cash<offer.Price or #d.Vehicles>=8 then notify:FireClient(p,{Kind="Error",Text="Offer unavailable, garage full, or insufficient cash."});return end
	d.Cash-=offer.Price; local c=offer.Condition; local vehicle={Uid=HttpService:GenerateGUID(false),Model=offer.Model,Name=offer.Name,Rarity=offer.Rarity,PurchasePrice=offer.Price,Value=offer.EstimatedLow,Displayed=false,Condition={Engine=c,Body=math.max(5,c+math.random(-15,15)),Interior=c,Cleanliness=math.max(5,c-20),Tires=c}}
	table.insert(d.Vehicles,vehicle); d.Collectibles.Vehicles[offer.Model]=true; table.remove(GameService.Market,index); notify:FireClient(p,{Kind=if offer.Rarity=="Legendary" or offer.Rarity=="Mythic" then "Big" else "Reward",Text=offer.Rarity:upper().." FIND!\n"..offer.Name}); GameService.Push(p)
end
local function repair(p:Player,uid:string,part:string)
	local d=Data.Get(p); if not d then return end; local allowed={Engine=true,Body=true,Interior=true,Cleanliness=true,Tires=true};if not allowed[part] then return end
	for _,v in ipairs(d.Vehicles) do if v.Uid==uid then local current=v.Condition[part];if current>=100 then return end;local cost=math.max(25,math.floor((100-current)*v.Value*.001));if d.Cash<cost then return end;d.Cash-=cost;v.Condition[part]=math.min(100,current+25);local sum=0;for _,x in pairs(v.Condition) do sum+=x end;v.Value=math.floor(v.Value*(1+(v.Condition[part]-current)/250));if sum/5>=95 then d.Statistics.CarsRestored+=1 end;notify:FireClient(p,{Kind="Reward",Text=part.." repaired!  Vehicle value $"..v.Value});GameService.Push(p);return end end
end
local function sellVehicle(p:Player,uid:string)
	local d=Data.Get(p);if not d then return end;for i,v in ipairs(d.Vehicles) do if v.Uid==uid then d.Cash+=v.Value;d.Statistics.CarsSold+=1;table.remove(d.Vehicles,i);award(p,0,75,"FLIP SOLD FOR $"..v.Value);return end end
end
local function buyHouse(p:Player,id:string)
	local d=Data.Get(p);local h=Config.Houses[id];if not d or not h or d.Properties[id] or d.Cash<h.Price or d.CareerLevel<h.Level then return end;d.Cash-=h.Price;d.Properties[id]={Owned=true,Value=h.Value,Upgrades=0};notify:FireClient(p,{Kind="Big",Text="NEW HOME!\n"..h.Name});GameService.Push(p)
end
local function daily(p:Player)
	local d=Data.Get(p);local day=math.floor(os.time()/86400);if d.DailyRewards.LastDay==day then return end
	if d.DailyRewards.LastDay==day-1 then d.DailyRewards.Index=d.DailyRewards.Index%7+1 else d.DailyRewards.Index=1 end;d.DailyRewards.LastDay=day;local r=Config.DailyRewards[d.DailyRewards.Index];d.Cash+=r.Cash or 0;d.Gems+=r.Gems or 0;d.LoginStreak.Current=if d.LoginStreak.LastDay>=day-1 then d.LoginStreak.Current+1 else 1;d.LoginStreak.Best=math.max(d.LoginStreak.Best,d.LoginStreak.Current);d.LoginStreak.LastDay=day;notify:FireClient(p,{Kind="Big",Text="DAY "..d.DailyRewards.Index.." REWARD!"});GameService.Push(p)
end
function GameService.Init(remotes:Folder)
	notify=remotes.Notify :: RemoteEvent;sync=remotes.Sync :: RemoteEvent
	GameService.RefreshMarket();task.spawn(function() while task.wait(Config.MarketRefreshSeconds) do GameService.RefreshMarket() end end)
	return {Award=award,StartJob=startJob,JobTarget=jobTarget,BuyMarket=buyMarket,Repair=repair,SellVehicle=sellVehicle,BuyHouse=buyHouse,Daily=daily,Public=public}
end
return GameService
