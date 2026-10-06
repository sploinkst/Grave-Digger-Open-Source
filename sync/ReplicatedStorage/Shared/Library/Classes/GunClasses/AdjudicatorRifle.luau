--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local CrestfallRifle = require(script.Parent.CrestfallRifle)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local Animations = Assets.Animations.Tools.Guns.AdjudicatorRifle

local assetSounds = Assets:FindFirstChild("Sounds")
local toolSounds = assetSounds and assetSounds:FindFirstChild("Guns")
local SoundFolder = (toolSounds and toolSounds:FindFirstChild("AdjudicatorRifle"))
	or (toolSounds and toolSounds:FindFirstChild("rsc"))
	or Assets.Sounds.Guns:FindFirstChild("rsc") or Assets.Sounds.Guns:FindFirstChild("AdjudicatorRifle")
	or Assets.Sounds.Guns.PrinceRifle

local CLIP_SIZE = 5
local STANDARD_RPM = 127
local BLACK_HAND_RPM = 60 / (0.475 * 0.925)
local STANDARD_RELOAD_TIME = 4.25
local VETERAN_RELOAD_TIME = 4.25
local STANDARD_FAILED_RELOAD_TIME = 4.25
local VETERAN_FAILED_RELOAD_TIME = 4.25
local BOLT_CATCH_FAILURE_CHANCE = 0.5
local ALT_SWITCH_TIME = 0.3
local CUT = 0.06
local WEAPON_STATS = {
	name = "'Adjudicator' Repeating Rifle",
	desc = "Semi automatic clip fed rifle firing a rifle sized cartridge.",
	icon = "131875342064540",
	ammo_give = "8mm Gras",
	damage = 140,
	range = 50,
	range_damage = 105,
	far = 70,
	far_damage = 80,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	accuracy = 8,
	moving_accuracy = 150,
	fire_rate = 0.475,
	cycle = 0,
	cycle_rest = 0,
	post_reload_delay = 0.15,
	draw_speed = 0.8,
	aim_speed = 0.4,
	recoil = 8,
	recoil_count = 6,
	movement = 3,
	firing_movement = 2,
	firing_movement_last = 0.75,
	ammo_reserves = 3,
	ammo_reserves_max = 4,
	capacity = 5,
	chamber = true,
	reload_start = 3,
	reload_empty = 0,
	reload_loop = 0,
	reload_end = 1.25,
	require_full_load = true,
	size = 2,
	wallpen_distance = 50,
	wallpen_studs = 3,
	wound = 1,
	length = 4.5,
}

local WALKING_FIRE_STATS = {
	recoil = 5,
	accuracy = 30,
	moving_accuracy = 50,
	aim_speed = 0.3,
	movement = 1,
	firing_movement = 0.5,
}

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Hip_Hold = 0,
	Hip_Aim = 0,
	Hip_Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Hip_Fire = 1,
	Hip_Fire_Left = 1,
	Reload_Start = 2,
	Reload_Start_Vet = 2,
	Reload_End = 2,
	Reload_End_Locked = 2,
	Check = 2,
}

local AdjudicatorRifle = {}
AdjudicatorRifle.__index = AdjudicatorRifle
setmetatable(AdjudicatorRifle, { __index = CrestfallRifle })

export type AdjudicatorRifle = typeof(setmetatable({} :: any, AdjudicatorRifle))

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
	if perk:IsA("StringValue") then return perk.Value == perkName or perk.Value ~= "" end
	return true
end

local function playReloadSequence(self: AdjudicatorRifle, endingName: string, duration: number)
	local equipGeneration = self._equipGeneration
	local animations = self.RegisteredAnimations
	local startTrack = animations and animations.Reload_Start
	local endTrack = endingName and animations and animations[endingName]
 if startTrack then
  local track=self:_playAnim("Reload_Start",false,{speed=1/self.reload_start})
  if not self:_waitReloadPhase(track,self.reload_start) then return end
 end
 if not self.Equipped or self._equipGeneration~=equipGeneration then return end
 if not self._reloadCancelled and endTrack then
  local seconds=self.reload_end*(endingName=="Reload_End_Locked" and 0.5 or 1)
  local track=self:_playAnim(endingName,false,{speed=1/seconds})
  self:_waitReloadPhase(track,seconds)
 end
end

