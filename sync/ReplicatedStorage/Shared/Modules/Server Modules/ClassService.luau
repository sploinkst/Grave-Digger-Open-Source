local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = require(ReplicatedStorage.Shared.Library.ClassDefinitions)
local ClassAppearance = require(ReplicatedStorage.Shared.Library.ClassAppearance)
local Perks = require(ReplicatedStorage.Shared.Library.PerkDefinitions)
local Service = {}
local Players = game:GetService("Players")
local events = ReplicatedStorage.Shared.Library.Events
local intel = events:FindFirstChild("ClassIntel")
if not intel then
	intel = Instance.new("RemoteEvent"); intel.Name = "ClassIntel"
	intel.Parent = events
end
local function hasPerk(player, name)
	local canonical = Perks.Canonical(name) or name
	if player:GetAttribute(canonical) or player:GetAttribute(name) then return true end
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and (perks:FindFirstChild(canonical) or perks:FindFirstChild(name))
	if not perk then return false end
	return not perk:IsA("BoolValue") or perk.Value
end

local lastSelection = setmetatable({}, {__mode = "k"})
local classes = ReplicatedStorage.Shared.Library.Classes

local function findItemController(name)
	local eliteClasses = classes:FindFirstChild("EliteClasses")
	return classes.GunClasses:FindFirstChild(name)
		or classes.ToolClasses:FindFirstChild(name)
		or (eliteClasses and eliteClasses:FindFirstChild(name))
end

local function weight(name)
	local source = findItemController(name)
	if not source or not source:IsA("ModuleScript") then return 0 end
	local ok, item = pcall(require, source)
	return ok and type(item.Weight) == "number" and item.Weight or 0
end

local function maxToolAmmo(tool: Tool?)
	if not tool then return end
	local reserve = tool:FindFirstChild("Reserve_Ammo")
	local maximum = tool:FindFirstChild("Max_Ammo")
	if reserve and reserve:IsA("NumberValue") then reserve.Value = 20000 end
	if maximum and maximum:IsA("NumberValue") then maximum.Value = 20000 end
end

local function maxBackpackAmmo(player: Player, toolName: string)
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end
	for _, tool in backpack:GetChildren() do
		if tool:IsA("Tool") and tool.Name == toolName then
			maxToolAmmo(tool)
		end
	end
end

local function fillBackpackAmmo(player: Player, toolName: string)
	local backpack = player:FindFirstChild("Backpack")
	local tool = backpack and backpack:FindFirstChild(toolName)
	local reserve = tool and tool:FindFirstChild("Reserve_Ammo")
	local maximum = tool and tool:FindFirstChild("Max_Ammo")
	if reserve and reserve:IsA("NumberValue") and maximum and maximum:IsA("NumberValue") then
		reserve.Value = maximum.Value
	end
end

local function clearCurrentInventory(player: Player, character: Model, humanoid: Humanoid)
	-- Unequip first so each weapon controller gets a chance to remove its held
	-- model and ToolMotor before the Tool instances themselves are destroyed.
	humanoid:UnequipTools()

	local backpack = player:FindFirstChildOfClass("Backpack")
	for _, container in {character, backpack} do
		if not container then continue end
		for _, item in container:GetChildren() do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
	end

	-- Holsters are replicated independently of Tools. Removing their source
	-- values tells every client to destroy the back model and its weld.
	local holsters = player:FindFirstChild("GameData")
		and player.GameData:FindFirstChild("Accessorys")
		and player.GameData.Accessorys:FindFirstChild("Holsters")
	if holsters then
		holsters:ClearAllChildren()
	end

	local characterData = character:FindFirstChild("CharacterData")
	local equipment = characterData and characterData:FindFirstChild("Equipment")
	if equipment then
		equipment:ClearAllChildren()
	end

	-- Also clean server-visible remnants immediately. Rendered_Holsters is
	-- normally client-owned, but clearing it here handles server-created or
	-- legacy back models as well.
	local renderedHolsters = characterData and characterData:FindFirstChild("Rendered_Holsters")
	if renderedHolsters then
		renderedHolsters:ClearAllChildren()
	end
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("Motor6D")
			and (descendant.Name == "ToolMotor" or descendant.Name == "Round_Motor6d") then
			descendant:Destroy()
		end
	end
	character:SetAttribute("GunEquipped", nil)
	character:SetAttribute("ShieldRaised", nil)
	player:SetAttribute("CantUnequip", nil)
end

local function findSound(name: string): Sound?
	local wanted = string.lower(name)
	for _, descendant in ReplicatedStorage.Shared:GetDescendants() do
		if descendant:IsA("Sound") and string.lower(descendant.Name) == wanted then
			return descendant
		end
	end
	return nil
