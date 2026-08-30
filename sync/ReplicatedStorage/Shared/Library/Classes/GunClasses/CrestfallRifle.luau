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
local createAnimationResolver = require(script.Parent.AnimationResolver)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects

local crestfallAnimations = Assets.Animations.Tools.Guns:FindFirstChild("lever")
local fallbackAnimations = Assets.Animations.Tools.Guns.PrinceRifle
local animation = createAnimationResolver("lever_rig", crestfallAnimations, fallbackAnimations)
local crestfallSounds = GunAssets.Sounds:FindFirstChild("lever")
local SoundFolder = crestfallSounds or GunAssets.Sounds.PrinceRifle

local FIRE_INTERVAL = 60 / 86
local BULLET_SPEED = 900
local HIP_BRACE_SWITCH_TIME = 0.33
local RELOAD_ROUND_TIME = 9.56 / 11
local HIP_BRACE_CROSSHAIR_SPREAD = 20
local CRESTFALL_GRIP_C0 = CFrame.new(0, -1, 0)
	* CFrame.Angles(0, math.rad(-90), math.rad(90))
local RELOAD_GRIP_C0 = CFrame.new(0.254, -1.703, -0.566)
	* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90))
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

local Crestfall = {}
Crestfall.__index = Crestfall
setmetatable(Crestfall, { __index = BaseRifle })

export type Crestfall = typeof(setmetatable({} :: any, Crestfall))

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("CrestfallRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "CrestfallRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "CrestfallRifle_Torso"
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

function Crestfall.new(info: Types.BaseToolCreateInfo): Crestfall
	local self = setmetatable(BaseRifle.new(info), Crestfall)

	self.className = "CrestfallRifle"
	self.item_image = "rbxthumb://type=Asset&id=14103121270&w=420&h=420"
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("lever") or ToolFolder:FindFirstChild("Lever")
	self.holster_reference = get_holster_reference(self.model_reference)
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = CRESTFALL_GRIP_C0,
		C1 = CFrame.identity,
		ReloadGripC0 = RELOAD_GRIP_C0,
	}

	self.animations = {
		Hold = animation("Hold", "PrinceRifle_Held"),
		Draw = animation("Draw", "PrinceRifle_Draw"),
		Unequip = animation("Unequip", "PrinceRifle_Unequip"),
		Aim = animation("Aim", "PrinceRifle_Aim"),
		Aim_Left = animation("Aim_Left", "PrinceRifle_Aim_Left"),
		Fire = animation("Fire", "PrinceRifle_Fire"),
		Fire_Left = animation("Fire_Left", "PrinceRifle_Fire_Left"),
		Cycle = animation("Cycle", "PrinceRifle_Cycle"),
		Reload_Start = animation("Reload_Start", "PrinceRifle_Reload_Start"),
		Reload_Loop = animation("Reload_Loop", "PrinceRifle_Reload_Loop"),
		Reload_End = animation("Reload_End", "PrinceRifle_Reload_End"),
		Check = animation("Check", "PrinceRifle_Check"),
		Melee1 = animation("Melee1", "PrinceRifle_Melee1"),
		Melee2 = animation("Melee2", "PrinceRifle_Melee2"),
		Short = animation("Short", "PrinceRifle_Short"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}

	self.animation_speeds = {
		Draw = 1 / 0.75,
		Aim = 1 / 0.275,
		Aim_Left = 1 / 0.275,
		Reload_Loop = 1 / RELOAD_ROUND_TIME,
	}

	self.damage = 120
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

function Crestfall:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if not self.HipBraced then
		return BaseRifle.get_spread(self, muzzle, shootDirection)
	end

	local spread = self.HipBraceAccuracy
	local random = Random.new()
	local horizontal = random:NextNumber(-spread, spread) / 1000
	local vertical = random:NextNumber(-spread, spread) / 1000
	return (shootDirection + muzzle.CFrame.RightVector * horizontal + muzzle.CFrame.UpVector * vertical).Unit
end

function Crestfall:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeAim = humanoid.WalkSpeed end
	self.FixedAimingSpread = self.HipBraced and HIP_BRACE_CROSSHAIR_SPREAD or nil

	BaseRifle.aim(self)
	if humanoid and self.Aiming and not self.HipBraced then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim * 0.7
	end
end

function Crestfall:endAiming()
	BaseRifle.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeAim then
		humanoid.WalkSpeed = self._walkSpeedBeforeAim
	end
	self._walkSpeedBeforeAim = nil
	self.FixedAimingSpread = nil
end

function Crestfall:setAltMode()
	if self:_isBusy() then return end
	self.Alting = true
	task.wait(HIP_BRACE_SWITCH_TIME)
	self.HipBraced = not self.HipBraced

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

function Crestfall:_damageAtDistance(distance: number): number
	if distance < 70 then
		return 120
	elseif distance <= 100 then
		return 90
	end
	return 75
end

function Crestfall:fire()
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
	local cycleTrack = self:_playAnim("Cycle")
	if cycleTrack then cycleTrack:AdjustSpeed(math.max(cycleTrack.Length / FIRE_INTERVAL, 0.01)) end
	task.wait(FIRE_INTERVAL)
	self.Cycling = false
	self.Firing = false
	self:_restoreBaseDeferred()
end

function Crestfall:reload()
	if self.Reloading or self.Equipping or self.Capacity >= self.Max_Capacity then return end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then
		self:notify("I don't have any more ammo...")
		return
	end

	if self.Aiming then self:endAiming() end
	self.Reloading = true
	self:_setGripArm("Left Arm")
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()
	self:_playAnim("Reload_Start").Stopped:Wait()

	while self.Equipped and self.Capacity < self.Max_Capacity and reserve.Value > 0 and not self._reloadCancelled do
		self:_playAnim("Reload_Loop").Stopped:Wait()
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
	end

	if not self._reloadCancelled then self:_playAnim("Reload_End").Stopped:Wait() end
	self.Reloading = false
	self:_setGripArm("Right Arm")
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function Crestfall:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function Crestfall:_on_equip()
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

function Crestfall:_on_unequip()
	self:_setGripArm("Right Arm")
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

function Crestfall:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

Crestfall.Tool_Image = "rbxthumb://type=Asset&id=14103121270&w=420&h=420"
Crestfall.Medal_Cost = 0
Crestfall.Weight = 2
Crestfall.Designation = "Primary"

return Crestfall
