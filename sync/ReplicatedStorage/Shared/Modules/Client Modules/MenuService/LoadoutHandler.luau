local module = {}

-- // Services
local player_service = game:GetService("Players")
local replicatedstorage_service = game:GetService("ReplicatedStorage")
local workspace_service = game:GetService("Workspace")

-- // Variables
local local_player = player_service.LocalPlayer

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

local Classes = require(
	replicatedstorage_service.Shared.Library.ClassDefinitions
)

local ClassAppearance = require(
	replicatedstorage_service.Shared.Library.ClassAppearance
)

-- // UI References
local loadout_ui
local scrolling_list
local scrolling_list_example
local options_frame
local primary_button
local secondary_button

local slot_buttons = {}

local defaultRowIcons = {}

-- // Preview
local preview
local previewGeneration = 0

-- // Connections
-- UI connections are intentionally separate from lifecycle connections.
local ui_connections = {}
local lifecycle_connections = {}

local started = false


-- // UI
local function disconnect_ui_connections()
	for _, connection in ipairs(ui_connections) do
		connection:Disconnect()
	end

	table.clear(ui_connections)
end


local function get_loadout_ui()
	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")

	if not player_gui then
		return false
	end

	local menu_scenes = player_gui:FindFirstChild("Menu_Scenes")

	if not menu_scenes then
		return false
	end

	local loadout = menu_scenes:FindFirstChild("Loadout")

	if not loadout then
		return false
	end

	local main_frame = loadout:FindFirstChild("Main_Frame")

	if not main_frame then
		return false
	end

	local new_scrolling_list =
		main_frame:FindFirstChild("Popup_Scrolling_List")

	local new_options_frame =
		main_frame:FindFirstChild("Weapon_Options")

	if not new_scrolling_list or not new_options_frame then
		return false
	end

	local new_example =
		new_scrolling_list:FindFirstChild("Example")

	if not new_example then
		return false
	end

	local new_primary =
		new_options_frame:FindFirstChild("Primary Sling")

	local new_secondary =
		new_options_frame:FindFirstChild("Secondary Holster")

	if not new_primary or not new_secondary then
		return false
	end

	-- Update references only after the entire UI has been validated.
	loadout_ui = main_frame
	scrolling_list = new_scrolling_list
	scrolling_list_example = new_example
	options_frame = new_options_frame

	primary_button = new_primary
	secondary_button = new_secondary

	slot_buttons = {
		Primary = primary_button,
		Secondary = secondary_button,
	}

	table.clear(defaultRowIcons)

	for _, row in options_frame:GetChildren() do
		local icon = row:FindFirstChild("wepicon")

		if icon then
			defaultRowIcons[row.Name] = icon.Image
		end
	end

	return true
end


-- // Weapon
local function is_locked(name: string)
	--[[
		Uncomment this if you want the unlock system.

		if local_player.PlayerData.PlayerData["Unlocked Items"]:FindFirstChild(name) then
			return false
		else
			return true
		end
	]]

	return false
end


local function clean_up_scrolling_list()
	if not scrolling_list or not scrolling_list.Parent then
		return
	end

	for _, child in ipairs(scrolling_list:GetChildren()) do
		if child.Name == "Example"
			or child:IsA("UIListLayout") then
			continue
		end

		child:Destroy()
	end
end


local function get_weapon_weight(weapon_name: string): number
	if weapon_name == "" then
		return 0
	end

	local weapon_script =
		gun_classes:FindFirstChild(weapon_name)
		or tool_classes:FindFirstChild(weapon_name)

	if not weapon_script
		or not weapon_script:IsA("ModuleScript") then
		return 0
	end

	local success, weapon_module =
		pcall(require, weapon_script)

	if not success then
		return 0
	end

	return weapon_module.Weight or 0
end


local function update_selected_weapon(
	slot_name: string,
	weapon_name: string,
	weapon_module
)
	local button = slot_buttons[slot_name]

	if not button then
		return
	end

	local weapon_name_label =
		button:FindFirstChild("wepname")

	local weapon_icon =
		button:FindFirstChild("wepicon")

	if weapon_name_label then
		weapon_name_label.Text =
			weapon_name == ""
			and "None"
			or weapon_name
	end

	if weapon_icon then
		weapon_icon.Image =
			weapon_module.Tool_Image or ""
	end
end


