local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClassService = require(ReplicatedStorage.Shared.Modules["Server Modules"].ClassService)
local InteractionManager = require(ReplicatedStorage.Shared.Modules["Server Modules"].InteractionManager)

return function(context, kit, target)
	local player = target or context.Executor
	if not player then
		return "No target player."
	end

	local requestedKit = kit
	if type(requestedKit) ~= "string" or requestedKit == "" then
		InteractionManager.OpenEliteKitSelection(player)
		return ("Opened the Shock Trooper picker for %s."):format(player.Name)
	end

	local ok, result = ClassService.SetShockTrooper(player, requestedKit, true)
	if not ok then
		return result
	end

	return ("%s is now %s."):format(player.Name, result)
end
