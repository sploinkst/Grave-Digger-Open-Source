--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)
local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects

local volkAnimations = Assets.Animations.Tools.Guns:FindFirstChild("VolkRifle")

local volkSounds = GunAssets.Sounds:FindFirstChild("mosin")
	or GunAssets.Sounds:FindFirstChild("Mosin")
	or GunAssets.Sounds:FindFirstChild("VolkRifle")
	or GunAssets.Sounds:FindFirstChild("Volk")
local SoundFolder = volkSounds or GunAssets.Sounds.VolkRifle

local FIRE_INTERVAL = 0.3
local BULLET_SPEED = 1200
local SCOPED_FOV = 25
local IRON_FOV = 70
local HOLSTER_C0 = CFrame.new(0, 0, -0.65)
	* CFrame.Angles(0, 0, math.rad(90))

local WEAPON_STATS = {
	name = "'Volk' Scoped Rifle",
	desc = "A marksman rifle with a scope, excellent precision and damage over far distances.",
	lore = "No-one knew his real name; he didn't speak much to his comrades, and his line of work kept him away from his fellow soldiers in the first place.\n\nInstead, he was known as 'The Wolf' - regarded the greatest marksman of the Royal Nation, many of his accolades have been likely been exaggerated in the years following his death. Wielding a mundane rifle with a make-shift scope assembly taken from a 'Jesse' rifle, he was rumored to have over 400 confirmed kills, with one kill at a distance over 2,000 meters. He earned his name from a story where the first kill of a skirmish coincided with the howling of a wolf, striking fear into the hearts of Imperial soldiers as they were helplessly picked off by the unseen sniper.\n\nAll legends eventually meet their end - the 'Wolf was no different. After being reported missing for weeks, his dessicated and dismembered corpse was found crucified on the stake of heresy, his dog-tags taken and his name lost to the grave.\n\nThough neither the Golden Empire nor the Royal Nation knows of who ended his reign, his legacy lives on with the standard production of his once-unique rifle.",
	size = 2,
	icon = "18352089477",
	animations = "mosin",
	ammo_give = "7.62mmR Lead",
	melee_sound = "rifle",
	assists = {
		"Top of the line accuracy while scoped, but mind the slow handling.",
		"[@ALT] to toggle the scope zoom.",
		"Has an inverse damage profile, rounds are deadlier at range due to overpenetration.",
	},
	tooltype = "gun",
	damage = 105,
	range = 45,
	range_damage = 180,
	far = 100,
	far_damage = 140,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	wallpen_distance = 50,
	wallpen_studs = 3,
	accuracy = 3,
	moving_accuracy = 120,
	fire_rate = FIRE_INTERVAL,
	cycle = 0.7,
	cycle_rest = 0.2,
	draw_speed = 1,
	aim_speed = 0.35,
	wound = 1,
	length = 4,
	recoil = 5,
	recoil_count = 6,
	movement = 3,
	firing_movement = 1.5,
	firing_movement_last = 0.5,
	ammo_reserves = 2,
	ammo_reserves_max = 4,
	capacity = 5,
	chamber = false,
	reload_start = 1,
	reload_empty = 1.5,
	reload_loop = 0.5,
	reload_end = 0.5,
	reload_full = 1.5,
	bullet_speed = BULLET_SPEED,
}

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
		local found = SoundFolder:FindFirstChild(name, true)
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
	self.item_image = VolkRifle.Tool_Image
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
	self.animations = {
		Draw = volkAnimations.Parent.PrinceRifle.PrinceRifle_Draw,
		Hold = volkAnimations.held,
		Unequip = volkAnimations.Parent.PrinceRifle.PrinceRifle_Unequip,

		Aim      = volkAnimations.aim,
		Aim_Left = volkAnimations.Parent.PrinceRifle.PrinceRifle_Aim_Left,

		Fire      = volkAnimations.fire,
		Fire_Left = volkAnimations.Parent.PrinceRifle.PrinceRifle_Fire_Left,

		Cycle = volkAnimations.cycle,

		Reload_Empty = volkAnimations.reload_empty,
		Reload_Start = volkAnimations.reload_start,
		Reload_Loop  = volkAnimations.reload_loop,
		Reload_End   = volkAnimations.reload_end,

		Check  = volkAnimations.check,
		Melee1 = volkAnimations.Parent.PrinceRifle.PrinceRifle_Melee1,
		Melee2 = volkAnimations.Parent.PrinceRifle.PrinceRifle_Melee2,

		Drop  = volkAnimations.Parent.Parent.Misc.Drop_Rifle,
		Short = volkAnimations.Parent.PrinceRifle.PrinceRifle_Short,
	}

	self.animation_speeds = {
		Draw = 1 / WEAPON_STATS.draw_speed,
		Aim = 1 / WEAPON_STATS.aim_speed,
		Aim_Left = 1 / WEAPON_STATS.aim_speed,
		Cycle = 1 / WEAPON_STATS.cycle,
		Reload_Start = 1 / WEAPON_STATS.reload_start,
		Reload_Empty = 1 / WEAPON_STATS.reload_empty,
		Reload_Loop = 1 / WEAPON_STATS.reload_loop,
		Reload_End = 1 / WEAPON_STATS.reload_end,
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force = 12
	self.Aiming_Number = 35
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = BULLET_SPEED
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = WEAPON_STATS.melee_range
	self.Melee_Damage = WEAPON_STATS.melee_damage
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.SoundFolder = SoundFolder
	self.FireInterval = WEAPON_STATS.fire_rate
	self:applyFirearmConfig(WEAPON_STATS)

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
	if distance < self.range then return self.damage end
	if distance <= self.far then return self.range_damage end
	return self.far_damage
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
	local fireSound = findSound("fire", "Fire")
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		sound = fireSound,
	})
	if not fired then return end

	self.Cycling = true
	task.wait(math.min(0.25, self.fire_rate or FIRE_INTERVAL))
	if self.Equipped then
		self:_stopAllExcept()
		local cycleTrack = self:_playAnim("Cycle")
		local cycleSound = findSound("cycle", "bolt")
		local muzzle = self:_getMuzzlePart()
		if cycleSound and muzzle then self:_play_sfx(cycleSound, muzzle) end
		if cycleTrack and self.cycle and self.cycle > 0 then
			cycleTrack:AdjustSpeed(math.max(cycleTrack.Length / self.cycle, 0.01))
		end
		if cycleTrack then cycleTrack.Stopped:Wait() end
	end
	task.wait(self.cycle_rest or 0)

	self.Cycling = false
	self:_restoreBaseDeferred()