local function create_weapon_options(slot_name: string)
	if not loadout_ui
		or not loadout_ui.Parent then
		return
	end

	local definition =
		Classes.Get(Classes.Selected(local_player))

	if not definition then
		return
	end

	if definition.NoFirearms
		or (
			definition.FixedPrimary
				and slot_name == "Primary"
		) then
		return
	end

	clean_up_scrolling_list()

	-- // None
	local none =
		scrolling_list_example:Clone()

	none.Name = "None"

	local none_icon =
		none:FindFirstChild("wepicon")

	if none_icon then
		none_icon.Image = ""
	end

	local none_locked =
		none:FindFirstChild("weaponlocked")

	if none_locked then
		none_locked.Visible = false
	end

	local label =
		Instance.new("TextLabel")

	label.Text = "None"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Parent = none

	none.Visible = true
	none.Parent = scrolling_list

	none.Activated:Connect(function()
		datapush_event:FireServer(
			"Loadout" .. slot_name,
			""
		)

		clean_up_scrolling_list()
	end)

	-- // Weapon choices
	local choices =
		gun_classes:GetChildren()

	for _, child in ipairs(tool_classes:GetChildren()) do
		local success, class =
			pcall(require, child)

		if success
			and class.Designation == slot_name then

			table.insert(choices, child)
		end
	end

	for _, child in ipairs(choices) do
		if not child:IsA("ModuleScript") then
			continue
		end

		if child.Name == "AnimationResolver" then
			continue
		end
		if Classes.IsEliteWeapon(child.Name) then
			continue
		end

		local success, weapon_module =
			pcall(require, child)

		if not success then
			warn(
				"[LoadoutHandler] Could not load weapon",
				child.Name,
				weapon_module
			)

			continue
		end

		if weapon_module.Designation ~= slot_name then
			continue
		end

		local equipment = Classes.GetLoadout(local_player, Classes.Selected(local_player))
		if not equipment then continue end

		local other_slot_name =
			slot_name == "Primary"
			and "Secondary"
			or "Primary"

		local other_slot =
			equipment:FindFirstChild(other_slot_name)

		local other_weight = 0

		if other_slot then
			other_weight =
				get_weapon_weight(other_slot.Value)
		end

		local weapon_weight =
			weapon_module.Weight or 0

		local too_heavy =
			weapon_weight + other_weight
			> definition.MaxWeight

		local scrolling_clone =
			scrolling_list_example:Clone()

		scrolling_clone.Name = child.Name
		scrolling_clone.Visible = true
		scrolling_clone.Parent = scrolling_list

		local weapon_icon =
			scrolling_clone:FindFirstChild("wepicon")

		if weapon_icon then
			weapon_icon.Image =
				weapon_module.Tool_Image or ""
		end

		-- // Weight indicators
		local weapon_weight_frame =
			scrolling_clone:FindFirstChild("weaponweight")

		if weapon_weight_frame then
			local weight_example =
				weapon_weight_frame:FindFirstChild("ex")

			if weight_example then
				for _ = 1, weapon_weight do
					local weight_clone =
						weight_example:Clone()

					weight_clone.Parent =
						weapon_weight_frame

					weight_clone.Visible = true
				end
			end
		end

		local weapon_locked =
			scrolling_clone:FindFirstChild("weaponlocked")

		if weapon_locked then
			weapon_locked.Visible =
				is_locked(child.Name)
				or too_heavy
		end

		if not too_heavy
			and not is_locked(child.Name) then

			scrolling_clone.Activated:Connect(function()
				print(
					"[LoadoutHandler] Selected",
					child.Name,
					"for",
					slot_name
				)

				datapush_event:FireServer(
					"Loadout" .. slot_name,
					child.Name
				)

				clean_up_scrolling_list()
			end)
		end
	end
end


-- // Character Preview
local function setup_character()
	previewGeneration += 1

	local generation =
		previewGeneration

	local character =
		local_player.Character
		or local_player.CharacterAdded:Wait()

	while character == local_player.Character
		and generation == previewGeneration
		and not character:GetAttribute("AppearanceReady") do

		task.wait()
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		root =
			character:WaitForChild(
				"HumanoidRootPart",
				5
			)
	end

	if not root
		or character ~= local_player.Character
		or generation ~= previewGeneration then

		return
	end

	character.Archivable = true

	local character_clone =
		character:Clone()

	for _, descendant in character_clone:GetDescendants() do
		if descendant:IsA("LuaSourceContainer")
			or descendant:IsA("Tool") then

			descendant:Destroy()
		end
	end

	ClassAppearance.Apply(
		character_clone,
		local_player.Team
			and local_player.Team.Name,
		Classes.Selected(local_player)
	)

	local clone_root =
		character_clone:FindFirstChild(
			"HumanoidRootPart"
		)

	if not clone_root
		or not clone_root:IsA("BasePart") then

		character_clone:Destroy()
		return
	end

	-- Character may have respawned while we were cloning.
	if generation ~= previewGeneration
		or character ~= local_player.Character then

		character_clone:Destroy()
		return
	end

	if preview then
		preview:Destroy()
	end

	preview =
		character_clone

	character_clone.Name =
		"LoadoutPreview"

	clone_root.Anchored =
		true

	character_clone.Parent =
		character_spot.Parent

	clone_root.CFrame =
		character_spot.CFrame
