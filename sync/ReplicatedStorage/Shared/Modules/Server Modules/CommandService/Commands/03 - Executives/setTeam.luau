return {
	Name = "setTeam";
	Aliases = {""};
	Description = "Sets a player's team";
	Group = "3";
	Args = {
		{
			Type = "players";
			Name = "Player";
			Description = "Player to be set.";
		},

		{
			Type = "teams";
			Name = "Team";
			Description = "The specific team.";
		},
	};
}