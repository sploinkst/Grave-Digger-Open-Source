--!native
--!optimize 2

-- Firearm-only behavior shared by rifle and pistol category bases.
-- This class is not meant to be used directly, but rather as a base for other firearm classes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local BaseTool = require(script.Parent.BaseTool)
local utilities_module = require(ReplicatedStorage.Shared.Library.Util)
local replicant_service = require(ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService)

local LOCAL_PLAYER = game:GetService("Players").LocalPlayer
local events = ReplicatedStorage.Shared.Library.Events
local fast_cast_replication = events.FastCast
local hit_connection = events.Hit
local vfx_cast_event = events.VFX
local texture_event = events.Texture
local casing_event = events.Casing
local ammo_communication = events.Ammo
local FX_BULLET_HOLE = ReplicatedStorage.Shared.Assets.Guns.Effects.BulletHole
local CUT = 0.06
local MIN_AMMO_CHECK_DISPLAY_TIME = 1

local BaseFirearm = {}
BaseFirearm.__index = BaseFirearm
setmetatable(BaseFirearm, { __index = BaseTool })

export type BaseFirearm = BaseTool.BaseTool

function BaseFirearm.new(info): BaseFirearm
	local self = BaseTool.new(info) :: any
	self.AnimationDrivenGrip = false
	self.IsFirearm = true
	-- Shared rifle mount matches Prince's original scripted attachment.
	self.DefaultGripC0 = CFrame.new(0.254, -1.703, -0.566)
		* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90))
	return setmetatable(self, BaseFirearm)
end

