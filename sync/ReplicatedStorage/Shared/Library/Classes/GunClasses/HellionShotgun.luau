--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseShotgun = require(script.Parent.Parent.BaseShotgun)
local Util = require(script.Parent.Parent.Parent.Util)
local createAnimationResolver = require(script.Parent.AnimationResolver)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local FxFolder = GunAssets.Effects
local rifleFallback = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local legacyAnimations = Assets.Animations.Tools.Guns:FindFirstChild("autosg")
local animation = createAnimationResolver("autosg_rig", legacyAnimations, rifleFallback)
local assetSounds = Assets:FindFirstChild("Sounds")
local toolSounds = assetSounds and assetSounds:FindFirstChild("tools")
local SoundFolder = (toolSounds and toolSounds:FindFirstChild("autosg"))
	or GunAssets.Sounds:FindFirstChild("autosg")
	or GunAssets.Sounds.PrinceRifle

local STANDARD_RPM = 150
local BLACK_HAND_RPM = 161
local BULLET_SPEED = 850
local STANDARD_FULL_RELOAD = 7.75
local VETERAN_FULL_RELOAD = 5.5
local SHOULDER_WALK_MULTIPLIER = 0.7

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0, Aim = 0, Aim_Left = 0,
	Shoulder_Hold = 0, Shoulder_Aim = 0, Shoulder_Aim_Left = 0,
	Fire = 1, Fire_Left = 1, Fire_Last = 1, Fire_Last_Left = 1,
	Shoulder_Fire = 1, Shoulder_Fire_Left = 1,
	Shoulder_Fire_Last = 1, Shoulder_Fire_Last_Left = 1,
	Draw = 2, Unequip = 2, Reload_Start = 2, Reload_Loop = 2,
	Reload_End = 2, Check = 2, Check_Empty = 2, Melee1 = 2, Melee2 = 2, Short = 2,
}

local HellionShotgun = {}
HellionShotgun.__index = HellionShotgun
setmetatable(HellionShotgun, { __index = BaseShotgun })

export type HellionShotgun = typeof(setmetatable({} :: any, HellionShotgun))

local function getModelReference(): Model?
	local source = GunAssets.ToolModels:FindFirstChild("autosg")
	if not source then return nil end
	if source:IsA("Model") then return source end

	local model = Instance.new("Model")
	model.Name = "autosg"
	local sourceClone = source:Clone()
	for _, child in ipairs(sourceClone:GetChildren()) do child.Parent = model end
	sourceClone:Destroy()
	-- The authored asset has both a Folder and the grip Part named "hitbox".
	-- ItemsService resolves Part1 by name, so keep that lookup unambiguous.
	local jointFolder = model:FindFirstChild("hitbox")
	if jointFolder and jointFolder:IsA("Folder") then jointFolder.Name = "joints" end
	local hitbox = model:FindFirstChild("hitbox", true)
	if hitbox and hitbox:IsA("BasePart") then model.PrimaryPart = hitbox end
	return model
end

local function findBasePartNamed(root: Instance, name: string): BasePart?
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == name then return descendant end
	end
	return nil
end

local function hasPerk(perkName: string): boolean
	local player = LOCAL_PLAYER
	local character = player and player.Character
	if character and character:GetAttribute(perkName) == true then return true end
	if player and player:GetAttribute(perkName) == true then return true end
	local playerData = player and player:FindFirstChild("PlayerData")
	local data = playerData and playerData:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and perks:FindFirstChild(perkName)
	if not perk then return false end
	if perk:IsA("BoolValue") then return perk.Value end
	return true
end

