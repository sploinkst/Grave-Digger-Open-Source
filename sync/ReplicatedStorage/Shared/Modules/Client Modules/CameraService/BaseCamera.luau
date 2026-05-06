--!strict
--!optimize 2
------------
-- @Praxitos
-- BaseCameraScript (FULL 1:1 Match with ingameScript_GD camera system)
-- MATCHED: Over-shoulder offsets, collision avoidance, hold breath, crouch, FOV, recoil
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

-- // Over-The-Shoulder Camera Offsets (Matches ingameScript_GD Lines 1695-1699, 3852-3868)
local CameraOffsets = {
	Third_Person_Right = {
		X = 1.5,      -- Right shoulder offset
		Y = 3,        -- Eye height
		Z = 3,        -- Depth from character
	},
	Third_Person_Left = {
		X = -1.5,     -- Left shoulder offset (flipped)
		Y = 3,
		Z = 3,
	},
	First_Person = {
		X = 0,        -- Centered
		Y = 1.5,      -- Eye height
		Z = 0,        -- No depth
	},
	Turret = {        -- Special case when mounted
		Y = 2,
		Z = -4,
	},
}

-- // FOV Configuration (Matches ingameScript_GD)
local FOV_Config = {
	BASE = 90,        -- Default gameplay FOV (Line 6319)
	AIMING = 80,      -- While aiming
	HOLD_BREATH = 40, -- While holding breath (scoped weapons)
	MENU = 40,        -- Menu FOV (Line 51)
	SCOPE = 40 / 3.5, -- Scoped weapon zoom (Line 3773)
}

-- // Render & Camera Settings
local RENDER_STEP_NAME = "BaseCamera_Update"
local RENDER_PRIORITY = Enum.RenderPriority.Camera.Value

-- // Camera Smooth Speed (Matches lerp @ 0.075)
local CAMERA_OFFSET_LERP = 0.075  -- v_u_1.CameraOffset lerp speed (Line 3865)
local FOV_LERP_SPEED = 0.1        -- FieldOfView lerp speed (Line 4509)
local NECK_LERP_SPEED = 0.1       -- Head rotation lerp speed (Line 3550)

-- // Character Rotation (Matches v409, v347, v348 system)
local CHARACTER_ROTATION_LERP = 0.075  -- RootJoint.C0 lerp (Lines 3667, 3676)
local ARM_ROTATION_LERP = 0.1          -- Arm IK lerp (Lines 3548-3549)
local NECK_PITCH_CLAMP = math.rad(75)  -- Max head pitch

-- // Sensitivity & Input
local MouseSensitivity = 0.0025   -- Delta multiplier for camera rotation
local PITCH_MIN = math.rad(-90)   -- Max look down
local PITCH_MAX = math.rad(90)    -- Max look up

-- // Collision Avoidance (Matches v_u_257, v_u_258, v_u_259 raycasts)
local COLLISION_MARGIN = 0.25     -- Stops camera from clipping
local MIN_ZOOM = 1.8            -- Closest camera zoom
local MAX_ZOOM = 3            -- Furthest zoom (with mouse wheel)
local WALL_COLLISION_DISTANCE = 6.5

-- // Hold Breath System (Matches ingameScript_GD)
local HOLD_BREATH_TIME = 3.5
local HOLD_BREATH_REGEN = 1.0
local HOLD_BREATH_ACCURACY = 1.5
local HOLD_BREATH_FADE_SPEED = 0.3
local RECOIL_YANK_STRENGTH = 8

-- // Recoil System (Matches v_u_81.RecoilPitch/Yaw system)
local RECOIL_SNAPPINESS = 100

-- // Shoulder System (Matches v_u_81.flip_cam toggle)
local SHOULDER_SWITCH_SPEED = 6

-- // Data
local PlayerData = LocalPlayer:WaitForChild("PlayerData")
local SettingsData = PlayerData:WaitForChild("Settings Data")
local InputData = SettingsData:WaitForChild("Input Options")
local Shoulder_Switch = InputData:WaitForChild("Shoulder Switch")
local First_Person = InputData:WaitForChild("First Person")
local Free_Look = InputData:WaitForChild("Free Look")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

