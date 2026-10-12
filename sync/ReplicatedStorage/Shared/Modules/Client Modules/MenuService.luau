-- Owns the authored menu scenes and their lifetime. Panel modules bind data only.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local CameraService = require(script.Parent.CameraService)
local MenuCamera = require(script.Parent.CameraService.MenuCamera)
local Scope = require(script.Scope)
local UI = require(script.UI)
local Layout = require(RS.Shared.Library.MenuLayout)
local Assets = require(RS.Shared.Library.AuthoredAssets)
local native = false
local Menu = {SceneChanged = Instance.new("BindableEvent")}
local player = Players.LocalPlayer
local started, opened, currentScene = false, false, "Loadout"
local shell, scenes, navigation, bindingScope
local chat, chatEnabled
local names = {Loadout=true, Appearance=true, Servers=true, Settings=true, Credits=true}

local function screenState(root, enabled)
    if root and root:IsA("ScreenGui") then root.Enabled = enabled
    elseif root and root:IsA("GuiObject") then root.Visible = enabled end
end
local function render()
    screenState(shell, opened)
    if native then
        for name in pairs(names) do
            screenState(Layout.Panel(name), opened and name == currentScene)
        end
        local core = Assets.CoreGame()
        if core then core.Enabled = not opened and player:GetAttribute("HudHidden") ~= true end
    end
    for _, scene in scenes and scenes:GetChildren() or {} do
        screenState(scene, opened and scene.Name == currentScene)
    end
    for _, button in navigation and navigation:GetDescendants() or {} do
        local sceneName = Layout.Buttons[button.Name]
        if button:IsA("GuiButton") and sceneName then UI.Selected(button, opened and sceneName == currentScene) end
    end
    local extras=Assets.CoreGame()
    if extras then extras.Enabled=not opened and player:GetAttribute("HudHidden")~=true end
    player:SetAttribute("MenuOpen", opened)
    _G.in_menu = opened
end
local function cloneSource(name, gui)
    local source = RS.Shared.Library.UI:FindFirstChild(name)
    if not source then warn("[Menu] Missing authored UI: " .. name); return nil end
    local clone = source:Clone()
    for _, child in clone:GetDescendants() do
        if child:IsA("LocalScript") then child.Enabled = false end
        if child:IsA("ScreenGui") then child.ResetOnSpawn = false; child.Enabled = false end
    end
    if clone:IsA("ScreenGui") then clone.ResetOnSpawn = false; clone.Enabled = false end
    clone.Parent = gui
    return clone
end
local function refresh()
    local gui = player:FindFirstChildOfClass("PlayerGui")
    if not gui then return false end
    local nativeShell = Layout.Container()
    native = nativeShell ~= nil
    local nextShell = nativeShell or gui:FindFirstChild("Menu") or cloneSource("Menu", gui)
    local nextScenes = not native and (gui:FindFirstChild("Menu_Scenes") or cloneSource("Menu_Scenes", gui)) or nil
    if not nextShell or (not native and not nextScenes) then return false end
    if native then
        screenState(gui:FindFirstChild("Menu"), false)
        local oldScenes = gui:FindFirstChild("Menu_Scenes")
        if oldScenes then for _, child in oldScenes:GetChildren() do screenState(child, false) end end
    end
    if nextShell == shell and nextScenes == scenes then render(); return true end
    if bindingScope then bindingScope:Destroy() end
    bindingScope = Scope.new()
    shell, scenes = nextShell, nextScenes
    local main = require(RS.Shared.Library.AuthoredAssets).MainGui()
    local legacyMenu = main and main:FindFirstChild("loadout_menu")
    if not native and legacyMenu and legacyMenu:IsA("GuiObject") then legacyMenu.Visible = false end
    if shell:IsA("ScreenGui") then shell.ResetOnSpawn = false end
    navigation = shell:FindFirstChild("menubuttons") or shell:FindFirstChild("Main_Menu", true) or shell:FindFirstChild("mainmenu", true) or shell
    for _, object in shell:GetDescendants() do
        if object:IsA("LocalScript") then object.Enabled = false end
        if object:IsA("GuiButton") then
            if Layout.Buttons[object.Name] and object:IsDescendantOf(navigation) then bindingScope:Connect(object.Activated, function() Menu.Navigate(Layout.Buttons[object.Name]) end)
            elseif table.find({"Back", "Close", "backout"}, object.Name) then bindingScope:Connect(object.Activated, Menu.Close) end
        end
    end
    for _, scene in scenes and scenes:GetChildren() or {} do
        if scene:IsA("ScreenGui") then
            scene.ResetOnSpawn = false
            for _, object in scene:GetDescendants() do
                if object:IsA("LocalScript") then object.Enabled = false end
                if object:IsA("GuiButton") and table.find({"Back", "Close", "backout"}, object.Name) then bindingScope:Connect(object.Activated, Menu.Close) end
            end
        end
    end
    render()
    return true
