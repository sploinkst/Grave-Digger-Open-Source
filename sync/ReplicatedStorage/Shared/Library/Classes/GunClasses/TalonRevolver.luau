-----------------------
--@Praxitos
--TalonRevolver
------------------------

--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types    = require(script.Parent.Parent.Parent.Types)
local BasePistol = require(script.Parent.Parent.BasePistol)

-- // Assets

local Assets         = ReplicatedStorage.Shared.Assets
local Holster_Folder = Assets.Guns.Holsters
local Tool_Folder    = Assets.Guns.ToolModels
local Guns_Anim_Folder = Assets.Animations.Tools.Guns
local Anim_Folder    = Guns_Anim_Folder:FindFirstChild("TalonRevolver")
local Grace_Anim_Folder = Guns_Anim_Folder:FindFirstChild("GraceRevolver")
local FxFolder       = Assets.Guns.Effects

local SoundFolder = Assets.Guns:WaitForChild("Sounds"):FindFirstChild("TalonRevolver")
	or Assets.Guns:WaitForChild("Sounds"):WaitForChild("GraceRevolver")
local fire_sound  = SoundFolder.fire

-- // Tuning

local FIRE_RATE    = 0.75
local BLACK_HAND_FIRE_RATE = 60 / 92
local FAN_FIRE_RATE = 60 / 170
local BULLET_SPEED = 800
local QUICKDRAW_READY_TIME = 0.75
local QUICKDRAW_HOLD_SPEED = 0.5
local WEAPON_STATS = {
    name = "'Talon' Army Revolver",
    desc = "A swift revolver with a bite and capable of firing from the hip.",
    lore = "A venerable and well-worn design originating in the Royal Nation's territory, this iconic pistol stands the test of time and serves as a symbol of patriotism and pride within the Royal Nation's ideology - ideals that are similarly represented by the symbol of soaring Eagles, hence the moniker.\n\nUnlike most other weapons, the 'Talon' is mostly produced domestically by the Nation rather than the Solace Coalition, a symbol of defiance against the fanatics - though, the irony of using such a symbol against the Nation's own soldiers is not lost on the Empire.\n\nPerhaps most famously wielded by King Helfort in an Empire Shock Trooper assassination attempt, six shots of .45 Flat proved adequate to put down each and every assailant with zero casualties on the Nation's part, further cementing the pistol's reputation of reliability under mud, muck and grime.",
    size = 1,
    icon = "18771441971",
    animations = "saa",
    ammo_give = ".45 Flat",
    melee_sound = "pistol",
    assists = {
        "Fan fire by firing from the hip, in-accurate, but deadly.",
        "Exceptional performance while firing on the move.",
        "Lacks precision compared to other weapons.",
        "[@ALT] to ready yourself for a Quick-draw.",
        "Quick-draw shots are perfectly accurate no matter what."
    },
    tooltype = "gun",
    damage = 105,
    range = 35,
    range_damage = 90,
    far = 60,
    far_damage = 70,
    melee_damage = 80,
    melee_swing_speed = 0.7,
    melee_range = 5,
    pen = 2,
    wallpen_distance = 50,
    wallpen_studs = 3,
    accuracy = 18,
    moving_accuracy = 38,
    fire_rate = 0.7,
    black_hand_fire_rate = BLACK_HAND_FIRE_RATE,
    fan_fire_rate = FAN_FIRE_RATE,
    cycle = 0,
    cycle_rest = 0,
    draw_speed = 0.05,
    aim_speed = 0.125,
    wound = 1,
    length = 3.5,
    recoil = 15,
    recoil_count = 6,
    movement = 0.5,
    firing_movement = 1,
    firing_movement_last = 0.5,
    ammo_reserves = 2,
    ammo_reserves_max = 3,
    capacity = 6,
    chamber = false,
    reload_start = 0.8,
    reload_empty = 0,
    reload_loop = 1.1,
    reload_loop_after = 0.1,
    reload_end = 0.6,
    reload_cancel_index_time = 0.3,
    reload_index_two_time = 0.25,
    quickdraw_ready_time = QUICKDRAW_READY_TIME,
    quickdraw_hold_speed = QUICKDRAW_HOLD_SPEED,
    bullet_speed = BULLET_SPEED,
    holster_point = "Torso",
    holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
    holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
    alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    lefthand = false,
    equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
    equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    special = {},
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
	Hip_Fire        = 1,
	Hip_Fire_Empty  = 1,
	Quickdraw_Fire  = 1,
	Short           = 1,
	Short_Alt       = 1,
	Spin            = 1,
	Spin_Start      = 1,
	Quickdraw       = 1,
	Quickdraw_Start = 1,

	Draw         = 2,
	Check        = 2,
	Reload_Start = 2,
	Reload_Start_Vet = 2,
	Reload_Loop  = 2,
	Reload_Loop_After = 2,
	Reload_Loop_After_Twice = 2,
	Reload_End   = 2,
}

