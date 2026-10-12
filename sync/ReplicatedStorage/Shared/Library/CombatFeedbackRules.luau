-- Master client timing and proximity rules; kept pure for boundary tests.
local Rules = {}
Rules.WhizzCooldown = 0.35
Rules.EarRingCooldown = 5.25
Rules.BloodImages = {92904376126712, 115368253261443, 125399080412483, 132798049017638, 98455730095525, 75875394654743}
function Rules.EarRingEligible(force, elapsed, immune)
	return not immune and type(force) == "number" and force == force and force >= 70 and elapsed >= Rules.EarRingCooldown
end
function Rules.NearBlood(distance, facing)
	return distance <= 12 and facing > -1
end
function Rules.SegmentDistance(point, start, finish)
	local segment = finish - start
	local lengthSquared = segment:Dot(segment)
	local fraction = lengthSquared > 0 and math.clamp((point - start):Dot(segment) / lengthSquared, 0, 1) or 0
	return (point - (start + segment * fraction)).Magnitude
end
return Rules
