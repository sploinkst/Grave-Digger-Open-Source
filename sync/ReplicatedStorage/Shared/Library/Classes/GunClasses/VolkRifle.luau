--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

local volkAnimations = Assets.Animations.Tools.Guns:FindFirstChild("mosin_rig")
	or Assets.Animations.Tools.Guns:FindFirstChild("mosin")
	or Assets.Animations.Tools.Guns:FindFirstChild("Mosin")
	or Assets.Animations.Tools.Guns:FindFirstChild("VolkRifle")
	or Assets.Animations.Tools.Guns:FindFirstChild("Volk")
local _, loadAnimations = createAnimationResolver("mosin")
local volkSounds = GunAssets.Sounds:FindFirstChild("mosin")
	or GunAssets.Sounds:FindFirstChild("Mosin")
	or GunAssets.Sounds:FindFirstChild("VolkRifle")
	or GunAssets.Sounds:FindFirstChild("Volk")
local SoundFolder = volkSounds or GunAssets.Sounds.VolkRifle

local FIRE_INTERVAL = 60 / 50
local BULLET_SPEED = 1200
local RELOAD_ROUND_TIME = 4 / 5
local SCOPED_FOV = 25
local IRON_FOV = 70
local HOLSTER_C0 = CFrame.new(0, 0, -0.65)
	* CFrame.Angles(0, 0, math.rad(90))

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Fire = 1,
	Cycle = 1,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
}

local VolkRifle = {}
VolkRifle.__index = VolkRifle
setmetatable(VolkRifle, { __index = BaseRifle })

export type VolkRifle = typeof(setmetatable({} :: any, VolkRifle))

local function findSound(...: string): Sound?
	for _, name in ipairs({ ... }) do
		local found = SoundFolder:FindFirstChild(name)
		if found and found:IsA("Sound") then return found end
	end
	return nil
end

local function getHolster(modelReference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("mosinHolster")
		or GunAssets.Holsters:FindFirstChild("MosinHolster")
		or GunAssets.Holsters:FindFirstChild("VolkRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not modelReference then return nil end

	local holster = modelReference:Clone()
	holster.Name = "VolkRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "VolkRifle_Torso"
	holster.PrimaryPart = hitbox
	holster:SetAttribute("HolsterC0", HOLSTER_C0)
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

function VolkRifle.new(info: Types.BaseToolCreateInfo): VolkRifle
	local self = setmetatable(BaseRifle.new(info), VolkRifle)

	self.className = "VolkRifle"
	self.item_image = "rbxassetid://17496049645"
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("mosin")
		or ToolFolder:FindFirstChild("Mosin")
		or ToolFolder:FindFirstChild("VolkRifle")
		or ToolFolder:FindFirstChild("Volk")
	self.holster_reference = getHolster(self.model_reference)
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "mosin"
	self.animations = loadAnimations({
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	})

	self.animation_speeds = {
		Aim = 1 / 0.35,
		Reload_Loop = 1 / RELOAD_ROUND_TIME,
	}

	self.damage = 180
	self.Max_Capacity = 5
	self.Capacity = 5
	self.Starting_Reserve_Ammo = 10
	self.Max_Reserve_Ammo = 20
	self.Ammo_Type = "7.62x54mmR Lead"
	self.recoil = 70
	self.recoil_count = 9
	self.Penetration_Level = 2
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force = 12
	self.Aiming_Number = 35
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = 5
	self.Melee_Damage = 35
	self.Accuracy = 3
	self.Moving_Accuracy = 55
	self.SoundFolder = SoundFolder

	self.ScopedMode = true
	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = false
	self.unequip_wait = false

	self.FireEmissions = {
		smoke_medium = function() return math.random(2, 4) end,
		smoke_forward = function() return math.random(3, 5) end,
	}

	self:_initShoulderTracking()
	return self
end

function VolkRifle:_setScopeFov()
	if not self.Aiming then return end
	local camera = workspace.CurrentCamera
	if not camera then return end
	TweenService:Create(camera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = self.ScopedMode and SCOPED_FOV or IRON_FOV,
	}):Play()
end

function VolkRifle:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	if self.ScopedMode and self.Aiming then return shootDirection end
	return BaseRifle.get_spread(self, muzzle, shootDirection)
end

function VolkRifle:aim()
	BaseRifle.aim(self)
	if not self.Aiming then return end
	self:_setScopeFov()
	local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and self.ScopedMode then
		self._preScopeWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, 6)
	end
end

function VolkRifle:endAiming()
	local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._preScopeWalkSpeed then
		humanoid.WalkSpeed = self._preScopeWalkSpeed
	end
	self._preScopeWalkSpeed = nil
	BaseRifle.endAiming(self)
end

function VolkRifle:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	local nextScopedMode = not self.ScopedMode
	local altName = nextScopedMode and "Alt_Mode_On" or "Alt_Mode_Off"
	local altTrack = self.RegisteredAnimations and self.RegisteredAnimations[altName]
	if altTrack then altTrack = self:_playAnim(altName) end
	if altTrack then altTrack.Stopped:Wait() end
	if not self.Equipped then return end
	self.ScopedMode = nextScopedMode
	self:notify(self.ScopedMode and "Sight: Scope" or "Sight: Iron")
	if self.Aiming then
		local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if self.ScopedMode then
				self._preScopeWalkSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, 6)
			elseif self._preScopeWalkSpeed then
				humanoid.WalkSpeed = self._preScopeWalkSpeed
				self._preScopeWalkSpeed = nil
			end
		end
		self:_setScopeFov()
	end
end

