-----------------------
--@Praxitos
--GraceRevolver
------------------------

--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types    = require(script.Parent.Parent.Parent.Types)
local BasePistol = require(script.Parent.Parent.BasePistol)

-- // Assets

local Assets         = ReplicatedStorage.Shared.Assets
local Holster_Folder = Assets.Guns.Holsters
local Tool_Folder    = Assets.Guns.ToolModels
local Anim_Folder    = Assets.Animations.Tools.Guns.GraceRevolver
local FxFolder       = Assets.Guns.Effects

local SoundFolder = Assets.Guns:WaitForChild("Sounds"):WaitForChild("GraceRevolver")
local fire_sound  = SoundFolder.fire

-- // Tuning

local FIRE_RATE    = 0.75
local BULLET_SPEED = 800
local WEAPON_STATS = {
	name = "'Grace' Service Revolver",
	desc = "The ever powerful service revolver of the great Golden Empire.",
	icon = "17601078078",
	ammo_give = ".45 Lead",
	damage = 120,
	range = 30,
	range_damage = 105,
	far = 70,
	far_damage = 70,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 2,
	accuracy = 8,
	moving_accuracy = 50,
	fire_rate = 0.75,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 0.2,
	aim_speed = 0.125,
	recoil = 15,
	recoil_count = 6,
	movement = 0.5,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 2,
	ammo_reserves_max = 3,
	capacity = 6,
	chamber = false,
	reload_start = 1.1,
	reload_empty = 0,
	reload_loop = 0.4,
	reload_loop_after = 0.1,
	reload_end = 0.65,
	bullet_speed = BULLET_SPEED,
}

-- // Animation layers

local ANIM_LAYERS: { [string]: number } = {
	Hold     = 0,
	Aim      = 0,
	Aim_Left = 0,

	Fire            = 1,
	Fire_Left       = 1,
	Fire_Empty      = 1,
	Fire_Empty_Left = 1,
	Short           = 1,
	Short_Alt       = 1,
	Spin            = 1,
	Spin_Start      = 1,

	Draw         = 2,
	Unequip      = 2,
	Check        = 2,
	Melee1       = 2,
	Melee2       = 2,
	Reload_Start = 2,
	Reload_Loop  = 2,
	Reload_End   = 2,
}

-- // Class

local GraceRevolver = {}
GraceRevolver.__index = GraceRevolver
setmetatable(GraceRevolver, { __index = BasePistol })

export type GraceRevolver = typeof(setmetatable({} :: {
	className:   "GraceRevolver",
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
	MuzzlePartName:          string,

	Aiming:    boolean,
	Firing:    boolean,
	Reloading: boolean,
	Spinning:  boolean,
	Meleeing:  boolean,

	_reloadCancelled: boolean,
	_spinCancelled:   boolean,

	ANIM_LAYERS:      { [string]: number },
	current_shoulder: string,

	Caster:         any,
	CasterBehavior: any,

	motor_6d:       Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
}, {} :: typeof(GraceRevolver)))

-- // Constructor