function HellionShotgun.new(info: Types.BaseToolCreateInfo): HellionShotgun
	local self = setmetatable(BaseShotgun.new(info), HellionShotgun)
	local veteran = hasPerk("Veteran")
	local blackHand = hasPerk("Black Hand") or hasPerk("BlackHand")

	self.className = "HellionShotgun"
	self.name = "HellionShotgun"
	self.item_image = HellionShotgun.Tool_Image
	self.ANIM_LAYERS = ANIM_LAYERS
	self.model_reference = getModelReference()
	self.holster_reference = GunAssets.Holsters:FindFirstChild("autosgHolster")
		or GunAssets.Holsters:FindFirstChild("HellionShotgunHolster")
	self.motor_6d_data = {
		Parent = "Right Arm", Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
		C1 = CFrame.identity,
		ReloadGripC0 = CFrame.new(0.254, -1.703, -0.566)
			* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Hold = animation({ "held" }, "PrinceRifle_Held"),
		Draw = animation({ "draw" }, "PrinceRifle_Draw"),
		Unequip = animation({ "unequip" }, "PrinceRifle_Unequip"),
		Aim = animation({ "aim" }, "PrinceRifle_Aim"),
		Aim_Left = animation({ "aim_left" }, "PrinceRifle_Aim_Left"),
		Fire = animation({ "fire" }, "PrinceRifle_Fire"),
		Fire_Left = animation({ "fire_left" }, "PrinceRifle_Fire_Left"),
		Fire_Last = animation({ "fire_last" }, "PrinceRifle_Fire"),
		Fire_Last_Left = animation({ "fire_last_left" }, "PrinceRifle_Fire_Left"),
		Shoulder_Hold = animation({ "locked" }, "PrinceRifle_Held"),
		Shoulder_Aim = animation({ "alt_changeaim" }, "PrinceRifle_Aim"),
		Shoulder_Aim_Left = animation({ "alt_changeaim_left" }, "PrinceRifle_Aim_Left"),
		Shoulder_Fire = animation({ "alt_changefire" }, "PrinceRifle_Fire"),
		Shoulder_Fire_Left = animation({ "alt_changefire_left" }, "PrinceRifle_Fire_Left"),
		Shoulder_Fire_Last = animation({ "alt_changefire_last" }, "PrinceRifle_Fire"),
		Shoulder_Fire_Last_Left = animation({ "alt_changefire_last_left" }, "PrinceRifle_Fire_Left"),
		Reload_Start = animation({ "reload_start" }, "PrinceRifle_Reload_Start"),
		Reload_Loop = animation({ "reload_loop" }, "PrinceRifle_Reload_Loop"),
		Reload_End = animation({ veteran and "reload_empty_vet" or "reload_empty" }, "PrinceRifle_Reload_End"),
		Check = animation({ "check" }, "PrinceRifle_Check"),
		Check_Empty = animation({ "check_empty" }, "PrinceRifle_Check"),
		Melee1 = animation("Melee1", "PrinceRifle_Melee1"),
		Melee2 = animation("Melee2", "PrinceRifle_Melee2"),
		Short = animation("Short", "PrinceRifle_Short"),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}
	self.animation_speeds = {
		Draw = 1 / (blackHand and 0.6 or 1),
		Aim = 1 / (blackHand and 0.3 or 0.35),
		Aim_Left = 1 / (blackHand and 0.3 or 0.35),
		Shoulder_Aim = 1 / (blackHand and 0.43 or 0.5),
		Shoulder_Aim_Left = 1 / (blackHand and 0.43 or 0.5),
	}

	self.damage = 22
	self.Max_Capacity = 7
	self.Capacity = 7
	self.Starting_Reserve_Ammo = 7
	self.Max_Reserve_Ammo = 14
	self.Ammo_Type = "00 Buckshot"
	self.PelletCount = 9
	self.HeadshotMultiplier = 1.2
	self.Penetration_Level = 0
	self.Armor_Penetration_Level = 2
	self.KnockBack_Force = 5
	self.recoil = 78
	self.recoil_count = 9
	self.Aiming_Number = 80
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireInterval = 60 / (blackHand and BLACK_HAND_RPM or STANDARD_RPM)
	self.FullReloadTime = veteran and VETERAN_FULL_RELOAD or STANDARD_FULL_RELOAD
	self.ShotgunSpread = 6
	self.ShoulderedSpread = 4
	self.Shouldered = false
	self.IsVeteran = veteran
	self.Can_Drop = true
	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = false
	self.FireEmissions = { smoke_medium = 4, smoke_forward = 6 }
	self:_initShoulderTracking()
	return self
end

function HellionShotgun:_damageAtDistance(distance: number): number
	if distance < 20 then return 22 end
	if distance <= 35 then return 12 end
	return 9
end

function HellionShotgun:get_pellet_directions(direction: Vector3, _spread: number?): { Vector3 }
	return BaseShotgun.get_pellet_directions(self, direction,
		self.Shouldered and self.ShoulderedSpread or self.ShotgunSpread)
end

function HellionShotgun:_aimTrack(): AnimationTrack?
	local animations = self.RegisteredAnimations
	if self.Shouldered and animations then
		return self.current_shoulder == "Right" and animations.Shoulder_Aim or animations.Shoulder_Aim_Left
	end
	return BaseShotgun._aimTrack(self)
end

