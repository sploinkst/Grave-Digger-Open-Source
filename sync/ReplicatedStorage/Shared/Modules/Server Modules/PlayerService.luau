local Module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationsFolder = ReplicatedStorage.Shared.Assets.Animations.Character.Walking.Standing.Walk_Forward
local RagdollStatus = require(ReplicatedStorage.Shared.Library.Classes.StatusClasses.RagdollStatus)
local TestingBoolean = ReplicatedStorage.Shared.Library.Configuration.Game_Variables.Testing_Boolean
local StatusService = require(script.Parent.StatusService)

local UtilModule = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local AccessoryService = require(script.Parent.AccessoryService)
local ClassService = require(script.Parent.ClassService)
local ClassAppearance = require(ReplicatedStorage.Shared.Library.ClassAppearance)

local function SetupGameData(player: Player)
	local playerDataFolder = Instance.new("Folder")
	playerDataFolder.Name = "GameData"
	playerDataFolder.Parent = player

	local accessorysFolder = Instance.new("Folder")
	accessorysFolder.Name = "Accessorys"
	accessorysFolder.Parent = playerDataFolder

	local holstersFolder = Instance.new("Folder")
	holstersFolder.Name = "Holsters"
	holstersFolder.Parent = accessorysFolder

	local hairsFolder = Instance.new("Folder")
	hairsFolder.Name = "Hairs"
	hairsFolder.Parent = accessorysFolder

	local hatsFolder = Instance.new("Folder")
	hatsFolder.Name = "Hats"
	hatsFolder.Parent = accessorysFolder
end

local function SetupCharacterData(character: Model, player: Player)
	-- Runtime values live on the character rather than in the saved profile.  They
	-- are deliberately ordinary Value objects: perk/equipment code can inspect
	-- them, and they remain visible while debugging a live character.
	local function value(className: string, name: string, default: any)
		local object = character:FindFirstChild(name)
		if not object or object.ClassName ~= className then
			if object then object:Destroy() end
			object = Instance.new(className)
			object.Name = name
			object.Parent = character
		end
		object.Value = default
		return object
	end

	local function folder(name: string)
		local object = character:FindFirstChild(name)
		if not object or not object:IsA("Folder") then
			if object then object:Destroy() end
			object = Instance.new("Folder")
			object.Name = name
			object.Parent = character
		end
		return object
	end

	-- Keep these names compatible with the original character-data layout.
	-- `class` and `perk` are populated by ClassService when the spawn snapshot is
	-- applied; the rest describe this particular life only.
	value("BoolValue", "action", false)
	value("CFrameValue", "charPos", character:GetPivot())
	value("StringValue", "class", "")
	value("BoolValue", "crouching", false)
	folder("equipment")
	value("NumberValue", "extra_ammo", 0)
	value("BoolValue", "full_ammo", true)
	value("StringValue", "gender", "")
	value("StringValue", "language", "")
	value("StringValue", "last_equip", "")
	value("BoolValue", "leaning", false)
	value("StringValue", "perk", "")
	value("StringValue", "spawnanim", "")
	value("BoolValue", "tools_loaded", false)
	value("BoolValue", "turret_mounted", false)
	value("StringValue", "team", player.Team and player.Team.Name or "")
	folder("wounds")
	local animSaves = character:FindFirstChild("AnimSaves")
	if not animSaves then
		animSaves = Instance.new("ObjectValue")
		animSaves.Name = "AnimSaves"
		animSaves.Parent = character
	end

	local folder = Instance.new("Folder")
	folder.Name = "CharacterData"
	folder.Parent = character

	local holsterFolder = Instance.new("Folder")
	holsterFolder.Name = "Rendered_Holsters"
	holsterFolder.Parent = folder

	local equipmentFolder = Instance.new("Folder")
	equipmentFolder.Name = "Equipment"
	equipmentFolder.Parent = folder

	local woundFolder = Instance.new("Folder")
	woundFolder.Name = "Wounds"
	woundFolder.Parent = folder

	-- Explicit state instances make the current character state inspectable and
	-- give clients a stable replicated signal to subscribe to after respawn.
	local stateFolder = Instance.new("Folder")
	stateFolder.Name = "State"
	stateFolder.Parent = folder
	for _, name in { "Sprinting", "Crouching", "HoldBreathe", "Vaulting" } do
		local value = Instance.new("BoolValue")
		value.Name = name
		value.Value = false
		value.Parent = stateFolder
	end
	local equipment = Instance.new("StringValue")
	equipment.Name = "Equipment"
	equipment.Value = ""
	equipment.Parent = stateFolder
