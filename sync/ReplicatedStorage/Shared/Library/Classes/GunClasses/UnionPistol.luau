--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Parent.Types)
local BasePistol = require(script.Parent.Parent.BasePistol)
local Util = require(script.Parent.Parent.Parent.Util)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local FxFolder = GunAssets.Effects
local SoundFolder = GunAssets.Sounds:FindFirstChild("UnionPistol")

local function findAnimation(folder: Instance?, names: { string }): Animation?
	if not folder then
		return nil
	end

	for _, name in names do
		print("Searching for animation:", name)
		local direct = folder:FindFirstChild(name, true)
		print("Found direct:", direct and direct.Name)
		if direct and direct:IsA("Animation") then
			print("Found direct match:", direct.Name)
			return direct
		else
			print("No direct match found, searching parent")
			local search = folder.Parent:FindFirstChild(name, true)
			if search and search:IsA("Animation") then
				print("Found search match:", search.Name)
				return search
			end
		end
		
		print("No match found for", name)
	end

	return nil
end

local function loadSteyrAnimations(): { [string]: Animation }
	local guns = Assets.Animations.Tools.Guns
	local folder = guns:FindFirstChild("steyr") or guns:FindFirstChild("UnionPistol")
	local graceFolder = guns:FindFirstChild("GraceRevolver")
	local bindings = {
		Hold = { "GraceRevolver_Held" },
		Aim = { "GraceRevolver_Aim" },
		Aim_Left = { "GraceRevolver_Aim_left" },
		TwoHand_Hold = { "alt_changeaim" },
		TwoHand_Aim = { "alt_changeaim" },
		TwoHand_Aim_Left = { "alt_changeaim_left" },
		Fire = { "fire" },
		Fire_Left = { "fire" },
		TwoHand_Fire = { "alt_changefire" },
		TwoHand_Fire_Left = { "alt_changefire_left" },
		Draw = { "steyrdraw" },
		Check = { "check" },
		Reload_Start = { "reload_start" },
		Reload_Start_Vet = { "reload_start_vet" },
		Reload_Loop = { "reload_loop" },
		Reload_One_Vet = { "reload_one_vet" },
		Reload_Clip = { "reload_clip" },
		Reload_Empty = { "reload_empty" },
		Reload_End = { "reload_end" },
	}

	local result: { [string]: Animation } = {}
	for key, names in bindings do
		local animation = findAnimation(folder, names)
		if animation then
			result[key] = animation
		end
	end

	-- The Union's one-handed ADS pose uses Grace's authored pistol animations.
	local graceAim = findAnimation(graceFolder, { "GraceRevolver_Aim" })
	local graceAimLeft = findAnimation(graceFolder, { "GraceRevolver_Aim_left" })
	if graceAim then result.Aim = graceAim end
	if graceAimLeft then result.Aim_Left = graceAimLeft else result.Aim_Left = graceAim end

	return result
end

local STANDARD_RPM = 160
local TWO_HANDED_RPM = 134
local BLACK_HAND_RPM = 172
local BLACK_HAND_TWO_HANDED_RPM = 144
local BULLET_SPEED = 800
local INDIVIDUAL_FULL_RELOAD_TIME = 6.45
local VETERAN_CLIP_RELOAD_TIME = 2.25
local TWO_HANDED_WALK_MULTIPLIER = 0.75

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	TwoHand_Hold = 0,
	TwoHand_Aim = 0,
	TwoHand_Aim_Left = 0,

	Fire = 1,
	Fire_Left = 1,
	TwoHand_Fire = 1,
	TwoHand_Fire_Left = 1,

	Draw = 2,
	Check = 2,
	Reload_Start = 2,
	Reload_Start_Vet = 2,
	Reload_Loop = 2,
	Reload_One_Vet = 2,
	Reload_Clip = 2,
	Reload_Empty = 2,
	Reload_End = 2,
}

local UnionPistol = {}
UnionPistol.__index = UnionPistol
setmetatable(UnionPistol, { __index = BasePistol })

export type UnionPistol = typeof(setmetatable({} :: any, UnionPistol))

local function hasPerk(perkName: string): boolean
	local player = LOCAL_PLAYER
	local character = player and player.Character
	if character and character:GetAttribute(perkName) == true then return true end
	if player and player:GetAttribute(perkName) == true then return true end
	local playerData = player and player:FindFirstChild("PlayerData")
	local data = playerData and playerData:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and (perks:FindFirstChild(perkName) or perks:FindFirstChild(perkName:gsub(" ", "")))
	if not perk then return false end
	if perk:IsA("BoolValue") then return perk.Value end
	return true
end

