-------------
-- @Praxitos
-- Handles the Menu system
-------------

local module = {}

-- // Services
local input_service = game:GetService("UserInputService")
local camera_service = require(script.Parent.CameraService)
local player_service = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

-- // Variables
local menu_camera_module = require(script.Parent.CameraService.MenuCamera)
local menu_button = Enum.KeyCode.M
local menu_boolean = false

local local_player = player_service.LocalPlayer
local menu_ui: ScreenGui? = nil
local scenes_folder: Instance? = nil
local main_menu: GuiObject? = nil
local current_ui: ScreenGui? = nil
local button_connections = {}

local firstclick = false
-- // Functions

local function set_ui()
	if menu_ui and menu_ui.Parent then
		menu_ui.Enabled = menu_boolean
	end

	local_player:SetAttribute("MenuOpen", menu_boolean)
end


local function color_all_grey()
	if not main_menu then
		return
	end

	for _, child in pairs(main_menu:GetChildren()) do
		if not child:IsA("ImageButton") then
			continue
		end

		child.ImageColor3 = Color3.new(0, 0, 0)
	end
end


local function disable_all_scenes_ui()
	if not scenes_folder then
		return
	end

	for _, child in pairs(scenes_folder:GetChildren()) do
		if not child:IsA("ScreenGui") then
			continue
		end

		child.Enabled = false
	end
end


local function set_scene(scene, btn)
	if not scenes_folder or not scenes_folder.Parent then
		return
	end

	local scene = scenes_folder:FindFirstChild(scene)

	if not scene or not scene:IsA("ScreenGui") then
		warn("[MENUSERVICE] Missing menu scene:", scene)
		return
	end

	-- Switch menu camera scene.
	menu_camera_module:Switch(scene)

	-- Reset all buttons.
	color_all_grey()

	-- Close every other scene.
	disable_all_scenes_ui()

	-- Open selected scene.
	scene.Enabled = true
	current_ui = scene
