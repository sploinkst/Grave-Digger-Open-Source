-- @Praxitos

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

local aiming_ui = LocalPlayer.PlayerGui:WaitForChild("Aiming"):WaitForChild("Scoped_In")
local cursor_ui = LocalPlayer.PlayerGui.Aiming.Regular_Crosshair

local CameraOffsets = {
	Third_Person_Right = { X = 1.5,  Y = 3, Z = 3 },
	Third_Person_Left  = { X = -1.5, Y = 3, Z = 3 },
	First_Person       = { X = 0,    Y = 1.5, Z = 0 },
	Turret             = { Y = 2, Z = -4 },
}

local FOV_Config = {
	BASE        = 90,
	AIMING      = 80,
	HOLD_BREATH = 60,
	MENU        = 40,
	SCOPE       = 40 / 3.5,
}

local RENDER_STEP_NAME = "BaseCamera_Update"
local RENDER_PRIORITY  = Enum.RenderPriority.Camera.Value

local CAMERA_OFFSET_LERP      = 0.075
local FOV_LERP_SPEED          = 0.1
local NECK_LERP_SPEED         = 0.05
local CHARACTER_ROTATION_LERP = 0.075
local ARM_ROTATION_LERP       = 0.1
local NECK_PITCH_CLAMP        = math.rad(75)

local MouseSensitivity = 0.004
local PITCH_MIN        = math.rad(-85)
local PITCH_MAX        = math.rad(85)

local COLLISION_MARGIN        = 0.25
local MIN_ZOOM                = 1.8
local MAX_ZOOM                = 3
local WALL_COLLISION_DISTANCE = 6.5

local HOLD_BREATH_TIME           = 3.5
local HOLD_BREATH_REGEN          = 1.0
local HOLD_BREATH_ACCURACY       = 1.5
local HOLD_BREATH_FADE_SPEED     = 0.5
local HOLD_BREATHE_RELEASE_SPEED = 0.2
local RECOIL_YANK_STRENGTH       = 16

local RECOIL_SNAPPINESS     = 100
local SHOULDER_SWITCH_SPEED = 6
local TRANSITION_SPEED      = 0.5

local hold_breath = LocalPlayer.PlayerGui:WaitForChild("Aiming"):WaitForChild("hold_breath")

local first_person_transparency_tween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local PlayerData      = LocalPlayer:WaitForChild("PlayerData")
local SettingsData    = PlayerData:WaitForChild("Settings Data")
local InputData       = SettingsData:WaitForChild("Input Options")
local Shoulder_Switch = InputData:WaitForChild("Shoulder Switch")
local First_Person    = InputData:WaitForChild("First Person")
local Free_Look       = InputData:WaitForChild("Free Look")
local isRightMouseDown = false

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local Presets = {
	OverTheShoulder = {
		CameraType     = Enum.CameraType.Custom,
		MouseLocked    = true,
		MouseVisible   = false,
		FOV            = FOV_Config.BASE,
		AutoRotate     = false,
		Cursor_UI      = true,
		Aiming_Dynamic = true,
	},
	FirstPerson = {
		CameraType     = Enum.CameraType.Custom,
		MouseLocked    = true,
		MouseVisible   = false,
		FOV            = FOV_Config.BASE,
		AutoRotate     = false,
		Cursor_UI      = true,
		Aiming_Dynamic = true,
	},
	CustomCamera = {
		CameraType     = Enum.CameraType.Custom,
		MouseLocked    = false,
		MouseVisible   = true,
		FOV            = FOV_Config.BASE,
		AutoRotate     = true,
		Cursor_UI      = false,
		Aiming_Dynamic = false,
	},
}

