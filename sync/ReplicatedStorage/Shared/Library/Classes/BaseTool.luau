-----------------------
--@Praxitos
--BaseTool
------------------------

--!native
--!optimize 2

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local Types            = require(script.Parent.Parent.Types)
local utilities_module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA       = workspace.CurrentCamera

local Assets   = ReplicatedStorage.Shared.Assets
local FxFolder = Assets.Guns.Effects.Shooting

local FX_BULLET_HOLE = FxFolder.BulletHole
local FX_WOOD_CHIPS  = FxFolder.Parent.Environment.Wood_Chips

local replicant_service             = require(ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService)
local events_replication_folder     = ReplicatedStorage.Shared.Library.Events.Replicant_Communication
local fast_cast_replication         = events_replication_folder.FastCast_Connection
local hit_connection                = events_replication_folder.Hit_Connection
local vfx_cast_event                = events_replication_folder.VFX_Connection
local sfx_cast_event                = events_replication_folder.SFX_Connection
local texture_event                 = events_replication_folder.Texture_Connection

local gun_communication = events_replication_folder.Parent.Gun_Communication
local drop_connection   = gun_communication.Drop_Connection

local general_sfx        = ReplicatedStorage.Shared.Assets.Guns.Sounds.Shared
local bullet_warning_part = ReplicatedStorage.Shared.Assets.UI.Warning_Barrel

-- // Tuning

local AIM_LERP_ALPHA   = 0.1
local MOTOR_LERP_ALPHA = 0.15
local MOTOR_SNAP_DIST  = 0.001
local CUT              = 0.15
local CHARACTER_TRANSPARENCY = 0.95

-- // Penetration profiles

local Penetration_Profiles = {
	[4] = { Stud_Limit = 4, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 70 },
	[3] = { Stud_Limit = 3, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 50 },
	[2] = { Stud_Limit = 2, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 30 },
	[1] = { Stud_Limit = 1, Materials = {},                                                Distance_Limiter = 0  },
}

-- // Class

local BaseTool = {}
BaseTool.__index = BaseTool

export type BaseTool = typeof(setmetatable({} :: {
	className: "BaseTool",
	name: string,
	tool: Tool?,
	model_reference: Model?,
	actual_model: Model?,
	holster_reference: Instance?,
	actual_holster: Model?,
	animations: { [string]: Animation }?,
	RegisteredAnimations: { [string]: AnimationTrack }?,
	ANIM_LAYERS: { [string]: number }?,
	motor_6d_data: { Parent: string, Part0: string, Part1: string | BasePart, C0: CFrame }?,
	motor_6d: Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
	current_shoulder: string,
	Aiming: boolean,
	_aimVersion: number,
	_aimConnection: RBXScriptConnection?,
	Firing: boolean,
	Reloading: boolean,
	Cycling: boolean,
	Alting: boolean,
	Spinning: boolean,
	Checking: boolean,
	Meleeing: boolean,
	_activationConnection: RBXScriptConnection?,
	_inputBeganConn: RBXScriptConnection?,
	_inputEndedConn: RBXScriptConnection?,
	_shoulderChangedConn: RBXScriptConnection?,
	character_connection: RBXScriptConnection?,
	Caster: any?,
	CasterBehavior: any?,
	Equipped: boolean?,
	Equipping: boolean?,
}, {} :: typeof(BaseTool)))

-- // Constructor

function BaseTool.new(BaseToolCreateInfo: Types.BaseToolCreateInfo): BaseTool
	local self = setmetatable({}, BaseTool)

	self.className = "BaseTool"
	self.name      = BaseToolCreateInfo.name

	self.tool           = nil
	self.actual_model   = nil
	self.actual_holster = nil
	self.RegisteredAnimations = nil

	self.Aiming           = false
	self._aimVersion      = 0
	self.current_shoulder = "Right"

	self.Firing    = false
	self.Reloading = false
	self.Cycling   = false
	self.Alting    = false
	self.Spinning  = false
	self.Checking  = false
	self.Meleeing  = false

	self.Equipped  = false
	self.Equipping = false

	self.ForceBlockFire = false

	self._activationConnection = nil
	self._inputBeganConn       = nil
	self._inputEndedConn       = nil
	self._shoulderChangedConn  = nil
	self._aimConnection        = nil
	self._shortTrack           = nil
	self._shortActive          = false
	self._shortAlpha           = 0

	self.Caster         = nil
	self.CasterBehavior = nil
	self.keyframe_connections = {}

	return self
end

-- // on_give

function BaseTool:on_give(tool: Tool, holster: Model?, model: Model?)
	self.tool = tool

	if self.animations then
		self.RegisteredAnimations = utilities_module.register_animations(LOCAL_PLAYER, self.animations)
		if not self.RegisteredAnimations then
			warn("[" .. self.className .. "] Failed to register animations")
		end

		if self.animation_speeds then
			for animName, speed in pairs(self.animation_speeds) do
				local track = self.RegisteredAnimations[animName]
				if track then
					track:AdjustSpeed(speed)
				end
			end
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

-- // Short mechanic

function BaseTool:GetBarrelWarningPart()
	local clone = bullet_warning_part:Clone()
	clone.CanQuery = false

	local hitAttach = Instance.new("Attachment")
	hitAttach.Name = "HitWarningAttach"
	hitAttach.Parent = clone
	clone:SetAttribute("HitAttachName", hitAttach.Name)

	return clone
end

