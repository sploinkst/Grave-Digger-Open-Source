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

local stormAnimations = Assets.Animations.Tools.Guns:FindFirstChild("mpgun")
	or Assets.Animations.Tools.Guns:FindFirstChild("StormRifle")
local stormSounds = GunAssets.Sounds:FindFirstChild("mpgun") or GunAssets.Sounds:FindFirstChild("StormRifle")
local SoundFolder = stormSounds or GunAssets.Sounds.mpgun

local FIRE_INTERVAL = 0.12
local BULLET_SPEED = 800
local STORM_HOLSTER_C0 = CFrame.new(0.428756714, -0.00153756142, 0.563869476, 0.487990797, -0.662724197, 0.568031669, 0.872847557, 0.370578408, -0.317500949, -0.0000846743642, 0.650742352, 0.759297907)

local WEAPON_STATS = {
	name = "'Breath of God'",
	desc = "",
	lore = "",
	size = 1,
	icon = "79235124191407",
	animations = "mpgun",
	ammo_give = "9mm Auto",
	melee_sound = "rifle",
	blacklist = true,
	alt_name = "'The Reaper'",
	assists = {},
	auto = true,
	tooltype = "gun",
	damage = 85,
	range = 35,
	range_damage = 70,
	far = 55,
	far_damage = 60,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 1,
	wallpen_distance = 30,
	wallpen_studs = 2,
	accuracy = 8,
	moving_accuracy = 15,
	fire_rate = FIRE_INTERVAL,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 1,
	aim_speed = 0.25,
	wound = 1,
	length = 4,
	recoil = 2,
	recoil_count = 2,
	movement = 1,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 200,
	ammo_reserves_max = 200,
	capacity = 32,
	chamber = false,
	reload_start = 3,
	reload_empty = 0.75,
	reload_loop = 0,
	reload_loop_after = 0,
	reload_end = 0,
	post_reload_delay = 0.15,
	bullet_speed = BULLET_SPEED,
	knockback = 6,
	aiming_number = 80,
}

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Draw = 2,
	Reload_Empty = 2,
	Reload_Start = 2,
	Check = 2,
	Short = 2,
}

local Crestfall = {}
Crestfall.__index = Crestfall
setmetatable(Crestfall, { __index = BaseRifle })

export type Crestfall = typeof(setmetatable({} :: any, Crestfall))

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("mpgunHolster")
		or GunAssets.Holsters:FindFirstChild("StormRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "StormRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "StormRifle_Torso"
	holster.PrimaryPart = hitbox
	holster:SetAttribute("HolsterC0", STORM_HOLSTER_C0)
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
	local found = stormAnimations and stormAnimations:FindFirstChild(name)
	if found and found:IsA("Animation") then return found end
	return nil
end

function Crestfall.new(info: Types.BaseToolCreateInfo): Crestfall
	local self = setmetatable(BaseRifle.new(info), Crestfall)

	self.className = "StormRifle"
	self.item_image = Crestfall.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("mpgun")
	self.holster_reference = get_holster_reference(self.model_reference)
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "mpgun"
	self.animations = {
		Draw = animation("draw"),
		Hold = animation("held"),

		Aim      = animation("aim"),
		Aim_Left = animation("aim_left"),

		Fire      = animation("fire"),
		Fire_Left = animation("fire_left"),

		Reload_Empty = animation("reload_empty"),
		Reload_Start = animation("reload_start"),

		Check = animation("check"),
		Short = animation("short"),
	}

	self.animation_speeds = {
		Draw = 1 / WEAPON_STATS.draw_speed,
		Aim = 1 / WEAPON_STATS.aim_speed,
		Aim_Left = 1 / WEAPON_STATS.aim_speed,
		Reload_Start = 1 / WEAPON_STATS.reload_start,
		Reload_Empty = 1 / WEAPON_STATS.reload_empty,
	}

	self.damage = WEAPON_STATS.damage
	self.range = WEAPON_STATS.range
	self.range_damage = WEAPON_STATS.range_damage
	self.far = WEAPON_STATS.far
	self.far_damage = WEAPON_STATS.far_damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = WEAPON_STATS.knockback
	self.Aiming_Number = WEAPON_STATS.aiming_number
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = WEAPON_STATS.bullet_speed
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = WEAPON_STATS.melee_range
	self.Melee_Damage = WEAPON_STATS.melee_damage
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.SoundFolder = SoundFolder
	self.FireInterval = WEAPON_STATS.fire_rate

	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self.HipBraced = false
	self._triggerHeld = false
	self._automaticLoopRunning = false
	self._reloadCancelled = false
	self.unequip_wait = false
	self:applyFirearmConfig(WEAPON_STATS)

	self.FireEmissions = {
		smoke_medium = function()
			return math.random(2, 4)
		end,
		smoke_forward = function()
			return math.random(4, 6)
		end,
	}

	self:_initShoulderTracking()
	return self
end

function Crestfall:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeAim = humanoid.WalkSpeed end

	BaseRifle.aim(self)
	if humanoid and self.Aiming then
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
	self:notify(WEAPON_STATS.alt_name)
end

function Crestfall:_damageAtDistance(distance: number): number
	return BaseRifle._damageAtDistance(self, distance)
end

function Crestfall:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation = left and self.RegisteredAnimations and self.RegisteredAnimations.Fire_Left and "Fire_Left" or "Fire"
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
	if not self.Equipped or self.Reloading or self.Equipping then return end
	if self.Capacity >= self.Max_Capacity then return end
	local reserveAmmo = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserveAmmo or not reserveAmmo:IsA("NumberValue") then
		warn(self.className .. ": Cannot reload because Reserve_Ammo is missing")
		return
	end
	if reserveAmmo.Value <= 0 then
		self:notify("I don't have any more ammo...")
		self:_restoreBase()
		return
	end

	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	local reloadTrack = self:_playAnim("Reload_Start")
	if reloadTrack then reloadTrack.Stopped:Wait() end

	if self.Equipped and not self._reloadCancelled then
		local ammoNeeded = math.min(self.Max_Capacity - self.Capacity, reserveAmmo.Value)
		if ammoNeeded > 0 then
			self.Capacity += ammoNeeded
			self:_fire_ammo(ammoNeeded)
		end
	end

	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_blockFireFor(self.PostReloadDelay or 0)
	self:_restoreBaseDeferred()
end

function Crestfall:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if not self.Aiming then
		self:melee()
		return
	end

	self._triggerHeld = true
	if self._automaticLoopRunning then return end
	self._automaticLoopRunning = true
	task.spawn(function()
		while self._triggerHeld and self.Equipped and self.Aiming do
			self:fire()
			task.wait()
		end
		self._automaticLoopRunning = false
	end)
end

function Crestfall:_on_give(tool: Tool)
	tool.Deactivated:Connect(function()
		self._triggerHeld = false
	end)
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
	self._triggerHeld = false
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
Crestfall.name = WEAPON_STATS.name
Crestfall.Display_Name = WEAPON_STATS.name
Crestfall.desc = WEAPON_STATS.desc
Crestfall.lore = WEAPON_STATS.lore
Crestfall.icon = WEAPON_STATS.icon
Crestfall.tooltype = WEAPON_STATS.tooltype
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