local function animation(name: string, graceName: string?): Animation?
	local candidate = Anim_Folder and Anim_Folder:FindFirstChild(name)
	if candidate and candidate:IsA("Animation") then
		return candidate
	end

	local fallback = Grace_Anim_Folder and Grace_Anim_Folder:FindFirstChild(graceName or name)
	if fallback and fallback:IsA("Animation") then
		return fallback
	end

	return nil
end

local function firstChild(parent: Instance?, names: { string }): Instance?
	if not parent then return nil end
	for _, name in names do
		local found = parent:FindFirstChild(name)
		if found then return found end
	end
	for _, name in names do
		local found = parent:FindFirstChild(name, true)
		if found then return found end
	end
	return nil
end

-- // Class

local TalonRevolver = {}
TalonRevolver.__index = TalonRevolver
setmetatable(TalonRevolver, { __index = BasePistol })

export type TalonRevolver = typeof(setmetatable({} :: {
	className:   "TalonRevolver",
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
}, {} :: typeof(TalonRevolver)))

-- // Constructor

function TalonRevolver.new(info: Types.BaseToolCreateInfo): TalonRevolver
	local self = setmetatable(BasePistol.new(info), TalonRevolver)

	self.className   = "TalonRevolver"
	self.item_image  = "rbxassetid://17601078078"
	self.Designation = "Secondary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.AnimationGunType = "saa"

	self.holster_reference = firstChild(Holster_Folder, {
		"TalonRevolverHolster",
		"saaHolster",
		"GraceRevolverHolster",
		"schoHolster",
	})
	self.model_reference = firstChild(Tool_Folder, {
		"TalonRevolver",
		"saa",
		"GraceRevolver",
		"scho",
	})
	self.Round = firstChild(Assets.Guns.Rounds, {
		"TalonRevolver_Round",
		"saa_Round",
		"GraceRevolver_Round",
		"scho_Round",
	})
	self.Round_Target_Part = "Left Arm"
	local modelPartPrefix = if self.model_reference and self.model_reference:FindFirstChild("TalonRevolver_Middle", true)
		then "TalonRevolver"
		elseif self.model_reference and self.model_reference:FindFirstChild("GraceRevolver_Middle", true)
		then "GraceRevolver"
		else nil

	self.AnimationDrivenGrip = false
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0  = "Right Arm",
		Part1  = self.model_reference and firstChild(self.model_reference, {
			"TalonRevolver_Middle",
			"GraceRevolver_Middle",
			"hitbox",
		}),
		C0 = CFrame.new(-0.258, -1.438, -0.506) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Hold    = animation("hipfire", "GraceRevolver_Held"),
		Draw    = animation("ocelot_draw_spin", "GraceRevolver_Draw"),

		Aim      = animation("hipfire", "GraceRevolver_Aim"),
		Aim_Left = animation("akimbo_fire", "GraceRevolver_Aim_left"),

		Fire            = animation("stock_fire", "GraceRevolver_Fire"),
		Fire_Left       = animation("stock_fire_left", "GraceRevolver_Fire_Left"),
		Fire_Empty      = animation("stock_fire_empty", "GraceRevolver_Fire_Empty"),
		Fire_Empty_Left = animation("stock_fire_empty_left", "GraceRevolver_Fire_Empty_Left"),
		Hip_Fire        = animation("fire"),
		Hip_Fire_Empty  = animation("fire_empty"),
		Quickdraw_Fire  = animation("quickdraw"),

		Short     = animation("fire", "GraceRevolver_Short"),
		Short_Alt = animation("akimbo_fire", "GraceRevolver_Short_alt"),

		Spin       = animation("akimbo_saa_spins", "GraceRevolver_Spin"),
		Spin_Start = animation("quickdraw_start", "GraceRevolver_Spin_start"),
		Quickdraw       = animation("quickdraw"),
		Quickdraw_Start = animation("quickdraw_start"),

		Reload_Start      = animation("reload_start", "GraceRevolver_Reload_start"),
		Reload_Start_Vet  = animation("reload_start_vet") or animation("reload_start", "GraceRevolver_Reload_start"),
		Reload_Loop       = animation("reload_loop", "GraceRevolver_Reload_loop"),
		Reload_Loop_After = animation("reload_loop_after", "GraceRevolver_Reload_loop_after"),
		Reload_Loop_After_Twice = animation("reload_loop_after_twic") or animation("reload_loop_after_twice") or animation("reload_loop_after", "GraceRevolver_Reload_loop_after"),
		Reload_End        = animation("reload_end", "GraceRevolver_Reload_end"),

		Check  = animation("check", "GraceRevolver_Check"),

		Drop = Assets.Animations.Tools.Misc.Drop_Pistol,
	}

	self.animation_speeds = {
		Melee1            = 1.43,
		Melee2            = 1.43,
		Fire              = 1.33,
		Fire_Left         = 1.33,
		Hip_Fire          = 1 / FAN_FIRE_RATE,
		Hip_Fire_Empty    = 1 / FAN_FIRE_RATE,
		Draw              = 1 / WEAPON_STATS.draw_speed,
		Aim               = 1 / WEAPON_STATS.aim_speed,
		Aim_Left          = 1 / WEAPON_STATS.aim_speed,
		Reload_Start      = 1 / WEAPON_STATS.reload_start,
		Reload_Start_Vet  = 1 / WEAPON_STATS.reload_start,
		Reload_Loop       = 1 / WEAPON_STATS.reload_loop,
		Reload_Loop_After = 1 / WEAPON_STATS.reload_loop_after,
		Reload_Loop_After_Twice = 1 / WEAPON_STATS.reload_index_two_time,
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
	self.MuzzlePartName          = modelPartPrefix and (modelPartPrefix .. "_Muzzle") or "muzzle"
	self.BulletSpeed             = BULLET_SPEED
	self.FireSound               = fire_sound
	self.AmmoCheckPartName       = modelPartPrefix and (modelPartPrefix .. "_Middle") or "hitbox"
	self.Can_Drop                = true
	self.Melee_Distance          = WEAPON_STATS.melee_range
	self.Melee_Damage            = WEAPON_STATS.melee_damage
	self.Accuracy                = WEAPON_STATS.accuracy
	self.Moving_Accuracy         = WEAPON_STATS.moving_accuracy

	self.SoundFolder             = SoundFolder
	self.FireInterval            = WEAPON_STATS.fire_rate
	local localPlayer = RunService:IsClient() and Players.LocalPlayer or nil
	local character = localPlayer and localPlayer.Character
	if character and character:FindFirstChild("perk") and character.perk.Value == "blackhand" then
		self.FireInterval = WEAPON_STATS.black_hand_fire_rate
	end

	self.unequip_wait     = false
	self.Aiming           = false
	self.Firing           = false
	self.Reloading        = false
	self.Spinning         = false
	self.Meleeing         = false
	self._reloadCancelled = false
	self._spinCancelled   = false
	self.Quickdrawing     = false
	self._quickdrawReady  = false
	self._quickdrawCancelled = false
	self._cylinderIndexOffset = 0

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

function TalonRevolver:_damageAtDistance(distance: number): number
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
end

-- // Key bindings

function TalonRevolver:_getKeyBindings()
	local base = BasePistol._getKeyBindings(self)
	base.Spin = Enum.KeyCode.Q
	return base
end

function TalonRevolver:setAltMode()
	if not self.Equipped then return end
	task.spawn(function() self:quickdraw() end)
end

-- // isBusy override (Spinning counts)

function TalonRevolver:_isBusy(): boolean
	return self.Firing or self.Reloading or self.Spinning or self.Meleeing or self.Checking or self.Quickdrawing
end

-- // Actions

function TalonRevolver:_cancelSpin()
	self._spinCancelled = true
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Spin       and anims.Spin.IsPlaying       then anims.Spin:Stop(0)       end
	if anims.Spin_Start and anims.Spin_Start.IsPlaying then anims.Spin_Start:Stop(0) end
end

function TalonRevolver:_cancelQuickdraw()
	self._quickdrawCancelled = true
	local anims = self.RegisteredAnimations
	if not anims then return end
	for _, name in ipairs({ "Quickdraw", "Quickdraw_Start" }) do
		local track = anims[name]
		if track and track.IsPlaying then track:Stop(0.2) end
	end
end

function TalonRevolver:quickdraw()
	if not self.Equipped or self:_isBusy() or self.Capacity <= 0 then return end
	self.Quickdrawing = true
	self._quickdrawReady = false
	self._quickdrawCancelled = false
	self:_stopAllExcept()

	local startTrack = self:_playAnim("Quickdraw_Start")
	if startTrack then
		task.wait(self.quickdraw_ready_time or WEAPON_STATS.quickdraw_ready_time)
	end
	if not self.Equipped or self._quickdrawCancelled then
		self.Quickdrawing = false
		self._quickdrawReady = false
		self._quickdrawCancelled = false
		self:_restoreBaseDeferred()
		return
	end

	local holdTrack = self:_playAnim("Quickdraw")
	if holdTrack then
		holdTrack:AdjustSpeed(self.quickdraw_hold_speed or WEAPON_STATS.quickdraw_hold_speed)
	end
	self._quickdrawReady = true
	while self.Equipped and self._quickdrawReady and not self._quickdrawCancelled do
		task.wait()
	end

	self.Quickdrawing = false
	self._quickdrawReady = false
	self._quickdrawCancelled = false
	self:_restoreBaseDeferred()
end

function TalonRevolver:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if self._quickdrawShot then return shootDirection end
	if self._fanFiring then
		local spread = 75
		local random = Random.new()
		local horizontal = random:NextNumber(-spread, spread) / 1000
		local vertical = random:NextNumber(-spread, spread) / 1000
		return (shootDirection + muzzle.CFrame.RightVector * horizontal + muzzle.CFrame.UpVector * vertical).Unit
	end
	return BasePistol.get_spread(self, muzzle, shootDirection)
end

function TalonRevolver:spin()
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

function TalonRevolver:fire()
	if self.Spinning then self:_cancelSpin() end
	if self.Quickdrawing then self:_cancelQuickdraw() end

	local quickdrawShot = self._quickdrawReady == true
	local fanFiring = quickdrawShot or not self.Aiming
	local left = self.current_shoulder ~= "Right"
	local fireAnim
	if fanFiring then
		fireAnim = self.Capacity <= 1 and "Hip_Fire_Empty" or "Hip_Fire"
		if quickdrawShot and self.RegisteredAnimations and self.RegisteredAnimations.Quickdraw_Fire then
			fireAnim = "Quickdraw_Fire"
		end
	else
		fireAnim = if self.Capacity <= 1
			then (left and "Fire_Empty_Left" or "Fire_Empty")
			else (left and "Fire_Left" or "Fire")
	end

	self._fanFiring = fanFiring
	self._quickdrawShot = quickdrawShot
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		distance = 1000,
		fireAnimation = fireAnim,
		sound = fire_sound,
		soundPitchVariation = fanFiring and 0.5 or nil,
		fireDelay = if fanFiring then (self.fan_fire_rate or WEAPON_STATS.fan_fire_rate) else self.FireInterval,
		requireAiming = not fanFiring,
	})
	self._fanFiring = false
	self._quickdrawShot = false
	if fired and quickdrawShot then
		self:_blockFireFor(self.fan_fire_rate or WEAPON_STATS.fan_fire_rate)
	end
