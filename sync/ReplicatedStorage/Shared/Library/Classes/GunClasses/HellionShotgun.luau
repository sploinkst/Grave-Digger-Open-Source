--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseShotgun = require(script.Parent.Parent.BaseShotgun)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local FxFolder = GunAssets.Effects
local rifleFallback = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local hellionAnimations = Assets.Animations.Tools.Guns:FindFirstChild("HellionShotgun")
local assetSounds = Assets:FindFirstChild("Sounds")
local toolSounds = assetSounds and assetSounds:FindFirstChild("tools")
local SoundFolder = (toolSounds and toolSounds:FindFirstChild("autosg"))
	or GunAssets.Sounds:FindFirstChild("autosg")
	or GunAssets.Sounds.PrinceRifle

local STANDARD_RPM = 150
local BLACK_HAND_RPM = 161
local BULLET_SPEED = 850
local STANDARD_FULL_RELOAD = 7.75
local VETERAN_FULL_RELOAD = 5.5
local SHOULDER_WALK_MULTIPLIER = 0.7
local WEAPON_STATS = {
	name = "'Hellion' Automatic Shotgun",
	desc = "High capacity crowd-sweeper capable of annihilating groups in close range.",
	icon = "117308271652473",
	ammo_give = "00 Buckshot",
	damage = 22,
	range = 20,
	range_damage = 12,
	far = 35,
	far_damage = 9,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 2,
	accuracy = 20,
	moving_accuracy = 20,
	fire_rate = 0.4,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 1,
	aim_speed = 0.35,
	pellets = 9,
	recoil = 12,
	recoil_count = 9,
	movement = 2,
	firing_movement = 2,
	firing_movement_last = 0.75,
	ammo_reserves = 1,
	ammo_reserves_max = 2,
	capacity = 7,
	chamber = false,
	reload_start = 0.75,
	reload_empty = 2,
	reload_loop = 1,
	reload_end = 0,
	bullet_speed = BULLET_SPEED,
}

local function animation(name: string, fallback: Animation?): Animation?
	local found = hellionAnimations and hellionAnimations:FindFirstChild(name, true)
	if found and found:IsA("Animation") then return found end
	return fallback
end

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Shoulder_Hold = 0,
	Shoulder_Aim = 0,
	Shoulder_Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Fire_Last = 1,
	Fire_Last_Left = 1,
	Shoulder_Fire = 1,
	Shoulder_Fire_Left = 1,
	Shoulder_Fire_Last = 1,
	Shoulder_Fire_Last_Left = 1,
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
	Check_Empty = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
}

local HellionShotgun = {}
HellionShotgun.__index = HellionShotgun
setmetatable(HellionShotgun, { __index = BaseShotgun })

export type HellionShotgun = typeof(setmetatable({} :: any, HellionShotgun))

local function getModelReference(): Model?
	local source = GunAssets.ToolModels:FindFirstChild("autosg")
	if not source then return nil end
	if source:IsA("Model") then return source end

	local model = Instance.new("Model")
	model.Name = "autosg"
	local sourceClone = source:Clone()
	for _, child in ipairs(sourceClone:GetChildren()) do child.Parent = model end
	sourceClone:Destroy()
	-- The authored asset has both a Folder and the grip Part named "hitbox".
	-- ItemsService resolves Part1 by name, so keep that lookup unambiguous.
	local jointFolder = model:FindFirstChild("hitbox")
	if jointFolder and jointFolder:IsA("Folder") then jointFolder.Name = "joints" end
	local hitbox = model:FindFirstChild("hitbox", true)
	if hitbox and hitbox:IsA("BasePart") then model.PrimaryPart = hitbox end
	return model
end

local function findBasePartNamed(root: Instance, name: string): BasePart?
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == name then return descendant end
	end
	return nil
end

local function hasPerk(perkName: string): boolean
	local player = LOCAL_PLAYER
	local character = player and player.Character
	if character and character:GetAttribute(perkName) == true then return true end
	if player and player:GetAttribute(perkName) == true then return true end
	local playerData = player and player:FindFirstChild("PlayerData")
	local data = playerData and playerData:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and perks:FindFirstChild(perkName)
	if not perk then return false end
	if perk:IsA("BoolValue") then return perk.Value end
	return true
end