end


-- // UI Rows
local function set_row(
	name,
	text: string?
)
	if not options_frame then
		return
	end

	local row =
		options_frame:FindFirstChild(name)

	if not row then
		return
	end

	local weapon_name =
		row:FindFirstChild("wepname")

	local weapon_icon =
		row:FindFirstChild("wepicon")

	if weapon_name then
		weapon_name.Text =
			text or name
	end

	if weapon_icon then
		local selected =
			Classes.Selected(local_player)

		if selected == "Soldat" then
			weapon_icon.Image =
				defaultRowIcons[name] or ""
		else
			weapon_icon.Image = ""
		end
	end
end


-- // Refresh
local function refresh_class()
	-- UI may have been recreated.
	if not loadout_ui
		or not loadout_ui.Parent then

		if not get_loadout_ui() then
			return
		end
	end

	local selected =
		Classes.Selected(local_player)

	local definition =
		Classes.Get(selected)

	if not definition then
		return
	end

	clean_up_scrolling_list()

	-- // Class buttons
	local buttons =
		loadout_ui:FindFirstChild(
			"Classes_Options"
		)

	if buttons then
		for _, name in Classes.Order do
			local button =
				buttons:FindFirstChild(
					string.lower(name)
				)

			if button then
				local border =
					button:FindFirstChild(
						"SelectedClassBorder"
					)

				if not border then
					border =
						Instance.new("UIStroke")

					border.Name =
						"SelectedClassBorder"

					border.Thickness = 2

					border.Color =
						Color3.fromRGB(
							238,
							220,
							149
						)

					border.Parent =
						button
				end

				border.Enabled =
					name == selected
			end
		end
	end

	-- // Class information
	set_row(
		"Combat Experience",
		definition.Passive
	)

	set_row(
		"Equipment Strap",
		if selected == "Vanguard"
			then "Guardian Spirit"
			else "Equipment Strap"
	)

	set_row(
		"Mining Pick Belt",
		if selected == "Rook"
			then "Heavy Pickaxe"
			else "Mining Pick"
	)

	set_row("First Aid Pouch")

	-- // Class tools
	local extra =
		options_frame:FindFirstChild(
			"Class Tools"
		)

	if not extra then
		extra =
			options_frame[
		"Mining Pick Belt"
		]:Clone()

		extra.Name =
			"Class Tools"

		extra.Parent =
			options_frame

		extra.cat.Text =
			"Class Tools"

		extra.wepicon.Image =
			""

		extra.LayoutOrder =
			options_frame[
		"Equipment Strap"
		].LayoutOrder + 1
	end

	local extras = {}

	for _, name in definition.Tools do
		if name ~= "Pickaxe"
			and name ~= "HeavyPickaxe" then

			-- gsub returns both the changed string and its replacement count. Keep
			-- only the string; otherwise table.insert treats the count as an index.
			table.insert(extras, (name:gsub("(%l)(%u)", "%1 %2")))
		end
	end

	extra.Visible =
		#extras > 0

	extra.wepname.Text =
		table.concat(
			extras,
			", "
		)

	-- // Equipment
	local equipment = Classes.GetLoadout(local_player, selected)
	if not equipment then return end

	for slot, button in slot_buttons do
		local name

		if slot == "Primary"
			and definition.FixedPrimary then

			name =
				definition.FixedPrimary

		elseif definition.NoFirearms then
			name = ""

		else
			local equipment_value =
				equipment:FindFirstChild(slot)

			name =
				equipment_value
				and equipment_value.Value
				or ""
		end

		local source =
			gun_classes:FindFirstChild(name)
			or tool_classes:FindFirstChild(name)

		local success = false
		local weapon

		if source then
			success, weapon =
				pcall(require, source)
		end

		if success then
			update_selected_weapon(
				slot,
				name,
				weapon
			)
		else
			local weapon_name =
				button:FindFirstChild(
					"wepname"
				)

			local weapon_icon =
				button:FindFirstChild(
					"wepicon"
				)

			if weapon_name then
				weapon_name.Text =
					name == ""
					and "None"
					or name
			end

			if weapon_icon then
				weapon_icon.Image =
					""
			end
		end
	end

	-- // Inventory weight
	local weights =
		loadout_ui:FindFirstChild(
			"Inventory_Weights"
		)

	if weights then
		local index = 0

		for _, child in weights:GetChildren() do
			if child:IsA("GuiObject")
				and child.Name ~= "ex" then

				index += 1

				child.Visible =
					index <= definition.MaxWeight
			end
		end
	end

	task.spawn(setup_character)
