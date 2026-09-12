--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local Guns = Assets.Guns
local Effects = Guns.Effects
local AnimationFolder = Assets.Animations.Tools.Guns.JesseRifle
local SoundFolder = Guns.Sounds.JesseRifle

local BULLET_SPEED = 1100
local STANDARD_RPM = 100
local BLACK_HAND_RPM = 120
local STANDARD_RELOAD_TIME = 5.4
local VETERAN_RELOAD_TIME = 3.8
local CLIP_SIZE = 5
local WEAPON_STATS = {
	name = "'Jesse' Combat Rifle",
	desc = "A high capacity and agile rifle reloaded with Stripper Clips innately.",
	icon = "127196615975204",
	ammo_give = ".303 Spitzer",
	damage = 130,
	range = 50,
	range_damage = 120,
	far = 95,
	far_damage = 95,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	accuracy = 12,
	moving_accuracy = 80,
	fire_rate = 0.2,
	cycle = 0.55,
	cycle_rest = 0.05,
	draw_speed = 0.65,
	aim_speed = 0.25,
	recoil = 10,
	recoil_count = 6,
	movement = 1,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 1,
	ammo_reserves_max = 2,
	capacity = 10,
	chamber = false,
	reload_start = 1.2,
	reload_empty = 1.7,
	reload_loop = 0.7,
	reload_end = 0.65,
	bullet_speed = BULLET_SPEED,
	standard_reload_time = STANDARD_RELOAD_TIME,
	veteran_reload_time = VETERAN_RELOAD_TIME,
	clip_size = CLIP_SIZE,
	black_hand_fire_rate = 60 / BLACK_HAND_RPM,
}

local ANIMATION_LAYERS = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Cycle = 1,
	Reload_Start = 2,
	Reload_Start_Vet = 2,
	Reload_Empty = 2,
	Reload_Clip = 2,
	Reload_Clip_Empty = 2,
	Reload_End = 2,
	Check = 2,
	Load_Blank = 2,
	Load_Blank_Vet = 2,
	Load_Grenade = 2,
	Unload_Grenade = 2,
	Discard_Grenade = 2,
	Blank_Boltback = 2,
	Blank_Boltback_Empty = 2,
	Blank_End = 2,
	Blank_Reload = 2,
	Cutoff_On = 2,
	Cutoff_Off = 2,
	Draw = 2,
	Unequip = 2,
	Short = 2,
}

local JesseRifle = {}
JesseRifle.__index = JesseRifle
setmetatable(JesseRifle, { __index = BaseRifle })

export type JesseRifle = typeof(setmetatable({} :: any, JesseRifle))

local animationWrappers: { [string]: Animation } = {}
for _, child in AnimationFolder:GetChildren() do
	if child:IsA("Animation") then
		animationWrappers[child.Name] = child
	end
end

local function getAnimation(name: string): Animation?
	return animationWrappers[name]
end

local function hasPerk(name: string): boolean
	local player = LOCAL_PLAYER
	local character = player and player.Character
	if character and character:GetAttribute(name) == true then return true end
	if player and player:GetAttribute(name) == true then return true end

	local playerData = player and player:FindFirstChild("PlayerData")
	local data = playerData and playerData:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and (perks:FindFirstChild(name) or perks:FindFirstChild(name:gsub(" ", "")))
	return perk ~= nil and (not perk:IsA("BoolValue") or perk.Value)
end

local function getModelReference(): Model?
	local source = Guns.ToolModels:FindFirstChild("enfield")
		or Guns.ToolModels:FindFirstChild("JesseRifle")
	return if source and source:IsA("Model") then source else nil
end

local function playTimedAnimation(self: JesseRifle, name: string, duration: number): boolean
	local registered = self.RegisteredAnimations
	local available = registered and registered[name]
	if not available then
		task.wait(duration)
		return self.Equipped and not self._reloadCancelled
	end

	local track = self:_playAnim(name)
	if not track then return false end
	if track.Length > 0 then
		track:AdjustSpeed(track.Length / math.max(duration, 0.05))
	end
	track.Stopped:Wait()
	return self.Equipped and not self._reloadCancelled
end

