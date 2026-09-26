--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events")
local Interact = Events:WaitForChild("Interact") :: RemoteEvent
local MountedWeaponEvent = Events:FindFirstChild("MountedWeapon") :: RemoteEvent?
if not MountedWeaponEvent then
	MountedWeaponEvent = Instance.new("RemoteEvent")
	MountedWeaponEvent.Name = "MountedWeapon"
	MountedWeaponEvent.Parent = Events
end

local Service = {}
local started = false
local mountedByPlayer: { [Player]: Instance } = {}
local playerByTurret: { [Instance]: Player } = {}
local lastAimUpdate: { [Player]: number } = {}

local MAX_MOUNT_DISTANCE = 10
local MAX_AIM_DISTANCE = 2000
local AIM_INTERVAL = 1 / 30

local function part(turret: Instance, name: string): BasePart?
	local found = turret:FindFirstChild(name, true)
	return if found and found:IsA("BasePart") then found else nil
end

local function value(turret: Instance, name: string): ValueBase?
	local found = turret:FindFirstChild(name)
	return if found and found:IsA("ValueBase") then found else nil
end

local function isTurret(turret: Instance?): boolean
	return turret ~= nil
		and turret:IsDescendantOf(Workspace)
		and part(turret, "centerpoint") ~= nil
		and part(turret, "torsoposition") ~= nil
		and value(turret, "turret_weapon") ~= nil
end

local function setInUse(turret: Instance, character: Model?)
	local inUse = turret:FindFirstChild("in_use")
	if not inUse then
		inUse = Instance.new("ObjectValue")
		inUse.Name = "in_use"
		inUse.Parent = turret
	end
	if inUse:IsA("ObjectValue") then
		inUse.Value = character
	end
end

local function clearCharacterState(player: Player, turret: Instance?)
	local character = player.Character
	if character then
		character:SetAttribute("MountedWeapon", nil)
		character:SetAttribute("MountedWeaponName", nil)
		local reference = character:FindFirstChild("mounted_weapon")
		if reference and reference:IsA("ObjectValue") then reference:Destroy() end
	end
	if turret and turret.Parent then setInUse(turret, nil) end
end

local function dismount(player: Player, reason: string?)
	local turret = mountedByPlayer[player]
	if not turret then return end
	mountedByPlayer[player] = nil
	playerByTurret[turret] = nil
	lastAimUpdate[player] = nil
	clearCharacterState(player, turret)
	MountedWeaponEvent:FireClient(player, "Dismounted", turret, reason or "Requested")
end

local function mount(player: Player, turret: Instance)
	if not isTurret(turret) then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torsoPosition = part(turret, "torsoposition")
	if not character or not humanoid or humanoid.Health <= 0
		or not root or not root:IsA("BasePart") or not torsoPosition then return end
	if (root.Position - torsoPosition.Position).Magnitude > MAX_MOUNT_DISTANCE then return end

	local currentPlayer = playerByTurret[turret]
	if currentPlayer and currentPlayer ~= player then return end
	if mountedByPlayer[player] == turret then
		dismount(player, "Interaction")
		return
	end
	if mountedByPlayer[player] then dismount(player, "ChangedTurret") end

	mountedByPlayer[player] = turret
	playerByTurret[turret] = player
	setInUse(turret, character)
	character:SetAttribute("MountedWeapon", true)
	character:SetAttribute("MountedWeaponName", turret.Name)
	local reference = Instance.new("ObjectValue")
	reference.Name = "mounted_weapon"
	reference.Value = turret
	reference.Parent = character
	character:PivotTo(torsoPosition.CFrame)
	MountedWeaponEvent:FireClient(player, "Mounted", turret)
end

local function finiteVector3(vector: Vector3): boolean
	return vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
		and math.abs(vector.X) < 1e7 and math.abs(vector.Y) < 1e7 and math.abs(vector.Z) < 1e7
end

