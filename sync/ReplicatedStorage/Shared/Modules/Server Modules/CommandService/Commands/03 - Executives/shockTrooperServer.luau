local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClassService = require(ReplicatedStorage.Shared.Modules["Server Modules"].ClassService)

return function(context, kit, target)
	local player = target or context.Executor
	if not player then
		return "No target player."
	end

	local requestedKit = kit
	if type(requestedKit) ~= "string" or requestedKit == "" then
		local className = player.Character and player.Character:GetAttribute("Class")
			or player:GetAttribute("SelectedClass")
		local classKits = {
			Soldat = "Storm Trooper",
			Rook = "Anti-Material Trooper",
			Officer = "Radio Trooper",
			Lancer = "Trench Trooper",
			Jaeger = "Geist Trooper",
			Vanguard = "Bulwark Trooper",
		}
		requestedKit = classKits[className] or "Storm Trooper"
	end

	local ok, result = ClassService.SetShockTrooper(player, requestedKit, true)
	if not ok then
		return result
	end

	return ("%s is now %s."):format(player.Name, result)
end
