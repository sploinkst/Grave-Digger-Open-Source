local Rules = {}
Rules.SurgeryThreshold = 100
Rules.PatientRange = 100
Rules.FirstAidPatientRange = 20
Rules.SyretteRange = 20
Rules.ThankWindow = 20
Rules.MoraleDuration = 20

function Rules.Patient(health, maximum, armoured)
	if armoured then return {label = "Can't tell under this armour", surgery = "Surgery Impossible", color = {200, 200, 200}} end
	if health <= 0 then return {label = "Dead", surgery = "", color = {120, 120, 120}} end
	local label, color = "Healthy", {190, 255, 160}
	for _, level in {
		{200, "Light Injury", {209, 255, 157}},
		{150, "Moderate Injury", {255, 234, 112}},
		{100, "Heavy Injury", {255, 155, 55}},
		{50, "Severe Damage", {255, 42, 42}},
		{10, "Near Death", {200, 0, 100}},
	} do
		if health < level[1] then label, color = level[2], level[3] end
	end
	if maximum > 200 and health >= 200 and health < maximum then label = "Negligible Injury" end
	return {label = label, surgery = health < Rules.SurgeryThreshold and "Needs Surgery" or "", color = color}
end

function Rules.CanReceiveSyrette(health, clotting, blocked)
	return health > 0 and not blocked and (health < Rules.SurgeryThreshold or clotting == true)
end

function Rules.CanThank(now, expires, sameLife, sameTeam, providerAlive, recipientAlive)
	return now <= expires and sameLife and sameTeam and providerAlive and recipientAlive
end

return Rules
