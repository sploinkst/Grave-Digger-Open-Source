local AuclairPistol = require(script.Parent.LegacyGunFactory).create({
	className = "AuclairPistol",
	assetName = "mares",
	AnimationGunType = "AuclairPistol",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "locked", Aim = "aim", Aim_Left = "aim_left", Fire = "fire", Fire_Left = "fire_left",
		Fire_Last = "fire_last", Fire_Last_Left = "fire_last_left", Check = "check",
		Reload_Start = "reload_start", Reload_Empty = "reload_empty", Reload_Empty_Vet = "reload_empty_vet",
		Reload_Loop = "reload_loop", Akimbo_Fire = "akimbo_fire", Akimbo_Fire_Empty = "akimbo_fire_empty",
		Akimbo_Locked = "akimbo_locked", Alt_Changefire = "alt_changefire",
		Spin_Left = "spin_left", Spin_Right = "spin_right",
	},
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Auclair' Lever Pistol",
		desc = "A cut-down lever pistol sharing .44 Army ammunition with the Crestfall rifle.",
		lore = "Named by its curators, Jean Auclair and August Woodrow, during its development by the Solace Coalition.",
		icon = "87759641915052",
		ammo_give = ".44 Army",
		damage = 110,
		range = 50,
		range_damage = 85,
		far = 70,
		far_damage = 70,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 2,
		wallpen_distance = 50,
		wallpen_studs = 3,
		accuracy = 10,
		moving_accuracy = 80,
		fire_rate = 0.7,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.4,
		aim_speed = 0.2,
		recoil = 6,
		recoil_count = 6,
		movement = 1,
		firing_movement = 1,
		firing_movement_last = 0.5,
		ammo_reserves = 2,
		ammo_reserves_max = 3,
		capacity = 7,
		chamber = false,
		reload_start = 0.7,
		reload_empty = 2,
		reload_loop = 0.95,
		reload_end = 0,
	},
	bulletSpeed = 800,
	cycles = true,
	sideCycleAnimations = {
		Left = "Spin_Left",
		Right = "Spin_Right",
	},
	sideCycleDelay = 0.25,
	sideCycleSpeed = 2,
	sideCycleRequiresAltMode = true,
})

function AuclairPistol:setAltMode()
	if self:_isBusyForActivation() or not self.RegisteredAnimations then return end
	self.Alt_Mode = not self.Alt_Mode
	local animations = self.RegisteredAnimations
	if not self._auclairNormalFire then
		self._auclairNormalFire = animations.Fire
		self._auclairNormalFireLeft = animations.Fire_Left
	end
	animations.Fire = if self.Alt_Mode then animations.Alt_Changefire or self._auclairNormalFire else self._auclairNormalFire
	animations.Fire_Left = if self.Alt_Mode then animations.Alt_Changefire_Left or self._auclairNormalFireLeft else self._auclairNormalFireLeft
	self.FireInterval = 0.7 * (if self.Alt_Mode then 1.1 else 1)
	self.recoil = if self.Alt_Mode then 12 else 6
	self.aim_speed = if self.Alt_Mode then 0.13 else 0.2
	self:notify(if self.Alt_Mode then "One-handed handling" else "Two-handed handling")
	self:_restoreBaseDeferred()
end

return AuclairPistol
