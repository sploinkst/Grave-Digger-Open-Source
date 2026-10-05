local UnionPistol = require(script.Parent.LegacyGunFactory).create({
	className = "UnionPistol",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.32220459, -1.17378056, -0.236167908, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
		alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
	},
	assetName = "steyr",
	AnimationGunType = "UnionPistol",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "locked", Aim = "alt_changeaim", Aim_Left = "alt_changeaim_left",
		Fire = "fire", Check = "check", Reload_Start = "reload_start",
		Reload_Start_Vet = "reload_start_vet", Reload_Empty = "reload_empty", Reload_Loop = "reload_loop",
		Reload_One_Vet = "reload_one_vet", Reload_Clip = "reload_clip", Reload_End = "reload_end",
		Akimbo_Fire = "akimbo_fire", Akimbo_Locked = "akimbo_locked", Alt_Changeaim = "alt_changeaim",
		Alt_Changeaim_Left = "alt_changeaim_left", Alt_Changefire = "alt_changefire", Alt_Changefire_Left = "alt_changefire_left",
		Steyrdraw = "steyrdraw",
	},
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Union' Military Pistol",
		icon = "94903428476030",
		ammo_give = "9mm Lead",
		damage = 90,
		range = 30,
		range_damage = 80,
		far = 225,
		far_damage = 60,
		pen = 1,
		accuracy = 8,
		moving_accuracy = 80,
		fire_rate = 0.375,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.275,
		aim_speed = 0.2,
		recoil = 10,
		recoil_count = 6,
		ammo_reserves = 2,
		ammo_reserves_max = 3,
		capacity = 8,
		size = 1,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 30,
		wallpen_studs = 2,
		wound = 1,
		length = 4,
		movement = 1,
		firing_movement = 2.5,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 1.3,
		reload_empty = 1.2,
		reload_loop = 0.6,
		reload_loop_after = 0,
		reload_end = 0.35,
		reload_full = 2,
	},
	bulletSpeed = 850,
})

function UnionPistol:reload()
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if self.IsVeteran and self.Capacity <= 1 and reserve and reserve:IsA("NumberValue")
		and reserve.Value >= self.Max_Capacity then
		return self:_reloadByRound({
			startAnim = self.Capacity == 1 and "Reload_One_Vet" or false,
			useEmptyAnim = false,
			useVeteranAnimations = false,
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

return UnionPistol
