local ConstructAudio = require(game:GetService("ReplicatedStorage").Shared.Library.ConstructAudio)
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
	core:SetAttribute("Unpiercable", true)
	core.CanQuery = true
	core.CanCollide = false
	core.Massless = true
	core.Parent = model
	model.PrimaryPart = core
	-- Preserve the deployment's upright frame rather than using the mesh axes.
	local deployables = Assets:FindFirstChild("deployables")
	local template = deployables and (deployables:FindFirstChild("Lewis Shield") or deployables:FindFirstChild("Vanguard Barrier"))
	local panels = template and (template:FindFirstChild("finished") or template)
	local visuals = {}
	if template and template:IsA("Model") and panels then
		local reference = template:GetPivot()
		local minimum = Vector3.new(math.huge, math.huge, math.huge)
		local maximum = -minimum
		for _, source in panels:GetDescendants() do
			if source:IsA("BasePart") and source.Transparency < 1
				and source.Name ~= "core" and source.Name ~= "bounding" and source.Name ~= "click"
				and source.Name ~= "clickpart" and source.Name ~= "damagepart" then
				local part = source:Clone()
				for _, child in part:GetDescendants() do
					if child:IsA("BasePart") or child:IsA("JointInstance") or child:IsA("Constraint")
						or child:IsA("BaseScript") or child:IsA("ProximityPrompt") or child:IsA("ClickDetector") then child:Destroy() end
				end
				part.CFrame = reference:ToObjectSpace(source.CFrame)
				part.Anchored = false; part.CanQuery = false; part.CanCollide = false; part.CanTouch = false; part.Massless = true
				part.CollisionGroup = "Default"
				part.Parent = model
				table.insert(visuals, part)
				local half = part.Size * 0.5
				for _, x in {-1, 1} do
					for _, y in {-1, 1} do
						for _, z in {-1, 1} do
							local corner = part.CFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
							minimum = minimum:Min(corner)
							maximum = maximum:Max(corner)
						end
					end
				end
			end
		end
		if #visuals > 0 then
			local center = (minimum + maximum) * 0.5
			core.Transparency = 1
			-- One solid plate covers the complete bounds of the authored panels.
			core.Size = (maximum - minimum):Max(Vector3.new(0.1, 0.1, 0.1))
			for _, part in visuals do part.CFrame -= center end
		end
	end
	for _, part in visuals do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = core; weld.Part1 = part; weld.Parent = part
	end
	return model
end
local function setBackShieldVisible(state, visible)
	local character = state.character
	if not character then return end
	-- EliteTorso.main is the authored carried shield. Remove the old duplicate.
	local duplicate = character:FindFirstChild("BulwarkShield")
	if duplicate then duplicate:Destroy() end
	local saved = state.backTransparency
	if visible then
		for part, transparency in saved or {} do
			if part.Parent then part.Transparency = transparency end
		end
		state.backTransparency = nil
		return
	end
	local eliteTorso = character:FindFirstChild("EliteTorso", true)
	local main = eliteTorso and eliteTorso:FindFirstChild("main")
	if not main then return end
	saved = saved or {}; state.backTransparency = saved
	local parts = main:GetDescendants()
	table.insert(parts, main)
	for _, part in parts do
		if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
			if saved[part] == nil then saved[part] = part.Transparency end
			part.Transparency = 1
		end
	end
end
local function remove(state)
	setBackShieldVisible(state, true)
	if state.deployed then state.deployed:Destroy() end
end
local function pickup(player, state)
	if not eligible(player) then return end
	if state.deployed then
		ConstructAudio.Play("shield_ready", player.Character)
		ConstructAudio.Play("shield_pickup", player.Character)
		state.deployed:Destroy(); state.deployed = nil
	end
	setBackShieldVisible(state, true)