function BaseFirearm:applyFirearmConfig(config)
	local legacy = config.LegacyStats
	if legacy then
		for key, value in pairs(legacy) do
			if config[key] == nil then
				config[key] = value
			end
		end
	end

	for key, value in pairs(config) do
		if key == "animations" and type(value) == "string" then
			self.AnimationGunType = value
		elseif key ~= "name" and type(value) ~= "function" and key ~= "methods" then
			self[key] = value
		end
	end

	local capacity = config.capacity or config.Max_Capacity or self.Max_Capacity
	local ammoType = config.ammo_give or config.ammoGive or config.ammoType or config.Ammo_Type or self.Ammo_Type
	local reserveClips = config.ammo_reserves or config.reserveClips or 2
	local maxReserveClips = config.ammo_reserves_max or config.maxReserveClips or 3

	self.tooltype = config.tooltype or "gun"
	self.Display_Name = config.Display_Name or config.name or self.Display_Name
	self.desc = config.desc or self.desc
	self.lore = config.lore or self.lore
	self.assists = config.assists or self.assists
	self.icon = config.icon or self.icon
	self.item_image = config.Tool_Image or config.item_image or (config.icon and ("rbxassetid://" .. config.icon)) or self.item_image
	self.damage = config.damage or self.damage
	self.Max_Capacity = capacity or self.Max_Capacity
	self.Capacity = config.Capacity or capacity or self.Capacity or self.Max_Capacity
	self.Ammo_Type = ammoType or self.Ammo_Type
	self.recoil = config.recoil or self.recoil
	self.recoil_count = config.recoil_count or config.recoilCount or self.recoil_count
	self.Penetration_Level = config.pen or config.penetration or self.Penetration_Level
	self.Armor_Penetration_Level = config.armor_pen or config.armorPenetration or self.Armor_Penetration_Level
	self.KnockBack_Force = config.knockback or config.KnockBack_Force or self.KnockBack_Force
	self.Melee_Damage = config.melee_damage or config.meleeDamage or self.Melee_Damage
	self.Melee_Distance = config.melee_range or config.meleeDistance or self.Melee_Distance
	self.Melee_Swing_Speed = config.melee_swing_speed or self.Melee_Swing_Speed
	self.Accuracy = config.accuracy or self.Accuracy
	self.Moving_Accuracy = config.moving_accuracy or config.movingAccuracy or self.Moving_Accuracy
	self.FireInterval = config.fire_rate or config.fireInterval or config.FireInterval or self.FireInterval
	self.BulletSpeed = config.bullet_speed or config.bulletSpeed or self.BulletSpeed
	self.PostFireDelay = config.post_fire_delay or config.postFireDelay or config.fire_recovery or self.PostFireDelay
	self.PostCycleDelay = config.post_cycle_delay or config.postCycleDelay or config.cycle_recovery or self.PostCycleDelay
	self.PostReloadDelay = config.post_reload_delay or config.postReloadDelay or config.reload_recovery or self.PostReloadDelay
	self.capacity = capacity
	self.ammo_give = ammoType
	self.ammo_reserves = reserveClips
	self.ammo_reserves_max = maxReserveClips
	self.fire_rate = config.fire_rate or config.fireInterval or config.FireInterval or self.FireInterval
	self.cycle = config.cycle or self.cycle or 0
	self.cycle_rest = config.cycle_rest or self.cycle_rest or 0
	self.draw_speed = config.draw_speed or config.drawSpeed or self.draw_speed
	self.aim_speed = config.aim_speed or config.aimSpeed or self.aim_speed
	self.reload_start = config.reload_start or config.reloadStart or self.reload_start
	self.reload_loop = config.reload_loop or config.reloadLoop or self.reload_loop
	self.reload_end = config.reload_end or config.reloadEnd or self.reload_end
	self.require_full_load = config.require_full_load or self.require_full_load or false
	self.hidereserves = config.hidereserves or self.hidereserves or false
	self.pellets = config.pellets or config.pelletCount or self.PelletCount or 1
	self.size = config.size or self.size or 2
	self.movement = config.movement or self.movement or 1
	self.firing_movement = config.firing_movement or self.firing_movement or self.movement
	self.firing_movement_last = config.firing_movement_last or self.firing_movement_last or self.firing_movement
	self.display_fire_rate = config.display_fire_rate or self.display_fire_rate
	self.range = config.range or self.range
	self.range_damage = config.range_damage or self.range_damage
	self.far = config.far or self.far
	self.far_damage = config.far_damage or self.far_damage
	self.wallpen_distance = config.wallpen_distance or self.wallpen_distance
	self.wallpen_studs = config.wallpen_studs or self.wallpen_studs
	self.wound = config.wound or self.wound
	self.length = config.length or self.length
	self.melee_sound = config.melee_sound or self.melee_sound
	self.reload_empty = config.reload_empty or self.reload_empty
	self.reload_loop_after = config.reload_loop_after or self.reload_loop_after
	self.reload_alt = config.reload_alt or self.reload_alt
	self.reload_full = config.reload_full or self.reload_full
	self.chamber = config.chamber or self.chamber or false
	self.blacklist = config.blacklist or self.blacklist or false
	self.auto = config.auto or self.auto or false
	self.alt_name = config.alt_name or self.alt_name
	self.Starting_Reserve_Ammo = config.startingReserve or config.Starting_Reserve_Ammo or capacity * reserveClips
	self.Max_Reserve_Ammo = config.maxReserve or config.Max_Reserve_Ammo or capacity * maxReserveClips
	self.animation_speeds = self.animation_speeds or {}
	if config.draw_speed and self.animation_speeds.Draw == nil then self.animation_speeds.Draw = 1 / config.draw_speed end
	if config.aim_speed and self.animation_speeds.Aim == nil then self.animation_speeds.Aim = 1 / config.aim_speed end
	if config.aim_speed and self.animation_speeds.Aim_Left == nil then self.animation_speeds.Aim_Left = 1 / config.aim_speed end
	if config.cycle and config.cycle > 0 and self.animation_speeds.Cycle == nil then self.animation_speeds.Cycle = 1 / config.cycle end
	if config.reload_start and config.reload_start > 0 and self.animation_speeds.Reload_Start == nil then self.animation_speeds.Reload_Start = 1 / config.reload_start end
	if config.reload_empty and config.reload_empty > 0 and self.animation_speeds.Reload_Empty == nil then self.animation_speeds.Reload_Empty = 1 / config.reload_empty end
	if config.reload_loop and config.reload_loop > 0 and self.animation_speeds.Reload_Loop == nil then self.animation_speeds.Reload_Loop = 1 / config.reload_loop end
	if config.reload_end and config.reload_end > 0 and self.animation_speeds.Reload_End == nil then self.animation_speeds.Reload_End = 1 / config.reload_end end
	if config.reload_alt and config.reload_alt > 0 and self.animation_speeds.Reload_Alt == nil then self.animation_speeds.Reload_Alt = 1 / config.reload_alt end
	self.LegacyWeaponAttributes = {
		tooltype = self.tooltype,
		capacity = self.capacity,
		ammo_give = self.ammo_give,
		ammo_reserves = self.ammo_reserves,
		ammo_reserves_max = self.ammo_reserves_max,
		fire_rate = self.fire_rate,
		cycle = self.cycle,
		cycle_rest = self.cycle_rest,
		draw_speed = self.draw_speed,
		aim_speed = self.aim_speed,
		reload_start = self.reload_start,
		reload_loop = self.reload_loop,
		reload_end = self.reload_end,
		require_full_load = self.require_full_load,
		hidereserves = self.hidereserves,
		pellets = self.pellets,
		size = self.size,
		movement = self.movement,
		firing_movement = self.firing_movement,
		firing_movement_last = self.firing_movement_last,
		display_fire_rate = self.display_fire_rate,
		range = self.range,
		range_damage = self.range_damage,
		far = self.far,
		far_damage = self.far_damage,
		wallpen_distance = self.wallpen_distance,
		wallpen_studs = self.wallpen_studs,
		wound = self.wound,
		length = self.length,
		melee_sound = self.melee_sound,
		reload_empty = self.reload_empty,
		reload_loop_after = self.reload_loop_after,
		reload_alt = self.reload_alt,
		reload_full = self.reload_full,
		chamber = self.chamber,
		blacklist = self.blacklist,
		auto = self.auto,
		alt_name = self.alt_name,
		damage = self.damage,
		accuracy = self.Accuracy,
		moving_accuracy = self.Moving_Accuracy,
		recoil = self.recoil,
		recoil_count = self.recoil_count,
	}

	return self
