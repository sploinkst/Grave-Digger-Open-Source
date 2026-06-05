-----------------------
--@Praxitos
--PrinceRifle
------------------------

--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local Types    = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local Util     = require(script.Parent.Parent.Parent.Util)

-- // Assets

local Assets        = ReplicatedStorage.Shared.Assets
local SoundFolder   = Assets.Guns:WaitForChild("Sounds"):WaitForChild("PrinceRifle")
local HolsterFolder = Assets.Guns.Holsters:FindFirstChild("Gun Holsters")
local ToolFolder    = Assets.Guns.ToolModels
local AnimFolder    = Assets.Animations.Tools.Guns.PrinceRifle
local FxFolder      = Assets.Guns.Effects.Shooting

local fire_sound = SoundFolder.fire

-- // Tuning

local CYCLE_REST_TIME = 1
local FIRE_RATE       = 0.30
local BULLET_SPEED    = 1000

-- // Animation layers

local ANIM_LAYERS: { [string]: number } = {
	Hold     = 0,
	Aim      = 0,
	Aim_Left = 0,

	Fire      = 1,
	Fire_Left = 1,
	Cycle     = 1,

	Draw         = 2,
	Unequip      = 2,
	Check        = 2,
	Reload_Empty = 2,
	Reload_Start = 2,
	Reload_Loop  = 2,
	Reload_End   = 2,
	Reload_Alt   = 2,
	Alt_Mode_On  = 2,
	Alt_Mode_Off = 2,
	Melee1       = 2,
	Melee2       = 2,
}

-- // Class

local PrinceRifle = {}
PrinceRifle.__index = PrinceRifle
setmetatable(PrinceRifle, { __index = BaseTool })

export type PrinceRifle = typeof(setmetatable({} :: {
	className:   "PrinceRifle",
	name:        string,
	item_image:  string,
	Designation: string,

	holster_reference: Instance?,
	actual_holster:    Model?,
	model_reference:   Model?,
	actual_model:      Model?,

	damage:                  number,
	Max_Capacity:            number,
	Capacity:                number,
	Ammo_Type:               string,
	recoil:                  number,
	recoil_count:            number,
	Penetration_Level:       number,
	Armor_Penetration_Level: number,
	KnockBack_Force:         number,
	Aiming_Number:           number,
	Check_Delay:             number,
	MuzzlePartName:          string,

	Aiming:    boolean,
	Cycled:    boolean,
	Firing:    boolean,
	Cycling:   boolean,
	Reloading: boolean,
	Alt_Mode:  boolean,
	Alting:    boolean,
	Checking:  boolean,
	Meleeing:  boolean,

	_reloadCancelled: boolean,
	ANIM_LAYERS:      { [string]: number },
	current_shoulder: string,

	Caster:         any,
	CasterBehavior: any,

	motor_6d:       Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
}, {} :: typeof(PrinceRifle)))

-- // Constructor