-- // Constructor
function BaseCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, BaseCamera)

	self.CurrentMode = nil

	self.CameraYaw   = 0
	self.CameraPitch = 0
	self.CameraKick  = 0
	self.MaxTurnRate = math.rad(700)
	self.MaxTurnRate_Transitioning = math.rad(1000)

	self.RecoilPitch       = 0
	self.RecoilYaw         = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw   = 0
	self.RecoilSnappiness  = RECOIL_SNAPPINESS

	self.ShoulderAlpha       = 1
	self.ShoulderTarget      = 1
	self.ShoulderSwitchSpeed = SHOULDER_SWITCH_SPEED

	self.IsFirstPerson = false

	self.IsTransitioning      = false
	self.TransitionStartWorld = nil
	self.TransitionElapsed    = 0

	self.ShoulderZoom       = CameraOffsets.Third_Person_Right.Z
	self.TargetShoulderZoom = CameraOffsets.Third_Person_Right.Z
	self.ZoomSpeed          = 10

	self.WallDistanceX = 0
	self.WallDistanceY = 0
	self.WallDistanceZ = 0

	self.HeadConnection    = nil
	self.HeadFollowEnabled = false
	self.HeadCurrentPitch  = 0

	self.holding_breath            = false
	self.hold_breathtime           = tick()
	self.hold_breathmax            = HOLD_BREATH_TIME
	self.hold_breathregen          = HOLD_BREATH_REGEN
	self.hold_breathaccuracy       = HOLD_BREATH_ACCURACY
	self.applied_holdbreath_recoil = false

	self.is_crouching = false
	self.is_aiming    = false
	self.shift_locked = false
	self.in_turret    = false

	self.FOVTween   = nil
	self.CurrentFOV = FOV_Config.BASE
	self.TargetFOV  = FOV_Config.BASE

	self.CharacterDeathConnection = nil
	self.InputBeganConnection     = nil
	self.CharacterAddedConnection = nil
	self.KeybindConnections       = {}
	self._mouseDelta              = Vector2.zero
	self._inputConn               = nil
	self.aim_check                = nil
	self.HoldBreathConnection     = nil
	self.sprint_check             = nil

	self._align           = nil
	self._alignAttachment = nil

	self.SwayAmplitude = 0.015
	self.SwayFrequency = 1.5
	self.SwayReduction = 0.1

	self.transparency_connection = nil
	self._shiftLockProcessed     = false

	return self
end

-- // Helpers

function BaseCamera:_unbind()
	RunService:UnbindFromRenderStep(RENDER_STEP_NAME)
end

function BaseCamera:_bind(callback)
	RunService:BindToRenderStep(RENDER_STEP_NAME, RENDER_PRIORITY, callback)
end

function BaseCamera:_getHumanoid()
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

function BaseCamera:_updateCameraKick(dt)
	self.CameraKick += (0 - self.CameraKick) * math.clamp(12 * dt, 0, 1)
end

function BaseCamera:_decayCameraOffsetZ(dt: number)
	local humanoid = self:_getHumanoid()
	if not humanoid then return end
	local co = humanoid.CameraOffset
	humanoid.CameraOffset = Vector3.new(co.X, co.Y, co.Z + (0 - co.Z) * math.clamp(8 * dt, 0, 1))
end

function BaseCamera:_applyTransition(root: BasePart, targetCFrame: CFrame, dt: number)
	if self.IsTransitioning then
		if not self.TransitionStartWorld then
			self.TransitionStartWorld = Camera.CFrame
		end

		self.TransitionElapsed += dt
		local alpha = math.clamp(self.TransitionElapsed / TRANSITION_SPEED, 0, 1)

		local lerpedCFrame = self.TransitionStartWorld:Lerp(targetCFrame, alpha)
		self.TransitionStartWorld = lerpedCFrame
		Camera.CFrame = lerpedCFrame

		if alpha >= 1 then
			Camera.CFrame             = targetCFrame
			self.IsTransitioning      = false
			self.TransitionStartWorld = nil
		end
	else
		Camera.CFrame = targetCFrame
	end
end

function BaseCamera:_updateRecoil(dt: number)
	local alpha = math.clamp(self.RecoilSnappiness * dt, 0, 1)

	local oldPitch = self.RecoilPitch
	local oldYaw   = self.RecoilYaw

	self.RecoilPitch += (self.RecoilTargetPitch - self.RecoilPitch) * alpha
	self.RecoilYaw   += (self.RecoilTargetYaw   - self.RecoilYaw)   * alpha

	self.CameraPitch += self.RecoilPitch - oldPitch
	self.CameraYaw   += self.RecoilYaw   - oldYaw

	self.RecoilPitch       = 0
	self.RecoilYaw         = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw   = 0
end

function BaseCamera:_updateHoldBreath()
	if self.holding_breath then
		self.applied_holdbreath_recoil = true
	else
		if self.applied_holdbreath_recoil == true then
			local yawDeg   = math.random(-30, 30) / 100
			local yawDeg2  = math.random(-30, 30) / 100
			local pitchRad = 0.006981317007977318

			self:ApplyRecoil(-pitchRad, -math.rad(yawDeg), 6)
			task.delay(6 * 0.015, function()
				self:ApplyRecoil(pitchRad, math.rad(yawDeg2), 6)
			end)

			self.applied_holdbreath_recoil = false
		end
	end
end

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

	InputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRightMouseDown = true
			InputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
	end)

	InputService.InputEnded:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRightMouseDown = false
			InputService.MouseBehavior = Enum.MouseBehavior.Default
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
			self._mouseDelta += Vector2.new(delta.X * MouseSensitivity, delta.Y * MouseSensitivity)
		end
	end)
