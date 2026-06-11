local item_service = require(game:GetService("ReplicatedStorage").Shared.Modules["Server Modules"].ReplicantManager)

return function(_, players, accessoryClasses, server_replicated: boolean)
	print("Received with:", players, accessoryClasses)
	for _, player in pairs(players) do
		local helmet_check, knockable = item_service.check_for_helmet(player.Character)
		
		if helmet_check then
			item_service.pop_helmet(player.Character, helmet_check, knockable)
		end
	end

	return "Popped helmet(s)"
end