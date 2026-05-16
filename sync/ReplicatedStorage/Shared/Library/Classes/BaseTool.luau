--!native
--!optimize 2

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")

local Types            = require(script.Parent.Parent.Types)
local utilities_module = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util")
)

local LOCAL_PLAYER = Players.LocalPlayer

local Assets         = ReplicatedStorage.Shared.Assets
local FxFolder       = Assets.Guns.Effects.Shooting

local FX_BULLET_HOLE = FxFolder.BulletHole
local FX_WOOD_CHIPS  = FxFolder.Parent.Environment.Wood_Chips

local replicant_service = require(ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService)
local events_replication_folder = ReplicatedStorage.Shared.Library.Events.Replicant_Communication
local fast_cast_replication     = events_replication_folder.FastCast_Connection
local hit_connection            = events_replication_folder.Hit_Connection
local vfx_cast_event            = events_replication_folder.VFX_Connection
local sfx_cast_event            = events_replication_folder.SFX_Connection
local texture_event             = events_replication_folder.Texture_Connection

local gun_communication = events_replication_folder.Parent.Gun_Communication
local drop_connection = gun_communication.Drop_Connection

local general_sfx = ReplicatedStorage.Shared.Assets.Guns.Sounds.Shared

local bullet_warning_part = ReplicatedStorage.Shared.Assets.UI.Warning_Barrel

-- // Tuning (shared defaults; subclasses can override on self)

local AIM_PITCH_LIMIT  = math.rad(60)
local AIM_LERP_ALPHA   = 0.1
local MOTOR_LERP_ALPHA = 0.15
local MOTOR_SNAP_DIST  = 0.001

-- Hard-cut blend time. 0 = instant cuts.
local CUT = 0.15

--------------------------------------------------------------------------------
-- Penetration profiles
--------------------------------------------------------------------------------

local Penetration_Profiles = {
	[4] = { Stud_Limit = 4, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 70 },
	[3] = { Stud_Limit = 3, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 50 },
	[2] = { Stud_Limit = 2, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 30 },
	[1] = { Stud_Limit = 1, Materials = {},                                                Distance_Limiter = 0  },
}

--------------------------------------------------------------------------------
-- BaseTool
--------------------------------------------------------------------------------

local BaseTool = {}
BaseTool.__index = BaseTool

export type BaseTool = typeof(setmetatable({} :: {
	className: "BaseTool",
	name: string,

	-- core
	tool: Tool?,
	model_reference: Model?,
	actual_model: Model?,

	-- holster
	holster_reference: Instance?,
	actual_holster: Model?,

	-- animations
	animations: { [string]: Animation }?,
	RegisteredAnimations: { [string]: AnimationTrack }?,

	-- animation layer table (subclass defines; BaseTool uses for _playAnim/_stopLayer)
	ANIM_LAYERS: { [string]: number }?,

	-- motor6d
	motor_6d_data: {
		Parent: string,
		Part0:  string,
		Part1:  string | BasePart,
		C0:     CFrame,
	}?,
	motor_6d:       Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,

	-- shoulder / aim state
	current_shoulder: string,
	Aiming:           boolean,
	_aimVersion:      number,
	_aimConnection:   RBXScriptConnection?,
	_leftShoulder:    Motor6D?,
	_rightShoulder:   Motor6D?,
	_leftShoulderC0:  CFrame?,
	_rightShoulderC0: CFrame?,

	-- busy flags (subclass sets these; _isBusy reads them)
	Firing:    boolean,
	Reloading: boolean,
	Cycling:   boolean,
	Alting:    boolean,
	Spinning:  boolean,

	-- internal
	_activationConnection: RBXScriptConnection?,
	_inputBeganConn:       RBXScriptConnection?,
	_inputEndedConn:       RBXScriptConnection?,
	_shoulderChangedConn:  RBXScriptConnection?,
	character_connection:  RBXScriptConnection?,

	-- fastcast
	Caster:         any?,
	CasterBehavior: any?,

	-- equipped state
	Equipped:  boolean?,
	Equipping: boolean?,
}, {} :: typeof(BaseTool)))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function BaseTool.new(BaseToolCreateInfo: Types.BaseToolCreateInfo): BaseTool
	local self = setmetatable({}, BaseTool)

	self.className = "BaseTool"
	self.name      = BaseToolCreateInfo.name

	self.tool           = nil
	self.actual_model   = nil
	self.actual_holster = nil
	self.RegisteredAnimations = nil

	-- Aim state
	self.Aiming           = false
	self._aimVersion      = 0
	self.current_shoulder = "Right"

	-- Busy flags (subclass overrides)
	self.Firing    = false
	self.Reloading = false
	self.Cycling   = false
	self.Alting    = false
	self.Spinning  = false

	-- Equipped state
	self.Equipped  = false
	self.Equipping = false

	-- Internal connections
	self._activationConnection = nil
	self._inputBeganConn       = nil
	self._inputEndedConn       = nil
	self._shoulderChangedConn  = nil
	self._aimConnection        = nil

	self._shortTrack = nil
	self._shortActive = false
	self._shortAlpha = 0
	
	self.ForceBlockFire = false
	-- FastCast (initialized by subclass)
	self.Caster         = nil
	self.CasterBehavior = nil

	return self
end

--------------------------------------------------------------------------------
-- Lifecycle: on_give
--------------------------------------------------------------------------------

function BaseTool:on_give(tool: Tool, holster: Model?, model: Model?)
	self.tool = tool

	if self.animations then
		self.RegisteredAnimations = utilities_module.register_animations(LOCAL_PLAYER, self.animations)
		if not self.RegisteredAnimations then
			warn("[" .. self.className .. "] Failed to register animations")
		end
	end

	if holster then
		self.actual_holster = holster
	elseif self.holster_reference then
		self.actual_holster = utilities_module.reverse_search_holster(LOCAL_PLAYER, self.holster_reference.Name)
	else
		warn("[" .. self.className .. "] Missing holster_reference")
	end

	if self._activationConnection then
		self._activationConnection:Disconnect()
	end
	self._activationConnection = tool.Activated:Connect(function()
		self:activate()
	end)

	if self._on_give then
		self:_on_give(tool, holster, model)
	end
end

--------------------------------------------------------------------------------
-- Short Mechanic
--------------------------------------------------------------------------------
function BaseTool:GetBarrelWarningPart(muzzle)
	local clone = bullet_warning_part:Clone()
	clone.CanQuery = false

	-- ensure attachments exist on the warning part
	local hitAttach = Instance.new("Attachment")
	hitAttach.Name = "HitWarningAttach"
	hitAttach.Parent = clone

	clone:SetAttribute("HitAttachName", hitAttach.Name)

	return clone
end

