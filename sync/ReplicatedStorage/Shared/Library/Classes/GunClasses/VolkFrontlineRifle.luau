local VolkFrontlineRifle = require(script.Parent.LegacyGunFactory).create({
	className = "VolkFrontlineRifle",
	AuthoredWelds = {
		equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = true,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-0.843444824, -0.160831451, 0.563819885, -0.0857552588, 0.996316195, -2.14072588e-6, -0.996316195, -0.0857552588, 6.89330363e-6, 6.68433131e-6, 2.72397665e-6, 1),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(-0.0671386719, 0.0569257736, 0.563720703, -0.085755609, -0.996316195, 1.70646985e-7, -0.996320546, 0.0857559666, 8.59710667e-7, -2.90349675e-7, -2.8889346e-7, -1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "mosin",
	AnimationGunType = "VolkRifle",
	WeaponCategory = "Rifle",
	Designation = "Primary",
	Weight = 2,
	LegacyStats = {
		name = "'Volk' Frontline Rifle",
		desc = "Modification of the 'Volk' Scoped Rifle",
		icon = "73535017242408",
		ammo_give = "7.62mmR Jacketed",
		damage = 150,
		range = 70,
		range_damage = 140,
		far = 100,
		far_damage = 130,
		pen = 2,
		accuracy = 10,
		moving_accuracy = 120,
		fire_rate = 0.3,
		cycle = 0.65,
		cycle_rest = 0.2,
		draw_speed = 0.5,
		aim_speed = 0.3,
		recoil = 10,
		recoil_count = 6,
		ammo_reserves = 2,
		ammo_reserves_max = 4,
		capacity = 5,
		size = 2,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 30,
		wallpen_studs = 2,
		wound = 1,
		length = 4,
		movement = 2,
		firing_movement = 1,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 1,
		reload_empty = 1.5,
		reload_loop = 0.5,
		reload_end = 0.5,
		reload_full = 1.5,
	},
	bulletSpeed = 1100,
})

function VolkFrontlineRifle:reload()
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	local canClipLoad = not self.IsVeteran and self.Capacity <= 1
		and reserve and reserve:IsA("NumberValue") and reserve.Value >= self.Max_Capacity
	if canClipLoad then
		return self:_reloadByRound({
			startAnim = if self.Capacity <= 0
				then "Reload_Clip_Start_Empty"
				else "Reload_Clip_Start_Empty_Novet",
			useEmptyAnim = false,
			loopAnim = "Reload_Clip",
			roundsPerLoop = self.Max_Capacity,
			endAnim = "Reload_End",
		})
	end
	return self:_reloadByRound({
		startAnim = "Reload_Start",
		loopAnim = "Reload_Loop",
		endAnim = "Reload_End",
	})
end

return VolkFrontlineRifle