-- // Preset Configurations
local Presets = {
	OverTheShoulder = {
		CameraType = Enum.CameraType.Custom,
		MouseLocked = true,
		MouseVisible = false,
		FOV = FOV_Config.BASE,
		AutoRotate = false,
		Cursor_UI = true,
		Aiming_Dynamic = true,
	},
	FirstPerson = {
		CameraType = Enum.CameraType.Custom,
		MouseLocked = true,
		MouseVisible = false,
		FOV = FOV_Config.BASE,
		AutoRotate = false,
		Cursor_UI = true,
		Aiming_Dynamic = true,
	},
	CustomCamera = {
		CameraType = Enum.CameraType.Custom,
		MouseLocked = false,
		MouseVisible = true,
		FOV = FOV_Config.BASE,
		AutoRotate = true,
		Cursor_UI = false,
		Aiming_Dynamic = false,
	},
}

local TweenCache = {}

-- // Constructor
function BaseCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, BaseCamera)

	self.CurrentMode = nil

	-- === CAMERA ANGLES (Matches ingameScript_GD v346, v345 system) ===
	self.CameraYaw = 0      -- Horizontal rotation (left/right)
	self.CameraPitch = 0    -- Vertical rotation (up/down)

	-- === RECOIL SYSTEM (Matches ingameScript_GD v_u_81 recoil values) ===
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0
	self.RecoilSnappiness = RECOIL_SNAPPINESS

	-- === SHOULDER SYSTEM (Matches v_u_81.flip_cam) ===
	self.ShoulderAlpha = 1  -- 0 = left, 1 = right (matching ingameScript_GD)
	self.ShoulderTarget = 1
	self.ShoulderSwitchSpeed = SHOULDER_SWITCH_SPEED

	-- === FIRST PERSON STATE ===
	self.IsFirstPerson = false

	-- === TRANSITION SYSTEM ===
	self.TransitionProgress = 1
	self.PreviousCameraPos = Camera.CFrame.Position
	self.PreviousCameraAngle = Camera.CFrame

	-- === CAMERA DEPTH (v_u_100 from ingameScript_GD) ===
	self.ShoulderZoom = CameraOffsets.Third_Person_Right.Z
	self.TargetShoulderZoom = CameraOffsets.Third_Person_Right.Z
	self.ZoomSpeed = 10

	-- === COLLISION AVOIDANCE (v_u_257, v_u_258, v_u_259) ===
	self.WallDistanceX = 0  -- Horizontal wall collision
	self.WallDistanceY = 0  -- Vertical wall collision
	self.WallDistanceZ = 0  -- Backward wall collision

	-- === HEAD FOLLOWING (Matches neck rotation system) ===
	self.HeadConnection = nil
	self.HeadFollowEnabled = false
	self.HeadCurrentPitch = 0

	-- === HOLD BREATH SYSTEM (Matches ingameScript_GD v_u_81 breathing) ===
	self.holding_breath = false
	self.hold_breathtime = tick()
	self.hold_breathmax = HOLD_BREATH_TIME
	self.hold_breathregen = HOLD_BREATH_REGEN
	self.hold_breathaccuracy = HOLD_BREATH_ACCURACY
	self.applied_holdbreath_recoil = false

	-- === CHARACTER STATE ===
	self.is_crouching = false           -- v_u_81.crouching
	self.is_aiming = false              -- v_u_81.aiming
	self.shift_locked = false           -- v_u_81.shift_locked
	self.in_turret = false              -- l_ObjectValue_0.Value

	-- === FOV TWEENING ===
	self.FOVTween = nil
	self.CurrentFOV = FOV_Config.BASE

	-- === CONNECTIONS ===
	self.CharacterDeathConnection = nil
	self.InputBeganConnection = nil
	self.CharacterAddedConnection = nil
	self.KeybindConnections = {}
	self._mouseDelta = Vector2.zero
	self._inputConn = nil
	self.aim_check = nil
	self.HoldBreathConnection = nil

	-- === ALIGN ORIENTATION ===
	self._align = nil
	self._alignAttachment = nil

	-- === SWAY (Idle breathing effect - Matches ingameScript_GD) ===
	self.SwayAmplitude = 0.015
	self.SwayFrequency = 1.5
	self.SwayReduction = 0.1

	-- === TORSO TRANSPARENCY ===
	self.transparency_connection = nil

	return self
