return function(_, players)
	for _, player in pairs(players) do
		player:SetAttribute("Force_Flinch", true)
		task.delay(0.2, function()
			player:SetAttribute("Force_Flinch", nil)
		end)
		
		print("Flinched", player.Name)
	end

	return "Flinched player(s)" 
end