end

function TalonRevolver:reload()
	if self.Reloading or self.Capacity >= self.Max_Capacity or self.Equipping then return end

	if self.Spinning then self:_cancelSpin() end

	local anims = self.RegisteredAnimations
	if not anims then return end
	if self.Quickdrawing then self:_cancelQuickdraw() end

	if anims.Reload_Start then anims.Reload_Start:AdjustWeight(1) end
	if anims.Reload_Loop then anims.Reload_Loop:AdjustWeight(1) end
	self:_set_sprint_arms(true)
	self:_stopLayer(2)

	self.Reloading        = true
	self._reloadCancelled = false

	game.Players.LocalPlayer:SetAttribute("CantUnequip", true)
	local character = game.Players.LocalPlayer.Character
	local startName = if character and character:FindFirstChild("perk") and character.perk.Value == "vet" and anims.Reload_Start_Vet
		then "Reload_Start_Vet"
		else "Reload_Start"
	local startTrack = self:_playAnim(startName)
	if startTrack then startTrack.Stopped:Wait() end
	self.Capacity = 0

	while self.Capacity < self.Max_Capacity and not self._reloadCancelled do
		local loopTrack = self:_playAnim("Reload_Loop")
		if loopTrack then loopTrack.Stopped:Wait() end
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
		self._cylinderIndexOffset = (self._cylinderIndexOffset + 1) % self.Max_Capacity
		if self.Capacity < self.Max_Capacity then
			local afterTrack = self:_playAnim("Reload_Loop_After")
			if afterTrack then afterTrack.Stopped:Wait() end
		end
	end

	if not self._reloadCancelled then
		self:_playAnim("Reload_End").Stopped:Wait()

		-- Reset cylinder rotation
		local middle = self.actual_model
			and (
				self.actual_model:FindFirstChild("TalonRevolver_Middle", true)
				or self.actual_model:FindFirstChild("GraceRevolver_Middle", true)
			)
		local cylinder_motor = middle
			and (
				middle:FindFirstChild("TalonRevolver_Cylinder")
				or middle:FindFirstChild("GraceRevolver_Cylinder")
			)

		if cylinder_motor and cylinder_motor:IsA("Motor6D") then
			local pos = cylinder_motor.C0.Position
			cylinder_motor.C0 = CFrame.new(pos)
		end
	else
		if anims.Reload_Loop  and anims.Reload_Loop.IsPlaying  then anims.Reload_Loop:Stop(0)  end
		if anims.Reload_Start and anims.Reload_Start.IsPlaying then anims.Reload_Start:Stop(0) end
		local missingIndexes = math.max(0, self.Max_Capacity - self.Capacity)
		while missingIndexes >= 2 do
			local indexTrack = self:_playAnim("Reload_Loop_After_Twice")
			if indexTrack then indexTrack.Stopped:Wait() else task.wait(self.reload_index_two_time or WEAPON_STATS.reload_index_two_time) end
			missingIndexes -= 2
		end
		if missingIndexes == 1 then
			local indexTrack = self:_playAnim("Reload_Loop_After")
			if indexTrack then indexTrack.Stopped:Wait() else task.wait(self.reload_cancel_index_time or WEAPON_STATS.reload_cancel_index_time) end
		end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	self:_set_sprint_arms(false)
	game.Players.LocalPlayer:SetAttribute("CantUnequip", false)
	self:_blockFireFor(self.PostReloadDelay or 0)