end

local function setValue(parent: Instance, className: string, name: string, value: any)
	local object = parent:FindFirstChild(name)
	if not object or object.ClassName ~= className then
		if object then object:Destroy() end
		object = Instance.new(className)
		object.Name = name
		object.Parent = parent
	end
	object.Value = value
	return object
end

local function setPlayerClassTag(player: Player, className: string)
	local tag = player:FindFirstChild("Class")
	if not tag or not tag:IsA("StringValue") then
		if tag then tag:Destroy() end
		tag = Instance.new("StringValue")
		tag.Name = "Class"
		tag.Parent = player
	end
	tag.Value = className
	player:SetAttribute("SelectedClass", className)
end

local function publishCharacterData(player: Player, character: Model, className: string, equipment: Folder)
	local characterData = character:FindFirstChild("CharacterData")
	if not characterData then return end
	setValue(characterData, "StringValue", "Class", className)
	setValue(characterData, "StringValue", "TeamSide", player.Team and player.Team.Name or "")

	local perks = characterData:FindFirstChild("Perks")
	if not perks then perks = Instance.new("Folder"); perks.Name = "Perks"; perks.Parent = characterData end
	perks:ClearAllChildren()
	local selectedPerks = equipment:FindFirstChild("Perks")
	local selectedLoadout = Classes.GetLoadout(player, className)
	local selectedPerk = selectedLoadout and selectedLoadout:FindFirstChild("Perk")
	if selectedPerk and selectedPerks then
		selectedPerks:ClearAllChildren()
		if selectedPerk.Value ~= "" then setValue(selectedPerks, "BoolValue", selectedPerk.Value, true) end
	end
	local runtimePerk = character:FindFirstChild("perk")
	local activePerkNames = {}
	if selectedPerks then
		for _, perk in selectedPerks:GetChildren() do
			local enabled = if perk:IsA("BoolValue") then perk.Value else true
			setValue(perks, "BoolValue", perk.Name, enabled)
			if enabled then table.insert(activePerkNames, perk.Name) end
		end
	end
	if runtimePerk and runtimePerk:IsA("StringValue") then
		local active = activePerkNames[1]
		runtimePerk.Value = active and (Perks.LegacyId(active) or active) or ""
	end

	local state = characterData:FindFirstChild("State")
	if not state then state = Instance.new("Folder"); state.Name = "State"; state.Parent = characterData end
	setValue(state, "BoolValue", "Crouching", false)
	setValue(state, "BoolValue", "Sprinting", false)
	setValue(state, "BoolValue", "Aiming", false)
	setValue(state, "StringValue", "LeanSide", "None")
end

function Service.Select(player, name)
	if type(name) ~= "string" or not Classes.Definitions[name] then return false end
	local now = os.clock()
	if now - (lastSelection[player] or -math.huge) < 0.25 then return false end
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local selected = equipment and equipment:FindFirstChild("Class")
	if not selected or not selected:IsA("StringValue") then return false end
	lastSelection[player] = now
	local definition = Classes.Get(name)
	local loadout = Classes.GetLoadout(player, name)
	local primary = loadout and loadout:FindFirstChild("Primary")
	local secondary = loadout and loadout:FindFirstChild("Secondary")
	-- Keep the stored editable firearm selection valid for the new capacity.
	if not definition.NoFirearms and primary and secondary then
		local maxWeight = Classes.GetMaxWeight(player, name)
		if weight(primary.Value) > maxWeight then primary.Value = "" end
		if weight(primary.Value) + weight(secondary.Value) > maxWeight then secondary.Value = "" end
	end
	selected.Value = name
	local legacyPrimary = equipment:FindFirstChild("Primary")
	local legacySecondary = equipment:FindFirstChild("Secondary")
	if legacyPrimary and primary then legacyPrimary.Value = primary.Value end
	if legacySecondary and secondary then legacySecondary.Value = secondary.Value end
	setPlayerClassTag(player, name)
	-- This is the next deployment's selection, never a mid-life passive swap.
	return true
end

