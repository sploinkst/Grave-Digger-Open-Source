local module = {}

-- // services
local player_service = game:GetService("Players")
local replicatedstorage_service = game:GetService("ReplicatedStorage")
local workspace_service = game:GetService("Workspace")
-- // vars
local local_player = player_service.LocalPlayer
local loadout_ui = local_player.PlayerGui:WaitForChild("Menu_Scenes"):WaitForChild("Loadout").Main_Frame

local gun_classes = replicatedstorage_service.Shared.Library.Classes.GunClasses
local character_spot = workspace_service
	:WaitForChild("Game_Details")
	:WaitForChild("Menus")
	:WaitForChild("Loadout_Scene")
	:WaitForChild("Character_Spot")

-- // ui stuff
local scrolling_list = loadout_ui.Popup_Scrolling_List
local scrolling_list_example = scrolling_list.Example

local options_frame = loadout_ui.Weapon_Options
local primary_button = options_frame["Primary Sling"]
local secondary_button = options_frame["Secondary Holster"]

-- // funcs
local function is_locked(name: string)
	--[[ this is commented out. uncomment this if you want the medal system.
		if local_player.PlayerData.PlayerData["Unlocked Items"]:FindFirstChild(name) then
		print("weapon is unlocked")
		return false
	else
		print("weapon is locked")
		return true
	end
	]]
	
	return false
end


local function clean_up_scrolling_list()
	for _, child in pairs(scrolling_list:GetChildren()) do
		if child.Name == "Example" or child:IsA("UIListLayout") then continue end

		child:Destroy()
	end
end



local function create_weapon_options()
	print("creating weapon options")
	clean_up_scrolling_list()
	
	-- // also create an empty variant
	local scrolling_clone = scrolling_list_example:Clone()
	scrolling_clone.Visible = true
	scrolling_clone.Parent = scrolling_list
	scrolling_clone.Name = "Empty"
	
	
	for _, child in pairs(gun_classes:GetChildren()) do
		if not child:IsA("ModuleScript") then continue end

		local scrolling_clone = scrolling_list_example:Clone()
		scrolling_clone.Parent = scrolling_list

		local weapon_module = require(child)

		scrolling_clone.wepicon.Image = weapon_module.Tool_Image

		-- create weights on clone
		for i = 1, weapon_module.Weight do
			local weight_example = scrolling_clone.weaponweight.ex:Clone()
			weight_example.Parent = scrolling_clone.weaponweight
			weight_example.Visible = true
		end
		
		if is_locked(child.Name) then
			scrolling_clone.weaponlocked.Visible = true
		end
		
		scrolling_clone.Name = child.Name
		scrolling_clone.Visible = true

	

		print("created weapon option:", child.Name)
	end
end

local function setup_character()
	local character = local_player.Character or local_player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		root = character:WaitForChild("HumanoidRootPart", 5)
	end
	if not root or character ~= local_player.Character then
		return
	end

	character.Archivable = true
	local character_clone = character:Clone()
	local clone_root = character_clone:FindFirstChild("HumanoidRootPart")
	if not clone_root or not clone_root:IsA("BasePart") then
		character_clone:Destroy()
		return
	end

	clone_root.Anchored = true
	character_clone.Parent = character_spot.Parent
	clone_root.CFrame = character_spot.CFrame
end

function module.start_module()
	
	primary_button.Activated:Connect(function()
		create_weapon_options()
		
		for _, child in pairs(scrolling_list:GetChildren()) do
			if child.Name == "Example" or child:IsA("UIListLayout") then continue end
			
			child.Activated:Connect(function()
				print("activated", child.Name)
			end)
		end
	end)
	
	
	secondary_button.Activated:Connect(function()
		create_weapon_options()
		
		for _, child in pairs(scrolling_list:GetChildren()) do
			if child.Name == "Example" or child:IsA("UIListLayout") then continue end
			
			child.Activated:Connect(function()
				print("activated", child.Name)
			end)
		end
	end)
	
	setup_character()
	
end

return module