local function rotateTurret(player: Player, turret: Instance, target: Vector3)
	if mountedByPlayer[player] ~= turret or not isTurret(turret) or not finiteVector3(target) then return end
	local now = os.clock()
	if now - (lastAimUpdate[player] or 0) < AIM_INTERVAL then return end
	lastAimUpdate[player] = now

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torsoPosition = part(turret, "torsoposition")
	if not root or not root:IsA("BasePart") or not torsoPosition
		or (root.Position - torsoPosition.Position).Magnitude > MAX_MOUNT_DISTANCE then
		dismount(player, "OutOfRange")
		return
	end

	local rig = turret:FindFirstChild("rig")
	local centerpoint = part(turret, "centerpoint")
	local turretPivot = rig and part(rig, "turretpivot")
	local gun = rig and rig:FindFirstChild("mg")
	local gunPivot = rig and part(rig, "mgpivot_outer")
	if not rig or not rig:IsA("Model") or not centerpoint or not turretPivot
		or not gun or not gun:IsA("Model") or not gunPivot then return end

	local offset = target - turretPivot.Position
	if offset.Magnitude < 0.01 then return end
	if offset.Magnitude > MAX_AIM_DISTANCE then target = turretPivot.Position + offset.Unit * MAX_AIM_DISTANCE end
	local pitch, yaw = CFrame.lookAt(turretPivot.Position + Vector3.new(0, 1, 0), target):ToOrientation()
	rig:PivotTo(centerpoint.CFrame * CFrame.fromOrientation(yaw, 0, 0)
		* CFrame.Angles(math.rad(90 - centerpoint.Orientation.Y), 0, 0))
	gun:PivotTo(gunPivot.CFrame * CFrame.fromOrientation(math.clamp(pitch, -0.6, 0.6), 0, 0))
end

local function prepareTurret(candidate: Instance)
	if not isTurret(candidate) then return end
	local clickPart = part(candidate, "click") or part(candidate, "centerpoint")
	if not clickPart then return end
	local detector = clickPart:FindFirstChildWhichIsA("ClickDetector")
	if not detector then
		detector = Instance.new("ClickDetector")
		detector.Parent = clickPart
	end
	detector.Name = "clicker"
	if detector.MaxActivationDistance <= 0 or detector.MaxActivationDistance > MAX_MOUNT_DISTANCE then
		detector.MaxActivationDistance = MAX_MOUNT_DISTANCE
	end
	local interactionObject = detector:FindFirstChild("InteractionObject")
	if not interactionObject then
		interactionObject = Instance.new("ObjectValue")
		interactionObject.Name = "InteractionObject"
		interactionObject.Parent = detector
	end
	if interactionObject:IsA("ObjectValue") then interactionObject.Value = candidate end
	local highlight = candidate:FindFirstChildWhichIsA("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "Highlight"
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 0
		highlight.Enabled = false
		highlight.Parent = candidate
	end
end

function Service.start_module()
	if started then return end
	started = true

	Interact.OnServerEvent:Connect(function(player, object)
		if typeof(object) == "Instance" and isTurret(object) then mount(player, object) end
	end)
	MountedWeaponEvent.OnServerEvent:Connect(function(player, action, turret, target)
		if action == "Dismount" then
			dismount(player, "Requested")
		elseif action == "Aim" and typeof(turret) == "Instance" and typeof(target) == "Vector3" then
			rotateTurret(player, turret, target)
		end
	end)

	Players.PlayerRemoving:Connect(function(player) dismount(player, "PlayerRemoving") end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterRemoving:Connect(function() dismount(player, "CharacterRemoving") end)
	end)
	for _, player in Players:GetPlayers() do
		player.CharacterRemoving:Connect(function() dismount(player, "CharacterRemoving") end)
	end

	Workspace.DescendantAdded:Connect(function(instance)
		if instance:IsA("Model") or instance:IsA("Folder") then task.defer(prepareTurret, instance) end
	end)
	for _, instance in Workspace:GetDescendants() do
		if instance:IsA("Model") or instance:IsA("Folder") then prepareTurret(instance) end
	end
end

return Service