end

function BaseCamera:_refreshKeybinds()
	self.shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
	self.first_person_key    = resolveKeyFromString(First_Person.Value)
	self.free_look_key       = resolveKeyFromString(Free_Look.Value)
end

function BaseCamera:_getCharacterParts()
	local character = LocalPlayer.Character
	if not character then return nil end

	local root     = character:FindFirstChild("HumanoidRootPart")
	local head     = character:FindFirstChild("Head")
	local torso    = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not root or not head or not humanoid then return nil end

	return character, root, head, torso, humanoid
end

local function yawFromLook(look: Vector3): number
	return math.atan2(-look.X, -look.Z)
end

function BaseCamera:_switch_shoulder(target: string)
	self.ShoulderTarget = (target == "Left") and 0 or 1
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

function BaseCamera:_setupAlignOrientation(root: BasePart)
	local existing = root:FindFirstChild("CameraAlign")
	if existing then existing:Destroy() end

	local att = Instance.new("Attachment")
	att.Name   = "CameraAlignAttachment"
	att.Parent = root

	local align = Instance.new("AlignOrientation")
	align.Name                  = "CameraAlign"
	align.Mode                  = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0           = att
	align.MaxAngularVelocity    = 80
	align.MaxTorque             = 500000
	align.Responsiveness        = 200
	align.AlignType             = Enum.AlignType.AllAxes
	align.ReactionTorqueEnabled = false
	align.RigidityEnabled       = false
	align.Parent                = root

	self._align           = align
	self._alignAttachment = att
end

function BaseCamera:_updateCharacterRotation(root: BasePart, dt: number)
	local targetYaw = self.CameraYaw

	local diff = math.atan2(
		math.sin(targetYaw - self.CharacterYaw),
		math.cos(targetYaw - self.CharacterYaw)
	)

	local character = LocalPlayer.Character
	local maxRate

	if self.IsTransitioning then
		maxRate = self.MaxTurnRate_Transitioning
	elseif character then
		local isCharging   = character:GetAttribute("charging")   == true
		local isSlowRotate = character:GetAttribute("slow_rotate") == true
		local isFallIntr   = character:GetAttribute("fall_damage_interrupt") == true
		local perk         = character:GetAttribute("perk")  or ""
		local class        = character:GetAttribute("class") or ""
		local hasLancer    = character:FindFirstChild("elitekit") and
			character.elitekit.Value == "lancer"
		local aiming       = character:GetAttribute("aiming") == true

		if isCharging or isFallIntr then
			if (perk == "butcher" or perk == "vet" or hasLancer) and class == "lancer" then
				maxRate = math.rad(6)
			else
				maxRate = math.rad(2)
			end
		elseif isSlowRotate then
			maxRate = math.rad(12)
		elseif aiming then
			maxRate = math.rad(850)
		else
			maxRate = math.rad(800)
		end
	else
		maxRate = math.rad(800)
	end

	local responsivenessAlpha = math.clamp((maxRate / math.rad(100)) * 10 * dt, 0, 1)

	local desiredStep = math.clamp(
		diff * responsivenessAlpha,
		-maxRate * dt,
		maxRate * dt
	)

	self.CharacterYaw += desiredStep
	root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, self.CharacterYaw, 0)
end

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

	local humanoid  = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local walkSpeed = humanoid and humanoid.WalkSpeed or 10
	local alpha     = math.clamp((walkSpeed - 10) / (18 - 10), 0, 1)
	local sprintFOV = 90 + (15 * alpha)

	if self.holding_breath then
		self.TargetFOV = FOV_Config.HOLD_BREATH
	elseif self.is_aiming then
		self.TargetFOV = FOV_Config.AIMING
	else
		self.TargetFOV = sprintFOV
	end

	if self.FOVTween then self.FOVTween:Cancel() end
	self.FOVTween = TweenService:Create(Camera,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = self.TargetFOV }
	)
	self.FOVTween:Play()
end

function BaseCamera:_setupSprintCheck()
	if self.sprint_check then
		self.sprint_check:Disconnect()
		self.sprint_check = nil
	end
	local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	self.sprint_check = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		self:_onSprintStateChanged(humanoid.WalkSpeed)
	end)
	self:_onSprintStateChanged(humanoid.WalkSpeed)
end

