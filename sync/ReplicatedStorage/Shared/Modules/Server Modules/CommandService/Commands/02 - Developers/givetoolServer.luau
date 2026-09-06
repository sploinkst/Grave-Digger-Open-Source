local item_service = require(game:GetService("ReplicatedStorage").Shared.Modules["Server Modules"].ItemsService)

return function(_, players, toolClasses)
	print("Received with:", players, toolClasses)
	local failures = {}
	for _, player in pairs(players) do
		for _, tool in pairs(toolClasses) do
			local ok, result = xpcall(function()
				return item_service.give_item(player, tool)
			end, debug.traceback)
			if not ok then
				local message = ("givetool failed for %s -> %s:\n%s")
					:format(player.Name, tostring(tool), tostring(result))
				warn(message)
				table.insert(failures, message)
			end
		end
	end

	if #failures > 0 then
		-- Cmdr normally replaces thrown command errors with a generic sentence.
		-- Return the first traceback as normal command output so it is visible in
		-- the command panel even when Studio Output is filtered or closed.
		return failures[1]:sub(1, 900)
	end
	return "Gave tool(s)"
end
