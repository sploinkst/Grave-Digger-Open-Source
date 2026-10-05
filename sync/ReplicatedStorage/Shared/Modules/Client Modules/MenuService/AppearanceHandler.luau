local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Appearance = require(Shared.Library.CosmeticAppearance)
local ClassAppearance = require(Shared.Library.ClassAppearance)
local Classes = require(Shared.Library.ClassDefinitions)
local Scope = require(script.Parent.Scope)
local player = Players.LocalPlayer
local module = {}
local started, active = false, false
local owner, frame, list, template, panelScope, rowScope, preview
local category = "haircolour"
local rotation = 0
local previewClass, previewTeam
local hiddenRig = {}
local queued = false

local function text(object, value)
    if object and (object:IsA("TextLabel") or object:IsA("TextButton")) then object.Text = value end
end

local function clearPreview()
    if preview then preview:Destroy(); preview = nil end
    for part, transparency in hiddenRig do
        if part.Parent then part.Transparency = transparency end
    end
    table.clear(hiddenRig)
end

local function visible()
    if not frame or not frame.Parent or not frame.Visible then return false end
    local ancestor = frame.Parent
    while ancestor and ancestor ~= player.PlayerGui do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
        if ancestor:IsA("ScreenGui") and not ancestor.Enabled then return false end
        ancestor = ancestor.Parent
    end
    return true
end

local function refreshPreview()
    clearPreview()
    if not active or not visible() then return end
    local character = player.Character
    local details = workspace:FindFirstChild("Game_Details")
    local scenes = details and details:FindFirstChild("Menus")
    local scene = scenes and scenes:FindFirstChild("Appearance_Scene")
    local rig = scene and scene:FindFirstChild("appearancerig")
    local spot = scene and scene:FindFirstChild("Character_Spot")
    if not character or not scene or not (rig or spot) then return end
    local pivot = spot and spot:IsA("BasePart") and spot.CFrame or rig and rig:IsA("Model") and rig:GetPivot()
    if not pivot then return end
    local archivable = character.Archivable
    character.Archivable = true
    local clone = character:Clone()
    character.Archivable = archivable
    if not clone then return end
    for _, object in clone:GetDescendants() do
        if object:IsA("LuaSourceContainer") or object:IsA("Tool") then object:Destroy() end
    end
    ClassAppearance.Apply(clone, previewTeam or (player.Team and player.Team.Name), previewClass or Classes.Selected(player))
    Appearance.Apply(clone, Appearance.Data(player))
    local root = clone:FindFirstChild("HumanoidRootPart")
    if not root then clone:Destroy(); return end
    root.Anchored = true
    if rig then
        for _, part in rig:GetDescendants() do
            if part:IsA("BasePart") then hiddenRig[part] = part.Transparency; part.Transparency = 1 end
        end
    end
    preview = clone
    preview.Name = "AppearancePreview"
    preview.Parent = scene
    preview:PivotTo(pivot * CFrame.Angles(0, rotation, 0))
end