end

function BaseFirearm:_effectiveFireDelay(delay: number?): number
	local fireDelay = delay or self.PostFireDelay or self.FireInterval or self.fire_rate or 0
	if fireDelay <= 0 then return 0 end
	return self.getFireDelay and self:getFireDelay(fireDelay) or fireDelay
end

function BaseFirearm:_blockFireFor(delay: number?)
	local fireDelay = self:_effectiveFireDelay(delay)
	if fireDelay <= 0 then return end
	self._nextFireAt = math.max(self._nextFireAt or 0, os.clock() + fireDelay)
end

function BaseFirearm:_canFireNow(): boolean
	return os.clock() >= (self._nextFireAt or 0)
end

function BaseFirearm:_getReserveAmmo(): NumberValue?
	local reserveAmmo = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if reserveAmmo and reserveAmmo:IsA("NumberValue") then
		return reserveAmmo
	end
	return nil
end

function BaseFirearm:_hasReserveAmmo(): boolean
	local reserveAmmo = self:_getReserveAmmo()
	if not reserveAmmo then
		warn(("%s: Cannot use reserve ammo because Reserve_Ammo is missing"):format(self.className))
		return false
	end
	if reserveAmmo.Value <= 0 then
		self:notify("I don't have any more ammo...")
		return false
	end
	return true
end

function BaseFirearm:_withUnequipLock(callback: () -> ())
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)
	local ok, err = pcall(callback)
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	if not ok then
		error(err, 2)
	end
end

function BaseFirearm:_playCycle(options): boolean
	if self.Cycling then return false end
	self.Cycling = true
	self.Cycled = false

	if not self.RegisteredAnimations then
		self.Cycling = false
		return false
	end

	local cycleDelay = options and options.delay or self.CycleDelay or 0
	local cycleAnim = options and options.animation or self.CycleAnimation or "Cycle"
	local complete = options and options.complete
	local recoveryDelay = options and options.recoveryDelay or self.PostCycleDelay or self.cycle_rest or 0

	local function finishCycle()
		if recoveryDelay > 0 then
			task.wait(self:_effectiveFireDelay(recoveryDelay))
		end
		if complete then
			complete(self)
		else
			self.Cycled = true
		end
		self.Cycling = false
		self:_restoreBase()
	end

	task.delay(cycleDelay, function()
		self:_stopAllExcept()
		local cycleTrack = self:_playAnim(cycleAnim)
		if cycleTrack then
			cycleTrack.Stopped:Once(function()
				finishCycle()
			end)
		else
			finishCycle()
		end
	end)

	return true
end

function BaseFirearm:_fireAnimationName(): string
	if self.FireAnimation then return self.FireAnimation end
	if self.Capacity <= 1 then
		local last = (self.current_shoulder == "Right") and "Fire_Last" or "Fire_Last_Left"
		if self.RegisteredAnimations and self.RegisteredAnimations[last] then
			return last
		end
	end
	return (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
end

function BaseFirearm:_fireOptions()
	return {
		bulletSpeed = self.BulletSpeed,
		distance = self.FireRayDistance,
		fireAnimation = self:_fireAnimationName(),
		sound = self.FireSound,
		soundPitchVariation = self.FireSoundPitchVariation,
		fireDelay = self.FireInterval or self.fire_rate,
	}
end

function BaseFirearm:fire(): boolean
	local fired = self:_fireSingleShot(self:_fireOptions())
	if fired and self.CycleAfterFire then
		self:_playCycle({
			delay = self.CycleDelay or self.cycle_rest or 0,
			animation = self.CycleAnimation or "Cycle",
		})
	end
	return fired
end

function BaseFirearm:_reloadOptions()
	local startAnim = if self.ReloadStartAnimation ~= nil then self.ReloadStartAnimation else "Reload_Start"
	local loopAnim = if self.ReloadLoopAnimation ~= nil then self.ReloadLoopAnimation else "Reload_Loop"
	local endAnim = if self.ReloadEndAnimation ~= nil then self.ReloadEndAnimation else "Reload_End"

	return {
		startAnim = startAnim,
		loopAnim = loopAnim,
		endAnim = endAnim,
		loopWait = self.reload_loop,
		ammoCost = self.ReloadAmmoCost or 1,
	}
end

function BaseFirearm:reload(): boolean
	return self:_reloadByRound(self:_reloadOptions())
end

function BaseFirearm:activate()
	if self.Reloading then
		if self.CanCancelReload ~= false then
			self._reloadCancelled = true
		end
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function BaseFirearm:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()

	local fxFolder = self.FxFolder or ReplicatedStorage.Shared.Assets.Guns.Effects
	self:_setupFastCast(fxFolder, function(cast, result, velocity)
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level,
			self:_damageAtDistance(distance), self.KnockBack_Force)
	end)
