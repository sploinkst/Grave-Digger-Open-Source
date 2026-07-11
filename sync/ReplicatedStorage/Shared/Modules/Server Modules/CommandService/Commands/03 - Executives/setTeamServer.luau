return function(context, players, team)
	print(players, team)
	for _, player in pairs(players) do
		player.Team = team[1]
	end
end