function BaseTool:init_short_mechanic()
	if not self.RegisteredAnimations.Short then return end

	local short_distance = self.Short_Distance or 2.3
	local barrelWarning  = self:GetBarrelWarningPart()
	if not barrelWarning then warn("[BASETOOL] barrelWarning missing") return end

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

	if self.short_connection then self.short_connection:Disconnect() end

	local lastState = "default"

	local function clearMuzzleFX()
		if warning_beam then warning_beam.Enabled = false end
		if billboard_ui  then billboard_ui.Enabled  = false end
		if barrelWarning.Parent then barrelWarning.Parent = nil end
		muzzleAttach.Parent = nil
		hitAttach.Parent    = nil
	end

	self.short_connection = RunService.RenderStepped:Connect(function()
		if not self.Aiming then clearMuzzleFX() return end
		local character = LOCAL_PLAYER.Character
		if not character or not self.Equipped then clearMuzzleFX() return end

		local head = character:FindFirstChild("Head")
		if not head or not self.actual_model then return end

		local muzzle = self.actual_model:FindFirstChild(self.MuzzlePartName)
		if not muzzle then return end

		rayParams.FilterDescendantsInstances     = { character, self.actual_model, barrelWarning }
		overlapParams.FilterDescendantsInstances = { character, self.actual_model, barrelWarning }

		local headDir    = head.CFrame.LookVector
		local headResult = workspace:Raycast(head.Position, headDir * short_distance, rayParams)

		local muzzleResult = nil

		if not self.Aiming then
			muzzleResult = workspace:Raycast(muzzle.Position, headDir * short_distance, rayParams)
		elseif not headResult and lastState ~= "headBlock" then
			local probe = Instance.new("Part")
			probe.Anchored = true; probe.CanCollide = false; probe.CanQuery = false
			probe.Transparency = 1; probe.Size = Vector3.new(0.15, 0.15, 0.15)
			probe.CFrame = CFrame.new(muzzle.Position, muzzle.Position + headDir)
			probe.Parent = workspace

			for _, p in ipairs(workspace:GetPartsInPart(probe, overlapParams)) do
				if p.Transparency < 0.95 then
					muzzleResult = { Position = muzzle.Position + headDir * 0.1, Distance = 0.1 }
					break
				end
			end
			task.delay(0.05, function() probe:Destroy() end)
		end

		-- Head block
		if headResult then
			if lastState ~= "headBlock" then
				lastState = "headBlock"
				self.IsShorted     = true
				self.ForceBlockFire = true
				self:_stopAllExcept()
				self._shortTrack = self:_playAnim("Short")
				if self._shortTrack then self._shortTrack:AdjustSpeed(0.001) end
			end
			clearMuzzleFX()
			return
		end

		-- Muzzle warning
		if muzzleResult and self.Aiming and lastState ~= "headBlock" then
			if lastState ~= "muzzleWarning" then
				lastState = "muzzleWarning"
				self.IsShorted     = false
				self.ForceBlockFire = true
				self:_stopAllExcept()
				self:_restoreBase("Short")
			end

			barrelWarning.CFrame = CFrame.new(muzzleResult.Position)
			muzzleAttach.Parent  = muzzle
			hitAttach.Parent     = barrelWarning

			if warning_beam then
				warning_beam.Attachment0 = muzzleAttach
				warning_beam.Attachment1 = hitAttach
				warning_beam.Enabled     = true
			end
			if billboard_ui then billboard_ui.Enabled = true end
			if barrelWarning.Parent ~= workspace then barrelWarning.Parent = workspace end
			return
		end

		-- Default
		if lastState ~= "default" then
			lastState = "default"
			self.IsShorted     = false
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

-- // Equip / Unequip

function BaseTool:equip()
	if not self.tool then return end
	self.Equipped  = true
	self.Equipping = true

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	character:SetAttribute("Sprint_Animation", self.className)
	humanoid:EquipTool(self.tool)

	if self._on_equip then self:_on_equip() end

	if self.RegisteredAnimations then
		local draw = self.RegisteredAnimations.Draw
		local hold = self.RegisteredAnimations.Hold
		if draw then self:_playAnim("Draw", true) end
		if hold then
			draw.Stopped:Connect(function()
				if hold and self.tool and self.tool.Parent == character and self.Equipped then
					self:_playAnim("Hold", true)
					hold:AdjustSpeed(0.2)
					self.Equipping = false
					self:init_short_mechanic()
				end
			end)
		end
	end

	if self.model_reference then
		self.actual_model = utilities_module.reverse_search_model(LOCAL_PLAYER, self.model_reference.Name)
		if not self.actual_model then warn("[" .. self.className .. "] Failed to find model") end
	end

	self:_startAimTracking()

	self.sprint_connection = character:GetAttributeChangedSignal("Sprinting"):Connect(function()
		if character:GetAttribute("Sprinting") == true then
			character:GetAttributeChangedSignal("Sprint_Animation"):Wait()
			self:_stopAllExcept()
			local hold = self.RegisteredAnimations.Hold
			hold:Stop()
			print("Is sprinting animation")
		else
			print("Is not sprinting animation")
			if not self.Equipped then return end
			if self.Aiming then
				local aimTrack = self:_aimTrack()
				if aimTrack and not aimTrack.IsPlaying then aimTrack:Play(CUT) end
				return
			end
			if self.RegisteredAnimations and self.RegisteredAnimations.Hold then
				self.RegisteredAnimations.Hold:AdjustSpeed(0.2)
				self:_playAnim("Hold", true)
			end
		end
	end)

	-- Keyframe dispatch
	for _, track in pairs(self.RegisteredAnimations) do
		if not track:IsA("AnimationTrack") then continue end

		table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)
			local rightArm = LOCAL_PLAYER.Character:FindFirstChild("Right Arm")
			if not rightArm then return end
			local round = rightArm:FindFirstChild(self.Round.Name)
			if not round then warn("No self.Round in Right_Arm") return end

			if keyframe == "vfx_hand_shell_visible" then
				round.Transparency = 0

			elseif keyframe == "vfx_hand_shell_invisible" then
				round.Transparency = 1

			elseif keyframe == "vfx_eject_casing" then
				local casing = self.actual_model:FindFirstChild(self.className .. "_Ejection")
				if not casing then warn("[BASETOOL] vfx_eject_casing: no casing for " .. self.className) return end
				BaseTool:emit_casing(casing, casing.CFrame)

			elseif keyframe == "vfx_cylinder_rotate_other" then
				local cylinder_motor: Motor6D =
					self.actual_model
					:FindFirstChild(self.className .. "_Middle")
					:FindFirstChild(self.className .. "_Cylinder")

				if not self.cylinder_rotation_degree then
					self.cylinder_rotation_degree = 360 / self.Max_Capacity
				end

				local newC0 = cylinder_motor.C0 * CFrame.Angles(math.rad(self.cylinder_rotation_degree), 0, 0)
				if self.cylinder_rotation then self.cylinder_rotation += 1 end

				TweenService:Create(cylinder_motor,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ C0 = newC0 }
				):Play()

			elseif keyframe == "vfx_cylinder_load" then
				local cylinder = self.actual_model:FindFirstChild(self.className .. "_Cylinder")
				local round_ref = cylinder:FindFirstChild(self.className .. "_Round" .. self.cylinder_rotation)
				round_ref.Transparency = 0
				round_ref.bullet.Transparency = 0

			elseif keyframe == "vfx_cylinder_empty" then
				local cylinder = self.actual_model:FindFirstChild(self.className .. "_Cylinder")
				for _, r in pairs(cylinder:GetChildren()) do
					if not r:IsA("MeshPart") or not string.find(r.Name, "Round") then continue end
					if r.Transparency == 1 then continue end
					r.Transparency = 1
					r.bullet.Transparency = 1
					r.CanCollide = true
					BaseTool:emit_casing(r, r.CFrame, r.CFrame.RightVector * math.random(0, 8))
				end
				self.cylinder_rotation = 1

			elseif keyframe:sub(1, 4) == "sfx_" then
				local sound = self.SoundFolder:FindFirstChild(keyframe:sub(5))
				if sound then
					self:_play_sfx(sound, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("Sound not found for keyframe: " .. keyframe)
				end

			elseif keyframe:sub(1, 5) == "gsfx_" then
				local baseName = keyframe:sub(6)
				local matches = {}
				for _, child in ipairs(general_sfx:GetChildren()) do
					if child.Name:sub(1, #baseName) == baseName then
						table.insert(matches, child)
					end
				end
				if #matches > 0 then
					self:_play_sfx(matches[math.random(1, #matches)], self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("No GSFX matches for: " .. baseName)
				end
			end
		end))
	end
	
	self.Moving_Connection = character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		self.LastMovedTime = tick()
	end)
end

function BaseTool:unequip()
	if not self.tool then return end
	self.Equipped = false

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	character:SetAttribute("Sprint_Animation", nil)
	if self._on_unequip then self:_on_unequip() end

	if self.RegisteredAnimations then
		for _, anim in pairs(self.RegisteredAnimations) do
			anim:Stop()
		end
	end

	self:_disable_aiming_ui()
	humanoid:UnequipTools()

	self.sprint_connection:Disconnect()
	if self.RegisteredAnimations and self.RegisteredAnimations.Unequip then
		if self.Emergency_Drop == true then
			self:_playAnim("Drop", true)
		else
			self:_playAnim("Unequip", true)
		end
		if self.unequip_wait then
			self.RegisteredAnimations.Unequip.Stopped:Wait()
		end
	end

	self:clean_up_short()
	self.actual_model = nil
	if LOCAL_PLAYER.Character then LOCAL_PLAYER.Character:SetAttribute("Aiming", nil) end

	local ammoCheck = workspace.CurrentCamera:FindFirstChild("Ammo_Check")
	if ammoCheck then ammoCheck:Destroy() end

	if #self.keyframe_connections > 0 then
		for _, conn in pairs(self.keyframe_connections) do conn:Disconnect() end
		self.keyframe_connections = {}
	end
	
	self.Moving_Connection = nil
end

-- // Automatic Spread
function BaseTool:get_spread(muzzle, shootDir)
	local character = game.Players.LocalPlayer.Character

	-- Hold breath
	local holdingBreath = character and character:GetAttribute("HoldBreathe") == true
	if holdingBreath then
		local windedUp = (tick() - (self.HoldBreathStartTime or 0)) >= (self.HoldBreathAccuracyTime or 0.35)
		if windedUp then
			return shootDir
		end
	end

	-- Original game uses moving_accuracy when moving/in air.
	-- Assuming LastMovedTime is maintained elsewhere.
	local isMoving = (tick() - (self.LastMovedTime or 0)) <= 0.1

	local spread = isMoving and self.Moving_Accuracy or self.Accuracy

	local hOffset = math.random(-spread, spread) / 1000
	local vOffset = math.random(-spread, spread) / 1000

	local muzzleCF = muzzle.CFrame

	return (
		shootDir
			+ muzzleCF.RightVector * hOffset
			+ muzzleCF.UpVector * vOffset
	).Unit
end

-- // State helpers

function BaseTool:_isBusy(): boolean
	return self.Firing or self.Reloading or self.Cycling or self.Alting or self.Spinning
		or self.Checking or self.Meleeing
		or (self.RegisteredAnimations and self.RegisteredAnimations.Draw.IsPlaying) or false
end

function BaseTool:_if_sprinting(): boolean
	local char = LOCAL_PLAYER.Character
	return char ~= nil and char:GetAttribute("Sprinting") == true
end

-- // Animation helpers

function BaseTool:_stopAllExcept(exception: AnimationTrack?)
	if not self.RegisteredAnimations then return end
	for _, track in pairs(self.RegisteredAnimations) do
		if track ~= exception and track:IsA("AnimationTrack") and track.IsPlaying then
			track:Stop(CUT)
		end
	end
end

function BaseTool:_playAnim(name: string, bypass_equiped: boolean): AnimationTrack?
	if not self.Equipped and not bypass_equiped then
		warn(self.className .. ":_playAnim called while not equipped: " .. name)
		return nil
	end

	local anims = self.RegisteredAnimations
	assert(anims, self.className .. ":_playAnim called before animations registered")

	local track = anims[name]
	assert(track, self.className .. ": unknown animation '" .. tostring(name) .. "'")

	local layers = self.ANIM_LAYERS
	if layers then
		local myLayer = layers[name] or 0
		local maxLayer = 0
		for _, v in pairs(layers) do if v > maxLayer then maxLayer = v end end

		for trackName, layer in pairs(layers) do
			local shouldStop = (myLayer >= maxLayer) and (layer <= myLayer) or (layer == myLayer)
			if shouldStop then
				local t = anims[trackName]
				if t and t ~= track and t.IsPlaying then t:Stop(CUT) end
			end
		end
	end

	track:Play(CUT)
	return track
end

function BaseTool:_stopLayer(maxLayer: number)
	if not self.RegisteredAnimations then return end
	local layers = self.ANIM_LAYERS
	if not layers then self:_stopAllExcept() return end
	for trackName, layer in pairs(layers) do
		if layer <= maxLayer then
			local t = self.RegisteredAnimations[trackName]
			if t and t.IsPlaying then t:Stop(CUT) end
		end
	end
end

function BaseTool:_aimTrack(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Aim or anims.Aim_Left
end

function BaseTool:_getFireAnim(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Fire or anims.Fire_Left
end

function BaseTool:_killAimTracks()
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Aim      and anims.Aim.IsPlaying      then anims.Aim:Stop(CUT)      end
	if anims.Aim_Left and anims.Aim_Left.IsPlaying then anims.Aim_Left:Stop(CUT) end
end

function BaseTool:_restoreBase()
	if self:_isBusy() or not self.Equipped then return end

	local anims = self.RegisteredAnimations
	if not anims then return end

	if self.ANIM_LAYERS then
		for trackName, layer in pairs(self.ANIM_LAYERS) do
			if layer == 1 then
				local t = anims[trackName]
				if t and t.IsPlaying then t:Stop(CUT) end
			end
		end
	end

	if self.Aiming then
		local want = self:_aimTrack()
		local kill = (want == anims.Aim) and anims.Aim_Left or anims.Aim
		if kill and kill.IsPlaying then kill:Stop(CUT) end
		if anims.Hold and anims.Hold.IsPlaying then anims.Hold:Stop(CUT) end
		if want and not want.IsPlaying then want:Play() end
	else
		self:_killAimTracks()
		if anims.Hold and not anims.Hold.IsPlaying then
			anims.Hold:Play()
			anims.Hold:AdjustSpeed(0.2)
		end
	end
end

function BaseTool:_restoreBaseDeferred()
	task.defer(function() self:_restoreBase() end)
end

function BaseTool:_set_sprint_arms(enabled: boolean)
	if enabled then
		LOCAL_PLAYER.Character:SetAttribute("No_Sprint_Animation", true)
	else
		LOCAL_PLAYER.Character:SetAttribute("No_Sprint_Animation", nil)
	end
end

-- // Melee (shared)

function BaseTool:melee()
	if self.Meleeing then return end
	if game.Players.LocalPlayer:GetAttribute("FreeLook") then return end
	self.Meleeing = true

	local anims = self.RegisteredAnimations
	self:_stopAllExcept()

	local anim = "Melee" .. math.random(1, 2)
	self:_playAnim(anim).Stopped:Connect(function()
		self.Meleeing = false
	end)
	
	self:_restoreBase()
end

-- // Shoulder tracking

function BaseTool:_onShoulderChanged()
	if self:_isBusy() or not self.Aiming then return end

	task.defer(function()
		if self:_isBusy() or not self.Aiming then return end

		local anims = self.RegisteredAnimations
		if not anims then return end

		local oldAimTrack = nil
		if anims.Aim      and anims.Aim.IsPlaying      then oldAimTrack = anims.Aim      end
		if anims.Aim_Left and anims.Aim_Left.IsPlaying then oldAimTrack = anims.Aim_Left end

		local newAimTrack = self:_aimTrack()
		if not newAimTrack or oldAimTrack == newAimTrack then return end

		if oldAimTrack and oldAimTrack.IsPlaying then oldAimTrack:Stop(CUT) end
		if not newAimTrack.IsPlaying then newAimTrack:Play(CUT) end
	end)
end

-- // Aim system

function BaseTool:aim()
	if self.Aiming or self:_isBusy() then return end
	if not self.RegisteredAnimations.Aim then return end
	if LOCAL_PLAYER:GetAttribute("FreeLook") then return end
	if self.Equipping or self.IsShorted then return end

	local function updateAimAnimation()
		self:_killAimTracks()

		if LOCAL_PLAYER:GetAttribute("Jumping") then
			self.ForceBlockFire = true
			if self._shortTrack then self._shortTrack:Stop(0) end
			self._shortTrack = self:_playAnim("Short")
			if self._shortTrack then self._shortTrack:AdjustSpeed(1) end
			return
		end

		if self._shortTrack then
			self._shortTrack:Stop(CUT)
			self._shortTrack = nil
		end

		local aimTrack = self:_aimTrack()
		if aimTrack then aimTrack:Play(CUT) self.ForceBlockFire = false end
		
	end

	self.Aiming = true
	self._aimVersion += 1
	self:_startAimTracking()

	local anims = self.RegisteredAnimations
	if not anims then return end

	if anims.Hold and anims.Hold.IsPlaying then anims.Hold:Stop(CUT * 1.5) end

	updateAimAnimation()

	local character = LOCAL_PLAYER.Character
	if character then character:SetAttribute("Aiming", true) end

	self:_enable_aiming_ui(self.Aiming_Number or 50)
	self:_startTransparencyTracking()

	if not self._jumpAimConnection then
		self._jumpAimConnection = LOCAL_PLAYER:GetAttributeChangedSignal("Jumping"):Connect(function()
			if self.Aiming then updateAimAnimation() end
		end)
	end

	if not self._freeLookAimConnection then
		self._freeLookAimConnection = LOCAL_PLAYER:GetAttributeChangedSignal("FreeLook"):Connect(function()
			if LOCAL_PLAYER:GetAttribute("FreeLook") then self:endAiming() end
		end)
	end
end

function BaseTool:endAiming()
	if not self.Aiming then return end
	self.Aiming = false
	self._aimVersion += 1

	self:_stopTransparencyTracking()
	self:_killAimTracks()

	self.IsShorted     = false
	self.ForceBlockFire = false
	if not self:_isBusy() then
		local anims = self.RegisteredAnimations
		if anims and anims.Hold and not anims.Hold.IsPlaying then
			anims.Hold:Play(CUT)
			anims.Hold:AdjustSpeed(0.2)
		end
	end

	local char = LOCAL_PLAYER.Character
	if char then char:SetAttribute("Aiming", nil) end
	self:_disable_aiming_ui()
	self:_resetBodyTransparency()
end

-- // Transparency helpers

function BaseTool:_startTransparencyTracking()
	if self._transparencyConnection then self._transparencyConnection:Disconnect() end

	local char = LOCAL_PLAYER.Character
	if not char then return end

	self._transparencyConnection = RunService.RenderStepped:Connect(function()
		if not self.Aiming or not char or not char:FindFirstChild("Humanoid") then return end
		if LOCAL_PLAYER:GetAttribute("FirstPerson") then
			return
		end

		local pitchAngle = math.rad(CAMERA.CFrame:ToEulerAnglesYXZ() * 50)
		self:_setBodyTransparency((pitchAngle >= 0.43 or pitchAngle <= -0.9) and CHARACTER_TRANSPARENCY or 0)
	end)
end

function BaseTool:_stopTransparencyTracking()
	if self._transparencyConnection then
		self._transparencyConnection:Disconnect()
		self._transparencyConnection = nil
	end
end

function BaseTool:_setBodyTransparency(transparency: number)
	local char = LOCAL_PLAYER.Character
	if not char then return end
	for _, name in ipairs({"Left Arm", "Right Arm" }) do
		local part = char:FindFirstChild(name)
		if part then part.Transparency = transparency end
	end
end

function BaseTool:_resetBodyTransparency()
	self:_setBodyTransparency(0)
end

-- // Input

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
					if self.Can_Drop and self.Reloading then
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
		if matched then self:endAiming() end
	end)
end

function BaseTool:_disconnectInput()
	if self._inputBeganConn  then self._inputBeganConn:Disconnect();  self._inputBeganConn  = nil end
	if self._inputEndedConn  then self._inputEndedConn:Disconnect();  self._inputEndedConn  = nil end
end

-- // Shoulder tracking

function BaseTool:_initShoulderTracking()
	if not RunService:IsClient() then return end
	self.current_shoulder = LOCAL_PLAYER:GetAttribute("Current_Shoulder") or "Right"

	if self._shoulderChangedConn then self._shoulderChangedConn:Disconnect() end

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

-- // Aim motor tracking

function BaseTool:_startAimTracking()
	if self._aimConnection then return end

	local character = LOCAL_PLAYER.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torso = character and character:FindFirstChild("Torso")
	if not (character and root and torso) then return end

	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	if not (leftShoulder and rightShoulder) then return end

	self._restLeftC0 = self._restLeftC0 or leftShoulder.C0
	self._restRightC0 = self._restRightC0 or rightShoulder.C0

	self._wasFreeLook = self._wasFreeLook or false
	self._freeLookYaw = self._freeLookYaw or 0

	self._smoothedYaw = self._smoothedYaw or 0
	self._lastYaw = self._lastYaw or 0


	
	local lerpAlpha = 0.15

	self._aimConnection = RunService.RenderStepped:Connect(function()
		if not self.Equipped then
			return
		end

		local char = LOCAL_PLAYER.Character
		local r = char and char:FindFirstChild("HumanoidRootPart")
		local t = char and char:FindFirstChild("Torso")
		if not (char and r and t) then
			return
		end

		local ls = t:FindFirstChild("Left Shoulder")
		local rs = t:FindFirstChild("Right Shoulder")
		if not (ls and rs) then
			return
		end

		if not self.Aiming then
			if self._restLeftC0 then
				ls.C0 = ls.C0:Lerp(self._restLeftC0, lerpAlpha)
			end

			if self._restRightC0 then
				rs.C0 = rs.C0:Lerp(self._restRightC0, lerpAlpha)
			end

			return
		end

		local leftArmCF
		local rightArmCF

		if LOCAL_PLAYER:GetAttribute("FirstPerson") then
			local camCF = CAMERA.CFrame

			local shoulderOffset = CFrame.new()

			if self.current_shoulder == "Left" then
				shoulderOffset = CFrame.new(-0.4, -1.75, 0)
			elseif self.current_shoulder == "Right" then
				shoulderOffset = CFrame.new(0.5, -1.75, 0)
			end

			leftArmCF = t.CFrame:ToObjectSpace(
				camCF
					* shoulderOffset
					* CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)
					* CFrame.new(-1, 0.5, 0)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			rightArmCF = t.CFrame:ToObjectSpace(
				camCF
					* shoulderOffset
					* CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)
					* CFrame.new(1, 0.5, 0)
					* CFrame.Angles(0, math.pi / 2, 0)
			)
		else
			local currentLookDir = CAMERA.CFrame.LookVector
			local cameraPitch = math.asin(math.clamp(currentLookDir.Y, -1, 1))

			local relativeCF = r.CFrame:ToObjectSpace(CAMERA.CFrame)
			local lookDir = relativeCF.LookVector

			local rawYaw = math.atan2(-lookDir.X, -lookDir.Z)

			local deltaYaw = rawYaw - self._lastYaw

			if deltaYaw > math.pi then
				deltaYaw -= 2 * math.pi
			elseif deltaYaw < -math.pi then
				deltaYaw += 2 * math.pi
			end

			self._smoothedYaw += deltaYaw * 0.25
			self._lastYaw = rawYaw

			local yaw = self._smoothedYaw

			if not LOCAL_PLAYER:GetAttribute("FreeLook") then
				self._wasFreeLook = false
				self._freeLookYaw = yaw
			end

			local rotationCF = CFrame.Angles(0, yaw, 0) * CFrame.Angles(cameraPitch, 0, 0)
			local armRotation = rotationCF * CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)

			leftArmCF = t.CFrame:ToObjectSpace(
				r.CFrame
					* armRotation
					* CFrame.new(-1, 0.5, 0)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			rightArmCF = t.CFrame:ToObjectSpace(
				r.CFrame
					* armRotation
					* CFrame.new(1, 0.5, 0)
					* CFrame.Angles(0, math.pi / 2, 0)
			)
		end

		if LOCAL_PLAYER:GetAttribute("FirstPerson") then
			local targetLeftRot = leftArmCF - leftArmCF.Position
			local targetRightRot = rightArmCF - rightArmCF.Position

			self._fpLeftRot = self._fpLeftRot or (leftArmCF - leftArmCF.Position)
			self._fpRightRot = self._fpRightRot or (rightArmCF - rightArmCF.Position)
			
			self._fpLeftRot = self._fpLeftRot:Lerp(targetLeftRot, 0.12)
			self._fpRightRot = self._fpRightRot:Lerp(targetRightRot, 0.12)

			
			ls.C0 = CFrame.new(leftArmCF.Position) * self._fpLeftRot
			rs.C0 = CFrame.new(rightArmCF.Position) * self._fpRightRot
		else
			ls.C0 = ls.C0:Lerp(leftArmCF, lerpAlpha)
			rs.C0 = rs.C0:Lerp(rightArmCF, lerpAlpha)
		end
	end)
end

function BaseTool:_stopAimTracking()
	if self._aimConnection then
		self._aimConnection:Disconnect()
		self._aimConnection = nil
	end

	local character = LOCAL_PLAYER.Character
	local torso = character and character:FindFirstChild("Torso")

	if torso then
		local resetInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ls = torso:FindFirstChild("Left Shoulder")
		local rs = torso:FindFirstChild("Right Shoulder")
		if ls and self._restLeftC0  then TweenService:Create(ls, resetInfo, { C0 = self._restLeftC0  }):Play() end
		if rs and self._restRightC0 then TweenService:Create(rs, resetInfo, { C0 = self._restRightC0 }):Play() end
	end

	task.delay(0.15, function()
		if not self.Aiming then self:_resetMotor6D() end
	end)
end

-- // Motor6D helpers

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
	local targetC0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(-math.rad(90), 0, 0)
	local targetC1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(-math.rad(90), 0, 0)
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

-- // Bullet hit & penetration

function BaseTool:_onBulletHit(cast, result, velocity, muzzle, Penetration_Level, damage, knockback_force)
	local profile = Penetration_Profiles[Penetration_Level]
	if not profile or not muzzle or cast.UserData.Penetrated then return end

	local instance  = result.Instance
	local material  = result.Material
	local direction = cast.UserData.Direction :: Vector3

	local hitModel    = instance:FindFirstAncestorOfClass("Model")
	local isCharacter = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

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

	self:bullet_hole(result.Position, result.Normal)

	if material == Enum.Material.Wood then
		self:emit_effect(FX_WOOD_CHIPS,
			CFrame.new(result.Position, result.Position + result.Normal),
			{ "woodchip1", "woodchip2", "woodchip3" },
			instance, 20, false
		)
	end

	local thicknessParams = RaycastParams.new()
	thicknessParams.FilterType = Enum.RaycastFilterType.Include
	thicknessParams.FilterDescendantsInstances = { instance }

	if workspace:Raycast(result.Position + direction * 0.05, direction * profile.Stud_Limit, thicknessParams) then
		cast.UserData.Penetrated = true
		return
	end

	local exitParams = RaycastParams.new()
	exitParams.FilterType = Enum.RaycastFilterType.Include
	exitParams.FilterDescendantsInstances = { instance }

	local exitResult = workspace:Raycast(result.Position + direction * profile.Stud_Limit, -direction * profile.Stud_Limit, exitParams)
	if exitResult then self:bullet_hole(exitResult.Position, exitResult.Normal) end

	cast.UserData.Penetrated = true

	local newOrigin = result.Position + direction * 0.2
	local continuation = self.Caster:Fire(newOrigin, direction, velocity.Magnitude, self.CasterBehavior)
	self:_connect_FastCast(newOrigin, direction, velocity.Magnitude, {
		bulletTemplate   = FxFolder.Bullet,
		bulletContainer  = workspace.Game_Details.Effects.Bullets,
		isPenetration    = true,
		penetrationLevel = Penetration_Level,
		damage           = damage,
		knockbackForce   = knockback_force,
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

-- // FastCast setup

function BaseTool:_setupFastCast(fxFolder: Folder, onHitCallback: (any, RaycastResult, Vector3) -> ())
	local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
	self.Caster, self.CasterBehavior = Util.setupFastCast({
		bulletTemplate  = fxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		onHit           = onHitCallback,
	})
end

-- // Projectile firing

function BaseTool:_fireProjectile(bulletSpeed, penetrationLevel, damage, knockbackForce): boolean
	if self:_if_sprinting() then return false end

	local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName or "Muzzle")
	if not muzzle then warn(self.className .. ": Muzzle not found") return false end

	local camera = workspace.CurrentCamera
	if not camera then return false end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	local result    = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir  = (targetPos - muzzle.Position).Unit

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, bulletSpeed, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false

	self:_connect_FastCast(muzzle.Position, shootDir, bulletSpeed)
	return true
end

-- // Muzzle flash

function BaseTool:_fireMuzzleFlash()
	if not self.actual_model then return end
	local muzzle = self.actual_model:FindFirstChild(self.MuzzlePartName or "Muzzle")
	if not muzzle then return end

	self:emit_effect(
		ReplicatedStorage.Shared.Assets.Guns.Effects.Shooting.Muzzle_Flash,
		muzzle.CFrame * CFrame.new(-0.1, 0, -2),
		{ "smoke_medium", "smoke_forward", "flash_general" },
		muzzle, 1, false
	)
end

-- // Generic reload sequence

function BaseTool:_reloadSequence(startAnimName, loopAnimName, endAnimName, onLoopCallback, maxAmmo, currentAmmo): boolean
	if self.Reloading or currentAmmo >= maxAmmo then return false end

	self:_stopAllExcept()
	self.Reloading        = true
	self._reloadCancelled = false

	local anims = self.RegisteredAnimations
	if not anims then self.Reloading = false; return false end

	if startAnimName and anims[startAnimName] then
		self:_playAnim(startAnimName).Stopped:Wait()
	end

	while currentAmmo < maxAmmo and not self._reloadCancelled do
		if loopAnimName and anims[loopAnimName] then
			self:_playAnim(loopAnimName).Stopped:Wait()
		end
		if self._reloadCancelled then break end
		currentAmmo += 1
		if onLoopCallback then onLoopCallback(currentAmmo) end
	end

	if not self._reloadCancelled then
		if endAnimName and anims[endAnimName] then
			self:_playAnim(endAnimName).Stopped:Wait()
		end
	else
		for _, name in ipairs({ startAnimName, loopAnimName, endAnimName }) do
			if name and anims[name] and anims[name].IsPlaying then anims[name]:Stop(CUT) end
		end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	return true
end

-- // Replication

function BaseTool:_connect_FastCast(...)
	fast_cast_replication:FireServer(...)
end

function BaseTool:_play_sfx(...)
	replicant_service.connect_sfx(LOCAL_PLAYER, ...)
end

-- // Aiming UI

function BaseTool:_enable_aiming_ui(max_aiming: number)
	local aiming_gui = game.Players.LocalPlayer.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = false
	aiming_gui.Scoped_In.Visible = true

	local scoped = aiming_gui.Scoped_In.main
	local down, left, right, up = scoped.down, scoped.left, scoped.right, scoped.up

	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local root      = character:WaitForChild("HumanoidRootPart")
	local humanoid  = character:WaitForChild("Humanoid")

	if self.character_connection then
		self.character_connection:Disconnect()
	end

	local currentSpread = 0

	self.character_connection = RunService.RenderStepped:Connect(function()
		if not root or not humanoid then
			return
		end

		local holdingBreath = character:GetAttribute("HoldBreathe") == true
		local targetSpread

		if holdingBreath then
			if not self._breathStartTime then
				self._breathStartTime = tick()
				self._spreadAtBreath = currentSpread
			end

			local breathHeldFor = tick() - self._breathStartTime
			local windUp = math.clamp(breathHeldFor / 0.5, 0, 1)

			local breathBonus = 5

			targetSpread = (self._spreadAtBreath or currentSpread)
				+ ((-breathBonus) - (self._spreadAtBreath or currentSpread)) * windUp
		else
			self._breathStartTime = nil
			self._spreadAtBreath = nil

			local speed = Vector3.new(
				root.AssemblyLinearVelocity.X,
				0,
				root.AssemblyLinearVelocity.Z
			).Magnitude

			local alpha = (humanoid.WalkSpeed > 0)
				and math.clamp(speed / humanoid.WalkSpeed, 0, 1)
				or 0

			targetSpread = alpha * max_aiming
		end

		currentSpread = currentSpread + (targetSpread - currentSpread) * 0.3

		-- Normal resting offset is 5px.
		-- Holding breath can now pull it below that.
		local offset = math.max(1, 5 + currentSpread)

		up.Position    = UDim2.new(0.5, 0, 0, -offset)
		down.Position  = UDim2.new(0.5, 0, 1, offset)
		left.Position  = UDim2.new(0, -offset, 0.5, 0)
		right.Position = UDim2.new(1, offset, 0.5, 0)
	end)
end

function BaseTool:_bounce_scoped_ui()
	local Scoped_In = LOCAL_PLAYER.PlayerGui.Aiming.Scoped_In
	local main = Scoped_In.main

	local currentSize = main.Size.X.Offset
	local kickSize = currentSize + 40

	-- Pop out
	TweenService:Create(main, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, kickSize, 0, kickSize)
	}):Play()

	-- Bounce back
	task.delay(0.03, function()
		TweenService:Create(main, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, currentSize, 0, currentSize)
		}):Play()
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