end

function BaseFirearm:_on_unequip()
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
end

function BaseFirearm:_damageAtDistance(distance: number): number
	if self.range and distance < self.range then
		return self.damage
	end
	if self.far and distance <= self.far then
		return self.range_damage or self.damage
	end
	return self.far_damage or self.range_damage or self.damage
end

-- Empty firearms only make a mechanical click. Keep this in the firearm base so
-- every controller follows the same rule and cannot accidentally play recoil.
function BaseFirearm:_dryFire(): boolean
	local now = os.clock()
	if now < (self._nextDryFireAt or 0) then return false end
	self._nextDryFireAt = now + math.max(self.FireInterval or 0.2, 0.15)

	local folder = self.SoundFolder
	local sound: Sound?
	if folder then
		for _, name in { "empty", "b_empty", "dryfire", "click" } do
			local candidate = folder:FindFirstChild(name, true)
			if candidate and candidate:IsA("Sound") then
				sound = candidate
				break
			end
		end
	end
	local origin = self:_findModelPart(self.MuzzlePartName or "muzzle")
		or (self.actual_model and self.actual_model:FindFirstChildWhichIsA("BasePart", true))
	if sound and origin and origin:IsA("BasePart") then
		self:_play_sfx(sound, origin, nil, 0.1)
	elseif not self._warnedMissingEmptySound then
		self._warnedMissingEmptySound = true
		warn(("[%s] Missing empty/dry-fire sound in its SoundFolder"):format(self.className))
	end
	return true
end


function BaseFirearm:_magazineAnimation(name: string): string
	local emptyName = if name == "Reload_Start" or name == "Reload_Alt" then "Reload_Empty"
		elseif name == "Check" then "Check_Empty" else nil
	if self.Capacity == 0 and emptyName and self.RegisteredAnimations and self.RegisteredAnimations[emptyName] then
		return emptyName
	end
	return name
end

function BaseFirearm:_playAnim(name: string, bypassEquipped: boolean?)
	return BaseTool._playAnim(self, self:_magazineAnimation(name), bypassEquipped)
end

function BaseFirearm:_onBulletHit(cast, result, velocity, muzzle, penetrationLevel, damage, knockback_force)
	if not result then return end

	local instance  = result.Instance
	local direction = cast.UserData.Direction :: Vector3

	local hitModel    = instance:FindFirstAncestorOfClass("Model")
	local isCharacter = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

	if isCharacter then
		-- Apply damage to the character.
		self:_applyHit(result, damage, direction, knockback_force, cast.UserData)
		return
	end

	self:_applyHit(result, damage, direction, knockback_force, cast.UserData)

	-- // if roblox terrain return
	if instance:IsDescendantOf(workspace.Terrain) then
		return
	else	
		--	self:bullet_hole(result.Position, result.Normal)
	end
end

function BaseFirearm:_applyHit(result: RaycastResult, damage: number, direction: Vector3, knockback_force: number, metadata: any?)
	if not result then return end
	hit_connection:FireServer({
		Position  = result.Position,
		Normal    = result.Normal,
		Instance  = result.Instance,
		Material  = result.Material,
		Direction = direction,
		WeaponName = self.className,
		ArmorPenetration = self.Armor_Penetration_Level,
		HeadshotMultiplier = self.HeadshotMultiplier,
		ShotId = metadata and metadata.ShotId,
		PelletIndex = metadata and metadata.PelletIndex,
		PelletCount = metadata and metadata.PelletCount,
	}, damage, knockback_force)
end

-- // FastCast setup

function BaseFirearm:_setupFastCast(fxFolder: Folder, onHitCallback: (any, RaycastResult, Vector3) -> ())
	local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
	self.Caster, self.CasterBehavior = Util.setupFastCast({
		bulletTemplate   = fxFolder.Bullet,
		bulletContainer  = workspace.Game_Details.Effects.Bullets,
		penetrationLevel = self.Penetration_Level or 1,
		onHit            = onHitCallback,
	})
end

-- // Projectile firing

