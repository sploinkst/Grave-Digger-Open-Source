--!strict
--!optimize 2
------------
-- @Praxitos
-- BaseCameraScript (Enhanced with Custom First Person + Original Recoil System)
-- FIXED: Proper HoldBreath implementation matching ingameScript_GD 1:1
------------

-- // Services
local InputService      = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local PlayerService     = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local CameraClass = require(script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass)

-- // Base Object
local BaseCamera = setmetatable({}, { __index = CameraClass })
BaseCamera.__index = BaseCamera

-- // Constants
local LocalPlayer = PlayerService.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- // Config
local CameraOffsets = {
	Third_Person = {
		X = 1.5,
		Y = 1,
		Z = 3,
	},
	First_Person = {
		X = 0,
		Y = 1.5,  -- eye height above root
		Z = 0,
	}
}

local RENDER_STEP_NAME = "BaseCamera_Update"
local RENDER_PRIORITY = Enum.RenderPriority.Camera.Value

local hold_breath = LocalPlayer.PlayerGui:WaitForChild("Aiming"):WaitForChild("hold_breath")

-- // Camera Settings
local CAM_SMOOTH_SPEED = 24
local MouseSensitivity = 0.25 
local PITCH_MIN = math.rad(-80)
local PITCH_MAX = math.rad(80)
local Current_Camera = nil
local CAMERA_TRANSITION_SPEED = 4 -- frames to blend between cameras

local MIN_ZOOM = 2
local MAX_ZOOM = 4
local DEFAULT_ZOOM = 12
local OCCLUSION_MARGIN = 0.25 -- Stops camera from clipping through walls

local AIMING_FOV = 80
local BASE_FOV = 90
local HOLD_BREATH_FOV = 40

local HEAD_FOLLOW_SMOOTH = 12
local HEAD_FOLLOW_MAX_PITCH = math.rad(75)

local HOLD_BREATH_FADE_SPEED = 0.3
local BASE_HOLDBREATH_TIME = 3.5  
local BASE_HOLDBREATH_REGEN = 1.0 
local BASE_HOLDBREATH_ACCURACY = 1.5 
local RECOIL_YANK_STRENGTH = 8

local SWAY_AMPLITUDE = 0.015 -- How far the camera drifts
local SWAY_FREQUENCY = 1.5   -- How fast the breathing cycle is
local SWAY_REDUCTION = 0.1   -- How much sway remains when holding breath (0.1 = 10%)

-- // Data
local PlayerData = LocalPlayer:WaitForChild("PlayerData")
local SettingsData = PlayerData:WaitForChild("Settings Data")
local InputData = SettingsData:WaitForChild("Input Options")
local Shoulder_Switch = InputData:WaitForChild("Shoulder Switch")
local First_Person = InputData:WaitForChild("First Person")
local Free_Look = InputData:WaitForChild("Free Look")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local limbs = {
	"Right Arm",
	"Left Arm",
	"Right Leg",
	"Left Leg",
}

local Presets = {
	OverTheShoulder = {
		CameraType = Enum.CameraType.Scriptable,
		MouseLocked = true,
		MouseVisible = false,
		FOV = BASE_FOV,
		AutoRotate = false,
		Cursor_UI = true,
		Aiming_Dynamic = true,
	},
	FirstPerson = {
		CameraType = Enum.CameraType.Scriptable,
		MouseLocked = true,
		MouseVisible = false,
		FOV = BASE_FOV,
		AutoRotate = false,
		Cursor_UI = true,
		Aiming_Dynamic = true,
	},
	CustomCamera = {
		CameraType = Enum.CameraType.Custom,
		MouseLocked = false,
		MouseVisible = true,
		FOV = BASE_FOV,
		AutoRotate = true,
		Cursor_UI = false,
		Aiming_Dynamic = false,
	},
}

local TweenCache = {}

-- // Input
local Input_Connections = {}

