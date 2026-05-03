--!strict
--!optimize 2
------------
-- @Praxitos
-- BaseCameraScript (Enhanced with Custom First Person + Original Recoil System)
------------

-- // Services
local InputService      = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local PlayerService     = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")

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

local delta = InputService:GetMouseDelta()
-- // Data
local PlayerData = LocalPlayer:WaitForChild("PlayerData")
local SettingsData = PlayerData:WaitForChild("Settings Data")
local InputData = SettingsData:WaitForChild("Input Options")
local Shoulder_Switch = InputData:WaitForChild("Shoulder Switch")
local First_Person = InputData:WaitForChild("First Person")
local Free_Look = InputData:WaitForChild("Free Look")

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
	-- This implements the original recoil_kick function behavior
	self.RecoilPitch = 0
	self.RecoilYaw = 0

	-- Target recoil amounts (what we're moving towards)
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	-- Recoil recovery/spring settings
	--self.RecoilRecoverySpeed = 10      -- How fast recoil recovers
	self.RecoilSnappiness = 100         -- How quickly we reach target recoil

	self.ShoulderZoom = CameraOffsets.Third_Person.Z
	self.TargetShoulderZoom = CameraOffsets.Third_Person.Z
	self.ZoomSpeed = 10

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
	-- Pure accumulation system (no return-to-center)

	-- Smoothly approach target (this gives you the "kick smoothing")
	local alpha = math.clamp(self.RecoilSnappiness * dt, 0, 1)

	self.RecoilPitch += (self.RecoilTargetPitch - self.RecoilPitch) * alpha
	self.RecoilYaw   += (self.RecoilTargetYaw   - self.RecoilYaw)   * alpha

	self.RecoilTargetPitch = self.RecoilPitch
	self.RecoilTargetYaw   = self.RecoilYaw
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

local function resolveKeyFromString(value: string): Enum.KeyCode?
	local keyName = string.match(value, "Enum%.KeyCode%.(.+)")
	if not keyName then
		warn("[BaseCamera] Invalid KeyCode format:", value)
		return nil
	end

	return Enum.KeyCode[keyName]
end

local function angleDifference(a: number, b: number): number
	local diff = (a - b + math.pi) % (2 * math.pi) - math.pi
	return diff
end

local function smoothLerp(a: CFrame, b: CFrame, t: number): CFrame
	local eased = t * t * (3 - 2 * t)
	return a:Lerp(b, eased)
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
		-- Hard-coded ignore list: Head and Torso parts
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
		-- Wait a frame for the part to initialize (important for tools/clothes)
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

-- // Shoulder switch (target only)
function BaseCamera:_switch_shoulder(target: string)
	if target == "Left" then
		self.ShoulderTarget = 0
	else
		self.ShoulderTarget = 1
	end

	LocalPlayer:SetAttribute("Current_Shoulder", target)
end

-- // Camera Mode
function BaseCamera:CustomCamera()
	self:_unbind()
	self.IsFirstPerson = false
	self.CurrentMode = "CustomCamera"
	self.TransitionProgress = 0 -- Reset transition for smooth entry

	local character, root, head, humanoid = self:_getCharacterParts()
	if not root then return end

	-- Cleanup Physical Constraints
	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	-- Reset Character Behavior
	first_person_transparency(character, false)
	-- Camera State
	local currentZoom = MAX_ZOOM 
	local isRightMouseDown = false
	local zoomSensitivity = 1 -- Ensure this is defined or use a constant

	LocalPlayer:SetAttribute("FreeLook", true)

	-- Input Handling
	local inputConn = InputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			currentZoom = math.clamp(
				currentZoom - (input.Position.Z * zoomSensitivity),
				MIN_ZOOM,
				MAX_ZOOM
			)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement and isRightMouseDown then
			local delta = input.Delta
			self.CameraYaw -= math.rad(delta.X * MouseSensitivity)
			self.CameraPitch = math.clamp(
				self.CameraPitch - math.rad(delta.Y * MouseSensitivity),
				PITCH_MIN,
				PITCH_MAX
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

	-- Main Update Loop
	self:_bind(function(dt)
		local _, rootPart = self:_getCharacterParts()
		if not rootPart then return end

		-- 1. Calculate the New Target Rotation & Position
		local rotation =
			CFrame.Angles(0, self.CameraYaw, 0)
			* CFrame.Angles(self.CameraPitch, 0, 0)
		local cameraDir = rotation.LookVector
		local cameraFocus = rootPart.Position + Vector3.new(0, 1.5, 0)

		-- 2. Raycast Occlusion
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayResult = Workspace:Raycast(cameraFocus, -cameraDir * currentZoom, rayParams)
		local finalZoom = currentZoom
		if rayResult then
			finalZoom = math.max(rayResult.Distance - OCCLUSION_MARGIN, MIN_ZOOM)
		end

		-- 3. Define the Ideal Target CFrame
		local targetCFrame = CFrame.new(cameraFocus - (cameraDir * finalZoom)) * rotation

		-- 4. Apply Transition (Tweening)
		if self.TransitionProgress < 1 then
			self.TransitionProgress = math.min(self.TransitionProgress + dt * CAMERA_TRANSITION_SPEED, 1)
			-- Smoothstep easing
			local eased = self.TransitionProgress * self.TransitionProgress * (3 - 2 * self.TransitionProgress)
			Camera.CFrame = self.PreviousCameraAngle:Lerp(targetCFrame, eased)
		else
			-- Full control handed over
			Camera.CFrame = targetCFrame
		end

		-- Cleanup if mode changes
		if self.CurrentMode ~= "CustomCamera" then
			inputConn:Disconnect()
			mouseConn1:Disconnect()
			mouseConn2:Disconnect()

			LocalPlayer:SetAttribute("FreeLook", false)
			self:_unbind()
		end
	end)
end

--- Custom First Person Camera - Built entirely from scratch
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

	-- HARD RESET RECOIL ON MODE SWITCH
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	self.aim_check = LocalPlayer.Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = AIMING_FOV})
		local tween1 = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = BASE_FOV})

		if LocalPlayer.Character:GetAttribute("Aiming") then
			tween:Play()
		else
			tween1:Play()
		end
	end)

	first_person_transparency(character, true)

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)

		local character, root, head, humanoid = self:_getCharacterParts()
		if not root then return end

		local delta = InputService:GetMouseDelta()
		self.CameraYaw -= math.rad(delta.X * MouseSensitivity)
		self.CameraPitch = math.clamp(
			self.CameraPitch - math.rad(delta.Y * MouseSensitivity),
			PITCH_MIN,
			PITCH_MAX
		)

		local offset = CameraOffsets.First_Person
		local focusPoint = root.Position + Vector3.new(0, offset.Y, 0)

		-- APPLY RECOIL HERE
		local finalYaw = self.CameraYaw + self.RecoilYaw
		local finalPitch = self.CameraPitch + self.RecoilPitch

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