-- // Notifications

function BaseTool:notify(text: string)
	local Notifications_util = require(
		LOCAL_PLAYER.PlayerGui:WaitForChild("Notifications"):WaitForChild("Utils")
	)
	Notifications_util.send_notification(LOCAL_PLAYER, text)
end

-- // Ammo check

function BaseTool:ammo_check()
	if not self.RegisteredAnimations or not self.RegisteredAnimations.Check then return end
	if self:_isBusy() or self.Checking or self.Check_Delayed then return end

	self:_set_sprint_arms(true)
	self.Checking     = true
	self.Check_Delayed = true

	local ammo_check_part, ammo_check_utils
	local cam = workspace.CurrentCamera
	if not cam:FindFirstChild("Ammo_Check") then
		ammo_check_part  = game.ReplicatedStorage.Shared.Assets.Guns.Effects.AmmoUI.Ammo_Check:Clone()
		ammo_check_part.Parent = cam
		ammo_check_utils = require(ammo_check_part.Utils)
	else
		ammo_check_part  = cam.Ammo_Check
		ammo_check_utils = require(cam.Ammo_Check.Utils)
	end

	self:_stopLayer(1)
	self:_killAimTracks()
	if self.RegisteredAnimations.Hold and self.RegisteredAnimations.Hold.IsPlaying then
		self.RegisteredAnimations.Hold:Stop(CUT)
	end

	self.RegisteredAnimations.Check:AdjustWeight(1)
	self:_playAnim("Check")

	local middle = self.actual_model:FindFirstChild(self.className .. "_Middle")
	ammo_check_part.CFrame = middle.CFrame + middle.CFrame.rightVector * -0.5 + middle.CFrame.upVector * 1

	if not ammo_check_part:FindFirstChild("WeldConstraint") then
		local weld   = Instance.new("WeldConstraint")
		weld.Part0   = ammo_check_part
		weld.Part1   = self.actual_model:FindFirstChild(self.MuzzlePartName)
		weld.Parent  = ammo_check_part
	end

	ammo_check_utils.utils(self.Ammo_Type, math.clamp(self.Capacity / self.Max_Capacity, 0, 1),
		false, self.tool:FindFirstChild("Reserve_Ammo").Value / (self.Max_Capacity * 3))

	self.RegisteredAnimations.Check.Stopped:Wait()

	self.Checking = false
	self:_restoreBase()
	self:_set_sprint_arms(false)

	task.delay(self.Check_Delay or 1, function()
		self.Check_Delayed = false
	end)
