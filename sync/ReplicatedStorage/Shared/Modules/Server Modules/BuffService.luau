--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Status = require(script.Parent.StatusService)
local Service = {}
local Events = RS.Shared.Library.Events
local Remote = Events:FindFirstChild("BuffAbility") :: RemoteEvent?
if not Remote then Remote = Instance.new("RemoteEvent"); Remote.Name = "BuffAbility"; Remote.Parent = Events end

local RALLY_RADIUS, RALLY_LIFETIME, RALLY_COOLDOWN = 35, 45, 45
local BULWARK_RANGE, BULWARK_WIDTH = 25, 10
local REFRESH, STATUS_TIME = .25, .75
type BannerState = {instance: Model, position: Vector3, team: Team?, expiresAt: number}
local banners: {[Player]: BannerState} = {}
local cooldowns: {[Player]: number} = {}
local graceSpins = setmetatable({}, {__mode = "k"})

local function className(c: Model?): string
	if not c then return "" end
	local a = c:GetAttribute("Class")
	if type(a) == "string" and a ~= "" then return string.lower(a) end
	local v = c:FindFirstChild("class")
	return v and v:IsA("StringValue") and string.lower(v.Value) or ""
end
local function root(p: Player): BasePart?
	local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	return if r and r:IsA("BasePart") then r else nil
end
local function alive(p: Player): boolean
	local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	return h ~= nil and h.Health > 0
end
local function allied(a: Player, b: Player): boolean
	return a == b or (a.Team ~= nil and b.Team ~= nil and a.Team == b.Team)
end

local function findTemplate(): Model?
	for _, container in {RS.Shared:FindFirstChild("Assets"), SS} do
		if container then for _, d in container:GetDescendants() do
			if d:IsA("Model") and string.lower(d.Name) == "rally banner" then return d end
		end end
	end
	return nil
end
local function prepareBanner(m: Model, color: Color3)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false
			local n=string.lower(d.Name); if string.find(n,"banner",1,true) or string.find(n,"flag",1,true) then d.Color=color end
		elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then d:Destroy() end
	end
	if not m.PrimaryPart then m.PrimaryPart=m:FindFirstChildWhichIsA("BasePart",true) end
	m:SetAttribute("RallyBanner",true)
end
local function placement(c: Model, r: BasePart): CFrame?
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={c}
	local intended=r.Position+r.CFrame.LookVector*5
	local hit=workspace:Raycast(intended+Vector3.new(0,4,0),Vector3.new(0,-12,0),params)
	if not hit or hit.Normal:Dot(Vector3.yAxis)<.7 then return nil end
	local yaw=math.atan2(-r.CFrame.LookVector.X,-r.CFrame.LookVector.Z)
	return CFrame.new(hit.Position)*CFrame.Angles(0,yaw,0)
end
local function destroyBanner(p: Player)
	local s=banners[p]; if s and s.instance.Parent then s.instance:Destroy() end; banners[p]=nil
end
local function deployBanner(p: Player)
	local c,r=p.Character,root(p); if not c or not r or not alive(p) or className(c)~="vanguard" then return end
	local now=os.clock(); if now<(cooldowns[p] or 0) then return end
	local cf=placement(c,r); if not cf then return end; destroyBanner(p)
	local color=p.Team and p.Team.TeamColor.Color or Color3.fromRGB(220,170,70)
	local template=findTemplate(); if not template then warn("[BuffService] Missing authored Rally Banner"); return end; local banner=template:Clone()
	prepareBanner(banner,color); if not banner.PrimaryPart then banner:Destroy(); return end
	banner:PivotTo(cf); banner:SetAttribute("OwnerUserId",p.UserId)
	local oldOwner=banner:FindFirstChild("owner"); if oldOwner then oldOwner:Destroy() end
	local owner=Instance.new("StringValue"); owner.Name="owner"; owner.Value=p.Name; owner.Parent=banner
	local oldTeam=banner:FindFirstChild("team"); if oldTeam then oldTeam:Destroy() end
	local teamValue=Instance.new("ObjectValue"); teamValue.Name="team"; teamValue.Value=p.Team; teamValue.Parent=banner
	local oldHealth=banner:FindFirstChild("health"); if oldHealth then oldHealth:Destroy() end
	local health=Instance.new("NumberValue"); health.Name="health"; health.Value=100; health.Parent=banner
	local constructions=workspace:FindFirstChild("constructions")
	if not constructions then constructions=Instance.new("Folder"); constructions.Name="constructions"; constructions.Parent=workspace end
	banner.Parent=constructions
	cooldowns[p]=now+RALLY_COOLDOWN; banners[p]={instance=banner,position=cf.Position,team=p.Team,expiresAt=now+RALLY_LIFETIME}
