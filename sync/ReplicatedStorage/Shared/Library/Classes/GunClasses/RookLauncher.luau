local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Rules = require(ReplicatedStorage.Shared.Library.RookLauncherRules)
local Class = require(script.Parent.LegacyGunFactory).create({
	className = "RookLauncher",
	AuthoredWelds = {
		equipc0 = CFrame.new(0.405620575, -0.918596983, -0.570411682, 0, 0, -1, 0.99999994, 0, 0, 0, -0.999998629, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = true,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.09724617, -0.126744747, 0.538330078, 0.342024028, 0.939687192, 0, 0.939691246, -0.342022538, 0, 0, 0, -0.999995708),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.09724617, -0.126744747, 0.538330078, 0.342024028, 0.939687192, 0, 0.939691246, -0.342022538, 0, 0, 0, -0.999995708),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "rooklauncher",
	AnimationGunType = "rooklauncher",
	WeaponCategory = "Rifle",
	Designation = "Nil",
	ClassEquipment = true,
	Weight = 2,
	LegacyStats = {
		name = "Mining Bomb Launcher",
		desc = "Fire a long range Mining Bomb, destroying the environment as well as concussing any souls unfortunate to be nearby.\n\nIn-effective in active combat due to the concentrated charge and little shrapnel.",
		lore = "The Rook Division sought for a way to blast rocks at a distance\226\128\148in these tunnels, collapses were common and our soldiers are not stupid\226\128\148they knew they could not keep mining in a straight line especially with a chance of the ceiling falling on their heads.\n\nUsing a forgotten blueprint design of a cut down \'Judgement\' grenade launching device that never reached trials, the Rook Division worked closely with the Solace Coalition to develop a long ranged Mining Bomb Launcher.\n\nThe problem however, was the charge. Pure TNT is expensive\226\128\148relatively speaking, not much use for cash nowadays\226\128\148and had rather annoying opposition from the Officer Watch, dictating that the TNT should be used for mortar shells instead.\n\nSeeking an alternative to the Officer Watch\'s rather idiotic thinking that they could employ mortar shells under the grounds, the Rook Division stumbled upon a Bandit group which has recently blown a hole through to a supply point at Low Texas using a make-shift scavenged compound explosive\226\128\148and that, was their shining moment in these dark times.\n\n58.6% Ammonium Nitrate\n21% Aluminium Powder\n2.4% Charcoal\n18% TNT\n\nThe Mining Bomb Launcher, a design that nearly became lost to time, failing to meet trials for a second time.. has been given a new life\226\128\148and passed with flying colours.",
		icon = "18655468297",
		ammo_give = "Mining Bomb",
		melee_sound = "rifle",
		tooltype = "launcher",
		damage = 50,
		range = 80,
		range_damage = 0,
		far = 0,
		far_damage = 0,
		pen = 3,
		accuracy = 2,
		moving_accuracy = 2,
		fire_rate = 0.5,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 1,
		aim_speed = 0.4,
		recoil = 10,
		recoil_count = 6,
		ammo_reserves = 100,
		ammo_reserves_max = 100,
		capacity = 1,
		size = 2,
		melee_damage = 200,
		melee_swing_speed = 0.6,
		melee_range = 5,
		wound = 1,
		length = 2,
		movement = 2,
		firing_movement = 1,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 2.5,
		reload_empty = 0,
		reload_loop = 0,
		reload_end = 0,
		reload_alt = 0,
		lefthand = true,
	},
	bulletSpeed = 450,
})

local construct = Class.new
function Class.new(info)
	local self = construct(info)
	local equipment = ReplicatedStorage.Shared.Assets:FindFirstChild("Equipment")
	self.model_reference = equipment and equipment:FindFirstChild("rooklauncher")
	if not self.model_reference then error("[RookLauncher] Missing Shared.Assets.Equipment.rooklauncher") end
	self.motor_6d_data.Part1 = self.model_reference:FindFirstChild("hitbox", true)
		or self.model_reference.PrimaryPart or self.model_reference:FindFirstChildWhichIsA("BasePart", true)
	self:_applyWeaponWelds()
	self.Can_Drop = false
	self.FireEmissions = {smoke_medium = function() return 4 end, smoke_forward = function() return 3 end}
	return self