function Service.ApplySpawn(player, character)
	local root = player:WaitForChild("PlayerData", 30)
	local data = root and root:WaitForChild("PlayerData", 30)
	local equipment = data and data:WaitForChild("Equipment", 30)
	if player.Character ~= character or character:GetAttribute("ClassSnapshotReady") then return end
	local name = Classes.Selected(player)
	setPlayerClassTag(player, name)
	local definition = Classes.Get(name)
	-- Shock Trooper is current-life state. A fresh character always starts as
	-- the player's selected base class, while permanent unlocks remain intact.
	player:SetAttribute("ShockTrooper", nil)
	local eliteName = nil
	local elite = nil
	local isDreadnought = player:GetAttribute("PendingDreadnought") == true
	if isDreadnought then
		player:SetAttribute("PendingDreadnought", nil)
		player:SetAttribute("Dreadnought", nil)
		events.Sounds:FireAllClients("DreadnoughtMusic", player.Team and player.Team.Name or "")
		eliteName = nil
		elite = nil
	end
	character:SetAttribute("Class", name)
	local runtimeClass = character:FindFirstChild("class")
	if runtimeClass and runtimeClass:IsA("StringValue") then runtimeClass.Value = name end
	character:SetAttribute("EliteClass", eliteName)
	character:SetAttribute("IsShockTrooper", elite ~= nil)
	character:SetAttribute("IsDreadnought", isDreadnought)
	if isDreadnought then
		character:SetAttribute("ClassOutfit", "dread")
		character:SetAttribute("ForceFirstPerson", true)
		character:SetAttribute("CanSprint", false)
		character:SetAttribute("StatusImmune", true)
		character:SetAttribute("GasImmune", true)
		local marker = Instance.new("BoolValue")
		marker.Name = "dreadnought"
		marker.Value = true
		marker.Parent = character
	end
	if not isDreadnought then
		character:SetAttribute("ClassOutfit", if elite then elite.OutfitClass else name)
	end
	if eliteName == "OcelotTrooper" then
		character:SetAttribute("MovementSpeedMultiplier", 1.25)
		character:SetAttribute("SprintSpeedMultiplier", 1.2)
		character:SetAttribute("SprintRampMultiplier", 0)
		character:SetAttribute("InstantSprintAcceleration", true)
		character:SetAttribute("SnakeEyes", true)
		local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
		local theme = findSound("theme")
		if rootPart and theme then
			events.Sounds:FireAllClients("OcelotTheme", theme, rootPart, theme.PlaybackSpeed, theme.Volume, 0, 0)
		end
	end

	publishCharacterData(player, character, name, equipment)
	local maxWeight = Classes.GetMaxWeight(player, name)
	character:SetAttribute("InventoryWeight", if isDreadnought then 0 else maxWeight)
	character:SetAttribute("OfficerOrderCapacity", if name == "Officer" and hasPerk(player, "Survivalist") then 2 else 1)
	for _, attribute in {"DrawSpeed", "AimSpeed", "SpreadMultiplier", "CaptureWeight", "AllyHealHealth",
		"SurgerySpeed", "MobileSurgery", "SuppressionImmune", "MeleeDamageMultiplier"} do
		character:SetAttribute(attribute, definition[attribute])
	end
	local leatherneck = hasPerk(player, "Leatherneck")
	character:SetAttribute("InstantSprintAcceleration", eliteName == "OcelotTrooper" or eliteName == "StormTrooper" or eliteName == "GeistTrooper" or hasPerk(player, "Greyhound") or nil)
	character:SetAttribute("FlinchImmune", leatherneck or nil)
	character:SetAttribute("ConcussionImmune", leatherneck or nil)
	character:SetAttribute("BulletKnockbackImmune", leatherneck or nil)
	if leatherneck then
		character:SetAttribute("MeleeDamageMultiplier", math.min(character:GetAttribute("MeleeDamageMultiplier") or 1, 0.7))
	end
	character:SetAttribute("Marksman", hasPerk(player, "Marksman") or nil)
	character:SetAttribute("TunnelRat", hasPerk(player, "Tunnel-rat") or nil)
	character:SetAttribute("DevilDog", hasPerk(player, "Devil Dog") or nil)
	character:SetAttribute("Chemist", hasPerk(player, "Chemist") or nil)
	character:SetAttribute("Apparition", hasPerk(player, "Apparition") or nil)
	-- Snapshot weapons with the class; menu edits cannot be changed until respawn
	local loadout = Classes.GetLoadout(player, name)
	local primary = loadout and loadout:FindFirstChild("Primary")
	local secondary = loadout and loadout:FindFirstChild("Secondary")
	local primaryName = if isDreadnought then "BrowningMachineGun" elseif elite then elite.Primary else definition.FixedPrimary or (primary and primary.Value or "")
	local secondaryName = if isDreadnought then "" elseif elite then elite.Secondary else if definition.NoFirearms then "" else (secondary and secondary.Value or "")
	if not elite and not isDreadnought and hasPerk(player, "Hippocratic") then
		primaryName = ""
		secondaryName = ""
	end
	if not elite and not isDreadnought then
		if weight(primaryName) > maxWeight and not definition.FixedPrimary then primaryName = "" end
		if weight(primaryName) + weight(secondaryName) > maxWeight then secondaryName = "" end
	end
	character:SetAttribute("ClassPrimary", primaryName)
	character:SetAttribute("ClassSecondary", secondaryName)
	local melee = loadout and loadout:FindFirstChild("Melee")
	character:SetAttribute("ClassMelee", melee and melee.Value or "Knife")
	character:SetAttribute("ClassSnapshotReady", true)