function BaseFirearm:_fireProjectile(bulletSpeed, penetrationLevel, damage, knockbackForce): boolean
	if self:_if_sprinting() or self:_if_jumping() then return false end

	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then warn(self.className .. ": Muzzle not found") return false end

	local camera = workspace.CurrentCamera
	if not camera then return false end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	-- Use the shared skip-transparent helper so invisible walls between the
	-- camera and the target don't deflect the aimed direction.
	local result    = utilities_module.raycastSkipTransparent(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir  = (targetPos - muzzle.Position).Unit

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, bulletSpeed, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false
	activeCast.UserData.Origin     = muzzle.Position
	activeCast.UserData.Shooter    = LOCAL_PLAYER

	self:_connect_FastCast(muzzle.Position, shootDir, bulletSpeed)
	return true
end

function BaseFirearm:_getAimedShot(muzzle: BasePart, distance: number?): (Vector3?, RaycastResult?)
	local camera = workspace.CurrentCamera
	if not camera then return nil, nil end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	local maxDistance = distance or self.FireRayDistance or 5000
	local result = utilities_module.raycastSkipTransparent(ray.Origin, ray.Direction * maxDistance, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * maxDistance)
	local shootDir = (targetPos - muzzle.Position).Unit

	if self.get_spread then
		shootDir = self:get_spread(muzzle, shootDir)
	end

	return shootDir, result
end

function BaseFirearm:_fireCastFromMuzzle(muzzle: BasePart, direction: Vector3, bulletSpeed: number)
	local activeCast = self.Caster:Fire(muzzle.Position, direction, bulletSpeed, self.CasterBehavior)
	activeCast.UserData = {
		Direction = direction,
		Penetrated = false,
		Origin = muzzle.Position,
		Shooter = LOCAL_PLAYER,
	}

	self:_connect_FastCast(muzzle.Position, direction, bulletSpeed, {
		bulletTemplate = ReplicatedStorage.Shared.Assets.Guns.Effects.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		isPenetration = false,
		penetrationLevel = self.Penetration_Level,
		damage = self.damage,
		knockbackForce = self.KnockBack_Force,
	})

	return activeCast
end

function BaseFirearm:_playShotFeedback(muzzle: BasePart, sound: Sound?, soundPitchVariation: number?)
	if sound then
		self:_play_sfx(sound, muzzle, nil, soundPitchVariation)
	end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	utilities_module.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)
end

function BaseFirearm:_fireSingleShot(options): boolean
	if self.Firing or self.Reloading or self.Cycling then return false end
	if not self:_canFireNow() then return false end
	if options and options.requireAiming ~= false and not self.Aiming then return false end
	if self.ForceBlockFire or self:_if_sprinting() or self:_if_jumping() then return false end
	if self.Capacity <= 0 then
		self:_dryFire()
		return false
	end

	local muzzle = if self._getMuzzlePart then self:_getMuzzlePart() else self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle or not muzzle:IsA("BasePart") then return false end
	if not self.Caster or not self.CasterBehavior then return false end

	local direction = self:_getAimedShot(muzzle, options and options.distance)
	if not direction then return false end

	self.Firing = true
	self:_fireCastFromMuzzle(muzzle, direction, options and options.bulletSpeed or self.BulletSpeed or 1000)
	if not options or options.consumeCapacity ~= false then
		self.Capacity -= options and options.capacityCost or 1
	end

	self:_stopAllExcept()
	local fireAnim = options and options.fireAnimation
	if not fireAnim then
		fireAnim = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	end
	local fireTrack = self:_playFireAnimation(fireAnim)
	self:_playShotFeedback(muzzle, options and options.sound or self.FireSound, options and options.soundPitchVariation)

	if fireTrack then
		fireTrack.Stopped:Once(function()
			if not self.Cycling then
				self:_restoreBase()
			end
		end)
	else
		self:_restoreBaseDeferred()
	end

	local fireDelay = options and options.fireDelay
	if fireDelay == nil then
		fireDelay = self.PostFireDelay or self.FireInterval or self.fire_rate
	end
	if fireDelay and fireDelay > 0 then
		task.wait(self:_effectiveFireDelay(fireDelay))
	end

	self.Firing = false
	self:_blockFireFor(self.PostFireDelay or 0)
	if self.Equipped and not self.Cycling and not self.Reloading then
		self:_restoreBaseDeferred()
	end
	return true
end

