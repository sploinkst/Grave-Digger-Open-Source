local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animations_Folder = ReplicatedStorage.Shared.Assets.Animations.Character.Walking.Standing.Walk_Forward
local Ragdoll_Status = require(ReplicatedStorage.Shared.Library.Classes.StatusClasses.RagdollStatus)
local testing_boolean = ReplicatedStorage.Shared.Library.Configuration.Game_Variables.Testing_Boolean
local status_service = require(script.Parent.StatusService)

local util_module = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local AccessoryService = require(script.Parent.AccessoryService)


local function setup_gamedata(player: Player)
	local player_data_folder = Instance.new("Folder")
	player_data_folder.Name = "GameData"
	player_data_folder.Parent = player

	local accessorys_folder = Instance.new("Folder")
	accessorys_folder.Name = "Accessorys"
	accessorys_folder.Parent = player_data_folder

	local holsters_folder = Instance.new("Folder")
	holsters_folder.Name = "Holsters"
	holsters_folder.Parent = accessorys_folder

	local hairs_folder = Instance.new("Folder")
	hairs_folder.Name = "Hairs"
	hairs_folder.Parent = accessorys_folder

	local hats_folder = Instance.new("Folder")
	hats_folder.Name = "Hats"
	hats_folder.Parent = accessorys_folder
end

local function setup_characterdata(character: Model)
	local folder = Instance.new("Folder")
	folder.Name = "CharacterData"
	folder.Parent = character

	local Holster_Folder = Instance.new("Folder")
	Holster_Folder.Name = "Rendered_Holsters"
	Holster_Folder.Parent = folder

	local Equipment_Folder = Instance.new("Folder")
	Equipment_Folder.Name = "Equipment"
	Equipment_Folder.Parent = folder

	local Wound_Folder = Instance.new("Folder")
	Wound_Folder.Name = "Wounds"
	Wound_Folder.Parent = folder
end

local function fetch_hair_accessories(player: Player)
	local humanoidDescription: HumanoidDescription = Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
	local accessories = humanoidDescription:GetAccessories(true)

	for _, accessory: AccessoriesInfo in pairs(accessories) do
		if not accessory.AccessoryType.Name:find("Hair") then continue end

		local string_value = Instance.new("StringValue")
		string_value.Parent = player.GameData.Accessorys.Hairs
		string_value.Name = "Hair" .. #player.GameData.Accessorys.Hairs:GetChildren()
		string_value.Value = tostring(accessory.AssetId)
	end
end

local function handle_accessory(player, child)
	if child:IsA("Model") then
		print("[PLAYERSERVICE] Accessory is a model:", child.Name)
		return
	end
	if child:GetAttribute("Given") then
		print("[PLAYERSERVICE] Accessory is already given:", child.Name)
		return
	end

	local accessory = util_module.fetch_accessory(child.Name)
	if not accessory then
		print("Accessory not found:", child.Name)
		return
	end

	util_module.quick_give_accessory(player, accessory, true, false, false)
	print("Gave accessory:", child.Name)
	child:SetAttribute("Given", true)

	-- // special child handling
	if child.Name == "LightEffect" then
		local spotlight_1: PointLight = accessory.Torso.a0:FindFirstChildWhichIsA("SpotLight")
		local spotlight_2: PointLight = accessory.Torso.a1:FindFirstChildWhichIsA("SpotLight")

		if player.Team.Name == "Golden Empire" then
			spotlight_1.Color = Color3.fromRGB(255, 210, 119)
			spotlight_2.Color = Color3.fromRGB(255, 210, 119)
		else
			spotlight_1.Color = Color3.fromRGB(196, 202, 255)
			spotlight_2.Color = Color3.fromRGB(196, 202, 255)
		end
	end
end

-- Attempts to handle an accessory child, waiting briefly for ServerHandled if not yet set
local function try_handle_accessory(player: Player, child: Instance)
	if not child:GetAttribute("ServerHandled") then
		-- Wait up to 5 seconds for the ServerHandled attribute to be set
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
	handle_accessory(player, child)
