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
local hidden_chat_ui: ScreenGui? = nil
local chat_enabled_before_menu: boolean? = nil

local firstclick = false
local started = false
module.SceneChanged = Instance.new("BindableEvent")
-- // Functions

local function set_chat_hidden(hidden: boolean)
	local player_gui = local_player:FindFirstChildOfClass("PlayerGui")
	local chat_ui = player_gui and player_gui:FindFirstChild("Chat")
	if not chat_ui or not chat_ui:IsA("ScreenGui") then
		if not hidden then
			hidden_chat_ui = nil
			chat_enabled_before_menu = nil
		end
		return
	end

	if hidden then
		if hidden_chat_ui ~= chat_ui then
			hidden_chat_ui = chat_ui
			chat_enabled_before_menu = chat_ui.Enabled
		end

		local focused = input_service:GetFocusedTextBox()
		if focused and focused:IsDescendantOf(chat_ui) then
			focused:ReleaseFocus(false)
		end
		chat_ui.Enabled = false
	elseif hidden_chat_ui == chat_ui then
		chat_ui.Enabled = if chat_enabled_before_menu == nil then true else chat_enabled_before_menu
		hidden_chat_ui = nil
		chat_enabled_before_menu = nil
	end
end

local function set_button_selected(button: GuiButton, selected: boolean)
	local color = selected and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
	if button:IsA("ImageButton") then
		button.ImageColor3 = color
	elseif button:IsA("TextButton") then
		button.TextColor3 = color
	end
end

local function set_ui()
	if menu_ui and menu_ui.Parent then
		menu_ui.Enabled = menu_boolean
	end

	local_player:SetAttribute("MenuOpen", menu_boolean)
	_G.in_menu = menu_boolean
	set_chat_hidden(menu_boolean)
end


local function color_all_grey()
	if not main_menu then
		return
	end

	for _, child in pairs(main_menu:GetChildren()) do
		if not child:IsA("GuiButton") then
			continue
		end

		set_button_selected(child, false)
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

	local scene_name = scene
	local scene_ui = scenes_folder:FindFirstChild(scene_name)

	if not scene_ui or not scene_ui:IsA("ScreenGui") then
		warn("[MENUSERVICE] Missing menu scene:", scene_name)
		return
	end

	-- Switch menu camera scene.
	menu_camera_module:Switch(scene_name)

	-- Reset all buttons.
	color_all_grey()

	-- Close every other scene.
	disable_all_scenes_ui()

	-- Open selected scene.
	scene_ui.Enabled = true
	current_ui = scene_ui
	module.SceneChanged:Fire(scene_name)
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

	for _, button in pairs(main_menu:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		table.insert(button_connections, button.Activated:Connect(function()
			if button.Name == "Back" or button.Name == "Close" or button.Name == "backout" then module.Close(); return end
			module.Navigate(button.Name)
			-- Highlight selected button.
			set_button_selected(button, true)
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
	firstclick = false

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
	firstclick = false

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
	-- MenuService remains the owner of the menu.  Children only bind behaviour to
	-- GUI objects which are already present in Library/UI or StarterGui/main.
	for _, name in {"LoadoutHandler", "SettingsHandler", "PresentationHandler", "CreditsHandler"} do
        local child = script:FindFirstChild(name)
        if child then
            task.spawn(function()
				local ok, err = xpcall(function() require(child).start_module(module) end, debug.traceback)
                if not ok then warn("[MenuService/" .. name .. "] " .. err) end
            end)
        end
    end
end

function module.IsOpen() return menu_boolean end
function module.Navigate(sceneName)
    if not refresh_ui(false) then return false end
    local scene = scenes_folder:FindFirstChild(sceneName)
    if not scene or not scene:IsA("ScreenGui") then return false end
    set_scene(sceneName)
    local button = main_menu and main_menu:FindFirstChild(sceneName)
    if button and button:IsA("GuiButton") then set_button_selected(button,true) end
    return true
end
function module.Close()
    if not menu_boolean then return end
    menu_boolean=false
    camera_service.EndCameraByName("MenuCamera",true)
    disable_all_scenes_ui()
    pcall(function() game:GetService("GamepadService"):DisableGamepadCursor() end)
    set_ui()
end
function module.Open(sceneName)
    if local_player:GetAttribute("MenuLocked") or local_player:GetAttribute("RebindingInput") then return end
    if not refresh_ui(false) then return end
    if not menu_boolean then camera_service.SwitchCamera("MenuCamera",true) end
    menu_boolean=true
    module.Navigate(sceneName or (current_ui and current_ui.Name) or "Loadout")
    input_service.MouseBehavior=Enum.MouseBehavior.Default
    input_service.MouseIconEnabled=true
    if input_service:GetLastInputType().Name:find("Gamepad") then
        pcall(function() game:GetService("GamepadService"):EnableGamepadCursor(current_ui) end)
    end
    set_ui()
end
function module.Toggle()
    if menu_boolean then module.Close() else module.Open() end
end


-- // Start
function module.start_module()
    if started then return end
    started=true
    local_player:SetAttribute("ModernMenuActive",true)
    if not refresh_ui(true) then warn("[MenuService] Waiting for the current menu UI") end
    menu_boolean=false;current_ui=nil
    disable_all_scenes_ui();set_ui()
    start_sub_modules()
    local_player.CharacterRemoving:Connect(handle_character_removing)
    local_player.CharacterAdded:Connect(handle_character_added)
    local playerGui=local_player:WaitForChild("PlayerGui")
    playerGui.ChildAdded:Connect(function(child)
		if child.Name=="Menu" or child.Name=="Menu_Scenes" or child.Name=="Chat" then
			task.defer(function() refresh_ui(false);set_ui() end)
		end
    end)
    input_service.InputBegan:Connect(function(input,processed)
        if processed or input_service:GetFocusedTextBox() or local_player:GetAttribute("RebindingInput") then return end
        local root=local_player:FindFirstChild("PlayerData")
        local settings=root and root:FindFirstChild("Settings Data")
        local inputs=settings and settings:FindFirstChild("Inputs")
        local binds=inputs and inputs:FindFirstChild("Binds")
        local bind=binds and binds:FindFirstChild("Menu")
        local current=bind and bind:FindFirstChild("Current")
        local key=current and Enum.KeyCode[current.Value] or menu_button
        if current and current.Value=="None" then key=nil end
        if input.KeyCode==key or input.KeyCode==Enum.KeyCode.ButtonSelect then module.Toggle() end
        if input.KeyCode==Enum.KeyCode.Escape and menu_boolean then module.Close() end
    end)
end

return module