end

-- // Helper Functions

function BaseCamera:_unbind()
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end

function BaseCamera:_bind(callback)
	RunService:BindToRenderStep(RENDER_STEP_NAME, RENDER_PRIORITY, callback)
end

--[[
	Update recoil state with spring physics.
	Matches ingameScript_GD recoil application where recoil is added to camera angles.
]]
function BaseCamera:_updateRecoil(dt: number)
	local alpha = math.clamp(self.RecoilSnappiness * dt, 0, 1)

	local oldPitch = self.RecoilPitch
	local oldYaw = self.RecoilYaw

	-- Interpolate toward target recoil
	self.RecoilPitch += (self.RecoilTargetPitch - self.RecoilPitch) * alpha
	self.RecoilYaw   += (self.RecoilTargetYaw - self.RecoilYaw) * alpha

	-- Apply delta to camera angles
	local pitchDelta = self.RecoilPitch - oldPitch
	local yawDelta = self.RecoilYaw - oldYaw

	self.CameraPitch += pitchDelta
	self.CameraYaw += yawDelta

	-- Reset recoil (already applied)
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0
end

--[[
	Update hold breath state and apply the release recoil yank.
	Matches ingameScript_GD _updateHoldBreath behavior.
]]
function BaseCamera:_updateHoldBreath()
	if self.holding_breath then
		self.applied_holdbreath_recoil = true
	else
		if self.applied_holdbreath_recoil == true then
			Util.applyRecoil(RECOIL_YANK_STRENGTH, 10, RECOIL_YANK_STRENGTH + math.random(-10, 10), true)
			self.applied_holdbreath_recoil = false	
		end
	end
end

-- LINEAR INTERPOLATION
function BaseCamera:_lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- Resolve KeyCode from string
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
	if not character then return nil end

	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not root or not head or not humanoid then return nil end

	return character, root, head, torso, humanoid
end

--[[
	Calculate yaw from look vector (heading angle).
	Used to preserve camera direction when switching modes.
]]
local function yawFromLook(look: Vector3): number
	return math.atan2(-look.X, -look.Z)
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

--[[
	Setup AlignOrientation for character body rotation.
	Matches the system in ingameScript_GD that rotates the RootJoint.
]]
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

--[[
	Setup aiming state monitoring.
	Matches ingameScript_GD's aiming FOV transitions.
]]
function BaseCamera:_setupAimingCheck()
	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	if not LocalPlayer.Character then return end

	self.aim_check = LocalPlayer.Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		self:_onAimingStateChanged()
	end)
end

function BaseCamera:_onAimingStateChanged()
	if not LocalPlayer.Character then return end

	self.is_aiming = LocalPlayer.Character:GetAttribute("Aiming") or false

	-- FOV transitions
	if self.FOVTween then
		self.FOVTween:Cancel()
	end

	local targetFOV = FOV_Config.BASE
	if self.holding_breath then
		targetFOV = FOV_Config.HOLD_BREATH
	elseif self.is_aiming then
		targetFOV = FOV_Config.AIMING
	end

	self.FOVTween = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = targetFOV})
	self.FOVTween:Play()
end

--[[
	Setup hold breath state monitoring.
	Matches ingameScript_GD hold breath system.
]]
function BaseCamera:_setupHoldBreathCheck()
	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
	end

	if not LocalPlayer.Character then return end

	self.HoldBreathConnection = LocalPlayer.Character:GetAttributeChangedSignal("HoldBreathe"):Connect(function()
		self:_onHoldBreathStateChanged()
	end)