function HellionShotgun.new(info: Types.BaseToolCreateInfo): HellionShotgun
	local self = setmetatable(BaseShotgun.new(info), HellionShotgun)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand") or hasPerk("BlackHand")

	self.className = "HellionShotgun"
	self.name = "HellionShotgun"
	self.item_image = HellionShotgun.Tool_Image
	self.ANIM_LAYERS = ANIM_LAYERS
	self.model_reference = getModelReference()
	self.holster_reference = GunAssets.Holsters:FindFirstChild("autosgHolster")
		or GunAssets.Holsters:FindFirstChild("HellionShotgunHolster")
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "autosg"
	self.animations = {
		Hold = animation("locked", rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Held") :: Animation?),
		Aim = animation("aim"),
		Aim_Left = animation("aim_left"),
		Fire = animation("fire"),
		Fire_Left = animation("fire_left"),
		Fire_Last = animation("fire_last"),
		Fire_Last_Left = animation("fire_last_left"),
		Shoulder_Hold = animation("locked"),
		Shoulder_Aim = animation("alt_changeaim"),
		Shoulder_Aim_Left = animation("alt_changeaim_left"),
		Shoulder_Fire = animation("alt_changefire"),
		Shoulder_Fire_Left = animation("alt_changefire_left"),
		Shoulder_Fire_Last = animation("alt_changefire_last"),
		Shoulder_Fire_Last_Left = animation("alt_changefire_last_left"),
		Reload_Start = animation("reload_start"),
		Reload_Empty = animation("reload_empty"),
		Reload_Empty_Vet = animation("reload_empty_vet"),
		Reload_Loop = animation("reload_loop"),
		Check = animation("check"),
		Check_Empty = animation("check_empty"),
		Draw = rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Draw") :: Animation?,
		Unequip = rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Unequip") :: Animation?,
		Melee1 = rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Melee1") :: Animation?,
		Melee2 = rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Melee2") :: Animation?,
		Short = rifleFallback and rifleFallback:FindFirstChild("PrinceRifle_Short") :: Animation?,
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}
	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.6 or WEAPON_STATS.draw_speed),
		Aim = 1 / (blackHand and 0.3 or WEAPON_STATS.aim_speed),
		Aim_Left = 1 / (blackHand and 0.3 or WEAPON_STATS.aim_speed),
		Shoulder_Aim = 1 / (blackHand and 0.43 or 0.5),
		Shoulder_Aim_Left = 1 / (blackHand and 0.43 or 0.5),
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.PelletCount = WEAPON_STATS.pellets
	self.HeadshotMultiplier = 1.2
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 5
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Aiming_Number = 80
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = BULLET_SPEED
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireInterval = blackHand and (60 / BLACK_HAND_RPM) or WEAPON_STATS.fire_rate
	self.FullReloadTime = veteran and VETERAN_FULL_RELOAD or STANDARD_FULL_RELOAD
	self.ShotgunSpread = WEAPON_STATS.accuracy
	self.ShoulderedSpread = WEAPON_STATS.moving_accuracy
	self.Shouldered = false
	self.IsVeteran = veteran
	self.Can_Drop = true
	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = false
	self.FireEmissions = { smoke_medium = 4, smoke_forward = 6 }
	self:_initShoulderTracking()
	self:applyFirearmConfig(WEAPON_STATS)
	self.FireInterval = blackHand and (60 / BLACK_HAND_RPM) or WEAPON_STATS.fire_rate
	self.FullReloadTime = veteran and VETERAN_FULL_RELOAD or STANDARD_FULL_RELOAD
	return self
end

function HellionShotgun:_damageAtDistance(distance: number): number
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
end

function HellionShotgun:get_pellet_directions(direction: Vector3, _spread: number?): { Vector3 }
	return BaseShotgun.get_pellet_directions(self, direction,
		self.Shouldered and self.ShoulderedSpread or self.ShotgunSpread)
end

function HellionShotgun:_aimTrack(): AnimationTrack?
	local animations = self.RegisteredAnimations
	if self.Shouldered and animations then
		return self.current_shoulder == "Right" and animations.Shoulder_Aim or animations.Shoulder_Aim_Left
	end
	return BaseShotgun._aimTrack(self)
end