function HellionShotgun:_killAimTracks()
	BaseShotgun._killAimTracks(self)
	local animations = self.RegisteredAnimations
	if not animations then return end
	for _, name in ipairs({ "Shoulder_Aim", "Shoulder_Aim_Left" }) do
		local track = animations[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

function HellionShotgun:_restoreBase()
	BaseShotgun._restoreBase(self)
	if self:_isBusy() or not self.Equipped or not self.Shouldered then return end
	local animations = self.RegisteredAnimations
	if not animations then return end
	if animations.Hold and animations.Hold.IsPlaying then animations.Hold:Stop(0.15) end
	if not self.Aiming and animations.Shoulder_Hold and not animations.Shoulder_Hold.IsPlaying then
		animations.Shoulder_Hold:Play(0.15)
	end
end

function HellionShotgun:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	self.Shouldered = not self.Shouldered
	self:_killAimTracks()
	local animations = self.RegisteredAnimations
	if not self.Shouldered and animations and animations.Shoulder_Hold and animations.Shoulder_Hold.IsPlaying then
		animations.Shoulder_Hold:Stop(0.15)
	end
	if self.Aiming then
		local track = self:_aimTrack()
		if track then track:Play(0.15) end
		local character = LOCAL_PLAYER.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if not self._walkSpeedBeforeShoulder then self._walkSpeedBeforeShoulder = humanoid.WalkSpeed end
			humanoid.WalkSpeed = self.Shouldered
				and self._walkSpeedBeforeShoulder * SHOULDER_WALK_MULTIPLIER
				or self._walkSpeedBeforeShoulder
		end
	end
	self.recoil = self.Shouldered and 52 or 78
	self.recoil_count = self.Shouldered and 6 or 9
	self:notify(self.Shouldered and "Stock shouldered" or "Stock lowered")
	self.Alting = false
	self:_restoreBase()
end

function HellionShotgun:aim()
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then self._walkSpeedBeforeShoulder = humanoid.WalkSpeed end
	BaseShotgun.aim(self)
	if humanoid and self.Aiming and self.Shouldered then
		humanoid.WalkSpeed = self._walkSpeedBeforeShoulder * SHOULDER_WALK_MULTIPLIER
	end
end

function HellionShotgun:endAiming()
	BaseShotgun.endAiming(self)
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and self._walkSpeedBeforeShoulder then humanoid.WalkSpeed = self._walkSpeedBeforeShoulder end
	self._walkSpeedBeforeShoulder = nil
	self:_restoreBase()
end

function HellionShotgun:fire()
	if self.Firing or self.Reloading or self.Cycling or not self.Aiming then return end
	if self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return end
	if self.Capacity <= 0 then
		self:_playFireAnimation(self.current_shoulder == "Right" and "Fire" or "Fire_Left", false)
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
	self:_firePellets(muzzle, (target - muzzle.Position).Unit, BULLET_SPEED, self.damage, self.KnockBack_Force)

	self.Capacity -= 1
	self:_stopAllExcept()
	local left = self.current_shoulder ~= "Right"
	local prefix = self.Shouldered and "Shoulder_" or ""
	local suffix = self.Capacity == 0 and "Fire_Last" or "Fire"
	self:_playFireAnimation(prefix .. suffix .. (left and "_Left" or ""))
	local sound = SoundFolder:FindFirstChild("fire")
	if sound then self:_play_sfx(sound, muzzle) end
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)
	task.wait(self.FireInterval)
	self.Firing = false
	self:_restoreBaseDeferred()
end

function HellionShotgun:reload()
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

	local shellsNeeded = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
	local animations = self.RegisteredAnimations
	local start = animations and animations.Reload_Start
	local loop = animations and animations.Reload_Loop
	local finish = animations and animations.Reload_End
	local authored = (start and start.Length or 0) + (loop and loop.Length or 0) * shellsNeeded
		+ (finish and finish.Length or 0)
	local targetDuration = self.FullReloadTime * (shellsNeeded / self.Max_Capacity)
	local speed = authored > 0 and authored / math.max(targetDuration, 0.1) or 1
	if start then local t = self:_playAnim("Reload_Start"); if t then t:AdjustSpeed(speed); t.Stopped:Wait() end end
	for _ = 1, shellsNeeded do
		if not self.Equipped or self._reloadCancelled or reserve.Value <= 0 then break end
		if loop then local t = self:_playAnim("Reload_Loop"); if t then t:AdjustSpeed(speed); t.Stopped:Wait() end end
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
	end
	if self.Equipped and not self._reloadCancelled and finish then
		local t = self:_playAnim("Reload_End"); if t then t:AdjustSpeed(speed); t.Stopped:Wait() end
	end
	self.Reloading = false
	self._reloadCancelled = false
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
end

function HellionShotgun:activate()
	if self.Reloading then self._reloadCancelled = true; return end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function HellionShotgun:_on_equip()
	self.Equipped = true
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

	local animations = self.RegisteredAnimations
	if not animations then return end
	for _, track in pairs(animations) do
		if not track:IsA("AnimationTrack") then continue end
		table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)
			local model = self.actual_model
			if not model then return end
			if keyframe:sub(1, 4) == "sfx_" then
				local sfx = SoundFolder:FindFirstChild("sfx")
				local sound = sfx and sfx:FindFirstChild(keyframe:sub(5))
				local muzzle = self:_findModelPart(self.MuzzlePartName)
				if sound and muzzle then self:_play_sfx(sound, muzzle, nil, 0.1) end
			elseif keyframe == "vfx_eject_casing" then
				local casing = findBasePartNamed(model, "casing")
				if casing then
					self:emit_casing(casing :: any, casing.CFrame, casing.CFrame.RightVector * 5)
				end
			end
		end))
	end
end

function HellionShotgun:_on_unequip()
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

HellionShotgun.Tool_Image = "rbxassetid://17496049645"
HellionShotgun.Medal_Cost = 0
HellionShotgun.Weight = 2
HellionShotgun.Designation = "Primary"

return HellionShotgun
