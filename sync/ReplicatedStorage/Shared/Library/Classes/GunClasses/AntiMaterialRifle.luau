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

local antimaterialAnimations = Assets.Animations.Tools.Guns:FindFirstChild("AntiMaterialRifle")
local SoundFolder = GunAssets.Sounds:WaitForChild("AntiMaterialRifle")

local FIRE_INTERVAL = 0.5
local BULLET_SPEED = 1400
local CYCLE_TIME = 1.2
local CYCLE_REST_TIME = 0.3
local HIP_BRACE_SWITCH_TIME = 0.33
local STANDARD_FULL_RELOAD_TIME = 5.75
local ROOK_FULL_RELOAD_TIME = 4.6
local HIP_BRACE_CROSSHAIR_SPREAD = 20
local ANTIMATERIAL_HOLSTER_C0 = CFrame.new(0, 0, -0.65)
	* CFrame.Angles(0, 0, math.rad(90))

local WEAPON_STATS = {
	damage = 500,
	range = 60,
	range_damage = 250,
	far = 80,
	far_damage = 199,
	capacity = 6,
	ammo_give = ".50 Remover",
	recoil = 120,
	recoil_count = 14,
	pen = 3,
	armor_pen = 5,
	knockback = 25,
	aiming_number = 80,
	bullet_speed = BULLET_SPEED,
	fire_rate = FIRE_INTERVAL,
	cycle = CYCLE_TIME,
	cycle_rest = CYCLE_REST_TIME,
	post_cycle_delay = CYCLE_REST_TIME,
	post_reload_delay = 0.15,
	melee_damage = 105,
	melee_range = 5,
	accuracy = 2,
	moving_accuracy = 75,
}

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Reload_Bolt = 1,
	Draw = 2,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
	Melee2 = 2,
	Short = 2,
	Sprint = 2,
}

local Antimaterial = {}
Antimaterial.__index = Antimaterial
setmetatable(Antimaterial, { __index = BaseRifle })

export type Antimaterial = typeof(setmetatable({} :: any, Antimaterial))

local function animation(folder: Instance?, names: { string }): Animation?
	if not folder then return nil end
	for _, name in ipairs(names) do
		local candidate = folder:FindFirstChild(name)
		if candidate and candidate:IsA("Animation") then
			return candidate
		end
	end
	return nil