end

local accessory_connections = {}

local function apply_full_appearance(character: Model, player: Player)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	local success, avatarDescription = pcall(function()
		return Players:GetHumanoidDescriptionFromUserIdAsync(player.UserId)
	end)
	if not success or not avatarDescription then return end

	local currentDescription = humanoid:GetAppliedDescription()
	if not currentDescription then return end

	currentDescription.HeadColor = avatarDescription.HeadColor
	currentDescription.LeftArmColor = avatarDescription.LeftArmColor
	currentDescription.RightArmColor = avatarDescription.RightArmColor
	currentDescription.LeftLegColor = avatarDescription.LeftLegColor
	currentDescription.RightLegColor = avatarDescription.RightLegColor
	currentDescription.TorsoColor = avatarDescription.TorsoColor

	currentDescription.Head = avatarDescription.Head

	local hairs_folder = player:FindFirstChild("GameData")
		and player.GameData:FindFirstChild("Accessorys")
		and player.GameData.Accessorys:FindFirstChild("Hairs")

	if hairs_folder then
		local existing = {}

		if currentDescription.HairAccessory ~= "" then
			for id in string.gmatch(currentDescription.HairAccessory, "%d+") do
				table.insert(existing, id)
			end
		end

		for _, value: StringValue in ipairs(hairs_folder:GetChildren()) do
			if tonumber(value.Value) then
				local found = false
				for _, old_id in ipairs(existing) do
					if old_id == value.Value then
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

	local shirt
	local pants

	if player.Team.Name == "Golden Empire" then
		shirt = script.EmpireShirt:Clone()
		pants = script.EmpirePants:Clone()
	elseif player.Team.Name == "Royal Nation" then
		shirt = script.NationShirt:Clone()
		pants = script.NationPants:Clone()
	end

	shirt.Parent = character
	pants.Parent = character

	local hair = character:WaitForChild("Hair", 10)
	if hair then
		local handle = hair:FindFirstChildWhichIsA("MeshPart") or hair:FindFirstChildWhichIsA("Part")
		if handle then
			local Mesh: SpecialMesh = handle:FindFirstChildWhichIsA("SpecialMesh") or handle:FindFirstChildWhichIsA("MeshPart")
			if Mesh then
				Mesh.TextureId = ""
			end
			handle.Material = Enum.Material.Sand
			handle.BrickColor = BrickColor.new("Brown")
		end
	else
		warn("[PLAYERSERVICE] Hair not found on character within timeout:", character.Name)
	end

	local head = character:FindFirstChild("Head")
	if head then
		local head_mesh = head:FindFirstChild("Mesh")
		if head_mesh then
			head_mesh.TextureId = ""
		end
		local decal = head:FindFirstChildWhichIsA("Decal")
		if decal then
			decal:Destroy()
		end
	end

	local accessorysFolder = player.GameData.Accessorys

	if accessory_connections[player] then
		accessory_connections[player]:Disconnect()
		accessory_connections[player] = nil
	end

	for _, child in pairs(accessorysFolder:GetChildren()) do
		task.spawn(try_handle_accessory, player, child)
	end

	accessory_connections[player] = accessorysFolder.ChildAdded:Connect(function(child)
		task.spawn(try_handle_accessory, player, child)
	end)
end

local function setup_hitboxes(character: Model)
	local hitboxes_folder = Instance.new("Folder")
	hitboxes_folder.Name = "Hitboxes"
	hitboxes_folder.Parent = character

	local head_hitbox = Instance.new("Part")
	head_hitbox.Name = "Head"
	head_hitbox.Parent = hitboxes_folder
	head_hitbox.Size = Vector3.new(2, 2, 1.6)
	head_hitbox.Transparency = 1
	head_hitbox.CanCollide = false
	head_hitbox.Massless = true
	head_hitbox.BrickColor = BrickColor.new("Bright red")
	head_hitbox:SetAttribute("Transparency_Skip", true)
	head_hitbox:SetAttribute("Unpiercable", true)

	util_module.quick_weld(character.Head, head_hitbox, character.Head, "HeadHitbox")
