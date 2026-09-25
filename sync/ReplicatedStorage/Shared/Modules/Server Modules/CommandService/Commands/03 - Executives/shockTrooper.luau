return {
	Name = "shocktrooper";
	Aliases = {"shock"};
	Description = "Open the Shock Trooper picker, or equip a named kit without respawning.";
	Group = "3";
	Args = {
		{Type = "string"; Name = "Kit"; Description = "Shock Trooper kit name."; Optional = true;},
		{Type = "player"; Name = "Player"; Description = "Player to convert. Defaults to yourself."; Optional = true;},
	};
}
