--!strict
local Config = {}
Config.SchemaVersion = 1
Config.DataStoreName = "LifeZero_Player_v1"
Config.AutosaveSeconds = 90
Config.StartingCash = 100
Config.AdminUserIds = { -- ChosinoXXX UserId goes here
}
Config.RateLimits = {Action = 0.18, Snapshot = 1}
Config.Rarities = {
	{Name="Common", Weight=600, Multiplier=1}, {Name="Uncommon", Weight=250, Multiplier=1.15},
	{Name="Rare", Weight=100, Multiplier=1.5}, {Name="Epic", Weight=40, Multiplier=2.2},
	{Name="Legendary", Weight=9, Multiplier=5}, {Name="Mythic", Weight=1, Multiplier=12},
}
Config.Jobs = {
	Cleaner={Name="Street Cleaner", BasePay=90, XP=30, Career=25, Unlock=1, TargetTag="Trash"},
	Pizza={Name="Pizza Delivery", BasePay=150, XP=45, Career=35, Unlock=2, TargetTag="PizzaDrop"},
	Warehouse={Name="Warehouse Worker", BasePay=210, XP=55, Career=45, Unlock=3, TargetTag="WarehouseDrop"},
	Mechanic={Name="Mechanic", BasePay=300, XP=70, Career=60, Unlock=5, TargetTag="MechanicBay"},
}
Config.Vehicles = {
	{Id="RustiGo", Name="RustiGo Compact", BaseValue=4800, Unlock=1},
	{Id="Metroline", Name="Metroline Sedan", BaseValue=12500, Unlock=4},
	{Id="Summit", Name="Summit SUV", BaseValue=28000, Unlock=8},
	{Id="Veloce", Name="Veloce Sport", BaseValue=82000, Unlock=15},
	{Id="Aurelia", Name="Aurelia Luxury", BaseValue=240000, Unlock=25},
}
Config.Houses = {
	StarterRoom={Name="Starter Room", Price=750, Level=2, Value=750},
	Apartment={Name="Small Apartment", Price=7500, Level=5, Value=7500},
	SmallHouse={Name="Small House", Price=30000, Level=10, Value=30000},
	FamilyHouse={Name="Family House", Price=120000, Level=20, Value=120000},
	Villa={Name="Luxury Villa", Price=650000, Level=35, Value=650000},
}
Config.Furniture = {
	Bed={Name="Cozy Bed", Category="Beds", Price=400, Need="Energy"},
	Sofa={Name="Bright Sofa", Category="Seating", Price=300, Need="Fun"},
	Table={Name="Dining Table", Category="Tables", Price=220},
	Kitchen={Name="Kitchen Unit", Category="Kitchen", Price=650, Need="Hunger"},
	Shower={Name="Shower", Category="Bathroom", Price=550, Need="Hygiene"},
	TV={Name="Television", Category="Electronics", Price=850, Need="Fun"},
	Plant={Name="Plant", Category="Decoration", Price=80},
	Statue={Name="Gold Statue", Category="Luxury", Price=9000},
}
Config.DailyRewards = {{Cash=250},{Cash=400},{Gems=5},{Cash=700},{Gems=10},{Cash=1200},{Cash=2500,Gems=25}}
Config.GamePasses = {VIP=0, ExtraGarage=0, ExtraHouse=0, PremiumNameplate=0, Cosmetics=0}
Config.Products = {SmallGems={Id=0,Gems=80}, MediumGems={Id=0,Gems=350}, LargeGems={Id=0,Gems=1000}, XPBoost={Id=0}, CashBoost={Id=0}, LuckBoost={Id=0}}
Config.Events = {DoubleJobXP={Enabled=false, XPMultiplier=2}, RareWeekend={Enabled=false, LuckBonus=.15}}
Config.MarketRefreshSeconds = 300
Config.Audio = {UI=0, Job=0, Reward=0, Vehicle=0, Environment=0}
return Config