end

local function behindShield(source: Player, ally: Player): boolean
	if source==ally or not allied(source,ally) or not alive(ally) then return false end
	local c,sr,ar=source.Character,root(source),root(ally)
	if not c or not sr or not ar or className(c)~="vanguard" or c:GetAttribute("ShieldRaised")~=true or not c:FindFirstChild("shield") then return false end
	local offset=ar.Position-sr.Position; if offset.Magnitude<=.01 or offset.Magnitude>BULWARK_RANGE or math.abs(offset.Y)>8 then return false end
	local depth=offset:Dot(sr.CFrame.LookVector); local lateral=(offset-sr.CFrame.LookVector*depth).Magnitude
	if depth>1 or lateral>BULWARK_WIDTH then return false end
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={c,ally.Character}
	return workspace:Raycast(sr.Position,offset,params)==nil
end

local function refreshBuffs()
	local now=os.clock()
	for owner,b in banners do
		if now>=b.expiresAt or not b.instance.Parent then destroyBanner(owner) else
			for _,ally in Players:GetPlayers() do local r=root(ally)
				if alive(ally) and ally.Team~=nil and ally.Team==b.team and r and (r.Position-b.position).Magnitude<=RALLY_RADIUS then Status.GiveStatus(ally,"RallyStatus",STATUS_TIME) end
			end
		end
	end
	for _,source in Players:GetPlayers() do
		if not alive(source) then continue end
		local c=source.Character; local elite=c and c:GetAttribute("EliteClass")
		for _,ally in Players:GetPlayers() do
			if not allied(source,ally) or not alive(ally) then continue end
			local sr,ar=root(source),root(ally); local distance=sr and ar and (sr.Position-ar.Position).Magnitude or math.huge
			if elite=="Radio Trooper" and distance<=75 then Status.GiveStatus(ally,"RadioFocusStatus",STATUS_TIME) end
			if elite=="Trench Trooper" and distance<=45 then Status.GiveStatus(ally,"MoraleStatus",STATUS_TIME) end
			if behindShield(source,ally) then Status.GiveStatus(ally,"BulwarkHopeStatus",STATUS_TIME) end
		end
		if c and c:GetAttribute("DevilDog") then for _,enemy in Players:GetPlayers() do
			local h=enemy.Character and enemy.Character:FindFirstChildOfClass("Humanoid"); local sr,er=root(source),root(enemy)
			if enemy~=source and not allied(source,enemy) and h and h.Health>0 and h.Health<100 and sr and er and (sr.Position-er.Position).Magnitude<=75 then Status.GiveStatus(source,"BloodlustStatus",STATUS_TIME); break end
		end end
	end
end

function Service.DeployBanner(player)
	deployBanner(player)
end

function Service.start_module()
	Remote.OnServerEvent:Connect(function(p: Player, action: any)
		if action=="RallyBanner" then deployBanner(p)
		elseif action=="GraceSpin" then local now=os.clock(); local s=graceSpins[p] or {count=0,last=0}; s.count=if now-s.last<=2 then s.count+1 else 1; s.last=now; graceSpins[p]=s; if s.count>=6 then s.count=0; Status.GiveStatus(p,"MoraleStatus",20) end end
	end)
	task.spawn(function() while true do task.wait(REFRESH); refreshBuffs() end end)
	Players.PlayerRemoving:Connect(function(p) graceSpins[p]=nil; cooldowns[p]=nil; destroyBanner(p) end)
end
return Service