end

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("AntiMaterialRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "AntiMaterialRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "AntiMaterialRifle_Torso"
	holster.PrimaryPart = hitbox
	holster:SetAttribute("HolsterC0", ANTIMATERIAL_HOLSTER_C0)
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

function Antimaterial.new(info: Types.BaseToolCreateInfo): Antimaterial
	local self = setmetatable(BaseRifle.new(info), Antimaterial)
	local isRook = LOCAL_PLAYER and LOCAL_PLAYER.Character
		and LOCAL_PLAYER.Character:GetAttribute("Class") == "Rook"

	self.className = "AntiMaterialRifle"
	self.item_image = Antimaterial.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("pugsley")
	self.holster_reference = get_holster_reference(self.model_reference)
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "AntiMaterialRifle"
	self.animations = {
		Draw = animation(antimaterialAnimations, { "draw", "Draw" }),
		Hold = animation(antimaterialAnimations, { "held", "Hold" }),

		Aim      = animation(antimaterialAnimations, { "aim", "Aim" }),
		Aim_Left = animation(antimaterialAnimations, { "aim_left", "Aim_Left" }),

		Fire      = animation(antimaterialAnimations, { "fire", "Fire" }),
		Fire_Left = animation(antimaterialAnimations, { "fire_left", "Fire_Left" }),

		Cycle = animation(antimaterialAnimations, { "cycle" }),
		Reload_Bolt = animation(antimaterialAnimations, { "reload_bolt" }),

		Reload_Start = animation(antimaterialAnimations, { "reload_start" }),
		Reload_Loop  = animation(antimaterialAnimations, { "reload_loop" }),
		Reload_End = animation(antimaterialAnimations, { "reload_end" }),

		Check  = animation(antimaterialAnimations, { "check" }),
		Melee2 = animation(antimaterialAnimations, { "melee2" }),

		Short = animation(antimaterialAnimations, { "short" }),
		Sprint = animation(antimaterialAnimations, { "sprint" }),
	}

	self.animation_speeds = {
		Draw = 1 / 1.3,
		Aim = 1 / 0.5,
		Aim_Left = 1 / 0.5,
	}

	self.damage = WEAPON_STATS.damage
	self.range = WEAPON_STATS.range
	self.range_damage = WEAPON_STATS.range_damage
	self.far = WEAPON_STATS.far
	self.far_damage = WEAPON_STATS.far_damage
	self.Max_Capacity = WEAPON_STATS.capacity -- 5+1 chambered rounds
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = 20000
	self.Max_Reserve_Ammo = 20000
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.armor_pen
	self.KnockBack_Force = WEAPON_STATS.knockback
	self.Aiming_Number = WEAPON_STATS.aiming_number
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = WEAPON_STATS.bullet_speed
	self.FireSound = SoundFolder:FindFirstChild("fire", true)
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = WEAPON_STATS.melee_range
	self.Melee_Damage = WEAPON_STATS.melee_damage
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.HipBraceAccuracy = self.Accuracy * 1.3
	self.SoundFolder = SoundFolder

	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self.HipBraced = false
	self.FireInterval = WEAPON_STATS.fire_rate / (isRook and 1.075 or 1)
	self.CycleTime = WEAPON_STATS.cycle * (isRook and 0.85 or 1)
	self.CycleRestTime = WEAPON_STATS.cycle_rest
	self.FullReloadTime = isRook and ROOK_FULL_RELOAD_TIME or STANDARD_FULL_RELOAD_TIME
	self.IsRook = isRook
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

function Antimaterial:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if not self.HipBraced then
		return BaseRifle.get_spread(self, muzzle, shootDirection)
	end

	local spread = self.HipBraceAccuracy
	local random = Random.new()
	local horizontal = random:NextNumber(-spread, spread) / 1000
	local vertical = random:NextNumber(-spread, spread) / 1000
	return (shootDirection + muzzle.CFrame.RightVector * horizontal + muzzle.CFrame.UpVector * vertical).Unit
end

function Antimaterial:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeAim = humanoid.WalkSpeed end
	self.FixedAimingSpread = self.HipBraced and HIP_BRACE_CROSSHAIR_SPREAD or nil

	BaseRifle.aim(self)
	if humanoid and self.Aiming and not self.HipBraced then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim * 0.7
	end
end

function Antimaterial:endAiming()
	BaseRifle.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeAim then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim
	end
	self._walkSpeedBeforeAim = nil
	self.FixedAimingSpread = nil
end

function Antimaterial:_aimTrack(): AnimationTrack?
	return BaseRifle._aimTrack(self)
end

function Antimaterial:_killAimTracks()
	BaseRifle._killAimTracks(self)
end

-- Use the shared held pose outside ADS, including alternate firing modes.

function Antimaterial:_getFireAnim(): AnimationTrack?
	return BaseRifle._getFireAnim(self)
end

function Antimaterial:_damageAtDistance(distance: number): number
	return BaseRifle._damageAtDistance(self, distance)
end

function Antimaterial:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation = left and "Fire_Left" or "Fire"
	local fireSound = self.SoundFolder and self.SoundFolder:FindFirstChild("fire", true)
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = fireAnimation,
		sound = fireSound,
		fireDelay = 0,
	})
	if not fired then return end

	self.Cycling = true
	local cycleTrack = self.RegisteredAnimations
		and self.RegisteredAnimations.Cycle
		and self:_playAnim("Cycle")
	local cycleTime = self.CycleTime or CYCLE_TIME
	if cycleTrack then cycleTrack:AdjustSpeed(math.max(cycleTrack.Length / cycleTime, 0.01)) end
	task.wait(cycleTime + (self.PostCycleDelay or self.CycleRestTime or CYCLE_REST_TIME))
	self.Cycling = false
	self:_restoreBaseDeferred()
end

function Antimaterial:reload()
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

	local roundsNeeded = math.min(self.Max_Capacity - self.Capacity, reserveAmmo.Value)
	if roundsNeeded <= 0 then return end

	local animations = self.RegisteredAnimations
	local startTrack = animations and animations.Reload_Start
	local loopTrack = animations and animations.Reload_Loop
	local endTrack = animations and animations.Reload_End
	local authoredLength = (startTrack and startTrack.Length or 0)
		+ (loopTrack and loopTrack.Length or 0) * roundsNeeded
		+ (endTrack and endTrack.Length or 0)
	local targetDuration = (self.FullReloadTime or STANDARD_FULL_RELOAD_TIME) * (roundsNeeded / self.Max_Capacity)
	local speed = authoredLength > 0 and authoredLength / math.max(targetDuration, 0.1) or 1

	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	if startTrack then
		local track = self:_playAnim("Reload_Start")
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end

	for _ = 1, roundsNeeded do
		if not self.Equipped or self._reloadCancelled or reserveAmmo.Value <= 0 then break end
		if loopTrack then
			local track = self:_playAnim("Reload_Loop")
			if track then
				track:AdjustSpeed(speed)
				track.Stopped:Wait()
			end
		else
			task.wait(targetDuration / math.max(roundsNeeded, 1))
		end
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
	end

	if self.Equipped and not self._reloadCancelled and endTrack then
		local track = self:_playAnim("Reload_End")
		if track then
			track:AdjustSpeed(speed)
			track.Stopped:Wait()
		end
	end

	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_blockFireFor(self.PostReloadDelay or 0)
	self:_restoreBaseDeferred()
end

function Antimaterial:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function Antimaterial:_on_equip()
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

function Antimaterial:_on_unequip()
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

function Antimaterial:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

Antimaterial.Tool_Image = "rbxthumb://type=Asset&id=118811623120292&w=420&h=420"
Antimaterial.Medal_Cost = 0
Antimaterial.Weight = 2
Antimaterial.Designation = "Primary"

return Antimaterial
