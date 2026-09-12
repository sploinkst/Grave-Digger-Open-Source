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
local rifleFallback = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local Animations = Assets.Animations.Tools.Guns.AdjudicatorRifle

local assetSounds = Assets:FindFirstChild("Sounds")
local toolSounds = assetSounds and assetSounds:FindFirstChild("tools")
local SoundFolder = (toolSounds and toolSounds:FindFirstChild("rsc"))
	or GunAssets.Sounds:FindFirstChild("rsc") or GunAssets.Sounds:FindFirstChild("AdjudicatorRifle")
	or GunAssets.Sounds.PrinceRifle

local CLIP_SIZE = 5
local STANDARD_RPM = 127
local BLACK_HAND_RPM = 136
local STANDARD_RELOAD_TIME = 3.6
local VETERAN_RELOAD_TIME = 2.5
local STANDARD_FAILED_RELOAD_TIME = 4.25
local VETERAN_FAILED_RELOAD_TIME = 3
local BOLT_CATCH_FAILURE_CHANCE = 0.4
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
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_End = 2,
	Reload_End_Locked = 2,
	Check = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
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
	local animations = self.RegisteredAnimations
	local startTrack = animations and animations.Reload_Start
	local endTrack = animations and animations[endingName]
	local authoredLength = (startTrack and startTrack.Length or 0) + (endTrack and endTrack.Length or 0)
	local speed = if authoredLength > 0 then authoredLength / duration else 1

	if startTrack then
		local track = self:_playAnim("Reload_Start")
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end
	if self.Equipped and not self._reloadCancelled and endTrack then
		local track = self:_playAnim(endingName)
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end
end

function AdjudicatorRifle.new(info: Types.BaseToolCreateInfo): AdjudicatorRifle
	local self = setmetatable(CrestfallRifle.new(info), AdjudicatorRifle)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand") or hasPerk("BlackHand")

	self.className = "AdjudicatorRifle"
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

	self.AnimationGunType = "rsc"
	self.animations = {
		Hold = Animations.Parent.PrinceRifle.PrinceRifle_Held,
		Draw = Animations.Parent.PrinceRifle.PrinceRifle_Draw,
		Unequip = Animations.Parent.PrinceRifle.PrinceRifle_Unequip,
		Aim = Animations.aim,
		Aim_Left = Animations.aim_left,
		Fire = Animations.fire,
		Fire_Left = Animations.fire_left,
		Hip_Hold = Animations.locked,
		Hip_Aim = Animations.alt_changeaim,
		Hip_Aim_Left = Animations.aim_left,
		Hip_Fire = Animations.alt_changefire,
		Hip_Fire_Left = Animations.alt_changefire_left,
		Reload_Start = veteran and Animations.reload_start_vet or Animations.reload_start,
		Reload_End = Animations.reload_end,
		Reload_End_Locked = Animations.reload_end_locked,
		Check = Animations.check,
		Melee1 = Animations.Parent.PrinceRifle.PrinceRifle_Melee1,
		Melee2 = Animations.Parent.PrinceRifle.PrinceRifle_Melee2,
		Short = Animations.Parent.PrinceRifle.PrinceRifle_Short,
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}

	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.65 or WEAPON_STATS.draw_speed),
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
	self.IsVeteran = veteran
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
	CrestfallRifle.setAltMode(self)
end

function AdjudicatorRifle:reload()
	if self.Reloading or self.Equipping or self.Capacity >= self.Max_Capacity then return end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value < CLIP_SIZE then
		self:notify("I need a full clip to reload...")
		return
	end
	if self.Max_Capacity - self.Capacity < CLIP_SIZE then
		self:notify("There is no room for a full clip...")
		return
	end

	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	local boltCatchFailed = math.random() < BOLT_CATCH_FAILURE_CHANCE
	local duration = if boltCatchFailed
		then (self.IsVeteran and VETERAN_FAILED_RELOAD_TIME or STANDARD_FAILED_RELOAD_TIME)
		else (self.IsVeteran and VETERAN_RELOAD_TIME or STANDARD_RELOAD_TIME)
	playReloadSequence(self, boltCatchFailed and "Reload_End_Locked" or "Reload_End", duration)

	if self.Equipped and not self._reloadCancelled then
		self.Capacity += CLIP_SIZE
		self:_fire_ammo(CLIP_SIZE)
	end
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function AdjudicatorRifle:_on_equip()
	CrestfallRifle._on_equip(self)
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
			elseif keyframe == "vfx_eject_casing" or keyframe == "vfx_rsc_eject_casing" then
				local casing = model:FindFirstChild("ejection", true)
				if casing and casing:IsA("BasePart") then
					self:emit_casing(casing :: any, casing.CFrame, casing.CFrame.RightVector * 5)
				end
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

return AdjudicatorRifle