function AdjudicatorRifle.new(info: Types.BaseToolCreateInfo): AdjudicatorRifle
	local self = setmetatable(CrestfallRifle.new(info), AdjudicatorRifle)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand") or hasPerk("BlackHand")

	self.className = "AdjudicatorRifle"
	self.HandlesCasingKeyframes = true
	self.name = "AdjudicatorRifle"
	self.item_image = AdjudicatorRifle.Tool_Image
	self.ANIM_LAYERS = ANIM_LAYERS
	self.model_reference = ToolFolder:FindFirstChild("rsc")
	self.holster_reference = GunAssets.Holsters:FindFirstChild("rscHolster")
		or GunAssets.Holsters:FindFirstChild("AdjudicatorRifleHolster")
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "AdjudicatorRifle"
	self.animations = {
		Hold = Animations:FindFirstChild("held"),
		Aim = Animations.aim,
		Aim_Left = Animations.aim_left,
		Fire = Animations.fire,
		Fire_Left = Animations.fire_left,
		Hip_Hold = Animations:FindFirstChild("held"),
		Hip_Aim = Animations.alt_changeaim,
		Hip_Aim_Left = Animations.alt_changeaim_left,
		Hip_Fire = Animations.alt_changefire,
		Hip_Fire_Left = Animations.alt_changefire_left,
		Reload_Start = veteran and Animations.reload_start_vet or Animations.reload_start,
		Reload_Start_Vet = Animations.reload_start_vet,
		Reload_End = Animations.reload_end,
		Reload_End_Locked = Animations.reload_end_locked,
		Check = Animations.check,
	}

	self.animation_speeds = {
		Aim = 1 / (blackHand and 0.34 or WEAPON_STATS.aim_speed),
		Aim_Left = 1 / (blackHand and 0.34 or WEAPON_STATS.aim_speed),
		Hip_Aim = 1 / (blackHand and 0.26 or 0.3),
		Hip_Aim_Left = 1 / (blackHand and 0.26 or 0.3),
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = veteran and (WEAPON_STATS.capacity + 1) or WEAPON_STATS.capacity
	self.Capacity = self.Max_Capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 10
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Aiming_Number = 80
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.HipBraceAccuracy = 12
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireInterval = blackHand and (60 / BLACK_HAND_RPM) or WEAPON_STATS.fire_rate
	self.IsVeteran = self.IsVeteran or veteran
	self.HipBraced = false
	self:applyFirearmConfig(WEAPON_STATS)
	if veteran then
		self.Max_Capacity = WEAPON_STATS.capacity + 1
		self.Capacity = self.Max_Capacity
	end
	if blackHand then
		self.FireInterval = 60 / BLACK_HAND_RPM
	end

	return self
end

function AdjudicatorRifle:_damageAtDistance(distance: number): number
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
end

function AdjudicatorRifle:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true

	self.HipBraced = not self.HipBraced
	self:_killAimTracks()
	local hipAim = self:_aimTrack()

	if self.HipBraced then
		self.recoil = WALKING_FIRE_STATS.recoil
		self.Accuracy = WALKING_FIRE_STATS.accuracy
		self.Moving_Accuracy = WALKING_FIRE_STATS.moving_accuracy
		self.aim_speed = WALKING_FIRE_STATS.aim_speed
		self.movement = WALKING_FIRE_STATS.movement
		self.firing_movement = WALKING_FIRE_STATS.firing_movement
		self.FixedAimingSpread = self.Aiming and self.HipBraceAccuracy or nil
	else
		self.recoil = WEAPON_STATS.recoil
		self.Accuracy = WEAPON_STATS.accuracy
		self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
		self.aim_speed = WEAPON_STATS.aim_speed
		self.movement = WEAPON_STATS.movement
		self.firing_movement = WEAPON_STATS.firing_movement
		self.FixedAimingSpread = nil
	end

	if self.Aiming then
		if hipAim then self:_blendAim(hipAim) end
		self:_enable_aiming_ui(self.Aiming_Number)
	end

	self:notify(self.HipBraced and "Walking Fire" or "Shouldered Fire")
	task.wait(ALT_SWITCH_TIME)
	self.Alting = false
end

function AdjudicatorRifle:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation
	if self.HipBraced then
		fireAnimation = left and "Hip_Fire_Left" or "Hip_Fire"
	else
		fireAnimation = left and "Fire_Left" or "Fire"
	end

	local fireSound = self.SoundFolder and self.SoundFolder:FindFirstChild("fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = fireAnimation,
		sound = fireSound,
		fireDelay = self.FireInterval or WEAPON_STATS.fire_rate,
	})
	if not fired then return end
	if self.Capacity <= 0 then self.SlideLocked = math.random() < BOLT_CATCH_FAILURE_CHANCE end

	self:_restoreBaseDeferred()
end

function AdjudicatorRifle:reload()
	if not self.Equipped or self.Reloading or self.Equipping or self.Firing or self.Cycling then return end
	local previousAmmo = self.Capacity
	local retained = if self.IsVeteran and previousAmmo > 0 then 1 else 0
	if self.Capacity >= WEAPON_STATS.capacity then return end
	local reserve = self:_getReserveAmmo()
	if not reserve or reserve.Value < CLIP_SIZE then
		self:notify("I need a full clip to reload...")
		return
	end
	local equipGeneration = self._equipGeneration
	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()
	-- The master wastes a partial clip; Veteran retains only its chambered round.
	self.Capacity = retained
	local ending = if retained == 1 then nil elseif self.SlideLocked then "Reload_End_Locked" else "Reload_End"
	local closingTime = if ending == "Reload_End_Locked" then WEAPON_STATS.reload_end * 0.5
		elseif ending then WEAPON_STATS.reload_end else 0
	playReloadSequence(self, ending, WEAPON_STATS.reload_start + closingTime)
	if not self.Equipped or self._equipGeneration ~= equipGeneration then return end
	self.Capacity = WEAPON_STATS.capacity + retained
	self.Max_Capacity = WEAPON_STATS.capacity + (self.IsVeteran and 1 or 0)
	self:_fire_ammo(CLIP_SIZE - (self.IsVeteran and previousAmmo or 0))
	self.SlideLocked = false
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

