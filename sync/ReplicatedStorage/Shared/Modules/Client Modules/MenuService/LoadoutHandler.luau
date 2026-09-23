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
local WeaponIds = require(
	replicatedstorage_service.Shared.Library.WeaponIds
)

local WeaponHandling = require(replicatedstorage_service.Shared.Library.WeaponHandling)

local PENETRATION_NAMES = {
	"Little", "Weak", "Decent", "Strong", "Powerful", "Devastating",
}

local function image_id(value): string
	if value == nil then return "" end
	local text = tostring(value)
	if text == "" or text:find("rbxasset", 1, true) then return text end
	return "rbxassetid://" .. text
end

local function set_text(parent: Instance?, name: string, value)
	local label = parent and parent:FindFirstChild(name, true)
	if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
		label.Text = tostring(value or "")
	end
end

local function set_bar(frame: Instance?, value: number)
	local inner = frame and frame:FindFirstChild("inner", true)
	if inner and inner:IsA("GuiObject") then
		inner.Size = UDim2.new(math.clamp(value, 0, 1), 0, 1, 0)
	end
end

local function format_assist(text: string): string
	local settings = local_player:FindFirstChild("PlayerData")
	settings = settings and settings:FindFirstChild("Settings Data")
	local inputs = settings and settings:FindFirstChild("Inputs")
	local binds = inputs and inputs:FindFirstChild("Binds")
	local function current_bind(name: string, fallback: string): string
		local bind = binds and binds:FindFirstChild(name)
		local current = bind and bind:FindFirstChild("Current")
		return current and tostring(current.Value) or fallback
	end
	local replacements = {
		["@ALT"] = current_bind("Alternate Action", "Q"),
		["@CHECK"] = current_bind("Check Ammo", "H"),
		["@RELOAD"] = current_bind("Reload", "R"),
		["@EQUIP"] = current_bind("Equipment", "1/2"),
		["@WALKER1"] = "1",
		["@WALKER2"] = "2",
		["@WALKER3"] = "3",
		["@WALKER4"] = "4",
	}
	for token, replacement in pairs(replacements) do
		text = text:gsub(token, replacement)
	end
	return text
end

-- // UI References
local loadout_ui
local scrolling_list
local scrolling_list_example
local options_frame
local primary_button
local secondary_button

local slot_buttons = {}

local defaultRows = {}

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

	table.clear(defaultRows)

	for _, row in options_frame:GetChildren() do
		local icon = row:FindFirstChild("wepicon")
		local category = row:FindFirstChild("cat")
		local weapon_name = row:FindFirstChild("wepname")

		if icon or category or weapon_name then
			defaultRows[row.Name] = {
				Icon = icon and icon.Image or "",
				Category = category and category.Text or row.Name,
				Name = weapon_name and weapon_name.Text or row.Name,
			}
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


local function get_master_weapon_data(weapon_module, weapon_name: string?)
	local merged = {}
	local asset_name = WeaponIds.AssetName(weapon_name or weapon_module.className or "")
	local legacy_folder = gun_classes:FindFirstChild("weapon_modules")
	local legacy_source = legacy_folder and legacy_folder:FindFirstChild(asset_name)
	if legacy_source and legacy_source:IsA("ModuleScript") then
		local ok, legacy = pcall(require, legacy_source)
		if ok and type(legacy) == "table" then
			for key, value in pairs(legacy) do merged[key] = value end
		end
	end
	for key, value in pairs(weapon_module) do
		if value ~= nil and value ~= "" then merged[key] = value end
	end
	return merged
end

local function get_legacy_item_data(asset_name: string)
	local legacy_folder = gun_classes:FindFirstChild("weapon_modules")
	local source = legacy_folder and legacy_folder:FindFirstChild(asset_name)
	if not source or not source:IsA("ModuleScript") then return nil end
	local ok, data = pcall(require, source)
	return ok and type(data) == "table" and data or nil
end