function BaseFirearm:_reloadByRound(options): boolean
	if not self.Equipped or self.Reloading or self.Equipping then return false end
	if self.Capacity >= self.Max_Capacity then return false end

	local reserveAmmo = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserveAmmo or not reserveAmmo:IsA("NumberValue") then
		warn(self.className .. ": Cannot reload because Reserve_Ammo is missing")
		return false
	end
	if reserveAmmo.Value <= 0 then
		self:notify("I don't have any more ammo...")
		self:_restoreBase()
		return false
	end

	self:_stopAllExcept()
	self.Reloading = true
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", true)

	local startAnim = if options and options.startAnim ~= nil then options.startAnim else "Reload_Start"
	local loopAnim = if options and options.loopAnim ~= nil then options.loopAnim else "Reload_Loop"
	local endAnim = if options and options.endAnim ~= nil then options.endAnim else "Reload_End"
	local startTrack = startAnim and self:_playAnim(startAnim) or nil
	if startTrack then startTrack.Stopped:Wait() end

	while self.Equipped and self.Capacity < self.Max_Capacity and reserveAmmo.Value > 0 and not self._reloadCancelled do
		local loopTrack = loopAnim and self:_playAnim(loopAnim) or nil
		if loopTrack then
			loopTrack.Stopped:Wait()
		elseif options and options.loopWait then
			task.wait(self.getFireDelay and self:getFireDelay(options.loopWait) or options.loopWait)
		end
		if self._reloadCancelled then break end
		if options and options.stopAfterLoop and options.stopAfterLoop(self) then break end

		self.Capacity += 1
		self:_fire_ammo(options and options.ammoCost or 1)
	end

	if not self._reloadCancelled then
		local endTrack = endAnim and self:_playAnim(endAnim) or nil
		if endTrack then endTrack.Stopped:Wait() end
	end

	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_blockFireFor(self.PostReloadDelay or 0)
	self:_restoreBaseDeferred()
	return true
end

-- // Muzzle flash

function BaseFirearm:emit_effect(effect, CFrame_Value, emissions, parent, attach_to_parent)
	for _, child in ipairs(effect:GetDescendants()) do
		local emit_count = emissions[child.Name]

		if not emit_count then
			continue
		end

		local clone = child:Clone()

		if attach_to_parent then
			clone.Parent = parent

			if clone:IsA("ParticleEmitter") then
				clone.Enabled = true
				clone:Emit(emit_count)

				task.delay(clone.Lifetime.Max + 0.1, function()
					if clone then
						clone:Destroy()
					end
				end)
			end

			continue
		end


		local part = Instance.new("Part")
		part.Size = Vector3.new(0.05, 0.05, 0.05)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.CFrame = CFrame_Value
		part.Parent = workspace


		clone.Parent = part

		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emit_count)

			task.delay(clone.Lifetime.Max + 0.1, function()
				if part then
					part:Destroy()
				end
			end)
		end
	end

	vfx_cast_event:FireServer(
		effect,
		CFrame_Value,
		emissions,
		parent,
		attach_to_parent
	)
end

-- // Generic reload sequence

function BaseFirearm:_reloadSequence(startAnimName, loopAnimName, endAnimName, onLoopCallback, maxAmmo, currentAmmo): boolean
	if self.Reloading or currentAmmo >= maxAmmo then return false end

	self:_stopAllExcept()
	self.Reloading        = true
	self._reloadCancelled = false

	local anims = self.RegisteredAnimations
	if not anims then self.Reloading = false; return false end

	if startAnimName then startAnimName = self:_magazineAnimation(startAnimName) end
	if startAnimName and anims[startAnimName] then
		self:_playAnim(startAnimName).Stopped:Wait()
	end

	while currentAmmo < maxAmmo and not self._reloadCancelled do
		if loopAnimName and anims[loopAnimName] then
			self:_playAnim(loopAnimName).Stopped:Wait()
		end
		if self._reloadCancelled then break end
		currentAmmo += 1
		if onLoopCallback then onLoopCallback(currentAmmo) end
	end

	if not self._reloadCancelled then
		if endAnimName and anims[endAnimName] then
			self:_playAnim(endAnimName).Stopped:Wait()
		end
	else
		for _, name in ipairs({ startAnimName, loopAnimName, endAnimName }) do
			if name and anims[name] and anims[name].IsPlaying then anims[name]:Stop(CUT) end
		end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	return true
end

-- // Replication

function BaseFirearm:_connect_FastCast(...)
	fast_cast_replication:FireServer(...)
end

function BaseFirearm:_play_sfx(...)
	replicant_service.ConnectSfx(LOCAL_PLAYER, ...)
end

function BaseFirearm:_fire_ammo(count)
	ammo_communication:FireServer(self.tool, count or 1)
	print("Firing ammo:", count)
end

-- // Aiming UI

