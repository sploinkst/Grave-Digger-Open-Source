local WeaponIds = {}

WeaponIds.LegacyToCanonical = {
	adjudicator = "AdjudicatorRifle",
	autosg = "HellionShotgun",
	auclair = "AuclairPistol",
	crestfall = "CrestfallRifle",
	equine = "EquineShotgun",
	grace = "GraceRevolver",
	henry = "JudgementRifle",
	hellion = "HellionShotgun",
	honour = "HonourPistol",
	honor = "HonourPistol",
	hope = "HopePistol",
	jesse = "JesseRifle",
	judgement = "JudgementRifle",
	judgment = "JudgementRifle",
	kingslayer = "KingslayerRevolver",
	knell = "KnellRevolver",
	lebel = "PrinceRifle",
	lever = "CrestfallRifle",
	mosin = "VolkRifle",
	negotiator = "NegotiatorShotgun",
	okhotnik = "OkhotnikCrossbow",
	prince = "PrinceRifle",
	rsc = "AdjudicatorRifle",
	rcs = "AdjudicatorRifle",
	saa = "TalonRevolver",
	scho = "GraceRevolver",
	springfield = "WhisperRifle",
	talon = "TalonRevolver",
	union = "UnionPistol",
	volk = "VolkRifle",
	walker = "KingslayerRevolver",
	whisper = "WhisperRifle",

	antimaterial = "AntiMaterialRifle",
	antimaterialrifle = "AntiMaterialRifle",
	browningmg = "BrowningMachineGun",
	browning = "BrowningMachineGun",
	crossbow = "OkhotnikCrossbow",
	dbgun = "EquineShotgun",
	enfield = "JesseRifle",
	lewis = "LewisGun",
	mares = "AuclairPistol",
	mauser = "HonourPistol",
	mausercarbine = "MauserCarbine",
	mgturret = "MachineGunTurret",
	machinegunturret = "MachineGunTurret",
	mondragon = "MondragonRifle",
	mpgun = "MachinePistol",
	mpistol = "HopePistol",
	pieper = "KnellRevolver",
	pugsley = "AntiMaterialRifle",
	remington = "NegotiatorShotgun",
	rooklauncher = "RookLauncher",
	steyr = "UnionPistol",
	trench = "TrenchShotgun",
	wex = "WexFlamethrower",

	atgrenade = "AntiTankGrenades",
	atgrenades = "AntiTankGrenades",
	binocs = "Binoculars",
	binoculars = "Binoculars",
	conscriptlantern = "ConscriptLantern",
	firstaid = "FirstAidKit",
	firstaidkit = "FirstAidKit",
	flagpole = "Flagpole",
	hammer = "Hammer",
	jaegerkit = "JaegerKit",
	lance = "lance",
	lancerstim = "LancerStim",
	nebel = "NebelGrenade",
	nebelgrenade = "NebelGrenade",
	pick = "Pick",
	pickaxe = "Pickaxe",
	stims = "Stimulants",
	stimulants = "Stimulants",
	throwaxe = "ThrowingAxes",
	throwingaxes = "ThrowingAxes",
	vanguardshield = "VanguardShield",
	whistle = "TrenchWhistle",
	wrench = "Wrench",
	weldingtool = "WeldingTool",
	bottle = "Bottle",
	machete = "Machete",
	club = "Club",
	knife = "Knife",

	Crossbow = "OkhotnikCrossbow",
	DoubleBarrelShotgun = "EquineShotgun",
	EnfieldRifle = "JesseRifle",
	MaresLeg = "AuclairPistol",
	MauserPistol = "HonourPistol",
	MilitaryPistol = "HopePistol",
	PieperCarbine = "KnellRevolver",
	RemingtonShotgun = "NegotiatorShotgun",
	SteyrRifle = "UnionPistol",
	WalkerRevolver = "KingslayerRevolver",
}

WeaponIds.DisplayNames = {
	AdjudicatorRifle = "Adjudicator",
	AuclairPistol = "Auclair",
	CrestfallRifle = "Crestfall",
	EquineShotgun = "Equine",
	GraceRevolver = "Grace",
	HellionShotgun = "Hellion",
	HonourPistol = "Honour",
	HopePistol = "Hope",
	JesseRifle = "Jesse",
	JudgementRifle = "Judgement",
	KingslayerRevolver = "Kingslayer",
	KnellRevolver = "Knell",
	MachinePistol = "Breath of God",
	MauserCarbine = "Commissar's Gift",
	NegotiatorShotgun = "Negotiator",
	OkhotnikCrossbow = "Okhotnik",
	PrinceRifle = "Prince",
	RookLauncher = "Mining Bomb Launcher",
	TalonRevolver = "Talon",
	UnionPistol = "Union",
	VolkRifle = "Volk",
	WhisperRifle = "Whisper",
}