function PrinceRifle.new(info: Types.BaseToolCreateInfo): PrinceRifle
	local self = setmetatable(BaseTool.new(info), PrinceRifle)

	self.className   = "PrinceRifle"
	self.item_image  = "rbxassetid://17496049645"
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.holster_reference = HolsterFolder and HolsterFolder:FindFirstChild("PrinceRifleHolster")
	self.model_reference   = ToolFolder:FindFirstChild("PrinceRifle")
	self.Round             = Assets.Guns.Rounds.PrinceRifle_Round

	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0  = "Left Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("PrinceRifle_Middle"),
		C0     = CFrame.new(0.254, -1.703, -0.566) * CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Draw    = AnimFolder.PrinceRifle_Draw,
		Hold    = AnimFolder.PrinceRifle_Held,
		Unequip = AnimFolder.PrinceRifle_Unequip,

		Aim      = AnimFolder.PrinceRifle_Aim,
		Aim_Left = AnimFolder.PrinceRifle_Aim_Left,

		Fire      = AnimFolder.PrinceRifle_Fire,
		Fire_Left = AnimFolder.PrinceRifle_Fire_Left,

		Cycle = AnimFolder.PrinceRifle_Cycle,

		Reload_Empty = AnimFolder.PrinceRifle_Reload_Empty,
		Reload_Start = AnimFolder.PrinceRifle_Reload_Start,
		Reload_Loop  = AnimFolder.PrinceRifle_Reload_Loop,
		Reload_End   = AnimFolder.PrinceRifle_Reload_End,
		Reload_Alt   = AnimFolder.PrinceRifle_Reload_Alt,

		Alt_Mode_On  = AnimFolder.PrinceRifle_Alt_Mode_On,
		Alt_Mode_Off = AnimFolder.PrinceRifle_Alt_Mode_Off,

		Check  = AnimFolder.PrinceRifle_Check,
		Melee1 = AnimFolder.PrinceRifle_Melee1,
		Melee2 = AnimFolder.PrinceRifle_Melee2,

		Drop  = AnimFolder.Parent.Parent.Misc.Drop_Rifle,
		Short = AnimFolder.PrinceRifle_Short,
	}

	self.animation_speeds = {
		Cycle        = 0.55,
		Draw         = 0.75,
		Aim          = 0.35,
		Aim_Left     = 0.35,
		Reload_Start = 1.6,
		Reload_Empty = 1.45,
		Reload_Loop  = 0.65,
		Reload_End   = 1.45,
		Reload_Alt   = 1.4,
		Melee1       = 0.7,
		Melee2       = 0.7,
	}

	self.damage                  = 105
	self.Max_Capacity            = 10
	self.Capacity                = 10
	self.Ammo_Type               = "8mm Smokeless"
	self.recoil                  = 10
	self.recoil_count            = 6
	self.Penetration_Level       = 2
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force         = 10
	self.Aiming_Number           = 100
	self.Check_Delay             = 1
	self.MuzzlePartName          = "PrinceRifle_Muzzle"
	self.Can_Drop                = true
	self.SoundFolder             = SoundFolder
	self.Short_Distance          = 4
	self.Melee_Distance			 = 5
	self.Melee_Damage			 = 80
	self.Accuracy = 6
	self.Moving_Accuracy = 100

	self.unequip_wait     = false
	self.Cycled           = true
	self.Firing           = false
	self.Cycling          = false
	self.Reloading        = false
	self.Alt_Mode         = true
	self.Alting           = false
	self._reloadCancelled = false
	self.Checking         = false
	self.Check_Delayed    = false
	self.Meleeing         = false

	self:_initShoulderTracking()

	return self
end

-- // Key bindings

function PrinceRifle:_getKeyBindings()
	local base = BaseTool._getKeyBindings(self)
	base.AltMode = Enum.KeyCode.Q
	return base
end

function PrinceRifle:AltMode()
	self:setAltMode()
end

-- // Actions

function PrinceRifle:setAltMode()
	if self:_isBusy() then return end
	self.Alting = true
	self:_stopAllExcept()

	if self.Alt_Mode then
		self:_playAnim("Alt_Mode_Off").Stopped:Wait()
		self.Alt_Mode = false
		self:notify("Firemode: Single Fire")
	else
		self:_playAnim("Alt_Mode_On").Stopped:Wait()
		self.Alt_Mode = true
		self:notify("Firemode: Repeating Fire")
		if not self.Cycled then self:cycle() end
	end

	self.Alting = false
	self:_restoreBase()
end

function PrinceRifle:cycle()
	if self.Cycling then return end
	self.Cycling = true

	local anims = self.RegisteredAnimations
	if not anims then self.Cycling = false; return end

	self:_stopAllExcept()
	self:_playAnim("Cycle")
	self.tool:FindFirstChild("Reserve_Ammo").Value -= 1

	task.delay(CYCLE_REST_TIME, function()
		self.Cycled  = true
		self.Cycling = false
		self:_restoreBase()
	end)
end

function PrinceRifle:fire()
	if self.Checking then return end
	if self.Capacity <= 0 then self:reload() return end
	if self.Firing then return end
	self.Firing = true

	if self:_if_sprinting() or self.ForceBlockFire then
		self.Firing = false
		return
	end

	local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName)
	if not muzzle then self.Firing = false; return end

	local camera = workspace.CurrentCamera
	if not camera then self.Firing = false; return end

	-- Aim logic
	local mousePos = UserInputService:GetMouseLocation()
	local ray      = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

	local result    = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir  = (targetPos - muzzle.Position).Unit

	shootDir = self:get_spread(muzzle, shootDir)
	-- Fire
	self:_play_sfx(fire_sound, muzzle, nil, self.Alt_Mode and 0.5 or nil)
	self:_bounce_scoped_ui()

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, BULLET_SPEED, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false

	self:_connect_FastCast(muzzle.Position, shootDir, BULLET_SPEED, {
		bulletTemplate   = FxFolder.Bullet,
		bulletContainer  = workspace.Game_Details.Effects.Bullets,
		isPenetration    = false,
		penetrationLevel = self.Penetration_Level,
		damage           = self.damage,
		knockbackForce   = self.KnockBack_Force,
	})

	self.Cycled    = false
	self.Capacity -= 1

	local fireAnim = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	self:_stopAllExcept()
	local fire_track = self:_playAnim(fireAnim)

	Util.applyRecoil(self.recoil, self.recoil_count, 10, false)

	if self.Alt_Mode then self:cycle() end

	self:_fireMuzzleFlash()

	fire_track.Stopped:Once(function()
		self:_restoreBase()
	end)
	
	task.wait(FIRE_RATE)
	self.Firing = false
