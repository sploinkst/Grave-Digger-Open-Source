-- Own caret visibility independently of camera initialization.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local tracked = setmetatable({}, {__mode = "k"})
local updating = false

local function shouldShow()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then return false end
    if player:GetAttribute("MenuOpen") or player:GetAttribute("FreeLook") or player:GetAttribute("FirstPerson") or UIS:GetFocusedTextBox() then return false end
    if character:GetAttribute("Aiming") or character:GetAttribute("StimulantSelecting") or character:GetAttribute("OfficerOrderSelecting") then return false end
    local action = character:FindFirstChild("action")
    return character:GetAttribute("GunEquipped") == true
        or character:GetAttribute("Action") == true
        or (action and action:IsA("BoolValue") and action.Value) or false
end

local function apply(object)
    if updating or not object.Parent then return end
    updating = true
    if object.Name == "genericcrosshair" then
        object.Visible = false
    else
        object.Size = UDim2.fromOffset(18, 18)
        object.Visible = shouldShow()
        local icon = object:FindFirstChild("icon")
        if icon and icon:IsA("TextLabel") then
            icon.Size = UDim2.fromScale(1, 1)
            icon.TextScaled = false
            icon.TextSize = 16
            icon.Visible = true
        end
    end
    updating = false
end

local function bind(object)
    if tracked[object] or not object:IsA("GuiObject") then return end
    if object.Name ~= "genericcrosshair" and object.Name ~= "Regular_Crosshair" then return end
    tracked[object] = true
    object:GetPropertyChangedSignal("Visible"):Connect(function() apply(object) end)
    object:GetPropertyChangedSignal("Size"):Connect(function() apply(object) end)
    apply(object)
end
for _, object in gui:GetDescendants() do bind(object) end
gui.DescendantAdded:Connect(function(object)
    bind(object)
    if object.Name == "icon" and object.Parent and tracked[object.Parent] then apply(object.Parent) end
end)
RunService:BindToRenderStep("CaretPresentation", Enum.RenderPriority.Last.Value, function()
    for object in tracked do apply(object) end
end)
