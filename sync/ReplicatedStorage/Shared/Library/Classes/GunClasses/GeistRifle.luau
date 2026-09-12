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

local geistAnimations = Assets.Animations.Tools.Guns:FindFirstChild("GeistRifle")
local geistSounds = GunAssets.Sounds:FindFirstChild("GeistRifle") or GunAssets.Sounds:FindFirstChild("lever")
local SoundFolder = geistSounds or GunAssets.Sounds.CrestfallRifle

local FIRE_INTERVAL = 60 / 86
local BULLET_SPEED = 900
local CUT = 0.06
local HIP_BRACE_SWITCH_TIME = 0.33
local RELOAD_ROUND_TIME = 9.56 / 11
local HIP_BRACE_CROSSHAIR_SPREAD = 20
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

local GeistRifle = {}
GeistRifle.__index = GeistRifle
setmetatable(GeistRifle, { __index = BaseRifle })

export type GeistRifle = typeof(setmetatable({} :: any, GeistRifle))

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("GeistRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "GeistRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "GeistRifle_Torso"
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

function GeistRifle.new(info: Types.BaseToolCreateInfo): GeistRifle
	local self = setmetatable(BaseRifle.new(info), GeistRifle)

	self.className = "GeistRifle"
	self.name = "GeistRifle"
	self.item_image = GeistRifle.Tool_Image
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
		Draw = geistAnimations.Parent.PrinceRifle.PrinceRifle_Draw,
		Hold = geistAnimations.held,
		Unequip = geistAnimations.Parent.PrinceRifle.PrinceRifle_Unequip,

		Aim      = geistAnimations.aim,
		Aim_Left = geistAnimations.aim_left,

		Fire      = geistAnimations.fire,
		Fire_Left = geistAnimations.fire_left,

		Reload_Empty = geistAnimations.reload_empty,
		Reload_Start = geistAnimations.reload_start,
		Reload_Loop  = geistAnimations.reload_loop,

		Check  = geistAnimations.check,
		Melee1 = geistAnimations.Parent.PrinceRifle.PrinceRifle_Melee1,
		Melee2 = geistAnimations.Parent.PrinceRifle.PrinceRifle_Melee2,

		Drop  = geistAnimations.Parent.Parent.Misc.Drop_Rifle,
		Short = geistAnimations.Parent.PrinceRifle.PrinceRifle_Short,

		Hip_Hold = geistAnimations.locked,
		Hip_Aim = geistAnimations.alt_changeaim,
		Hip_Aim_Left = geistAnimations.alt_changeaim_left,
		Hip_Fire = geistAnimations.alt_changefire,
		Hip_Fire_Left = geistAnimations.alt_changeaim_left,
		Hip_Fire_Empty = geistAnimations.alt_changefire_empty,
		Hip_Fire_Empty_Left = geistAnimations.alt_changefire_empty_left,
		Hip_Fire_Last = geistAnimations.alt_changefire_last,
		Hip_Fire_Last_Left = geistAnimations.alt_changefire_last_left,
		Reload_Empty_Vet_Old = geistAnimations.reload_empty_vet,
	}

	self.animation_speeds = {
		Draw = 1 / 0.75,
		Aim = 1 / 0.275,
		Aim_Left = 1 / 0.275,
		Reload_Loop = 1 / RELOAD_ROUND_TIME,
	}

	self.damage = 120
	self.range = 70
	self.range_damage = 90
	self.far = 100
	self.far_damage = 75
	self.Max_Capacity = 11
	self.Capacity = 11
	self.Starting_Reserve_Ammo = 11
	self.Max_Reserve_Ammo = 33
	self.Ammo_Type = ".44 Army"
	self.recoil = 68
	self.recoil_count = 8
	self.Penetration_Level = 2
	self.Armor_Penetration_Level = 2
	self.KnockBack_Force = 10
	self.Aiming_Number = 75
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = BULLET_SPEED
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = 5
	self.Melee_Damage = 80
	self.Accuracy = 5
	self.Moving_Accuracy = 65
	self.HipBraceAccuracy = self.Accuracy * 1.3
	self.SoundFolder = SoundFolder

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
	return self
