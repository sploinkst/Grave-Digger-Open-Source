local WeaponIds = {}

WeaponIds.LegacyToCanonical = {
	adjudicator = "AdjudicatorRifle",
	autosg = "HellionShotgun",
	autosgvariant = "HellionHeavyShotgun",
	auclair = "AuclairPistol",
	crestfall = "CrestfallRifle",
	crestfallranger = "CrestfallRangerRifle",
	equine = "EquineShotgun",
	equinesawed = "EquineSawedShotgun",
	grace = "GraceRevolver",
	henry = "JudgementRifle",
	henryvariant = "JudgementIncendiaryRifle",
	hellion = "HellionShotgun",
	hellionheavy = "HellionHeavyShotgun",
	honour = "HonourPistol",
	honor = "HonourPistol",
	honourinsurgent = "HonourInsurgentPistol",
	honorinsurgent = "HonourInsurgentPistol",
	hope = "HopePistol",
	jesse = "JesseRifle",
	jesseprecision = "JessePrecisionRifle",
	judgement = "JudgementRifle",
	judgment = "JudgementRifle",
	judgementincendiary = "JudgementIncendiaryRifle",
	judgmentincendiary = "JudgementIncendiaryRifle",
	kingslayer = "KingslayerRevolver",
	knell = "KnellRevolver",
	knellbandit = "KnellBanditRevolver",
	lebel = "PrinceRifle",
	lever = "CrestfallRifle",
	levervariant = "CrestfallRangerRifle",
	mosin = "VolkRifle",
	mosinvariant = "VolkFrontlineRifle",
	negotiator = "NegotiatorShotgun",
	negotiatorlong = "NegotiatorLongShotgun",
	okhotnik = "OkhotnikCrossbow",
	ocelot = "TalonCavalryRevolver",
	prince = "PrinceRifle",
	rsc = "AdjudicatorRifle",
	rcs = "AdjudicatorRifle",
	saa = "TalonRevolver",
	saavariant = "TalonCavalryRevolver",
	scho = "GraceRevolver",
	springfield = "WhisperRifle",
	springfieldvariant = "WhisperFlyboyRifle",
	talon = "TalonRevolver",
	taloncavalry = "TalonCavalryRevolver",
	union = "UnionPistol",
	unionstocked = "UnionStockedPistol",
	volk = "VolkRifle",
	volkfrontline = "VolkFrontlineRifle",
	walker = "KingslayerRevolver",
	whisper = "WhisperRifle",
	whisperflyboy = "WhisperFlyboyRifle",

	antimaterial = "AntiMaterialRifle",
	antimaterialrifle = "AntiMaterialRifle",
	browningmg = "BrowningMachineGun",
	browning = "BrowningMachineGun",
	crossbow = "OkhotnikCrossbow",
	dbgun = "EquineShotgun",
	dbgunvariant = "EquineSawedShotgun",
	enfield = "JesseRifle",
	enfieldvariant = "JessePrecisionRifle",
	lewis = "LewisGun",
	mares = "AuclairPistol",
	mauser = "HonourPistol",
	mausercarbine = "MauserCarbine",
	mauservariant = "HonourInsurgentPistol",
	mgturret = "MachineGunTurret",
	machinegunturret = "MachineGunTurret",
	mondragon = "MondragonRifle",
	mpgun = "StormRifle",
	mpistol = "HopePistol",
	pieper = "KnellRevolver",
	piepervariant = "KnellBanditRevolver",
	pugsley = "AntiMaterialRifle",
	remington = "NegotiatorShotgun",
	remingtonvariant = "NegotiatorLongShotgun",
	rooklauncher = "RookLauncher",
	steyr = "UnionPistol",
	steyrvariant = "UnionStockedPistol",
	trench = "TrenchShotgun",
	flamethrower = "WexFlamethrower",
	lamentations = "WexFlamethrower",
	wex = "WexFlamethrower",

	["anti-armourgrenades"] = "AntiArmourGrenades",
	["anti-armour grenade"] = "AntiArmourGrenades",
	["anti-armour grenades"] = "AntiArmourGrenades",
	["anti-armor grenade"] = "AntiArmourGrenades",
	["anti-armor grenades"] = "AntiArmourGrenades",
	antiarmourgrenade = "AntiArmourGrenades",
	antiarmourgrenades = "AntiArmourGrenades",
	antiarmorgrenade = "AntiArmourGrenades",
	antiarmorgrenades = "AntiArmourGrenades",
	antitankgrenade = "AntiArmourGrenades",
	antitankgrenades = "AntiArmourGrenades",
	atgrenade = "AntiArmourGrenades",
	atgrenades = "AntiArmourGrenades",
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
	EquineSawedShotgun = "Equine Sawed",
	GraceRevolver = "Grace",
	CrestfallRangerRifle = "Crestfall Ranger",
	HellionShotgun = "Hellion",
	HellionHeavyShotgun = "Hellion Heavy",
	HonourPistol = "Honour",
	HonourInsurgentPistol = "Honour Insurgent",
	HopePistol = "Hope",
	JesseRifle = "Jesse",
	JessePrecisionRifle = "Jesse Precision",
	JudgementRifle = "Judgement",
	JudgementIncendiaryRifle = "Judgement Incendiary",
	KingslayerRevolver = "Kingslayer",
	KnellRevolver = "Knell",
	KnellBanditRevolver = "Knell Bandit",
	MachinePistol = "Breath of God",
	MauserCarbine = "Commissar's Gift",
	NegotiatorShotgun = "Negotiator",
	NegotiatorLongShotgun = "Negotiator Long",
	OkhotnikCrossbow = "Okhotnik",
	PrinceRifle = "Prince",
	RookLauncher = "Mining Bomb Launcher",
	TalonRevolver = "Talon",
	TalonCavalryRevolver = "Talon Cavalry",
	UnionPistol = "Union",
	UnionStockedPistol = "Union Stocked",
	VolkRifle = "Volk",
	VolkFrontlineRifle = "Volk Frontline",
	WexFlamethrower = "Lamentations",
	WhisperRifle = "Whisper",
	WhisperFlyboyRifle = "Whisper Flyboy",
}

