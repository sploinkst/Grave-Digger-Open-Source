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
local Classes = require(replicatedstorage_service.Shared.Library.ClassDefinitions)
local ClassAppearance = require(replicatedstorage_service.Shared.Library.ClassAppearance)
local defaultRowIcons = {}
for _, row in options_frame:GetChildren() do
	local icon = row:FindFirstChild("wepicon")
	if icon then defaultRowIcons[row.Name] = icon.Image end
end
local preview
local previewGeneration = 0
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
	local definition = Classes.Get(Classes.Selected(local_player))
	if definition.NoFirearms or (definition.FixedPrimary and slot_name == "Primary") then return end
	print("creating weapon options")
	clean_up_scrolling_list()

	local none = scrolling_list_example:Clone()
	none.Name = "None"; none.wepicon.Image = ""; none.weaponlocked.Visible = false
	local label = Instance.new("TextLabel")
	label.Text = "None"; label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1; label.Size = UDim2.fromScale(1, 1); label.Parent = none
	none.Visible = true; none.Parent = scrolling_list
	none.Activated:Connect(function()
		datapush_event:FireServer("Loadout" .. slot_name, "")
		clean_up_scrolling_list()
	end)
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
		local too_heavy = weapon_module.Weight + other_weight > definition.MaxWeight

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
				clean_up_scrolling_list()
			end)
		end

		print("created weapon option:", child.Name)
	end
end

local function setup_character()
	previewGeneration += 1
	local generation = previewGeneration
	local character = local_player.Character or local_player.CharacterAdded:Wait()
	while character == local_player.Character and generation == previewGeneration
		and not character:GetAttribute("AppearanceReady") do
		task.wait()
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		root = character:WaitForChild("HumanoidRootPart", 5)
	end
	if not root or character ~= local_player.Character or generation ~= previewGeneration then
		return
	end

	character.Archivable = true
	local character_clone = character:Clone()
	for _, descendant in character_clone:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("Tool") then descendant:Destroy() end
	end
	ClassAppearance.Apply(character_clone, local_player.Team and local_player.Team.Name, Classes.Selected(local_player))
	local clone_root = character_clone:FindFirstChild("HumanoidRootPart")
	if not clone_root or not clone_root:IsA("BasePart") then
		character_clone:Destroy()
		return
	end

	if preview then preview:Destroy() end
	preview = character_clone
	character_clone.Name = "LoadoutPreview"
	clone_root.Anchored = true
	character_clone.Parent = character_spot.Parent
	clone_root.CFrame = character_spot.CFrame
end

local function set_row(name, text: string?)
	local row = options_frame:FindFirstChild(name)
	if row and row:FindFirstChild("wepname") then
		row.wepname.Text = text or name
		if row:FindFirstChild("wepicon") then
			row.wepicon.Image = if Classes.Selected(local_player) == "Soldat" then defaultRowIcons[name] or "" else ""
		end
	end
end

local function refresh_class()
	local selected = Classes.Selected(local_player)
	local definition = Classes.Get(selected)
	clean_up_scrolling_list()
	local buttons = loadout_ui:FindFirstChild("Classes_Options")
	if buttons then
		for _, name in Classes.Order do
			local button = buttons:FindFirstChild(string.lower(name))
			if button then
				local border = button:FindFirstChild("SelectedClassBorder")
				if not border then
					border = Instance.new("UIStroke")
					border.Name = "SelectedClassBorder"; border.Thickness = 2
					border.Color = Color3.fromRGB(238, 220, 149); border.Parent = button
				end
				border.Enabled = name == selected
			end
		end
	end
	set_row("Combat Experience", definition.Passive)
	set_row("Equipment Strap", if selected == "Vanguard" then "Guardian Spirit" else "Equipment Strap")
	set_row("Mining Pick Belt", if selected == "Rook" then "Heavy Pickaxe" else "Mining Pick")
	set_row("First Aid Pouch")
	local extra = options_frame:FindFirstChild("Class Tools")
	if not extra then
		extra = options_frame["Mining Pick Belt"]:Clone()
		extra.Name = "Class Tools"; extra.Parent = options_frame
		extra.cat.Text = "Class Tools"; extra.wepicon.Image = ""
		extra.LayoutOrder = options_frame["Equipment Strap"].LayoutOrder + 1
	end
	local extras = {}
	for _, name in definition.Tools do
		-- gsub returns both the changed text and its replacement count. Wrap it
		-- so table.insert receives only the display name.
		if name ~= "Pickaxe" and name ~= "HeavyPickaxe" then
			table.insert(extras, (name:gsub("(%l)(%u)", "%1 %2")))
		end
	end
	extra.Visible = #extras > 0
	extra.wepname.Text = table.concat(extras, ", ")
	local equipment = local_player.PlayerData.PlayerData.Equipment
	for slot, button in slot_buttons do
		local name = if slot == "Primary" and definition.FixedPrimary then definition.FixedPrimary
			elseif definition.NoFirearms then "" else equipment[slot].Value
		local source = gun_classes:FindFirstChild(name) or tool_classes:FindFirstChild(name)
		local ok, weapon = false, nil
		if source then ok, weapon = pcall(require, source) end
		if ok then update_selected_weapon(slot, name, weapon)
		else button.wepname.Text = if name == "" then "None" else name; button.wepicon.Image = "" end
	end
	local weights = loadout_ui:FindFirstChild("Inventory_Weights")
	if weights then
		local index = 0
		for _, child in weights:GetChildren() do
			if child:IsA("GuiObject") and child.Name ~= "ex" then
				index += 1; child.Visible = index <= definition.MaxWeight
			end
		end
	end
	task.spawn(setup_character)
end

function module.start_module()
	local equipment = local_player:WaitForChild("PlayerData"):WaitForChild("PlayerData"):WaitForChild("Equipment")
	local selected = equipment:WaitForChild("Class")
	local buttons = loadout_ui:WaitForChild("Classes_Options")
	for _, name in Classes.Order do
		local button = buttons:FindFirstChild(string.lower(name))
		if button and button:IsA("GuiButton") then
			button.Activated:Connect(function() datapush_event:FireServer("LoadoutClass", name) end)
		end
	end
	for slot, button in slot_buttons do
		button.Activated:Connect(function() create_weapon_options(slot) end)
		equipment:WaitForChild(slot).Changed:Connect(refresh_class)
	end
	selected.Changed:Connect(refresh_class)
	local_player.CharacterAdded:Connect(function(character)
		if character:GetAttribute("ServerReady") then
			refresh_class()
		else
			character:GetAttributeChangedSignal("ServerReady"):Once(refresh_class)
		end
	end)
	local_player.CharacterRemoving:Connect(function()
		previewGeneration += 1
		if preview then preview:Destroy(); preview = nil end
	end)
	local_player:GetPropertyChangedSignal("Team"):Connect(refresh_class)
	refresh_class()
end

return module
