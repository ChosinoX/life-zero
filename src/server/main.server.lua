--!strict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local MarketplaceService=game:GetService("MarketplaceService")
local Config=require(ReplicatedStorage.Shared.Config)
local Data=require(script.Services.DataService)
local Game=require(script.Services.GameService)
require(script.MapBuilder).Build()
local remotes=Instance.new("Folder");remotes.Name="LifeZeroRemotes";remotes.Parent=ReplicatedStorage
for _,n in ipairs({"Action","Sync","Notify"}) do local r=Instance.new("RemoteEvent");r.Name=n;r.Parent=remotes end
local action=remotes.Action::RemoteEvent;local api=Game.Init(remotes);local rates:{[Player]:{[string]:number}}={}
local function allowed(p:Player,key:string,delay:number):boolean local now=os.clock();rates[p]=rates[p] or {};if now-(rates[p][key] or 0)<delay then return false end;rates[p][key]=now;return true end
local handlers:{[string]:(Player,any)->()}={
	Snapshot=function(p) Game.Push(p) end,
	BuyMarket=function(p,x) if type(x)=="string" then api.BuyMarket(p,x) end end,
	Repair=function(p,x) if type(x)=="table" and type(x.Uid)=="string" and type(x.Part)=="string" then api.Repair(p,x.Uid,x.Part) end end,
	SellVehicle=function(p,x) if type(x)=="string" then api.SellVehicle(p,x) end end,
	BuyHouse=function(p,x) if type(x)=="string" then api.BuyHouse(p,x) end end,
	Daily=function(p) api.Daily(p) end,
	ClaimQuest=function(p) local d=Data.Get(p);if d and d.Quests.Daily.Jobs>=3 and not d.Quests.Daily.Claimed then d.Quests.Daily.Claimed=true;d.Cash+=500;d.Gems+=5;Game.Push(p) end end,
}
action.OnServerEvent:Connect(function(p,kind,payload) if type(kind)~="string" or #kind>30 or not allowed(p,kind,Config.RateLimits.Action) then return end;local h=handlers[kind];if h then h(p,payload) end end)
for _,desc in ipairs(workspace.LifeZeroCity:GetDescendants()) do if desc:IsA("ProximityPrompt") then desc.Triggered:Connect(function(p) if not allowed(p,"Prompt",.4) then return end;local kind=desc:GetAttribute("Kind");local id=desc:GetAttribute("Id");if kind=="StartJob" then api.StartJob(p,id) elseif kind=="JobTarget" then api.JobTarget(p,id) end end) end end
local function leaderstats(p:Player,d:any) local f=Instance.new("Folder");f.Name="leaderstats";f.Parent=p;local level=Instance.new("IntValue");level.Name="Career";level.Value=d.CareerLevel;level.Parent=f;local worth=Instance.new("IntValue");worth.Name="Net Worth";worth.Value=api.Public(d).NetWorth;worth.Parent=f end
Players.PlayerAdded:Connect(function(p) local d=Data.Load(p);leaderstats(p,d);task.delay(1,function()Game.Push(p);(remotes.Notify::RemoteEvent):FireClient(p,{Kind="Quest",Text="Welcome! Clean the glowing trash in Town Square."})end) end)
Players.PlayerRemoving:Connect(function(p) Data.Save(p,true);rates[p]=nil;Game.ActiveJobs[p]=nil end)
task.spawn(function() while task.wait(Config.AutosaveSeconds) do for _,p in ipairs(Players:GetPlayers()) do Data.Save(p,false) end end end)
task.spawn(function() while task.wait(60) do for _,p in ipairs(Players:GetPlayers()) do local d=Data.Get(p);if d then for n,v in pairs(d.Needs) do d.Needs[n]=math.max(0,v-1) end;d.Statistics.SessionSeconds+=60;Game.Push(p) end end end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do task.spawn(Data.Save,p,true) end;task.wait(4) end)
MarketplaceService.ProcessReceipt=function(info) local p=Players:GetPlayerByUserId(info.PlayerId);if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end;local d=Data.Get(p);if not d then return Enum.ProductPurchaseDecision.NotProcessedYet end;local key=tostring(info.PurchaseId);if d.Receipts[key] then return Enum.ProductPurchaseDecision.PurchaseGranted end;for _,product in pairs(Config.Products) do if product.Id~=0 and product.Id==info.ProductId then if product.Gems then d.Gems+=product.Gems end;d.Receipts[key]=true;Game.Push(p);Data.Save(p,false);return Enum.ProductPurchaseDecision.PurchaseGranted end end;return Enum.ProductPurchaseDecision.NotProcessedYet end
