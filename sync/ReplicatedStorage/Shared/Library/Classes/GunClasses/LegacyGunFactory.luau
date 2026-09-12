--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BasePistol = require(script.Parent.Parent.BasePistol)
local BaseRifle = require(script.Parent.Parent.BaseRifle)
local BaseShotgun = require(script.Parent.Parent.BaseShotgun)
local WeaponIds = require(script.Parent.Parent.Parent.WeaponIds)

local Assets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets")
local GunAssets = Assets:WaitForChild("Guns")

local DEFAULT_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Fire_Last = 1,
	Fire_Last_Left = 1,
	Cycle = 1,
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
	Check_Empty = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
}

local function firstChild(parent: Instance?, names: { string }): Instance?
	if not parent then return nil end
	for _, name in names do
		local found = parent:FindFirstChild(name)
		if found then return found end
	end
	for _, name in names do
		local found = parent:FindFirstChild(name, true)
		if found then return found end
	end
	return nil
end

local function aliasNames(...): { string }
	local result = {}
	local seen = {}

	local function add(name)
		if type(name) ~= "string" or name == "" or seen[name] then return end
		table.insert(result, name)
		seen[name] = true
	end

	for _, name in { ... } do
		if type(name) == "table" then
			for _, entry in name do
				add(entry)
				for _, alias in WeaponIds.Aliases(entry) do
					add(alias)
				end
			end
		else
			add(name)
			for _, alias in WeaponIds.Aliases(name) do
				add(alias)
			end
		end
	end

	return result
end

local function animation(folder: Instance?, names: { string }): Animation?
	local found = firstChild(folder, names)
	return found and found:IsA("Animation") and found or nil
end

local function sound(folder: Instance?, names: { string }): Sound?
	local found = firstChild(folder, names)
	return found and found:IsA("Sound") and found or nil
end

local function buildAnimations(animationId: string): { [string]: Animation }?
	local guns = Assets:FindFirstChild("Animations")
		and Assets.Animations:FindFirstChild("Tools")
		and Assets.Animations.Tools:FindFirstChild("Guns")
	local folder = firstChild(guns, { animationId })
	local prince = guns and guns:FindFirstChild("PrinceRifle")
	local result = {
		Hold = animation(folder, { "held", "Hold" }) or animation(prince, { "PrinceRifle_Held" }),
		Draw = animation(folder, { "draw", "Draw" }) or animation(prince, { "PrinceRifle_Draw" }),
		Unequip = animation(folder, { "unequip", "Unequip" }) or animation(prince, { "PrinceRifle_Unequip" }),
		Aim = animation(folder, { "aim", "Aim" }) or animation(prince, { "PrinceRifle_Aim" }),
		Aim_Left = animation(folder, { "aim_left", "Aim_Left" }) or animation(prince, { "PrinceRifle_Aim_Left" }),
		Fire = animation(folder, { "fire", "Fire" }) or animation(prince, { "PrinceRifle_Fire" }),
		Fire_Left = animation(folder, { "fire_left", "Fire_Left" }) or animation(prince, { "PrinceRifle_Fire_Left" }),
		Fire_Last = animation(folder, { "fire_last", "Fire_Last" }),
		Fire_Last_Left = animation(folder, { "fire_last_left", "Fire_Last_Left" }),
		Cycle = animation(folder, { "cycle", "Cycle", "reload_bolt" }),
		Reload_Start = animation(folder, { "reload_start", "Reload_Start" }),
		Reload_Loop = animation(folder, { "reload_loop", "Reload_Loop", "reload_one" }),
		Reload_End = animation(folder, { "reload_end", "Reload_End" }),
		Check = animation(folder, { "check", "Check" }),
		Check_Empty = animation(folder, { "check_empty", "Check_Empty" }),
		Melee1 = animation(folder, { "melee1", "Melee1" }) or animation(prince, { "PrinceRifle_Melee1" }),
		Melee2 = animation(folder, { "melee2", "Melee2" }) or animation(prince, { "PrinceRifle_Melee2" }),
		Short = animation(folder, { "short", "Short" }) or animation(prince, { "PrinceRifle_Short" }),
	}

	for _, value in result do
		if value then
			return result
		end
	end
	return nil
end

local function baseFor(category: string?)
	if category == "Pistol" then return BasePistol end
	if category == "Shotgun" then return BaseShotgun end
	return BaseRifle
end

local function mergeLegacyStats(config)
	local legacy = config.LegacyStats
	if not legacy then return config end

	for key, value in pairs(legacy) do
		if config[key] == nil then
			config[key] = value
		end
	end
	if config.name == nil and legacy.name then
		config.name = legacy.name
	end
	return config