end

function TalonRevolver:activate()
	if not self.actual_model then return end
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if (self:_isBusy() and not self.Quickdrawing) or self.Firing then return end

	self:fire()
end

-- // Lifecycle hooks

function TalonRevolver:_on_equip()
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

function TalonRevolver:_on_unequip()
	self._reloadCancelled = true
	self.Equipped         = false

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_cancelSpin()
	self:_cancelQuickdraw()
	self:_stopLayer(2)
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	self.Firing    = false
	self.Reloading = false
	self.Spinning  = false
	self.Quickdrawing = false

	local char = game.Players.LocalPlayer.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

-- // Cleanup

function TalonRevolver:Destroy()
	self:_disconnectInput()
	BasePistol.destroy(self)
end

TalonRevolver.Tool_Image = "rbxassetid://17601078078"
TalonRevolver.Medal_Cost = 1
TalonRevolver.Weight     = 1
TalonRevolver.Designation = "Secondary"
TalonRevolver.Display_Name = WEAPON_STATS.name
TalonRevolver.desc = WEAPON_STATS.desc
TalonRevolver.icon = WEAPON_STATS.icon
TalonRevolver.damage = WEAPON_STATS.damage
TalonRevolver.range = WEAPON_STATS.range
TalonRevolver.range_damage = WEAPON_STATS.range_damage
TalonRevolver.far = WEAPON_STATS.far
TalonRevolver.far_damage = WEAPON_STATS.far_damage
TalonRevolver.accuracy = WEAPON_STATS.accuracy
TalonRevolver.moving_accuracy = WEAPON_STATS.moving_accuracy
TalonRevolver.fire_rate = WEAPON_STATS.fire_rate
TalonRevolver.recoil = WEAPON_STATS.recoil
TalonRevolver.recoil_count = WEAPON_STATS.recoil_count
TalonRevolver.capacity = WEAPON_STATS.capacity
TalonRevolver.ammo_give = WEAPON_STATS.ammo_give
TalonRevolver.ammo_reserves = WEAPON_STATS.ammo_reserves
TalonRevolver.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
TalonRevolver.pen = WEAPON_STATS.pen

return TalonRevolver
