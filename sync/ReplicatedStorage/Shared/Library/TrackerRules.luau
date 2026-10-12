local Rules = {}
function Rules.Heartbeat(health, distance)
	return health > 0 and health <= 99 and distance <= 80
end
function Rules.Sonar(elapsed, soundElapsed, occluded, jaeger)
	return jaeger and occluded and elapsed > 2, soundElapsed >= 5
end
return Rules
