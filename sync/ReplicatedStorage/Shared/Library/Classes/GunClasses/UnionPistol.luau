local UnionPistol = require(script.Parent.LegacyGunFactory).create({
	className = "UnionPistol",
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