local function show_weapon_details(weapon_module, weapon_name: string?)
	if not loadout_ui or type(weapon_module) ~= "table" then return end
	weapon_module = get_master_weapon_data(weapon_module, weapon_name)
	local stats_side = loadout_ui:FindFirstChild("Statistics") or loadout_ui:FindFirstChild("statsside")
	if not stats_side then return end

	stats_side.Visible = true
	local icon = stats_side:FindFirstChild("wepicon")
	if icon and icon:IsA("ImageLabel") then
		icon.Image = image_id(weapon_module.icon or weapon_module.Tool_Image)
	end
	set_text(stats_side, "wepnametext", weapon_module.Display_Name or weapon_module.name)

	local description = stats_side:FindFirstChild("descscroll")
	set_text(description, "desc", weapon_module.desc)
	if description and description:IsA("ScrollingFrame") then
		description.CanvasPosition = Vector2.zero
	end

	local lore_panel = stats_side:FindFirstChild("perklore_lower")
	local lore_scroll = lore_panel and lore_panel:FindFirstChild("scroll")
	set_text(lore_scroll, "desc", weapon_module.lore)
	if lore_scroll and lore_scroll:IsA("ScrollingFrame") then
		lore_scroll.CanvasPosition = Vector2.zero
	end
	if lore_panel and lore_panel:IsA("GuiObject") then
		lore_panel.Visible = false
	end
	local view_lore = stats_side:FindFirstChild("viewlore")
	if view_lore and view_lore:IsA("GuiObject") then
		view_lore.Visible = weapon_module.lore ~= nil and weapon_module.lore ~= ""
		if view_lore:IsA("TextButton") then
			view_lore.Text = "Show History & Lore"
		end
	end

	local assists_panel = stats_side:FindFirstChild("stats_assist")
	local assists_scroll = assists_panel and assists_panel:FindFirstChild("scroll")
	local assists = weapon_module.assists
	if assists_panel and assists_panel:IsA("GuiObject") then
		assists_panel.Visible = type(assists) == "table" and #assists > 0
	end
	if assists_scroll then
		for _, child in ipairs(assists_scroll:GetChildren()) do
			if child.Name ~= "ex" and not child:IsA("UIListLayout") then child:Destroy() end
		end
		local example = assists_scroll:FindFirstChild("ex")
		if example and type(assists) == "table" then
			for order, assist in ipairs(assists) do
				local row = example:Clone()
				row.Name = "assist"
				row.LayoutOrder = order
				if row:IsA("TextLabel") or row:IsA("TextButton") then
					row.Text = "- " .. format_assist(assist)
				else
					set_text(row, "label", "- " .. format_assist(assist))
				end
				row.Visible = true
				row.Parent = assists_scroll
			end
		end
	end

	local stats_lower = stats_side:FindFirstChild("statslower")
	local is_gun = weapon_module.tooltype == "gun"
	if stats_lower and stats_lower:IsA("GuiObject") then stats_lower.Visible = is_gun end
	local stats_range = stats_side:FindFirstChild("statsrange")
	if stats_range and stats_range:IsA("GuiObject") then stats_range.Visible = is_gun end
	if not is_gun then return end
	local range_page = stats_range and stats_range:FindFirstChild("rangestats")
	local handling_page = stats_range and stats_range:FindFirstChild("handlingstats")
	if range_page and range_page:IsA("GuiObject") then range_page.Visible = true end
	if handling_page and handling_page:IsA("GuiObject") then handling_page.Visible = false end
	set_text(stats_range, "toptext", "Damage Range Info")

	local damage = weapon_module.damage or 0
	local mid_damage = weapon_module.range_damage or damage
	local far_damage = weapon_module.far_damage or mid_damage
	local pellets = weapon_module.pellets or 1
	local accuracy = weapon_module.accuracy or 50
	local moving_accuracy = math.max(weapon_module.moving_accuracy or accuracy, 0.001)
	local recoil = weapon_module.recoil or 0
	local recoil_count = weapon_module.recoil_count or 6
	if stats_lower then
		set_bar(stats_lower:FindFirstChild("statline1"), (damage + mid_damage / 2 + far_damage / 2) * pellets / 300)
		set_bar(stats_lower:FindFirstChild("statline2"), (50 - accuracy) / 50)
		set_bar(stats_lower:FindFirstChild("statline3"), accuracy / moving_accuracy)
		set_bar(stats_lower:FindFirstChild("statline4"), (60 - recoil * (recoil_count / 6)) / 60)
		local total_delay = (weapon_module.fire_rate or 1) + (weapon_module.cycle or 0) + (weapon_module.cycle_rest or 0)
		set_text(stats_lower:FindFirstChild("statline5"), "insidetext", weapon_module.display_fire_rate or math.ceil(60 / math.max(total_delay, 0.001)))
		local capacity = weapon_module.capacity or 0
		local ammo_text = tostring(capacity)
		if not weapon_module.hidereserves then
			ammo_text ..= " | " .. capacity * (weapon_module.ammo_reserves or 0) .. "/" .. capacity * (weapon_module.ammo_reserves_max or 0)
		end
		set_text(stats_lower:FindFirstChild("statline6"), "insidetext", ammo_text)
	end

	local range_stats = stats_range and stats_range:FindFirstChild("rangestats")
	if range_stats then
		local close = range_stats:FindFirstChild("rangeclose")
		local mid = range_stats:FindFirstChild("rangemid")
		local long = range_stats:FindFirstChild("rangelong")
		set_text(close, "rangeclose", "<" .. tostring(weapon_module.range or 0) .. " std")
		if close and (close:IsA("TextLabel") or close:IsA("TextButton")) then close.Text = "<" .. tostring(weapon_module.range or 0) .. " std" end
		set_text(close, "insidetext", damage * pellets)
		if mid and (mid:IsA("TextLabel") or mid:IsA("TextButton")) then mid.Text = tostring(weapon_module.range or 0) .. " std" end
		set_text(mid, "insidetext", mid_damage * pellets)
		if long and (long:IsA("TextLabel") or long:IsA("TextButton")) then long.Text = tostring(weapon_module.far or 0) .. " std" end
		set_text(long, "insidetext", far_damage * pellets)
	end

	local handling = stats_range and stats_range:FindFirstChild("handlingstats")
	if handling then
		local penetration = math.clamp((weapon_module.pen or 0) + 1, 1, #PENETRATION_NAMES)
		set_text(handling:FindFirstChild("penpower"), "insidetext", PENETRATION_NAMES[penetration])
		set_text(handling:FindFirstChild("aimspeed"), "insidetext", tostring(weapon_module.draw_speed or 0) .. "s | " .. tostring(weapon_module.aim_speed or 0) .. "s")
		local reload = ((weapon_module.reload_loop or 0) + (weapon_module.reload_loop_after or 0)) * (weapon_module.capacity or 0)
			+ (weapon_module.reload_start or 0) + (weapon_module.reload_end or 0)
		set_text(handling:FindFirstChild("reloadfull"), "insidetext", tostring(math.ceil(reload * 100) / 100) .. "s")
	end
end

local function show_item_details(item_name: string?, legacy_asset: string?, fallback)
	-- Explicit legacy IDs are the authoritative master-script records for menu
	-- tools. Their modern controller classes intentionally contain behaviour,
	-- not the descriptive/stat fields used by this panel.
	local legacy = legacy_asset and get_legacy_item_data(legacy_asset)
	if legacy then
		show_weapon_details(legacy)
		return
	end

	if item_name and item_name ~= "" then
		local source = gun_classes:FindFirstChild(item_name)
			or tool_classes:FindFirstChild(item_name)
		if source and source:IsA("ModuleScript") then
			local ok, data = pcall(require, source)
			if ok and type(data) == "table" then
				show_weapon_details(data, item_name)
				return
			end
		end
	end

	if fallback then
		show_weapon_details(fallback)
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
			or weapon_module.Display_Name
			or weapon_module.name
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

	set_text(none, "wepname", "None")
	set_text(none, "desc", "Leave this equipment slot empty.")

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

		if child.Name == "AnimationResolver"
			or child.Name == "LegacyGunFactory" then
			continue
		end
		if child.Parent == gun_classes and not WeaponHandling.IsBaseline(child.Name) then
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

		if weapon_module.HiddenFromLoadout == true then
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
			> Classes.GetMaxWeight(local_player)

		local scrolling_clone =
			scrolling_list_example:Clone()

		scrolling_clone.Name = child.Name
		scrolling_clone.Visible = true
		scrolling_clone.Parent = scrolling_list

		local weapon_icon =
			scrolling_clone:FindFirstChild("wepicon")

		if weapon_icon then
			weapon_icon.Image =
				image_id(weapon_module.icon or weapon_module.Tool_Image)
		end
		local menu_data = get_master_weapon_data(weapon_module, child.Name)
		set_text(scrolling_clone, "wepname", menu_data.Display_Name or menu_data.name or child.Name)
		set_text(scrolling_clone, "desc", menu_data.desc)

		local function preview_details()
			show_weapon_details(weapon_module, child.Name)
		end
		scrolling_clone.MouseEnter:Connect(preview_details)
		scrolling_clone.SelectionGained:Connect(preview_details)

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
	local appearance_deadline = os.clock() + 10

	while character == local_player.Character
		and generation == previewGeneration
		and not character:GetAttribute("AppearanceReady")
		and os.clock() < appearance_deadline do

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
	text: string?,
	category_text: string?,
	icon: string?
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
	local category = row:FindFirstChild("cat")
	local defaults = defaultRows[name]

	if category then
		category.Text = category_text or (defaults and defaults.Category) or name
	end

	if weapon_name then
		weapon_name.Text =
			text or (defaults and defaults.Name) or name
	end

	if weapon_icon then
		weapon_icon.Image = icon ~= nil and image_id(icon)
			or (defaults and defaults.Icon) or ""
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
	local special_rows = {
		Soldat = { Category = "Combat Experience", Name = "Duty & Virtue" },
		Rook = { Category = "Hammer Holder", Name = "Construct Hammer", Asset = "hammer" },
		Mortician = { Category = "Stimulants Pouch", Name = "Stimulant Compounds" },
		Officer = { Category = "Binoculars Pouch", Name = "Recon Kit" },
		Jaeger = { Category = "Trapper Kit", Name = "Hunter Kit" },
		Lancer = { Category = "Injector Strap", Name = "Painkiller Injector" },
		Vanguard = { Category = "Flag Bundle", Name = "Rally Banner" },
	}
	local special = special_rows[selected] or special_rows.Soldat
	local special_icon
	if special.Asset then
		local legacy_folder = gun_classes:FindFirstChild("weapon_modules")
		local source = legacy_folder and legacy_folder:FindFirstChild(special.Asset)
		if source and source:IsA("ModuleScript") then
			local ok, data = pcall(require, source)
			if ok then special_icon = data.icon end
		end
	end
	set_row("Combat Experience", special.Name, special.Category, special_icon)

	local equipment_icon
	if selected == "Rook" then
		local source = gun_classes:FindFirstChild("RookLauncher")
		if source and source:IsA("ModuleScript") then
			local ok, data = pcall(require, source)
			if ok then equipment_icon = get_master_weapon_data(data, "RookLauncher").icon end
		end
	end
	set_row(
		"Equipment Strap",
		definition.EquipmentName,
		if selected == "Vanguard" then "Guardian Spirit" else "Equipment Strap",
		equipment_icon
	)

	set_row(
		"Mining Pick Belt",
		if selected == "Rook" then "Heavy Pickaxe" else "Mining Pick",
		if selected == "Rook" then "Heavy Pick Sling" else "Mining Pick Belt"
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

	-- Class-specific tools occupy the authored special row above. The previous
	-- generic clone produced an extra "Class Tools" entry and displaced the
	-- equipment/perk rows compared with the original menu.
	extra.Visible = false

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

		if source and source.Parent == gun_classes and not WeaponHandling.IsBaseline(name) then
			source = nil
			name = ""
		end

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

	local perk_row = options_frame:FindFirstChild("Perk Slot")
	local perk_value = equipment:FindFirstChild("Perk")
	if perk_row then
		local perk_name = perk_value and perk_value.Value or ""
		set_text(perk_row, "wepname", perk_name == "" and "None" or perk_name)
	end

	-- // Inventory weight
	local weights =
		loadout_ui:FindFirstChild(
			"Inventory_Weights"
		)

	if weights then
		local max_weight = Classes.GetMaxWeight(local_player)
		local template = weights:FindFirstChild("ex")
		local indicators = {}

		for _, child in weights:GetChildren() do
			if child:IsA("GuiObject")
				and child.Name ~= "ex" then
				table.insert(indicators, child)
			end
		end

		if template and template:IsA("GuiObject") then
			for index = #indicators + 1, max_weight do
				local indicator = template:Clone()
				indicator.Name = "Weight_" .. index
				indicator.Parent = weights
				table.insert(indicators, indicator)
			end
		end

		for index, indicator in indicators do
			indicator.Visible = index <= max_weight
		end
	end

	task.spawn(setup_character)
end


local SPECIAL_DETAIL_ASSETS = {
	Rook = "hammer",
	Mortician = "stimbottle",
	Officer = "binocs",
	Jaeger = "jaegerkit",
	Lancer = "lancerstim",
	Vanguard = "flagpole",
}

local EQUIPMENT_DETAIL_ASSETS = {
	Rook = "rooklauncher",
	Mortician = "stims",
	Officer = "whistle",
	Jaeger = "nebel",
	Lancer = "throwaxe",
	Vanguard = "flagpole",
}

local function preview_inventory_row(row_name: string)
	local selected = Classes.Selected(local_player)
	local definition = Classes.Get(selected)
	local equipment = Classes.GetLoadout(local_player, selected)

	if row_name == "Primary Sling" or row_name == "Secondary Holster" then
		local slot = row_name == "Primary Sling" and "Primary" or "Secondary"
		local value = equipment and equipment:FindFirstChild(slot)
		local item_name = value and value.Value or ""
		if slot == "Primary" and definition.FixedPrimary then
			item_name = definition.FixedPrimary
		elseif definition.NoFirearms then
			item_name = ""
		end
		show_item_details(item_name)
	elseif row_name == "Melee Sheath" then
		local value = equipment and equipment:FindFirstChild("Melee")
		local item_name = value and value.Value or "Knife"
		show_item_details(item_name, WeaponIds.AssetName(item_name))
	elseif row_name == "Mining Pick Belt" then
		show_item_details(
			selected == "Rook" and "HeavyPickaxe" or "Pickaxe",
			selected == "Rook" and "pickaxe" or "pick"
		)
	elseif row_name == "First Aid Pouch" then
		show_item_details("FirstAidKit", "firstaid")
	elseif row_name == "Combat Experience" then
		show_item_details(nil, SPECIAL_DETAIL_ASSETS[selected], {
			name = definition.Passive,
			desc = "Class specialty for the " .. selected .. ".",
			lore = "",
		})
	elseif row_name == "Equipment Strap" then
		show_item_details(nil, EQUIPMENT_DETAIL_ASSETS[selected], {
			name = definition.EquipmentName,
			desc = "Class equipment issued to the " .. selected .. ".",
			lore = "",
		})
	elseif row_name == "Perk Slot" then
		local value = equipment and equipment:FindFirstChild("Perk")
		local perk_name = value and value.Value or ""
		show_item_details(nil, nil, {
			name = perk_name == "" and "None" or perk_name,
			desc = perk_name == "" and "No perk selected." or "Selected combat perk.",
			lore = "",
		})
	end
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

	-- Every visible inventory card previews its master item record on hover,
	-- matching the original menu (weapons, tools, class kit and perk alike).
	for _, row_name in {
		"Primary Sling",
		"Secondary Holster",
		"Melee Sheath",
		"Mining Pick Belt",
		"First Aid Pouch",
		"Combat Experience",
		"Equipment Strap",
		"Perk Slot",
	} do
		local row = options_frame:FindFirstChild(row_name)
		if row and row:IsA("GuiObject") then
			table.insert(ui_connections, row.MouseEnter:Connect(function()
				preview_inventory_row(row_name)
			end))
			if row:IsA("GuiButton") then
				table.insert(ui_connections, row.SelectionGained:Connect(function()
					preview_inventory_row(row_name)
				end))
			end
		end
	end

	-- // Master-script detail panel controls
	local stats_side = loadout_ui:FindFirstChild("Statistics") or loadout_ui:FindFirstChild("statsside")
	if stats_side then
		local stats_range = stats_side:FindFirstChild("statsrange")
		local next_page = stats_range and stats_range:FindFirstChild("nextpage")
		if next_page and next_page:IsA("GuiButton") then
			table.insert(ui_connections, next_page.Activated:Connect(function()
				local range_page = stats_range:FindFirstChild("rangestats")
				local handling_page = stats_range:FindFirstChild("handlingstats")
				local show_handling = range_page and range_page.Visible == true
				if range_page and range_page:IsA("GuiObject") then range_page.Visible = not show_handling end
				if handling_page and handling_page:IsA("GuiObject") then handling_page.Visible = show_handling end
				set_text(stats_range, "toptext", show_handling and "Weapon Performance Info" or "Damage Range Info")
			end))
		end

		local assists = stats_side:FindFirstChild("stats_assist")
		local assist_hover = stats_side:FindFirstChild("assist_hover")
		if assists and assists:IsA("GuiObject") and assist_hover and assist_hover:IsA("GuiButton") then
			table.insert(ui_connections, assist_hover.Activated:Connect(function()
				assists.Visible = not assists.Visible
			end))
		end

		local lore = stats_side:FindFirstChild("perklore_lower")
		local stats_lower = stats_side:FindFirstChild("statslower")
		local view_lore = stats_side:FindFirstChild("viewlore")
		if lore and lore:IsA("GuiObject") and view_lore and view_lore:IsA("GuiButton") then
			table.insert(ui_connections, view_lore.Activated:Connect(function()
				lore.Visible = not lore.Visible
				if stats_lower and stats_lower:IsA("GuiObject") then stats_lower.Visible = not lore.Visible end
				if stats_range and stats_range:IsA("GuiObject") then stats_range.Visible = not lore.Visible end
				if view_lore:IsA("TextButton") then
					view_lore.Text = lore.Visible and "Show Stats & Details" or "Show History & Lore"
				end
			end))
		end
	end

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
		local function preview_selected()
			local equipment_value = equipment:FindFirstChild(slot)
			local selected_name = equipment_value and equipment_value.Value or ""
			local definition = Classes.Get(Classes.Selected(local_player))
			if slot == "Primary" and definition.FixedPrimary then
				selected_name = definition.FixedPrimary
			elseif definition.NoFirearms then
				selected_name = ""
			end
			local selected_source = gun_classes:FindFirstChild(selected_name)
				or tool_classes:FindFirstChild(selected_name)
			if selected_source and selected_source:IsA("ModuleScript") then
				local ok, selected_module = pcall(require, selected_source)
				if ok then show_weapon_details(selected_module, selected_name) end
			end
		end

		table.insert(
			ui_connections,
			button.Activated:Connect(
				function()
					preview_selected()
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
	table.clear(defaultRows)

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
