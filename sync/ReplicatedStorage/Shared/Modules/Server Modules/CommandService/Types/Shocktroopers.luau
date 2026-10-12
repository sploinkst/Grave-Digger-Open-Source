local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(script.Parent.Parent.Shared.Util)

local Shocktroopers = {
	"Storm Trooper",
	"Anti-Material Trooper",
	"Flame Trooper",
	"Radio Trooper",
	"Trench Trooper",
	"Geist Trooper",
	"Bulwark Trooper",
	"Ocelot Trooper",
}

local shocktrooperType = {
	Transform = function(text)
		local find_shocktrooper = Util.MakeFuzzyFinder(Shocktroopers)

		return find_shocktrooper(text)
	end;

	Validate = function(shocktroopers)
		return #shocktroopers > 0, "No Shocktrooper with that name could be found."
	end;

	Autocomplete = function(shocktroopers)
		return shocktroopers
	end;

	Parse = function(shocktroopers)
		return shocktroopers[1]
	end;
}

return function(cmdr)
	cmdr:RegisterType("shocktrooper", shocktrooperType)
end