function BaseCamera:_onSprintStateChanged(walkSpeed)
	if not LocalPlayer.Character then return end

	local alpha     = math.clamp((walkSpeed - 10) / (18 - 10), 0, 1)
	local sprintFOV = 90 + (15 * alpha)

	if self.holding_breath then
		self.TargetFOV = FOV_Config.HOLD_BREATH
	elseif self.is_aiming then
		self.TargetFOV = FOV_Config.AIMING
	else
		self.TargetFOV = sprintFOV
	end

	if self.FOVTween then self.FOVTween:Cancel() end
	self.FOVTween = TweenService:Create(Camera,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = self.TargetFOV }
	)
	self.FOVTween:Play()
end

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

	self.holding_breath  = LocalPlayer.Character:GetAttribute("HoldBreathe") or false
	self.hold_breathtime = tick()

	local humanoid  = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local walkSpeed = humanoid and humanoid.WalkSpeed or 10
	local alpha     = math.clamp((walkSpeed - 10) / (18 - 10), 0, 1)
	local sprintFOV = 90 + (10 * alpha)

	if self.holding_breath then
		self.TargetFOV = FOV_Config.HOLD_BREATH
	elseif self.is_aiming then
		self.TargetFOV = FOV_Config.AIMING
	else
		self.TargetFOV = sprintFOV
	end

	local fade_speed         = self.holding_breath and HOLD_BREATH_FADE_SPEED or HOLD_BREATHE_RELEASE_SPEED
	local targetTransparency = self.holding_breath and 0 or 1

	if self.FOVTween  then self.FOVTween:Cancel()  end
	if self.FOVTween2 then self.FOVTween2:Cancel() end

	self.FOVTween = TweenService:Create(Camera,
		TweenInfo.new(fade_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ FieldOfView = self.TargetFOV }
	)
	self.FOVTween2 = TweenService:Create(hold_breath,
		TweenInfo.new(fade_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ ImageTransparency = targetTransparency }
	)
	self.FOVTween:Play()
	self.FOVTween2:Play()
end

local transparency_table = {
	Head  = true,
	Torso = true,
}

local transparency_connections  = {}
local original_transparencies   = {}

local function should_hide(part)
	if transparency_table[part.Name] or part.Name == "Handle" then
		return true
	end

	local parent      = part.Parent
	local grandparent = parent and parent.Parent

	if parent and transparency_table[parent.Name] then
		return true
	end

	if grandparent and transparency_table[grandparent.Name] then
		return true
	end

	local current = part
	while current do
		if string.find(current.Name, "Helmet", 1, true) then
			local p  = current.Parent
			local gp = p and p.Parent
			if (p and p.Name == "Equipment") or (gp and gp.Name == "Equipment") then
				return true
			end
		end
		current = current.Parent
	end

	return false
end

local function handle_object(part, isFirstPerson)
	if not part:IsA("BasePart") then return end
	if part:GetAttribute("Transparency_Skip") then return end

	local hide        = should_hide(part)
	local parent      = part.Parent
	local grandparent = parent and parent.Parent

	if grandparent and grandparent.Name == "Rendered_Holsters" then
		hide = true
		for part_name in pairs(transparency_table) do
			if string.find(part.Name, part_name, 1, true) then
				hide = false
				break
			end
		end
	end

	if not hide then return end

	if original_transparencies[part] == nil then
		original_transparencies[part] = part.Transparency
	end

	local targetTransparency = isFirstPerson and 1 or original_transparencies[part]

	TweenService:Create(part, first_person_transparency_tween, { Transparency = targetTransparency }):Play()

	if transparency_connections[part] then
		transparency_connections[part]:Disconnect()
		transparency_connections[part] = nil
	end

	if isFirstPerson then
		transparency_connections[part] = part:GetPropertyChangedSignal("Transparency"):Connect(function()
			if part.Parent and part.Transparency ~= 1 then
				if part.Transparency < 0.95 then
					part.Transparency = 1
				end
			end
		end)
	end
end

local transparency_descendant_connection

local function first_person_transparency(character: Instance, isFirstPerson: boolean)
	if transparency_descendant_connection then
		transparency_descendant_connection:Disconnect()
		transparency_descendant_connection = nil
	end

	for part, connection in pairs(transparency_connections) do
		connection:Disconnect()
		transparency_connections[part] = nil
	end

	-- Only modify transparency when entering first person.
	-- When leaving first person, restore ONLY parts we personally hid,
	-- then bail out without touching anything else or setting up watchers.
	if not isFirstPerson then
		for part, originalTransparency in pairs(original_transparencies) do
			if part and part.Parent then
				TweenService:Create(part, first_person_transparency_tween, { Transparency = originalTransparency }):Play()
			end
		end
		original_transparencies = {}
		return
	end

	for _, part in ipairs(character:GetDescendants()) do
		handle_object(part, isFirstPerson)
	end

	transparency_descendant_connection = character.DescendantAdded:Connect(function(descendant)
		task.defer(function()
			if not descendant.Parent then return end
			handle_object(descendant, isFirstPerson)
			for _, obj in ipairs(descendant:GetDescendants()) do
				handle_object(obj, isFirstPerson)
			end
		end)
	end)