end

function BaseCamera:_onHoldBreathStateChanged()
	if not LocalPlayer.Character then return end

	self.holding_breath = LocalPlayer.Character:GetAttribute("HoldBreathe") or false
	self.hold_breathtime = tick()

	if self.FOVTween then self.FOVTween:Cancel() end

	local isAiming = LocalPlayer.Character:GetAttribute("Aiming")
	local targetFOV = self.holding_breath and FOV_Config.HOLD_BREATH or (isAiming and FOV_Config.AIMING or FOV_Config.BASE)

	self.FOVTween = TweenService:Create(Camera, 
		TweenInfo.new(HOLD_BREATH_FADE_SPEED, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
		{FieldOfView = targetFOV}
	)

	self.FOVTween:Play()
end

--[[
	Manage torso transparency for first-person mode.
	Fades out head/torso when in FP.
]]
local function first_person_transparency(character: Instance, isFirstPerson: boolean)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local transparency_connection = nil

	local function update_part(obj: BasePart, instant: boolean)
		local isEssentialBodyPart = obj.Name:find("Head") or obj.Name:find("Torso") or obj.Name:find("Root") or obj.Parent:IsA("Accessory")

		local targetValue = 0
		if isFirstPerson and isEssentialBodyPart then
			targetValue = 1
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

	-- Track new parts
	transparency_connection = character.DescendantAdded:Connect(function(obj)
		task.defer(function()
			if obj:IsA("BasePart") then
				update_part(obj, true)
			end
		end)
	end)

	return transparency_connection
end

--[[
	Setup head following camera pitch.
	Matches ingameScript_GD neck rotation (Line 3550).
]]
function BaseCamera:HeadFollowCamera_Setup()
	local character, root = self:_getCharacterParts()
	if not character then return end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then return end

	local neck: Motor6D = torso:FindFirstChild("Neck")
	if not neck or not neck:IsA("Motor6D") then return end

	self.HeadFollowEnabled = true

	local baseC0 = neck.C0
	local currentPitch = 0

	self.HeadConnection = RunService.RenderStepped:Connect(function(dt)
		if not character.Parent or not self.HeadFollowEnabled then return end

		local targetPitch = self.CameraPitch + self.RecoilPitch
		targetPitch = math.clamp(targetPitch, -NECK_PITCH_CLAMP, NECK_PITCH_CLAMP)

		local alpha = math.clamp(12 * dt, 0, 1)  -- Smooth head follow
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

	local torso = character:FindFirstChild("Torso")
	if not torso then return end

	local neck = torso:FindFirstChild("Neck")
	if neck then
		neck.C0 = neck.C0 * CFrame.Angles(0, 0, 0)
	end

	self.HeadCurrentPitch = 0
end

--[[
	Raycast to detect wall collisions.
	Matches ingameScript_GD wall detection (v_u_257, v_u_258, v_u_259).
]]
function BaseCamera:_updateCollisionAvoidance(focusPoint: Vector3, rotation: CFrame, desiredPos: Vector3)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	-- Horizontal wall collision (shoulder side)
	local horizontalRay = Workspace:Raycast(focusPoint, rotation.RightVector * 1.5, rayParams)
	self.WallDistanceX = horizontalRay and (1.5 - horizontalRay.Distance) or 0

	-- Vertical wall collision
	local verticalRay = Workspace:Raycast(focusPoint, Vector3.new(0, 5, 0), rayParams)
	self.WallDistanceY = verticalRay and math.max(0, 1 - verticalRay.Distance) or 0

	-- Backward wall collision (depth)
	local depthRay = Workspace:Raycast(focusPoint, -rotation.LookVector * 2, rayParams)
	self.WallDistanceZ = depthRay and math.max(0, 1 - depthRay.Distance) or 0
end

-- // CAMERA MODES

function BaseCamera:CustomCamera()
	self:_unbind()
	self.IsFirstPerson = false
	self.CurrentMode = "CustomCamera"
	self.TransitionProgress = 0

	local character, root = self:_getCharacterParts()
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
		local character, root = self:_getCharacterParts()
		if not root then return end

		local delta = self:_consumeMouseDelta()

		if isRightMouseDown then
			self.CameraYaw -= delta.X * MouseSensitivity

			local potentialPitch = self.CameraPitch - delta.Y * MouseSensitivity

			self.CameraPitch = math.clamp(
				potentialPitch,
				PITCH_MIN - self.RecoilPitch,
				PITCH_MAX - self.RecoilPitch
			)
		end

		local rotation = CFrame.Angles(0, self.CameraYaw, 0) * CFrame.Angles(self.CameraPitch, 0, 0)
		local cameraDir = rotation.LookVector
		local cameraFocus = root.Position + Vector3.new(0, 1.5, 0)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = Workspace:Raycast(cameraFocus, -cameraDir * currentZoom, rayParams)
		local finalZoom = currentZoom
		if rayResult then
			finalZoom = math.max(rayResult.Distance - COLLISION_MARGIN, MIN_ZOOM)
		end

		local targetCFrame = CFrame.new(cameraFocus - (cameraDir * finalZoom)) * rotation

		if self.TransitionProgress < 1 then
			self.TransitionProgress = math.min(self.TransitionProgress + dt * 4, 1)

			-- Linearly interpolate the position (prevents the "curve")
			local lerpPos = self.PreviousCameraPos:Lerp(targetCFrame.Position, self.TransitionProgress)

			-- Interpolate the rotation separately
			local lerpRot = self.PreviousCameraRotation:Lerp(targetCFrame.Rotation, self.TransitionProgress)

			-- Construct the final CFrame using the linear position and the new rotation
			Camera.CFrame = CFrame.fromMatrix(lerpPos, lerpRot.XVector, lerpRot.YVector)
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

--[[
	First Person Camera Mode.
	Full 1:1 match with ingameScript_GD first-person system.
]]
function BaseCamera:FirstPerson()
	self:_unbind()
	self.IsFirstPerson = true
	self.TransitionProgress = 0

	local character, root = self:_getCharacterParts()
	if not root then return end

	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	-- Reset recoil on mode switch
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

	self.transparency_connection = first_person_transparency(character, true)

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()

		local character, root, head, torso, humanoid = self:_getCharacterParts()
		if not root then return end

		local delta = self:_consumeMouseDelta()

		local isAiming = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Aiming") == true

		-- Sway calculation (breathing effect while idle)
		local swayTime = tick() * self.SwayFrequency
		local swayMultiplier = isAiming and (self.holding_breath and self.SwayReduction or 1) or 0
		local swayX = math.sin(swayTime) * self.SwayAmplitude * swayMultiplier
		local swayY = math.cos(swayTime * 0.5) * self.SwayAmplitude * swayMultiplier

		-- Update camera angles from input
		self.CameraYaw -= delta.X * MouseSensitivity
		local potentialPitch = self.CameraPitch - delta.Y * MouseSensitivity

		self.CameraPitch = math.clamp(
			potentialPitch,
			PITCH_MIN - self.RecoilPitch, 
			PITCH_MAX - self.RecoilPitch
		)

		-- Apply Recoil + Sway
		local finalYaw = self.CameraYaw + self.RecoilYaw + swayX
		local finalPitch = self.CameraPitch + self.RecoilPitch + swayY

		local offset = CameraOffsets.First_Person
		local focusPoint = root.Position + Vector3.new(0, offset.Y, 0)

		local targetCFrame =
			CFrame.new(focusPoint)
			* CFrame.Angles(0, finalYaw, 0)
			* CFrame.Angles(finalPitch, 0, 0)

		-- FIX: Linear lerp between positions, then apply rotation
		if self.TransitionProgress < 1 then
			self.TransitionProgress = math.min(self.TransitionProgress + dt * 4, 1)
			local lerpPos = self.PreviousCameraPos:Lerp(targetCFrame.Position, self.TransitionProgress)
			local lerpRot = self.PreviousCameraRotation:Lerp(targetCFrame.Rotation, self.TransitionProgress)
			Camera.CFrame = CFrame.fromMatrix(lerpPos, lerpRot.XVector, lerpRot.YVector)
		else
			Camera.CFrame = targetCFrame
		end

		-- Rotate character body to face camera direction
		if humanoid and humanoid.Health > 0 then
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, self.CameraYaw, 0)
		end

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)
end

