--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)
local VolkRifle = require(script.Parent.VolkRifle)

local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels

local whisperAnimations = Assets.Animations.Tools.Guns:FindFirstChild("WhisperRifle")
local princeAnimations = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")

local function animation(folder: Instance?, name: string): Animation?
	local found = folder and folder:FindFirstChild(name)
	return if found and found:IsA("Animation") then found else nil
end

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
	pen = 2,
	armor_pen = 3,
	accuracy = 6,
	moving_accuracy = 100,
	fire_rate = BOLT_FIRE_INTERVAL,
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
	Reload_Clip = 2,
	Reload_Clip_Start_Empty = 2,
	Reload_Clip_Start_One = 2,
	Reload_Empty = 2,
	Reload_Heavyloop = 2,
	Cycle_Pedersen = 1,
	Pedersen_Bolt_Place = 2,
	Pedersen_Bolt_Remove = 2,
	Pedersen_Charge = 2,
	Pedersen_Device_Off = 2,
	Pedersen_Device_On = 2,
	Pedersen_Jam = 2,
	Pedersen_Mag_Eject = 2,
	Pedersen_Mag_In = 2,
	Pedersen_Mag_Out = 2,
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

	self.AnimationGunType = "WhisperRifle"
	self.animations = {
		Hold = animation(whisperAnimations, "held"),
		Locked = animation(whisperAnimations, "locked"),
		Locked_Alt = animation(whisperAnimations, "locked_alt"),
		Draw = animation(princeAnimations, "draw"),
		Unequip = animation(princeAnimations, "unequip"),
		Aim = animation(whisperAnimations, "aim"),
		Aim_Left = animation(princeAnimations, "aim_left"),
		Fire = animation(whisperAnimations, "fire"),
		Fire_Left = animation(whisperAnimations, "fire_left"),
		Cycle = animation(whisperAnimations, "cycle"),
		Cycle_Pedersen = animation(whisperAnimations, "cycle_pedersen"),
		Reload_Start = animation(whisperAnimations, "reload_start"),
		Reload_Start_Vet = animation(whisperAnimations, "reload_start_vet"),
		Reload_Loop = animation(whisperAnimations, "reload_loop"),
		Reload_End = animation(whisperAnimations, "reload_end"),
		Reload_Empty = animation(whisperAnimations, "reload_empty"),
		Reload_Clip = animation(whisperAnimations, "reload_clip"),
		Reload_Clip_Start_Empty = animation(whisperAnimations, "reload_clip_start_empty"),
		Reload_Clip_Start_One = animation(whisperAnimations, "reload_clip_start_one"),
		Reload_Heavyloop = animation(whisperAnimations, "reload_heavyloop"),
		Pedersen_Bolt_Place = animation(whisperAnimations, "pedersen_bolt_place"),
		Pedersen_Bolt_Remove = animation(whisperAnimations, "pedersen_bolt_remove"),
		Pedersen_Charge = animation(whisperAnimations, "pedersen_charge"),
		Pedersen_Device_Off = animation(whisperAnimations, "pedersen_device_off"),
		Pedersen_Device_On = animation(whisperAnimations, "pedersen_device_on"),
		Pedersen_Jam = animation(whisperAnimations, "pedersen_jam"),
		Pedersen_Mag_Eject = animation(whisperAnimations, "pedersen_mag_eject"),
		Pedersen_Mag_In = animation(whisperAnimations, "pedersen_mag_in"),
		Pedersen_Mag_Out = animation(whisperAnimations, "pedersen_mag_out"),
		Check = animation(whisperAnimations, "check"),
		Melee1 = animation(princeAnimations, "melee1"),
		Melee2 = animation(princeAnimations, "melee2"),
		Short = animation(princeAnimations, "short"),
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
	self.Armor_Penetration_Level = WEAPON_STATS.armor_pen
	self.KnockBack_Force = 12
	self.SoundFolder = whisperSounds
	self.BulletSpeed = 1200
	self.FireEmissions = nil
	self.ShowBulletTrail = false

	self.PedersenMode = false
	-- The first 40-round magazine is installed with the device. Its reserve
	-- starts empty and must be replenished separately.
	self.PedersenCapacity = 40
	self.PedersenMaxCapacity = self.IsVeteran and 41 or 40
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

local function setModelGroupVisible(group: Instance?, visible: boolean)
	if not group then return end
	local instances = group:GetDescendants()
	table.insert(instances, group)
	for _, descendant in instances do
		if descendant:IsA("BasePart") then
			local original = descendant:GetAttribute("WhisperOriginalTransparency")
			if type(original) ~= "number" then
				original = descendant.Transparency
				descendant:SetAttribute("WhisperOriginalTransparency", original)
			end
			descendant.Transparency = if visible then original else 1
		end
	end
end

function WhisperRifle:_syncPedersenModel()
	local model = self.actual_model
	if not model then return end
	local parts = model:FindFirstChild("parts")
	if not parts then return end
	setModelGroupVisible(parts:FindFirstChild("bolt"), not self.PedersenMode)
	setModelGroupVisible(parts:FindFirstChild("pedersen"), self.PedersenMode)
	setModelGroupVisible(parts:FindFirstChild("pedersenmag"), self.PedersenMode)
end

function WhisperRifle:_getMuzzlePart(): BasePart?
	local model = self.actual_model
	local muzzleName = self.PedersenMode and "altmuzzle" or "muzzle"
	local muzzle = model and model:FindFirstChild(muzzleName, true)
	if muzzle and muzzle:IsA("BasePart") then return muzzle end
	return VolkRifle._getMuzzlePart(self)
end

function WhisperRifle:_refreshFastCast()
	self:_setupFastCast(GunAssets.Effects, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local muzzle = self:_getMuzzlePart()
		self:_onBulletHit(
			cast,
			result,
			velocity,
			muzzle,
			self.Penetration_Level,
			self:_damageAtDistance(distance),
			self.KnockBack_Force
		)
	end)
end

-- Whisper has ordinary rifle sights. It inherits Volk's bolt mechanics, not
-- Volk's scope camera or its iron-sight FOV override.
function WhisperRifle:aim()
	local character = game.Players.LocalPlayer.Character
	if character then character:SetAttribute("WeaponFOV", nil) end
	BaseRifle.aim(self)
end

function WhisperRifle:endAiming()
	local character = game.Players.LocalPlayer.Character
	if character then character:SetAttribute("WeaponFOV", nil) end
	BaseRifle.endAiming(self)
end

function WhisperRifle:_playTimedAction(name: string, duration: number): boolean
	local track = self:_playAnim(name)
	if not track then
		task.wait(duration)
		return false
	end

	local loadDeadline = os.clock() + 0.25
	while track.Length <= 0 and os.clock() < loadDeadline and self.Equipped do
		RunService.Heartbeat:Wait()
	end
	if track.Length > 0 then
		track:AdjustSpeed(track.Length / math.max(duration, 0.01))
	end

	local finished = false
	local stoppedConnection = track.Stopped:Once(function() finished = true end)
	local deadline = os.clock() + duration + 0.25
	while not finished and self.Equipped and os.clock() < deadline do
		RunService.Heartbeat:Wait()
	end
	stoppedConnection:Disconnect()
	if track.IsPlaying then track:Stop(0.05) end
	return self.Equipped
end

function WhisperRifle:setAltMode()
	if not self.Equipped or self:_isBusy() or self.Alting then return end
	if self.Aiming then self:endAiming() end

	self.Alting = true
	self:_stopAllExcept()
	local switchSequence = if self.PedersenMode
		then { "Pedersen_Mag_Out", "Pedersen_Device_Off", "Pedersen_Bolt_Place", "Cycle_Pedersen" }
		else { "Pedersen_Bolt_Remove", "Pedersen_Device_On", "Pedersen_Mag_In", "Pedersen_Charge" }
	for _, animationName in switchSequence do
		if not self:_playTimedAction(animationName, PEDERSEN_SWITCH_TIME / #switchSequence) then break end
	end

	if self.Equipped then
		self.PedersenMode = not self.PedersenMode
		if self.PedersenMode then
			self._BoltCapacity = self.Capacity
			self.Capacity = self.PedersenCapacity
			self.Max_Capacity = self.PedersenMaxCapacity
			self.Ammo_Type = ".30 Light"
			self.Penetration_Level = 0
			self.Armor_Penetration_Level = 1
			self.FireInterval = PEDERSEN_FIRE_INTERVAL
			self.recoil = 1
		else
			self.PedersenCapacity = self.Capacity
			self.Capacity = self._BoltCapacity or 5
			self.Max_Capacity = 5
			self.Ammo_Type = ".30-06 Ball"
			self.Penetration_Level = 2
			self.Armor_Penetration_Level = 3
			self.FireInterval = BOLT_FIRE_INTERVAL
			self.recoil = WEAPON_STATS.recoil
		end
		self:_syncPedersenModel()
		self:_refreshFastCast()
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
		self:_playTimedAction("Pedersen_Jam", PEDERSEN_JAM_CLEAR_TIME)
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

	local shotStartedAt = os.clock()
	self.damage = self.PedersenMode and 55 or 130
	local fireAnimation = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	local fireSound = if self.PedersenMode
		then whisperSounds:FindFirstChild("pedersen_fire") or whisperSounds:FindFirstChild("fire")
		else whisperSounds:FindFirstChild("fire") or whisperSounds:FindFirstChild("Fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = 1200,
		fireAnimation = fireAnimation,
		sound = fireSound,
		fireDelay = self.PedersenMode and PEDERSEN_FIRE_INTERVAL or 0,
	})
	if fired then
		if self.PedersenMode then self.ShotsUntilJam -= 1 end
		if self.PedersenMode and self.ShotsUntilJam <= 0 then self.Jammed = true end
	end
	if not fired then return end

	if not self.PedersenMode then
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
		task.wait(math.max(0, BOLT_FIRE_INTERVAL - (os.clock() - shotStartedAt)))
		self.Cycling = false
	end
	self:_restoreBaseDeferred()
end

function WhisperRifle:reload()
	if not self.PedersenMode then
		if self.IsVeteran and self.Capacity <= 1 then
			self:_reloadByRound({
				startAnim = self.Capacity <= 0 and "Reload_Clip_Start_Empty" or "Reload_Clip_Start_One",
				useEmptyAnim = false,
				useVeteranAnimations = false,
				loopAnim = "Reload_Clip",
				roundsPerLoop = self.Max_Capacity,
				endAnim = "Reload_End",
			})
			return
		end
		VolkRifle.reload(self)
		return
	end
	local reserve = self.tool and self.tool:FindFirstChild("Pedersen_Reserve")
	if not reserve or not reserve:IsA("NumberValue") then
		warn("[WhisperRifle] Pedersen_Reserve is missing")
		return
	end
	if self.Reloading or self.Capacity >= self.Max_Capacity or reserve.Value <= 0 then return end

	self.Reloading = true
	self:_stopAllExcept()
	local wasEmpty = self.Capacity <= 0
	local sequence = {
		wasEmpty and "Pedersen_Mag_Eject" or "Pedersen_Mag_Out",
		"Pedersen_Mag_In",
	}
	if wasEmpty then table.insert(sequence, "Pedersen_Charge") end
	for _, animationName in sequence do
		if not self:_playTimedAction(animationName, PEDERSEN_RELOAD_TIME / #sequence) then break end
	end
	if self.Equipped then
		local loaded = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
		self.Capacity += loaded
		self:_fire_ammo(loaded, "Pedersen_Reserve")
	end
	self.Reloading = false
	self:_restoreBaseDeferred()
end

function WhisperRifle:_on_equip()
	VolkRifle._on_equip(self)
	self:_refreshFastCast()
	task.defer(function()
		if self.Equipped then self:_syncPedersenModel() end
	end)
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
