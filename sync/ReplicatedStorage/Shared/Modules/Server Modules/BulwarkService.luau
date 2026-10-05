local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Assets = RS.Shared.Assets
local Service = {}
local events = RS.Shared.Library.Events
local event = events:FindFirstChild("BulwarkAbility") or Instance.new("RemoteEvent")
event.Name = "BulwarkAbility"
event.Parent = events
local states = {}

local function eligible(player)
	local character = player.Character
	local elite = character and character:GetAttribute("EliteClass")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return character and humanoid and humanoid.Health > 0 and (elite == "BulwarkTrooper" or elite == "Bulwark Trooper")
end
local function heldGun(player)
	local character = player.Character
	if not character then return nil end
	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			local name = tool:FindFirstChild("weapon")
			if name and (name.Value == "LewisGun" or name.Value == "BulwarkRifle" or name.Value == "lewis") then return tool end
		end
	end
end

local function shieldModel()
	local model = Instance.new("Model")
	model.Name = "BulwarkShield"
	local core = Instance.new("Part")
	core.Name = "BulwarkShieldPlate"
	core.Size = Vector3.new(4, 4, 0.4)
	core.Material = Enum.Material.Metal
	core.Color = Color3.fromRGB(66, 65, 57)
	core:SetAttribute("IndestructibleShield", true)
	core.Parent = model
	model.PrimaryPart = core
	-- Reuse the authored shield panels instead of a new decorative asset.
	local deployables = Assets:FindFirstChild("deployables")
	local barrier = deployables and deployables:FindFirstChild("Vanguard Barrier")
	local panels = barrier and barrier:FindFirstChild("finished")
	local cover = panels and panels:FindFirstChild("shieldcover", true)
	if cover and cover:IsA("BasePart") then
		core.Transparency = 1
		for _, name in {"shieldcover", "shieldside", "shieldbolts"} do
			local source = panels:FindFirstChild(name, true)
			if source and source:IsA("BasePart") then
				local part = source:Clone()
				for _, child in part:GetDescendants() do if child:IsA("JointInstance") or child:IsA("WeldConstraint") then child:Destroy() end end
				part.CFrame = cover.CFrame:ToObjectSpace(source.CFrame)
				part.CanQuery = false; part.CanCollide = false; part.Massless = true
				part.Parent = model
				local weld = Instance.new("WeldConstraint"); weld.Part0 = core; weld.Part1 = part; weld.Parent = part
			end
		end
	end
	return model
end
local function backShield(player, state)
	if state.deployed and state.deployed.Parent then return end
	if state.back and state.back.Parent then return end
	local character = player.Character
	local torso = character and (character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
	if not torso then return end
	local model = shieldModel()
	model:PivotTo(torso.CFrame * CFrame.new(0, 0, 0.8))
	for _, part in model:GetDescendants() do if part:IsA("BasePart") then part.Anchored = false; part.CanCollide = false; part.Massless = true end end
	local weld = Instance.new("WeldConstraint"); weld.Part0 = torso; weld.Part1 = model.PrimaryPart; weld.Parent = model.PrimaryPart
	model.Parent = character
	state.back = model
end
local function remove(state)
	if state.back then state.back:Destroy() end
	if state.deployed then state.deployed:Destroy() end
end
local function allyCollisions(player, state)
	local shield = state.deployed
	if not shield or not shield.Parent then return end
	local old = shield:FindFirstChild("AllyCollisions")
	if old then old:Destroy() end
	local folder = Instance.new("Folder"); folder.Name = "AllyCollisions"; folder.Parent = shield
	for _, ally in Players:GetPlayers() do
		if ally == player or (player.Team and ally.Team == player.Team) then
			for _, part in (ally.Character and ally.Character:GetDescendants() or {}) do
				if part:IsA("BasePart") then
					local constraint = Instance.new("NoCollisionConstraint")
					constraint.Part0 = shield.PrimaryPart; constraint.Part1 = part; constraint.Parent = folder
				end
			end
		end
	end
end
local function pickup(player, state)
	if not eligible(player) then return end
	if state.deployed then state.deployed:Destroy(); state.deployed = nil end
	backShield(player, state)
end
local function deploy(player, state)
	if not eligible(player) or not heldGun(player) or not state.back or (state.deployed and state.deployed.Parent) then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {player.Character}
	local ahead = root.Position + root.CFrame.LookVector * 5
	local ground = workspace:Raycast(ahead + Vector3.new(0, 3, 0), Vector3.new(0, -9, 0), params)
	if not ground or ground.Normal.Y < 0.6 then return end
	if workspace:Raycast(root.Position, root.CFrame.LookVector * 5, params) then return end
	local model = shieldModel()
	local position = ground.Position + Vector3.new(0, 2, 0)
	local direction = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
	model:PivotTo(CFrame.lookAt(position, position + direction))
	for _, part in model:GetDescendants() do if part:IsA("BasePart") then part.Anchored = true end end
	model.PrimaryPart.CanCollide = true
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("IndestructibleShield", true)
	model.Parent = workspace
	state.back:Destroy(); state.back = nil; state.deployed = model
	-- A top rail is a physical surface for the existing downward bipod test.
	local rail = Instance.new("Part"); rail.Name = "BipodRail"; rail.Size = Vector3.new(4, 0.2, 1.5)
	rail.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 1.6, 0)
	rail.Transparency = 1; rail.Anchored = true; rail.CanCollide = false
	rail:SetAttribute("IndestructibleShield", true); rail.Parent = model
	local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Pick up"; prompt.ObjectText = "Bulwark Shield"
	prompt.MaxActivationDistance = 8; prompt.RequiresLineOfSight = false; prompt.Parent = model.PrimaryPart
	prompt.Triggered:Connect(function(who)
		local r = who.Character and who.Character:FindFirstChild("HumanoidRootPart")
		if who == player and r and (r.Position - model.PrimaryPart.Position).Magnitude <= 9 then pickup(player, state) end
	end)
	allyCollisions(player, state)