end
local function deploy(player, state)
	if not eligible(player) or not heldGun(player) or (state.deployed and state.deployed.Parent) then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {player.Character}
	local ahead = root.Position + root.CFrame.LookVector * 5
	local ground = workspace:Raycast(ahead + Vector3.new(0, 3, 0), Vector3.new(0, -9, 0), params)
	if not ground or ground.Normal.Y < 0.6 then return end
	if workspace:Raycast(root.Position, root.CFrame.LookVector * 5, params) then return end
	local model = shieldModel()
	local position = ground.Position
	local direction = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
	model:PivotTo(CFrame.lookAt(position, position + direction))
	-- Rest the lowest corner on the ground plane, including the authored panels.
	-- Checking the plane also keeps the uphill edge clear on sloped ground.
	local lowest = math.huge
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			local half = part.Size * 0.5
			for _, x in {-1, 1} do
				for _, y in {-1, 1} do
					for _, z in {-1, 1} do
						local corner = part.CFrame:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
						lowest = math.min(lowest, (corner - ground.Position):Dot(ground.Normal))
					end
				end
			end
		end
	end
	model:PivotTo(model:GetPivot() + Vector3.new(0, -lowest / ground.Normal.Y, 0))
	for _, part in model:GetDescendants() do if part:IsA("BasePart") then part.Anchored = true end end
	model.PrimaryPart.CanCollide = true
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("IndestructibleShield", true)
	model.Parent = workspace
	ConstructAudio.Play("shield_ready", root)
	ConstructAudio.Play("shield_deploy", model)
	state.deployed = model
	setBackShieldVisible(state, false)
	-- A top rail is a physical surface for the existing downward bipod test.
	local rail = Instance.new("Part"); rail.Name = "BipodRail"; rail.Size = Vector3.new(model.PrimaryPart.Size.X, 0.2, 1.5)
	rail.CFrame = model.PrimaryPart.CFrame * CFrame.new(0, model.PrimaryPart.Size.Y * 0.5 - 0.1, 0)
	rail.Transparency = 1; rail.Anchored = true; rail.CanCollide = false
	rail:SetAttribute("IndestructibleShield", true); rail.Parent = model
	local detector = Instance.new("ClickDetector")
	detector.Name = "clicker"
	detector.MaxActivationDistance = 8
	local interactionObject = Instance.new("ObjectValue")
	interactionObject.Name = "InteractionObject"
	interactionObject.Value = model
	interactionObject.Parent = detector
	detector.Parent = model.PrimaryPart
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.Adornee = model
	highlight.FillTransparency = 0.5
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = false
	highlight.Parent = model
end
function Service.Restock(player)
	local state = states[player]
	if state and eligible(player) and not (state.deployed and state.deployed.Parent) then setBackShieldVisible(state, true) end
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
	-- Equipped models are nested under CharacterData.Equipment.
	for _, model in character:GetDescendants() do
		if model:IsA("Model") and (string.lower(model.Name):find("lewis", 1, true) or model.Name == "BulwarkRifle") then
			local parts = model:FindFirstChild("parts")
			local visual = parts and parts:FindFirstChild("shield")
			local shield = parts and (parts:FindFirstChild("protect") or visual)
			if visual and visual:IsA("BasePart") then
				visual.Transparency = active and 0 or 1
				if visual ~= shield then visual.CanQuery = false end
			end
			if shield and shield:IsA("BasePart") then
				shield.CanQuery = active; shield:SetAttribute("IndestructibleShield", active or nil)
				shield:SetAttribute("Unpiercable", active or nil)
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
		elseif action == "Pickup" then
			local shield = state.deployed
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if shield and shield.Parent and requested == shield and root
				and (root.Position - shield.PrimaryPart.Position).Magnitude <= 8 then
				pickup(player, state)
			end
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
					state = {character = player.Character}; states[player] = state; setBackShieldVisible(state, true)
				end
				setBackShieldVisible(state, not (state.deployed and state.deployed.Parent))
				if player.Character:GetAttribute("BulwarkMounted") and not mounted(player) then player.Character:SetAttribute("BulwarkMounted", nil) end
				updateGunShield(player.Character, player.Character:GetAttribute("BulwarkMounted") == true)
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player) if states[player] then remove(states[player]); states[player] = nil end end)
end
return Service
