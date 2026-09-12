-----------------------
--@Praxitos
--PrinceRifle
------------------------

--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types    = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)

local LOCAL_PLAYER = Players.LocalPlayer

-- // Assets

local Assets        = ReplicatedStorage.Shared.Assets
local SoundFolder   = Assets.Guns:WaitForChild("Sounds"):WaitForChild("PrinceRifle")
local HolsterFolder = Assets.Guns.Holsters
local ToolFolder    = Assets.Guns.ToolModels
local AnimFolder    = Assets.Animations.Tools.Guns.PrinceRifle
local FxFolder      = Assets.Guns.Effects

local fire_sound = SoundFolder.fire

-- // Tuning

local CYCLE_REST_TIME = 0.25
local FIRE_RATE       = 0.3
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

local FIREARM_CONFIG = {
	className = "PrinceRifle",
	name = "'Prince' Long Rifle",
	desc = "An infantry rifle with good stopping power and range.",
	size = 2,
	icon = "17496049645",
	animations = "lebel",
	ammo_give = "8mm Smokeless",
	melee_sound = "rifle",
	tooltype = "gun",
	damage = 150,
	range = 100,
	range_damage = 120,
	far = 150,
	far_damage = 105,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	wallpen_distance = 50,
	wallpen_studs = 3,
	accuracy = 6,
	moving_accuracy = 100,
	fire_rate = FIRE_RATE,
	cycle = 0.55,
	cycle_rest = 0.15,
	draw_speed = 0.75,
	aim_speed = 0.35,
	wound = 1,
	length = 4,
	recoil = 10,
	recoil_count = 6,
	movement = 1,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 1,
	ammo_reserves_max = 3,
	capacity = 7,
	chamber = true,
	reload_start = 1.6,
	reload_empty = 1.45,
	reload_loop = 0.65,
	reload_end = 1.45,
	reload_alt = 1.4,
	bullet_speed = BULLET_SPEED,
	AnimationGunType = "lebel",
	item_image = "rbxassetid://17496049645",
	Designation = "Primary",
	ANIM_LAYERS = ANIM_LAYERS,

	holster_reference = HolsterFolder and HolsterFolder:FindFirstChild("PrinceRifleHolster"),
	model_reference = ToolFolder:FindFirstChild("PrinceRifle"),
	Round = Assets.Guns.Rounds.PrinceRifle_Round,
	RoundMotor_6d_Data = {
		C0 = CFrame.new(-0.1, 0, 0) * CFrame.Angles(0, 0, 0),
	},

	AnimationDrivenGrip = false,

	animations = {
		Draw = AnimFolder.PrinceRifle_Draw,
		Hold = AnimFolder.PrinceRifle_Held,
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
	},

	animation_speeds = {
		Cycle        = 1.818182,
		Draw         = 1.333333,
		Aim          = 2.857143,
		Aim_Left     = 2.857143,
		Reload_Start = 0.625,
		Reload_Empty = 0.689655,
		Reload_Loop  = 1.538462,
		Reload_End   = 0.689655,
		Reload_Alt   = 0.714286,
		Melee1       = 1.428571,
		Melee2       = 1.428571,
	},

	damage = 150,
	Max_Capacity = 7,
	Capacity = 7,
	Ammo_Type = "8mm Smokeless",
	recoil = 10,
	recoil_count = 6,
	Penetration_Level = 3,
	Armor_Penetration_Level = 3,
	KnockBack_Force = 10,
	Aiming_Number = 100,
	Check_Delay = 1,
	MuzzlePartName = "PrinceRifle_Muzzle",
	FireSound = fire_sound,
	Can_Drop = true,
	SoundFolder = SoundFolder,
	Short_Distance = 3.5,
	Melee_Distance = 5,
	Melee_Damage = 80,
	Accuracy = 6,
	Moving_Accuracy = 100,
	CycleDelay = FIRE_RATE + CYCLE_REST_TIME,
	CycleAnimation = "Cycle",

	unequip_wait = false,
	Cycled = true,
	Firing = false,
	Cycling = false,
	Reloading = false,
	Alt_Mode = true,
	Alting = false,
	_reloadCancelled = false,
	_ToCancelReload = false,
	Checking = false,
	Check_Delayed = false,
	Meleeing = false,
	CompassRight = true,

	FireEmissions = {
		smoke_medium = function()
			return math.random(2, 4)
		end,

		smoke_forward = function()
			return math.random(4, 6)
		end,
	},
}

-- // Class

local PrinceRifle = {}
PrinceRifle.__index = PrinceRifle
setmetatable(PrinceRifle, { __index = BaseRifle })

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
	local self = setmetatable(BaseRifle.new(info), PrinceRifle)

	self:applyFirearmConfig(FIREARM_CONFIG)
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0  = "Left Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("PrinceRifle_Middle"),
		C0     = CFrame.new(0.254, -1.703, -0.566) * CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90)),
	}

	self:_initShoulderTracking()

	return self
end