local function populate()
    if not frame or not frame.Parent or not list or not list.Parent or not template or not template.Parent then return end
    if rowScope then rowScope:Destroy() end
    rowScope = Scope.new()
    local definition = Appearance.Categories[category]
    local choices = definition.Choices and table.clone(definition.Choices) or {}
    if category == "accessories" then
        table.insert(choices, "None")
        local assets = Appearance.Assets()
        if assets then
            local names = {}
            for _, asset in assets:GetChildren() do
                if asset:IsA("Model") or asset:IsA("Accessory") or asset:IsA("BasePart") then table.insert(names, asset.Name) end
            end
            table.sort(names)
            for _, name in names do table.insert(choices, name) end
        end
    end
    local options = frame:FindFirstChild("customisationoptions")
    local button = options and options:FindFirstChild(category)
    local label = button and button:FindFirstChild("textuse")
    text(frame:FindFirstChild("categoryselection"), label and label:IsA("StringValue") and label.Value ~= "" and label.Value or definition.Label)
    local data = Appearance.Data(player)
    for _, option in options:GetChildren() do
        local icon = option:FindFirstChild("iconuse")
        if icon and icon:IsA("ImageLabel") then icon.ImageColor3 = option.Name == category and Color3.new(1,1,1) or Color3.fromRGB(128,128,128) end
    end
    for index, name in choices do
        local saved = data and data:FindFirstChild(definition.Key)
        local selected = false
        if category == "accessories" then
            if name == "None" then
                selected = true
                if saved then for _, value in saved:GetChildren() do if value:IsA("BoolValue") and value.Value then selected = false; break end end end
            else
                local value = saved and saved:FindFirstChild(name)
                selected = value and value:IsA("BoolValue") and value.Value or false
            end
        else
            selected = saved and saved:IsA("StringValue") and saved.Value == name or false
        end
        local row = rowScope:Own(template:Clone())
        row.Name, row.Visible, row.LayoutOrder = "AppearanceChoice_" .. name, true, index
        local display = row:FindFirstChild("display")
        text(display, (definition.Labels and definition.Labels[name]) or name)
        if display and display:IsA("TextLabel") then display.TextColor3 = selected and Color3.new(1,1,1) or Color3.fromRGB(160,160,160) end
        local value = row:FindFirstChild("valuse")
        if value and value:IsA("StringValue") then value.Value = name end
        local swatch = row:FindFirstChild("coloruse")
        local colour = category == "haircolour" and Appearance.HairColours[name] or category == "skincolour" and Appearance.SkinColours[name]
        if swatch and swatch:IsA("GuiObject") then swatch.Visible = colour ~= nil; if colour then swatch.BackgroundColor3 = colour end end
        local locked = row:FindFirstChild("skinlocked")
        if locked and locked:IsA("GuiObject") then locked.Visible = false end
        local previewButton = row:FindFirstChild("preview")
        if previewButton and previewButton:IsA("GuiObject") then previewButton.Visible = category == "accessories" end
        local key = definition.Key
        local function choose() Shared.Library.Events:WaitForChild("Appearance"):FireServer(key, name) end
        if row:IsA("GuiButton") then rowScope:Connect(row.Activated, choose) end
        if previewButton and previewButton:IsA("GuiButton") then
            rowScope:Connect(previewButton.Activated, function()
                refreshPreview()
                if not preview then return end
                local temporary = data and data:Clone()
                if not temporary then return end
                local accessories = temporary:FindFirstChild("Accessories")
                if accessories and name == "None" then
                    for _, value in accessories:GetChildren() do if value:IsA("BoolValue") then value.Value = false end end
                elseif accessories then
                    local item = accessories:FindFirstChild(name) or Instance.new("BoolValue")
                    item.Name, item.Value, item.Parent = name, true, accessories
                end
                Appearance.Apply(preview, temporary)
                temporary:Destroy()
            end)
        end
        row.Parent = list
    end
    refreshPreview()
end

local function scheduleRefresh()
    if queued then return end
    queued = true
    task.defer(function() queued = false; populate() end)
end

