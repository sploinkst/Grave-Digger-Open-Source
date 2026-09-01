--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local CrestfallRifle = require(script.Parent.CrestfallRifle)
local createAnimationResolver = require(script.Parent.AnimationResolver)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local rifleFallback = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local legacyAnimations = Assets.Animations.Tools.Guns:FindFirstChild("rsc")
local animation = createAnimationResolver("rsc_rig", legacyAnimations, rifleFallback)
local assetSounds = Assets:FindFirstChild("Sounds")
local toolSounds = assetSounds and assetSounds:FindFirstChild("tools")
local SoundFolder = (toolSounds and toolSounds:FindFirstChild("rsc"))
	or GunAssets.Sounds:FindFirstChild("rsc")
	or GunAssets.Sounds.PrinceRifle

local CLIP_SIZE = 5
local STANDARD_RPM = 127
local BLACK_HAND_RPM = 136
local STANDARD_RELOAD_TIME = 3.6
local VETERAN_RELOAD_TIME = 2.5
local STANDARD_FAILED_RELOAD_TIME = 4.25
local VETERAN_FAILED_RELOAD_TIME = 3
local BOLT_CATCH_FAILURE_CHANCE = 0.4

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
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
		C1 = CFrame.identity,
		ReloadGripC0 = CFrame.new(0.254, -1.703, -0.566)
			* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Hold = animation({ "locked" }, "PrinceRifle_Held"),
		Draw = animation({ "draw" }, "PrinceRifle_Draw"),
		Unequip = animation({ "unequip" }, "PrinceRifle_Unequip"),
		Aim = animation({ "aim" }, "PrinceRifle_Aim"),
		Aim_Left = animation({ "aim_left" }, "PrinceRifle_Aim_Left"),
		Fire = animation({ "fire" }, "PrinceRifle_Fire"),
		Fire_Left = animation({ "fire_left" }, "PrinceRifle_Fire_Left"),
		Hip_Hold = animation({ "locked" }, "PrinceRifle_Held"),
		Hip_Aim = animation({ "alt_changeaim" }, "PrinceRifle_Aim"),
		Hip_Aim_Left = animation({ "alt_changeaim_left" }, "PrinceRifle_Aim_Left"),
		Hip_Fire = animation({ "alt_changefire" }, "PrinceRifle_Fire"),
		Hip_Fire_Left = animation({ "alt_changefire_left" }, "PrinceRifle_Fire_Left"),
		Reload_Start = animation({ veteran and "reload_start_vet" or "reload_start" }, "PrinceRifle_Reload_Start"),
		Reload_End = animation({ "reload_end" }, "PrinceRifle_Reload_End"),
		Reload_End_Locked = animation({ "reload_end_locked" }, "PrinceRifle_Reload_End"),
		Check = animation({ "check" }, "PrinceRifle_Check"),
		Melee1 = animation("Melee1", "PrinceRifle_Melee1"),
		Melee2 = animation("Melee2", "PrinceRifle_Melee2"),
		Short = animation("Short", "PrinceRifle_Short"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}

	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.65 or 0.8),
		Aim = 1 / (blackHand and 0.34 or 0.4),
		Aim_Left = 1 / (blackHand and 0.34 or 0.4),
		Hip_Aim = 1 / (blackHand and 0.26 or 0.3),
		Hip_Aim_Left = 1 / (blackHand and 0.26 or 0.3),
	}

	self.damage = 140
	self.Max_Capacity = veteran and 6 or 5
	self.Capacity = self.Max_Capacity
	self.Starting_Reserve_Ammo = 15
	self.Max_Reserve_Ammo = 20
	self.Ammo_Type = "8mm Gras"
	self.Penetration_Level = 2
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force = 10
	self.recoil = 55
	self.recoil_count = 7
	self.Aiming_Number = 80
	self.Accuracy = 5
	self.Moving_Accuracy = 65
	self.HipBraceAccuracy = 12
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireInterval = 60 / (blackHand and BLACK_HAND_RPM or STANDARD_RPM)
	self.IsVeteran = veteran
	self.HipBraced = false

	return self
end

function AdjudicatorRifle:_damageAtDistance(distance: number): number
	if distance < 50 then return 140 end
	if distance <= 70 then return 105 end
	return 80
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

	if self.Aiming then self:endAiming() end
	self.Reloading = true
	self:_setGripArm("Left Arm")
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
	self:_setGripArm("Right Arm")
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

AdjudicatorRifle.Tool_Image = "rbxassetid://17496049645"
AdjudicatorRifle.Medal_Cost = 0
AdjudicatorRifle.Weight = 2
AdjudicatorRifle.Designation = "Primary"

return AdjudicatorRifle