--[[
	Over The Shoulder Camera Mode (PRIMARY MODE).
	FULL 1:1 MATCH with ingameScript_GD Lines 3627-3890.
	
	Features:
	- Dynamic shoulder offset (±1.5 units)
	- Wall collision avoidance (v_u_257, v_u_258, v_u_259)
	- Crouch camera adjustment
	- Turret mounting special case
	- Head following camera pitch
	- Smooth shoulder switching
	- Recoil & sway application
]]
function BaseCamera:OverTheShoulder()
	self:_unbind()
	self.IsFirstPerson = false
	self.TransitionProgress = 0

	-- Reset recoil on mode switch
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	local character, root, head, torso, humanoid = self:_getCharacterParts()
	if not root then return end

	local zoomConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			-- Matches the 1.5 to 4 zoom range logic
			self.TargetShoulderZoom = math.clamp(self.TargetShoulderZoom - (input.Position.Z), MIN_ZOOM, MAX_ZOOM)
		end
	end)

	if humanoid then humanoid.AutoRotate = false end
	if not self._align then self:_setupAlignOrientation(root) end

	self.transparency_connection = first_person_transparency(character, false)
	self:HeadFollowCamera_Setup()

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()

		local character, root, head, torso, humanoid = self:_getCharacterParts()
		if not root or not character then return end

		local delta = self:_consumeMouseDelta()

		-- 1. Input & Angles
		self.CameraYaw -= delta.X * MouseSensitivity
		local potentialPitch = self.CameraPitch - delta.Y * MouseSensitivity
		self.CameraPitch = math.clamp(potentialPitch, PITCH_MIN, PITCH_MAX)

		local rotation = CFrame.Angles(0, self.CameraYaw, 0) * CFrame.Angles(self.CameraPitch, 0, 0)

		-- 2. Shoulder & Zoom Interpolation
		self.ShoulderAlpha = self:_lerp(self.ShoulderAlpha, self.ShoulderTarget, math.clamp(self.ShoulderSwitchSpeed * dt, 0, 1))
		self.ShoulderZoom = self:_lerp(self.ShoulderZoom, self.TargetShoulderZoom, math.clamp(self.ZoomSpeed * dt, 0, 1))

		-- 3. Calculate "Ideal" Position (Where we WANT the camera to be)
		local shoulderX = CameraOffsets.Third_Person_Right.X * ((self.ShoulderAlpha * 2) - 1)
		local verticalOffset = self.is_crouching and 0.5 or 1.8 -- Adjusted for crouch height

		local focusPoint = root.Position + Vector3.new(0, verticalOffset, 0)
		local cameraOffset = (rotation.RightVector * shoulderX) + (rotation.UpVector * 0.5) - (rotation.LookVector * self.ShoulderZoom)
		local idealPosition = focusPoint + cameraOffset

		-- 4. Collision Check (Raycast/Spherecast)
		-- We cast from the focusPoint (character head area) to the idealPosition
		local rayDirection = (idealPosition - focusPoint)
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character, Camera}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		-- Spherecast is better than Raycast for cameras to prevent clipping corners
		local collisionResult = Workspace:Spherecast(focusPoint, COLLISION_MARGIN, rayDirection, rayParams)

		local finalPos = idealPosition
		if collisionResult then
			-- If hit, move camera to the hit position plus a small margin (COLLISION_MARGIN)
			finalPos = focusPoint + (rayDirection.Unit * (collisionResult.Distance))
		end

		local targetCFrame = CFrame.new(finalPos) * rotation

		-- 5. Linear Transition Fix
		if self.TransitionProgress < 1 then
			self.TransitionProgress = math.min(self.TransitionProgress + dt * 4, 1)
			local lerpPos = self.PreviousCameraPos:Lerp(targetCFrame.Position, self.TransitionProgress)
			local lerpRot = self.PreviousCameraRotation:Lerp(targetCFrame.Rotation, self.TransitionProgress)
			Camera.CFrame = CFrame.fromMatrix(lerpPos, lerpRot.XVector, lerpRot.YVector)
		else
			Camera.CFrame = targetCFrame
		end

		-- 6. Character Alignment
		if self._align then
			self._align.CFrame = CFrame.Angles(0, self.CameraYaw, 0)
		end

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		if self.CurrentMode ~= "OverTheShoulder" then
			zoomConn:Disconnect()
		end
	end)