WeaponIds.PreferredAssetNames = {
	AdjudicatorRifle = "rsc",
	AntiMaterialRifle = "pugsley",
	AuclairPistol = "mares",
	BrowningMachineGun = "browningmg",
	CrestfallRifle = "lever",
	EquineShotgun = "dbgun",
	GraceRevolver = "scho",
	HellionShotgun = "autosg",
	HonourPistol = "mauser",
	HopePistol = "mpistol",
	JesseRifle = "enfield",
	JudgementRifle = "henry",
	KingslayerRevolver = "walker",
	KnellRevolver = "pieper",
	LewisGun = "lewis",
	MachineGunTurret = "mgturret",
	MachinePistol = "mpgun",
	MauserCarbine = "mausercarbine",
	MondragonRifle = "mondragon",
	NegotiatorShotgun = "remington",
	OkhotnikCrossbow = "crossbow",
	PrinceRifle = "lebel",
	RookLauncher = "rooklauncher",
	TalonRevolver = "saa",
	TrenchShotgun = "trench",
	UnionPistol = "steyr",
	VolkRifle = "mosin",
	WexFlamethrower = "wex",
	WhisperRifle = "springfield",

	AntiTankGrenades = "atgrenades",
	Binoculars = "binocs",
	Bottle = "bottle",
	Club = "club",
	ConscriptLantern = "conscriptlantern",
	FirstAidKit = "firstaidkit",
	Flagpole = "flagpole",
	Hammer = "hammer",
	JaegerKit = "jaegerkit",
	Knife = "knife",
	LancerStim = "lancerstim",
	Machete = "machete",
	NebelGrenade = "nebel",
	Pick = "pick",
	Pickaxe = "pickaxe",
	Stimulants = "stims",
	ThrowingAxes = "throwaxe",
	TrenchWhistle = "whistle",
	VanguardShield = "vanguardshield",
	WeldingTool = "weldingtool",
	Wrench = "wrench",
}

local function normalize(name: string): string
	return name:lower():gsub("[^%w]", "")
end

local rawAliases = WeaponIds.LegacyToCanonical
WeaponIds.LegacyToCanonical = {}
for alias, canonical in pairs(rawAliases) do
	WeaponIds.LegacyToCanonical[alias] = canonical
	WeaponIds.LegacyToCanonical[normalize(alias)] = canonical
	WeaponIds.LegacyToCanonical[normalize(canonical)] = canonical
end

for canonical, displayName in pairs(WeaponIds.DisplayNames) do
	WeaponIds.LegacyToCanonical[canonical] = canonical
	WeaponIds.LegacyToCanonical[normalize(canonical)] = canonical
	WeaponIds.LegacyToCanonical[displayName] = canonical
	WeaponIds.LegacyToCanonical[normalize(displayName)] = canonical
end

WeaponIds.CanonicalToLegacyAsset = {}
for canonical, assetName in pairs(WeaponIds.PreferredAssetNames) do
	WeaponIds.CanonicalToLegacyAsset[canonical] = assetName
end

function WeaponIds.Canonical(name: any): string
	if type(name) ~= "string" then
		return ""
	end

	return WeaponIds.LegacyToCanonical[name] or WeaponIds.LegacyToCanonical[normalize(name)] or name
end

function WeaponIds.AssetName(name: any): string
	local canonical = WeaponIds.Canonical(name)
	return WeaponIds.CanonicalToLegacyAsset[canonical] or canonical
end

function WeaponIds.Aliases(name: any): { string }
	local canonical = WeaponIds.Canonical(name)
	if canonical == "" then
		return {}
	end

	local aliases = { canonical }
	local seen = { [canonical] = true }

	local displayName = WeaponIds.DisplayNames[canonical]
	if displayName and not seen[displayName] then
		table.insert(aliases, displayName)
		seen[displayName] = true
	end

	for alias, aliasCanonical in pairs(WeaponIds.LegacyToCanonical) do
		if aliasCanonical == canonical and not seen[alias] then
			table.insert(aliases, alias)
			seen[alias] = true
		end
	end

	return aliases
end

function WeaponIds.DisplayName(name: any): string
	local canonical = WeaponIds.Canonical(name)
	if canonical == "" then
		return "None"
	end

	return WeaponIds.DisplayNames[canonical] or (canonical:gsub("(%l)(%u)", "%1 %2"))
end

return WeaponIds