end

local function classToolType(config): string
	if config.tooltype then return config.tooltype end
	if config.WeaponCategory == "Launcher" then return "launcher" end
	if config.WeaponCategory == "Flamer" then return "flamer" end
	return "gun"
end

local function publishStaticFields(Class, className: string, config)
	Class.className = className
	Class.name = config.name or className
	Class.Display_Name = Class.name
	Class.Tool_Image = config.Tool_Image or (config.icon and ("rbxassetid://" .. config.icon)) or ""
	Class.Medal_Cost = config.Medal_Cost or 0
	Class.Weight = config.Weight or (config.WeaponCategory == "Pistol" and 1 or 2)
	Class.Designation = config.Designation or (config.WeaponCategory == "Pistol" and "Secondary" or "Primary")
	Class.desc = config.desc or ""
	Class.lore = config.lore or ""
	Class.assists = config.assists
	Class.icon = config.icon
	Class.alt_name = config.alt_name
	Class.blacklist = config.blacklist or false
	Class.tooltype = classToolType(config)
	Class.capacity = config.capacity
	Class.ammo_give = config.ammo_give or config.ammoGive or config.ammoType
	Class.ammo_reserves = config.ammo_reserves or config.reserveClips
	Class.ammo_reserves_max = config.ammo_reserves_max or config.maxReserveClips
	Class.damage = config.damage
	Class.range = config.range
	Class.range_damage = config.range_damage
	Class.far = config.far
	Class.far_damage = config.far_damage
	Class.accuracy = config.accuracy
	Class.moving_accuracy = config.moving_accuracy or config.movingAccuracy
	Class.fire_rate = config.fire_rate or config.fireInterval
	Class.cycle = config.cycle or 0
	Class.cycle_rest = config.cycle_rest or 0
	Class.display_fire_rate = config.display_fire_rate
	Class.pen = config.pen or config.penetration
	Class.pellets = config.pellets or config.pelletCount
	Class.melee_damage = config.melee_damage or config.meleeDamage
	Class.melee_range = config.melee_range or config.meleeDistance
	Class.melee_swing_speed = config.melee_swing_speed
	Class.draw_speed = config.draw_speed or config.drawSpeed
	Class.aim_speed = config.aim_speed or config.aimSpeed
end

local Factory = {}

