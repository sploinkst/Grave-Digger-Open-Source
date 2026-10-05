-- Values present in the client masters. Missing server tuning belongs on the
-- authored templates (Cost, Limit, Damage, Radius, Lifetime), not in UI scripts.
local Rules = {}
Rules.Constructs = {"Barricade", "Palisade", "Sandbags", "Barbed Wire", "Cache"}
Rules.Traps = {"Mantrap", "Tin Bomb", "Gas Shell", "Dynamite Stack", "Shotshell Trap", "Light Lure"}
Rules.Icons = {
	Barricade = "130926719066828", Palisade = "131075569490508", Sandbags = "129709621621618",
	["Barbed Wire"] = "92239986631707", Cache = "106638603044659", ["Tin Bomb"] = "89266402201210",
	["Gas Shell"] = "81547229510246", Mantrap = "134767166459938", ["Dynamite Stack"] = "114916851365951",
	["Shotshell Trap"] = "91573950154593", ["Light Lure"] = "81497413008362",
}
Rules.PlacementCooldown = 0.5
Rules.TripwireCooldown = 0.1
Rules.TripwireRange = 20
Rules.RepairRange = 3
Rules.MarkRange = 500
Rules.MarkCooldown = 1
Rules.FlagPlaceTime = 1.5
Rules.ShieldPlantTime = 1
Rules.LancerUseTime = 0.4

function Rules.Finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
function Rules.CanSpend(balance, cost, count, limit)
	return Rules.Finite(balance) and Rules.Finite(cost) and cost >= 0 and balance >= cost
		and Rules.Finite(count) and Rules.Finite(limit) and count < limit
end
function Rules.ConstructionState(progress, health, maximum)
	if health <= 0 then return "damaged" end
	if progress < 100 then return "unfinished" end
	return "finished"
end
function Rules.CanVote(mode, active, eligible, voted, choice)
	return mode == "truce" and active and eligible and not voted and (choice == "truce" or choice == "fight")
end
function Rules.CanSurrender(losing, alive, surrendered, immune, burning)
	return losing and alive and not surrendered and not immune and not burning
end
return Rules