function BaseFirearm:_enable_aiming_ui(max_aiming: number)
	local aiming_gui = game.Players.LocalPlayer.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = false
	aiming_gui.Scoped_In.Visible = true

	local scoped = aiming_gui.Scoped_In.main
	local down, left, right, up = scoped.down, scoped.left, scoped.right, scoped.up

	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
	if not root or not humanoid or character ~= game.Players.LocalPlayer.Character then
		return
	end

	if self.character_connection then
		self.character_connection:Disconnect()
	end

	local fixedSpread = self.FixedAimingSpread
	local currentSpread = fixedSpread or 0

	self.character_connection = RunService.RenderStepped:Connect(function()
		if not root or not humanoid then
			return
		end

		local holdingBreath = character:GetAttribute("HoldBreathe") == true
		local targetSpread

		if fixedSpread then
			targetSpread = fixedSpread
		elseif holdingBreath then
			if not self._breathStartTime then
				self._breathStartTime = tick()
				self._spreadAtBreath = currentSpread
			end

			local breathHeldFor = tick() - self._breathStartTime
			local focusMultiplier = character:GetAttribute("OrderFocusMultiplier") or 1
			local windUp = math.clamp(breathHeldFor / (0.5 / focusMultiplier), 0, 1)

			local breathBonus = 5 * focusMultiplier

			targetSpread = (self._spreadAtBreath or currentSpread)
				+ ((-breathBonus) - (self._spreadAtBreath or currentSpread)) * windUp
		else
			self._breathStartTime = nil
			self._spreadAtBreath = nil

			local speed = Vector3.new(
				root.AssemblyLinearVelocity.X,
				0,
				root.AssemblyLinearVelocity.Z
			).Magnitude

			local alpha = (humanoid.WalkSpeed > 0)
				and math.clamp(speed / humanoid.WalkSpeed, 0, 1)
				or 0

			targetSpread = alpha * max_aiming
		end

		currentSpread = currentSpread + (targetSpread - currentSpread) * 0.3

		local offset = math.max(1, 5 + currentSpread)

		up.Position    = UDim2.new(0.5, 0, 0, -offset)
		down.Position  = UDim2.new(0.5, 0, 1, offset)
		left.Position  = UDim2.new(0, -offset, 0.5, 0)
		right.Position = UDim2.new(1, offset, 0.5, 0)
	end)
end

function BaseFirearm:_bounce_scoped_ui()
	local Scoped_In = LOCAL_PLAYER.PlayerGui.Aiming.Scoped_In
	local main = Scoped_In.main

	local currentSize = main.Size.X.Offset
	local kickSize = currentSize + 40

	TweenService:Create(main, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, kickSize, 0, kickSize)
	}):Play()

	task.delay(0.03, function()
		TweenService:Create(main, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, currentSize, 0, currentSize)
		}):Play()
	end)
end

function BaseFirearm:_disable_aiming_ui()
	local aiming_gui = LOCAL_PLAYER.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = true
	aiming_gui.Scoped_In.Visible = false
	if self.character_connection then
		self.character_connection:Disconnect()
		self.character_connection = nil
	end
end

-- // Notifications


function BaseFirearm:end_ammo_check(force: boolean?)
	local displayId = self._ammoCheckDisplayId
	local shownAt = self._ammoCheckShownAt
	local remaining = force and 0
		or math.max(0, MIN_AMMO_CHECK_DISPLAY_TIME - (shownAt and (os.clock() - shownAt) or 0))

	local function finishAmmoCheck()
		if not force and (self._ammoCheckHeld or displayId ~= self._ammoCheckDisplayId) then return end

		local checkTrack = self._ammoCheckTrack
		if self._ammoCheckPaused and checkTrack and checkTrack.IsPlaying then
			self._ammoCheckPaused = false
			checkTrack:AdjustSpeed(self.animation_speeds and self.animation_speeds[self._ammoCheckAnimationName] or 1)
		end

		if self._ammoCheckUtils and type(self._ammoCheckUtils.hide) == "function" then
			task.spawn(self._ammoCheckUtils.hide)
		end
	end

	if force then
		finishAmmoCheck()
	else
		task.delay(remaining, finishAmmoCheck)
	end
end

