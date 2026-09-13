--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects

local crestfallAnimations = Assets.Animations.Tools.Guns:FindFirstChild("CrestfallRifle")
local crestfallSounds = GunAssets.Sounds:FindFirstChild("lever") or GunAssets.Sounds:FindFirstChild("CrestfallRifle")
local SoundFolder = crestfallSounds or GunAssets.Sounds.CrestfallRifle

local FIRE_INTERVAL = 60 / 86
local BULLET_SPEED = 900
local HIP_BRACE_SWITCH_TIME = 0.33
local RELOAD_ROUND_TIME = 9.56 / 11
local HIP_BRACE_CROSSHAIR_SPREAD = 20
local CUT = 0.06
local WEAPON_STATS = {
	name = "'Crestfall' Lever Rifle",
	desc = "Lethal and fast firing rifle, excelling at close to mid range duels.",
	icon = "18236623631",
	ammo_give = ".44 Army",
	damage = 120,
	range = 70,
	range_damage = 90,
	far = 100,
	far_damage = 75,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 2,
	accuracy = 8,
	moving_accuracy = 120,
	fire_rate = 0.7,
	cycle = 0,
	cycle_rest = 0,
	post_reload_delay = 0.15,
	draw_speed = 0.75,
	aim_speed = 0.275,
	recoil = 8,
	recoil_count = 6,
	movement = 1.5,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 1,
	ammo_reserves_max = 3,
	capacity = 11,
	chamber = false,
	reload_start = 0.75,
	reload_empty = 1.9,
	reload_loop = 0.8,
	reload_end = 0,
	bullet_speed = BULLET_SPEED,
}
local WALKING_FIRE_STATS = {
	accuracy = 35,
	moving_accuracy = 35,
	movement = 0.5,
	firing_movement = 0.5,
}
local CRESTFALL_HOLSTER_C0 = CFrame.new(0, 0, -0.65)
	* CFrame.Angles(0, 0, math.rad(90))

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Fire_Empty = 1,
	Fire_Empty_Left = 1,
	Fire_Last = 1,
	Fire_Last_Left = 1,
	Hip_Hold = 0,
	Hip_Aim = 0,
	Hip_Aim_Left = 0,
	Hip_Fire = 1,
	Hip_Fire_Left = 1,
	Hip_Fire_Empty = 1,
	Hip_Fire_Empty_Left = 1,
	Hip_Fire_Last = 1,
	Hip_Fire_Last_Left = 1,
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
}

local Crestfall = {}
Crestfall.__index = Crestfall
setmetatable(Crestfall, { __index = BaseRifle })

