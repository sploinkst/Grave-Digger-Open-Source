-- Bind authored GUI objects. Only existing row templates may be cloned.
local UI = {}
function UI.Find(root, path)
    local item=root
    for name in path:gmatch("[^/]+") do item=item and item:FindFirstChild(name) end
    return item
end
function UI.Text(root,path,text)
    local label=UI.Find(root,path)
    if label and (label:IsA("TextLabel") or label:IsA("TextButton") or label:IsA("TextBox")) then label.Text=tostring(text or "") end
end
function UI.Bind(scope,root,path,callback)
    local button=UI.Find(root,path)
    if button and button:IsA("GuiButton") then return scope:Connect(button.Activated,callback) end
end
function UI.Selected(button,selected)
    if not button then return end
    if button:IsA("ImageButton") then button.ImageColor3=selected and Color3.new(1,1,1) or Color3.new(0,0,0) end
    local inner=button:FindFirstChild("inner")
    if inner and inner:IsA("TextLabel") then inner.TextColor3=selected and Color3.new(0,0,0) or Color3.new(1,1,1) end
end
function UI.Clone(template,parent,scope,name)
    if not template or not template:IsA("GuiObject") then return nil end
    local row=scope:Own(template:Clone());row.Name=name or "MenuRow";row.Visible=true;row.Parent=parent
    row:SetAttribute("MenuGeneratedRow",true)
    return row
end
function UI.Mount(sceneName, mount)
    local Players = game:GetService("Players")
    local Scope = require(script.Parent.Scope)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local current, scope
    local function refresh()
        local scenes = playerGui:FindFirstChild("Menu_Scenes")
        local scene = scenes and scenes:FindFirstChild(sceneName)
        if scene == current then return end
        if scope then scope:Destroy() end
        current, scope = scene, nil
        if scene then
            scope = Scope.new()
            local ok, err = xpcall(function() mount(scene, scope) end, debug.traceback)
            if not ok then scope:Destroy(); warn("[Menu/" .. sceneName .. "] " .. err) end
        end
    end
    local queued = false
    local function queue()
        if queued then return end
        queued = true
        task.defer(function() queued = false; refresh() end)
    end
    local added = playerGui.DescendantAdded:Connect(queue)
    local removed = playerGui.DescendantRemoving:Connect(queue)
    refresh()
    return function()
        added:Disconnect(); removed:Disconnect()
        if scope then scope:Destroy() end
    end
end
return UI
