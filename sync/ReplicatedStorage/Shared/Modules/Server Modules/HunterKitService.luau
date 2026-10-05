-- Authored deployables share placement/ownership with constructions.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Rules = require(RS.Shared.Library.MasterPortRules)
local V = require(script.Parent.MasterActions.Validation)
local Service = {}
local event = V.Remote("HunterKitAbility")
local triggered = setmetatable({}, {__mode = "k"})
local function enemy(owner, character)
	local player = character and Players:GetPlayerFromCharacter(character)
	return player and player ~= owner and owner.Team and player.Team ~= owner.Team and player or nil
end
function Service.TriggerHit(instance)
	local model = require(script.Parent.ConstructionService).Find(instance)
	if not model or not model:GetAttribute("HunterTrap") or triggered[model] then return false end
	triggered[model] = true
	local owner = Players:GetPlayerByUserId(model:GetAttribute("OwnerUserId"))
	local core = model:FindFirstChild("core")
	if not owner or not core then model:Destroy(); return true end
	local name, position = model.Name, core.Position
	local radius = model:GetAttribute("Radius") or 12
	local damage = model:GetAttribute("Damage") or (name == "Dynamite Stack" and 100 or 45)
	for _, target in ipairs(Players:GetPlayers()) do
		local c = target.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
		local h = c and c:FindFirstChildOfClass("Humanoid")
		if enemy(owner, c) and root and h and h.Health > 0 and (root.Position-position).Magnitude <= radius then
			local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={model}
			local obstruction=workspace:Raycast(position,root.Position-position,params)
			if obstruction and not obstruction.Instance:IsDescendantOf(c) then continue end
			if name == "Mantrap" then require(script.Parent.StatusService).GiveStatus(target,"CrippleStatus",3)
			elseif name == "Gas Shell" then if not c:GetAttribute("GasImmune") then require(script.Parent.StatusService).GiveStatus(target,"SicknessStatus") end
			elseif name == "Light Lure" then require(script.Parent.StatusService).GiveStatus(target,"LethalBurningStatus")
			else h:TakeDamage(damage) end
		end
	end
	require(script.Parent.ReplicantManager).SendPresentation(owner,"trap_triggered",{message="Your "..name.." was triggered."})
	model:Destroy(); return true
end
function Service.BindTrap(owner, model)
	model:SetAttribute("HunterTrap",true)
	local function touched(hit)
		local ancestor=hit:FindFirstAncestorOfClass("Model")
		while ancestor and not Players:GetPlayerFromCharacter(ancestor) do ancestor=ancestor:FindFirstAncestorOfClass("Model") end
		if enemy(owner,ancestor) then Service.TriggerHit(model) end
	end
	local finished=model:FindFirstChild("finished")
	for _,part in ipairs(finished and finished:GetDescendants() or {}) do
		if part:IsA("BasePart") then part.CanTouch=true; part.Touched:Connect(touched) end
	end
	if model.Name=="Tripwire" then
		local nearest, distance
		for _,candidate in ipairs(model.Parent:GetChildren()) do
			local core=candidate:FindFirstChild("fuse_hook")
			if candidate~=model and core and candidate:FindFirstChild("tripwires") and candidate:GetAttribute("OwnerUserId")==owner.UserId then
				local d=(core.Position-model.core.Position).Magnitude
				if d<=Rules.TripwireRange and (not distance or d<distance) then nearest=candidate; distance=d end
			end
		end
		if not nearest then model:Destroy(); return end
		local a0=Instance.new("Attachment"); a0.Parent=model.core
		local a1=Instance.new("Attachment"); a1.Parent=nearest.fuse_hook
		local source=RS.Shared.Assets:FindFirstChild("tripwire",true)
		local beam=source and (source:IsA("Beam") and source or source:FindFirstChildWhichIsA("Beam",true))
		if beam then local clone=beam:Clone(); clone.Attachment0=a0; clone.Attachment1=a1; clone.Parent=model.core end
		local connection
		connection=game:GetService("RunService").Heartbeat:Connect(function()
			if not model.Parent or not nearest.Parent then connection:Disconnect(); a1:Destroy(); if model.Parent then model:Destroy() end; return end
			local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={model,nearest}
			local hit=workspace:Raycast(model.core.Position,nearest.fuse_hook.Position-model.core.Position,params)
			if hit then local c=hit.Instance:FindFirstAncestorOfClass("Model"); if enemy(owner,c) then Service.TriggerHit(nearest); model:Destroy() end end
		end)
	end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	event.OnServerEvent:Connect(function(player,action,kind)
		local c,root=V.Living(player)
		local tool=c and (c:FindFirstChild("HunterKit") or c:FindFirstChild("JaegerKit"))
		if not tool or not V.Cooldown(player,"HunterLegacy",0.5) then return end
		if action=="PlaceTripwire" then kind="Tripwire" elseif action~="PlaceTrap" then return end
		if not table.find(Rules.Traps,kind) and kind~="Tripwire" then return end
		require(script.Parent.ConstructionService).Place(player,kind,root.CFrame*CFrame.new(0,-2.5,-3))
	end)
end
return Service
