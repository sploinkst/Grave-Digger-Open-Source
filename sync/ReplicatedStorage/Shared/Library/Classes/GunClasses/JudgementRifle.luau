--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)
local Util = require(script.Parent.Parent.Parent.Util)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects

local judgementAnimations = Assets.Animations.Tools.Guns:FindFirstChild("henry")
	or Assets.Animations.Tools.Guns:FindFirstChild("JudgementRifle")
	or Assets.Animations.Tools.Guns:FindFirstChild("Judgement")
	or Assets.Animations.Tools.Guns:FindFirstChild("lever")
local fallbackAnimations = Assets.Animations.Tools.Guns.PrinceRifle
local judgementSounds = GunAssets.Sounds:FindFirstChild("henry")
	or GunAssets.Sounds:FindFirstChild("JudgementRifle")
	or GunAssets.Sounds:FindFirstChild("Judgement")
	or GunAssets.Sounds:FindFirstChild("lever")
local SoundFolder = judgementSounds or GunAssets.Sounds.PrinceRifle

local FIRE_INTERVAL = 60 / 80
local BULLET_SPEED = 1000
local RELOAD_ROUND_TIME = 2
local CRESTFALL_GRIP_C0 = CFrame.new(-0.25, -1.45, -0.5)
	* CFrame.Angles(0, math.rad(-90), math.rad(90))
local CRESTFALL_HOLSTER_C0 = CFrame.new(0, 0, -0.65)
	* CFrame.Angles(0, 0, math.rad(90))

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
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

local JudgementRifle = {}
JudgementRifle.__index = JudgementRifle
setmetatable(JudgementRifle, { __index = BaseRifle })

export type JudgementRifle = typeof(setmetatable({} :: any, JudgementRifle))

local function animation(name: string, fallback: string): Animation
	return ((judgementAnimations and judgementAnimations:FindFirstChild(name)) or fallbackAnimations:FindFirstChild(fallback)) :: Animation