end

local function handle_character(player: Player, character: Model, ragdoll_object)
	setup_characterdata(character)

	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false

	humanoid.MaxHealth = 200
	humanoid.Health = 200
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	setup_hitboxes(character)
	task.defer(function()
		apply_full_appearance(character, player)
	end)

	humanoid.Died:Connect(function()
		character.Archivable = true
		local character_clone = character:Clone()

		if workspace.Game_Details:FindFirstChild("Bodies") then
			character_clone.Parent = workspace.Game_Details.Bodies
		else
			local bodies_folder = Instance.new("Folder")
			bodies_folder.Name = "Bodies"
			bodies_folder.Parent = workspace.Game_Details
			character_clone.Parent = bodies_folder
		end

		character:Destroy()

		ragdoll_object:_special_apply(character_clone)

		player:SetAttribute("Active", nil)

		task.delay(60, function()
			character_clone:Destroy()
		end)
	end)
	
	character:SetAttribute("ServerReady", true)
end

local function setup_player(player: Player)
	setup_gamedata(player)
	fetch_hair_accessories(player)

	local ragdoll_object = Ragdoll_Status.new()

	player.CharacterAdded:Connect(function(character)
		handle_character(player, character, ragdoll_object)
		status_service.remove_all_statuses(player)
	end)

	if player.Character then
		handle_character(player, player.Character, ragdoll_object)
	end

	if player.Team.Name == "Golden Empire" then
		AccessoryService.give_accessory(player, "Empire_Soldat_Helmet", true, true, false)
		AccessoryService.give_accessory(player, "Empire_Belt", false, true, false)
		AccessoryService.give_accessory(player, "Empire_Lantern", false, true, false)
		AccessoryService.give_accessory(player, "Empire_Dogtag", false, true, false)
	else
		AccessoryService.give_accessory(player, "Nation_Soldat_Helmet", true, true, false)
		AccessoryService.give_accessory(player, "Nation_Belt", false, true, false)
		AccessoryService.give_accessory(player, "Nation_Lantern", false, true, false)
		AccessoryService.give_accessory(player, "Nation_Dogtag", false, true, false)
	end

	player.Team.Changed:Connect(function()
		for _, child in pairs(player.GameData.Accessorys:GetChildren()) do
			if child.Name == "Empire_Soldat_Helmet" or child.Name == "Nation_Soldat_Helmet"
				or child.Name == "Empire_Belt" or child.Name == "Nation_Belt"
				or child.Name == "Empire_Lantern" or child.Name == "Nation_Lantern" then
				child:Destroy()
			end
		end

		if player.Team.Name == "Golden Empire" then
			AccessoryService.give_accessory(player, "Empire_Soldat_Helmet", true, true, false)
			AccessoryService.give_accessory(player, "Empire_Belt", false, true, false)
			AccessoryService.give_accessory(player, "Empire_Lantern", false, true, false)
			print("Gave Empire helmet")
		else
			AccessoryService.give_accessory(player, "Nation_Soldat_Helmet", true, true, false)
			AccessoryService.give_accessory(player, "Nation_Belt", false, true, false)
			AccessoryService.give_accessory(player, "Nation_Lantern", false, true, false)
			print("Gave Nation helmet")
		end
	end)

	AccessoryService.give_accessory(player, "LightEffect", false)
end

function module.start_module()
	if testing_boolean.Value == true then
		Players.CharacterAutoLoads = true
	end

	for _, player in ipairs(Players:GetPlayers()) do
		setup_player(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		setup_player(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if accessory_connections[player] then
			accessory_connections[player]:Disconnect()
			accessory_connections[player] = nil
		end
	end)
end

return module