function GraceRevolver.new(info: Types.BaseToolCreateInfo): GraceRevolver
	local self = setmetatable(BasePistol.new(info), GraceRevolver)

	self.className   = "GraceRevolver"
	self.item_image  = "rbxassetid://17601078078"
	self.Designation = "Secondary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.AnimationGunType = "saa"

	self.holster_reference = Holster_Folder and Holster_Folder:FindFirstChild("GraceRevolverHolster")
	self.model_reference   = Tool_Folder:FindFirstChild("GraceRevolver")
	self.Round             = Assets.Guns.Rounds.GraceRevolver_Round
	self.Round_Target_Part = "Left Arm"

	self.AnimationDrivenGrip = false
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0  = "Right Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("GraceRevolver_Middle"),
		C0 = CFrame.new(-0.258, -1.438, -0.506) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Hold    = Anim_Folder.GraceRevolver_Held,
		Draw    = Anim_Folder.GraceRevolver_Draw,
		Unequip = Anim_Folder.GraceRevolver_Unequip,

		Aim      = Anim_Folder.GraceRevolver_Aim,
		Aim_Left = Anim_Folder.GraceRevolver_Aim_left,

		Fire            = Anim_Folder.GraceRevolver_Fire,
		Fire_Left       = Anim_Folder.GraceRevolver_Fire_Left,
		Fire_Empty      = Anim_Folder.GraceRevolver_Fire_Empty,
		Fire_Empty_Left = Anim_Folder.GraceRevolver_Fire_Empty_Left,

		Short     = Anim_Folder.GraceRevolver_Short,
		Short_Alt = Anim_Folder.GraceRevolver_Short_alt,

		Spin       = Anim_Folder.GraceRevolver_Spin,
		Spin_Start = Anim_Folder.GraceRevolver_Spin_start,

		Reload_Start      = Anim_Folder.GraceRevolver_Reload_start,
		Reload_Loop       = Anim_Folder.GraceRevolver_Reload_loop,
		Reload_Loop_After = Anim_Folder.GraceRevolver_Reload_loop_after,
		Reload_End        = Anim_Folder.GraceRevolver_Reload_end,

		Check  = Anim_Folder.GraceRevolver_Check,
		Melee1 = Anim_Folder.GraceRevolver_Melee1,
		Melee2 = Anim_Folder.GraceRevolver_Melee2,

		Drop = Anim_Folder.Parent.Parent.Misc.Drop_Pistol,
	}

	self.animation_speeds = {
		Melee1            = 1.43,
		Melee2            = 1.43,
		Fire              = 1.33,
		Fire_Left         = 1.33,
		Draw              = 1 / WEAPON_STATS.draw_speed,
		Aim               = 1 / WEAPON_STATS.aim_speed,
		Aim_Left          = 1 / WEAPON_STATS.aim_speed,
		Reload_Start      = 1 / WEAPON_STATS.reload_start,
		Reload_Loop       = 1 / WEAPON_STATS.reload_loop,
		Reload_Loop_After = 1 / WEAPON_STATS.reload_loop_after,
		Reload_End        = 1 / WEAPON_STATS.reload_end,
	}

	self.damage                  = WEAPON_STATS.damage
	self.Max_Capacity            = WEAPON_STATS.capacity
	self.Capacity                = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo   = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo        = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type               = WEAPON_STATS.ammo_give
	self.recoil                  = WEAPON_STATS.recoil
	self.recoil_count            = WEAPON_STATS.recoil_count
	self.do_roll 				 = true
	self.Penetration_Level       = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force         = 8
	self.Aiming_Number           = 80
	self.Short_Distance          = 3.5
	self.MuzzlePartName          = "GraceRevolver_Muzzle"
	self.BulletSpeed             = BULLET_SPEED
	self.FireSound               = fire_sound
	self.AmmoCheckPartName       = "GraceRevolver_Middle"
	self.Can_Drop                = true
	self.Melee_Distance          = WEAPON_STATS.melee_range
	self.Melee_Damage            = WEAPON_STATS.melee_damage
	self.Accuracy                = WEAPON_STATS.accuracy
	self.Moving_Accuracy         = WEAPON_STATS.moving_accuracy

	self.SoundFolder             = SoundFolder
	self.FireInterval            = WEAPON_STATS.fire_rate

	self.unequip_wait     = false
	self.Aiming           = false
	self.Firing           = false
	self.Reloading        = false
	self.Spinning         = false
	self.Meleeing         = false
	self._reloadCancelled = false
	self._spinCancelled   = false

	self.FireEmissions = {
		flash = {
			chance = 0.5,
			count = 1,
		},

		flash_general = {
			chance = 0.5,
			count = 1,
		},

		smoke_flash_heavy = 1,

		smoke_medium = function()
			return math.random(2, 4)
		end,

		smoke_forward = function()
			return math.random(4, 6)
		end,

		smoke_linger_strong = 1,
	}
	
	self:_initShoulderTracking()
	self:applyFirearmConfig(WEAPON_STATS)
	self.FireSound = fire_sound
	self.SoundFolder = SoundFolder

	return self
end

function GraceRevolver:_damageAtDistance(distance: number): number
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
end

-- // Key bindings

function GraceRevolver:_getKeyBindings()
	local base = BasePistol._getKeyBindings(self)
	base.Spin = Enum.KeyCode.Q
	return base
end

function GraceRevolver:setAltMode()
	if not self.Equipped then return end
	task.spawn(function() self:spin() end)
end

-- // isBusy override (Spinning counts)

function GraceRevolver:_isBusy(): boolean
	return self.Firing or self.Reloading or self.Spinning or self.Meleeing or self.Checking
end

-- // Actions

function GraceRevolver:_cancelSpin()
	self._spinCancelled = true
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Spin       and anims.Spin.IsPlaying       then anims.Spin:Stop(0)       end
	if anims.Spin_Start and anims.Spin_Start.IsPlaying then anims.Spin_Start:Stop(0) end
end