end

function Service.SetShockTrooper(player: Player, eliteName: string, bypassRequirements: boolean?): (boolean, string)
	local elite, canonicalName = Classes.GetElite(eliteName)
	if not elite or not canonicalName then
		return false, "Unknown Shock Trooper kit: " .. eliteName
	end
	if not bypassRequirements and not Classes.CanUseElite(player, canonicalName) then
		return false, canonicalName .. " has not been unlocked."
	end
	-- Standard Shock kits have no base-class eligibility requirement.
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid or humanoid.Health <= 0 then
		return false, "A living character is required to equip a Shock Trooper kit."
	end
	-- Convert the current life in place. Rebuild only the inventory snapshot so
	-- position and current combat state are not lost to a forced respawn.
	character:SetAttribute("EliteClass", canonicalName)
	character:SetAttribute("IsShockTrooper", true)
	character:SetAttribute("ClassOutfit", elite.OutfitClass)
	character:SetAttribute("ClassPrimary", elite.Primary)
	character:SetAttribute("ClassSecondary", elite.Secondary)
	character:SetAttribute("ClassEquipmentGranted", nil)
	ClassAppearance.Apply(
		character,
		player.Team and player.Team.Name,
		elite.OutfitClass,
		true
	)
	if canonicalName == "OcelotTrooper" then
		character:SetAttribute("MovementSpeedMultiplier", 1.25)
		character:SetAttribute("SprintSpeedMultiplier", 1.2)
		character:SetAttribute("SprintRampMultiplier", 0)
		character:SetAttribute("InstantSprintAcceleration", true)
		character:SetAttribute("SnakeEyes", true)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local theme = findSound("theme")
		if rootPart and theme then
			events.Sounds:FireAllClients(
				"OcelotTheme",
				theme,
				rootPart,
				theme.PlaybackSpeed,
				theme.Volume,
				0,
				0
			)
		end
	end

	clearCurrentInventory(player, character, humanoid)

	local toolsLoaded = character:FindFirstChild("tools_loaded")
	if toolsLoaded and toolsLoaded:IsA("BoolValue") then
		toolsLoaded.Value = false
	end

	Service.GiveLoadout(player, character)
	return true, canonicalName
end

function Service.UnlockShockTrooper(player: Player, eliteName: string): boolean
	local elite, canonicalName = Classes.GetElite(eliteName)
	if not elite or not canonicalName then return false end
	local unlocked = player:FindFirstChild("UnlockedShockTroopers")
	if not unlocked then
		unlocked = Instance.new("Folder")
		unlocked.Name = "UnlockedShockTroopers"
		unlocked.Parent = player
	end
	if not unlocked:FindFirstChild(canonicalName) then
		local marker = Instance.new("BoolValue")
		marker.Name = canonicalName
		marker.Value = true
		marker.Parent = unlocked
	end
	player:SetAttribute(canonicalName .. "Unlocked", true)
	return true
end

function Service.ClearShockTrooper(player: Player)
	player:SetAttribute("ShockTrooper", nil)
	if player.Character then player:LoadCharacter() end
end

