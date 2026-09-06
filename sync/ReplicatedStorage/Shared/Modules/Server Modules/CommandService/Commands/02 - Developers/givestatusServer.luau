local item_service = require(game:GetService("ReplicatedStorage").Shared.Modules["Server Modules"].StatusService)

return function(_, players, StatusClass)
	print("Received with:", players, StatusClass)
	for _, player in pairs(players) do
		for _, status in pairs(StatusClass) do
			item_service.GiveStatus(player, status)
		end
	end

	return "Gave tool(s)"
end