end

local function FetchHairAccessories(player: Player)
	local humanoidDescription: HumanoidDescription = Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
	local accessories = humanoidDescription:GetAccessories(true)

	for _, accessory: AccessoriesInfo in pairs(accessories) do
		if not accessory.AccessoryType.Name:find("Hair") then
			continue
		end

		local stringValue = Instance.new("StringValue")
		stringValue.Parent = player.GameData.Accessorys.Hairs
		stringValue.Name = "Hair" .. #player.GameData.Accessorys.Hairs:GetChildren()
		stringValue.Value = tostring(accessory.AssetId)
	end
end

local function HandleAccessory(player, child)
	-- Class hats are no longer generic accessories. They are mounted exclusively
	-- by ClassAppearance from Assets/outfits/<team>/<class> (or elite/...).
	-- Ignoring old saved helmet entries prevents Assets.Accessories from adding a
	-- second, stale class helmet after the correct outfit has been applied.
	if string.find(string.lower(child.Name), "helmet", 1, true) then
		return
	end
	if child:IsA("Model") then
		print("[PLAYERSERVICE] Accessory is a model:", child.Name)
		return
	end
	if child:GetAttribute("Given") then
		print("[PLAYERSERVICE] Accessory is already given:", child.Name)
		return
	end

	local accessory = UtilModule.fetch_accessory(child.Name)
	if not accessory then
		print("Accessory not found:", child.Name)
		return
	end

	UtilModule.quick_give_accessory(player, accessory, true, false, false)
	print("Gave accessory:", child.Name)
	child:SetAttribute("Given", true)

	-- // special child handling
	if child.Name == "LightEffect" then
		local spotlight1: PointLight = accessory.Torso.a0:FindFirstChildWhichIsA("SpotLight")
		local spotlight2: PointLight = accessory.Torso.a1:FindFirstChildWhichIsA("SpotLight")

		if player.Team.Name == "Golden Empire" then
			spotlight1.Color = Color3.fromRGB(255, 210, 119)
			spotlight2.Color = Color3.fromRGB(255, 210, 119)
		else
			spotlight1.Color = Color3.fromRGB(196, 202, 255)
			spotlight2.Color = Color3.fromRGB(196, 202, 255)
		end
	end
end

-- // Attempts to handle an accessory child, waiting briefly for ServerHandled if not yet set
local function TryHandleAccessory(player: Player, child: Instance)
	if not child:GetAttribute("ServerHandled") then
		-- // Wait up to 5 seconds for the ServerHandled attribute to be set
		local deadline = tick() + 5
		repeat
			task.wait(0.05)
		until child:GetAttribute("ServerHandled") or tick() >= deadline

		if not child:GetAttribute("ServerHandled") then
			print("[PLAYERSERVICE] ServerHandled never set for:", child.Name)
			return
		end
	end

	child:SetAttribute("Given", nil)
	HandleAccessory(player, child)
end

local accessoryConnections = {}

local function ApplyUniform(character: Model, player: Player)
	-- A character can load before GameManager assigns its team. Wait for a
	-- playable team so the uniform selection cannot fail and leave it naked.
	local shirtTemplate: Shirt?
	local pantsTemplate: Pants?

	repeat
		local team = player.Team
		if team and team.Name == "Golden Empire" then
			shirtTemplate = script:FindFirstChild("EmpireShirt") :: Shirt?
			pantsTemplate = script:FindFirstChild("EmpirePants") :: Pants?
		elseif team and team.Name == "Royal Nation" then
			shirtTemplate = script:FindFirstChild("NationShirt") :: Shirt?
			pantsTemplate = script:FindFirstChild("NationPants") :: Pants?
		end

		if not shirtTemplate or not pantsTemplate then
			player:GetPropertyChangedSignal("Team"):Wait()
		end
	until (shirtTemplate and pantsTemplate) or not player.Parent or player.Character ~= character

	if not shirtTemplate or not pantsTemplate or player.Character ~= character then
		return
	end

	-- ApplyDescription may leave more than one classic-clothing instance behind.
	-- Remove all competing clothes so Roblox renders only the team uniform.
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
			child:Destroy()
		end
	end

	local shirt = shirtTemplate:Clone()
	shirt.Parent = character
	local pants = pantsTemplate:Clone()
	pants.Parent = character
	ClassAppearance.Apply(character, player.Team and player.Team.Name, character:GetAttribute("Class") or "Soldat")