local function bind()
    local gui = player:FindFirstChildOfClass("PlayerGui")
    local scenes = gui and gui:FindFirstChild("Menu_Scenes")
    local scene = scenes and scenes:FindFirstChild("Appearance")
    local nextFrame = scene and scene:FindFirstChild("cosmeticsframe")
    if not nextFrame then
        local main = gui and gui:FindFirstChild("main")
        local loadout = main and main:FindFirstChild("loadout_menu")
        nextFrame = loadout and loadout:FindFirstChild("cosmeticsframe")
    end
    if not nextFrame or nextFrame == frame then return end
    local nextList = nextFrame:FindFirstChild("scroll")
    local nextOptions = nextFrame:FindFirstChild("customisationoptions")
    local nextTemplate = nextList and nextList:FindFirstChild("ex")
    if not nextList or not nextOptions or not nextTemplate or not nextTemplate:IsA("GuiButton") then
        warn("[AppearanceHandler] Existing cosmeticsframe requires customisationoptions and scroll.ex")
        return
    end
    if panelScope then panelScope:Destroy() end
    if rowScope then rowScope:Destroy(); rowScope = nil end
    clearPreview()
    panelScope = Scope.new()
    frame, list, template = nextFrame, nextList, nextTemplate
    for _, child in list:GetChildren() do if child:IsA("GuiObject") then child.Visible = false end end
    if list:IsA("ScrollingFrame") then list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.CanvasSize = UDim2.new() end
    for name in Appearance.Categories do
        local button = nextOptions:FindFirstChild(name)
        if button and button:IsA("GuiButton") then
            panelScope:Connect(button.Activated, function() category = name; populate() end)
        end
    end
    for _, entry in {{"rotateleft", -1}, {"rotateright", 1}} do
        local button = frame:FindFirstChild(entry[1])
        if button and button:IsA("GuiButton") then panelScope:Connect(button.Activated, function() rotation += entry[2] * math.pi / 8; refreshPreview() end) end
    end
    for _, entry in {{"empireteam", "Golden Empire"}, {"royalteam", "Royal Nation"}} do
        local button = frame:FindFirstChild(entry[1])
        if button and button:IsA("GuiButton") then
            panelScope:Connect(button.Activated, function() previewTeam = entry[2]; text(frame:FindFirstChild("teampreview"), previewTeam); refreshPreview() end)
        end
    end
    local classes = frame:FindFirstChild("classes")
    if classes then
        for _, className in Classes.Order do
            local button = classes:FindFirstChild(className:lower())
            if button and button:IsA("GuiButton") then
                panelScope:Connect(button.Activated, function() previewClass = className; text(frame:FindFirstChild("classpopup"), className); refreshPreview() end)
            end
        end
    end
    panelScope:Connect(frame:GetPropertyChangedSignal("Visible"), function() active = visible(); if active then populate() else clearPreview() end end)
    local screen = frame:FindFirstAncestorOfClass("ScreenGui")
    if screen then panelScope:Connect(screen:GetPropertyChangedSignal("Enabled"), function() active = visible(); if active then populate() else clearPreview() end end) end
    local parent = frame.Parent
    if parent:IsA("GuiObject") then panelScope:Connect(parent:GetPropertyChangedSignal("Visible"), function() active = visible(); if active then populate() else clearPreview() end end) end
    active = visible()
    populate()
end

function module.start_module(menu)
    if started then return end
    started, owner = true, menu
    local gui = player:WaitForChild("PlayerGui")
    gui.DescendantAdded:Connect(function(object)
        if object.Name == "cosmeticsframe" or object.Name == "customisationoptions" or object.Name == "ex" then task.defer(bind) end
    end)
    owner.SceneChanged.Event:Connect(function(name)
        active = name == "Appearance"
        if active then bind(); populate() else clearPreview() end
    end)
    player:GetAttributeChangedSignal("MenuOpen"):Connect(function() if not owner.IsOpen() then clearPreview() end end)
    player.CharacterRemoving:Connect(clearPreview)
    player.CharacterAdded:Connect(function(character)
        character:GetAttributeChangedSignal("AppearanceReady"):Connect(scheduleRefresh)
        task.defer(bind)
    end)
    local data = Appearance.Data(player)
    if data then
        local function track(value)
            if value:IsA("ValueBase") then value.Changed:Connect(scheduleRefresh) end
        end
        for _, value in data:GetDescendants() do track(value) end
        data.DescendantAdded:Connect(function(value) track(value); scheduleRefresh() end)
        data.DescendantRemoving:Connect(scheduleRefresh)
    end
    bind()
end
return module