-- // Constructor
function BaseCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, BaseCamera)

	self.CameraPosition = Camera.CFrame.Position
	self.CurrentMode = nil

	self.CameraYaw = 0
	self.CameraPitch = 0

	-- shoulder system
	self.ShoulderAlpha = 1 -- 0 = left, 1 = right
	self.ShoulderTarget = 1
	self.ShoulderSwitchSpeed = 6

	-- first person specific
	self.IsFirstPerson = false

	-- camera transition
	self.TransitionProgress = 1 -- 0 to 1, 1 = fully transitioned
	self.PreviousCameraPos = Camera.CFrame.Position
	self.PreviousCameraAngle = Camera.CFrame

	-- first person torso fade
	self.TorsoTween = nil
	self.TorsoFadeOut = false

	-- === RECOIL SYSTEM (Matching Original ingameScript_GD) ===
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0
	self.RecoilSnappiness = 100

	self.ShoulderZoom = CameraOffsets.Third_Person.Z
	self.TargetShoulderZoom = CameraOffsets.Third_Person.Z
	self.ZoomSpeed = 10

	self.HeadConnection = nil
	self.HeadFollowEnabled = false
	self.HeadCurrentPitch = 0

	-- FOV Tween Management
	self.FOVTween = nil


	self.HoldBreathConnection = nil
	self.holding_breath = false
	self.hold_breathtime = tick()
	self.hold_breathmax = BASE_HOLDBREATH_TIME
	self.hold_breathregen = BASE_HOLDBREATH_REGEN
	self.hold_breathaccuracy = BASE_HOLDBREATH_ACCURACY
	self.applied_holdbreath_recoil = false

	-- Character respawn tracking
	self.CharacterDeathConnection = nil
	self.CustomCameraConnection = nil

	self.InputBeganConnection = nil

	self.CharacterAddedConnection = nil
	self.KeybindConnections = {}

	self._mouseDelta = Vector2.zero
	self._inputConn = nil

	return self
end

-- // Helpers
function BaseCamera:_unbind()
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end

function BaseCamera:_bind(callback)
	RunService:BindToRenderStep(RENDER_STEP_NAME, RENDER_PRIORITY, callback)
end

--[[
	Update recoil state (spring physics).
	This moves RecoilPitch and RecoilYaw towards their targets at a speed
	determined by RecoilSnappiness. When not being shot, it slowly recovers to 0.
	
	Matches the original system's smooth recoil application.
]]
function BaseCamera:_updateRecoil(dt: number)
	local alpha = math.clamp(self.RecoilSnappiness * dt, 0, 1)

	-- Calculate how much the recoil moved this frame
	local oldPitch = self.RecoilPitch
	local oldYaw = self.RecoilYaw

	-- Interpolate the recoil values toward the target (the 8-degree yank)
	self.RecoilPitch += (self.RecoilTargetPitch - self.RecoilPitch) * alpha
	self.RecoilYaw   += (self.RecoilTargetYaw - self.RecoilYaw) * alpha

	-- Calculate the difference (the "delta") and add it to the actual Camera angles
	local pitchDelta = self.RecoilPitch - oldPitch
	local yawDelta = self.RecoilYaw - oldYaw

	self.CameraPitch += pitchDelta
	self.CameraYaw += yawDelta

	-- Reset recoil values back to 0 immediately since they've been moved to the camera
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0
end


function BaseCamera:_updateHoldBreath()
	if self.holding_breath then
		--local progress = math.clamp((tick() - self.hold_breathtime) / self.hold_breathaccuracy, 0, 1)
		--hold_breath.ImageTransparency = self:_lerp(1, 0, progress)
		self.applied_holdbreath_recoil = true
	else
		--local recovery = math.clamp((tick() - self.hold_breathtime) / self.hold_breathregen, 0, 1)
		--hold_breath.ImageTransparency = self:_lerp(0, 1, recovery)
		
		if self.applied_holdbreath_recoil == true then
		
			Util.applyRecoil(RECOIL_YANK_STRENGTH, 10, RECOIL_YANK_STRENGTH + math.random(-10, 10), true)
			self.applied_holdbreath_recoil = false	
		end
	end
end

-- LINEAR INTERPOLATION FUNCTION
function BaseCamera:_lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function resolveKeyFromString(value: string): Enum.KeyCode?
	local keyName = string.match(value, "Enum%.KeyCode%.(.+)")
	if not keyName then
		warn("[BaseCamera] Invalid KeyCode format:", value)
		return nil
	end

	return Enum.KeyCode[keyName]
end

