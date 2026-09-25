-- Central class contract. Names are controller IDs, not asset display names.
local Classes = {}
local Perks = require(script.Parent.PerkDefinitions)
Classes.Default = "Soldat"
Classes.Order = {"Soldat", "Rook", "Mortician", "Officer", "Jaeger", "Lancer", "Vanguard"}
Classes.Definitions = {
	Soldat = {
		Passive = "Duty and Virtue", MaxWeight = 3, Equipment = "AmmoPack",
		EquipmentName = "Ammunition Pouch", Tools = {"Pickaxe"},
		DrawSpeed = 1.25, AimSpeed = 1.15, SpreadMultiplier = 0.9,
	},
	Rook = {
		Passive = "Construct Hammer", MaxWeight = 2, Equipment = "MiningBombLauncher",
		EquipmentName = "Mining Bomb Launcher", Tools = {"HeavyPickaxe", "ConstructHammer"},
		ExplosiveKnockdownImmune = true,
	},
	Mortician = {
		Passive = "Stimulant Compounds", MaxWeight = 2, Equipment = "MedicalSyrettes",
		EquipmentName = "Medical Syrettes", Tools = {"Pickaxe", "StimulantCompounds"},
		AllyHealHealth = 200, SurgerySpeed = 1.5, MobileSurgery = true, GasImmune = true,
	},
	Officer = {
		Passive = "Recon Kit", MaxWeight = 2, Equipment = "TrenchWhistle",
		EquipmentName = "Trench Whistle", Tools = {"Pickaxe", "ReconKit"},
		NoHelmet = true, CaptureWeight = 2, IconRange = 200, MarkDuration = 10,
	},
	Jaeger = {
		Passive = "Hunter Kit ", MaxWeight = 2, Equipment = "SmokescreenBombs",
		EquipmentName = "Smokescreen Bombs", Tools = {"Pickaxe", "HunterKit"},
		PoxPerShot = 20, HearingRange = 80,
	},
	Lancer = {
		Passive = "Painkiller Injector", MaxWeight = 2, Equipment = "ThrowingAxes",
		EquipmentName = "Throwing Axes", Tools = {"Pickaxe", "PainkillerInjector"},
		FixedPrimary = "lance", NoFirearms = true, MeleeDamageMultiplier = 0.7,
	},
	Vanguard = {
		Passive = "Bulwark's Hope", MaxWeight = 2, Equipment = "lebel",
		EquipmentName = "Rally Banner", Tools = {"Pickaxe", "RallyBanner"},
		FixedPrimary = "shield", NoFirearms = true, SuppressionImmune = true,
	}
}

-- Elite kits deliberately sit beside a player's selected class. This lets a
-- conversion retain that class's tools/equipment while replacing only weapons.
-- Weapon controller modules can be added later under these stable IDs.
Classes.EliteDefinitions = {

	["Storm Trooper"] = { Primary = "StormRifle", Secondary = "", OutfitClass = "Soldat" },
	["Anti-Material Trooper"] = { Primary = "AntiMaterialRifle", Secondary = "GraceRevolver", OutfitClass = "Rook" },
	["Flame Trooper"] = { Primary = "WexFlamethrower", Secondary = "GraceRevolver", OutfitClass = "Mortician" },
	["Radio Trooper"] = { Primary = "MauserCarbine", Secondary = "", OutfitClass = "Officer" },
	["Trench Trooper"] = { Primary = "TrenchShotgun", Secondary = "", OutfitClass = "Lancer" },
	["Geist Trooper"] = { Primary = "MondragonRifle", Secondary = "", OutfitClass = "Jaeger" },
	["Bulwark Trooper"] = { Primary = "LewisGun", Secondary = "GraceRevolver", OutfitClass = "Vanguard" },
	OcelotTrooper = { Primary = "OcelotTalonRevolver", Secondary = "OcelotTalonRevolverSecondary", OutfitClass = "Officer", RequiresUnlock = "OcelotTrooper" },
}

function Classes.Get(name)
	return Classes.Definitions[name] or Classes.Definitions[Classes.Default]
end