end

function VolkRifle:reload()
	self:_reloadByRound({
		startAnim = "Reload_Start",
		loopAnim = "Reload_Loop",
		endAnim = "Reload_End",
	})
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

VolkRifle.name = WEAPON_STATS.name
VolkRifle.Display_Name = WEAPON_STATS.name
VolkRifle.Tool_Image = "rbxassetid://109461036497765"
VolkRifle.Medal_Cost = 0
VolkRifle.Weight = 2
VolkRifle.Designation = "Primary"
VolkRifle.desc = WEAPON_STATS.desc
VolkRifle.lore = WEAPON_STATS.lore
VolkRifle.assists = WEAPON_STATS.assists
VolkRifle.icon = WEAPON_STATS.icon
VolkRifle.tooltype = WEAPON_STATS.tooltype
VolkRifle.damage = WEAPON_STATS.damage
VolkRifle.range = WEAPON_STATS.range
VolkRifle.range_damage = WEAPON_STATS.range_damage
VolkRifle.far = WEAPON_STATS.far
VolkRifle.far_damage = WEAPON_STATS.far_damage
VolkRifle.accuracy = WEAPON_STATS.accuracy
VolkRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
VolkRifle.fire_rate = WEAPON_STATS.fire_rate
VolkRifle.cycle = WEAPON_STATS.cycle
VolkRifle.cycle_rest = WEAPON_STATS.cycle_rest
VolkRifle.recoil = WEAPON_STATS.recoil
VolkRifle.recoil_count = WEAPON_STATS.recoil_count
VolkRifle.capacity = WEAPON_STATS.capacity
VolkRifle.ammo_give = WEAPON_STATS.ammo_give
VolkRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
VolkRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
VolkRifle.pen = WEAPON_STATS.pen

return VolkRifle