function BaseCamera:_setupInput()
	if self.InputBeganConnection then return end

	self.InputBeganConnection = InputService.InputBegan:Connect(function(input, gp)
		if gp then return end

		if input.KeyCode == self.shoulder_switch_key then
			self:_switch_shoulder(
				LocalPlayer:GetAttribute("Current_Shoulder") == "Left" and "Right" or "Left"
			)

		elseif input.KeyCode == self.first_person_key then
			self:Switch_Camera(self.CurrentMode == "FirstPerson" and "OverTheShoulder" or "FirstPerson")

		elseif input.KeyCode == self.free_look_key then
			self:Switch_Camera(self.CurrentMode == "CustomCamera" and "OverTheShoulder" or "CustomCamera")
		end
	end)
end

function BaseCamera:_consumeMouseDelta()
	local d = self._mouseDelta
	self._mouseDelta = Vector2.zero
	return d
end

function BaseCamera:_setupMouseInput()
	if self._inputConn then return end

	self._inputConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Delta
			self._mouseDelta += Vector2.new(delta.X, delta.Y)
		end
	end)
end

function BaseCamera:_refreshKeybinds()
	self.shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
	self.first_person_key = resolveKeyFromString(First_Person.Value)
	self.free_look_key = resolveKeyFromString(Free_Look.Value)
end

function BaseCamera:_getCharacterParts()
	local character = LocalPlayer.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not root or not head or not humanoid then return end

	return character, root, head, humanoid
end

local function yawFromLook(look: Vector3): number
	return math.atan2(-look.X, -look.Z)
end

local function angleDifference(a: number, b: number): number
	local diff = (a - b + math.pi) % (2 * math.pi) - math.pi
	return diff
end

local function smoothLerp(a: CFrame, b: CFrame, t: number): CFrame
	local eased = t * t * (3 - 2 * t)
	return a:Lerp(b, eased)
end

-- // FOV Management Functions
function BaseCamera:_setupAimingCheck()
	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	self.aim_check = LocalPlayer.Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		self:_onAimingStateChanged()
	end)

	print("[BaseCamera] Aiming check setup for mode:", self.CurrentMode)
end

function BaseCamera:_onAimingStateChanged()
	if self.FOVTween then
		self.FOVTween:Cancel()
	end

	local aimingState = LocalPlayer.Character:GetAttribute("Aiming")
	local targetFOV = aimingState and AIMING_FOV or BASE_FOV

	-- If holding breath, prioritize that FOV
	if self.holding_breath then
		targetFOV = HOLD_BREATH_FOV
		print("[BaseCamera] Aiming changed but holding breath - keeping FOV at", targetFOV)
	else
		print("[BaseCamera] Aiming state changed - setting FOV to", targetFOV)
	end

	self.FOVTween = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = targetFOV})
	self.FOVTween:Play()
end

-- HOLD BREATH CHECK SETUP
function BaseCamera:_setupHoldBreathCheck()
	print("[BaseCamera] Setting up HoldBreath listener for mode:", self.CurrentMode)

	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
	end

	-- Listen for attribute changes
	self.HoldBreathConnection = LocalPlayer.Character:GetAttributeChangedSignal("HoldBreathe"):Connect(function()
		self:_onHoldBreathStateChanged()
	end)
end

