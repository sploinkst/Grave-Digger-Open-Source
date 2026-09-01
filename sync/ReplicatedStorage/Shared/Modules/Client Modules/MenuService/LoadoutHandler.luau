local module = {}

-- // services
local player_service = game:GetService("Players")
local replicatedstorage_service = game:GetService("ReplicatedStorage")
local workspace_service = game:GetService("Workspace")
-- // vars
local local_player = player_service.LocalPlayer
local loadout_ui = local_player.PlayerGui:WaitForChild("Menu_Scenes"):WaitForChild("Loadout").Main_Frame

local gun_classes = replicatedstorage_service.Shared.Library.Classes.GunClasses
local tool_classes = replicatedstorage_service.Shared.Library.Classes.ToolClasses
local datapush_event = replicatedstorage_service
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Events")
	:WaitForChild("Datapush")
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
local MAX_LOADOUT_WEIGHT = 3
local slot_buttons = {
	Primary = primary_button,
	Secondary = secondary_button,
}

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

local function get_weapon_weight(weapon_name: string): number
	local weapon_script = gun_classes:FindFirstChild(weapon_name) or tool_classes:FindFirstChild(weapon_name)
	if not weapon_script or not weapon_script:IsA("ModuleScript") then return 0 end
	local weapon_module = require(weapon_script)
	return weapon_module.Weight or 0
end

local function update_selected_weapon(slot_name: string, weapon_name: string, weapon_module)
	local button = slot_buttons[slot_name]
	if not button then return end
	button.wepname.Text = weapon_name
	button.wepicon.Image = weapon_module.Tool_Image
end



local function create_weapon_options(slot_name: string)
	print("creating weapon options")
	clean_up_scrolling_list()

	local choices = gun_classes:GetChildren()
	for _, child in ipairs(tool_classes:GetChildren()) do
		local ok, class = pcall(require, child)
		if ok and class.Designation == slot_name then table.insert(choices, child) end
	end
	for _, child in pairs(choices) do
		if not child:IsA("ModuleScript") or child.Name == "AnimationResolver" then continue end
		local success, weapon_module = pcall(require, child)
		if not success then
			warn("[LoadoutHandler] Could not load weapon", child.Name, weapon_module)
			continue
		end
		if weapon_module.Designation ~= slot_name then continue end

		local equipment = local_player.PlayerData.PlayerData.Equipment
		local other_slot_name = slot_name == "Primary" and "Secondary" or "Primary"
		local other_weight = get_weapon_weight(equipment[other_slot_name].Value)
		local too_heavy = weapon_module.Weight + other_weight > MAX_LOADOUT_WEIGHT

		local scrolling_clone = scrolling_list_example:Clone()
		scrolling_clone.Parent = scrolling_list

		scrolling_clone.wepicon.Image = weapon_module.Tool_Image

		-- create weights on clone
		for i = 1, weapon_module.Weight do
			local weight_example = scrolling_clone.weaponweight.ex:Clone()
			weight_example.Parent = scrolling_clone.weaponweight
			weight_example.Visible = true
		end
		
		if is_locked(child.Name) or too_heavy then
			scrolling_clone.weaponlocked.Visible = true
		end
		
		scrolling_clone.Name = child.Name
		scrolling_clone.Visible = true
		if not too_heavy then
			scrolling_clone.Activated:Connect(function()
				print("selected", child.Name, "for", slot_name)
				datapush_event:FireServer("Loadout" .. slot_name, child.Name)
				update_selected_weapon(slot_name, child.Name, weapon_module)
				clean_up_scrolling_list()
			end)
		end

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
	local equipment = local_player:WaitForChild("PlayerData")
		:WaitForChild("PlayerData")
		:WaitForChild("Equipment")
	for slot_name, button in pairs(slot_buttons) do
		local selected = equipment:WaitForChild(slot_name).Value
		local weapon_script = gun_classes:FindFirstChild(selected) or tool_classes:FindFirstChild(selected)
		if weapon_script and weapon_script:IsA("ModuleScript") then
			update_selected_weapon(slot_name, selected, require(weapon_script))
		end
	end
	
	primary_button.Activated:Connect(function()
		create_weapon_options("Primary")
	end)
	
	
	secondary_button.Activated:Connect(function()
		create_weapon_options("Secondary")
	end)
	
	setup_character()
	
end

return module
