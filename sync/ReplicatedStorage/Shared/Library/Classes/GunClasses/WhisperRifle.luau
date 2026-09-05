--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local VolkRifle = require(script.Parent.VolkRifle)
local createAnimationResolver = require(script.Parent.AnimationResolver)

local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels

local animation = createAnimationResolver("springfield")

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

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0, Aim = 0, Aim_Left = 0,
	Fire = 1, Fire_Left = 1, Fire_Empty = 1, Fire_Empty_Left = 1,
	Fire_Last = 1, Fire_Last_Left = 1, Recoil = 1, Recoil_Left = 1, Cycle = 1,
	Draw = 2, Unequip = 2, Reload_Start = 2, Reload_Loop = 2,
	Reload_End = 2, Check = 2, Melee1 = 2, Melee2 = 2, Short = 2,
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
		Hold = animation("Hold", "PrinceRifle_Held"),
		Draw = animation("Draw", "PrinceRifle_Draw"),
		Unequip = animation("Unequip", "PrinceRifle_Unequip"),
		Aim = animation("Aim", "PrinceRifle_Aim"),
		Aim_Left = animation("Aim_Left", "PrinceRifle_Aim_Left"),
		Fire = animation("Fire", "PrinceRifle_Fire"),
		Fire_Left = animation("Fire_Left", "PrinceRifle_Fire_Left"),
		Fire_Empty = animation({ "fire_empty" }, "fire_empty"),
		Fire_Empty_Left = animation({ "fire_empty_left" }, "fire_empty_left"),
		Fire_Last = animation({ "fire_last" }, "fire_last"),
		Fire_Last_Left = animation({ "fire_last_left" }, "fire_last_left"),
		Recoil = animation({ "recoil" }, "recoil"),
		Recoil_Left = animation({ "recoil_left" }, "recoil_left"),
		Cycle = animation("Cycle", "PrinceRifle_Cycle"),
		Reload_Start = animation("Reload_Start", "PrinceRifle_Reload_Start"),
		Reload_Loop = animation("Reload_Loop", "PrinceRifle_Reload_Loop"),
		Reload_End = animation("Reload_End", "PrinceRifle_Reload_End"),
		Check = animation("Check", "PrinceRifle_Check"),
		Melee1 = animation("Melee1", "PrinceRifle_Melee1"),
		Melee2 = animation("Melee2", "PrinceRifle_Melee2"),
		Short = animation("Short", "PrinceRifle_Short"),
		Sprint = animation("Sprint", "sprint"),
		Alt_Mode_On = animation({ "alt_mode_on" }, "alt_mode_on"),
		Alt_Mode_Off = animation({ "alt_mode_off" }, "alt_mode_off"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}
	self.animation_speeds.Draw = 1 / 0.75
	self.animation_speeds.Aim = 1 / 0.35
	self.animation_speeds.Aim_Left = 1 / 0.35
	self.animation_speeds.Reload_Loop = 1 / RELOAD_ROUND_TIME

	self.damage = 130
	self.Max_Capacity = 5
	self.Capacity = 5
	self.Starting_Reserve_Ammo = 15
	self.Max_Reserve_Ammo = 20
	self.Ammo_Type = ".30-06 Ball"
	self.Penetration_Level = 2
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force = 12
	self.SoundFolder = whisperSounds
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
	return self
end

function WhisperRifle:_damageAtDistance(distance: number): number
	if self.PedersenMode then return 55 end
	if distance < 70 then return 130 end
	if distance <= 100 then return 120 end
	return 115
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
		self:_playFireAnimation((self.current_shoulder == "Right") and "Fire_Empty" or "Fire_Empty_Left", false)
		return
	end

	self.Firing = true
	self.damage = self.PedersenMode and 55 or 130
	local fired = self:_fireProjectile(
		1200,
		self.Penetration_Level,
		self.damage,
		self.KnockBack_Force
	)
	if fired then
		self.Capacity -= 1
		if self.PedersenMode then self.ShotsUntilJam -= 1 end
		self:_stopAllExcept()
		local fireAnimation = if self.Capacity == 0
			then ((self.current_shoulder == "Right") and "Fire_Last" or "Fire_Last_Left")
			else ((self.current_shoulder == "Right") and "Fire" or "Fire_Left")
		self:_playFireAnimation(fireAnimation)
		local fireSound = whisperSounds:FindFirstChild("fire") or whisperSounds:FindFirstChild("Fire")
		if fireSound and fireSound:IsA("Sound") then self:_play_sfx(fireSound, self:_getMuzzlePart()) end
		if self.PedersenMode and self.ShotsUntilJam <= 0 then self.Jammed = true end
	end

	if self.PedersenMode then
		task.wait(PEDERSEN_FIRE_INTERVAL)
	else
		self.Cycling = true
		task.wait(0.25)
		if self.Equipped then
			self:_stopAllExcept()
			local cycleTrack = self:_playAnim("Cycle")
			local cycleSound = whisperSounds:FindFirstChild("cycle") or whisperSounds:FindFirstChild("bolt")
			if cycleSound and cycleSound:IsA("Sound") then self:_play_sfx(cycleSound, self:_getMuzzlePart()) end
			if cycleTrack then cycleTrack.Stopped:Wait() end
		end
		task.wait(math.max(0, BOLT_FIRE_INTERVAL - 0.25))
		self.Cycling = false
	end
	self.Firing = false
	self:_restoreBaseDeferred()
end

function WhisperRifle:reload()
	if not self.PedersenMode then
		VolkRifle.reload(self)
		return
	end
	if self.Reloading or self.Capacity >= self.Max_Capacity or self.PedersenReserve <= 0 then return end

	if self.Aiming then self:endAiming() end
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

WhisperRifle.Tool_Image = "rbxassetid://17496049645"
WhisperRifle.Medal_Cost = 0
WhisperRifle.Weight = 2
WhisperRifle.Designation = "Primary"

return WhisperRifle
