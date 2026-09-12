--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local VolkRifle = require(script.Parent.VolkRifle)

local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels

local whisperAnimations = Assets.Animations.Tools.Guns:FindFirstChild("WhisperRifle")

local whisperSounds = GunAssets.Sounds:FindFirstChild("springfield")
		or GunAssets.Sounds:FindFirstChild("Springfield")
		or GunAssets.Sounds:FindFirstChild("WhisperRifle")
		or GunAssets.Sounds:FindFirstChild("Whisper")
		or GunAssets.Sounds.PrinceRifle

local PEDERSEN_FIRE_INTERVAL = 60 / 186
local BOLT_FIRE_INTERVAL = 60 / 60
local PEDERSEN_SWITCH_TIME = 7
local PEDERSEN_RELOAD_TIME = 5
local PEDERSEN_JAM_CLEAR_TIME = 1
local RELOAD_ROUND_TIME = 5.2 / 5
local WEAPON_STATS = {
	name = "'Whisper' Silenced Rifle",
	desc = "A silent and powerful bolt rifle that leaves no bullet trails.",
	icon = "130781995861130",
	ammo_give = ".30-06 Ball",
	damage = 130,
	range = 70,
	range_damage = 120,
	far = 100,
	far_damage = 115,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	accuracy = 6,
	moving_accuracy = 100,
	fire_rate = 0.3,
	cycle = 0.55,
	cycle_rest = 0.15,
	draw_speed = 0.75,
	aim_speed = 0.35,
	recoil = 8,
	recoil_count = 6,
	movement = 1,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 3,
	ammo_reserves_max = 4,
	capacity = 5,
	chamber = false,
	reload_start = 1.5,
	reload_empty = 1.75,
	reload_loop = 0.65,
	reload_end = 0.75,
}

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
	Recoil = 1,
	Recoil_Left = 1,
	Cycle = 1,
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

local WhisperRifle = {}
WhisperRifle.__index = WhisperRifle
setmetatable(WhisperRifle, { __index = VolkRifle })

export type WhisperRifle = typeof(setmetatable({} :: any, WhisperRifle))

local function findModel(): Model?
	local model = ToolFolder:FindFirstChild("springfield")
		or ToolFolder:FindFirstChild("Springfield")
		or ToolFolder:FindFirstChild("WhisperRifle")
		or ToolFolder:FindFirstChild("Whisper")
	return model and model:IsA("Model") and model or nil
end

local function configureSuppressedSounds(folder: Instance)
	if not RunService:IsClient() then return end
	for _, sound in folder:GetDescendants() do
		if sound:IsA("Sound") then
			local name = string.lower(sound.Name)
			sound.RollOffMaxDistance = (name == "fire") and 20 or math.min(sound.RollOffMaxDistance, 65)
		end
	end
end

function WhisperRifle.new(info: Types.BaseToolCreateInfo): WhisperRifle
	-- Reuse the established bolt-action behavior, then replace its identity,
	-- assets, statistics, and alternate-action behavior.
	local self = setmetatable(VolkRifle.new(info), WhisperRifle)

	self.className = "WhisperRifle"
	self.item_image = WhisperRifle.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	local model = findModel()
	if model then
		self.model_reference = model
		self.holster_reference = GunAssets.Holsters:FindFirstChild("springfieldHolster")
			or GunAssets.Holsters:FindFirstChild("SpringfieldHolster")
			or GunAssets.Holsters:FindFirstChild("WhisperRifleHolster")
		self.motor_6d_data.Part1 = model:FindFirstChild("hitbox", true)
	end

	self.AnimationGunType = "springfield"
	self.animations = {
		Hold = whisperAnimations.held,
		Draw = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Draw,
		Unequip = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Unequip,
		Aim = whisperAnimations.aim,
		Aim_Left = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Aim_Left,
		Fire = whisperAnimations.fire,
		Fire_Left = whisperAnimations.fire_left,
		Cycle = whisperAnimations.cycle,
		Reload_Start = whisperAnimations.reload_start,
		Reload_Loop =whisperAnimations.reload_loop,
		Reload_End = whisperAnimations.reload_end,
		Check = whisperAnimations.check,
		Melee1 = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Melee1,
		Melee2 = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Melee2,
		Short = whisperAnimations.Parent.PrinceRifle.PrinceRifle_Short,
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}
	self.animation_speeds.Draw = 1 / WEAPON_STATS.draw_speed
	self.animation_speeds.Aim = 1 / WEAPON_STATS.aim_speed
	self.animation_speeds.Aim_Left = 1 / WEAPON_STATS.aim_speed
	self.animation_speeds.Reload_Loop = 1 / WEAPON_STATS.reload_loop

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 12
	self.SoundFolder = whisperSounds
	self.BulletSpeed = 1200
	self.FireEmissions = nil

	self.PedersenMode = false
	self.PedersenCapacity = 0
	self.PedersenReserve = 0
	self.PedersenMaxCapacity = 40
	self.PedersenMaxReserve = 40
	self.ShotsUntilJam = math.random(7, 15)
	self.Jammed = false
	self.Alting = false

	configureSuppressedSounds(whisperSounds)
	self:applyFirearmConfig(WEAPON_STATS)
	self.SoundFolder = whisperSounds
	return self
end

function WhisperRifle:_damageAtDistance(distance: number): number
	if self.PedersenMode then return 55 end
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
end