end

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("henryHolster")
		or GunAssets.Holsters:FindFirstChild("JudgementRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "JudgementRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "JudgementRifle_Torso"
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

function JudgementRifle.new(info: Types.BaseToolCreateInfo): JudgementRifle
	local self = setmetatable(BaseRifle.new(info), JudgementRifle)

	self.className = "JudgementRifle"
	self.item_image = "rbxthumb://type=Asset&id=14103121270&w=420&h=420"
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("henry")
		or ToolFolder:FindFirstChild("Henry")
		or ToolFolder:FindFirstChild("JudgementRifle")
		or ToolFolder:FindFirstChild("Judgement")
		or ToolFolder:FindFirstChild("lever")
		or ToolFolder:FindFirstChild("Lever")
	self.holster_reference = get_holster_reference(self.model_reference)
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = CRESTFALL_GRIP_C0,
	}

	self.animations = {
		Hold = animation("held", "PrinceRifle_Held"),
		Draw = animation("draw", "PrinceRifle_Draw"),
		Unequip = animation("lever_Unequip", "PrinceRifle_Unequip"),
		Aim = animation("aim", "PrinceRifle_Aim"),
		Aim_Left = animation("aim_left", "PrinceRifle_Aim_Left"),
		Fire = animation("fire", "PrinceRifle_Fire"),
		Fire_Left = animation("fire_left", "PrinceRifle_Fire_Left"),
		Cycle = animation("lever_Cycle", "PrinceRifle_Cycle"),
		Reload_Start = animation("reload_start", "PrinceRifle_Reload_Start"),
		Reload_Loop = animation("reload_start", "PrinceRifle_Reload_Loop"),
		Reload_End = animation("lever_Reload_End", "PrinceRifle_Reload_End"),
		Check = animation("check", "PrinceRifle_Check"),
		Melee1 = animation("melee1", "PrinceRifle_Melee1"),
		Melee2 = animation("melee2", "PrinceRifle_Melee2"),
		Short = animation("short", "PrinceRifle_Short"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}

	self.animation_speeds = {
		Draw = 1 / 1.2,
		Aim = 1 / 0.4,
		Aim_Left = 1 / 0.4,
		Reload_Start = 1 / RELOAD_ROUND_TIME,
	}

	self.damage = 199
	self.Max_Capacity = 1
	self.Capacity = 1
	self.Starting_Reserve_Ammo = 8
	self.Max_Reserve_Ammo = 14
	self.Ammo_Type = ".577 Alloy"
	self.recoil = 80
	self.recoil_count = 10
	self.Penetration_Level = 3
	self.Armor_Penetration_Level = 4
	self.KnockBack_Force = 14
	self.Aiming_Number = 80
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = 7
	self.Melee_Damage = 105
	self.Accuracy = 4
	self.Moving_Accuracy = 65
	self.SoundFolder = SoundFolder

	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
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

function JudgementRifle:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	return BaseRifle.get_spread(self, muzzle, shootDirection)
end

function JudgementRifle:aim()
	BaseRifle.aim(self)
end

function JudgementRifle:endAiming()
	BaseRifle.endAiming(self)
end

function JudgementRifle:setAltMode()
	if self:_isBusy() then return end
	self:melee()
end

function JudgementRifle:_damageAtDistance(distance: number): number
	if distance < 60 then
		return 199
	elseif distance <= 100 then
		return 180
	end
	return 120
end

function JudgementRifle:fire()
	if self.Firing or self.Reloading or self.Cycling or not self.Aiming then return end
	if self.Capacity <= 0 or self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return end

	local muzzle = self:_findModelPart(self.MuzzlePartName)
	local camera = workspace.CurrentCamera
	if not muzzle or not muzzle:IsA("BasePart") or not camera then return end

	self.Firing = true
	local mousePosition = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	local result = Util.raycastSkipTransparent(ray.Origin, ray.Direction * 5000, params)
	local target = result and result.Position or ray.Origin + ray.Direction * 5000
	local direction = self:get_spread(muzzle, (target - muzzle.Position).Unit)
	local cast = self.Caster:Fire(muzzle.Position, direction, BULLET_SPEED, self.CasterBehavior)
	cast.UserData = {
		Direction = direction,
		Penetrated = false,
		Origin = muzzle.Position,
		Shooter = LOCAL_PLAYER,
	}

	self:_connect_FastCast(muzzle.Position, direction, BULLET_SPEED, {
		bulletTemplate = FxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		isPenetration = false,
		penetrationLevel = self.Penetration_Level,
		damage = self.damage,
		knockbackForce = self.KnockBack_Force,
	})

	self.Capacity -= 1
	self:_stopAllExcept()
	self:_playAnim((self.current_shoulder == "Right") and "Fire" or "Fire_Left")
	local fireSound = SoundFolder:FindFirstChild("fire")
	if fireSound then self:_play_sfx(fireSound, muzzle) end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)

	self.Cycling = true
	task.wait(FIRE_INTERVAL)
	self.Cycling = false
	self.Firing = false
	self:_restoreBaseDeferred()
end

function JudgementRifle:reload()
	if self.Reloading or self.Equipping or self.Capacity >= self.Max_Capacity then return end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then
		self:notify("I don't have any more ammo...")
		return
	end

	if self.Aiming then self:endAiming() end
	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()
	local reloadTrack = self:_playAnim("Reload_Start")
	if reloadTrack then reloadTrack.Stopped:Wait() end

	if self.Equipped and reserve.Value > 0 and not self._reloadCancelled then
		self.Capacity += 1
		self:_fire_ammo(1)
	end
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function JudgementRifle:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function JudgementRifle:_on_equip()
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

function JudgementRifle:_on_unequip()
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

function JudgementRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

JudgementRifle.Tool_Image = "rbxassetid://14103121270"
JudgementRifle.Medal_Cost = 0
JudgementRifle.Weight = 2
JudgementRifle.Designation = "Primary"

return JudgementRifle