-- HANDLE HOLD BREATH STATE CHANGE
function BaseCamera:_onHoldBreathStateChanged()
	local newState = LocalPlayer.Character:GetAttribute("HoldBreathe") or false

	self.holding_breath = newState
	self.hold_breathtime = tick()

	if self.FOVTween then self.FOVTween:Cancel() end
	if self.ImageTween then self.ImageTween:Cancel() end

	local isAiming = LocalPlayer.Character:GetAttribute("Aiming")
	local targetFOV = self.holding_breath and HOLD_BREATH_FOV or (isAiming and AIMING_FOV or BASE_FOV)

	-- Using Linear easing to match the UI's _updateHoldBreath lerp
	self.FOVTween = TweenService:Create(Camera, 
		TweenInfo.new(HOLD_BREATH_FADE_SPEED, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
		{FieldOfView = targetFOV}
	)
	
	self.ImageTween = TweenService:Create(hold_breath, 
		TweenInfo.new(HOLD_BREATH_FADE_SPEED, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
		{ImageTransparency = self.holding_breath and 0 or 1}
	)
	
	self.FOVTween:Play()
	self.ImageTween:Play()
end

local transparency_connection = nil

local function first_person_transparency(character: Instance, isFirstPerson: boolean)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Cleanup old connection
	if transparency_connection then
		transparency_connection:Disconnect()
		transparency_connection = nil
	end

	local function update_part(obj: BasePart, instant: boolean)
		local isEssentialBodyPart = obj.Name:find("Head") or obj.Name:find("Torso") or obj.Name:find("Root") or obj.Parent:IsA("Accessory")

		local targetValue = 0 -- Default to visible
		if isFirstPerson and isEssentialBodyPart then
			targetValue = 1 -- Hide head/torso in FP
		end

		if TweenCache[obj] then TweenCache[obj]:Cancel() end

		if instant then
			obj.LocalTransparencyModifier = targetValue
		else
			local tween = TweenService:Create(obj, tweenInfo, {LocalTransparencyModifier = targetValue})
			tween:Play()
			TweenCache[obj] = tween
		end
	end

	-- Initial sweep
	for _, obj in character:GetDescendants() do
		if obj:IsA("BasePart") then
			update_part(obj, false)
		end
	end

	-- The "No Matter What" listener
	transparency_connection = character.DescendantAdded:Connect(function(obj)
		task.defer(function()
			if obj:IsA("BasePart") then
				update_part(obj, true)
			end
		end)
	end)

	return TweenCache
end

function BaseCamera:_setupAlignOrientation(root: BasePart)
	local existing = root:FindFirstChild("CameraAlign")
	if existing then
		existing:Destroy()
	end

	local att = Instance.new("Attachment")
	att.Name = "CameraAlignAttachment"
	att.Parent = root

	local align = Instance.new("AlignOrientation")
	align.Name = "CameraAlign"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = att
	align.MaxAngularVelocity = 100
	align.MaxTorque = 100000
	align.Responsiveness = 100
	align.AlignType = Enum.AlignType.AllAxes
	align.ReactionTorqueEnabled = false
	align.RigidityEnabled = true
	align.Parent = root

	self._align = align
	self._alignAttachment = att
end

function BaseCamera:_switch_shoulder(target: string)
	if target == "Left" then
		self.ShoulderTarget = 0
	else
		self.ShoulderTarget = 1
	end

	LocalPlayer:SetAttribute("Current_Shoulder", target)
end

function BaseCamera:_resetAllTransparency()
	local character = LocalPlayer.Character
	if not character then return end

	for _, obj in character:GetDescendants() do
		if obj:IsA("BasePart") then
			obj.LocalTransparencyModifier = 0
		end
	end
end

-- // Camera Mode: Custom Free Look
function BaseCamera:CustomCamera()
	self:_unbind()
	self.IsFirstPerson = false
	self.CurrentMode = "CustomCamera"
	self.TransitionProgress = 0

	local character, root, head, humanoid = self:_getCharacterParts()
	if not root then return end

	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	self:_resetAllTransparency()

	local currentZoom = MAX_ZOOM 
	local isRightMouseDown = false
	local zoomSensitivity = 1

	LocalPlayer:SetAttribute("FreeLook", true)

	local zoomConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			currentZoom = math.clamp(
				currentZoom - (input.Position.Z * zoomSensitivity),
				MIN_ZOOM,
				MAX_ZOOM
			)
		end
	end)

	local mouseConn1 = InputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRightMouseDown = true
			InputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
	end)

	local mouseConn2 = InputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRightMouseDown = false
			InputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)

	self:_bind(function(dt)
		local _, rootPart = self:_getCharacterParts()
		if not rootPart then return end

		local delta = self:_consumeMouseDelta()

		if isRightMouseDown then
			self.CameraYaw -= delta.X * 0.0025

			local potentialPitch = self.CameraPitch - delta.Y * 0.0025

			self.CameraPitch = math.clamp(
				potentialPitch,
				PITCH_MIN - self.RecoilPitch,
				PITCH_MAX - self.RecoilPitch
			)
		end

		local rotation =
			CFrame.Angles(0, self.CameraYaw, 0)
			* CFrame.Angles(self.CameraPitch, 0, 0)
		local cameraDir = rotation.LookVector
		local cameraFocus = rootPart.Position + Vector3.new(0, 1.5, 0)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = Workspace:Raycast(cameraFocus, -cameraDir * currentZoom, rayParams)
		local finalZoom = currentZoom
		if rayResult then
			finalZoom = math.max(rayResult.Distance - OCCLUSION_MARGIN, MIN_ZOOM)
		end

		local targetCFrame = CFrame.new(cameraFocus - (cameraDir * finalZoom)) * rotation

		if self.TransitionProgress < 1 then
			self.TransitionProgress = math.min(self.TransitionProgress + dt * CAMERA_TRANSITION_SPEED, 1)
			local eased = self.TransitionProgress * self.TransitionProgress * (3 - 2 * self.TransitionProgress)
			Camera.CFrame = self.PreviousCameraAngle:Lerp(targetCFrame, eased)
		else
			Camera.CFrame = targetCFrame
		end

		if self.CurrentMode ~= "CustomCamera" then
			zoomConn:Disconnect()
			mouseConn1:Disconnect()
			mouseConn2:Disconnect()

			LocalPlayer:SetAttribute("FreeLook", false)
			self:_unbind()
		end
	end)
