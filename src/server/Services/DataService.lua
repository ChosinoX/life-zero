--!strict
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local Util = require(game.ReplicatedStorage.Shared.Util)
local store = DataStoreService:GetDataStore(Config.DataStoreName)
local DataService = {Profiles = {}}
local TEMPLATE = {
	schemaVersion=Config.SchemaVersion, Cash=Config.StartingCash, Gems=0, CareerXP=0, CareerLevel=1,
	Jobs={Cleaner={XP=0,Level=1,Streak=0},Pizza={XP=0,Level=1,Streak=0},Warehouse={XP=0,Level=1,Streak=0},Mechanic={XP=0,Level=1,Streak=0}},
	Needs={Hunger=100,Energy=100,Hygiene=100,Fun=100}, Vehicles={}, Properties={}, Furniture={}, FurniturePlacements={},
	Inventory={}, Collectibles={Vehicles={},Furniture={}}, Quests={Daily={Jobs=0,Earn=0,Claimed=false},Weekly={Jobs=0}}, Achievements={},
	DailyRewards={LastDay=0,Index=0}, LoginStreak={Current=0,Best=0,LastDay=0}, Settings={Language="en",Music=true},
	Statistics={JobsCompleted=0,CarsRestored=0,CarsSold=0,Earned=0,SessionSeconds=0}, Receipts={}, TutorialStep=1,
}
local function reconcile(data: any, template: any)
	for k,v in pairs(template) do if data[k] == nil then data[k]=Util.copy(v) elseif type(v)=="table" and type(data[k])=="table" then reconcile(data[k],v) end end
end
local function retry(callback: () -> any): (boolean, any)
	local last
	for attempt=1,5 do local ok,result=pcall(callback); if ok then return true,result end; last=result; task.wait(2^(attempt-1)) end
	return false,last
end
function DataService.Load(player: Player): any
	local key="u_"..player.UserId; local data
	local ok, loaded = retry(function() return store:UpdateAsync(key,function(old)
		old=old or Util.copy(TEMPLATE); reconcile(old,TEMPLATE)
		local lock=old._session; if lock and lock.job~=game.JobId and os.time()-lock.time<180 then return nil end
		old._session={job=game.JobId,time=os.time()}; return old
	end) end)
	data = if ok and loaded then loaded else Util.copy(TEMPLATE)
	reconcile(data,TEMPLATE); data._session={job=game.JobId,time=os.time()}; DataService.Profiles[player]=data
	return data
end
function DataService.Get(player: Player): any return DataService.Profiles[player] end
function DataService.Save(player: Player, release: boolean?): boolean
	local data=DataService.Profiles[player]; if not data then return true end
	data._session = if release then nil else {job=game.JobId,time=os.time()}
	local snapshot=Util.copy(data); local ok=retry(function() store:UpdateAsync("u_"..player.UserId,function(old)
		if old and old._session and old._session.job~=game.JobId and os.time()-old._session.time<180 then return old end
		return snapshot
	end) end)
	if release then DataService.Profiles[player]=nil end
	return ok
end
function DataService.Reset(player: Player) DataService.Profiles[player]=Util.copy(TEMPLATE) end
function DataService.Template(): any return Util.copy(TEMPLATE) end
return DataService