end
local function bind_menu_buttons()
	-- Disconnect connections belonging to the previous UI tree.
	for _, connection in ipairs(button_connections) do
		connection:Disconnect()
	end

	button_connections = {}

	if not main_menu or not scenes_folder then
		return
	end

	for _, button: ImageButton in pairs(main_menu:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		table.insert(button_connections, button.Activated:Connect(function()
			set_scene(button.Name)
			-- Highlight selected button.
			button.ImageColor3 = Color3.new(1, 1, 1)
		end))
	end
end


-- PlayerGui contents may be recreated during respawn.
-- Always resolve the current UI tree before interacting with it.
local function refresh_ui(wait_for_ui: boolean): boolean
	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")

	if not player_gui then
		return false
	end

	local new_menu = player_gui:FindFirstChild("Menu")
	local new_scenes = player_gui:FindFirstChild("Menu_Scenes")

	if wait_for_ui then
		new_menu = new_menu or player_gui:WaitForChild("Menu", 10)
		new_scenes = new_scenes or player_gui:WaitForChild("Menu_Scenes", 10)
	end

	-- Fallback in case Roblox has reset PlayerGui but the replacement
	-- instances have not replicated yet.
	if not new_menu or not new_scenes then
		local shared = replicated_storage:FindFirstChild("Shared")

		local library = shared and shared:FindFirstChild("Library")
		local ui = library and library:FindFirstChild("UI")

		if ui then
			if not new_menu then
				local source = ui:FindFirstChild("Menu")

				if source then
					new_menu = source:Clone()
					new_menu.Parent = player_gui
				end
			end

			if not new_scenes then
				local source = ui:FindFirstChild("Menu_Scenes")

				if source then
					new_scenes = source:Clone()
					new_scenes.Parent = player_gui
				end
			end
		end
	end

	if not (new_menu and new_menu:IsA("ScreenGui") and new_scenes) then
		return false
	end

	-- Detect when Roblox has given us a new UI tree.
	if menu_ui ~= new_menu or scenes_folder ~= new_scenes then
		-- Disconnect old button connections before replacing references.
		for _, connection in ipairs(button_connections) do
			connection:Disconnect()
		end

		button_connections = {}

		menu_ui = new_menu
		scenes_folder = new_scenes

		main_menu = menu_ui:FindFirstChild("Main_Frame")

		-- Do NOT inherit the old scene.
		current_ui = nil

		-- Bind buttons to the new UI instances.
		bind_menu_buttons()
	end

	return main_menu ~= nil
end


-- Completely reset the menu using the current PlayerGui instances.
local function reset_menu_ui()
	-- Immediately close the logical menu state.
	menu_boolean = false
	current_ui = nil

	local_player:SetAttribute("MenuOpen", false)

	-- Wait until the replacement UI actually exists.
	if not refresh_ui(true) then
		warn("[MENUSERVICE] Failed to refresh menu UI during reset")
		return
	end

	-- Make sure no scene survived the respawn.
	disable_all_scenes_ui()

	-- Reset all button colors.
	color_all_grey()

	-- Rebind against the current UI tree.
	bind_menu_buttons()

	-- Ensure the menu itself is disabled.
	set_ui()
end


-- Handle the outgoing character.
local function handle_character_removing()
	-- Kill the menu camera immediately.
	camera_service.EndCameraByName("MenuCamera", true)

	-- Reset local menu state immediately.
	menu_boolean = false
	current_ui = nil

	-- Disable the currently-existing UI.
	if menu_ui and menu_ui.Parent then
		menu_ui.Enabled = false
	end

	if scenes_folder and scenes_folder.Parent then
		disable_all_scenes_ui()
	end

	if main_menu and main_menu.Parent then
		color_all_grey()
	end

	local_player:SetAttribute("MenuOpen", false)
end


-- Handle the new character.
local function handle_character_added()
	-- PlayerGui may not have finished resetting at the exact moment
	-- CharacterAdded fires, so wait for the replacement UI.
	task.spawn(function()
		local player_gui = local_player:WaitForChild("PlayerGui", 10)

		if not player_gui then
			warn("[MENUSERVICE] PlayerGui missing after respawn")
			return
		end

		-- Explicitly wait for the new menu hierarchy.
		local new_menu = player_gui:WaitForChild("Menu", 10)
		local new_scenes = player_gui:WaitForChild("Menu_Scenes", 10)

		if not new_menu or not new_scenes then
			warn("[MENUSERVICE] Menu UI missing after respawn")
			return
		end

		-- Reset after Roblox has recreated the UI.
		reset_menu_ui()
	end)
end


local function start_sub_modules()
	print("[MENUSERVICE] Starting sub modules")

	for _, child in ipairs(script:GetChildren()) do
		print("[MENUSERVICE] Checking:", child.Name, "is ModuleScript")

		if not child:IsA("ModuleScript") then
			continue
		end

		print("[MENUSERVICE] Requiring:", child.Name)

		task.spawn(function()
			local success, child_module = pcall(require, child)

			if not success then
				warn("[MENUSERVICE] Failed to require", child.Name, child_module)
				return
			end

			if typeof(child_module.start_module) == "function" then
				local ok, err = pcall(child_module.start_module)

				if ok then
					print("[MENUSERVICE] Started:", child.Name)
				else
					warn("[MENUSERVICE] Error starting", child.Name, err)
				end
			else
				warn(
					"[MENUSERVICE]",
					child.Name,
					"has no start_module function"
				)
			end
		end)
	end
end


-- // Start
function module.start_module()
	-- Initial UI setup.
	if not refresh_ui(true) then
		warn("[MENUSERVICE] Menu UI was not available during startup")
	end

	menu_boolean = false
	current_ui = nil

	-- Ensure the initial state is clean.
	disable_all_scenes_ui()
	set_ui()

	-- Start child menu modules.
	start_sub_modules()
	-- Character lifecycle.
	local_player.CharacterRemoving:Connect(handle_character_removing)
	local_player.CharacterAdded:Connect(handle_character_added)
	-- Menu input.
	input_service.InputBegan:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode ~= menu_button then
			return
		end
		

		-- Always resolve the current UI before opening/closing.
		if not refresh_ui(false) then
			warn("[MENUSERVICE] Menu UI is unavailable; cannot open menu")
			return
		end

		if menu_boolean then
			-- CLOSE MENU
			menu_boolean = false

			camera_service.EndCameraByName("MenuCamera", true)

			disable_all_scenes_ui()
		else
			-- OPEN MENU
			menu_boolean = true
			
			if not firstclick then
				set_scene("Loadout")
				firstclick = true
				
				local_player.PlayerGui.Menu.Main_Frame.Loadout.ImageColor3 = Color3.fromRGB(255, 255, 255)
			end
			
			camera_service.SwitchCamera("MenuCamera", true)

			if current_ui and current_ui.Parent then
				current_ui.Enabled = true
			end
		end

		set_ui()
	end)
end


return module