end

function BaseCamera:HeadFollowCamera_Setup()
	local character, root = self:_getCharacterParts()
	if not character then return end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then
		return
	end

	local neck: Motor6D = torso:FindFirstChild("Neck")
	if not neck or not neck:IsA("Motor6D") then
		return
	end

	self.HeadFollowEnabled = true

	local baseC0 = neck.C0
	local currentPitch = 0

	self.HeadConnection = RunService.RenderStepped:Connect(function(dt)
		if not character.Parent or not self.HeadFollowEnabled then return end

		local targetPitch = self.CameraPitch + self.RecoilPitch
		targetPitch = math.clamp(targetPitch, -HEAD_FOLLOW_MAX_PITCH, HEAD_FOLLOW_MAX_PITCH)

		local alpha = math.clamp(HEAD_FOLLOW_SMOOTH * dt, 0, 1)
		currentPitch += (targetPitch - currentPitch) * alpha

		neck.C0 = baseC0 * CFrame.Angles(-currentPitch, 0, 0)

		self.HeadCurrentPitch = currentPitch
	end)
end

function BaseCamera:HeadFollowCamera_Reject()
	self.HeadFollowEnabled = false

	if self.HeadConnection then
		self.HeadConnection:Disconnect()
		self.HeadConnection = nil
	end

	local character = LocalPlayer.Character
	if not character then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local neck = head:FindFirstChild("Neck")
	if not neck then return end

	neck.Transform = CFrame.Angles(0, 0, 0)
	self.HeadCurrentPitch = 0
end

-- // Camera Mode: First Person
function BaseCamera:FirstPerson()
	self:_unbind()
	self.IsFirstPerson = true
	self.TransitionProgress = 0 
	self.TorsoFadeOut = true

	local character, root = self:_getCharacterParts()
	if not root then return end

	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	print("[BaseCamera] FirstPerson mode activated")
	self:_setupAimingCheck()
	self:_setupHoldBreathCheck()

	first_person_transparency(character, true)

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()

		local character, root, head, humanoid = self:_getCharacterParts()
		if not root then return end

		local delta = self:_consumeMouseDelta()

		local isAiming = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Aiming") == true

		local swayTime = tick() * SWAY_FREQUENCY

		local swayMultiplier = 0
		if isAiming then
			swayMultiplier = self.holding_breath and SWAY_REDUCTION or 1
		end

		local swayX = math.sin(swayTime) * SWAY_AMPLITUDE * swayMultiplier
		local swayY = math.cos(swayTime * 0.5) * SWAY_AMPLITUDE * swayMultiplier

		self.CameraYaw -= delta.X * 0.0025
		local potentialPitch = self.CameraPitch - delta.Y * 0.0025

		self.CameraPitch = math.clamp(
			potentialPitch,
			PITCH_MIN - self.RecoilPitch, 
			PITCH_MAX - self.RecoilPitch
		)

		-- Apply Recoil + Sway to the final angles
		local finalYaw = self.CameraYaw + self.RecoilYaw + swayX
		local finalPitch = self.CameraPitch + self.RecoilPitch + swayY

		local offset = CameraOffsets.First_Person
		local focusPoint = root.Position + Vector3.new(0, offset.Y, 0)

		local targetCFrame =
			CFrame.new(focusPoint)
			* CFrame.Angles(0, finalYaw, 0)
			* CFrame.Angles(finalPitch, 0, 0)

		self.TransitionProgress = math.min(self.TransitionProgress + dt * CAMERA_TRANSITION_SPEED, 1)
		local eased = self.TransitionProgress * self.TransitionProgress * (3 - 2 * self.TransitionProgress)
		Camera.CFrame = self.PreviousCameraAngle:Lerp(targetCFrame, eased)

		if humanoid and humanoid.Health > 0 then
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, self.CameraYaw, 0)
		end

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)
end

