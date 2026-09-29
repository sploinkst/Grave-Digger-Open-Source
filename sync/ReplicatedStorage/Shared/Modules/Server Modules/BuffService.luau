local Players=game:GetService("Players"); local RS=game:GetService("ReplicatedStorage"); local Service={}; local status=require(script.Parent.StatusService)
local events=RS.Shared.Library.Events; local event=events:FindFirstChild("BuffAbility") or Instance.new("RemoteEvent"); event.Name="BuffAbility"; event.Parent=events
local rallyBanners={}; local graceSpins=setmetatable({},{__mode="k"})
local function root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function alive(p) local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
local function nearby(source,target,radius) local a,b=root(source),root(target); return a and b and (a.Position-b.Position).Magnitude<=radius end
local function deployBanner(player)
	local r=root(player); if not r then return end; if rallyBanners[player] then rallyBanners[player]:Destroy() end
	local part=Instance.new("Part"); part.Name="RallyBanner"; part.Size=Vector3.new(.5,6,.5); part.Anchored=true; part.CanCollide=false; part.Color=player.Team and player.Team.TeamColor.Color or Color3.fromRGB(220,170,70); part.CFrame=r.CFrame*CFrame.new(0,0,-4)*CFrame.new(0,3,0); part:SetAttribute("OwnerUserId",player.UserId); part.Parent=workspace; rallyBanners[player]=part
	task.delay(45,function() if rallyBanners[player]==part then rallyBanners[player]=nil end; if part.Parent then part:Destroy() end end)
end
function Service.start_module()
	event.OnServerEvent:Connect(function(player,action)
		if action=="RallyBanner" then deployBanner(player)
		elseif action=="GraceSpin" then local now=os.clock(); local state=graceSpins[player] or {count=0,last=0}; state.count=if now-state.last<=2 then state.count+1 else 1; state.last=now; graceSpins[player]=state; if state.count>=6 then state.count=0; status.GiveStatus(player,"MoraleStatus",20) end end
	end)
	task.spawn(function() while true do task.wait(.75); for _,p in Players:GetPlayers() do
		if not alive(p) then continue end; local c=p.Character; local elite=c:GetAttribute("EliteClass")
		for _,ally in Players:GetPlayers() do if ally.Team==p.Team and alive(ally) then
			if elite=="Radio Trooper" and nearby(p,ally,75) then status.GiveStatus(ally,"RadioFocusStatus",2) end
			if elite=="Trench Trooper" and nearby(p,ally,45) then status.GiveStatus(ally,"MoraleStatus",2) end
			if c:GetAttribute("Class")=="Vanguard" and c:GetAttribute("ShieldRaised") and nearby(p,ally,25) then status.GiveStatus(ally,"BulwarkHopeStatus",2) end
		end end
		if c:GetAttribute("DevilDog") then for _,enemy in Players:GetPlayers() do local h=enemy.Character and enemy.Character:FindFirstChildOfClass("Humanoid"); if enemy.Team~=p.Team and h and h.Health>0 and h.Health<100 and nearby(p,enemy,75) then status.GiveStatus(p,"BloodlustStatus",2); break end end end
	end
	for owner,banner in pairs(rallyBanners) do if not banner.Parent then rallyBanners[owner]=nil else for _,ally in Players:GetPlayers() do local r=root(ally); if ally.Team==owner.Team and r and (r.Position-banner.Position).Magnitude<=35 then status.GiveStatus(ally,"RallyStatus",2) end end end end
	end end)
	Players.PlayerRemoving:Connect(function(p) graceSpins[p]=nil; if rallyBanners[p] then rallyBanners[p]:Destroy(); rallyBanners[p]=nil end end)
end
return Service