end

function Class:_finishLauncherAction()
	self.Firing = false
	self.Reloading = false
	self._launcherPending = false
	self:_cutAnim("Reload_Start", 0.1)
	if self.tool then self.Capacity = self.tool:GetAttribute("LauncherLoaded") and 1 or 0 end
	if self.Equipped then self:_restoreBase() end
end

function Class:_on_give(tool)
	self._launcherRemote = ReplicatedStorage.Shared.Library.Events:WaitForChild("RookLauncherAction")
	self.Capacity = tool:GetAttribute("LauncherLoaded") and 1 or 0
	self._launcherResponse = self._launcherRemote.OnClientEvent:Connect(function(target, action)
		if target ~= tool then return end
		self._launcherPending = false
		if action == "Fired" then
			self.Capacity = 0
			if not self.Equipped then self.Firing = false; return end
			local generation = self._equipGeneration
			self:_stopAllExcept()
			self:_playFireAnimation(self.current_shoulder == "Right" and "Fire" or "Fire_Left")
			local muzzle = self:_findModelPart("muzzle")
			if muzzle then self:_playShotFeedback(muzzle, self.FireSound, 0.1) end
			self:_blockFireFor(Rules.FireInterval)
			task.delay(Rules.FireInterval, function()
				if generation == self._equipGeneration then self.Firing = false; self:_restoreBase() end
			end)
		elseif action == "Reloading" then
			if self.Equipped then
				self.Reloading = true
				self:_stopAllExcept()
				self:_playAnim("Reload_Start", false, {speed = 1 / Rules.ReloadTime})
			end
		else
			self:_finishLauncherAction()
			if action == "Empty" and self.Equipped then self:notify("I don't have any Mining Bombs left.") end
		end
	end)
	self._launcherLoaded = tool:GetAttributeChangedSignal("LauncherLoaded"):Connect(function()
		self.Capacity = tool:GetAttribute("LauncherLoaded") and 1 or 0
	end)
	tool.Destroying:Connect(function()
		self._launcherResponse:Disconnect()
		self._launcherLoaded:Disconnect()
	end)
end

function Class:fire()
	if not self.Aiming or not self:_canFireNow() or self:_isBusy() or not self._launcherRemote then return false end
	if self.ForceBlockFire or self:_if_sprinting() or self:_if_jumping() then return false end
	if self.Capacity <= 0 then self:_dryFire(); return false end
	local muzzle = self:_findModelPart("muzzle")
	local direction = muzzle and self:_getAimedShot(muzzle)
	if not direction then return false end
	self.Firing = true
	self._launcherPending = true
	self._launcherRemote:FireServer(self.tool, "Fire", direction)
	self:_launcherWatchdog()
	return true
end

function Class:reload()
	if not self.Equipped or self:_isBusy() or not self._launcherRemote or self.Capacity > 0 then return false end
	local character = Players.LocalPlayer.Character
	if (character and character:GetAttribute("MiningBombLauncherCharges") or 0) <= 0 then
		self:notify("I don't have any Mining Bombs left.")
		return false
	end
	self.Reloading = true
	self._launcherPending = true
	self._launcherRemote:FireServer(self.tool, "Reload")
	self:_launcherWatchdog()
	return true
end

function Class:_launcherWatchdog()
	local generation = self._equipGeneration
	task.delay(5, function()
		if self._launcherPending and generation == self._equipGeneration then self:_finishLauncherAction() end
	end)
end

local unequip = Class._on_unequip
function Class:_on_unequip()
	if unequip then unequip(self) end
	self:_finishLauncherAction()
end
return Class
