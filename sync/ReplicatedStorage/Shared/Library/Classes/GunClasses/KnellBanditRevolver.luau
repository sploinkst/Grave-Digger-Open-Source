local KnellBanditRevolver = require(script.Parent.LegacyGunFactory).create({
	className = "KnellBanditRevolver",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "pieper",
	AnimationGunType = "pieper",
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Knell' Bandit Revolver",
		desc = "Modification of the 'Knell' Silenced Revolver",
		icon = "128547123001673",
		ammo_give = "8mm Copper",
		damage = 105,
		range = 40,
		range_damage = 95,
		far = 60,
		far_damage = 80,
		pen = 2,
		accuracy = 10,
		moving_accuracy = 80,
		fire_rate = 0.34,
		draw_speed = 0.2,
		aim_speed = 0.15,
		recoil = 12,
		recoil_count = 6,
		ammo_reserves = 2,
		ammo_reserves_max = 3,
		capacity = 7,
		size = 1,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 50,
		wallpen_studs = 3,
		cycle = 0,
		cycle_rest = 0,
		wound = 1,
		length = 4,
		movement = 0.5,
		firing_movement = 1,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 1.65,
		reload_empty = 0,
		reload_loop = 0.5,
		reload_loop_after = 0.2,
		reload_end = 0.5,
	},
	bulletSpeed = 800,
})

local baseFire = KnellBanditRevolver.fire
function KnellBanditRevolver:setAltMode()
	if not self.Equipped or self:_isBusyForActivation() then return end
	self.Alt_Mode = not self.Alt_Mode
	self:notify(self.Alt_Mode and "Single action: cock, then fire" or "Double action: cock and fire")
end
function KnellBanditRevolver:fire()
	if not self.Equipped or self:_isBusyForActivation() then return false end
	if self.SlideLocked == false then
		local generation = self._equipGeneration
		local duration = self.Alt_Mode and 0.25 or 0.15
		self.Cycling = true
		self:_playConfiguredSound("hammer")
		self:_playAnim("Hammer_Pull", false, {restart=true})
		task.wait(duration / 1.5)
		if not self.Equipped or generation ~= self._equipGeneration then return false end
		self:_playConfiguredSound("rotate_cylinder")
		task.wait(duration - duration / 1.5)
		if not self.Equipped or generation ~= self._equipGeneration then return false end
		self.Cycling = false; self.SlideLocked = true
		if self.Alt_Mode then return false end
	end
	local fired = baseFire(self)
	if fired then self.SlideLocked = false end
	return fired
end
return KnellBanditRevolver