end

local function ApplyFullAppearance(character: Model, player: Player)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	-- Uniforms do not depend on Roblox's avatar API. Apply them first so a
	-- failed or throttled avatar lookup cannot leave the character undressed.
	ApplyUniform(character, player)
	if player.Character ~= character then return end
	character:SetAttribute("AppearanceReady", true)

	local success, avatarDescription = pcall(function()
		return Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
	end)
	if not success or not avatarDescription then
		warn("[PLAYERSERVICE] Could not load avatar description for", player.Name, avatarDescription)
		return
	end

	local currentDescription = humanoid:GetAppliedDescription()
	if not currentDescription then
		return
	end

	currentDescription.HeadColor = avatarDescription.HeadColor
	currentDescription.LeftArmColor = avatarDescription.LeftArmColor
	currentDescription.RightArmColor = avatarDescription.RightArmColor
	currentDescription.LeftLegColor = avatarDescription.LeftLegColor
	currentDescription.RightLegColor = avatarDescription.RightLegColor
	currentDescription.TorsoColor = avatarDescription.TorsoColor

	currentDescription.Head = avatarDescription.Head
	-- Player avatar clothing must not compete with the faction uniform.
	currentDescription.Shirt = 0
	currentDescription.Pants = 0
	currentDescription.GraphicTShirt = 0

	local hairsFolder = player:FindFirstChild("GameData")
		and player.GameData:FindFirstChild("Accessorys")
		and player.GameData.Accessorys:FindFirstChild("Hairs")

	if hairsFolder then
		local existing = {}

		if currentDescription.HairAccessory ~= "" then
			for id in string.gmatch(currentDescription.HairAccessory, "%d+") do
				table.insert(existing, id)
			end
		end

		for _, value: StringValue in ipairs(hairsFolder:GetChildren()) do
			if tonumber(value.Value) then
				local found = false
				for _, oldId in ipairs(existing) do
					if oldId == value.Value then
						found = true
						break
					end
				end
				if not found then
					table.insert(existing, value.Value)
				end
			end
		end

		currentDescription.HairAccessory = table.concat(existing, ",")
	end

	humanoid:ApplyDescription(currentDescription)

	-- ApplyDescription can finish reconciling character children on the next
	-- scheduler step, so restore the uniform once that work has settled.
	task.wait()
	ApplyUniform(character, player)

	local hair = character:WaitForChild("Hair", 10)
	if hair then
		local handle = hair:FindFirstChildWhichIsA("MeshPart") or hair:FindFirstChildWhichIsA("Part")
		if handle then
			local mesh: SpecialMesh = handle:FindFirstChildWhichIsA("SpecialMesh") or handle:FindFirstChildWhichIsA("MeshPart")
			if mesh then
				mesh.TextureId = ""
			end
			handle.Material = Enum.Material.Sand
			handle.BrickColor = BrickColor.new("Brown")
		end
	else
		warn("[PLAYERSERVICE] Hair not found on character within timeout:", character.Name)
	end

	local head = character:FindFirstChild("Head")
	if head then
		local headMesh = head:FindFirstChild("Mesh")
		if headMesh then
			headMesh.TextureId = ""
		end
		local decal = head:FindFirstChildWhichIsA("Decal")
		if decal then
			decal:Destroy()
		end
	end

	local accessorysFolder = player.GameData.Accessorys

	if accessoryConnections[player] then
		accessoryConnections[player]:Disconnect()
		accessoryConnections[player] = nil
	end

	for _, child in pairs(accessorysFolder:GetChildren()) do
		task.spawn(TryHandleAccessory, player, child)
	end

	accessoryConnections[player] = accessorysFolder.ChildAdded:Connect(function(child)
		task.spawn(TryHandleAccessory, player, child)
	end)

	character.Humanoid.Died:Connect(function()
		for _, child in pairs(character.CharacterData.Equipment:GetChildren()) do
			child:Destroy()
		end
	end)