function HellionShotgun:_killAimTracks()
	BaseShotgun._killAimTracks(self)
	local animations = self.RegisteredAnimations
	if not animations then return end
	for _, name in ipairs({ "Shoulder_Aim", "Shoulder_Aim_Left" }) do
		local track = animations[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

-- Use the shared held pose outside ADS, including alternate firing modes.

function HellionShotgun:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	self.Shouldered = not self.Shouldered
	self:_killAimTracks()
	local animations = self.RegisteredAnimations
	if not self.Shouldered and animations and animations.Shoulder_Hold and animations.Shoulder_Hold.IsPlaying then
		animations.Shoulder_Hold:Stop(0.15)
	end
	if self.Aiming then
		local track = self:_aimTrack()
		if track then track:Play(0.15) end
		local character = LOCAL_PLAYER.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if not self._walkSpeedBeforeShoulder then self._walkSpeedBeforeShoulder = humanoid.WalkSpeed end
			humanoid.WalkSpeed = self.Shouldered
				and self._walkSpeedBeforeShoulder * SHOULDER_WALK_MULTIPLIER
				or self._walkSpeedBeforeShoulder
		end
	end
	self.recoil = self.Shouldered and 52 or 78
	self.recoil_count = self.Shouldered and 6 or 9
	self:notify(self.Shouldered and "Stock shouldered" or "Stock lowered")
	self.Alting = false
	self:_restoreBase()
end

function HellionShotgun:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeShoulder = humanoid.WalkSpeed end
	BaseShotgun.aim(self)
	if humanoid and self.Aiming and self.Shouldered then
		humanoid.WalkSpeed = self._walkSpeedBeforeShoulder * SHOULDER_WALK_MULTIPLIER
	end
end

function HellionShotgun:endAiming()
	BaseShotgun.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeShoulder then humanoid.WalkSpeed = self._walkSpeedBeforeShoulder end
	self._walkSpeedBeforeShoulder = nil
	self:_restoreBase()
end

function HellionShotgun:fire()
	local left = self.current_shoulder ~= "Right"
	local prefix = self.Shouldered and "Shoulder_" or ""
	local suffix = self.Capacity <= 1 and "Fire_Last" or "Fire"
	local sound = SoundFolder:FindFirstChild("fire")
	self:_fireShotgunBlast({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = prefix .. suffix .. (left and "_Left" or ""),
		sound = sound,
		fireDelay = self.FireInterval,
	})
end

function HellionShotgun:reload()
	if self.Reloading or self.Equipping or self.Capacity >= self.Max_Capacity then return end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then
		self:notify("I don't have any more ammo...")
		return
	end
	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	local shellsNeeded = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
	local animations = self.RegisteredAnimations
	local start = animations and animations.Reload_Start
	local loop = animations and animations.Reload_Loop
	local finish = animations and animations.Reload_End
	local authored = (start and start.Length or 0) + (loop and loop.Length or 0) * shellsNeeded
		+ (finish and finish.Length or 0)
	local targetDuration = self.FullReloadTime * (shellsNeeded / self.Max_Capacity)
	local speed = authored > 0 and authored / math.max(targetDuration, 0.1) or 1
	if start then
		local track = self:_playAnim("Reload_Start")
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end
	for _ = 1, shellsNeeded do
		if not self.Equipped or self._reloadCancelled or reserve.Value <= 0 then break end
		if loop then
			local track = self:_playAnim("Reload_Loop")
			if track then
				track:AdjustSpeed(speed)
				track.Stopped:Wait()
			end
		end
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
	end
	if self.Equipped and not self._reloadCancelled and finish then
		local track = self:_playAnim("Reload_End")
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function HellionShotgun:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function HellionShotgun:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level,
			self:_damageAtDistance(distance), self.KnockBack_Force)
	end)

	local animations = self.RegisteredAnimations
	if not animations then return end
	for _, track in pairs(animations) do
		if not track:IsA("AnimationTrack") then continue end
		table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)
			local model = self.actual_model
			if not model then return end
			if keyframe:sub(1, 4) == "sfx_" then
				local sfx = SoundFolder:FindFirstChild("sfx")
				local sound = sfx and sfx:FindFirstChild(keyframe:sub(5))
				local muzzle = self:_findModelPart(self.MuzzlePartName)
				if sound and muzzle then self:_play_sfx(sound, muzzle, nil, 0.1) end
			elseif keyframe == "vfx_eject_casing" then
				local casing = findBasePartNamed(model, "casing")
				if casing then
					self:emit_casing(casing :: any, casing.CFrame, casing.CFrame.RightVector * 5)
				end
			end
		end))
	end
end

function HellionShotgun:_on_unequip()
	self:endAiming()
	self.Equipped = false
	self.Firing = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = true
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
end

HellionShotgun.Tool_Image = "rbxassetid://17496049645"
HellionShotgun.Medal_Cost = 0
HellionShotgun.Weight = 2
HellionShotgun.Designation = "Primary"
HellionShotgun.Display_Name = WEAPON_STATS.name
HellionShotgun.desc = WEAPON_STATS.desc
HellionShotgun.icon = WEAPON_STATS.icon
HellionShotgun.damage = WEAPON_STATS.damage
HellionShotgun.range = WEAPON_STATS.range
HellionShotgun.range_damage = WEAPON_STATS.range_damage
HellionShotgun.far = WEAPON_STATS.far
HellionShotgun.far_damage = WEAPON_STATS.far_damage
HellionShotgun.accuracy = WEAPON_STATS.accuracy
HellionShotgun.moving_accuracy = WEAPON_STATS.moving_accuracy
HellionShotgun.fire_rate = WEAPON_STATS.fire_rate
HellionShotgun.recoil = WEAPON_STATS.recoil
HellionShotgun.recoil_count = WEAPON_STATS.recoil_count
HellionShotgun.capacity = WEAPON_STATS.capacity
HellionShotgun.ammo_give = WEAPON_STATS.ammo_give
HellionShotgun.ammo_reserves = WEAPON_STATS.ammo_reserves
HellionShotgun.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
HellionShotgun.pen = WEAPON_STATS.pen
HellionShotgun.pellets = WEAPON_STATS.pellets

return HellionShotgun
