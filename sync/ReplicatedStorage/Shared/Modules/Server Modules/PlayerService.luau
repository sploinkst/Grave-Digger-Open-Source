local module = {}

local Players = game:GetService("Players")

local Animations_Folder = game:GetService("ReplicatedStorage").Shared.Assets.Animations.Character.Walking.Standing.Walk_Forward
local Ragdoll_Status = require(game:GetService("ReplicatedStorage").Shared.Library.Classes.StatusClasses.RagdollStatus)
local testing_boolean = game.ReplicatedStorage.Shared.Library.Configuration.Game_Variables.Testing_Boolean
local status_service = require(script.Parent.StatusService)


local shirt_clothing = script.Shirt
local pants_clothing = script.Pants

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

local function apply_full_appearance(character: Model, player: Player)
	local humanoid = character:WaitForChild("Humanoid")

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
	
	shirt_clothing:Clone().Parent = character
	pants_clothing:Clone().Parent = character

	-- // remove texture of the hair, give a sand material, and color it brown
	local hair = character:FindFirstChild("Hair")
	local handle = hair:FindFirstChild("Handle")
	local Mesh:SpecialMesh = handle:FindFirstChild("Mesh")
	Mesh.TextureId = ""
	handle.Material = Enum.Material.Sand
	handle.BrickColor = BrickColor.new("Brown")
	
	-- // remove face
	local head = character:FindFirstChild("Head")
	local head_mesh = head:FindFirstChild("Mesh")
	head_mesh.TextureId = ""
	head:FindFirstChildWhichIsA("Decal"):Destroy()
end

local function handle_character(player: Player, character: Model, ragdoll_object)
	setup_characterdata(character)

	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false

	humanoid.MaxHealth = 200
	humanoid.Health = 200
	
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
	end)
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
end

return module