function GraceRevolver:spin()
	if not self.Equipped or self:_isBusy() then return end
	self.Spinning       = true
	self._spinCancelled = false

	self:_playAnim("Spin_Start").Stopped:Wait()

	if self._spinCancelled then
		self.Spinning       = false
		self._spinCancelled = false
		self:_restoreBaseDeferred()
		return
	end

	self:_playAnim("Spin").Stopped:Wait()

	self.Spinning       = false
	self._spinCancelled = false
	self:_restoreBaseDeferred()
end

function GraceRevolver:fire()
	if self.Spinning then self:_cancelSpin() end

	local fireAnim  = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		distance = 1000,
		fireAnimation = fireAnim,
		sound = fire_sound,
		soundPitchVariation = self.Alt_Mode and 0.5 or nil,
		fireDelay = self.FireInterval,
	})
end

function GraceRevolver:reload()
	if self.Reloading or self.Capacity >= self.Max_Capacity or self.Equipping then return end

	if self.Spinning then self:_cancelSpin() end

	self.RegisteredAnimations["Reload_Start"]:AdjustWeight(1)
	self.RegisteredAnimations["Reload_Loop"]:AdjustWeight(1)
	self:_set_sprint_arms(true)
	self:_stopLayer(2)

	self.Reloading        = true
	self._reloadCancelled = false

	game.Players.LocalPlayer:SetAttribute("CantUnequip", true)
	self:_playAnim("Reload_Start").Stopped:Wait()
	self.Capacity = 0

	while self.Capacity < self.Max_Capacity and not self._reloadCancelled do
		self:_playAnim("Reload_Loop").Stopped:Wait()
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
		self:_playAnim("Reload_Loop_After").Stopped:Wait()
	end

	if not self._reloadCancelled then
		self:_playAnim("Reload_End").Stopped:Wait()

		-- Reset cylinder rotation
		local cylinder_motor: Motor6D =
			self.actual_model
			:FindFirstChild(self.className .. "_Middle")
			:FindFirstChild(self.className .. "_Cylinder")

		local pos = cylinder_motor.C0.Position
		cylinder_motor.C0 = CFrame.new(pos)
	else
		local anims = self.RegisteredAnimations
		if anims.Reload_Loop  and anims.Reload_Loop.IsPlaying  then anims.Reload_Loop:Stop(0)  end
		if anims.Reload_Start and anims.Reload_Start.IsPlaying then anims.Reload_Start:Stop(0) end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	self:_set_sprint_arms(false)
	game.Players.LocalPlayer:SetAttribute("CantUnequip", false)
end

function GraceRevolver:activate()
	if not self.actual_model then return end
	if self:_isBusy() or self.Firing then return end

	if self.Aiming then
		self:fire()
	else
		self:melee()
	end
end

-- // Lifecycle hooks

function GraceRevolver:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()

	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level, self:_damageAtDistance(distance), self.KnockBack_Force)
	end)
end

function GraceRevolver:_on_unequip()
	self._reloadCancelled = true
	self.Equipped         = false

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_cancelSpin()
	self:_stopLayer(2)
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	self.Firing    = false
	self.Reloading = false
	self.Spinning  = false

	local char = game.Players.LocalPlayer.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

-- // Cleanup

function GraceRevolver:Destroy()
	self:_disconnectInput()
	BasePistol.destroy(self)
end

GraceRevolver.Tool_Image = "rbxassetid://17601078078"
GraceRevolver.Medal_Cost = 1
GraceRevolver.Weight     = 1
GraceRevolver.Designation = "Secondary"
GraceRevolver.Display_Name = WEAPON_STATS.name
GraceRevolver.desc = WEAPON_STATS.desc
GraceRevolver.icon = WEAPON_STATS.icon
GraceRevolver.damage = WEAPON_STATS.damage
GraceRevolver.range = WEAPON_STATS.range
GraceRevolver.range_damage = WEAPON_STATS.range_damage
GraceRevolver.far = WEAPON_STATS.far
GraceRevolver.far_damage = WEAPON_STATS.far_damage
GraceRevolver.accuracy = WEAPON_STATS.accuracy
GraceRevolver.moving_accuracy = WEAPON_STATS.moving_accuracy
GraceRevolver.fire_rate = WEAPON_STATS.fire_rate
GraceRevolver.recoil = WEAPON_STATS.recoil
GraceRevolver.recoil_count = WEAPON_STATS.recoil_count
GraceRevolver.capacity = WEAPON_STATS.capacity
GraceRevolver.ammo_give = WEAPON_STATS.ammo_give
GraceRevolver.ammo_reserves = WEAPON_STATS.ammo_reserves
GraceRevolver.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
GraceRevolver.pen = WEAPON_STATS.pen

return GraceRevolver
