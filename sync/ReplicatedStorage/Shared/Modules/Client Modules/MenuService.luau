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

-- // functions
local function set_ui()
	if menu_ui and menu_ui.Parent then
		menu_ui.Enabled = menu_boolean
	end
	local_player:SetAttribute("MenuOpen", menu_boolean)
end

local function color_all_grey()
	if not main_menu then return end
	for _, child in pairs(main_menu:GetChildren()) do
		if not child:IsA("ImageButton") then continue end

		child.ImageColor3 = Color3.new(0,0,0)
	end
end

local function disable_all_scenes_ui()
	if not scenes_folder then return end
	for _, child in pairs(scenes_folder:GetChildren()) do
		if not child:IsA("ScreenGui") then continue end

		child.Enabled = false
	end
end

local function bind_menu_buttons()
	for _, connection in ipairs(button_connections) do
		connection:Disconnect()
	end
	button_connections = {}

	if not main_menu or not scenes_folder then return end
	for _, button: ImageButton in pairs(main_menu:GetChildren()) do
		if not button:IsA("ImageButton") then continue end

		table.insert(button_connections, button.Activated:Connect(function()
			if not scenes_folder or not scenes_folder.Parent then return end
			local scene = scenes_folder:FindFirstChild(button.Name)
			if not scene or not scene:IsA("ScreenGui") then
				warn("[MENUSERVICE] Missing menu scene:", button.Name)
				return
			end

			menu_camera_module:Switch(button.Name)
			color_all_grey()
			button.ImageColor3 = Color3.new(255,255,255)
			disable_all_scenes_ui()
			scene.Enabled = true
			current_ui = scene
		end))
	end
end

-- PlayerGui contents may be recreated during respawn. Do not retain stale GUI
-- references: resolve the current trees before every menu interaction.
local function refresh_ui(wait_for_ui: boolean): boolean
	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")
	if not player_gui then return false end

	local new_menu = player_gui:FindFirstChild("Menu")
	local new_scenes = player_gui:FindFirstChild("Menu_Scenes")
	if wait_for_ui then
		new_menu = new_menu or player_gui:WaitForChild("Menu", 10)
		new_scenes = new_scenes or player_gui:WaitForChild("Menu_Scenes", 10)
	end
	-- Server-side restoration is authoritative. This local fallback covers the
	-- short Roblox respawn window where PlayerGui has already been reset but the
	-- replacement has not replicated yet, so the M key never becomes a dead key.
	if not new_menu or not new_scenes then
		local ui = replicated_storage:FindFirstChild("Shared")
			and replicated_storage.Shared:FindFirstChild("Library")
			and replicated_storage.Shared.Library:FindFirstChild("UI")
		if ui then
			if not new_menu then
				local source = ui:FindFirstChild("Menu")
				if source then new_menu = source:Clone(); new_menu.Parent = player_gui end
			end
			if not new_scenes then
				local source = ui:FindFirstChild("Menu_Scenes")
				if source then new_scenes = source:Clone(); new_scenes.Parent = player_gui end
			end
		end
	end

	if not (new_menu and new_menu:IsA("ScreenGui") and new_scenes) then
		return false
	end

	if menu_ui ~= new_menu or scenes_folder ~= new_scenes then
		menu_ui = new_menu
		scenes_folder = new_scenes
		main_menu = menu_ui:FindFirstChild("Main_Frame")
		current_ui = scenes_folder:FindFirstChild("Loadout") :: ScreenGui?
		bind_menu_buttons()
	end

	return main_menu ~= nil
end

-- Reset the authored menu state without replacing its instances. Menu
-- submodules cache controls and event connections, so preserving the tree is
-- what keeps every button usable after a character respawn.
local function reset_menu_ui()
	if not refresh_ui(true) then return end
	menu_boolean = false
	current_ui = nil
	if scenes_folder then
		local loadout = scenes_folder:FindFirstChild("Loadout")
		if loadout and loadout:IsA("ScreenGui") then current_ui = loadout end
	end
	disable_all_scenes_ui()
	color_all_grey()
	bind_menu_buttons()
	set_ui()
end

local function start_sub_modules()
	print("[MENUSERVICE] Starting sub modules")

	for _, child in ipairs(script:GetChildren()) do
		print("[MENUSERVICE] Checking:", child.Name, "is ModuleScript")
		if not child:IsA("ModuleScript") then
			continue
		end

		print("[MENUSERVE] Requiring:", child.Name)
		
		task.spawn(function()
			local success, module = pcall(require, child)
			if not success then
				warn("[MENUSERVICE] Failed to require", child.Name, module)
				return
			end
			
			if typeof(module.start_module) == "function" then
				local ok, err = pcall(module.start_module)
				if ok then
					print("[MENUSERVICE] Started:", child.Name)
				else
					warn("[MENUSERVICE] Error starting", child.Name, err)
				end
			else
				warn("[MENUSERVICE]", child.Name, "has no start_module function")
			end
		end)
	end
end

function module.start_module()
	if not refresh_ui(true) then
		warn("[MENUSERVICE] Menu UI was not available during startup")
	end
	local_player:SetAttribute("MenuOpen", false)
	start_sub_modules()
	local_player.CharacterRemoving:Connect(function()
		-- A menu camera references the outgoing character/scene. Always close it
		-- before respawn so the next M press starts from a clean state.
		camera_service.EndCameraByName("MenuCamera", true)
		reset_menu_ui()
	end)

	local_player.CharacterAdded:Connect(function()
		-- Rebind after Roblox has finished its PlayerGui reset cycle. This also
		-- restores every scene to a closed, clean state before the menu is used.
		task.defer(reset_menu_ui)
	end)

	input_service.InputBegan:Connect(function(input, gps)
		if gps then return end

		if input.KeyCode == menu_button then
			if not refresh_ui(false) then
				warn("[MENUSERVICE] Menu UI is unavailable; cannot open menu")
				return
			end
			if menu_boolean then
				menu_boolean = false
				camera_service.EndCameraByName("MenuCamera", true)
				disable_all_scenes_ui()
			else
				menu_boolean = true
				camera_service.SwitchCamera("MenuCamera", true)

				if current_ui then
					current_ui.Enabled = true
				end
			end

			set_ui()
		end
	end)
end

return module