function BaseCamera:OverTheShoulder()
	self:_unbind()
	self.IsFirstPerson = false
	self.TransitionProgress = 0

	-- HARD RESET RECOIL ON MODE SWITCH
	self.RecoilPitch = 0
	self.RecoilYaw = 0
	self.RecoilTargetPitch = 0
	self.RecoilTargetYaw = 0

	self.aim_check = LocalPlayer.Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = AIMING_FOV})
		local tween1 = TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = BASE_FOV})

		if LocalPlayer.Character:GetAttribute("Aiming") then
			tween:Play()
		else
			tween1:Play()
		end
	end)

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

	self:_bind(function(dt: number)
		self:_updateRecoil(dt)

		local character, root = self:_getCharacterParts()
		if not root then return end

		local delta = InputService:GetMouseDelta()
		self.CameraYaw -= math.rad(delta.X * MouseSensitivity)
		self.CameraPitch = math.clamp(
			self.CameraPitch - math.rad(delta.Y * MouseSensitivity),
			PITCH_MIN,
			PITCH_MAX
		)

		-- APPLY RECOIL HERE
		local finalYaw = self.CameraYaw + self.RecoilYaw
		local finalPitch = self.CameraPitch + self.RecoilPitch

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

	-- Capture rotation before unbinding so the next mode knows where we were looking
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

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		task.defer(function() humanoid.AutoRotate = preset.AutoRotate or false end)
	end

	if LocalPlayer.PlayerGui:FindFirstChild("Aiming") then
		LocalPlayer.PlayerGui.Aiming.Regular_Crosshair.Visible = preset.Cursor_UI or false
	end

	self.aim_check = nil 

	self[target](self)
	Current_Camera = target
end

-- // Lifecycle
function BaseCamera:Start()
	local character = LocalPlayer.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			self.CameraYaw = yawFromLook(root.CFrame.LookVector)
		end
	end

	self:Switch_Camera("OverTheShoulder")

	self:_switch_shoulder("Right")

	local shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
	local first_person_key = resolveKeyFromString(First_Person.Value)
	local free_look_key = resolveKeyFromString(Free_Look.Value)

	Input_Connections = {
		InputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == shoulder_switch_key then
				local current = LocalPlayer:GetAttribute("Current_Shoulder")

				if current == "Left" then
					self:_switch_shoulder("Right")
				else
					self:_switch_shoulder("Left")
				end
			elseif input.KeyCode == first_person_key then
				if Current_Camera == "FirstPerson" then
					self:Switch_Camera("OverTheShoulder")
				else
					self:Switch_Camera("FirstPerson")
				end
			elseif input.KeyCode == free_look_key then
				if Current_Camera == "CustomCamera" then
					self:Switch_Camera("OverTheShoulder")
				else
					self:Switch_Camera("CustomCamera")
				end

			end
		end),
	}

	Shoulder_Switch:GetPropertyChangedSignal("Value"):Connect(function()
		shoulder_switch_key = resolveKeyFromString(Shoulder_Switch.Value)
	end)

	First_Person:GetPropertyChangedSignal("Value"):Connect(function()
		first_person_key = resolveKeyFromString(First_Person.Value)
	end)

	Free_Look:GetPropertyChangedSignal("Value"):Connect(function()
		free_look_key = resolveKeyFromString(Free_Look.Value)
	end)
end

function BaseCamera:End()
	self:_unbind()

	if self._align then
		self._align:Destroy()
		self._align = nil
	end

	if self._alignAttachment then
		self._alignAttachment:Destroy()
		self._alignAttachment = nil
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