end

function PrinceRifle:_autoCycle()
	if self.Capacity >= self.Max_Capacity then self.Cycled = true; return end
	if self.Cycling then return end

	self.Cycling = true
	self.Cycled  = false

	if not self.RegisteredAnimations then self.Cycling = false; return end

	self:_stopAllExcept()
	self:_playAnim("Reload_Alt").Stopped:Wait()

	if self.tool:FindFirstChild("Reserve_Ammo").Value > 0 then
		self.tool:FindFirstChild("Reserve_Ammo").Value -= 1
		self.Capacity += 1
	end

	self.Cycling = false
	self.Cycled  = true
	self:_restoreBase()
end

function PrinceRifle:reload()
	if self.Reloading or self.Equipping then return end
	if self.Capacity >= self.Max_Capacity then return end

	if self.tool:FindFirstChild("Reserve_Ammo").Value <= 0 then
		self:notify("I don't have any more ammo...")
		self.Cycling = false
		self:_restoreBase()
		return
	end

	if self.Alt_Mode then
		self:_stopAllExcept()
		self.Reloading        = true
		self._reloadCancelled = false

		if self.Aiming then self:endAiming() end

		local anims = self.RegisteredAnimations

		if self.Capacity == 0 then
			self:_playAnim("Reload_Empty").Stopped:Wait()
		else
			self:_playAnim("Reload_Start").Stopped:Wait()
		end

		while self.Capacity < self.Max_Capacity and not self._reloadCancelled do
			self:_playAnim("Reload_Loop").Stopped:Wait()
			if self._reloadCancelled then break end
			self.Capacity += 1
			self.tool:FindFirstChild("Reserve_Ammo").Value -= 1
		end

		if not self._reloadCancelled then
			self:_playAnim("Reload_End").Stopped:Wait()
		else
			for _, name in ipairs({ "Reload_Loop", "Reload_Start", "Reload_Empty" }) do
				local t = anims[name]
				if t and t.IsPlaying then t:Stop(0.15) end
			end
		end

		self.Reloading        = false
		self._reloadCancelled = false
		self:_restoreBase()
	else
		self:_autoCycle()
	end
end

function PrinceRifle:activate()
	if not self.actual_model then return end
	if self:_isBusy() or self.Firing or self.Cycling or not self.Cycled then return end

	if self.Aiming then
		self:fire()
	else
		self:melee()
	end
end

-- // Lifecycle hooks

function PrinceRifle:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()

	local char = game.Players.LocalPlayer.Character

	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level, self.damage, self.KnockBack_Force)
	end)

	-- Keyframe-driven round visibility (local to equip, before BaseTool keyframe dispatch)
	for _, track in pairs(self.RegisteredAnimations) do
		if not track:IsA("AnimationTrack") then continue end
		track.KeyframeReached:Connect(function(keyframe)
			local rightArm = char:FindFirstChild("Right Arm")
			if not rightArm then return end
			local round = rightArm:FindFirstChild(self.Round.Name)
			if not round then return end

			if keyframe == "vfx_hand_shell_visible" then
				round.Transparency = 0
			elseif keyframe == "vfx_hand_shell_invisible" then
				round.Transparency = 1
			end

			if keyframe:sub(1, 4) == "sfx_" then
				local sound = SoundFolder:FindFirstChild(keyframe:sub(5))
				if sound then
					self:_play_sfx(sound, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("Sound not found for keyframe: " .. keyframe)
				end
			end
		end)
	end
end

function PrinceRifle:_on_unequip()
	self.Equipped         = false
	self._reloadCancelled = true

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	self.Cycled    = true
	self.Firing    = false
	self.Cycling   = false
	self.Reloading = false
	self.Alting    = false

	local char = game.Players.LocalPlayer.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

-- // Cleanup

function PrinceRifle:Destroy()
	self:_disconnectInput()
	BaseTool.destroy(self)
end

PrinceRifle.Tool_Image = "rbxassetid://17496049645"
PrinceRifle.Medal_Cost = 0
PrinceRifle.Weight     = 2

return PrinceRifle