function JesseRifle.new(info: Types.BaseToolCreateInfo): JesseRifle
	local self = setmetatable(BaseRifle.new(info), JesseRifle)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand")
	local princeAnimations = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")

	self.className = "JesseRifle"
	self.name = "JesseRifle"
	self.item_image = JesseRifle.Tool_Image
	self.Designation = "Primary"
	self.AnimationGunType = "enfield"
	self.ANIM_LAYERS = ANIMATION_LAYERS

	self.model_reference = getModelReference()
	self.holster_reference = Guns.Holsters:FindFirstChild("enfieldHolster")
		or Guns.Holsters:FindFirstChild("JesseRifleHolster")
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = CFrame.identity,
	}

	self.animations = {
		Hold = getAnimation("locked"),
		Aim = getAnimation("aim"),
		Aim_Left = getAnimation("aim"),
		Fire = getAnimation("fire"),
		Fire_Left = getAnimation("fire"),
		Cycle = getAnimation("cycle"),
		Reload_Start = getAnimation("reload_start"),
		Reload_Start_Vet = getAnimation("reload_start_vet"),
		Reload_Empty = getAnimation("reload_empty"),
		Reload_Clip = getAnimation("reload_clip"),
		Reload_Clip_Empty = getAnimation("reload_clip_empty"),
		Reload_End = getAnimation("reload_end"),
		Check = getAnimation("check"),
		Load_Blank = getAnimation("load_blank"),
		Load_Blank_Vet = getAnimation("load_blank_vet"),
		Load_Grenade = getAnimation("load_grenade"),
		Unload_Grenade = getAnimation("unload_grenade"),
		Discard_Grenade = getAnimation("discard_grenade"),
		Blank_Boltback = getAnimation("blank_boltback"),
		Blank_Boltback_Empty = getAnimation("blank_boltback_empty"),
		Blank_End = getAnimation("blank_end"),
		Blank_Reload = getAnimation("blank_reload"),
		Cutoff_On = getAnimation("cutoff_on"),
		Cutoff_Off = getAnimation("cutoff_off"),
		Draw = princeAnimations and princeAnimations:FindFirstChild("PrinceRifle_Draw") :: Animation?,
		Unequip = princeAnimations and princeAnimations:FindFirstChild("PrinceRifle_Unequip") :: Animation?,
		Short = princeAnimations and princeAnimations:FindFirstChild("PrinceRifle_Short") :: Animation?,
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}
	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.35 or WEAPON_STATS.draw_speed),
		Aim = 1 / (blackHand and 0.21 or WEAPON_STATS.aim_speed),
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * (veteran and WEAPON_STATS.ammo_reserves_max or WEAPON_STATS.ammo_reserves)
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Starting_Grenades = 2
	self.Max_Grenades = 2
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 10
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Aiming_Number = 45
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = WEAPON_STATS.bullet_speed
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireInterval = blackHand and (60 / BLACK_HAND_RPM) or WEAPON_STATS.fire_rate
	self.ReloadDuration = veteran and WEAPON_STATS.veteran_reload_time or WEAPON_STATS.standard_reload_time
	self.IsVeteran = veteran
	self.GrenadeLoaded = false
	self.LoadingGrenade = false
	self.Can_Drop = true
	self:_initShoulderTracking()
	self:applyFirearmConfig(WEAPON_STATS)
	if veteran then
		self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	end
	if blackHand then
		self.FireInterval = WEAPON_STATS.black_hand_fire_rate
	end
	return self
end

function JesseRifle:_damageAtDistance(distance: number): number
	if distance < self.range then return self.damage end
	if distance >= self.far then return self.far_damage end
	return self.range_damage + (distance - self.range) / (self.far - self.range) * (self.far_damage - self.range_damage)
end

function JesseRifle:fire()
	if self.Firing or self.Reloading or self.Cycling or self.LoadingGrenade or not self.Aiming then return end
	if self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return end
	if self.GrenadeLoaded then
		self:_fireGrenade()
		return
	end
	local fireSound = SoundFolder:FindFirstChild("fire", true)
	local fired = self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = "Fire",
		sound = fireSound,
	})
	if not fired then return end

	self.Cycling = true
	task.wait(0.15)
	local cycleTrack = self.Equipped and self:_playAnim("Cycle")
	if cycleTrack then cycleTrack.Stopped:Wait() end
	task.wait(math.max(0, self.FireInterval - 0.15))
	self.Cycling = false
	self:_restoreBaseDeferred()
end

function JesseRifle:_fireGrenade()
	local muzzle = self:_findModelPart(self.MuzzlePartName)
	local camera = workspace.CurrentCamera
	local grenades = self.tool and self.tool:FindFirstChild("Grenades")
	if not muzzle or not camera or not grenades or not grenades:IsA("NumberValue") or grenades.Value <= 0 then return end

	self.Firing = true
	local mousePosition = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local grenadeEvent = ReplicatedStorage.Shared.Library.Events:WaitForChild("JesseGrenade") :: RemoteEvent
	grenadeEvent:FireServer(muzzle.Position, ray.Direction.Unit)
	local blankSound = SoundFolder:FindFirstChild("blank", true)
	if blankSound then self:_play_sfx(blankSound, muzzle) end
	self:_playFireAnimation("Fire")
	self.GrenadeLoaded = false
	local grenadePart = self.actual_model and self.actual_model:FindFirstChild("riflegrenade", true)
	if grenadePart and grenadePart:IsA("BasePart") then grenadePart.Transparency = 1 end
	task.wait(self:getFireDelay(self.FireInterval))
	self.Firing = false
	self:_restoreBaseDeferred()
