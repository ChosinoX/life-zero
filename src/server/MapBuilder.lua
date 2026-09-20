--!strict
local CollectionService=game:GetService("CollectionService")
local MapBuilder={}
local COLORS={Blue=Color3.fromRGB(53,126,224),Green=Color3.fromRGB(64,184,112),Orange=Color3.fromRGB(245,153,58),Purple=Color3.fromRGB(132,91,209),Red=Color3.fromRGB(225,75,79)}
local function part(parent:Instance,name:string,size:Vector3,pos:Vector3,color:Color3):Part local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Parent=parent;return p end
local function label(base:BasePart,text:string)
	local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(240,55);gui.StudsOffset=Vector3.new(0,base.Size.Y/2+2,0);gui.AlwaysOnTop=true;gui.Parent=base
	local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundColor3=Color3.fromRGB(20,27,40);l.BackgroundTransparency=.08;l.TextColor3=Color3.new(1,1,1);l.Font=Enum.Font.GothamBold;l.TextScaled=true;l.Text=text;l.Parent=gui;Instance.new("UICorner",l)
end
local function prompt(p:BasePart,action:string,object:string,attrs:{[string]:any}) local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=object;q.HoldDuration=.35;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=p;for k,v in pairs(attrs) do q:SetAttribute(k,v) end end
local function building(root:Folder,name:string,pos:Vector3,color:Color3,size:Vector3?):Part local s=size or Vector3.new(34,16,26);local b=part(root,name,s,pos+Vector3.new(0,s.Y/2,0),color);label(b,name);part(root,name.." Door",Vector3.new(5,8,.5),pos+Vector3.new(0,4,-s.Z/2-.3),Color3.fromRGB(35,45,60));return b end
function MapBuilder.Build()
	if workspace:FindFirstChild("LifeZeroCity") then return end
	local root=Instance.new("Folder");root.Name="LifeZeroCity";root.Parent=workspace
	part(root,"Ground",Vector3.new(520,2,520),Vector3.new(0,-1,0),Color3.fromRGB(103,184,99))
	for x=-200,200,100 do part(root,"Road",Vector3.new(28,.3,500),Vector3.new(x,.15,0),Color3.fromRGB(48,53,62)) end
	for z=-200,200,100 do part(root,"Road",Vector3.new(500,.3,28),Vector3.new(0,.16,z),Color3.fromRGB(48,53,62)) end
	local places={{"Town Square",Vector3.new(50,0,50),COLORS.Blue},{"Job Center",Vector3.new(-50,0,50),COLORS.Purple},{"Slice Sprint Pizza",Vector3.new(-150,0,50),COLORS.Orange},{"BoxWorks Warehouse",Vector3.new(-150,0,-50),COLORS.Blue},{"FixIt Garage",Vector3.new(-50,0,-50),COLORS.Red},{"Used Car Market",Vector3.new(50,0,-50),COLORS.Orange},{"Nova Car Dealer",Vector3.new(150,0,-50),COLORS.Blue},{"Fresh Basket",Vector3.new(150,0,50),COLORS.Green},{"Starter Housing",Vector3.new(-150,0,150),COLORS.Purple},{"Residential Area",Vector3.new(-50,0,150),COLORS.Green},{"Luxury District",Vector3.new(150,0,150),Color3.fromRGB(240,205,90)},{"City Park",Vector3.new(50,0,150),COLORS.Green},{"Auction House",Vector3.new(150,0,-150),COLORS.Red}}
	for _,v in ipairs(places) do building(root,v[1]::string,v[2]::Vector3,v[3]::Color3) end
	local spawn=Instance.new("SpawnLocation");spawn.Name="Welcome Spawn";spawn.Size=Vector3.new(12,1,12);spawn.Position=Vector3.new(50,1,90);spawn.Anchored=true;spawn.Neutral=true;spawn.Color=Color3.fromRGB(255,222,70);spawn.Parent=root
	local jobs={{"Cleaner",Vector3.new(38,2,32)},{"Pizza",Vector3.new(-150,2,32)},{"Warehouse",Vector3.new(-150,2,-68)},{"Mechanic",Vector3.new(-50,2,-68)}}
	for _,v in ipairs(jobs) do local p=part(root,v[1].." Job",Vector3.new(7,4,7),v[2],COLORS.Green);label(p,"START "..string.upper(v[1]));prompt(p,"Start work",v[1],{Kind="StartJob",Id=v[1]}) end
	local targets={{"Cleaner",Vector3.new(60,1,62),"Trash pile"},{"Pizza",Vector3.new(-120,2,145),"Pizza customer"},{"Warehouse",Vector3.new(-175,2,-40),"Package shelf"},{"Mechanic",Vector3.new(-30,2,-50),"Repair vehicle"}}
	for _,v in ipairs(targets) do local p=part(root,v[3],Vector3.new(5,3,5),v[2],COLORS.Orange);prompt(p,"Complete task",v[3],{Kind="JobTarget",Id=v[1]}) end
	for i=1,16 do local x=math.random(-230,230);local z=math.random(-230,230);local trunk=part(root,"Tree",Vector3.new(2,8,2),Vector3.new(x,4,z),Color3.fromRGB(111,75,48));local crown=part(root,"Crown",Vector3.new(8,8,8),Vector3.new(x,10,z),COLORS.Green);crown.Shape=Enum.PartType.Ball end
	for i=1,12 do local pole=part(root,"Streetlight",Vector3.new(.7,10,.7),Vector3.new(-215+i*35,5,18),Color3.fromRGB(60,68,78));local lamp=part(root,"Lamp",Vector3.new(3,.8,1.5),pole.Position+Vector3.new(1,5,0),Color3.fromRGB(255,232,155));lamp.Material=Enum.Material.Neon end
end
return MapBuilder