end


-- // UI Connections
local function setup_ui_connections()
	-- Only destroy UI connections.
	-- NEVER touch CharacterAdded/CharacterRemoving here.
	disconnect_ui_connections()

	if not get_loadout_ui() then
		warn(
			"[LoadoutHandler] Could not find Loadout UI"
		)

		return false
	end

	local equipment =
		local_player
		:WaitForChild("PlayerData")
		:WaitForChild("PlayerData")
		:WaitForChild("Equipment")

	local selected =
		equipment:WaitForChild("Class")

	local buttons =
		loadout_ui:WaitForChild(
			"Classes_Options"
		)

	-- // Class buttons
	for _, name in Classes.Order do
		local button =
			buttons:FindFirstChild(
				string.lower(name)
			)

		if button
			and button:IsA("GuiButton") then

			table.insert(
				ui_connections,
				button.Activated:Connect(
					function()
						datapush_event:FireServer(
							"LoadoutClass",
							name
						)
					end
				)
			)
		end
	end

	-- // Equipment buttons
	for slot, button in slot_buttons do
		table.insert(
			ui_connections,
			button.Activated:Connect(
				function()
					create_weapon_options(slot)
				end
			)
		)

		local equipment_value =
			equipment:FindFirstChild(slot)

		if equipment_value then
			table.insert(
				ui_connections,
				equipment_value.Changed:Connect(
					refresh_class
				)
			)
		end
	end

	-- // Class changed
	table.insert(
		ui_connections,
		selected.Changed:Connect(
			refresh_class
		)
	)

	return true
end


-- // Character Added
local function handle_character_added(character)
	previewGeneration += 1
	local generation = previewGeneration

	if preview then
		preview:Destroy()
		preview = nil
	end

	clean_up_scrolling_list()
	disconnect_ui_connections()

	loadout_ui = nil
	scrolling_list = nil
	scrolling_list_example = nil
	options_frame = nil
	primary_button = nil
	secondary_button = nil
	table.clear(slot_buttons)
	table.clear(defaultRowIcons)

	task.defer(function()
		task.wait()

		if character ~= local_player.Character
			or generation ~= previewGeneration then
			return
		end

		local player_gui =
			local_player:WaitForChild("PlayerGui")

		local menu_scenes =
			player_gui:WaitForChild("Menu_Scenes")

		local loadout =
			menu_scenes:WaitForChild("Loadout")

		local main_frame =
			loadout:WaitForChild("Main_Frame")

		-- Bail if a newer respawn superseded us while waiting.
		if character ~= local_player.Character
			or generation ~= previewGeneration then
			return
		end

		while not get_loadout_ui() do
			task.wait()

			if character ~= local_player.Character
				or generation ~= previewGeneration then
				return
			end
		end

		setup_ui_connections()
		refresh_class()
	end)
end


-- // Character Removing
local function handle_character_removing()
	previewGeneration += 1

	if preview then
		preview:Destroy()
		preview = nil
	end

	clean_up_scrolling_list()
	disconnect_ui_connections()
end


-- // Start
function module.start_module()
	if started then
		return
	end

	started = true

	-- // Initial UI
	if not get_loadout_ui() then
		local player_gui =
			local_player:WaitForChild(
				"PlayerGui"
			)

		player_gui
			:WaitForChild(
				"Menu_Scenes"
			)
			:WaitForChild(
				"Loadout"
			)
			:WaitForChild(
				"Main_Frame"
			)

		if not get_loadout_ui() then
			warn(
				"[LoadoutHandler] Failed to initialize Loadout UI"
			)

			return
		end
	end

	local equipment =
		local_player
		:WaitForChild("PlayerData")
		:WaitForChild("PlayerData")
		:WaitForChild("Equipment")

	equipment:WaitForChild("Class")

	-- // Initial UI connections
	setup_ui_connections()

	-- // These connections are NEVER disconnected
	table.insert(
		lifecycle_connections,
		local_player.CharacterAdded:Connect(
			handle_character_added
		)
	)

	table.insert(
		lifecycle_connections,
		local_player.CharacterRemoving:Connect(
			handle_character_removing
		)
	)

	table.insert(
		lifecycle_connections,
		local_player:GetPropertyChangedSignal(
			"Team"
		):Connect(
			refresh_class
		)
	)

	-- // Initial refresh
	refresh_class()
end


return module
