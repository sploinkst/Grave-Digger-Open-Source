return {
	Name = "giveaccessory";
	Aliases = {""};
	Description = "Force-Gives you a accessory";
	Group = "2";
	Args = {
		{
			Type = "players";
			Name = "Players";
			Description = "To receive the designated accessories.";
		},

		{
			Type = "accessories";
			Name = "Accessory Name";
			Description = "The specific item/weapon's name, bypasses restrictions.";
		},
		
		{
			Type = "boolean";
			Name = "Server-Handled";
			Description = "Handles the accessory on the server if true, else, client replication primary.";
			Optional = true;
			Default = false;
		},
	};
}