end

-- // Head Follow

function BaseCamera:HeadFollowCamera_Setup()
	local character, root = self:_getCharacterParts()
	if not character then return end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then return end

	local neck: Motor6D = torso:FindFirstChild("Neck")
	if not neck or not neck:IsA("Motor6D") then return end

	self.HeadFollowEnabled = true
	local baseC0       = neck.C0
	local currentPitch = 0

	self.HeadConnection = RunService.RenderStepped:Connect(function(dt)
		if not character.Parent or not self.HeadFollowEnabled then return end
		local targetPitch = math.clamp(self.CameraPitch + self.RecoilPitch, -NECK_PITCH_CLAMP, NECK_PITCH_CLAMP)
		local alpha = math.clamp(12 * dt, 0, 1)
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
	if neck then neck.C0 = neck.C0 * CFrame.Angles(0, 0, 0) end
	self.HeadCurrentPitch = 0
end

function BaseCamera:_updateCollisionAvoidance(focusPoint: Vector3, rotation: CFrame, desiredPos: Vector3)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local hRay = Workspace:Raycast(focusPoint, rotation.RightVector * 1.5, rayParams)
	self.WallDistanceX = hRay and (1.5 - hRay.Distance) or 0

	local vRay = Workspace:Raycast(focusPoint, Vector3.new(0, 5, 0), rayParams)
	self.WallDistanceY = vRay and math.max(0, 1 - vRay.Distance) or 0

	local dRay = Workspace:Raycast(focusPoint, -rotation.LookVector * 2, rayParams)
	self.WallDistanceZ = dRay and math.max(0, 1 - dRay.Distance) or 0
end

-- // CAMERA MODES

function BaseCamera:CustomCamera()
	self:_unbind()
	self.IsFirstPerson = false
	self.CurrentMode   = "CustomCamera"

	local character, root = self:_getCharacterParts()
	if not root then return end

	if self._align then self._align:Destroy(); self._align = nil end
	self:_resetAllTransparency()

	local currentZoom     = MAX_ZOOM
	local zoomSensitivity = 1

	LocalPlayer:SetAttribute("FreeLook", true)

	local zoomConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			currentZoom = math.clamp(
				currentZoom - (input.Position.Z * zoomSensitivity),
				MIN_ZOOM, MAX_ZOOM * 1.8
			)
		end
	end)

	self.transparency_connection = first_person_transparency(character, false)

	self:_bind(function(dt)
		local character, root = self:_getCharacterParts()
		if not root then return end

		local delta = self:_consumeMouseDelta()

		if isRightMouseDown then
			self.CameraYaw -= delta.X
			self.CameraPitch = math.clamp(
				self.CameraPitch - delta.Y,
				PITCH_MIN - self.RecoilPitch,
				PITCH_MAX - self.RecoilPitch
			)
		end

		local rotation    = CFrame.Angles(0, self.CameraYaw, 0) * CFrame.Angles(self.CameraPitch, 0, 0)
		local cameraDir   = rotation.LookVector
		local cameraFocus = root.Position + Vector3.new(0, 1.5, 0)

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { character }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = Workspace:Raycast(cameraFocus, -cameraDir * currentZoom, rayParams)
		local finalZoom = currentZoom
		if rayResult then finalZoom = math.max(rayResult.Distance - COLLISION_MARGIN, MIN_ZOOM) end

		local targetCFrame = CFrame.new(cameraFocus - (cameraDir * finalZoom)) * rotation
		self:_applyTransition(root, targetCFrame, dt)

		if self.CurrentMode ~= "CustomCamera" then
			zoomConn:Disconnect()
			LocalPlayer:SetAttribute("FreeLook", false)
			self:_unbind()
		end
	end)
end