end

-- // CAMERA SWITCHING

function BaseCamera:Switch_Camera(target: string)
	if not Presets[target] then return end

	print("[BaseCamera] Switching to camera mode:", target)

	-- Preserve camera direction when switching modes
	local look = Camera.CFrame.LookVector
	self.CameraYaw = math.atan2(-look.X, -look.Z)
	self.CameraPitch = math.asin(look.Y)

	self.PreviousCameraPos = Camera.CFrame.Position
	self.PreviousCameraRotation = Camera.CFrame.Rotation  -- Store just rotation

	self:_unbind()
	self.CurrentMode = target
	self.TransitionProgress = 0

	-- Apply preset settings
	local preset = Presets[target]
	Camera.CameraType = preset.CameraType
	Camera.FieldOfView = preset.FOV or FOV_Config.BASE
	InputService.MouseIconEnabled = preset.MouseVisible or false
	InputService.MouseBehavior = preset.MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default

	-- Disconnect old listeners
	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
		print("[BaseCamera] Disconnected HoldBreath listener")
	end

	if self.transparency_connection then
		self.transparency_connection:Disconnect()
		self.transparency_connection = nil
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		task.defer(function() humanoid.AutoRotate = preset.AutoRotate or false end)
	end

	LocalPlayer:SetAttribute("FreeLook", nil)
	-- Switch to new mode
	self[target](self)
