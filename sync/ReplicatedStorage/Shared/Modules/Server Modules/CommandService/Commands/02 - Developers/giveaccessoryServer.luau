local item_service = require(game:GetService("ReplicatedStorage").Shared.Modules["Server Modules"].AccessoryService)

return function(_, players, accessoryClasses, server_replicated: boolean)
	print("Received with:", players, accessoryClasses)
	for _, player in pairs(players) do
		for _, Accessory in pairs(accessoryClasses) do
			item_service.give_accessory(player, Accessory, server_replicated)
		end
	end

	return "Gave Accessory(s)"
end