function Service.GiveLoadout(player, character)
	if not character:GetAttribute("ClassSnapshotReady") then Service.ApplySpawn(player, character) end
	if player.Character ~= character or not character:GetAttribute("ClassSnapshotReady")
		or character:GetAttribute("ClassEquipmentGranted") then return end
	character:SetAttribute("ClassEquipmentGranted", true)
	local definition = Classes.Get(character:GetAttribute("Class"))
	local Items = require(script.Parent.ItemsService)
	local names
	if character:GetAttribute("IsDreadnought") then
		names = { character:GetAttribute("ClassPrimary") or "BrowningMachineGun" }
	else
		names = {character:GetAttribute("ClassPrimary") or "", character:GetAttribute("ClassSecondary") or "",
			"Compass", "Medkit", character:GetAttribute("ClassMelee") or "Knife"}
		for _, name in definition.Tools do table.insert(names, name) end
	end
	for index, name in names do
		if player.Character ~= character or not character.Parent then return end
		if name == "" then continue end
		local source = findItemController(name)
		if not source then
			warn("[Classes] Missing item controller: " .. name)
			continue
		end

		local inventoryDesignation = if index == 1 then "Primary" elseif index == 2 then "Secondary" else nil
		local ok, err = pcall(Items.give_item, player, name, nil, inventoryDesignation)
		if not ok then
			warn("[Classes] Could not grant " .. name .. ": " .. tostring(err))
			continue
		end

		if character:GetAttribute("IsShockTrooper") or character:GetAttribute("IsDreadnought") then
			maxBackpackAmmo(player, name)
		elseif hasPerk(player, "Veteran") then
			fillBackpackAmmo(player, name)
		end
	end
	local toolsLoaded = character:FindFirstChild("tools_loaded")
	if toolsLoaded and toolsLoaded:IsA("BoolValue") then toolsLoaded.Value = true end
	local equipment = definition.Equipment
	local equipmentValue = character:FindFirstChild("CharacterData")
		and character.CharacterData:FindFirstChild("State")
		and character.CharacterData.State:FindFirstChild("Equipment")
	if equipment and classes.EquipmentClasses:FindFirstChild(equipment) then
		if equipmentValue and equipmentValue:IsA("StringValue") then equipmentValue.Value = equipment end
		character:SetAttribute("Equipment", equipment)
	else
		if equipmentValue and equipmentValue:IsA("StringValue") then equipmentValue.Value = "" end
		character:SetAttribute("Equipment", nil)
		if equipment then warn("[Classes] Missing equipment controller: " .. equipment) end
	end
end
function Service.RecordHit(player, target, weaponName)
	local character = player.Character
	if not character or character:GetAttribute("Class") ~= "Officer" or type(weaponName) ~= "string"
		or not character:FindFirstChild(weaponName) or target == player or not player.Team
		or target.Team == player.Team or hasPerk(target, "Apparition") then return end
	local enemy = target.Character
	local root = enemy and enemy:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, ally in Players:GetPlayers() do
		local allyRoot = ally.Character and ally.Character:FindFirstChild("HumanoidRootPart")
		if ally.Team == player.Team and allyRoot and (allyRoot.Position - root.Position).Magnitude <= 200 then
			intel:FireClient(ally, "Mark", enemy, 10)
		end
	end
end

function Service.RecordMining(player)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head or character:GetAttribute("EliteClass") == "Geist Trooper" then return end
	for _, listener in Players:GetPlayers() do
		local hunter = listener.Character
		local origin = hunter and hunter:FindFirstChild("Head")
		if listener.Team and listener.Team ~= player.Team and origin
			and hunter:GetAttribute("Class") == "Jaeger" then
			local direction = head.Position - origin.Position
			if direction.Magnitude > 0 and direction.Magnitude <= 80 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {hunter}
				local hit = workspace:Raycast(origin.Position, direction, params)
				if hit and not hit.Instance:IsDescendantOf(character) then
					intel:FireClient(listener, "Mining", head.Position, 2)
				end
			end
		end
	end
end

function Service.start_module()
	local lastMark = setmetatable({}, {__mode = "k"})
	intel.OnServerEvent:Connect(function(player, kind, target)
		if kind ~= "ReconMark" or typeof(target) ~= "Instance" or not target:IsA("Model") then return end
		local character = player.Character
		local head = character and character:FindFirstChild("Head")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local enemy = Players:GetPlayerFromCharacter(target)
		local enemyHead = target:FindFirstChild("Head")
		local enemyHumanoid = target:FindFirstChildOfClass("Humanoid")
		if not head or not humanoid or humanoid.Health <= 0 or character:GetAttribute("Class") ~= "Officer"
			or not character:FindFirstChild("ReconKit") or not player.Team
			or not enemy or enemy == player or enemy.Team == player.Team
			or not enemyHead or not enemyHumanoid or enemyHumanoid.Health <= 0 then return end
		local now = os.clock()
		if now - (lastMark[player] or -math.huge) < 1 then return end
		lastMark[player] = now
		local direction = enemyHead.Position - head.Position
		if direction.Magnitude > 1000 then return end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		local hit = workspace:Raycast(head.Position, direction, params)
		if hit and not hit.Instance:IsDescendantOf(target) then return end
		for _, ally in Players:GetPlayers() do
			local root = ally.Character and ally.Character:FindFirstChild("HumanoidRootPart")
			if ally.Team == player.Team and root and (root.Position - head.Position).Magnitude <= 200 then
				intel:FireClient(ally, "Mark", target, 10)
			end
		end
	end)
end

return Service