end
function Service.Restock(player)
	local state = states[player]
	if state and eligible(player) and not (state.deployed and state.deployed.Parent) then backShield(player, state) end
end
local function mounted(player)
	if not heldGun(player) then return false end
	local character = player.Character
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not head or not humanoid or humanoid.FloorMaterial == Enum.Material.Air or root.AssemblyLinearVelocity.Magnitude >= 3 then return false end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {character}
	local origin = head.Position - Vector3.new(0, 0.5, 0)
	local function valid(result)
		if not result or result.Normal.Y < 0.6 then return false end
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		return not (model and model:FindFirstChildOfClass("Humanoid"))
	end
	return valid(workspace:Raycast(origin + root.CFrame.LookVector * 1.5, Vector3.new(0, -2.25, 0), params))
		or valid(workspace:Raycast(origin + root.CFrame.LookVector * 4, Vector3.new(0, -2.25, 0), params))
end
local function updateGunShield(character, active)
	for _, model in character:GetChildren() do
		if model:IsA("Model") and (string.lower(model.Name):find("lewis", 1, true) or model.Name == "BulwarkRifle") then
			local parts = model:FindFirstChild("parts")
			local visual = parts and parts:FindFirstChild("shield")
			local shield = parts and (parts:FindFirstChild("protect") or visual)
			if visual and visual ~= shield and visual:IsA("BasePart") then visual.CanQuery = false end
			if shield and shield:IsA("BasePart") then
				shield.CanQuery = active; shield:SetAttribute("IndestructibleShield", active or nil)
			end
		end
	end
end
function Service.start_module()
	event.OnServerEvent:Connect(function(player, action, requested)
		if not eligible(player) then return end
		local state = states[player]
		if not state then return end
		if action == "Deploy" and os.clock() >= (state.nextDeploy or 0) then state.nextDeploy = os.clock() + 0.5; deploy(player, state)
		elseif action == "Mount" and os.clock() >= (state.nextMount or 0) then
			state.nextMount = os.clock() + 0.1
			local active = requested == true and mounted(player)
			player.Character:SetAttribute("BulwarkMounted", active or nil)
			updateGunShield(player.Character, active)
		end
	end)
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt; if elapsed < 0.5 then return end; elapsed = 0
		for _, player in Players:GetPlayers() do
			if not eligible(player) then
				if states[player] then remove(states[player]); states[player] = nil end
				if player.Character then player.Character:SetAttribute("BulwarkMounted", nil); updateGunShield(player.Character, false) end
			else
				local state = states[player]
				if not state or state.character ~= player.Character then
					if state then remove(state) end
					state = {character = player.Character}; states[player] = state; backShield(player, state)
				end
				if state.deployed and state.deployed.Parent then allyCollisions(player, state) end
				if player.Character:GetAttribute("BulwarkMounted") and not mounted(player) then player.Character:SetAttribute("BulwarkMounted", nil) end
				updateGunShield(player.Character, player.Character:GetAttribute("BulwarkMounted") == true)
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player) if states[player] then remove(states[player]); states[player] = nil end end)
end
return Service
