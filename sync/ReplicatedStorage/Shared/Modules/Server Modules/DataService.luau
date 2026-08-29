local Module = {}

-- // services
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

-- // dependencies
local ExternalsFolder = ReplicatedStorageService.Shared.Library.Externals
local ProfileServiceModule = require(ExternalsFolder:WaitForChild("ProfileService"))

local TemplateModule = require(script.Template)
local UtilitiesModule = require(script.Utilities)

local DatastoreModule = require(script.Datastores)

-- // profile store
local PlayerStoreKey = ProfileServiceModule.GetProfileStore(
	"PlayerData",
	TemplateModule
)

-- // runtime state
local activeProfiles = {}

-- // functions

local function UpdateTableData(player: Player)
	local profile = activeProfiles[player]
	if not profile then
		return
	end
	local dataRoot = profile.Data
	local configRoot = player:FindFirstChild("PlayerData")
	if not configRoot then
		return
	end

	-- // Cache to store instance paths
	local instancePaths = {}

	-- // Resolve Instance → parent table + key
	local function ResolveParentAndKey(instance: Instance)
		local names = {}
		local current = instance
		while current and current ~= configRoot do
			table.insert(names, 1, current.Name)
			current = current.Parent
		end
		local parent = dataRoot
		for i = 1, #names - 1 do
			parent[names[i]] = parent[names[i]] or {}
			parent = parent[names[i]]
		end
		return parent, names[#names]
	end

	-- // Resolve using cached path
	local function ResolveWithCache(instance: Instance)
		local cached = instancePaths[instance]
		if cached then
			local parent = dataRoot
			for i = 1, #cached - 1 do
				if not parent[cached[i]] then
					return nil, nil
				end
				parent = parent[cached[i]]
			end
			return parent, cached[#cached]
		end
		return ResolveParentAndKey(instance)
	end

	-- // Write instance into table
	local function WriteInstance(instance: Instance)
		local parentTable, key = ResolveParentAndKey(instance)
		if not parentTable or not key then
			return
		end

		-- // Cache the path
		local names = {}
		local current = instance
		while current and current ~= configRoot do
			table.insert(names, 1, current.Name)
			current = current.Parent
		end
		instancePaths[instance] = names

		if instance:IsA("ValueBase") then
			parentTable[key] = instance.Value
		else
			parentTable[key] = parentTable[key] or {}
		end
	end

	-- // Remove instance from table
	local function RemoveInstance(instance: Instance)
		local parentTable, key = ResolveWithCache(instance)
		if parentTable and key then
			parentTable[key] = nil
			-- // Clean up cache
			instancePaths[instance] = nil
		end
	end

	-- // Track one instance
	local function TrackInstance(instance: Instance)
		local oldName = instance.Name

		WriteInstance(instance)

		-- // Property changes
		instance.Changed:Connect(function(property)
			-- // Rename
			if property == "Name" then
				local parentTable, _ = ResolveParentAndKey(instance)
				if parentTable then
					parentTable[instance.Name] = parentTable[oldName]
					parentTable[oldName] = nil
					oldName = instance.Name
					-- // Update cache
					WriteInstance(instance)
				end
			end
			-- // Value update
			if property == "Value" and instance:IsA("ValueBase") then
				local parentTable, key = ResolveParentAndKey(instance)
				if parentTable and key then
					parentTable[key] = instance.Value
				end
			end
		end)
		-- // Reparenting/Removal detection
		instance.AncestryChanged:Connect(function()
			if not instance:IsDescendantOf(configRoot) then
				-- // Instance was removed from PlayerData, remove from table
				RemoveInstance(instance)
			else
				-- // Instance was reparented within PlayerData, update location
				WriteInstance(instance)
			end
		end)
		-- // Track children being added/removed
		instance.ChildAdded:Connect(function(child)
			TrackInstance(child)
		end)
		instance.ChildRemoved:Connect(function(child)
			RemoveInstance(child)
		end)
		-- // Initial children
		for _, child in ipairs(instance:GetChildren()) do
			TrackInstance(child)
		end
	end

	-- // Start tracking
	TrackInstance(configRoot)
end

local function RetrieveRestores()
	local restoreTable = DatastoreModule.data_retrieve("restores", "main")
	return restoreTable
end

local function LoadProfile(player: Player)
	local profileKey = "Player_" .. player.UserId

	local profile = PlayerStoreKey:LoadProfileAsync(profileKey)

	if not profile then
		player:Kick("Failed to load data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile:ListenToRelease(function()
		activeProfiles[player] = nil

		if player and player.Parent then
			player:Kick("Data loaded on another server.")
		end
	end)

	-- // Safety check: player left during load
	if not player:IsDescendantOf(PlayersService) then
		profile:Release()
		return
	end

	activeProfiles[player] = profile

	UtilitiesModule.visualize_table(player, profile.Data)
	UpdateTableData(player)

	local restores = RetrieveRestores()
	if typeof(restores) == "table" then
		local index = table.find(restores, player.UserId)
		if index then
			player:WaitForChild("PlayerData"):WaitForChild("CharacterData"):WaitForChild("Wiped").Value = false
			table.remove(restores, index)
			DatastoreModule.data_push("restores", restores, "main", true)
			print("RestoreServer: restored player data for", player.Name)
		end
	end
end

local function ReleaseProfile(player: Player)
	local profile = activeProfiles[player]

	if profile then
		profile:Release()
		activeProfiles[player] = nil
	end
end

-- // api

function Module.start_module()
	-- // Existing players
	for _, player in pairs(PlayersService:GetPlayers()) do
		task.spawn(LoadProfile, player)
	end

	-- // Player join
	PlayersService.PlayerAdded:Connect(function(player)
		task.spawn(LoadProfile, player)
	end)

	-- // Player leave
	PlayersService.PlayerRemoving:Connect(function(player)
		ReleaseProfile(player)
	end)
end

function Module.WipePlayerData(player: Player, wipeType)
	print("WipeServer: wiping data for", player.Name, "type:", wipeType)
	local profile = activeProfiles[player]
	if not profile then
		warn("No active profile found for player: " .. player.Name)
		return
	end

	local function DeepCopy(t)
		local copy = {}
		for k, v in pairs(t) do
			if type(v) == "table" then
				copy[k] = DeepCopy(v)
			else
				copy[k] = v
			end
		end
		return copy
	end

	-- // Wipe data in memory
	if wipeType == 0 then
		-- // Wipe only CharacterData
		if profile.Data.CharacterData then
			for key, _ in pairs(profile.Data.CharacterData) do
				profile.Data.CharacterData[key] = nil
			end

			local templateCharacterData = TemplateModule.CharacterData
			for key, value in pairs(templateCharacterData) do
				if type(value) == "table" then
					profile.Data.CharacterData[key] = DeepCopy(value)
				else
					profile.Data.CharacterData[key] = value
				end
			end
		end
	else
		-- // Wipe all player data
		for key, _ in pairs(profile.Data) do
			profile.Data[key] = nil
		end
		for key, value in pairs(TemplateModule) do
			if type(value) == "table" then
				profile.Data[key] = DeepCopy(value)
			else
				profile.Data[key] = value
			end
		end
	end

	-- // Use a flag to prevent kick during internal release
	local releasingForWipe = Module._internal_releasing or {}
	releasingForWipe[player] = true
	Module._internal_releasing = releasingForWipe

	-- // Safely release profile
	profile:Release()
	activeProfiles[player] = nil

	-- // Destroy old PlayerData instance
	local playerData = player:FindFirstChild("PlayerData")
	if playerData then
		playerData:Destroy()
	end

	-- // Give ProfileService a small moment to finalize release before reloading
	task.wait(0.1)

	-- // Reload the profile
	task.spawn(function()
		LoadProfile(player)
	end)
end

return Module