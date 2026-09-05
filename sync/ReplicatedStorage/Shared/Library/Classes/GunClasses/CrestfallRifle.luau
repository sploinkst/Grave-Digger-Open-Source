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
local animation, loadAnimations = createAnimationResolver("lever")
local crestfallSounds = GunAssets.Sounds:FindFirstChild("lever") or GunAssets.Sounds:FindFirstChild("CrestfallRifle")
local SoundFolder = crestfallSounds or GunAssets.Sounds.CrestfallRifle

local FIRE_INTERVAL = 60 / 86
local BULLET_SPEED = 900
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
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "lever"
	self.animations = loadAnimations({
		Hip_Hold = animation({ "locked" }, "locked"),
		Hip_Aim = animation({ "alt_changeaim" }, "alt_changeaim"),
		Hip_Aim_Left = animation({ "alt_changeaim_left" }, "alt_changeaim_left"),
		Hip_Fire = animation({ "alt_changefire" }, "alt_changefire"),
		Hip_Fire_Left = animation({ "alt_changefire_left" }, "alt_changefire_left"),
		Hip_Fire_Empty = animation({ "alt_changefire_empty" }, "alt_changefire_empty"),
		Hip_Fire_Empty_Left = animation({ "alt_changefire_empty_left" }, "alt_changefire_empty_left"),
		Hip_Fire_Last = animation({ "alt_changefire_last" }, "alt_changefire_last"),
		Hip_Fire_Last_Left = animation({ "alt_changefire_last_left" }, "alt_changefire_last_left"),
		Reload_Empty_Vet_Old = animation({ "reload_empty_vetOLD", "reload_empty_vet_old" }, "reload_empty_vetOLD"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	})

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

function Crestfall:_aimTrack(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Aim
			or self.RegisteredAnimations.Hip_Aim_Left
	end
	return BaseRifle._aimTrack(self)
end

function Crestfall:_killAimTracks()
	BaseRifle._killAimTracks(self)
	local anims = self.RegisteredAnimations
	if not anims then return end
	for _, name in ipairs({ "Hip_Aim", "Hip_Aim_Left" }) do
		local track = anims[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

-- Use the shared held pose outside ADS, including alternate firing modes.

function Crestfall:_getFireAnim(): AnimationTrack?
	if self.HipBraced and self.RegisteredAnimations then
		return (self.current_shoulder == "Right")
			and self.RegisteredAnimations.Hip_Fire
			or self.RegisteredAnimations.Hip_Fire_Left
	end
	return BaseRifle._getFireAnim(self)
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
	if self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return end
	if self.Capacity <= 0 then
		local left = self.current_shoulder ~= "Right"
		local emptyAnimation
		if self.HipBraced then
			emptyAnimation = left and "Hip_Fire_Empty_Left" or "Hip_Fire_Empty"
		else
			emptyAnimation = left and "Fire_Empty_Left" or "Fire_Empty"
		end
		self:_playFireAnimation(emptyAnimation, false)
		return
	end

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
	local left = self.current_shoulder ~= "Right"
	local fireAnimation
	if self.HipBraced then
		if self.Capacity == 0 then
			fireAnimation = left and "Hip_Fire_Last_Left" or "Hip_Fire_Last"
		else
			fireAnimation = left and "Hip_Fire_Left" or "Hip_Fire"
		end
	else
		if self.Capacity == 0 then
			fireAnimation = left and "Fire_Last_Left" or "Fire_Last"
		else
			fireAnimation = left and "Fire_Left" or "Fire"
		end
	end
	self:_playFireAnimation(fireAnimation)
	local fireSound = self.SoundFolder and self.SoundFolder:FindFirstChild("fire")
	if fireSound then self:_play_sfx(fireSound, muzzle) end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)

	self.Cycling = true
	local cycleTrack = self.RegisteredAnimations
		and self.RegisteredAnimations.Cycle
		and self:_playAnim("Cycle")
	local fireInterval = self.FireInterval or FIRE_INTERVAL
	if cycleTrack then cycleTrack:AdjustSpeed(math.max(cycleTrack.Length / fireInterval, 0.01)) end
	task.wait(fireInterval)
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

	if not self._reloadCancelled and self.RegisteredAnimations.Reload_End then
		local endTrack = self:_playAnim("Reload_End")
		if endTrack then endTrack.Stopped:Wait() end
	end
	self.Reloading = false
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