export type Crestfall = typeof(setmetatable({} :: any, Crestfall))

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("CrestfallRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "CrestfallRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "CrestfallRifle_Torso"
	holster.PrimaryPart = hitbox
	holster:SetAttribute("HolsterC0", CRESTFALL_HOLSTER_C0)
	for _, descendant in ipairs(holster:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant:SetAttribute("Hide_On_Equip", true)
		end
	end
	hitbox.Transparency = 1
	hitbox:SetAttribute("Hide_On_Equip", nil)
	holster.Parent = GunAssets.Holsters
	return holster
end

local function animation(name: string): Animation?
	local found = crestfallAnimations and crestfallAnimations:FindFirstChild(name)
	if found and found:IsA("Animation") then return found end
	return nil
end

function Crestfall.new(info: Types.BaseToolCreateInfo): Crestfall
	local self = setmetatable(BaseRifle.new(info), Crestfall)

	self.className = "CrestfallRifle"
	self.item_image = Crestfall.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("lever") or ToolFolder:FindFirstChild("Lever")
	self.holster_reference = get_holster_reference(self.model_reference)
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "lever"
	self.animations = {
		Draw = animation("draw"),
		Hold = animation("held"),

		Aim      = animation("aim"),
		Aim_Left = animation("aim_left"),

		Fire      = animation("fire"),
		Fire_Left = animation("fire_left"),

		Reload_Empty = animation("reload_empty"),
		Reload_Start = animation("reload_start"),
		Reload_Loop  = animation("reload_loop"),

		Check = animation("check"),

		Hip_Hold = animation("locked"),
		Hip_Aim = animation("alt_changeaim"),
		Hip_Aim_Left = animation("alt_changeaim_left"),
		Hip_Fire = animation("alt_changefire"),
		Hip_Fire_Left = animation("alt_changefire_left"),
		Hip_Fire_Empty = animation("alt_changefire_empty"),
		Hip_Fire_Empty_Left = animation("alt_changefire_empty_left"),
		Hip_Fire_Last = animation("alt_changefire_last"),
		Hip_Fire_Last_Left = animation("alt_changefire_last_left"),
		Reload_Empty_Vet_Old = animation("reload_empty_vet"),
	}

	self.animation_speeds = {
		Draw = 1 / WEAPON_STATS.draw_speed,
		Aim = 1 / WEAPON_STATS.aim_speed,
		Aim_Left = 1 / WEAPON_STATS.aim_speed,
		Reload_Loop = 1 / WEAPON_STATS.reload_loop,
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 10
	self.Aiming_Number = 75
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = WEAPON_STATS.bullet_speed
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = WEAPON_STATS.melee_range
	self.Melee_Damage = WEAPON_STATS.melee_damage
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.HipBraceAccuracy = WALKING_FIRE_STATS.accuracy
	self.SoundFolder = SoundFolder
	self.FireInterval = WEAPON_STATS.fire_rate

	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self.HipBraced = false
	self._reloadCancelled = false
	self.unequip_wait = false

	self.FireEmissions = {
		smoke_medium = function()
			return math.random(2, 4)
		end,
		smoke_forward = function()
			return math.random(4, 6)
		end,
	}

	self:_initShoulderTracking()
	self:applyFirearmConfig(WEAPON_STATS)
	return self
end

function Crestfall:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if not self.HipBraced then
		return BaseRifle.get_spread(self, muzzle, shootDirection)
	end

	local spread = self.HipBraceAccuracy
	local random = Random.new()
	local horizontal = random:NextNumber(-spread, spread) / 1000
	local vertical = random:NextNumber(-spread, spread) / 1000
	return (shootDirection + muzzle.CFrame.RightVector * horizontal + muzzle.CFrame.UpVector * vertical).Unit
end

function Crestfall:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeAim = humanoid.WalkSpeed end
	self.FixedAimingSpread = self.HipBraced and HIP_BRACE_CROSSHAIR_SPREAD or nil

	BaseRifle.aim(self)
	if humanoid and self.Aiming and not self.HipBraced then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim * 0.7
	end
end

function Crestfall:endAiming()
	BaseRifle.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeAim then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim
	end
	self._walkSpeedBeforeAim = nil
	self.FixedAimingSpread = nil
end

function Crestfall:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	task.wait(HIP_BRACE_SWITCH_TIME)
	if not self.Equipped then
		self.Alting = false
		return
	end
	self.HipBraced = not self.HipBraced
	if self.HipBraced then
		self.Accuracy = WALKING_FIRE_STATS.accuracy
		self.Moving_Accuracy = WALKING_FIRE_STATS.moving_accuracy
		self.movement = WALKING_FIRE_STATS.movement
		self.firing_movement = WALKING_FIRE_STATS.firing_movement
	else
		self.Accuracy = WEAPON_STATS.accuracy
		self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
		self.movement = WEAPON_STATS.movement
		self.firing_movement = WEAPON_STATS.firing_movement
	end
	self:_killAimTracks()
	local hipAim = self:_aimTrack()
	if self.HipBraced and self.Aiming and hipAim then hipAim:Play(CUT) end

	if self.Aiming then
		self.FixedAimingSpread = self.HipBraced and HIP_BRACE_CROSSHAIR_SPREAD or nil
		self:_enable_aiming_ui(self.Aiming_Number)

		local character = LOCAL_PLAYER.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and self._walkSpeedBeforeAim then
			humanoid.WalkSpeed = self.HipBraced
				and self._walkSpeedBeforeAim
				or self._walkSpeedBeforeAim * 0.7
		end
	end

	self:notify(self.HipBraced and "I am now hip bracing" or "I am now shoulder bracing")
	self.Alting = false
end

function Crestfall:_aimTrack(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Aim
			or self.RegisteredAnimations.Hip_Aim_Left
	end
	return BaseRifle._aimTrack(self)
end

function Crestfall:_killAimTracks()
	BaseRifle._killAimTracks(self)
	local anims = self.RegisteredAnimations
	if not anims then return end
	for _, name in ipairs({ "Hip_Aim", "Hip_Aim_Left" }) do
		local track = anims[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

-- Use the shared held pose outside ADS, including alternate firing modes.

function Crestfall:_getFireAnim(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Fire
			or self.RegisteredAnimations.Hip_Fire_Left
	end
	return BaseRifle._getFireAnim(self)
end

function Crestfall:_damageAtDistance(distance: number): number
	if distance < self.range then
		return self.damage
	elseif distance <= self.far then
		return self.range_damage
	end
	return self.far_damage
end

function Crestfall:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation
	local animations = self.RegisteredAnimations
	if self.HipBraced then
		if self.Capacity <= 1 and animations and (left and animations.Hip_Fire_Last_Left or animations.Hip_Fire_Last) then
			fireAnimation = left and "Hip_Fire_Last_Left" or "Hip_Fire_Last"
		else
			fireAnimation = left and animations and animations.Hip_Fire_Left and "Hip_Fire_Left" or "Hip_Fire"
		end
	else
		if self.Capacity <= 1 and animations and (left and animations.Fire_Last_Left or animations.Fire_Last) then
			fireAnimation = left and "Fire_Last_Left" or "Fire_Last"
		else
			fireAnimation = left and animations and animations.Fire_Left and "Fire_Left" or "Fire"
		end
	end
	local fireSound = self.SoundFolder and self.SoundFolder:FindFirstChild("fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = fireAnimation,
		sound = fireSound,
		fireDelay = self.FireInterval or WEAPON_STATS.fire_rate,
	})
	if not fired then return end

	self:_restoreBaseDeferred()
end

function Crestfall:reload()
	self:_reloadByRound({
		startAnim = "Reload_Start",
		loopAnim = "Reload_Loop",
		endAnim = "Reload_End",
	})
end

function Crestfall:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function Crestfall:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local damage = self:_damageAtDistance(distance)
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level, damage, self.KnockBack_Force)
	end)
end

function Crestfall:_on_unequip()
	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = true
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	local character = LOCAL_PLAYER.Character
	if character then
		character:SetAttribute("Aiming", false)
		character:SetAttribute("Sprint_Animation", nil)
	end
end

function Crestfall:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

Crestfall.Tool_Image = "rbxthumb://type=Asset&id=118811623120292&w=420&h=420"
Crestfall.Medal_Cost = 0
Crestfall.Weight = 2
Crestfall.Designation = "Primary"
Crestfall.Display_Name = WEAPON_STATS.name
Crestfall.desc = WEAPON_STATS.desc
Crestfall.icon = WEAPON_STATS.icon
Crestfall.damage = WEAPON_STATS.damage
Crestfall.range = WEAPON_STATS.range
Crestfall.range_damage = WEAPON_STATS.range_damage
Crestfall.far = WEAPON_STATS.far
Crestfall.far_damage = WEAPON_STATS.far_damage
Crestfall.accuracy = WEAPON_STATS.accuracy
Crestfall.moving_accuracy = WEAPON_STATS.moving_accuracy
Crestfall.fire_rate = WEAPON_STATS.fire_rate
Crestfall.recoil = WEAPON_STATS.recoil
Crestfall.recoil_count = WEAPON_STATS.recoil_count
Crestfall.capacity = WEAPON_STATS.capacity
Crestfall.ammo_give = WEAPON_STATS.ammo_give
Crestfall.ammo_reserves = WEAPON_STATS.ammo_reserves
Crestfall.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
Crestfall.pen = WEAPON_STATS.pen

return Crestfall