-- A shot opens one ejection event even if an animation contains both aliases.
function AdjudicatorRifle:_playFireAnimation(name)
	self._shotCasingEjected = false
	return CrestfallRifle._playFireAnimation(self, name)
end

function AdjudicatorRifle:_ejectShotCasing()
	if self._shotCasingEjected ~= false or not self.Equipped then return end
	-- Eject the authored cartridge assembly, including its bullet mesh.
	-- The ejection marker is not the object that should be dropped.
	local casing = self:_findModelPart("casing")
	if not casing then return end
	self._shotCasingEjected = true
	local muzzle = self:_findModelPart(self.MuzzlePartName or "muzzle")
	local directionFrame = muzzle and muzzle.CFrame or casing.CFrame
	self:emit_casing(casing, casing.CFrame, directionFrame.RightVector * 12)
end

function AdjudicatorRifle:_on_equip()
	CrestfallRifle._on_equip(self)
	local animations = self.RegisteredAnimations
	if not animations then return end

	local connectedTracks = {}
	for _, track in pairs(animations) do
		if not track:IsA("AnimationTrack") or connectedTracks[track] then continue end
		connectedTracks[track] = true
		table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)
			local model = self.actual_model
			if not model then return end

			if keyframe:sub(1, 4) == "sfx_" then
				local sfx = SoundFolder:FindFirstChild("sfx")
				local sound = sfx and sfx:FindFirstChild(keyframe:sub(5))
				local muzzle = self:_findModelPart(self.MuzzlePartName)
				if sound and muzzle then self:_play_sfx(sound, muzzle, nil, nil, nil, 0.1) end
			elseif keyframe == "vfx_eject_casing" or keyframe == "vfx_rsc_eject_casing" then
				self:_ejectShotCasing()
			elseif keyframe == "vfx_rsc_clip_eject" then
				local clip = model:FindFirstChild("clip", true)
				if clip and clip:IsA("BasePart") then
					self:emit_casing(clip :: any, clip.CFrame, clip.CFrame.RightVector * 3)
					clip.Transparency = 1
				end
			elseif keyframe == "vfx_rsc_newclip" or keyframe == "vfx_rsc_clip_update" then
				local clip = model:FindFirstChild("clip", true)
				if clip and clip:IsA("BasePart") then clip.Transparency = 0 end
			end
		end))
	end
end

AdjudicatorRifle.Tool_Image = "rbxassetid://109119172425763"
AdjudicatorRifle.Medal_Cost = 0
AdjudicatorRifle.Weight = 2
AdjudicatorRifle.Designation = "Primary"
AdjudicatorRifle.Display_Name = WEAPON_STATS.name
AdjudicatorRifle.desc = WEAPON_STATS.desc
AdjudicatorRifle.icon = WEAPON_STATS.icon
AdjudicatorRifle.damage = WEAPON_STATS.damage
AdjudicatorRifle.range = WEAPON_STATS.range
AdjudicatorRifle.range_damage = WEAPON_STATS.range_damage
AdjudicatorRifle.far = WEAPON_STATS.far
AdjudicatorRifle.far_damage = WEAPON_STATS.far_damage
AdjudicatorRifle.accuracy = WEAPON_STATS.accuracy
AdjudicatorRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
AdjudicatorRifle.fire_rate = WEAPON_STATS.fire_rate
AdjudicatorRifle.recoil = WEAPON_STATS.recoil
AdjudicatorRifle.recoil_count = WEAPON_STATS.recoil_count
AdjudicatorRifle.capacity = WEAPON_STATS.capacity
AdjudicatorRifle.ammo_give = WEAPON_STATS.ammo_give
AdjudicatorRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
AdjudicatorRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
AdjudicatorRifle.pen = WEAPON_STATS.pen

-- Authored mount data from weapon_modules.rsc (including inherited values).
AdjudicatorRifle.AuthoredWelds = {
	equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	lefthand = true,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-0.950378418, 0.100975513, 0.597045898, 0, 1, 0, -1, 0, 0, 0, 0, 1),
	holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	alt_holsterc0 = CFrame.new(-0.00793457031, 0.0137820244, 0.597045898, 0, -1, 0, -1, 0, 0, 0, 0, -1),
	alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

return AdjudicatorRifle