function BaseCamera:FirstPerson()
	self:_unbind()

	self.IsFirstPerson = true
	self.CurrentMode   = "FirstPerson"

	local character, root, head, torso, humanoid = self:_getCharacterParts()
	if not root or not character then return end

	self.RecoilPitch       = 0
	self.RecoilYaw         = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw   = 0
	self.CameraKick        = 0

	if humanoid then
		local co = humanoid.CameraOffset
		humanoid.CameraOffset = Vector3.new(co.X, co.Y, 0)
	end

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	self:_setupAimingCheck()
	self:_setupHoldBreathCheck()
	self:_setupSprintCheck()

	LocalPlayer:SetAttribute("FirstPerson", true)
	self.transparency_connection = first_person_transparency(character, true)

	self:_bind(function(dt)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()
		self:_updateCameraKick(dt)
		self:_decayCameraOffsetZ(dt)

		local character, root, head, torso, humanoid = self:_getCharacterParts()
		if not root or not head then return end

		local delta = self:_consumeMouseDelta()

		self.CameraYaw -= delta.X
		self.CameraPitch = math.clamp(
			self.CameraPitch - delta.Y,
			PITCH_MIN,
			PITCH_MAX
		)

		if humanoid and humanoid.Health > 0 then
			self.CharacterYaw = self.CameraYaw
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, self.CharacterYaw, 0)
		end

		local cameraPosition = root.Position + Vector3.new(0, 1.5, 0)

		local rotation =
			CFrame.Angles(0, self.CameraYaw, 0)
			* CFrame.Angles(self.CameraPitch, 0, 0)

		local kickOffset = -rotation.LookVector * self.CameraKick

		local targetCFrame =
			CFrame.new(cameraPosition + kickOffset)
			* rotation

		self:_applyTransition(root, targetCFrame, dt)

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)
end

function BaseCamera:OverTheShoulder()
	self:_unbind()

	self.IsFirstPerson = false

	self.RecoilPitch       = 0
	self.RecoilYaw         = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw   = 0

	local hum = self:_getHumanoid()
	if hum then
		local co = hum.CameraOffset
		hum.CameraOffset = Vector3.new(co.X, co.Y, 0)
	end

	if self.FOVTween then
		self.FOVTween:Cancel()
		self.FOVTween = nil
	end

	local character, root, head, torso, humanoid = self:_getCharacterParts()
	if not root then return end

	local zoomConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.TargetShoulderZoom = math.clamp(
				self.TargetShoulderZoom - (input.Position.Z * 1.5),
				MIN_ZOOM,
				MAX_ZOOM
			)
		end
	end)

	if humanoid then
		humanoid.AutoRotate = false
	end

	self.transparency_connection = first_person_transparency(character, false)

	self:HeadFollowCamera_Setup()
	self:_setupAimingCheck()
	self:_setupHoldBreathCheck()
	self:_setupSprintCheck()

	self:_bind(function(dt)
		self:_updateRecoil(dt)
		self:_updateHoldBreath()
		self:_updateCameraKick(dt)
		self:_decayCameraOffsetZ(dt)

		local character, root, head, torso, humanoid = self:_getCharacterParts()
		if not root or not character then return end

		local delta = self:_consumeMouseDelta()

		self.CameraYaw -= delta.X
		self.CameraPitch = math.clamp(
			self.CameraPitch - delta.Y,
			PITCH_MIN,
			PITCH_MAX
		)

		local rotation =
			CFrame.Angles(0, self.CameraYaw, 0)
			* CFrame.Angles(self.CameraPitch, 0, 0)

		self.ShoulderAlpha = self:_lerp(
			self.ShoulderAlpha,
			self.ShoulderTarget,
			math.clamp(self.ShoulderSwitchSpeed * dt, 0, 1)
		)

		self.ShoulderZoom = self:_lerp(
			self.ShoulderZoom,
			self.TargetShoulderZoom,
			math.clamp(self.ZoomSpeed * dt, 0, 1)
		)

		local shoulderX      = CameraOffsets.Third_Person_Right.X * ((self.ShoulderAlpha * 2) - 1)
		local verticalOffset = self.is_crouching and 0.5 or 1.8
		local focusPoint     = root.Position + Vector3.new(0, verticalOffset, 0)

		local cameraOffset =
			(rotation.RightVector * shoulderX)
			+ (rotation.UpVector * 0.5)
		- (rotation.LookVector * self.ShoulderZoom)

		local idealPosition = focusPoint + cameraOffset
		local rayDirection  = idealPosition - focusPoint

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = { character, Workspace.CurrentCamera }
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local collisionResult = Workspace:Spherecast(focusPoint, COLLISION_MARGIN, rayDirection, rayParams)

		local finalPos = idealPosition
		if collisionResult then
			finalPos = focusPoint + (rayDirection.Unit * collisionResult.Distance)
		end

		local kickOffset =
			(-rotation.LookVector * self.CameraKick)
			+ (rotation.UpVector * (self.CameraKick * 0.15))

		local targetCFrame = CFrame.new(finalPos + kickOffset) * rotation

		self:_applyTransition(root, targetCFrame, dt)
		self:_updateCharacterRotation(root, dt)

		InputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		if self.CurrentMode ~= "OverTheShoulder" then
			zoomConn:Disconnect()
		end
	end)
end

-- // CAMERA SWITCHING

