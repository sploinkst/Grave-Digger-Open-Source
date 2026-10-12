local Equipment = require(script.Parent.EquipmentRules).Get("MiningBombLauncher")
local Rules = {
	ReloadTime = 2.5,
	FireInterval = 0.5,
	DrawTime = 1,
	EquipmentCapacity = Equipment.ammo,
	EquipmentRecharge = Equipment.cd,
	ProjectileSpeed = 450,
	Damage = 50,
	BlastRadius = 12,
	MiningRadius = 6,
	ConcussionDuration = 3,
}
function Rules.CanFire(loaded, reloading, charges)
	return loaded == true and not reloading and charges > 0
end
function Rules.CanReload(loaded, reloading, charges)
	return not loaded and not reloading and charges > 0
end
return Rules