end

local function SetupHitboxes(character: Model)
	local hitboxesFolder = Instance.new("Folder")
	hitboxesFolder.Name = "Hitboxes"
	hitboxesFolder.Parent = character

	local headHitbox = Instance.new("Part")
	headHitbox.Name = "Head"
	headHitbox.Parent = hitboxesFolder
	headHitbox.Size = Vector3.new(2, 2, 1.6)
	headHitbox.Transparency = 1
	headHitbox.CanCollide = false
	headHitbox.Massless = true
	headHitbox.BrickColor = BrickColor.new("Bright red")
	headHitbox:SetAttribute("Transparency_Skip", true)
	headHitbox:SetAttribute("Unpiercable", true)

	UtilModule.quick_weld(character.Head, headHitbox, character.Head, "HeadHitbox")
end

local function CopyUI(player)
	for _, child in pairs(game:GetService("ReplicatedStorage").Shared:WaitForChild("Library"):WaitForChild("UI"):GetChildren()) do
		local existing = player.PlayerGui:FindFirstChild(child.Name)
		if existing then
			-- Menu modules start once and retain references to these two trees.
			-- Preserve them across respawns instead of replacing their instances.
			if child.Name == "Menu" or child.Name == "Menu_Scenes" then
				for _, gui in ipairs(existing:GetDescendants()) do
					if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end
				end
				if existing:IsA("ScreenGui") then existing.ResetOnSpawn = false end
			end
			continue
		end
		local clone = child:Clone()
		if clone.Name == "Menu" or clone.Name == "Menu_Scenes" then
			for _, gui in ipairs(clone:GetDescendants()) do
				if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end
			end
			if clone:IsA("ScreenGui") then clone.ResetOnSpawn = false end
		end
		clone.Parent = player:WaitForChild("PlayerGui")
	end
end

local function CopyRespawnUI(player)
	for _, child: ScreenGui in pairs(game:GetService("ReplicatedStorage").Shared:WaitForChild("Library"):WaitForChild("UI"):GetChildren()) do
		if child.Name == "Menu" or child.Name == "Menu_Scenes" then
			-- These are normally persistent, but Roblox can still remove their
			-- ScreenGui descendants during a respawn. Restore the authored tree
			-- if it is absent instead of leaving MenuService with no UI to show.
			if not player.PlayerGui:FindFirstChild(child.Name) then
				local clone = child:Clone()
				for _, gui in ipairs(clone:GetDescendants()) do
					if gui:IsA("ScreenGui") then gui.ResetOnSpawn = false end
				end
				if clone:IsA("ScreenGui") then clone.ResetOnSpawn = false end
				clone.Parent = player:WaitForChild("PlayerGui")
			end
			continue
		end
		if player.PlayerGui:FindFirstChild(child.Name) then
			continue
		end

		if child:IsA("ScreenGui") then
			if child.ResetOnSpawn then
				child:Clone().Parent = player:WaitForChild("PlayerGui")
			end
		end
	end
end