function BaseTool:init_short_mechanic()
	if not self.RegisteredAnimations.Short then return end
	
	print("[BASETOOL] init_short_mechanic called")

	local RunService = game:GetService("RunService")

	local short_distance = self.Short_Distance or 2.3
	local barrelWarning = self:GetBarrelWarningPart()

	if not barrelWarning then
		warn("[BASETOOL] ERROR: barrelWarning missing")
		return
	end

	local warning_beam = barrelWarning:FindFirstChild("warningbeam", true)
	local billboard_ui = barrelWarning:FindFirstChild("x", true)

	local muzzleAttach = Instance.new("Attachment")
	muzzleAttach.Name = "MuzzleWarningAttach"

	local hitAttach = barrelWarning:FindFirstChild("HitWarningAttach", true)
	if not hitAttach then
		hitAttach = Instance.new("Attachment")
		hitAttach.Name = "HitWarningAttach"
		hitAttach.Parent = barrelWarning
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude

	if self.short_connection then
		self.short_connection:Disconnect()
	end

	local lastState = "default"

	local function clearMuzzleFX()
		if warning_beam then warning_beam.Enabled = false end
		if billboard_ui then billboard_ui.Enabled = false end
		if barrelWarning.Parent then barrelWarning.Parent = nil end
		muzzleAttach.Parent = nil
		hitAttach.Parent = nil
	end

	self.short_connection = RunService.RenderStepped:Connect(function()
		local character = LOCAL_PLAYER.Character
		if not character then return end
		if not self.Equipped then
			clearMuzzleFX()
			return
		end

		local head = character:FindFirstChild("Head")
		if not head then return end

		if not self.actual_model then return end
		local muzzle = self.actual_model:FindFirstChild(self.MuzzlePartName)
		if not muzzle then return end

		rayParams.FilterDescendantsInstances = {
			character,
			self.actual_model,
			barrelWarning
		}

		overlapParams.FilterDescendantsInstances = {
			character,
			self.actual_model,
			barrelWarning
		}

		local headDir = head.CFrame.LookVector

		local headResult = workspace:Raycast(
			head.Position,
			headDir * short_distance,
			rayParams
		)

		local muzzleResult = nil

		-- =========================
		-- MUZZLE LOGIC
		-- =========================
		if not self.Aiming then
			muzzleResult = workspace:Raycast(
				muzzle.Position,
				headDir * short_distance,
				rayParams
			)

		elseif not headResult and lastState ~= "headBlock" then
			local probe = Instance.new("Part")
			probe.Anchored = true
			probe.CanCollide = false
			probe.CanQuery = false
			probe.Transparency = 1
			probe.Size = Vector3.new(0.15, 0.15, 0.15)
			probe.CFrame = CFrame.new(muzzle.Position, muzzle.Position + headDir)
			probe.Parent = workspace

			local parts = workspace:GetPartsInPart(probe, overlapParams)

			for _, p in ipairs(parts) do
				if p.Transparency < 0.95 then
					muzzleResult = {
						Position = muzzle.Position + (headDir * 0.1),
						Distance = 0.1
					}
					break
				end
			end

			task.delay(0.05, function()
				probe:Destroy()
			end)
		end

		-- =========================
		-- HEAD BLOCK
		-- =========================
		if headResult then
			if lastState ~= "headBlock" then
				lastState = "headBlock"

				self.IsShorted = true
				self.ForceBlockFire = true
				self:_stopAllExcept()

				self._shortTrack = self:_playAnim("Short")

				if self._shortTrack then
					self._shortTrack:AdjustSpeed(0.001)
				end
			end

			-- HARD BLOCK muzzle FX
			clearMuzzleFX()

			return
		end

		-- =========================
		-- MUZZLE WARNING
		-- =========================
		if muzzleResult and self.Aiming and lastState ~= "headBlock" then
			if lastState ~= "muzzleWarning" then
				lastState = "muzzleWarning"

				self.IsShorted = false
				self.ForceBlockFire = true

				self:_stopAllExcept()
				self:_restoreBase("Short")
			end

			barrelWarning.CFrame = CFrame.new(muzzleResult.Position)

			muzzleAttach.Parent = muzzle
			hitAttach.Parent = barrelWarning

			if warning_beam then
				warning_beam.Attachment0 = muzzleAttach
				warning_beam.Attachment1 = hitAttach
				warning_beam.Enabled = true
			end

			if billboard_ui then
				billboard_ui.Enabled = true
			end

			if barrelWarning.Parent ~= workspace then
				barrelWarning.Parent = workspace
			end

			return
		end

		-- =========================
		-- DEFAULT
		-- =========================
		if lastState ~= "default" then
			lastState = "default"

			self.IsShorted = false
			self.ForceBlockFire = false

			self:_stopAllExcept()
			self:_restoreBase("Short")

			if self._shortTrack then
				self._shortTrack:Stop()
				self._shortTrack = nil
			end
		end

		clearMuzzleFX()
	end)
end

function BaseTool:clean_up_short()
	if self.short_connection then
		self.short_connection:Disconnect()
		self.short_connection = nil
	end
end
--------------------------------------------------------------------------------
-- Equip / Unequip
--------------------------------------------------------------------------------