-- // Camera Mode: Over The Shoulder
function BaseCamera:OverTheShoulder()
	self:_unbind()
	self.IsFirstPerson = false
	self.TransitionProgress = 0

	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	print("[BaseCamera] OverTheShoulder mode activated")
	self:_setupAimingCheck()
	self:_setupHoldBreathCheck()

	local character, root, _, humanoid = self:_getCharacterParts()
	if not root then return end

	local zoomConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.TargetShoulderZoom = math.clamp(self.TargetShoulderZoom - input.Position.Z, 1.5, 3)
		end
	end)

	if humanoid then humanoid.AutoRotate = false end
	if not self._align then self:_setupAlignOrientation(root) end

	first_person_transparency(character, false)

	self:HeadFollowCamera_Setup()

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()

		local character, root = self:_getCharacterParts()
		if not root then return end

		local delta = self:_consumeMouseDelta()

		-- Calculate Sway
		local isAiming = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Aiming") == true

		local swayTime = tick() * SWAY_FREQUENCY

		local swayMultiplier = 0
		if isAiming then
			swayMultiplier = self.holding_breath and SWAY_REDUCTION or 1
		end

		local swayX = math.sin(swayTime) * SWAY_AMPLITUDE * swayMultiplier
		local swayY = math.cos(swayTime * 0.5) * SWAY_AMPLITUDE * swayMultiplier

		self.CameraYaw -= delta.X * 0.0025
		local potentialPitch = self.CameraPitch - delta.Y * 0.0025

		self.CameraPitch = math.clamp(
			potentialPitch,
			PITCH_MIN - self.RecoilPitch,
			PITCH_MAX - self.RecoilPitch
		)

		-- Apply Recoil + Sway
		local finalYaw = self.CameraYaw + self.RecoilYaw + swayX
		local finalPitch = self.CameraPitch + self.RecoilPitch + swayY

		local rotation =
			CFrame.Angles(0, finalYaw, 0)
			* CFrame.Angles(finalPitch, 0, 0)

		local offset = CameraOffsets.Third_Person
		local focusPoint = root.Position + Vector3.new(0, 1, 0)

		self.ShoulderAlpha += (self.ShoulderTarget - self.ShoulderAlpha) * math.clamp(self.ShoulderSwitchSpeed * dt, 0, 1)
		self.ShoulderZoom += (self.TargetShoulderZoom - self.ShoulderZoom) * math.clamp(self.ZoomSpeed * dt, 0, 1)

		local x_offset = offset.X * ((self.ShoulderAlpha * 2) - 1)
		local desiredPos = focusPoint + (rotation.RightVector * x_offset) - (rotation.LookVector * self.ShoulderZoom) + Vector3.new(0, offset.Y, 0)

		local targetCFrame = CFrame.new(desiredPos) * rotation

		self.TransitionProgress = math.min(self.TransitionProgress + dt * CAMERA_TRANSITION_SPEED, 1)
		local eased = self.TransitionProgress * self.TransitionProgress * (3 - 2 * self.TransitionProgress)
		Camera.CFrame = self.PreviousCameraAngle:Lerp(targetCFrame, eased)

		if self._align then
			self._align.CFrame = CFrame.Angles(0, self.CameraYaw, 0)
		end

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		if self.CurrentMode ~= "OverTheShoulder" then zoomConn:Disconnect() end
	end)
end