function Classes.HasPerk(player: Player, perkName: string): boolean
	local canonical = Perks.Canonical(perkName) or perkName
	if player:GetAttribute(canonical) == true or player:GetAttribute(perkName) == true then return true end
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and (perks:FindFirstChild(canonical) or perks:FindFirstChild(perkName))
	if not perk then return false end
	return not perk:IsA("BoolValue") or perk.Value
end

function Classes.GetMaxWeight(player: Player, className: string?): number
	local definition = Classes.Get(className or Classes.Selected(player))
	local loadout = Classes.GetLoadout(player, className or Classes.Selected(player))
	local selectedPerk = loadout and loadout:FindFirstChild("Perk")
	local survivalist = if selectedPerk then selectedPerk.Value == "Survivalist" else Classes.HasPerk(player, "Survivalist")
	return definition.MaxWeight + (survivalist and 1 or 0)
end

function Classes.Selected(player)
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local value = equipment and equipment:FindFirstChild("Class")
	return value and Classes.Definitions[value.Value] and value.Value or Classes.Default
end

-- Each normal class owns an editable weapon pair. Legacy Primary/Secondary
-- values remain available for old code, but are no longer the source of truth.
function Classes.GetLoadout(player: Player, className: string?)
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	if not equipment then return nil end
	local name = className or Classes.Selected(player)
	if not Classes.Definitions[name] then name = Classes.Default end
	local loadouts = equipment:FindFirstChild("ClassLoadouts")
	if not loadouts and game:GetService("RunService"):IsServer() then
		loadouts = Instance.new("Folder")
		loadouts.Name = "ClassLoadouts"
		loadouts.Parent = equipment
	end
	local loadout = loadouts and loadouts:FindFirstChild(name)
	if not loadout and loadouts and game:GetService("RunService"):IsServer() then
		loadout = Instance.new("Folder")
		loadout.Name = name
		loadout.Parent = loadouts
		for _, slotName in {"Primary", "Secondary"} do
			local value = Instance.new("StringValue")
			value.Name = slotName
			local legacy = equipment:FindFirstChild(slotName)
			value.Value = legacy and legacy:IsA("StringValue") and legacy.Value or ""
			value.Parent = loadout
		end
	end
	-- Clear retired selections before they can appear in a slot or be deployed.
	if loadout and game:GetService("RunService"):IsServer() then
		local handling = require(script.Parent.WeaponHandling)
		local tools = script.Parent.Classes.ToolClasses
		for _, slot in loadout:GetChildren() do
			if slot:IsA("StringValue") and (slot.Name == "Primary" or slot.Name == "Secondary") and slot.Value ~= "" and (slot.Value == "SteyrRifle" or (not tools:FindFirstChild(slot.Value) and not handling.IsBaseline(slot.Value))) then
				slot.Value = ""
				local legacy = equipment:FindFirstChild(slot.Name)
				if legacy and legacy:IsA("StringValue") then legacy.Value = "" end
			end
		end
	end
	return loadout
end

function Classes.IsEliteWeapon(name: string): boolean
	for _, elite in Classes.EliteDefinitions do
		if elite.Primary == name or elite.Secondary == name then return true end
	end
	return false
end

function Classes.Active(player)
	local character = player.Character
	local name = character and character:GetAttribute("Class")
	return Classes.Get(name)
end

function Classes.GetElite(name)
	if type(name) ~= "string" then return nil end
	if Classes.EliteDefinitions[name] then return Classes.EliteDefinitions[name], name end
	local normalized = name:lower():gsub("[^%w]", "")
	for eliteName, definition in Classes.EliteDefinitions do
		if eliteName:lower():gsub("[^%w]", "") == normalized then
			return definition, eliteName
		end
	end
	return nil
end

function Classes.CanUseElite(player: Player, eliteName: string): boolean
	local elite, canonicalName = Classes.GetElite(eliteName)
	if not elite or not canonicalName then return false end
	if not elite.RequiresUnlock then return true end
	if player:GetAttribute(elite.RequiresUnlock .. "Unlocked") == true then return true end
	local unlocked = player:FindFirstChild("UnlockedShockTroopers")
	return unlocked ~= nil and unlocked:FindFirstChild(elite.RequiresUnlock) ~= nil
end

return Classes
