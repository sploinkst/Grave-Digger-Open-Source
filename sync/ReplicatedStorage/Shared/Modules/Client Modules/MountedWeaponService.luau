--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events")
local MountedWeaponEvent = Events:WaitForChild("MountedWeapon") :: RemoteEvent
local CameraService = require(ReplicatedStorage.Shared.Modules["Client Modules"].CameraService)

local Service = {}
local started = false
local activeTurret: Instance? = nil
local previousCameraMode: string? = nil
local previousWalkSpeed: number? = nil
local previousAutoRotate: boolean? = nil
local lastReplication = 0
local RENDER_BIND = "MountedWeaponAlignment"

local function part(parent: Instance?, name: string): BasePart?
	local found = parent and parent:FindFirstChild(name, true)
	return if found and found:IsA("BasePart") then found else nil
end

local function crosshair(): GuiObject?
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local main = playerGui and playerGui:FindFirstChild("main")
	local core = main and main:FindFirstChild("core_game")
	local object = core and core:FindFirstChild("crosshair")
	return if object and object:IsA("GuiObject") then object else nil
end

local function restoreCrosshair()
	local object = crosshair()
	if object then
		object.AnchorPoint = Vector2.new(0.5, 0.5)
		object.Position = UDim2.fromScale(0.5, 0.5)
	end
end

local function stopAlignment(restoreCamera: boolean)
	RunService:UnbindFromRenderStep(RENDER_BIND)
	activeTurret = nil
	lastReplication = 0
	restoreCrosshair()
	LocalPlayer:SetAttribute("MountedWeapon", nil)
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if previousWalkSpeed ~= nil then humanoid.WalkSpeed = previousWalkSpeed end
		if previousAutoRotate ~= nil then humanoid.AutoRotate = previousAutoRotate end
	end
	previousWalkSpeed = nil
	previousAutoRotate = nil

	local controller = CameraService.GetCurrentCamera()
	if controller then
		controller.in_turret = false
		if restoreCamera and previousCameraMode and type(controller.Switch_Camera) == "function" then
			controller:Switch_Camera(previousCameraMode)
		end
	end
	previousCameraMode = nil
end

local function aimTarget(camera: Camera): Vector3
	local viewport = camera.ViewportSize * 0.5
	local ray = camera:ViewportPointToRay(viewport.X, viewport.Y)
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Exclude
	local exclusions = {}
	if LocalPlayer.Character then table.insert(exclusions, LocalPlayer.Character) end
	if activeTurret then table.insert(exclusions, activeTurret) end
	parameters.FilterDescendantsInstances = exclusions
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, parameters)
	return result and result.Position or ray.Origin + ray.Direction * 2000
end

local function updateAlignment()
	local turret = activeTurret
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torsoPosition = part(turret, "torsoposition")
	local camera = Workspace.CurrentCamera
	if not turret or not turret.Parent or not character or not humanoid or humanoid.Health <= 0
		or not root or not root:IsA("BasePart") or not torsoPosition or not camera then
		MountedWeaponEvent:FireServer("Dismount")
		stopAlignment(true)
		return
	end

	root.CFrame = torsoPosition.CFrame
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	humanoid.AutoRotate = false
	humanoid.WalkSpeed = 0
	local target = aimTarget(camera)

	local muzzle = part(turret:FindFirstChild("rig"), "muzzle")
	local object = crosshair()
	if muzzle and object then
		local hit = Workspace:Raycast(muzzle.Position, muzzle.CFrame.LookVector * 500)
		local point = hit and hit.Position or muzzle.Position + muzzle.CFrame.LookVector * 500
		local screen = camera:WorldToViewportPoint(point)
		object.AnchorPoint = Vector2.new(0.5, 0.5)
		object.Position = UDim2.fromOffset(screen.X, screen.Y)
	end

	if os.clock() - lastReplication >= 1 / 20 then
		lastReplication = os.clock()
		MountedWeaponEvent:FireServer("Aim", turret, target)
	end
end

local function startAlignment(turret: Instance)
	stopAlignment(false)
	activeTurret = turret
	LocalPlayer:SetAttribute("MountedWeapon", true)
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		previousWalkSpeed = humanoid.WalkSpeed
		previousAutoRotate = humanoid.AutoRotate
	end
	local controller = CameraService.GetCurrentCamera()
	if controller then
		previousCameraMode = controller.CurrentMode
		controller.in_turret = true
		if type(controller.Switch_Camera) == "function" then
			controller:Switch_Camera("OverTheShoulder")
		end
	end
	RunService:BindToRenderStep(RENDER_BIND, Enum.RenderPriority.Camera.Value + 2, updateAlignment)
end

function Service.start_module()
	if started then return end
	started = true

	MountedWeaponEvent.OnClientEvent:Connect(function(action, turret)
		if action == "Mounted" and typeof(turret) == "Instance" then
			startAlignment(turret)
		elseif action == "Dismounted" then
			stopAlignment(true)
		end
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and activeTurret and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonB) then
			MountedWeaponEvent:FireServer("Dismount")
		end
	end)
	LocalPlayer.CharacterRemoving:Connect(function() stopAlignment(false) end)
end

return Service