-- // Camera switching
function BaseCamera:Switch_Camera(target: string)
	if not Presets[target] then return end

	print("[BaseCamera] Switching to camera mode:", target)

	local look = Camera.CFrame.LookVector
	self.CameraYaw = math.atan2(-look.X, -look.Z)
	self.CameraPitch = math.asin(look.Y)

	self.PreviousCameraAngle = Camera.CFrame
	self.PreviousCameraPos = Camera.CFrame.Position

	self:_unbind()
	self.CurrentMode = target
	self.TransitionProgress = 0

	local preset = Presets[target]
	Camera.CameraType = preset.CameraType
	Camera.FieldOfView = preset.FOV or 70
	InputService.MouseIconEnabled = preset.MouseVisible or false
	InputService.MouseBehavior = preset.MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default

	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
		print("[BaseCamera] Disconnected HoldBreath listener")
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		task.defer(function() humanoid.AutoRotate = preset.AutoRotate or false end)
	end

	if LocalPlayer.PlayerGui:FindFirstChild("Aiming") then
		LocalPlayer.PlayerGui.Aiming.Regular_Crosshair.Visible = preset.Cursor_UI or false
	end

	self[target](self)
	Current_Camera = target
end

-- // Initialize/Reset on character respawn
function BaseCamera:_setupCharacterDeathListener(humanoid)
	if self.CharacterDeathConnection then self.CharacterDeathConnection:Disconnect() end

	self.CharacterDeathConnection = humanoid.Died:Connect(function()
		print("[BaseCamera] Character died")
		self:_resetAllTransparency()

		if transparency_connection then
			transparency_connection:Disconnect()
			transparency_connection = nil
		end

		self:End() 
	end)
end

-- // Lifecycle
function BaseCamera:Start()
	print("[BaseCamera] Starting camera system")

	local function onCharacterAdded(character)
		print("[BaseCamera] Character added, initializing...")
		self:End()

		self:_refreshKeybinds()
		self:_setupInput()
		self:_setupMouseInput()

		local root = character:WaitForChild("HumanoidRootPart", 5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not root or not humanoid then return end

		self.CameraYaw = yawFromLook(root.CFrame.LookVector)
		self.CameraPitch = 0
		self.RecoilPitch = 0
		self.RecoilYaw = 0
		self.RecoilTargetPitch = 0
		self.RecoilTargetYaw = 0
		self.TransitionProgress = 0
		self.holding_breath = false
		self.hold_breathtime = tick()

		self:_setupAlignOrientation(root)
		humanoid.AutoRotate = false

		self:_setupCharacterDeathListener(humanoid)

		task.defer(function()
			self:Switch_Camera("OverTheShoulder")
			self:_switch_shoulder("Right")
			self:_resetAllTransparency()
		end)
	end

	if LocalPlayer.Character then
		onCharacterAdded(LocalPlayer.Character)
	end

	self.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

	local function updateKeys()
		self.shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
		self.first_person_key = resolveKeyFromString(First_Person.Value)
		self.free_look_key = resolveKeyFromString(Free_Look.Value)
	end

	updateKeys()
	table.insert(self.KeybindConnections, Shoulder_Switch:GetPropertyChangedSignal("Value"):Connect(updateKeys))
	table.insert(self.KeybindConnections, First_Person:GetPropertyChangedSignal("Value"):Connect(updateKeys))
	table.insert(self.KeybindConnections, Free_Look:GetPropertyChangedSignal("Value"):Connect(updateKeys))

	self:_setupInput()
end

function BaseCamera:End()
	print("[BaseCamera] Ending camera system")

	self:_unbind()

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	if self.CharacterDeathConnection then
		self.CharacterDeathConnection:Disconnect()
		self.CharacterDeathConnection = nil
	end

	if self.HeadConnection then
		self.HeadConnection:Disconnect()
		self.HeadConnection = nil
	end

	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
		print("[BaseCamera] HoldBreathConnection disconnected in End()")
	end

	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	if self._alignAttachment then
		self._alignAttachment:Destroy()
		self._alignAttachment = nil
	end

	if self.InputBeganConnection then
		self.InputBeganConnection:Disconnect()
		self.InputBeganConnection = nil
	end

	if self.KeybindConnections then
		for _, c in ipairs(self.KeybindConnections) do
			c:Disconnect()
		end
		self.KeybindConnections = {}
	end
end

function BaseCamera:Cut()
	self:End()
end

function BaseCamera:ApplyRecoil(vertical: number, horizontal: number)
	self.RecoilTargetPitch += vertical
	self.RecoilTargetYaw += horizontal
end

local myCamera = BaseCamera.new({
	name = "BaseCamera",
	priority = 1,
})

return BaseCamera