end

function GeistRifle:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if not self.HipBraced then
		return BaseRifle.get_spread(self, muzzle, shootDirection)
	end

	local spread = self.HipBraceAccuracy
	local random = Random.new()
	local horizontal = random:NextNumber(-spread, spread) / 1000
	local vertical = random:NextNumber(-spread, spread) / 1000
	return (shootDirection + muzzle.CFrame.RightVector * horizontal + muzzle.CFrame.UpVector * vertical).Unit
end

function GeistRifle:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeAim = humanoid.WalkSpeed end
	self.FixedAimingSpread = self.HipBraced and HIP_BRACE_CROSSHAIR_SPREAD or nil

	BaseRifle.aim(self)
	if humanoid and self.Aiming and not self.HipBraced then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim * 0.7
	end
end

function GeistRifle:endAiming()
	BaseRifle.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeAim then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim
	end
	self._walkSpeedBeforeAim = nil
	self.FixedAimingSpread = nil
end

function GeistRifle:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	task.wait(HIP_BRACE_SWITCH_TIME)
	if not self.Equipped then
		self.Alting = false
		return
	end
	self.HipBraced = not self.HipBraced
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

function GeistRifle:_aimTrack(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Aim
			or self.RegisteredAnimations.Hip_Aim_Left
	end
	return BaseRifle._aimTrack(self)
end

function GeistRifle:_killAimTracks()
	BaseRifle._killAimTracks(self)
	local anims = self.RegisteredAnimations
	if not anims then return end
	for _, name in ipairs({ "Hip_Aim", "Hip_Aim_Left" }) do
		local track = anims[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

-- Use the shared held pose outside ADS, including alternate firing modes.

function GeistRifle:_getFireAnim(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Fire
			or self.RegisteredAnimations.Hip_Fire_Left
	end
	return BaseRifle._getFireAnim(self)
end

function GeistRifle:_damageAtDistance(distance: number): number
	return BaseRifle._damageAtDistance(self, distance)
end

function GeistRifle:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation
	if self.HipBraced then
		if self.Capacity <= 1 then
			fireAnimation = left and "Hip_Fire_Last_Left" or "Hip_Fire_Last"
		else
			fireAnimation = left and "Hip_Fire_Left" or "Hip_Fire"
		end
	else
		if self.Capacity <= 1 then
			fireAnimation = left and "Fire_Last_Left" or "Fire_Last"
		else
			fireAnimation = left and "Fire_Left" or "Fire"
		end
	end
	local fireSound = self.SoundFolder and self.SoundFolder:FindFirstChild("fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = fireAnimation,
		sound = fireSound,
	})
	if not fired then return end

	self.Cycling = true
	local cycleTrack = self.RegisteredAnimations
		and self.RegisteredAnimations.Cycle
		and self:_playAnim("Cycle")
	local fireInterval = self.FireInterval or FIRE_INTERVAL
	local effectiveInterval = self:getFireDelay(fireInterval)
	if cycleTrack then cycleTrack:AdjustSpeed(math.max(cycleTrack.Length / effectiveInterval, 0.01)) end
	task.wait(effectiveInterval)
	self.Cycling = false
	self:_restoreBaseDeferred()
end

function GeistRifle:reload()
	self:_reloadByRound({
		startAnim = "Reload_Start",
		loopAnim = "Reload_Loop",
		endAnim = "Reload_End",
	})
end

function GeistRifle:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function GeistRifle:_on_equip()
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

function GeistRifle:_on_unequip()
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

function GeistRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

GeistRifle.Tool_Image = "rbxthumb://type=Asset&id=118811623120292&w=420&h=420"
GeistRifle.Medal_Cost = 0
GeistRifle.Weight = 2
GeistRifle.Designation = "Primary"

return GeistRifle
