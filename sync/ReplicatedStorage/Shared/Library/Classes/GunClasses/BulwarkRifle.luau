local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BaseFirearm = require(script.Parent.Parent.BaseFirearm)
local Handling = require(script.Parent.Parent.Parent.WeaponHandling)
local BulwarkRifle = require(script.Parent.LegacyGunFactory).create({
	className = "LewisGun",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.267684937, -2.46884155, -0.482276917, 0, -2.84217094e-14, -1, 0.99999994, -5.55623067e-16, 0, 5.5562312e-16, -1, -2.84217094e-14),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.945495605, 0.903594494, 0.468746185, 2.14288557e-15, -0.642787576, -0.766044438, -0.999999762, 4.18500217e-15, -7.14295261e-16, -3.66503745e-15, 0.766044438, -0.642787576),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.945495605, 0.903594494, 0.468746185, 2.14288557e-15, -0.642787576, -0.766044438, -0.999999762, 4.18500217e-15, -7.14295261e-16, -3.66503745e-15, 0.766044438, -0.642787576),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "lewis",
	soundNames = {"BulwarkRifle", "lewis", "LewisGun"},
	AnimationGunType = "BulwarkRifle",
	animationMap = { ShieldPlace = "shieldplace" },
	WeaponCategory = "Rifle",
	Designation = "Primary",
	Weight = 3,
	reloadStartIsFullReload = true,
	bipod = true,
	fullReloadAnimation = "Reload_Start",
	LegacyStats = {
		name = "'Sword and Shield'",
		alt_name = "'Heart of Steel'",
		desc = "Guardian Lewis machine gun with a bipod, gun shield, and deployable cover.",
		icon = "119864425083906",
		ammo_give = ".303 Smokeless",
		damage = 120,
		range = 30,
		range_damage = 105,
		far = 90,
		far_damage = 90,
		pen = 2,
		armor_pen = 3,
		accuracy = 48,
		moving_accuracy = 48,
		fire_rate = 0.12,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 1,
		aim_speed = 0.6,
		recoil = 10,
		recoil_count = 2,
		ammo_reserves = 200,
		ammo_reserves_max = 200,
		capacity = 97,
		auto = true,
		blacklist = true,
		size = 2,
		melee_damage = 0,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 50,
		wallpen_studs = 3,
		wound = 1,
		length = 5,
		movement = 2,
		firing_movement = 0,
		firing_movement_last = 0.25,
		chamber = false,
		reload_start = 4.5,
		reload_empty = 1,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
	},
	bulletSpeed = 950,
})

local inheritedNew = BulwarkRifle.new
local inheritedEquip = BulwarkRifle._on_equip
local inheritedUnequip = BulwarkRifle._on_unequip
local inheritedFire = BulwarkRifle._fireConfiguredShot
local inheritedBipod = BulwarkRifle._isBipodActive
local inheritedAim = BulwarkRifle.aim
local inheritedReloadMultiplier = BulwarkRifle._reloadSpeedMultiplier
local function remote()
	return RS.Shared.Library.Events:FindFirstChild("BulwarkAbility")
end

function BulwarkRifle.new(info)
	local self = inheritedNew(info)
	self.DisableSteadyAimAccuracy = true
	-- Lewis uses the Veteran clips at their authored rates, without a blanket buff.
	self.VeteranReloadSpeed = 1
	self.CasingPartName = "casing"
	self.EjectionPartName = "ejection"
	local sounds = RS.Shared.Assets.Sounds.Guns:FindFirstChild("BulwarkRifle")
	if sounds then
		self.SoundFolder = sounds
		self.FireSound = sounds:FindFirstChild("fire")
	end
	return self
end


-- These action cues are explicit in the master script. Reload mechanics stay
-- on their authored sfx_bolt / sfx_mag_* keyframes.
function BulwarkRifle:_playConfiguredSound(name)
	local source = self.SoundFolder and self.SoundFolder:FindFirstChild(name, true)
	local character = Players.LocalPlayer.Character
	local origin = character and character:FindFirstChild("HumanoidRootPart")
	if source and source:IsA("Sound") and origin then self:_play_sfx(source, origin, nil, nil, nil, 0.1) end
end

function BulwarkRifle:_shouldPlayAnimationSound(name)
	-- The action path owns these cues, avoiding a duplicate if an animation
	-- also contains the same sound keyframe.
	return name ~= "draw" and name ~= "aimed" and name ~= "last" and name ~= "fire"
end

function BulwarkRifle:aim()
	local wasAiming = self.Aiming
	inheritedAim(self)
	if wasAiming or not self.Aiming then return end
	local generation, aimVersion = self._equipGeneration, self._aimVersion
	task.delay(self:_aimDuration(), function()
		if self.Equipped and self.Aiming and self._equipGeneration == generation and self._aimVersion == aimVersion then
			self:_playConfiguredSound("aimed")
		end
	end)
end

function BulwarkRifle:_playShotFeedback(muzzle, sound, variation, volumeAdjustment)
	BaseFirearm._playShotFeedback(self, muzzle, sound, variation, volumeAdjustment)
	if self.Capacity == 0 then self:_playConfiguredSound("last") end
end

function BulwarkRifle:_isBipodActive()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return self.Equipped and not self.Reloading and humanoid and root
		and humanoid.FloorMaterial ~= Enum.Material.Air
		and root.AssemblyLinearVelocity.Magnitude < 3 and inheritedBipod(self) or false