function WhisperRifle:setAltMode()
	if not self.Equipped or self:_isBusy() or self.Alting then return end
	if self.Aiming then self:endAiming() end

	self.Alting = true
	self:_stopAllExcept()
	local switchTrack = self:_playAnim(self.PedersenMode and "Alt_Mode_Off" or "Alt_Mode_On")
	if not switchTrack then switchTrack = self:_playAnim("Short") end
	if switchTrack then switchTrack:AdjustSpeed(math.max(switchTrack.Length / PEDERSEN_SWITCH_TIME, 0.01)) end
	task.wait(PEDERSEN_SWITCH_TIME)

	if self.Equipped then
		self.PedersenMode = not self.PedersenMode
		if self.PedersenMode then
			self._BoltCapacity = self.Capacity
			self.Capacity = self.PedersenCapacity
			self.Max_Capacity = self.PedersenMaxCapacity
			self.Ammo_Type = ".30 Light"
			self.Penetration_Level = 0
			self.Armor_Penetration_Level = 1
		else
			self.PedersenCapacity = self.Capacity
			self.Capacity = self._BoltCapacity or 5
			self.Max_Capacity = 5
			self.Ammo_Type = ".30-06 Ball"
			self.Penetration_Level = 2
			self.Armor_Penetration_Level = 3
		end
		self:notify(self.PedersenMode and "Pedersen Device installed" or "Bolt action restored")
	end

	self.Alting = false
	self:_restoreBaseDeferred()
end

function WhisperRifle:fire()
	if self.PedersenMode and self.Jammed then
		if self.Cycling then return end
		self.Cycling = true
		self:notify("Clearing jam...")
		task.wait(PEDERSEN_JAM_CLEAR_TIME)
		self.Jammed = false
		self.ShotsUntilJam = math.random(7, 15)
		self.Cycling = false
		return
	end

	if self.Firing or self.Cycling or self.Reloading or self.Checking or self.Alting or not self.Aiming then return end
	if self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return end
	if self.Capacity <= 0 then
		self:_dryFire()
		return
	end

	self.damage = self.PedersenMode and 55 or 130
	local fireAnimation = if self.Capacity <= 1
		then ((self.current_shoulder == "Right") and "Fire_Last" or "Fire_Last_Left")
		else ((self.current_shoulder == "Right") and "Fire" or "Fire_Left")
	local fireSound = whisperSounds:FindFirstChild("fire") or whisperSounds:FindFirstChild("Fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = 1200,
		fireAnimation = fireAnimation,
		sound = fireSound,
	})
	if fired then
		if self.PedersenMode then self.ShotsUntilJam -= 1 end
		if self.PedersenMode and self.ShotsUntilJam <= 0 then self.Jammed = true end
	end
	if not fired then return end

	if self.PedersenMode then
		task.wait(PEDERSEN_FIRE_INTERVAL)
	else
		self.Cycling = true
		task.wait(0.25)
		if self.Equipped then
			self:_stopAllExcept()
			local cycleTrack = self:_playAnim("Cycle")
			local cycleSound = whisperSounds:FindFirstChild("cycle") or whisperSounds:FindFirstChild("bolt")
			local muzzle = self:_getMuzzlePart()
			if cycleSound and cycleSound:IsA("Sound") and muzzle then self:_play_sfx(cycleSound, muzzle) end
			if cycleTrack then cycleTrack.Stopped:Wait() end
		end
		task.wait(math.max(0, BOLT_FIRE_INTERVAL - 0.25))
		self.Cycling = false
	end
	self:_restoreBaseDeferred()
end

function WhisperRifle:reload()
	if not self.PedersenMode then
		VolkRifle.reload(self)
		return
	end
	if self.Reloading or self.Capacity >= self.Max_Capacity or self.PedersenReserve <= 0 then return end

	self.Reloading = true
	self:_stopAllExcept()
	self:_playAnim("Reload_Start")
	task.wait(PEDERSEN_RELOAD_TIME)
	if self.Equipped then
		local loaded = math.min(self.Max_Capacity - self.Capacity, self.PedersenReserve)
		self.Capacity += loaded
		self.PedersenReserve -= loaded
	end
	self.Reloading = false
	self:_restoreBaseDeferred()
end

WhisperRifle.Tool_Image = "rbxassetid://76707981179928"
WhisperRifle.Medal_Cost = 0
WhisperRifle.Weight = 2
WhisperRifle.Designation = "Primary"
WhisperRifle.Display_Name = WEAPON_STATS.name
WhisperRifle.desc = WEAPON_STATS.desc
WhisperRifle.icon = WEAPON_STATS.icon
WhisperRifle.damage = WEAPON_STATS.damage
WhisperRifle.range = WEAPON_STATS.range
WhisperRifle.range_damage = WEAPON_STATS.range_damage
WhisperRifle.far = WEAPON_STATS.far
WhisperRifle.far_damage = WEAPON_STATS.far_damage
WhisperRifle.accuracy = WEAPON_STATS.accuracy
WhisperRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
WhisperRifle.fire_rate = WEAPON_STATS.fire_rate
WhisperRifle.cycle = WEAPON_STATS.cycle
WhisperRifle.cycle_rest = WEAPON_STATS.cycle_rest
WhisperRifle.recoil = WEAPON_STATS.recoil
WhisperRifle.recoil_count = WEAPON_STATS.recoil_count
WhisperRifle.capacity = WEAPON_STATS.capacity
WhisperRifle.ammo_give = WEAPON_STATS.ammo_give
WhisperRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
WhisperRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
WhisperRifle.pen = WEAPON_STATS.pen

return WhisperRifle
