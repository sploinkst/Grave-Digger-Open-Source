local HonourInsurgentPistol = require(script.Parent.LegacyGunFactory).create({
	className = "HonourInsurgentPistol",
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
	assetName = "mauser",
	AnimationGunType = "HonourPistol",
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Honour' Insurgent Pistol",
		desc = "Modification of the 'Honour' Duty Pistol",
		icon = "115458043355747",
		ammo_give = ".30 Automatic",
		damage = 75,
		range = 40,
		range_damage = 60,
		far = 65,
		far_damage = 50,
		pen = 0,
		accuracy = 20,
		moving_accuracy = 30,
		fire_rate = 0.25,
		recoil = 9,
		recoil_count = 6,
		ammo_reserves = 2,
		ammo_reserves_max = 3,
		capacity = 20,
		size = 1,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 30,
		wallpen_studs = 2,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.275,
		aim_speed = 0.2,
		wound = 1,
		length = 4,
		movement = 0.5,
		firing_movement = 0.5,
		firing_movement_last = 0.25,
		chamber = false,
		reload_start = 1.5,
		reload_empty = 0.6,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
		reload_full = 2.2,
		require_full_load = true,
		hidereserves = true,
	},
	bulletSpeed = 850,
})

function HonourInsurgentPistol:reload()
	if self.Equipped and not self.Equipping then self:drop() end
end

function HonourInsurgentPistol:fire()
	if self.Capacity <= 0 then return false end
	local fired = self:_fireConfiguredShot(self.FireInterval)
	if fired and self.Capacity <= 0 and self.Equipped then self:drop() end
	return fired
end

return HonourInsurgentPistol