end

function BaseTool:drop()
	drop_connection:FireServer(self.className, self.model_reference, true)
	self:destroy()
	self.Emergency_Drop = true
end

-- // VFX

function BaseTool:emit_effect(effect, CFrame_Value, target_tables, parent, emit_count, attach_to_parent)
	emit_count = emit_count or 10

	for _, child in pairs(effect:GetDescendants()) do
		if not (table.find(target_tables, child.Name) or table.find(target_tables, child.ClassName)) then continue end

		local clone = child:Clone()

		if attach_to_parent then
			clone.Parent = parent
		else
			local part = Instance.new("Part")
			part.Size = Vector3.new(0.05, 0.05, 0.05)
			part.Anchored = true; part.CanCollide = false; part.Transparency = 1
			part.Parent = workspace; part.CFrame = CFrame_Value
			clone.Parent = part

			if clone:IsA("ParticleEmitter") then
				clone.Enabled = true
				clone:Emit(emit_count)
				task.delay(clone.Lifetime.Max + 0.1, function() part:Destroy() end)
			end
			continue
		end

		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emit_count)
			task.delay(clone.Lifetime.Max + 0.1, function() clone:Destroy() end)
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

function BaseTool:emit_casing(casing: Part, origin: CFrame, direction: Vector3)
	local clone = casing:Clone()
	clone.Parent = workspace
	clone.CFrame = origin
	clone.Anchored = false; clone.CanCollide = true; clone.Transparency = 0

	local vel = direction or origin.LookVector * math.random(10, 15) + Vector3.new(0, math.random(10, 15), 0)

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = vel
	bv.Parent   = clone

	clone.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

	task.delay(0.1, function() bv:Destroy() end)
	
	task.delay(3, function() clone:Destroy() end)
end

-- // Stubs

function BaseTool:activate() end
function BaseTool:reload() end

-- // Cleanup

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