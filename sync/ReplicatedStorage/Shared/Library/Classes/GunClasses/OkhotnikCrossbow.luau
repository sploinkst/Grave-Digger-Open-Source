local OkhotnikCrossbow = require(script.Parent.LegacyGunFactory).create({
	className = "OkhotnikCrossbow",
	assetName = "crossbow",
	AnimationGunType = "OkhotnikCrossbow",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Locked = "locked", Aim = "aim", Aim_Left = "aim_left", Draw = "draw",
		Fire = "fire", Fire_Left = "fire_left", Check = "check", Reload_Start = "reload_start",
		Melee1 = "melee1", Melee2 = "melee2", Altmelee1 = "altmelee1", Altmelee2 = "altmelee2",
		Short = "short", Speen = "speen", Sprint = "sprint",
	},
	WeaponCategory = "Rifle",
	Designation = "Primary",
	Weight = 2,
	LegacyStats = {
		name = "'Okhotnik' Hunting Crossbow",
		icon = "85866554467590",
		ammo_give = "Bodkin Bolt",
		-- The legacy controller sent crossbow hits through a dedicated server
		-- handler, so its module-level damage was only a sentinel. The migrated
		-- firearm uses the shared hit pipeline and needs its real damage here.
		damage = 150,
		range = 60,
		range_damage = 125,
		far = 100,
		far_damage = 100,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 3,
		wallpen_distance = 1,
		wallpen_studs = 1,
		accuracy = 1,
		moving_accuracy = 1,
		fire_rate = 0.25,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.55,
		aim_speed = 0.125,
		recoil = 1,
		recoil_count = 1,
		movement = 1,
		firing_movement = 1,
		firing_movement_last = 0.5,
		ammo_reserves = 8,
		ammo_reserves_max = 14,
		capacity = 1,
		chamber = false,
		reload_start = 2.5,
	},
	bulletSpeed = 650,
})

function OkhotnikCrossbow:reload()
	local reloaded = self:_reloadMagazine()
	if reloaded then self.CrossbowCocked = true end
	return reloaded
end

function OkhotnikCrossbow:fire()
	if self.Capacity <= 0 or self.CrossbowCocked == false then return false end
	local fired = self:_fireConfiguredShot(self.FireInterval)
	if fired then self.CrossbowCocked = false end
	return fired
end

return OkhotnikCrossbow