function BaseTool:equip()
	if not self.tool then return end
	self.Equipped = true
	self.Equipping = true

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:EquipTool(self.tool)
	if self._on_equip then
		self:_on_equip() 
	end

	if self.RegisteredAnimations then
		local draw = self.RegisteredAnimations.Draw
		local hold = self.RegisteredAnimations.Hold
		if draw then draw:Play() end
		if hold then draw.Stopped:Connect(function() 
				if hold and self.tool and self.tool.Parent == character and self.Equipped then 
					hold:Play() 
					hold:AdjustSpeed(0.2) 
					self.Equipping = false 
					self:init_short_mechanic()
				end 
			end) end
	end

	if self.model_reference then
		self.actual_model = utilities_module.reverse_search_model(LOCAL_PLAYER, self.model_reference.Name)
		if not self.actual_model then
			warn("[" .. self.className .. "] Failed to find model")
		end
	end
	
	self:_startAimTracking()

	character:GetAttributeChangedSignal("Sprinting"):Connect(function()
		if character:GetAttribute("Sprinting") == true then
			task.wait(1)
			self:_stopAllExcept()
		else
			if not self.Equipped then return end

			if self.Aiming then
				local aimTrack = self:_aimTrack()
				if aimTrack and not aimTrack.IsPlaying then
					aimTrack:Play(CUT)
				end
				return
			end
			if self.RegisteredAnimations and self.RegisteredAnimations.Hold then
				self.RegisteredAnimations.Hold:Play()
				self.RegisteredAnimations.Hold:AdjustSpeed(0.2)
			end
		end
	end)
	
	
	-- Keyframe-driven round visibility
	for _, track in pairs(self.RegisteredAnimations) do
		if not self.SoundFolder then return end
		
		if not track:IsA("AnimationTrack") then continue end
		track.KeyframeReached:Connect(function(keyframe)
			local rightArm = LOCAL_PLAYER.Character:FindFirstChild("Right Arm")
			if not rightArm then return end
			local round = rightArm:FindFirstChild(self.Round.Name)
			if not round then return end
			if keyframe == "vfx_hand_shell_visible" then
				round.Transparency = 0
			elseif keyframe == "vfx_hand_shell_invisible" then
				round.Transparency = 1
			end

			if keyframe:sub(1,4) == "sfx_" then
				local soundName = keyframe:sub(5)
				local sound = self.SoundFolder:FindFirstChild(soundName)
				if sound then
					self:_play_sfx(sound, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("Sound not found for keyframe:", soundName)
				end
			elseif keyframe:sub(1,5) == "gsfx_" then
				local baseName = keyframe:sub(6)

				local matches = {}

				for _, child in ipairs(general_sfx:GetChildren()) do
					-- match prefix: princerifle_shell, princerifle_shell1, etc.
					if child.Name:sub(1, #baseName) == baseName then
						table.insert(matches, child)
					end
				end

				if #matches > 0 then
					local chosen = matches[math.random(1, #matches)]

					self:_play_sfx(chosen, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("No GSFX matches found for:", baseName)
				end
			end
		end)
	end
	
	

end

function BaseTool:unequip()
	if not self.tool then return end	

	self.Equipped = false

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if self._on_unequip then
		self:_on_unequip()
	end

	if self.RegisteredAnimations then
		for _, anim in pairs(self.RegisteredAnimations) do
			anim:Stop()
		end
	end

	self:_disable_aiming_ui()
	humanoid:UnequipTools()

	if self.RegisteredAnimations and self.RegisteredAnimations.Unequip then
		if self.Emergency_Drop == true then
			self.RegisteredAnimations.Drop:Play()
		else
			self.RegisteredAnimations.Unequip:Play()
		end
		if self.unequip_wait == true then
			self.RegisteredAnimations.Unequip.Stopped:Wait()
		end
	end

	self:clean_up_short()
	self.actual_model = nil
	if LOCAL_PLAYER.Character then LOCAL_PLAYER.Character:SetAttribute("Aiming", nil) end
end

--------------------------------------------------------------------------------
-- Shared: state helpers
--------------------------------------------------------------------------------

-- Returns true if any exclusive action is running.
-- Subclasses can override to include custom flags.
function BaseTool:_isBusy(): boolean
	return self.Firing or self.Reloading or self.Cycling or self.Alting or self.Spinning
end

function BaseTool:_if_sprinting(): boolean
	local char = LOCAL_PLAYER.Character
	return char ~= nil and char:GetAttribute("Sprinting") == true
end

--------------------------------------------------------------------------------
-- Shared: animation helpers
--------------------------------------------------------------------------------

-- Stops every registered track (except the optional exception) instantly.
function BaseTool:_stopAllExcept(exception: AnimationTrack?)
	if not self.RegisteredAnimations then return end
	for _, track in pairs(self.RegisteredAnimations) do
		if track ~= exception then
			if track:IsA("AnimationTrack") and track.IsPlaying then
				track:Stop(CUT)
			end
		end
	end
end

-- Layer-aware animation player. Requires self.ANIM_LAYERS to be defined.
-- Playing a layer-N track stops all other tracks at layer <= N (for N==max it stops all).
-- Falls back to a simple track:Play() when ANIM_LAYERS is absent.
-- GUARD: Checks Equipped state to prevent animations after unequip.
function BaseTool:_playAnim(name: string): AnimationTrack?
	if not self.Equipped then
		warn(self.className .. ":_playAnim called while not equipped: " .. name)
		return nil
	end

	local anims = self.RegisteredAnimations
	assert(anims, self.className .. ":_playAnim called before animations were registered")

	local track = anims[name]
	assert(track, self.className .. ": unknown animation '" .. tostring(name) .. "'")

	local layers = self.ANIM_LAYERS
	if layers then
		local myLayer = layers[name] or 0
		local maxLayer = 0
		for _, v in pairs(layers) do
			if v > maxLayer then maxLayer = v end
		end

		for trackName, layer in pairs(layers) do
			local shouldStop = (myLayer >= maxLayer) and (layer <= myLayer) or (layer == myLayer)
			if shouldStop then
				local t = anims[trackName]
				if t and t ~= track and t.IsPlaying then
					t:Stop(CUT)
				end
			end
		end
	end

	track:Play(CUT)
	return track
end

-- Stops all registered tracks at or below the given layer number.
function BaseTool:_stopLayer(maxLayer: number)
	if not self.RegisteredAnimations then return end
	local layers = self.ANIM_LAYERS
	if not layers then
		-- No layer table: stop everything
		self:_stopAllExcept()
		return
	end
	for trackName, layer in pairs(layers) do
		if layer <= maxLayer then
			local t = self.RegisteredAnimations[trackName]
			if t and t.IsPlaying then
				t:Stop(CUT)
			end
		end
	end
end

-- Returns the correct aim AnimationTrack for the current shoulder, or nil.
function BaseTool:_aimTrack(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Aim or anims.Aim_Left
end

-- Returns the correct fire AnimationTrack for the current shoulder, or nil.
function BaseTool:_getFireAnim(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Fire or anims.Fire_Left
end

-- Kills both aim tracks unconditionally.
function BaseTool:_killAimTracks()
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Aim      and anims.Aim.IsPlaying      then anims.Aim:Stop(CUT)      end
	if anims.Aim_Left and anims.Aim_Left.IsPlaying then anims.Aim_Left:Stop(CUT) end
end

-- Restores the correct base pose (Hold or Aim) once no busy action is running.
-- Subclasses can override for more complex layer logic.
function BaseTool:_restoreBase()
	if self:_isBusy() then
		return
	end

	if not self.Equipped then
		return
	end

	local anims = self.RegisteredAnimations
	if not anims then
		return
	end

	-- Stop all Layer 1 (fire/cycle) animations unconditionally
	if self.ANIM_LAYERS then
		for trackName, layer in pairs(self.ANIM_LAYERS) do
			if layer == 1 then
				local t = anims[trackName]
				if t and t.IsPlaying then
					t:Stop(CUT)
				end
			end
		end
	end

	if self.Aiming then
		local want = self:_aimTrack()

		-- Kill the opposite shoulder aim track
		local kill = (want == anims.Aim) and anims.Aim_Left or anims.Aim

		if kill and kill.IsPlaying then
			kill:Stop(CUT)
		end

		-- Stop Hold if it's playing
		if anims.Hold and anims.Hold.IsPlaying then
			anims.Hold:Stop(CUT)
		end

		-- ONLY play if not already playing (prevent restart)
		if want and not want.IsPlaying then
			want:Play()
		end
	else
		-- Kill both aim tracks
		self:_killAimTracks()

		-- Play Hold
		if anims.Hold and not anims.Hold.IsPlaying then
			anims.Hold:Play()
			anims.Hold:AdjustSpeed(0.2)
		end
	end
end
function BaseTool:_restoreBaseDeferred()
	task.defer(function()
		self:_restoreBase()
	end)
end

--------------------------------------------------------------------------------
-- Shared: aim system (aimVersion prevents stuck-aim on rapid RMB tap)
--------------------------------------------------------------------------------

-- Called when the shoulder attribute changes. Base implementation swaps aim tracks.
-- Subclasses may override (call or skip super as needed).
function BaseTool:_onShoulderChanged()
	if self:_isBusy() then return end
	if not self.Aiming then return end

	task.defer(function()
		if self:_isBusy() or not self.Aiming then return end

		local anims = self.RegisteredAnimations
		if not anims then return end

		local rightTrack = anims.Aim
		local leftTrack  = anims.Aim_Left

		-- Detect currently playing track (this is the REAL "old")
		local oldAimTrack = nil
		if rightTrack and rightTrack.IsPlaying then
			oldAimTrack = rightTrack
		elseif leftTrack and leftTrack.IsPlaying then
			oldAimTrack = leftTrack
		end

		local newAimTrack = self:_aimTrack()
		if not newAimTrack then return end

		-- If switching to the same track, do nothing
		if oldAimTrack == newAimTrack then return end

		-- Stop old, start new
		if oldAimTrack and oldAimTrack.IsPlaying then
			oldAimTrack:Stop(CUT)
		end

		if not newAimTrack.IsPlaying then
			newAimTrack:Play(CUT)
		end
	end)
end

local CAMERA = workspace.CurrentCamera
local CHARACTER_TRANSPARENCY = 0.95 -- Semi-transparent value

function BaseTool:aim()
	if self:_if_sprinting() then return end
	if self.Aiming or self:_isBusy() then return end
	if not self.RegisteredAnimations.Aim then return end
	
	if self.Equipping then 
		return 	
	end

	if self.IsShorted == true then
		return 
	end
	
	if LOCAL_PLAYER:GetAttribute("Jumping") then return end
	self.Aiming = true
	self._aimVersion += 1
	self:_startAimTracking()
	local anims = self.RegisteredAnimations
	if not anims then return end
	self:_killAimTracks()
	if anims.Hold and anims.Hold.IsPlaying then anims.Hold:Stop(CUT) end
	local aimTrack = self:_aimTrack()
	if aimTrack then aimTrack:Play(CUT) end
	local char = LOCAL_PLAYER.Character
	if char then char:SetAttribute("Aiming", true) end

	self:_enable_aiming_ui(self.Aiming_Number or 50)

	-- Start monitoring camera angle for body transparency
	self:_startTransparencyTracking()

	LOCAL_PLAYER:GetAttributeChangedSignal("Jumping"):Connect(function()
		if LOCAL_PLAYER:GetAttribute("Jumping") then
			self:endAiming()
		end
	end)
end

function BaseTool:endAiming()
	if not self.Aiming then return end
	self.Aiming = false
	self._aimVersion += 1
	self:_stopAimTracking()
	self:_stopTransparencyTracking()
	local anims = self.RegisteredAnimations
	if anims then
		self:_killAimTracks()
		if not self:_isBusy() then
			if anims.Hold and not anims.Hold.IsPlaying then
				anims.Hold:Play(CUT)
				anims.Hold:AdjustSpeed(0.2)
			end
		end
	end
	local char = LOCAL_PLAYER.Character
	if char then char:SetAttribute("Aiming", nil) end
	self:_disable_aiming_ui()

	-- Reset body transparency
	self:_resetBodyTransparency()
end

-- Helper function to start camera angle tracking for transparency
function BaseTool:_startTransparencyTracking()
	if self._transparencyConnection then
		self._transparencyConnection:Disconnect()
	end

	local char = LOCAL_PLAYER.Character
	if not char then return end

	self._transparencyConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not self.Aiming or not char or not char:FindFirstChild("Humanoid") then
			return
		end

		-- Get camera's euler angles and calculate the pitch angle
		local cameraEulerAngles = CAMERA.CFrame:ToEulerAnglesYXZ()
		local pitchAngle = math.rad(cameraEulerAngles * 50) -- Multiply by 50 like in GraveDigger

		-- Apply body transparency based on extreme camera angles
		-- Transparent when aiming very far up (>= 0.43 rad / ~28.2°) or very far down (<= -0.9 rad / ~-59°)
		if pitchAngle >= 0.43 or pitchAngle <= -0.9 then
			self:_setBodyTransparency(CHARACTER_TRANSPARENCY)
		else
			self:_setBodyTransparency(0)
		end
	end)
end

-- Helper function to stop transparency tracking
function BaseTool:_stopTransparencyTracking()
	if self._transparencyConnection then
		self._transparencyConnection:Disconnect()
		self._transparencyConnection = nil
	end
end

-- Helper function to set body part transparency
function BaseTool:_setBodyTransparency(transparency)
	local char = LOCAL_PLAYER.Character
	if not char then return end

	local bodyParts = {"Torso", "Left Arm", "Right Arm"}

	for _, partName in ipairs(bodyParts) do
		local part = char:FindFirstChild(partName)
		if part then
			part.Transparency = transparency
		end
	end
end

-- Helper function to reset body transparency to normal
function BaseTool:_resetBodyTransparency()
	local char = LOCAL_PLAYER.Character
	if not char then return end

	local bodyParts = {"Torso", "Left Arm", "Right Arm"}

	for _, partName in ipairs(bodyParts) do
		local part = char:FindFirstChild(partName)
		if part then
			part.Transparency = 0
		end
	end
end

--------------------------------------------------------------------------------
-- Shared: input system
-- Subclasses define _getKeyBindings() returning a table of action->KeyCode/input.
-- Default bindings cover RMB=aim, R=reload, T=ammo_check.
-- Override _getKeyBindings in the subclass to add/replace bindings.
--------------------------------------------------------------------------------

-- Default bindings. Subclass can override _getKeyBindings() to extend/replace.
function BaseTool:_getKeyBindings(): { [string]: Enum.KeyCode | Enum.UserInputType }
	return {
		Aim    = Enum.UserInputType.MouseButton2,
		Reload = Enum.KeyCode.R,
		Check  = Enum.KeyCode.T,
		["Emergency Drop"] = Enum.KeyCode.T,
	}
end

function BaseTool:_connectInput()
	local bindings = self:_getKeyBindings()

	self._inputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end

		for action, bind in pairs(bindings) do
			local matched = (typeof(bind) == "EnumItem" and bind.EnumType == Enum.UserInputType)
				and input.UserInputType == bind
				or (typeof(bind) == "EnumItem" and bind.EnumType == Enum.KeyCode)
				and input.KeyCode == bind

			if matched then
				if action == "Aim" then
					self:aim()
				elseif action == "Reload" then
					self:reload()
				elseif action == "Check" then

					if self.Can_Drop == true and self.Reloading == true then
						self:drop()
					else
						self:ammo_check()
					end

				elseif self[action] and type(self[action]) == "function" then
					self[action](self)
				end
			end
		end
	end)

	self._inputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		local aimBind = bindings.Aim
		local matched = aimBind
			and ((typeof(aimBind) == "EnumItem" and aimBind.EnumType == Enum.UserInputType and input.UserInputType == aimBind)
				or (typeof(aimBind) == "EnumItem" and aimBind.EnumType == Enum.KeyCode and input.KeyCode == aimBind))
		if matched then
			self:endAiming()
		end
	end)
end

function BaseTool:_disconnectInput()
	if self._inputBeganConn then
		self._inputBeganConn:Disconnect()
		self._inputBeganConn = nil
	end
	if self._inputEndedConn then
		self._inputEndedConn:Disconnect()
		self._inputEndedConn = nil
	end
end

--------------------------------------------------------------------------------
-- Shared: shoulder tracking
--------------------------------------------------------------------------------

function BaseTool:_initShoulderTracking()
	if not RunService:IsClient() then return end
	self.current_shoulder = LOCAL_PLAYER:GetAttribute("Current_Shoulder") or "Right"

	if self._shoulderChangedConn then
		self._shoulderChangedConn:Disconnect()
	end

	self._shoulderChangedConn = LOCAL_PLAYER:GetAttributeChangedSignal("Current_Shoulder"):Connect(function()
		self.current_shoulder = LOCAL_PLAYER:GetAttribute("Current_Shoulder") or "Right"
		self:_onShoulderChanged()
	end)
end

function BaseTool:_stopShoulderTracking()
	if self._shoulderChangedConn then
		self._shoulderChangedConn:Disconnect()
		self._shoulderChangedConn = nil
	end
end

--------------------------------------------------------------------------------
-- Shared: aim motor tracking (PreSimulation lerp for pitch)
--------------------------------------------------------------------------------

function BaseTool:_startAimTracking()
	-- 1. Guard Clause
	if self._aimConnection then
		return
	end

	local character = LOCAL_PLAYER.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torso = character and character:FindFirstChild("Torso")
	if not (character and root and torso) then return end

	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	if not (leftShoulder and rightShoulder) then return end

	-- 2. Rest state cache
	self._restLeftC0 = self._restLeftC0 or leftShoulder.C0
	self._restRightC0 = self._restRightC0 or rightShoulder.C0

	local camera = workspace.CurrentCamera

	-- freelook state cache
	self._wasFreeLook = self._wasFreeLook or false
	self._freeLookYaw = self._freeLookYaw or 0

	local lastJitterTime = tick()
	local jitterAngles = { 0, 0, 0 }
	local lerpAlpha = 0.15

	-- 3. Render loop
	self._aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not self.Equipped then return end

		local t = tick()

		local freeLook = LOCAL_PLAYER:GetAttribute("FreeLook") == true

		-- === CHARACTER CHECK SAFETY (in case of respawn) ===
		local character = LOCAL_PLAYER.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local torso = character and character:FindFirstChild("Torso")
		if not (character and root and torso) then return end

		local leftShoulder = torso:FindFirstChild("Left Shoulder")
		local rightShoulder = torso:FindFirstChild("Right Shoulder")
		if not (leftShoulder and rightShoulder) then return end

		-- === PITCH (camera driven, unchanged) ===
		local currentLookDir = camera.CFrame.LookVector
		local cameraPitch = math.asin(math.clamp(currentLookDir.Y, -1, 1))

		-- === YAW (FIXED) ===
		local relativeCF = root.CFrame:ToObjectSpace(camera.CFrame)
		local lookDir = relativeCF.LookVector
		local currentYaw = math.atan2(-lookDir.X, -lookDir.Z)

		if freeLook then
			--[[ lock yaw on first entry into freelook
			if not self._wasFreeLook then
				self._freeLookYaw = currentYaw
			end

			self._wasFreeLook = true
			yaw = self._freeLookYaw]]
		else
			-- normal mode: follow camera every frame
			self._wasFreeLook = false
			self._freeLookYaw = currentYaw
			yaw = currentYaw
		end

		-- === ROTATION BUILD ===
		if yaw == nil then return end
		local rotationCF =
			CFrame.Angles(0, yaw, 0)
			* CFrame.Angles(cameraPitch, 0, 0)

		-- Apply animation lean
		local armRotation = rotationCF * CFrame.Angles(0, root.RootJoint.CurrentAngle, 0)

		-- === ARM TARGETS ===
		local leftArmCF = torso.CFrame:ToObjectSpace(
			root.CFrame
				* armRotation
				* CFrame.new(-1, 0.5, 0)
				* CFrame.Angles(0, -math.pi / 2, 0)
		)

		local rightArmCF = torso.CFrame:ToObjectSpace(
			root.CFrame
				* armRotation
				* CFrame.new(1, 0.5, 0)
				* CFrame.Angles(0, math.pi / 2, 0)
		)

		-- === JITTER (kept disabled as in your original) ===
		--[[
		if t - lastJitterTime >= 0.06 then
			lastJitterTime = t
			jitterAngles = {
				math.rad(math.random(-5, 5)) / 20,
				math.rad(math.random(-5, 5)) / 20,
				math.rad(math.random(-5, 5)) / 20
			}
		end

		local jitterRotation = CFrame.Angles(jitterAngles[1], jitterAngles[2], jitterAngles[3])
		local breatheSway = CFrame.new(0, math.sin(t * 4) * 0.01, 0)

		leftShoulder.C0 =
			leftShoulder.C0:Lerp(breatheSway * jitterRotation * leftArmCF, lerpAlpha)

		rightShoulder.C0 =
			rightShoulder.C0:Lerp(breatheSway * jitterRotation * rightArmCF, lerpAlpha)
		]]

		-- If jitter is disabled, you still need to apply arms somewhere:
		leftShoulder.C0 = leftShoulder.C0:Lerp(leftArmCF, lerpAlpha)
		rightShoulder.C0 = rightShoulder.C0:Lerp(rightArmCF, lerpAlpha)
	end)
end
--[[ BrokenAnim Im keeping cuz its funny function BaseTool:_startAimTracking()
	local character = LOCAL_PLAYER.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("Torso")
	if not (root and torso) then return end

	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	if not (leftShoulder and rightShoulder) then return end

	local restLeftShoulder = leftShoulder.C0
	local restRightShoulder = rightShoulder.C0

	local jitterAngles = { 0, 0, 0 }
	local lastJitterTime = tick()
	local lerpAlpha = 0.15 

	self._restLeftC0 = leftShoulder.C0
	self._restRightC0 = rightShoulder.C0

	self._aimConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not self.Aiming or not self.Equipped then return end

		local camera = workspace.CurrentCamera
		local isFirstPerson = LOCAL_PLAYER.CameraMode == Enum.CameraMode.LockFirstPerson

		local armOffset = CFrame.new(0, 0, 0)
		local defaultArmOffset = CFrame.new()

		-- Use camera CFrame directly to avoid double rotation
		local leftArmCF = torso.CFrame:ToObjectSpace(
			root.CFrame 
				* CFrame.new(-1, 0.5, 0) 
				* armOffset 
				* CFrame.Angles(0, -math.pi / 2, 0) 
				* defaultArmOffset
		) * root.CFrame:ToObjectSpace(camera.CFrame)

		local rightArmCF = torso.CFrame:ToObjectSpace(
			root.CFrame 
				* CFrame.new(1, 0.5, 0) 
				* armOffset 
				* CFrame.Angles(0, math.pi / 2, 0) 
				* defaultArmOffset:Inverse()
		) * root.CFrame:ToObjectSpace(camera.CFrame)

		if isFirstPerson then
			local shoulderOffsetX = 0.5
			local shoulderOffsetY = -1.75
			local shoulderOffsetZ = 0

			if character:GetAttribute("LeftAiming") then shoulderOffsetX = -0.4 end
			if character:GetAttribute("Guarding") then 
				shoulderOffsetX = 0.15
				shoulderOffsetY = -1.85 
			end

			local shoulderOffset = CFrame.new(shoulderOffsetX, shoulderOffsetY, shoulderOffsetZ)
			local cameraRelativeCF = root.CFrame:ToObjectSpace(camera.CFrame)

			leftArmCF = torso.CFrame:ToObjectSpace(
				root.CFrame
					* shoulderOffset 
					* CFrame.Angles(0, root.RootJoint.CurrentAngle, 0) 
					* CFrame.new(-1, 0.5, 0) 
					* CFrame.Angles(0, -math.pi / 2, 0) 
					* defaultArmOffset
			) * cameraRelativeCF

			rightArmCF = torso.CFrame:ToObjectSpace(
				root.CFrame
					* shoulderOffset 
					* CFrame.Angles(0, root.RootJoint.CurrentAngle, 0) 
					* CFrame.new(1, 0.5, 0) 
					* CFrame.Angles(0, math.pi / 2, 0) 
					* defaultArmOffset:Inverse()
			) * cameraRelativeCF
		end

		local t = tick()
		if t - lastJitterTime >= 0.06 then
			lastJitterTime = t
			jitterAngles = {
				math.rad(math.random(-5, 5)) / 20,
				math.rad(math.random(-5, 5)) / 20,
				math.rad(math.random(-5, 5)) / 20
			}
		end

		local jitterRotation = CFrame.Angles(jitterAngles[1], jitterAngles[2], jitterAngles[3])
		local breatheSway = CFrame.new(0, math.sin(t * 4) * 0.01, 0)

		leftShoulder.C0 = leftShoulder.C0:Lerp(breatheSway * jitterRotation * leftArmCF, lerpAlpha)
		rightShoulder.C0 = rightShoulder.C0:Lerp(breatheSway * jitterRotation * rightArmCF, lerpAlpha)
	end)
end]]

function BaseTool:_stopAimTracking()
	-- 1. Kill the loop immediately so it stops setting C0 every frame
	if self._aimConnection then
		self._aimConnection:Disconnect()
		self._aimConnection = nil
	end

	local character = LOCAL_PLAYER.Character
	local torso = character and character:FindFirstChild("Torso")

	if torso then
		local leftShoulder = torso:FindFirstChild("Left Shoulder")
		local rightShoulder = torso:FindFirstChild("Right Shoulder")

		-- 2. Smooth Reset using TweenService
		-- We use a slightly faster tween to make the tool feel responsive
		local resetInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		if leftShoulder and self._restLeftC0 then
			game:GetService("TweenService"):Create(leftShoulder, resetInfo, {C0 = self._restLeftC0}):Play()
		end

		if rightShoulder and self._restRightC0 then
			game:GetService("TweenService"):Create(rightShoulder, resetInfo, {C0 = self._restRightC0}):Play()
		end
	end
	task.delay(0.15, function()
		if not self.Aiming then -- Double check we haven't started aiming again
			self:_resetMotor6D()
		end
	end)
end

--------------------------------------------------------------------------------
-- Shared: Motor6D helpers
--------------------------------------------------------------------------------

function BaseTool:_cacheMotor6D()
	if not self.motor_6d then return end
	self._motorOriginal = {
		C0    = self.motor_6d.C0,
		C1    = self.motor_6d.C1,
		Part0 = self.motor_6d.Part0,
		Part1 = self.motor_6d.Part1,
	}
end

function BaseTool:_resetMotor6D()
	if not self.motor_6d or not self._motorOriginal then return end
	local motor    = self.motor_6d
	local targetC0 = self._motorOriginal.C0
	local targetC1 = self._motorOriginal.C1
	local snapDist = (self :: any).MOTOR_SNAP_DIST or MOTOR_SNAP_DIST
	local alpha    = (self :: any).MOTOR_LERP_ALPHA or MOTOR_LERP_ALPHA
	local conn
	conn = RunService.PreSimulation:Connect(function()
		motor.C0 = motor.C0:Lerp(targetC0, alpha)
		motor.C1 = motor.C1:Lerp(targetC1, alpha)
		if (motor.C0.Position - targetC0.Position).Magnitude < snapDist then
			conn:Disconnect()
		end
	end)
end

--------------------------------------------------------------------------------
-- Shared: projectile hit & penetration
--------------------------------------------------------------------------------

function BaseTool:_onBulletHit(
	cast:             any,
	result:           RaycastResult,
	velocity:         Vector3,
	muzzle:           Part,
	Penetration_Level: number,
	damage:           number,
	knockback_force:  number
)
	local profile = Penetration_Profiles[Penetration_Level]
	if not profile then return end

	local instance  = result.Instance
	local material  = result.Material
	local direction = cast.UserData.Direction :: Vector3

	if cast.UserData.Penetrated then return end
	if not muzzle then return end

	-- Check if we hit a character (player or NPC)
	local hitModel = instance:FindFirstAncestorOfClass("Model")
	local isCharacter = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

	-- If we hit a character, skip penetration and just apply damage
	if isCharacter then
		self:_applyHit(result, damage, direction, knockback_force)
		cast.UserData.Penetrated = true
		return
	end

	if (muzzle.Position - result.Position).Magnitude > profile.Distance_Limiter then
		cast.UserData.Penetrated = true
		return
	end

	local canPenetrate = false
	for _, mat in ipairs(profile.Materials) do
		if mat == material then canPenetrate = true; break end
	end

	self:_applyHit(result, damage, direction, knockback_force)

	if not canPenetrate then
		cast.UserData.Penetrated = true
		return
	end

	-- Entry effects
	self:bullet_hole(result.Position, result.Normal)

	if material == Enum.Material.Wood then
		self:emit_effect(
			FX_WOOD_CHIPS,
			CFrame.new(result.Position, result.Position + result.Normal),
			{ "woodchip1", "woodchip2", "woodchip3" },
			instance,
			20,
			false
		)
	end

	-- Thickness check
	local thicknessParams = RaycastParams.new()
	thicknessParams.FilterType = Enum.RaycastFilterType.Include
	thicknessParams.FilterDescendantsInstances = { instance }

	local thicknessResult = workspace:Raycast(result.Position + direction * 0.05, direction * profile.Stud_Limit, thicknessParams)
	if thicknessResult then
		cast.UserData.Penetrated = true
		return
	end

	-- Exit hole
	local exitParams = RaycastParams.new()
	exitParams.FilterType = Enum.RaycastFilterType.Include
	exitParams.FilterDescendantsInstances = { instance }

	local exitResult = workspace:Raycast(result.Position + direction * profile.Stud_Limit, -direction * profile.Stud_Limit, exitParams)
	if exitResult then
		self:bullet_hole(exitResult.Position, exitResult.Normal)
	end

	-- Continue bullet (penetration continuation)
	cast.UserData.Penetrated = true

	local newOrigin    = result.Position + direction * 0.2
	local continuation = self.Caster:Fire(newOrigin, direction, velocity.Magnitude, self.CasterBehavior)
	self:_connect_FastCast(newOrigin, direction, velocity.Magnitude, {
		bulletTemplate = FxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		isPenetration = true,
		penetrationLevel = Penetration_Level,
		damage = damage,
		knockbackForce = knockback_force
	})
	continuation.UserData.Direction  = direction
	continuation.UserData.Penetrated = true
end

function BaseTool:_applyHit(result: RaycastResult, damage: number, direction: Vector3, knockback_force: number)
	if not result then return end
	hit_connection:FireServer({
		Position  = result.Position,
		Normal    = result.Normal,
		Instance  = result.Instance,
		Material  = result.Material,
		Direction = direction,
	}, damage, knockback_force)
end

--------------------------------------------------------------------------------
-- Shared: FastCast setup (NEW METHOD)
--------------------------------------------------------------------------------

function BaseTool:_setupFastCast(fxFolder: Folder, onHitCallback: (any, RaycastResult, Vector3) -> ())
	local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
	self.Caster, self.CasterBehavior = Util.setupFastCast({
		bulletTemplate  = fxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		onHit           = onHitCallback,
	})
end

--------------------------------------------------------------------------------
-- Shared: projectile firing (NEW METHOD)
-- Performs camera raycast and fires projectile with standard logic.
-- Subclass should call this from their fire() method.
--------------------------------------------------------------------------------

function BaseTool:_fireProjectile(
	bulletSpeed:      number,
	penetrationLevel: number,
	damage:           number,
	knockbackForce:   number
): boolean
	if self:_if_sprinting() then
		return false
	end

	local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName or "Muzzle")
	if not muzzle then
		warn(self.className .. ": Muzzle part not found")
		return false
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return false
	end

	-- Raycast from camera to find target
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir = (targetPos - muzzle.Position).Unit

	-- Fire projectile
	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, bulletSpeed, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false

	self:_connect_FastCast(muzzle.Position, shootDir, bulletSpeed)

	return true
end

--------------------------------------------------------------------------------
-- Shared: muzzle flash effect (NEW METHOD)
--------------------------------------------------------------------------------

function BaseTool:_fireMuzzleFlash()
	if not self.actual_model then return end

	local muzzle = self.actual_model:FindFirstChild(self.MuzzlePartName or "Muzzle")
	if not muzzle then return end

	local fxFolder = ReplicatedStorage.Shared.Assets.Guns.Effects.Shooting
	self:emit_effect(
		fxFolder.Muzzle_Flash,
		muzzle.CFrame * CFrame.new(-0.1, 0, -2),
		{ "smoke_medium", "smoke_forward", "flash_general" },
		muzzle,
		1,
		false
	)
end

--------------------------------------------------------------------------------
-- Shared: reload sequence (NEW METHOD)
-- Generic reload state machine. Subclass calls with animation names.
-- onLoopCallback(ammoLoaded) called after each loop iteration to do custom logic.
--------------------------------------------------------------------------------

function BaseTool:_reloadSequence(
	startAnimName: string,
	loopAnimName: string,
	endAnimName: string,
	onLoopCallback: ((number) -> ())?,
	maxAmmo: number,
	currentAmmo: number
): boolean
	if self.Reloading then return false end
	if currentAmmo >= maxAmmo then return false end

	self:_stopAllExcept()
	self.Reloading = true
	self._reloadCancelled = false

	local anims = self.RegisteredAnimations
	if not anims then
		self.Reloading = false
		return false
	end

	-- Start animation
	if startAnimName and anims[startAnimName] then
		self:_playAnim(startAnimName).Stopped:Wait()
	end

	-- Loop animation until full or cancelled
	while currentAmmo < maxAmmo and not self._reloadCancelled do
		if loopAnimName and anims[loopAnimName] then
			self:_playAnim(loopAnimName).Stopped:Wait()
		end
		if self._reloadCancelled then break end

		currentAmmo += 1
		if onLoopCallback then
			onLoopCallback(currentAmmo)
		end
	end

	-- End animation
	if not self._reloadCancelled then
		if endAnimName and anims[endAnimName] then
			self:_playAnim(endAnimName).Stopped:Wait()
		end
	else
		-- Cancel: stop all reload animations
		local stopNames = { startAnimName, loopAnimName, endAnimName }
		for _, name in ipairs(stopNames) do
			if name and anims[name] and anims[name].IsPlaying then
				anims[name]:Stop(CUT)
			end
		end
	end

	self.Reloading = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()

	return true
end

--------------------------------------------------------------------------------
-- Shared: replication
--------------------------------------------------------------------------------

function BaseTool:_connect_FastCast(...)
	fast_cast_replication:FireServer(...)
end

function BaseTool:_play_sfx(...)
	replicant_service.connect_sfx(LOCAL_PLAYER, ...)
end

--------------------------------------------------------------------------------
-- Shared: aiming UI
--------------------------------------------------------------------------------

function BaseTool:_enable_aiming_ui(max_aiming: number)
	local aiming_gui = LOCAL_PLAYER.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = false
	aiming_gui.Scoped_In.Visible = true

	local scoped = aiming_gui.Scoped_In.main
	local down   = scoped.down
	local left   = scoped.left
	local right  = scoped.right
	local up     = scoped.up

	local character = LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait()
	local root      = character:WaitForChild("HumanoidRootPart")
	local humanoid  = character:WaitForChild("Humanoid")

	if self.character_connection then
		self.character_connection:Disconnect()
	end

	local currentSpread = 0
	self.character_connection = RunService.RenderStepped:Connect(function()
		if not root or not humanoid then return end
		local speed      = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
		local alpha      = (humanoid.WalkSpeed > 0) and math.clamp(speed / humanoid.WalkSpeed, 0, 1) or 0
		local target     = alpha * max_aiming
		currentSpread    = currentSpread + (target - currentSpread) * 0.15
		local offset     = 5 + currentSpread
		up.Position    = UDim2.new(0.5, 0, 0, -offset)
		down.Position  = UDim2.new(0.5, 0, 1,  offset)
		left.Position  = UDim2.new(0, -offset, 0.5, 0)
		right.Position = UDim2.new(1,  offset, 0.5, 0)
	end)
end

function BaseTool:_disable_aiming_ui()
	local aiming_gui = LOCAL_PLAYER.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = true
	aiming_gui.Scoped_In.Visible = false
	if self.character_connection then
		self.character_connection:Disconnect()
		self.character_connection = nil
	end
end

--------------------------------------------------------------------------------
-- Shared: notifications
--------------------------------------------------------------------------------

function BaseTool:notify(text: string)
	local Notifications_util = require(
		LOCAL_PLAYER.PlayerGui:WaitForChild("Notifications"):WaitForChild("Utils")
	)
	Notifications_util.send_notification(LOCAL_PLAYER, text)
end

--------------------------------------------------------------------------------
-- Shared: ammo check
--------------------------------------------------------------------------------

function BaseTool:ammo_check()
	if not self.RegisteredAnimations or not self.RegisteredAnimations.Check then return end
	if self:_isBusy() then return end
	if self.Checking == true then return end
	if self.Check_Delayed == true then return end

	self.Checking = true
	self.Check_Delayed = true
	local ammo_check_part, ammo_check_utils
	if not workspace.CurrentCamera:FindFirstChild("Ammo_Check") then
		ammo_check_part  = game.ReplicatedStorage.Shared.Assets.Guns.Effects.AmmoUI.Ammo_Check:Clone()
		ammo_check_part.Parent = workspace.CurrentCamera
		ammo_check_utils = require(ammo_check_part.Utils)
	else
		ammo_check_part  = workspace.CurrentCamera.Ammo_Check
		ammo_check_utils = require(workspace.CurrentCamera.Ammo_Check.Utils)
	end

	self:_stopAllExcept()
	self.RegisteredAnimations.Check:Play()

	self.Checking = false
	local hrp = LOCAL_PLAYER.Character.HumanoidRootPart
	ammo_check_part.Position = self.actual_model:FindFirstChild(self.MuzzlePartName).Position + self.actual_model:FindFirstChild(self.MuzzlePartName).CFrame.RightVector * 2 + Vector3.new(0, 1.5, 0)

	-- // destroy old weld
	if ammo_check_part:FindFirstChild("WeldConstraint") then
		ammo_check_part:FindFirstChild("WeldConstraint"):Destroy()
	end

	local weld   = Instance.new("WeldConstraint")
	weld.Part0   = ammo_check_part
	weld.Part1   = self.actual_model:FindFirstChild(self.MuzzlePartName)
	weld.Parent  = ammo_check_part

	local pct = math.clamp(self.Capacity / self.Max_Capacity, 0, 1)
	ammo_check_utils.utils(self.Ammo_Type, pct, false,  self.tool:FindFirstChild("Reserve_Ammo").Value / (self.Max_Capacity * 3) )
	print("Bar Size will be:", self.Max_Capacity * 3, self.tool:FindFirstChild("Reserve_Ammo").Value, self.tool:FindFirstChild("Reserve_Ammo").Value / (self.Max_Capacity * 3))

	self:_restoreBase()

	if self.Check_Delayed and self.Check_Delay then
		task.delay(self.Check_Delay, function()
			self.Check_Delayed = false
		end)
	end
end


function BaseTool:drop()
	print("Emergency dropping...")
	drop_connection:FireServer(self.className, self.model_reference, true)
	self:destroy()
	self.Emergency_Drop = true
end

--------------------------------------------------------------------------------
-- Shared: VFX
--------------------------------------------------------------------------------

function BaseTool:emit_effect(
	effect:           Part,
	CFrame_Value:     CFrame,
	target_tables:    { string },
	parent:           Instance,
	emit_count:       number,
	attach_to_parent: boolean
)
	emit_count = emit_count or 10

	for _, child in pairs(effect:GetDescendants()) do
		local match = table.find(target_tables, child.Name) or table.find(target_tables, child.ClassName)
		if not match then continue end

		local clone     = child:Clone()
		local container = parent

		if attach_to_parent then
			clone.Parent = parent
		else
			local part        = Instance.new("Part")
			part.Size         = Vector3.new(0.05, 0.05, 0.05)
			part.Anchored     = true
			part.CanCollide   = false
			part.Transparency = 1
			part.Parent       = workspace
			part.CFrame       = CFrame_Value
			clone.Parent      = part
			container         = part
		end

		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emit_count)
			local lifetime = clone.Lifetime.Max
			task.delay(lifetime + 0.1, function()
				if attach_to_parent then
					if clone then clone:Destroy() end
				else
					if container then container:Destroy() end
				end
			end)
		end
	end

	vfx_cast_event:FireServer(effect, CFrame_Value, target_tables, parent, emit_count, attach_to_parent)
end

function BaseTool:bullet_hole(position: Vector3, normal: Vector3)
	local folder = workspace.Game_Details.Effects.BulletHoles
	local clone  = FX_BULLET_HOLE:Clone()
	clone.CFrame = CFrame.new(position, position + normal)
	clone.Parent = folder
	texture_event:FireServer(FX_BULLET_HOLE, position, normal, folder)
end

--------------------------------------------------------------------------------
-- Stubs (subclass must implement)
--------------------------------------------------------------------------------

function BaseTool:activate()

end

function BaseTool:reload()
	-- Optional. Subclass implements if the weapon reloads.
end

--------------------------------------------------------------------------------
-- Cleanup
--------------------------------------------------------------------------------

function BaseTool:destroy()
	if self._activationConnection then
		self._activationConnection:Disconnect()
		self._activationConnection = nil
	end

	self:_stopAllExcept()
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()

	if self.actual_model then
		self.actual_model:Destroy()
		self.actual_model = nil
	end
end

return BaseTool