end

-- // LIFECYCLE

function BaseCamera:_setupCharacterDeathListener(humanoid)
	if self.CharacterDeathConnection then self.CharacterDeathConnection:Disconnect() end

	self.CharacterDeathConnection = humanoid.Died:Connect(function()
		print("[BaseCamera] Character died")
		self:_resetAllTransparency()

		if self.transparency_connection then
			self.transparency_connection:Disconnect()
			self.transparency_connection = nil
		end

		self:End() 
	end)
end

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
		self.PreviousCameraRotation = Camera.CFrame.Rotation 

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

	-- Setup keybind update listeners
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

	self:HeadFollowCamera_Reject()

	if self.aim_check then
		self.aim_check:Disconnect()
		self.aim_check = nil
	end

	if self.HoldBreathConnection then
		self.HoldBreathConnection:Disconnect()
		self.HoldBreathConnection = nil
		print("[BaseCamera] HoldBreathConnection disconnected in End()")
	end

	if self.transparency_connection then
		self.transparency_connection:Disconnect()
		self.transparency_connection = nil
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

	if self._inputConn then
		self._inputConn:Disconnect()
		self._inputConn = nil
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

--[[
	Apply recoil to the camera.
	Called by weapon scripts to add bullet kick.
	Matches Util.applyRecoil() system.
]]
function BaseCamera:ApplyRecoil(vertical: number, horizontal: number)
	self.RecoilTargetPitch += vertical
	self.RecoilTargetYaw += horizontal
end

local myCamera = BaseCamera.new({
	name = "BaseCamera",
	priority = 1,
})

return BaseCamera