end

function BulwarkRifle:_getShotAccuracy()
	return self:_isBipodActive() and 2 or 48
end

function BulwarkRifle:_aimDuration()
	return Handling.Duration(Players.LocalPlayer, self:_isBipodActive() and 0.3 or 0.6, "aim")
end

function BulwarkRifle:melee() return false end

function BulwarkRifle:setAltMode()
	if not self.Equipped or self.Equipping or self:_isBusy() then return end
	local event = remote()
	if not event then return end
	self.Alting = true
	local generation = self._equipGeneration
	local track = self:_playAnim("ShieldPlace")
	if self:_waitActionPhase(nil, 0.2) then
		event:FireServer("Deploy")
		self:_waitActionPhase(track, 0.6)
	end
	if self._equipGeneration == generation then
		self.Alting = false
		self:_restoreBaseDeferred()
	end
end

local function specialty(character)
	return character and character:GetAttribute("Class") == "Vanguard"
end

function BulwarkRifle:_reloadSpeedMultiplier()
	local multiplier = inheritedReloadMultiplier(self)
	local character = Players.LocalPlayer.Character
	local elite = character and character:FindFirstChild("elitekit")
	local class = character and character:FindFirstChild("class")
	-- Modern class attributes can exist without the legacy class Value objects.
	if specialty(character) and not (elite and class and elite.Value == class.Value) then multiplier /= 0.8 end
	return multiplier
end

function BulwarkRifle:_fireConfiguredShot(delay)
	local character = Players.LocalPlayer.Character
	local generation = self._equipGeneration
	if character then character:SetAttribute("BulwarkFiring", true) end
	local result = inheritedFire(self, delay)
	if character and self._equipGeneration == generation then character:SetAttribute("BulwarkFiring", nil) end
	return result
end

function BulwarkRifle:reload()
	if not self.Equipped or self.Equipping or self:_isBusy() or self.Capacity >= self.Max_Capacity then return false end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or reserve.Value <= 0 then return false end
	local player = Players.LocalPlayer
	local character = player.Character
	local generation = self._equipGeneration
	local rounds = math.min(self.Max_Capacity - self.Capacity, reserve.Value)
	local empty = self.Capacity <= 0
	local duration = empty and self.RegisteredAnimations.Reload_Empty and self.reload_empty or self.reload_start
	local multiplier = self:_reloadSpeedMultiplier()
	if character then
		character:SetAttribute("BulwarkReloading", true)
	end
	self.Reloading = true
	self._reloadCancelled = false
	self:_stopAllExcept()
	player:SetAttribute("CantUnequip", true)
	local function phase(name, seconds, options)
		local track = self:_playAnim(name, false, options or {speed = 1 / seconds})
		local deadline = os.clock() + seconds / multiplier
		while os.clock() < deadline and self.Equipped and self._equipGeneration == generation and not self._reloadCancelled do
			task.wait(math.min(0.03, deadline - os.clock()))
		end
		if track then track:Stop(0) end
		return self.Equipped and self._equipGeneration == generation and not self._reloadCancelled
	end
	local completed = true
	if empty then
		-- Master: the empty bolt phase is 60% for Vanguard; the magazine phase is 80%.
		local boltDuration = self.reload_empty * (specialty(character) and 0.75 or 1)
		local boltName = self.RegisteredAnimations.Reload_Bolt and "Reload_Bolt" or "Cycle"
		completed = phase(boltName, boltDuration, {speed = 1 / boltDuration, veteran = false})
	end
	if completed then completed = phase(empty and self.RegisteredAnimations.Reload_Empty and "Reload_Empty" or "Reload_Start", duration) end
	if completed then
		self.Capacity += rounds
		self:_fire_ammo(rounds)
	end
	if self._equipGeneration == generation then
		self.Reloading = false
		self._reloadCancelled = false
		if character then character:SetAttribute("BulwarkReloading", nil) end
		player:SetAttribute("CantUnequip", nil)
		self:_restoreBaseDeferred()
	end
	return true
end

function BulwarkRifle:ammo_check()
	return BaseFirearm.ammo_check(self)
end

function BulwarkRifle:_on_equip()
	inheritedEquip(self)
	if self._bulwarkConnection then self._bulwarkConnection:Disconnect() end
	local elapsed = 0
	self._bulwarkConnection = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.15 then return end
		elapsed = 0
		local mounted = self.Equipped and self:_isBipodActive() and not self.Reloading
		local character = Players.LocalPlayer.Character
		if character then
			character:SetAttribute("WeaponAimDuration", self:_aimDuration())
		end
		local shield = self.actual_model and self.actual_model:FindFirstChild("parts")
		shield = shield and shield:FindFirstChild("shield")
		if shield and shield:IsA("BasePart") then shield.Transparency = mounted and 0 or 1 end
		local event = remote()
		if event then event:FireServer("Mount", mounted) end
	end)
end

function BulwarkRifle:_on_unequip()
	if self._bulwarkConnection then self._bulwarkConnection:Disconnect(); self._bulwarkConnection = nil end
	local character = Players.LocalPlayer.Character
	if character then
		character:SetAttribute("BulwarkReloading", nil)
		character:SetAttribute("BulwarkFiring", nil)
	end
	local event = remote()
	if event then event:FireServer("Mount", false) end
	inheritedUnequip(self)
end

return BulwarkRifle