local function findSteyrModel(): Model?
	local source = GunAssets.ToolModels:FindFirstChild("steyr")
		or GunAssets.ToolModels:FindFirstChild("UnionPistol")
	if source and source:IsA("Model") then return source end
	local development = workspace:FindFirstChild("Development_Storage")
	local models = development and development:FindFirstChild("weapon_models")
	local fallback = models and models:FindFirstChild("steyr")
	return if fallback and fallback:IsA("Model") then fallback else nil
end

local function playToDuration(self: UnionPistol, animationName: string, duration: number): boolean
	local animations = self.RegisteredAnimations
	local available = animations and animations[animationName]
	if not available then
		task.wait(duration)
		return self.Equipped and not self._reloadCancelled
	end
	local track = self:_playAnim(animationName)
	if not track then return false end
	if track.Length > 0 then track:AdjustSpeed(track.Length / math.max(duration, 0.05)) end
	track.Stopped:Wait()
	return self.Equipped and not self._reloadCancelled
end

function UnionPistol.new(info: Types.BaseToolCreateInfo): UnionPistol
	local self = setmetatable(BasePistol.new(info), UnionPistol)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand")

	self.className = "UnionPistol"
	self.name = "UnionPistol"
	self.item_image = UnionPistol.Tool_Image
	self.Designation = "Secondary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.model_reference = findSteyrModel()
	self.holster_reference = GunAssets.Holsters:FindFirstChild("steyrHolster")
		or GunAssets.Holsters:FindFirstChild("UnionPistolHolster")
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
		C1 = CFrame.identity,
	}

	self.AnimationGunType = "steyr"
	self._prepareAnimations = function(current)
		current.animations = loadSteyrAnimations()
	end
	self.animations = nil
	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.18 or 0.275),
		Aim = 1 / (blackHand and 0.172 or 0.2),
		Aim_Left = 1 / (blackHand and 0.172 or 0.2),
		TwoHand_Aim = 1 / (blackHand and 0.172 or 0.2),
		TwoHand_Aim_Left = 1 / (blackHand and 0.172 or 0.2),
	}

	self.damage = 90
	self.Max_Capacity = 8
	self.Capacity = 8
	self.Starting_Reserve_Ammo = veteran and 24 or 16
	self.Max_Reserve_Ammo = 24
	self.Ammo_Type = "9mm Lead"
	self.Penetration_Level = 1
	self.Armor_Penetration_Level = 1
	self.KnockBack_Force = 6
	self.Aiming_Number = 80
	self.Accuracy = 7
	self.Moving_Accuracy = 55
	self.OneHandAccuracy = 7
	self.OneHandMovingAccuracy = 55
	self.TwoHandAccuracy = 4
	self.TwoHandMovingAccuracy = 35
	self.recoil = 42
	self.recoil_count = 7
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.IsVeteran = veteran
	self.IsBlackHand = blackHand
	self.TwoHanded = false
	self.FireInterval = 60 / (blackHand and BLACK_HAND_RPM or STANDARD_RPM)
	self.Can_Drop = true
	self._reloadCancelled = false
	self:_initShoulderTracking()
	return self
end

function UnionPistol:_damageAtDistance(distance: number): number
	if distance < 30 then return 90 end
	if distance >= 225 then return 60 end
	return 80 + (distance - 30) / 195 * (60 - 80)
end

function UnionPistol:_aimTrack(): AnimationTrack?
	local animations = self.RegisteredAnimations
	if self.TwoHanded and animations then
		return self.current_shoulder == "Right" and animations.TwoHand_Aim or animations.TwoHand_Aim_Left
	end
	return BasePistol._aimTrack(self)
end

function UnionPistol:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	self.TwoHanded = not self.TwoHanded
	self.Accuracy = self.TwoHanded and self.TwoHandAccuracy or self.OneHandAccuracy
	self.Moving_Accuracy = self.TwoHanded and self.TwoHandMovingAccuracy or self.OneHandMovingAccuracy
	self.recoil = self.TwoHanded and 28 or 42
	self.recoil_count = self.TwoHanded and 5 or 7
	local rpm = if self.TwoHanded
		then (self.IsBlackHand and BLACK_HAND_TWO_HANDED_RPM or TWO_HANDED_RPM)
		else (self.IsBlackHand and BLACK_HAND_RPM or STANDARD_RPM)
	self.FireInterval = 60 / rpm
	self.Alting = false
	if self.Aiming then
		self:_killAimTracks()
		local track = self:_aimTrack()
		if track then track:Play(0.15) end
		self:_applyStanceWalkSpeed()
	else
		self:_restoreBase()
	end
	self:notify(self.TwoHanded and "Two-handed stance" or "One-handed stance")
end