function Factory.create(config)
	config = mergeLegacyStats(config)
	local className = config.className or config.canonicalName or config.name
	local Base = baseFor(config.WeaponCategory)
	local Class = {}
	Class.__index = Class
	setmetatable(Class, { __index = Base })

	function Class.new(info)
		local self = setmetatable(Base.new(info), Class)
		local animationId = WeaponIds.Canonical(config.AnimationGunType or config.animations or config.assetName or className)
		local assetName = config.assetName or WeaponIds.AssetName(className)
		local modelNames = aliasNames(config.modelNames or {}, assetName, className)
		local soundNames = aliasNames(config.soundNames or {}, assetName, className)
		local animationNames = aliasNames(config.AnimationGunType or config.animations or {}, assetName, className)

		self.className = className
		self.name = config.name or className
		self.item_image = Class.Tool_Image
		self.Designation = Class.Designation
		self.ANIM_LAYERS = config.ANIM_LAYERS or DEFAULT_LAYERS
		self.AnimationGunType = animationId
		for _, candidate in animationNames do
			self.animations = buildAnimations(candidate)
			if self.animations then
				self.AnimationGunType = candidate
				break
			end
		end

		local toolModels = GunAssets:FindFirstChild("ToolModels")
		local holsters = GunAssets:FindFirstChild("Holsters")
		local sounds = GunAssets:FindFirstChild("Sounds")
		self.model_reference = firstChild(toolModels, modelNames)
		local holsterNames = {}
		for _, name in aliasNames(config.holsterNames or {}, assetName, className) do
			table.insert(holsterNames, name)
			table.insert(holsterNames, name .. "Holster")
		end
		self.holster_reference = firstChild(holsters, holsterNames)
		self.SoundFolder = firstChild(sounds, soundNames)
		self.FireSound = sound(self.SoundFolder, { "fire", "Fire", "shot" })

		self.motor_6d_data = {
			Parent = config.WeaponCategory == "Pistol" and "Right Arm" or "Left Arm",
			Part0 = config.WeaponCategory == "Pistol" and "Right Arm" or "Left Arm",
			Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
			C0 = config.GripC0 or self.DefaultGripC0,
			C1 = CFrame.identity,
		}

		self.damage = config.damage or self.damage
		self.Max_Capacity = config.capacity or self.Max_Capacity
		self.Capacity = self.Max_Capacity
		self.Ammo_Type = config.ammoType or config.ammo_give or self.Ammo_Type
		self.recoil = config.recoil or self.recoil
		self.recoil_count = config.recoilCount or config.recoil_count or self.recoil_count
		self.Penetration_Level = config.penetration or config.pen or self.Penetration_Level
		self.Armor_Penetration_Level = config.armorPenetration or self.Armor_Penetration_Level
		self.KnockBack_Force = config.knockback or self.KnockBack_Force
		self.Aiming_Number = config.aimingNumber or self.Aiming_Number
		self.Accuracy = config.accuracy or self.Accuracy
		self.Moving_Accuracy = config.movingAccuracy or config.moving_accuracy or self.Moving_Accuracy
		self.MuzzlePartName = config.muzzlePartName or "muzzle"
		self.AmmoCheckPartName = config.ammoCheckPartName or "hitbox"
		self.BulletSpeed = config.bullet_speed or config.bulletSpeed or 900
		self.FireInterval = config.fireInterval or config.fire_rate or 0.5
		self.Short_Distance = config.shortDistance or 3.5
		self.Melee_Distance = config.meleeDistance or config.melee_range or 5
		self.Melee_Damage = config.meleeDamage or config.melee_damage or 80
		self.Can_Drop = config.canDrop ~= false
		self.FireEmissions = config.fireEmissions or {
			smoke_medium = function() return math.random(2, 4) end,
			smoke_forward = function() return math.random(3, 5) end,
		}

		if config.WeaponCategory == "Shotgun" then
			self.PelletCount = config.pelletCount or config.pellets or self.PelletCount
			self.ShotgunSpread = config.shotgunSpread or self.ShotgunSpread
		end

		self:applyFirearmConfig(config)
		self.Equipped = false
		self.Firing = false
		self.Cycling = false
		self.Reloading = false
		self.Alting = false
		self._reloadCancelled = false
		self:_initShoulderTracking()
		return self
	end

	function Class:fire()
		local left = self.current_shoulder ~= "Right"
		local fireAnimation = if self.Capacity <= 1
			then (left and "Fire_Last_Left" or "Fire_Last")
			else (left and "Fire_Left" or "Fire")
		local options = {
			bulletSpeed = self.BulletSpeed,
			fireAnimation = fireAnimation,
			sound = self.FireSound,
			fireDelay = config.cycles and nil or self.FireInterval,
		}
		local fired = if config.WeaponCategory == "Shotgun"
			then self:_fireShotgunBlast(options)
			else self:_fireSingleShot(options)
		if not fired or not config.cycles then return end

		self.Cycling = true
		task.wait(math.min(0.25, self.FireInterval))
		local cycleTrack = self.Equipped and self:_playAnim("Cycle")
		if cycleTrack then cycleTrack.Stopped:Wait() end
		task.wait(math.max(0, self.FireInterval - 0.25))
		self.Cycling = false
		self:_restoreBaseDeferred()
	end

	function Class:_damageAtDistance(distance: number): number
		return Base._damageAtDistance(self, distance)
	end

	function Class:reload()
		self:_reloadByRound({
			startAnim = "Reload_Start",
			loopAnim = "Reload_Loop",
			endAnim = "Reload_End",
			loopWait = config.reload_loop,
		})
	end

	function Class:activate()
		if self.Reloading then
			self._reloadCancelled = true
			return
		end
		if not self.actual_model or self:_isBusy() then return end
		if self.Aiming then self:fire() else self:melee() end
	end

	function Class:_on_equip()
		self.Equipped = true
		self:_cacheMotor6D()
		self:_connectInput()
		self:_initShoulderTracking()

		local fxFolder = GunAssets:FindFirstChild("Effects")
		if fxFolder then
			self:_setupFastCast(fxFolder, function(cast, result, velocity)
				local muzzle = self:_findModelPart(self.MuzzlePartName)
				local origin = cast.UserData and cast.UserData.Origin
				local distance = origin and (result.Position - origin).Magnitude or 0
				self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level,
					self:_damageAtDistance(distance), self.KnockBack_Force)
			end)
		end
	end

	function Class:_on_unequip()
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
		game.Players.LocalPlayer:SetAttribute("CantUnequip", nil)
	end

	publishStaticFields(Class, className, config)
	return Class
end

return Factory
