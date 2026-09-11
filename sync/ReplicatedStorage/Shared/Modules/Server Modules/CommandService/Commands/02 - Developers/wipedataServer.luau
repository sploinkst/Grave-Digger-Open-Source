return function(_, players, boolean)
	local wipe_type = boolean and 1 or 0
	for _, player in pairs(players) do
		print("wipedataServer: wiping data for", player.Name, "type:", boolean)
		local wipedata_module = require(game.ReplicatedStorage.Shared.Modules["Server Modules"].DataService)
		wipedata_module.WipePlayerData(player, true)
	end
end