function BaseFirearm:ammo_check()
	local checkName = self:_magazineAnimation("Check")
	if not self.RegisteredAnimations or not self.RegisteredAnimations[checkName] then return end
	if self:_isBusy() or self.Checking or self.Check_Delayed then return end
	if self.Equipping then return end
	if not self.Equipped then return end

	local reserveAmmo = self.tool:FindFirstChild("Reserve_Ammo")
	if not reserveAmmo then
		warn("BaseTool: Cannot check ammo because Reserve_Ammo is missing from", self.tool:GetFullName())
		return
	end

	local actualModel = self.actual_model
	if not actualModel then
		warn("BaseTool: Cannot check ammo because the equipped model is missing for", self.className)
		return
	end

	local ammoCheckPartName = self.AmmoCheckPartName or self.className .. "_Middle"
	local middle = actualModel:FindFirstChild(ammoCheckPartName, true)
		or actualModel.PrimaryPart
		or actualModel:FindFirstChildWhichIsA("BasePart", true)
	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then
		for _, descendant in ipairs(actualModel:GetDescendants()) do
			if descendant:IsA("BasePart") and string.find(string.lower(descendant.Name), "muzzle", 1, true) then
				muzzle = descendant
				break
			end
		end
	end
	if not middle or not middle:IsA("BasePart") then
		warn("BaseFirearm: Cannot check ammo because the equipped model has no usable parts for", self.className)
		return
	end
	if not muzzle or not muzzle:IsA("BasePart") then
		-- The ammo display only needs a stable weld target. Some cosmetic model
		-- variants omit their dedicated muzzle marker, so use the body part.
		muzzle = middle
	end

	self:_set_sprint_arms(true)
	self.Checking     = true
	self.Check_Delayed = true
	self._ammoCheckDisplayId = (self._ammoCheckDisplayId or 0) + 1

	local ammo_check_part, ammo_check_utils
	local cam = workspace.CurrentCamera
	if not cam:FindFirstChild("Ammo_Check") then
		ammo_check_part  = game.ReplicatedStorage.Shared.Assets.Guns.Effects.Ammo_Check:Clone()
		ammo_check_part.Parent = cam
		ammo_check_utils = require(ammo_check_part.Utils)
	else
		ammo_check_part  = cam.Ammo_Check
		ammo_check_utils = require(cam.Ammo_Check.Utils)
	end
	self._ammoCheckUtils = ammo_check_utils

	self:_stopLayer(1)
	self:_killAimTracks()
	if self.RegisteredAnimations.Hold and self.RegisteredAnimations.Hold.IsPlaying then
		self.RegisteredAnimations.Hold:Stop(CUT)
	end

	local checkTrack = self.RegisteredAnimations[checkName]
	self._ammoCheckTrack = checkTrack
	self._ammoCheckAnimationName = checkName
	self._ammoCheckPaused = false
	checkTrack:AdjustWeight(1)
	self:_playAnim(checkName)

	-- Leave enough of the animation after this point to close and recock the gun.
	-- Releasing the ammo-check key before this point simply lets it finish normally.
	task.delay(self.AmmoCheckHoldTime or 0.65, function()
		if self.Checking and self._ammoCheckHeld and checkTrack.IsPlaying then
			self._ammoCheckPaused = true
			checkTrack:AdjustSpeed(0)
		end
	end)

	ammo_check_part.CFrame = middle.CFrame + middle.CFrame.rightVector * -0.5 + middle.CFrame.upVector * 1


	if not ammo_check_part:FindFirstChild("WeldConstraint") then
		local weld   = Instance.new("WeldConstraint")
		weld.Part0   = ammo_check_part
		weld.Part1   = muzzle
		weld.Parent  = ammo_check_part
	end

	ammo_check_utils.utils(self.Ammo_Type, math.clamp(self.Capacity / self.Max_Capacity, 0, 1),
		false, reserveAmmo.Value / (self.Max_Capacity * 3))
	self._ammoCheckShownAt = os.clock()
	if not self._ammoCheckHeld then
		self:end_ammo_check()
	end

	checkTrack.Stopped:Wait()

	self._ammoCheckPaused = false
	self.Checking = false
	self:_restoreBase()
	self:_set_sprint_arms(false)

	task.delay(self.Check_Delay or 1, function()
		self.Check_Delayed = false
	end)
end


function BaseFirearm:_fireMuzzleFlash()
	if not self.FireEmissions then return end
	if not self.actual_model then return end

	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then return end

	local emissions = {}

	for effect, value in pairs(self.FireEmissions) do
		if type(value) == "table" and value.chance then
			if math.random() <= value.chance then
				emissions[effect] = value.count
			end

		elseif type(value) == "function" then
			emissions[effect] = value()

		else
			emissions[effect] = value
		end
	end

	if math.random(1, 2) == 1 then
		emissions.flash = 1
		emissions.flash_general = 1
	end

	self:emit_effect(
		ReplicatedStorage.Shared.Assets.Guns.Effects.Muzzle_Flash,
		muzzle.CFrame * CFrame.new(-0.1, 0, -2),
		emissions,
		muzzle,
		false
	)
end

function BaseFirearm:bullet_hole(position: Vector3, normal: Vector3)
	local folder = workspace.Game_Details.Effects.BulletHoles
	local clone  = FX_BULLET_HOLE:Clone()
	clone.CFrame = CFrame.new(position, position + normal)
	clone.Parent = folder
	texture_event:FireServer(FX_BULLET_HOLE, position, normal, folder)
end

function BaseFirearm:emit_casing(casing: Part, origin: CFrame, direction: Vector3)
	print("Fired casing event with:", casing.Name, origin, direction)
	replicant_service.HandleCasingReplication(LOCAL_PLAYER, casing, origin, direction)
	casing_event:FireServer(casing, origin, direction)
end

-- // Stubs


return BaseFirearm
