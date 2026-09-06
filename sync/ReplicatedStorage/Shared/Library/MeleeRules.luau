-- Shared timing and server damage rules. Ranges are measured from the attacker.
local Rules = {
	Lance = {SweepDamage = 130, StabDamage = 190, SweepRange = 7, StabRange = 10,
		Windup = .15, Interval = .85, SweepDot = .25, ChargeTime = 3, ChargeCooldown = 3},
	Shield = {Damage = 90, Range = 5, Windup = .15, Interval = .85, BlockDot = .35},
	Axes = {Damage = 199, Speed = 120, Count = 4, Windup = .2, Interval = .4, Lifetime = 5},
}

function Rules.IsInSweep(distance, dot)
	return distance <= Rules.Lance.SweepRange and dot >= Rules.Lance.SweepDot
end

function Rules.ChargePerks(butcher, veteran)
	return (butcher or veteran) and 5 or 3, butcher and 2 or 3, veteran and 3 or 1
end

return Rules