end
function Menu.IsOpen() return opened end
function Menu.GetScene(name) return native and Layout.Panel(name) or (scenes and scenes:FindFirstChild(name)) end
function Menu.Close()
    if not opened then render(); return end
    opened = false
    CameraService.EndCameraByName("MenuCamera", true)
    pcall(function() game:GetService("GamepadService"):DisableGamepadCursor() end)
    render()
    Menu.SceneChanged:Fire(nil)
end
function Menu.Open(name)
    if player:GetAttribute("MenuLocked") or player:GetAttribute("RebindingInput") then return false end
    if not refresh() then return false end
    name = name or currentScene
    local scene = Menu.GetScene(name)
    if not names[name] or not scene or not (scene:IsA("ScreenGui") or scene:IsA("GuiObject")) then return false end
    local wasOpen = opened
    currentScene, opened = name, true
    if not wasOpen then CameraService.SwitchCamera("MenuCamera", true) end
    MenuCamera:Switch(name)
    render()
    Input.MouseBehavior = Enum.MouseBehavior.Default
    Input.MouseIconEnabled = true
    if Input:GetLastInputType().Name:find("Gamepad") then
        pcall(function() game:GetService("GamepadService"):EnableGamepadCursor(scene) end)
    end
    Menu.SceneChanged:Fire(name)
    return true
end
function Menu.Navigate(name) return Menu.Open(name) end
function Menu.Toggle() if opened then Menu.Close() else Menu.Open() end end
function Menu.PlayTutorial() return require(script.TutorialHandler).Play(Menu) end
function Menu.start_module()
    if started then return end
    started = true
    player:SetAttribute("ModernMenuActive", true)
    local gui = player:WaitForChild("PlayerGui")
    refresh()
    local queued = false
    local function queue()
        if queued then return end
        queued = true
        task.defer(function() queued = false; refresh() end)
    end
    gui.ChildAdded:Connect(queue)
    gui.ChildRemoved:Connect(queue)
    player.CharacterRemoving:Connect(Menu.Close)
    player.CharacterAdded:Connect(function() task.defer(refresh) end)
    Input.InputBegan:Connect(function(input, processed)
        if processed or Input:GetFocusedTextBox() or player:GetAttribute("RebindingInput") then return end
        local data = player:FindFirstChild("PlayerData")
        local settings = data and data:FindFirstChild("Settings Data")
        local binds = settings and settings:FindFirstChild("Inputs") and settings.Inputs:FindFirstChild("Binds")
        local value = binds and binds:FindFirstChild("Menu") and binds.Menu:FindFirstChild("Current")
        local key = value and value.Value or "M"
        if input.KeyCode.Name == key or input.KeyCode == Enum.KeyCode.ButtonSelect then Menu.Toggle()
        elseif input.KeyCode == Enum.KeyCode.Escape then Menu.Close() end
    end)
    for _, name in {"HoverAudioHandler", "LoadoutHandler", "AppearanceHandler", "SettingsHandler", "ServersHandler", "CreditsHandler", "PresentationHandler"} do
        local handler = script:FindFirstChild(name)
        if handler then task.spawn(function()
            local ok, err = xpcall(function() require(handler).start_module(Menu) end, debug.traceback)
            if not ok then warn("[Menu/" .. name .. "] " .. err) end
        end) end
    end
end
return Menu
