local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = require(ReplicatedStorage.Shared.Library.ClassDefinitions)
local Service = {}
local Players = game:GetService("Players")
local events = ReplicatedStorage.Shared.Library.Events
local intel = events:FindFirstChild("ClassIntel")
if not intel then
	intel = Instance.new("RemoteEvent"); intel.Name = "ClassIntel"
	intel.Parent = events
end
local function hasPerk(player, name)
	if player:GetAttribute(name) then return true end
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local perks = equipment and equipment:FindFirstChild("Perks")
	local perk = perks and perks:FindFirstChild(name)
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

local function findSound(name: string): Sound?
	local soundsFolder = ReplicatedStorage.Shared.Assets:FindFirstChild("Sounds")
	local gunsFolder = ReplicatedStorage.Shared.Assets:FindFirstChild("Guns")
	local gunSounds = gunsFolder and gunsFolder:FindFirstChild("Sounds")
	for _, root in { soundsFolder, gunSounds } do
		local sound = root and root:FindFirstChild(name, true)
		if sound and sound:IsA("Sound") then return sound end
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
		runtimePerk.Value = table.concat(activePerkNames, ",")
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
		if weight(primary.Value) > definition.MaxWeight then primary.Value = "" end
		if weight(primary.Value) + weight(secondary.Value) > definition.MaxWeight then secondary.Value = "" end
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
	local eliteName = player:GetAttribute("ShockTrooper")
	local elite = type(eliteName) == "string" and Classes.GetElite(eliteName) or nil
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
		character:SetAttribute("ClassOutfit", if elite then elite.OutfitClass or elite.RequiredClass else name)
	end
	if eliteName == "OcelotTrooper" then
		character:SetAttribute("MovementSpeedMultiplier", 1.15)
		character:SetAttribute("SprintSpeedMultiplier", 1.25)
		character:SetAttribute("InstantSprintAcceleration", true)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local theme = findSound("theme")
		if rootPart and theme then
			events.Sounds:FireAllClients(player, theme, rootPart, theme.PlaybackSpeed, theme.Volume, 0, 0)
		end
	end

	publishCharacterData(player, character, name, equipment)
	character:SetAttribute("InventoryWeight", if isDreadnought then 0 else definition.MaxWeight)
	character:SetAttribute("OfficerOrderCapacity", if name == "Officer" and hasPerk(player, "Survivalist") then 2 else 1)
	for _, attribute in {"DrawSpeed", "AimSpeed", "SpreadMultiplier", "CaptureWeight", "AllyHealHealth",
		"SurgerySpeed", "MobileSurgery", "SuppressionImmune", "MeleeDamageMultiplier"} do
		character:SetAttribute(attribute, definition[attribute])
	end
	-- Snapshot weapons with the class; menu edits cannot alter a spawning life.
	local loadout = Classes.GetLoadout(player, name)
	local primary = loadout and loadout:FindFirstChild("Primary")
	local secondary = loadout and loadout:FindFirstChild("Secondary")
	local primaryName = if isDreadnought then "BrowningMachineGun" elseif elite then elite.Primary else definition.FixedPrimary or (primary and primary.Value or "PrinceRifle")
	local secondaryName = if isDreadnought then "" elseif elite then elite.Secondary else if definition.NoFirearms then "" else (secondary and secondary.Value or "")
	if not elite and not isDreadnought then
		if weight(primaryName) > definition.MaxWeight and not definition.FixedPrimary then primaryName = "" end
		if weight(primaryName) + weight(secondaryName) > definition.MaxWeight then secondaryName = "" end
	end
	character:SetAttribute("ClassPrimary", primaryName)
	character:SetAttribute("ClassSecondary", secondaryName)
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
	if not bypassRequirements and elite.RequiredClass and Classes.Selected(player) ~= elite.RequiredClass then
		return false, canonicalName .. " requires " .. elite.RequiredClass .. "."
	end
	player:SetAttribute("ShockTrooper", canonicalName)
	if player.Character then player:LoadCharacter() end
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
			"Compass", "Medkit"}
		for _, name in definition.Tools do table.insert(names, name) end
	end
	local given = {}
	for _, name in names do
		if player.Character ~= character or not character.Parent then return end
		if name == "" or given[name] then continue end

		given[name] = true
		local source = findItemController(name)
		if not source then
			warn("[Classes] Missing item controller: " .. name)
			continue
		end

		local ok, err = pcall(Items.give_item, player, name)
		if not ok then
			warn("[Classes] Could not grant " .. name .. ": " .. tostring(err))
			continue
		end

		if character:GetAttribute("IsShockTrooper") or character:GetAttribute("IsDreadnought") then
			maxToolAmmo(player.Backpack:FindFirstChild(name))
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
