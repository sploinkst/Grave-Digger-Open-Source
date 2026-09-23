return require(script.Parent.LegacyGunFactory).create({
	name = "SteyrRifle",
	assetName = "steyr",
	WeaponCategory = "Rifle",
	Designation = "Primary",
	-- The Steyr is the internal controller for a weapon modification, not a
	-- standalone loadout choice.
	HiddenFromLoadout = true,
	Weight = 2,
	damage = 105,
	capacity = 5,
	ammoType = "8mm",
	recoil = 1.5,
	recoilCount = 6,
	accuracy = 3,
	movingAccuracy = 7,
	fireInterval = 0.55,
	bulletSpeed = 950,
	cycles = true,
})
-- THIS IS THE WEAPON MOD!