function BaseCamera:Switch_Camera(target: string)
	if not Presets[target] then return end

	local look = Camera.CFrame.LookVector
	self.CameraYaw   = math.atan2(-look.X, -look.Z)
	self.CameraPitch = math.asin(math.clamp(look.Y, -1, 1))

	self.TransitionStartWorld = Camera.CFrame
	self.IsTransitioning      = true
	self.TransitionElapsed    = 0
	self.CurrentMode          = target

	local preset = Presets[target]
	Camera.CameraType             = preset.CameraType
	Camera.FieldOfView            = self.TargetFOV or preset.FOV or FOV_Config.BASE
	InputService.MouseIconEnabled = preset.MouseVisible or false
	InputService.MouseBehavior    = preset.MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default

	if self.aim_check            then self.aim_check:Disconnect();            self.aim_check            = nil end
	if self.HoldBreathConnection then self.HoldBreathConnection:Disconnect(); self.HoldBreathConnection = nil end
	if self.transparency_connection then self.transparency_connection:Disconnect(); self.transparency_connection = nil end

	local character = LocalPlayer.Character
	local humanoid  = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then task.defer(function() humanoid.AutoRotate = preset.AutoRotate or false end) end

	cursor_ui.Visible = preset.Cursor_UI and not character:GetAttribute("Aiming") or false
	LocalPlayer:SetAttribute("FreeLook", nil)
	LocalPlayer:SetAttribute("FirstPerson", nil)

	for part, connection in pairs(transparency_connections) do
		connection:Disconnect()
		transparency_connections[part] = nil
	end

	self:_unbind()
	self[target](self)
end

-- // LIFECYCLE

function BaseCamera:_setupCharacterDeathListener(humanoid)
	if self.CharacterDeathConnection then self.CharacterDeathConnection:Disconnect() end
	self.CharacterDeathConnection = humanoid.Died:Connect(function()
		self:_resetAllTransparency()
		if self.transparency_connection then
			self.transparency_connection:Disconnect()
			self.transparency_connection = nil
		end
		self:End()
	end)
end

function BaseCamera:_snapCameraToCharacter()
	local character = LocalPlayer.Character
	local root      = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local snapCFrame =
		CFrame.new(root.Position + Vector3.new(0, 1.8, 0))
		* CFrame.Angles(0, self.CameraYaw, 0)
		* CFrame.Angles(self.CameraPitch, 0, 0)

	Camera.CFrame             = snapCFrame
	self.TransitionStartWorld = snapCFrame
end

function BaseCamera:Start()
	print("CameraService: BaseCamera started")

	self.IsTransitioning      = false
	self.TransitionStartWorld = nil
	self.TransitionElapsed    = 0

	local function onCharacterAdded(character)
		self:_refreshKeybinds()
		self:_setupInput()
		self:_setupMouseInput()

		local root     = character:WaitForChild("HumanoidRootPart", 5)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not root or not humanoid then return end

		self.CameraYaw         = yawFromLook(root.CFrame.LookVector)
		self.CharacterYaw      = self.CameraYaw
		self.CameraPitch       = 0
		self.RecoilPitch       = 0
		self.RecoilYaw         = 0
		self.RecoilTargetPitch = 0
		self.RecoilTargetYaw   = 0
		self.IsTransitioning   = false
		self.TransitionElapsed = 0
		self.holding_breath    = false
		self.hold_breathtime   = tick()

		humanoid.AutoRotate   = false
		humanoid.CameraOffset = Vector3.new(0, 0, 0)

		self:_setupCharacterDeathListener(humanoid)
		self:_snapCameraToCharacter()
		self:Switch_Camera("OverTheShoulder")
		self:_switch_shoulder("Right")
		self:_resetAllTransparency()
	end

	if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

	self.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

	local function updateKeys()
		self.shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
		self.first_person_key    = resolveKeyFromString(First_Person.Value)
		self.free_look_key       = resolveKeyFromString(Free_Look.Value)
	end

	updateKeys()
	table.insert(self.KeybindConnections, Shoulder_Switch:GetPropertyChangedSignal("Value"):Connect(updateKeys))
	table.insert(self.KeybindConnections, First_Person:GetPropertyChangedSignal("Value"):Connect(updateKeys))
	table.insert(self.KeybindConnections, Free_Look:GetPropertyChangedSignal("Value"):Connect(updateKeys))

	self:_setupInput()
end