-- // Actions
function PrinceRifle:setAltMode()
	print("PrinceRifle:setAltMode() called")
	if self:_isBusy() then print("Busy, cannot change alt mode") return end
	self.Alting = true
	self:_stopAllExcept()
	local shouldCycle = false

	if self.Alt_Mode then
		self:_playAnim("Alt_Mode_Off").Stopped:Wait()
		self.Alt_Mode = false
		-- Single Fire uses a separately hand-loaded round, never the internal
		-- magazine. Require the player to load that first round with R.
		self.Cycled = false
		self:notify("Firemode: Single Fire")
		print("Firemode: Single Fire")
	else
		self:_playAnim("Alt_Mode_On").Stopped:Wait()
		self.Alt_Mode = true
		self:notify("Firemode: Repeating Fire")
		shouldCycle = not self.Cycled
		print("Firemode: Repeating Fire")
	end

	self.Alting = false
	self:_restoreBase()
	if shouldCycle then self:_cycleAction() end
	print("Alt mode set to:", self.Alt_Mode)
end

function PrinceRifle:_cycleAction()
	self:_playCycle()
end

function PrinceRifle:_damageAtDistance(distance: number): number
	return BaseRifle._damageAtDistance(self, distance)
end

function PrinceRifle:fire()
	if self.Checking then return end
	if self.CantFire then return end

	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		consumeCapacity = self.Alt_Mode,
		sound = fire_sound,
		soundPitchVariation = self.Alt_Mode and 0.5 or nil,
	})
	if not fired then return end

	self.Cycled = false
	if self.Alt_Mode then self:_cycleAction() end

	self.CantFire = true
	task.delay(CYCLE_REST_TIME, function()
		self.CantFire = false
	end)
end

-- Prince selects its legacy clips explicitly in its own action methods.
function PrinceRifle:_magazineAnimation(name: string): string
	return name
end

function PrinceRifle:_autoCycle()
	if self.Cycling then return end

	self:_withUnequipLock(function()
		self.Cycling = true
		self.Cycled  = false

		if not self.RegisteredAnimations then
			self.Cycling = false
			return
		end

		self:_stopAllExcept()
		local reloadTrack = self:_playAnim("Reload_Alt")
		if reloadTrack then reloadTrack.Stopped:Wait() end

		if self:_hasReserveAmmo() then
			-- The hand-loaded round is paid for directly from reserve ammo. It is
			-- deliberately not added to Capacity, which belongs to Repeating Fire.
			self:_fire_ammo(1)
			self.Cycled = true
		end

		self.Cycling = false
		self:_restoreBase()
	end)
end

function PrinceRifle:reload()
	if not self.Equipped then return end
	if self.Reloading or self.Equipping then return end
	if self.Alt_Mode and self.Capacity >= self.Max_Capacity then return end
	if not self.Alt_Mode and self.Cycled then return end
	if not self:_hasReserveAmmo() then
		self.Cycling = false
		self:_restoreBase()
		return
	end

	if self.Alt_Mode then
		self._ToCancelReload = false
		self:_reloadByRound({
			startAnim = "Reload_Start",
			loopAnim = "Reload_Loop",
			endAnim = "Reload_End",
			stopAfterLoop = function(controller)
				if controller._ToCancelReload then
					controller.Capacity += 1
					return true
				end
				return false
			end,
		})
	else
		self:_autoCycle()
	end
end

function PrinceRifle:activate()
	if self.Reloading then
		self._ToCancelReload = true
		return
	end

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

	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level,
			self:_damageAtDistance(distance), self.KnockBack_Force)
	end)
end

function PrinceRifle:_on_unequip()
	self.Equipped         = false
	self._reloadCancelled = true

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	-- Re-equipping in Single Fire must not grant an unaccounted free round.
	self.Cycled    = self.Alt_Mode
	self.Firing    = false
	self.Cycling   = false
	self.Reloading = false
	self.Alting    = false

	local char = LOCAL_PLAYER.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

-- // Cleanup
PrinceRifle.Tool_Image = "rbxassetid://17496049645"
PrinceRifle.Medal_Cost = 0
PrinceRifle.Weight     = 2
PrinceRifle.Designation = "Primary"
PrinceRifle.Display_Name = FIREARM_CONFIG.name
PrinceRifle.desc = FIREARM_CONFIG.desc
PrinceRifle.icon = FIREARM_CONFIG.icon
PrinceRifle.damage = FIREARM_CONFIG.damage
PrinceRifle.range = FIREARM_CONFIG.range
PrinceRifle.range_damage = FIREARM_CONFIG.range_damage
PrinceRifle.far = FIREARM_CONFIG.far
PrinceRifle.far_damage = FIREARM_CONFIG.far_damage
PrinceRifle.accuracy = FIREARM_CONFIG.accuracy
PrinceRifle.moving_accuracy = FIREARM_CONFIG.moving_accuracy
PrinceRifle.fire_rate = FIREARM_CONFIG.fire_rate
PrinceRifle.cycle = FIREARM_CONFIG.cycle
PrinceRifle.cycle_rest = FIREARM_CONFIG.cycle_rest
PrinceRifle.recoil = FIREARM_CONFIG.recoil
PrinceRifle.recoil_count = FIREARM_CONFIG.recoil_count
PrinceRifle.capacity = FIREARM_CONFIG.capacity
PrinceRifle.ammo_give = FIREARM_CONFIG.ammo_give
PrinceRifle.ammo_reserves = FIREARM_CONFIG.ammo_reserves
PrinceRifle.ammo_reserves_max = FIREARM_CONFIG.ammo_reserves_max
PrinceRifle.pen = FIREARM_CONFIG.pen

return PrinceRifle