WeaponIds.PreferredAssetNames = {
	AdjudicatorRifle = "rsc",
	AntiMaterialRifle = "pugsley",
	AuclairPistol = "mares",
	BrowningMachineGun = "browningmg",
	CrestfallRifle = "lever",
	CrestfallRangerRifle = "lever",
	EquineShotgun = "dbgun",
	EquineSawedShotgun = "dbgun",
	GraceRevolver = "scho",
	HellionShotgun = "autosg",
	HellionHeavyShotgun = "autosg",
	HonourPistol = "mauser",
	HonourInsurgentPistol = "mauser",
	HopePistol = "mpistol",
	JesseRifle = "enfield",
	JessePrecisionRifle = "enfield",
	JudgementRifle = "henry",
	JudgementIncendiaryRifle = "henry",
	KingslayerRevolver = "walker",
	KnellRevolver = "pieper",
	KnellBanditRevolver = "pieper",
	LewisGun = "lewis",
	MachineGunTurret = "mgturret",
	StormRifle = "mpgun",
	MauserCarbine = "mausercarbine",
	MondragonRifle = "mondragon",
	NegotiatorShotgun = "remington",
	NegotiatorLongShotgun = "remington",
	OkhotnikCrossbow = "crossbow",
	PrinceRifle = "lebel",
	RookLauncher = "rooklauncher",
	TalonRevolver = "saa",
	TalonCavalryRevolver = "saa",
	TrenchShotgun = "trench",
	UnionPistol = "steyr",
	UnionStockedPistol = "steyr",
	VolkRifle = "mosin",
	VolkFrontlineRifle = "mosin",
	WexFlamethrower = "wex",
	WhisperRifle = "springfield",
	WhisperFlyboyRifle = "springfield",

	AntiArmourGrenades = "atgrenades",
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