function UnionPistol:_applyStanceWalkSpeed()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if not self._walkSpeedBeforeStance then self._walkSpeedBeforeStance = humanoid.WalkSpeed end
	humanoid.WalkSpeed = self.TwoHanded and self.Aiming
		and self._walkSpeedBeforeStance * TWO_HANDED_WALK_MULTIPLIER
		or self._walkSpeedBeforeStance
end

function UnionPistol:aim()
	BasePistol.aim(self)
	if self.Aiming then self:_applyStanceWalkSpeed() end
end

function UnionPistol:endAiming()
	BasePistol.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeStance then humanoid.WalkSpeed = self._walkSpeedBeforeStance end
	self._walkSpeedBeforeStance = nil
end

function UnionPistol:fire()
	if self.Firing or self.Reloading or not self.Aiming or self.ForceBlockFire then return end
	if self:_if_sprinting() or self:_if_jumping() then return end
	if self.Capacity <= 0 then
		self:_dryFire()
		return
	end
	local muzzle = self:_findModelPart(self.MuzzlePartName)
	local camera = workspace.CurrentCamera
	if not muzzle or not camera then return end

	self.Firing = true
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
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
	local animation = if self.TwoHanded
		then (left and "TwoHand_Fire_Left" or "TwoHand_Fire")
		else (left and "Fire_Left" or "Fire")
	self:_playFireAnimation(animation)
	local sound = SoundFolder and (SoundFolder:FindFirstChild("fire") or SoundFolder:FindFirstChild("shot"))
	if not sound then
		local fallback = GunAssets.Sounds:FindFirstChild("AuclairPistol")
		sound = fallback and fallback:FindFirstChild("fire")
	end
	if sound then self:_play_sfx(sound, muzzle) end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)
	task.wait(self:getFireDelay(self.FireInterval))
	self.Firing = false
	self:_restoreBaseDeferred()
end

function UnionPistol:reload()
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

	local needed = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
	local useClip = self.IsVeteran and self.Capacity <= 1 and needed > 0
	if useClip then
		if playToDuration(self, "Reload_Clip", VETERAN_CLIP_RELOAD_TIME) then
			self.Capacity += needed
			self:_fire_ammo(needed)
		end
	else
		-- Scale the authored start, round insertions, and closing action so an
		-- empty eight-round reload lasts the documented 6.45 seconds.
		local perAction = INDIVIDUAL_FULL_RELOAD_TIME / (self.Max_Capacity + 2)
		local startName = self.IsVeteran and "Reload_Start_Vet" or "Reload_Start"
		playToDuration(self, startName, perAction)
		for _ = 1, needed do
			if not self.Equipped or self._reloadCancelled then break end
			local loopName = self.IsVeteran and "Reload_One_Vet" or "Reload_Loop"
			if not playToDuration(self, loopName, perAction) then break end
			self.Capacity += 1
			self:_fire_ammo(1)
		end
		if self.Equipped and not self._reloadCancelled then playToDuration(self, "Reload_End", perAction) end
	end

	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function UnionPistol:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function UnionPistol:_on_equip()
	self.Equipped = true
	-- Union has no authored sprint overlay; use Grace's compatible one while
	-- this single-handed pistol is equipped.
	local character = LOCAL_PLAYER.Character
	if character then character:SetAttribute("Sprint_Animation", "GraceRevolver") end
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level,
			self:_damageAtDistance(distance), self.KnockBack_Force)
	end)

	-- Authored Steyr clips use sfx_<sound name> keyframes. Resolve those names
	-- directly against the UnionPistol folder, including the newly added reload
	-- sounds (clip_remove, roundplace, slide_back, clip_place, clip_load, and
	-- slide_forward).
	local animations = self.RegisteredAnimations
	if animations and SoundFolder then
		for _, track in animations do
			table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)
				if keyframe:sub(1, 4) ~= "sfx_" then return end
				local sound = SoundFolder:FindFirstChild(keyframe:sub(5))
				local origin = self:_findModelPart(self.MuzzlePartName)
					or (self.actual_model and self.actual_model:FindFirstChild("hitbox", true))
				if sound and sound:IsA("Sound") and origin and origin:IsA("BasePart") then
					self:_play_sfx(sound, origin, nil, 0.1)
				end
			end))
		end
	end
end

function UnionPistol:_on_unequip()
	self:endAiming()
	self.Equipped = false
	self.Firing = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = true
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
end

function UnionPistol:Destroy()
	self:_disconnectInput()
	BasePistol.destroy(self)
end

UnionPistol.Tool_Image = "rbxassetid://17601078078"
UnionPistol.Medal_Cost = 0
UnionPistol.Weight = 1
UnionPistol.Designation = "Secondary"

return UnionPistol
