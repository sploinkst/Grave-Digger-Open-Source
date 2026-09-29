local VolkFrontlineRifle = require(script.Parent.LegacyGunFactory).create({
	className = "VolkFrontlineRifle",
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