local function HandleCharacter(player: Player, character: Model, ragdollObject)
	CopyRespawnUI(player)
	SetupCharacterData(character, player)
	ClassService.ApplySpawn(player, character)

	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false

	local maxHealth = character:GetAttribute("IsShockTrooper") and 300 or 200
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	SetupHitboxes(character)
	task.defer(function()
		ApplyFullAppearance(character, player)
	end)

	humanoid.Died:Connect(function()
		character.Archivable = true
		local characterClone = character:Clone()

		if workspace.Game_Details:FindFirstChild("Bodies") then
			characterClone.Parent = workspace.Game_Details.Bodies
		else
			local bodiesFolder = Instance.new("Folder")
			bodiesFolder.Name = "Bodies"
			bodiesFolder.Parent = workspace.Game_Details
			characterClone.Parent = bodiesFolder
		end

		ragdollObject:_special_apply(characterClone)

		player:SetAttribute("Active", nil)

		task.delay(60, function()
			characterClone:Destroy()
		end)

		task.delay(0.5, function()
			character:Destroy()
		end)
		player:SetAttribute("LastTagged", nil)
	end)

	local leftHip = character:FindFirstChild("Torso"):FindFirstChild("Left Hip")
	local rightHip = character:FindFirstChild("Torso"):FindFirstChild("Right Hip")

	-- // set part 0 as the legs, part1 as the hrp
	leftHip.Part0 = character:FindFirstChild("HumanoidRootPart")
	rightHip.Part0 = character:FindFirstChild("HumanoidRootPart")

	print("PlayerService: Setup hips")
	character:SetAttribute("ServerReady", true)
end

local function SetupPlayer(player: Player)
	CopyUI(player)
	SetupGameData(player)
	-- Client modules require these replicated roots at module load time. Publish
	-- one readiness signal only after the server has created both sets.
	player:SetAttribute("ClientDependenciesReady", true)
	local hairSuccess, hairError = pcall(FetchHairAccessories, player)
	if not hairSuccess then
		warn("[PLAYERSERVICE] Could not load hair accessories for", player.Name, hairError)
	end

	local ragdollObject = RagdollStatus.new()

	player.CharacterAdded:Connect(function(character)
		HandleCharacter(player, character, ragdollObject)
		StatusService.RemoveAllStatuses(player)
	end)

	if player.Character then
		HandleCharacter(player, player.Character, ragdollObject)
	end

	if player.Team.Name == "Golden Empire" then
		print("Setting up empire player")
		AccessoryService.GiveAccessory(player, "Empire_Belt", false, true, false)
		AccessoryService.GiveAccessory(player, "Empire_Lantern", false, true, false)
		AccessoryService.GiveAccessory(player, "Empire_Dogtag", false, true, false)
	else
		print("Setting up nation player")
		AccessoryService.GiveAccessory(player, "Nation_Belt", false, true, false)
		AccessoryService.GiveAccessory(player, "Nation_Lantern", false, true, false)
		AccessoryService.GiveAccessory(player, "Nation_Dogtag", false, true, false)
	end

	player:GetPropertyChangedSignal("Team"):Connect(function()
		local characterData = player.Character and player.Character:FindFirstChild("CharacterData")
		local teamValue = player.Character and player.Character:FindFirstChild("team")
		if teamValue and teamValue:IsA("StringValue") then teamValue.Value = player.Team and player.Team.Name or "" end
		local teamSide = characterData and characterData:FindFirstChild("TeamSide")
		if teamSide and teamSide:IsA("StringValue") then
			teamSide.Value = player.Team and player.Team.Name or ""
		end
		if player.Character then task.spawn(ApplyUniform, player.Character, player) end
		for _, child in pairs(player.GameData.Accessorys:GetChildren()) do
			if child.Name == "Empire_Soldat_Helmet" or child.Name == "Nation_Soldat_Helmet"
				or child.Name == "Empire_Belt" or child.Name == "Nation_Belt"
				or child.Name == "Empire_Lantern" or child.Name == "Nation_Lantern" then
				child:Destroy()
			end
		end

		if player.Team.Name == "Golden Empire" then
			AccessoryService.GiveAccessory(player, "Empire_Belt", false, true, false)
			AccessoryService.GiveAccessory(player, "Empire_Lantern", false, true, false)
			print("Gave Empire helmet")
		else
			AccessoryService.GiveAccessory(player, "Nation_Belt", false, true, false)
			AccessoryService.GiveAccessory(player, "Nation_Lantern", false, true, false)
			print("Gave Nation helmet")
		end
	end)

	AccessoryService.GiveAccessory(player, "LightEffect", false)
end

function Module.start_module()
	if TestingBoolean.Value == true then
		Players.CharacterAutoLoads = true
	end

	for _, player in ipairs(Players:GetPlayers()) do
		SetupPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		SetupPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if accessoryConnections[player] then
			accessoryConnections[player]:Disconnect()
			accessoryConnections[player] = nil
		end
	end)
end

return Module
