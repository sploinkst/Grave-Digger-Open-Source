return {
	Name = "shocktrooper";
	Aliases = {"shock"};
	Description = "Assign a Shock Trooper kit and respawn the player. Defaults to their class kit, or Storm Trooper.";
	Group = "3";
	Args = {
		{Type = "string"; Name = "Kit"; Description = "Shock Trooper kit name."; Optional = true;},
		{Type = "player"; Name = "Player"; Description = "Player to convert. Defaults to yourself."; Optional = true;},
	};
}