function VolkRifle:_damageAtDistance(distance: number): number
	if distance < 45 then return 105 end
	if distance <= 100 then return 180 end
	return 140
end

function VolkRifle:_getMuzzlePart(): BasePart?
	local muzzle = self:_findModelPart(self.MuzzlePartName)
	if muzzle then return muzzle end

	local model = self.actual_model
	if not model then return nil end
	local cachedMuzzle = self._runtimeMuzzle
	if cachedMuzzle and cachedMuzzle:IsA("BasePart") and cachedMuzzle:IsDescendantOf(model) then
		return cachedMuzzle
	end

	-- The Mosin keeps its muzzle inside special. The model can replicate before
	-- all of its descendants, so give that exact path a moment to arrive.
	local special = model:FindFirstChild("special") or model:WaitForChild("special", 1)
	if special then
		local nestedMuzzle = special:FindFirstChild("muzzle") or special:WaitForChild("muzzle", 1)
		if nestedMuzzle and nestedMuzzle:IsA("BasePart") then
			return nestedMuzzle
		end
	end

	local marker = model:FindFirstChild(self.MuzzlePartName, true)
	if marker and marker:IsA("Model") then
		local markerPart = marker:FindFirstChildWhichIsA("BasePart", true)
		if markerPart then return markerPart end
	end

	local hitbox = model:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then return nil end

	local runtimeMuzzle = Instance.new("Part")
	runtimeMuzzle.Name = self.MuzzlePartName
	runtimeMuzzle.Size = Vector3.new(0.1, 0.1, 0.1)
	runtimeMuzzle.Transparency = 1
	runtimeMuzzle.CanCollide = false
	runtimeMuzzle.CanQuery = false
	runtimeMuzzle.CanTouch = false
	runtimeMuzzle.Massless = true
	runtimeMuzzle.CFrame = marker and marker:IsA("Model") and marker:GetPivot() or hitbox.CFrame
	runtimeMuzzle.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = runtimeMuzzle
	weld.Part1 = hitbox
	weld.Parent = runtimeMuzzle

	self._runtimeMuzzle = runtimeMuzzle
	return runtimeMuzzle
end

function VolkRifle:fire()
	if self.Firing or self.Reloading or self.Cycling or self.Checking or self.Alting or self.Meleeing then
		return
	end
	if not self.Aiming then
		return
	end
	if self.Capacity <= 0 then
		return
	end
	if self:_if_sprinting() then
		return
	end
	if self:_if_jumping() then
		return
	end
	if self.ForceBlockFire then
		return
	end

	local muzzle = self:_getMuzzlePart()
	local camera = workspace.CurrentCamera
	if not muzzle or not muzzle:IsA("BasePart") then
		warn("[VolkRifle Debug] Fire blocked because muzzle was not found as a BasePart:", self.MuzzlePartName, muzzle)
		return
	end
	if not camera then
		warn("[VolkRifle Debug] Fire blocked because CurrentCamera is missing")
		return
	end
	if not self.Caster or not self.CasterBehavior then
		warn("[VolkRifle Debug] Fire blocked because FastCast was not initialized", self.Caster, self.CasterBehavior)
		return
	end

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
	if self.current_shoulder == "Right" then
		self:_playFireAnimation("Fire")
	end
	local fireSound = findSound("fire", "Fire")
	if fireSound then self:_play_sfx(fireSound, muzzle) end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)

	self.Cycling = true
	task.wait(math.min(0.25, FIRE_INTERVAL))
	if self.Equipped then
		self:_stopAllExcept()
		local cycleTrack = self:_playAnim("Cycle")
		local cycleSound = findSound("cycle", "bolt")
		if cycleSound then self:_play_sfx(cycleSound, muzzle) end
		if cycleTrack then cycleTrack.Stopped:Wait() end
	end
	local elapsedRest = math.max(0, FIRE_INTERVAL - 0.25)
	if elapsedRest > 0 then task.wait(elapsedRest) end
	self.Cycling = false
	self.Firing = false
	self:_restoreBaseDeferred()
end

function VolkRifle:reload()
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

	local startTrack = self:_playAnim("Reload_Start")
	if startTrack then startTrack.Stopped:Wait() end
	while self.Equipped and self.Capacity < self.Max_Capacity and reserve.Value > 0 and not self._reloadCancelled do
		local loopTrack = self:_playAnim("Reload_Loop")
		if loopTrack then loopTrack.Stopped:Wait() else task.wait(RELOAD_ROUND_TIME) end
		if self._reloadCancelled or not self.Equipped then break end
		self.Capacity += 1
		self:_fire_ammo(1)
	end
	if self.Equipped and not self._reloadCancelled then
		local endTrack = self:_playAnim("Reload_End")
		if endTrack then endTrack.Stopped:Wait() end
	end

	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function VolkRifle:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model then
		warn("[VolkRifle Debug] Activation blocked because actual_model is missing")
		return
	end
	-- A left click can arrive on the frame immediately after right click. Honor
	-- the held aim input instead of dropping that first shot during transition.
	if self.holding_aim_button and not self.Aiming and not self:_isBusy() then
		self:aim()
	end
	if self.Aiming then
		self:fire()
	elseif not self:_isBusy() then
		self:melee()
	end
end

function VolkRifle:_on_equip()
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

function VolkRifle:_on_unequip()
	self:endAiming()
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

function VolkRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

VolkRifle.Tool_Image = "rbxassetid://17496049645"
VolkRifle.Medal_Cost = 0
VolkRifle.Weight = 2
VolkRifle.Designation = "Primary"

return VolkRifle
