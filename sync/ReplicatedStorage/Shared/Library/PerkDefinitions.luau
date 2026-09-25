-- Canonical perk catalog migrated from the legacy master configuration.
local Perks = {}

Perks.Order = {
	"None", "Veteran", "Butcher", "Survivalist", "Tunnel-rat", "Greyhound",
	"Snake Eyes", "Leatherneck", "Marksman", "Black Hand", "Apparition",
	"Devil Dog", "Chemist", "Ambidextrous", "Hippocratic",
}

Perks.Definitions = {
	None = {
		Icon = "17768266447",
		Description = "Too green to experience the trauma of war.",
	},
	Veteran = {
		Icon = "17855293408",
		Description = "Superior reloading skills and technique.\nStart with full ammunition reserves.\nCannot be motivated by morale.",
		LancerDescription = "Lance Charges skewer up to three enemies, last longer, turn better, and stagger Vanguard Shields.",
	},
	Butcher = {
		Icon = "17848127421",
		Description = "Restore all life, ammunition, supplies and motivation on a Combat Knife or Trench Mace kill.\nIncreased lethality with both weapons.",
		LancerDescription = "Improves Lance Charge duration, control, recovery and executions. Successful charges restore life, ammunition and motivation.",
	},
	Survivalist = {
		Icon = "17855410807",
		Description = "Carry an extra inventory weight, extra equipment and extra class supplies.",
	},
	["Tunnel-rat"] = {
		Icon = "17855466133",
		Description = "Mine faster, quietly and subtly with your Pick.\nQuieter footsteps and improved handling after mining.",
	},
	Greyhound = {
		Icon = "18109565944",
		Description = "Break into a sprint immediately and handle weapons better after sprinting.\nManoeuvre over Barbed Wire more easily.",
	},
	["Snake Eyes"] = {
		Icon = "18109504628",
		Description = "Survive a lethal non-headshot every thirty seconds.\nRoll after dangerous falls; holding Jump lowers the roll threshold.",
	},
	Leatherneck = {
		Icon = "18456666880",
		Description = "Immune to flinches, concussions and bullet knockback.\nGain resilience to melee attacks.",
	},
	Marksman = {
		Icon = "71071479396010",
		Description = "Vastly improved steady aim, accuracy and recoil control.",
		LancerDescription = "Throwing Axes fly straighter and can be drawn faster.",
	},
	["Black Hand"] = {
		Icon = "18456667058",
		Description = "Improved weapon handling and reduced movement penalties.\nSlightly improved trigger finger.",
	},
	Apparition = {
		Icon = "95654030934373",
		Description = "Temporarily dim your light after a kill.\nImmune to lesser spotting effects and gain better vision in darkness.",
	},
	["Devil Dog"] = {
		Icon = "131119424203557",
		Description = "Track enemy footsteps without crouching penalties.\nSense and hunt nearby injured prey.",
	},
	Chemist = {
		Icon = "139580185887345",
		Description = "Perform self-surgery faster, replace Peridaxon with Tricordrazine, and see precise health information.",
	},
	Ambidextrous = {
		Icon = "96077944644981",
		Description = "Wield a pistol in each hand when both weapon slots contain pistols.\nUse Alternate Action to control them independently.",
	},
	Hippocratic = {
		Icon = "96285132800375",
		Description = "Forgo firearms to provide stronger surgery to allies.\nSurgery inspires morale; taking a life damages your will to fight.",
	},
	Cursed = {
		Icon = "114894113099243",
		Description = "You've desecrated hallowed grounds. You know too much.",
		Selectable = false,
	},
}

local aliases = {
	none = "None", vet = "Veteran", butcher = "Butcher", extrainv = "Survivalist",
	tunnelrat = "Tunnel-rat", sprinter = "Greyhound", knockdown = "Snake Eyes",
	leather = "Leatherneck", marksman = "Marksman", quickdraw = "Black Hand",
	ghost = "Apparition", tracker = "Devil Dog", healing = "Chemist",
	akimbo = "Ambidextrous", hippocratic = "Hippocratic", cursed = "Cursed",
}

local legacyIds = {
	None = "none", Veteran = "vet", Butcher = "butcher", Survivalist = "extrainv",
	["Tunnel-rat"] = "tunnelrat", Greyhound = "sprinter", ["Snake Eyes"] = "knockdown",
	Leatherneck = "leather", Marksman = "marksman", ["Black Hand"] = "blackhand",
	Apparition = "ghost", ["Devil Dog"] = "tracker", Chemist = "healing",
	Ambidextrous = "akimbo", Hippocratic = "hippocratic", Cursed = "cursed",
}

local function normalize(name: string): string
	return name:lower():gsub("[^%w]", "")
end

for name in Perks.Definitions do
	aliases[normalize(name)] = name
end

function Perks.Canonical(name: any): string?
	if type(name) ~= "string" or name == "" then return nil end
	return Perks.Definitions[name] and name or aliases[normalize(name)]
end

function Perks.Get(name: any)
	local canonical = Perks.Canonical(name)
	return canonical and Perks.Definitions[canonical], canonical
end

function Perks.LegacyId(name: any): string?
	local canonical = Perks.Canonical(name)
	return canonical and legacyIds[canonical]
end

function Perks.Description(name: any, className: string?): string
	local definition = Perks.Get(name)
	if not definition then return "" end
	return className == "Lancer" and definition.LancerDescription or definition.Description
end

return Perks
