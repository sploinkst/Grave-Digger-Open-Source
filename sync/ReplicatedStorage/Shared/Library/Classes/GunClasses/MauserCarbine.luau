local RadioRifle = require(script.Parent.LegacyGunFactory).create({
	className = "MauserCarbine",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.987213135, 0.399168491, 0.526702881, -2.91702968e-14, -0.5, -0.866025388, -0.999997139, 1.69012767e-13, -6.38968723e-14, 1.2275623e-13, 0.866025388, -0.5),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.987213135, 0.399168491, 0.526702881, -2.91702968e-14, -0.5, -0.866025388, -0.999997139, 1.69012767e-13, -6.38968723e-14, 1.2275623e-13, 0.866025388, -0.5),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "mausercarbine",
	soundNames = {"radiorifle", "RadioRifle", "mausercarbine", "MauserCarbine"},
	AnimationGunType = "RadioRifle",
	PreferOwnDraw = true,
	AnimationMap = {
		Hold = "held", Draw = "draw",
		Aim = "aim", Aim_Left = "aim_left",
		Fire = "fire", Fire_Left = "fire_left",
		Melee1 = "melee1", Melee2 = "melee2", Short = "short",
	},
	WeaponCategory = "Pistol",
	Designation = "Primary",
	Weight = 1,
	reloadStartIsFullReload = true,
	fullReloadAnimation = "Reload_Full",
	LegacyStats = {
		name = "'Commissar's Gift'",
		icon = "117647294446177",
		ammo_give = ".30 Steel",
		damage = 95,
		range = 40,
		range_damage = 90,
		far = 60,
		far_damage = 85,
		pen = 2,
		accuracy = 3,
		moving_accuracy = 6,
		fire_rate = 0.3,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.75,
		aim_speed = 0.2,
		recoil = 3,
		recoil_count = 6,
		ammo_reserves = 200,
		ammo_reserves_max = 200,
		capacity = 10,
		require_full_load = true,
		reload_full = 2,
		blacklist = true,
		size = 1,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 30,
		wallpen_studs = 2,
		wound = 1,
		length = 5,
		movement = 0.5,
		firing_movement = 0.5,
		firing_movement_last = 0.25,
		chamber = false,
		reload_start = 1,
		reload_empty = 0.5,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
	},
	bulletSpeed = 850,
})

local inheritedEquip = RadioRifle._on_equip
local inheritedAim = RadioRifle.aim

function RadioRifle:_shouldPlayAnimationSound(name)
	return name ~= "draw" and name ~= "aim" and name ~= "fire"
end

function RadioRifle:_on_equip()
	inheritedEquip(self)
	self:_playConfiguredSound("draw")
end

function RadioRifle:aim()
	local wasAiming = self.Aiming
	inheritedAim(self)
	if not wasAiming and self.Aiming then self:_playConfiguredSound("aim") end
end

return RadioRifle