end

function JesseRifle:setAltMode()
	if not self.Equipped or self:_isBusy() or self.LoadingGrenade then return end
	local grenades = self.tool and self.tool:FindFirstChild("Grenades")
	if not self.GrenadeLoaded and (not grenades or not grenades:IsA("NumberValue") or grenades.Value <= 0) then
		self:notify("I don't have any rifle grenades...")
		return
	end
	if self.Aiming then self:endAiming() end
	self.LoadingGrenade = true
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	if self.GrenadeLoaded then
		playTimedAnimation(self, "Unload_Grenade", 3.5)
		self.GrenadeLoaded = false
	else
		if not self.IsVeteran and self.Capacity > 0 then self.Capacity -= 1 end
		local blankAnimation = self.IsVeteran and "Load_Blank_Vet" or "Load_Blank"
		if playTimedAnimation(self, blankAnimation, 2.25) then
			playTimedAnimation(self, "Load_Grenade", 2.25)
			self.GrenadeLoaded = true
		end
	end

	local grenadePart = self.actual_model and self.actual_model:FindFirstChild("riflegrenade", true)
	if grenadePart and grenadePart:IsA("BasePart") then
		grenadePart.Transparency = self.GrenadeLoaded and 0 or 1
	end
	self.LoadingGrenade = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function JesseRifle:reload()
	if self.Reloading or self.Equipping or self.GrenadeLoaded or self.Capacity >= self.Max_Capacity then return end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then
		self:notify("I don't have any more ammo...")
		return
	end
	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	local needed = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
	local clipCount = math.ceil(needed / WEAPON_STATS.clip_size)
	local actionDuration = self.ReloadDuration / (clipCount + 2)
	playTimedAnimation(self, self.IsVeteran and "Reload_Start_Vet" or "Reload_Start", actionDuration)
	for _ = 1, clipCount do
		if not self.Equipped or self._reloadCancelled then break end
		local amount = math.min(WEAPON_STATS.clip_size, self.Max_Capacity - self.Capacity, reserve.Value)
		local animationName = self.Capacity == 0 and "Reload_Clip_Empty" or "Reload_Clip"
		if not playTimedAnimation(self, animationName, actionDuration) then break end
		self.Capacity += amount
		self:_fire_ammo(amount)
	end
	if self.Equipped and not self._reloadCancelled then
		playTimedAnimation(self, "Reload_End", actionDuration)
	end
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function JesseRifle:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function JesseRifle:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	self:_setupFastCast(Effects, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		self:_onBulletHit(cast, result, velocity, self:_findModelPart(self.MuzzlePartName),
			self.Penetration_Level, self:_damageAtDistance(distance), self.KnockBack_Force)
	end)
end

function JesseRifle:_on_unequip()
	self:endAiming()
	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.LoadingGrenade = false
	self._reloadCancelled = true
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
end

JesseRifle.Tool_Image = "rbxassetid://109461036497765"
JesseRifle.Medal_Cost = 0
JesseRifle.Weight = 2
JesseRifle.Designation = "Primary"
JesseRifle.Display_Name = WEAPON_STATS.name
JesseRifle.desc = WEAPON_STATS.desc
JesseRifle.icon = WEAPON_STATS.icon
JesseRifle.damage = WEAPON_STATS.damage
JesseRifle.range = WEAPON_STATS.range
JesseRifle.range_damage = WEAPON_STATS.range_damage
JesseRifle.far = WEAPON_STATS.far
JesseRifle.far_damage = WEAPON_STATS.far_damage
JesseRifle.accuracy = WEAPON_STATS.accuracy
JesseRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
JesseRifle.fire_rate = WEAPON_STATS.fire_rate
JesseRifle.cycle = WEAPON_STATS.cycle
JesseRifle.cycle_rest = WEAPON_STATS.cycle_rest
JesseRifle.recoil = WEAPON_STATS.recoil
JesseRifle.recoil_count = WEAPON_STATS.recoil_count
JesseRifle.capacity = WEAPON_STATS.capacity
JesseRifle.ammo_give = WEAPON_STATS.ammo_give
JesseRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
JesseRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
JesseRifle.pen = WEAPON_STATS.pen

return JesseRifle