function BaseCamera:Resume()
	print("CameraService: BaseCamera resumed")

	-- reset any leftover transition state from when we were paused
	self.IsTransitioning      = false
	self.TransitionStartWorld = nil
	self.TransitionElapsed    = 0

	-- read current yaw from root so we face the right direction immediately
	local character = LocalPlayer.Character
	local root      = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		self.CameraYaw    = yawFromLook(root.CFrame.LookVector)
		self.CharacterYaw = self.CameraYaw
		self.CameraPitch  = 0
	end

	-- snap camera to character so there is zero void time
	self:_snapCameraToCharacter()

	-- restore FOV in case MenuCamera changed it
	Camera.FieldOfView = self.TargetFOV or FOV_Config.BASE

	-- re-wire connections that End() tore down
	self:_refreshKeybinds()
	self:_setupInput()
	self:_setupMouseInput()

	local humanoid = self:_getHumanoid()
	if humanoid then
		self:_setupCharacterDeathListener(humanoid)
		humanoid.AutoRotate   = false
		humanoid.CameraOffset = Vector3.new(0, 0, 0)
	end

	-- jump straight into the last mode (or default to OTS)
	local resumeMode = self.CurrentMode or "OverTheShoulder"
	self:Switch_Camera(resumeMode)
	self:_switch_shoulder(LocalPlayer:GetAttribute("Current_Shoulder") or "Right")
	self:_resetAllTransparency()
end

function BaseCamera:End()
	print("CameraService: BaseCamera ended")
	self:_unbind()

	Camera.CameraType             = Enum.CameraType.Custom
	Camera.FieldOfView            = FOV_Config.BASE
	InputService.MouseIconEnabled = true
	InputService.MouseBehavior    = Enum.MouseBehavior.Default

	cursor_ui.Visible = false
	LocalPlayer:SetAttribute("FreeLook", nil)
	LocalPlayer:SetAttribute("FirstPerson", nil)

	if self.FOVTween  then self.FOVTween:Cancel();  self.FOVTween  = nil end
	if self.FOVTween2 then self.FOVTween2:Cancel(); self.FOVTween2 = nil end

	if self.CharacterDeathConnection then self.CharacterDeathConnection:Disconnect(); self.CharacterDeathConnection = nil end

	self:HeadFollowCamera_Reject()

	if self.aim_check            then self.aim_check:Disconnect();            self.aim_check            = nil end
	if self.HoldBreathConnection then self.HoldBreathConnection:Disconnect(); self.HoldBreathConnection = nil end
	if self.sprint_check         then self.sprint_check:Disconnect();         self.sprint_check         = nil end
	if self.transparency_connection then self.transparency_connection:Disconnect(); self.transparency_connection = nil end
	if self._align           then self._align:Destroy();           self._align           = nil end
	if self._alignAttachment then self._alignAttachment:Destroy(); self._alignAttachment = nil end
	if self.InputBeganConnection then self.InputBeganConnection:Disconnect(); self.InputBeganConnection = nil end
	if self._inputConn       then self._inputConn:Disconnect();       self._inputConn       = nil end

	if self.KeybindConnections then
		for _, c in ipairs(self.KeybindConnections) do c:Disconnect() end
		self.KeybindConnections = {}
	end

	for part, connection in pairs(transparency_connections) do
		connection:Disconnect()
		transparency_connections[part] = nil
	end
end

function BaseCamera:Cut()
	self:End()
end

function BaseCamera:ApplyRecoil(vertical: number, horizontal: number, steps: number?, doRoll: boolean?)
	steps = steps or 6

	local totalSteps   = steps + 1
	local stepInterval = 0.015
	local elapsed      = 0
	local stepsApplied = 0

	if doRoll then
		local rollSteps   = 0
		local rollElapsed = 0
		local rollConn
		rollConn = RunService.RenderStepped:Connect(function(dt)
			if rollSteps >= 4 then rollConn:Disconnect(); return end
			rollElapsed += dt
			local due = math.floor(rollElapsed / stepInterval)
			for _ = 1, math.min(due - rollSteps, 4 - rollSteps) do
				Camera.CFrame *= CFrame.Angles(0, 0, math.rad(2))
				rollSteps += 1
			end
		end)
	end

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if stepsApplied >= totalSteps then conn:Disconnect(); return end

		elapsed += dt
		local due = math.floor(elapsed / stepInterval)

		for _ = 1, math.min(due - stepsApplied, totalSteps - stepsApplied) do
			if self.holding_breath then
				self.CameraPitch += vertical   * 0.5
				self.CameraYaw   += horizontal * 0.5
				self.CameraKick  += 0.15
			else
				self.CameraPitch += vertical
				self.CameraYaw   += horizontal
				self.CameraKick  += 0.15
			end
			stepsApplied += 1
		end
	end)
end

local myCamera = BaseCamera.new({
	name     = "BaseCamera",
	priority = 1,
})

return BaseCamera