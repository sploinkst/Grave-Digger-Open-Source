local l_LocalPlayer_0 = game.Players.LocalPlayer
local v_u_1 = workspace:WaitForChild("remotes", 10)
local v_u_2 = require(game.ReplicatedStorage.shared.bFunctions)
local v_u_3 = require(game.ReplicatedStorage.shared.visualEffects)
local v_u_4 = require(game.ReplicatedStorage.shared.weaponEffects)
local v_u_5 = require(game.ReplicatedStorage.shared.base)
local v_u_6 = require(game.ReplicatedStorage.shared.equipments)
local l_Parent_0 = script.Parent
local s_Debris_0 = game:GetService("Debris")
local s_UserInputService_0 = game:GetService("UserInputService")
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local l_CurrentCamera_0 = workspace.CurrentCamera
local l_values_0 = workspace.serverStuff.values
local v_u_7 = l_LocalPlayer_0:WaitForChild("playerstats", 100)
l_LocalPlayer_0:WaitForChild("data_loaded", 100)
local v_u_8 = {}
for _, v9 in ipairs(game.ReplicatedStorage.weapon_modules:GetChildren()) do
    v_u_8[v9.Name] = require(v9)
end;
local s_GamepadService_0 = game:GetService("GamepadService")
local s_StarterGui_0 = game:GetService("StarterGui")
s_StarterGui_0:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
l_LocalPlayer_0:WaitForChild("PlayerGui", 10):SetTopbarTransparency(0)
local v_u_10 = require(game.ReplicatedStorage.shared.cosmetics)
if l_LocalPlayer_0.PlayerGui:FindFirstChild("Chat") then
    for _, v11 in ipairs(l_LocalPlayer_0.PlayerGui.Chat:FindFirstChild("Frame"):GetChildren()) do
        if v11.Name ~= "ChatBarParentFrame" then
            v11.Visible = false
        end;
    end;
    l_LocalPlayer_0.PlayerGui.Chat.Frame:FindFirstChild("ChatBarParentFrame").Position = UDim2.new(0, 0, 0, 0)
end;
_G.using_controller = false
_G.global_hint = 0
local v12 = {
    ["alt"] = Enum.KeyCode.Q,
    ["reload"] = Enum.KeyCode.R,
    ["flipcam"] = Enum.KeyCode.F,
    ["checkammo"] = Enum.KeyCode.T,
    ["dropweapon"] = Enum.KeyCode.T,
    ["viewobj"] = Enum.KeyCode.X,
    ["voicelines"] = Enum.KeyCode.E,
    ["firstperson"] = Enum.KeyCode.V,
    ["crouch"] = Enum.KeyCode.C,
    ["equipment"] = Enum.KeyCode.G,
    ["swapteam"] = Enum.KeyCode.B,
    ["hidehud"] = Enum.KeyCode.P,
    ["playerlist"] = Enum.KeyCode.Tab,
    ["spectateleft"] = Enum.KeyCode.Q,
    ["spectateright"] = Enum.KeyCode.E,
    ["menu"] = Enum.KeyCode.M,
    ["shiftlock"] = Enum.KeyCode.LeftControl,
    ["cleanface"] = Enum.KeyCode.Z,
    ["reset"] = Enum.KeyCode.Backspace,
    ["vchealing"] = Enum.KeyCode.World52,
    ["vcthanks"] = Enum.KeyCode.World52,
    ["vcdanger"] = Enum.KeyCode.World52,
    ["vchelp"] = Enum.KeyCode.World52,
    ["vcammo"] = Enum.KeyCode.World52,
    ["vcofficerdefend"] = Enum.KeyCode.World52,
    ["vcofficerorder"] = Enum.KeyCode.World52,
    ["vcofficerfollow"] = Enum.KeyCode.World52
}
local v_u_13 = {
    ["alt"] = Enum.KeyCode.ButtonL1,
    ["reload"] = Enum.KeyCode.ButtonX,
    ["flipcam"] = Enum.KeyCode.V,
    ["checkammo"] = Enum.KeyCode.ButtonY,
    ["dropweapon"] = Enum.KeyCode.ButtonY,
    ["viewobj"] = Enum.KeyCode.DPadUp,
    ["voicelines"] = Enum.KeyCode.E,
    ["firstperson"] = Enum.KeyCode.ButtonB,
    ["crouch"] = Enum.KeyCode.ButtonR3,
    ["equipment"] = Enum.KeyCode.ButtonR1,
    ["swapteam"] = Enum.KeyCode.B,
    ["hidehud"] = Enum.KeyCode.P,
    ["playerlist"] = Enum.KeyCode.DPadDown,
    ["spectateleft"] = Enum.KeyCode.DPadLeft,
    ["spectateright"] = Enum.KeyCode.DPadRight,
    ["menu"] = Enum.KeyCode.ButtonSelect,
    ["shiftlock"] = Enum.KeyCode.Z,
    ["cleanface"] = Enum.KeyCode.Z,
    ["reset"] = Enum.KeyCode.Z,
    ["vchealing"] = Enum.KeyCode.World52,
    ["vcthanks"] = Enum.KeyCode.World52,
    ["vcdanger"] = Enum.KeyCode.World52,
    ["vchelp"] = Enum.KeyCode.World52,
    ["vcammo"] = Enum.KeyCode.World52,
    ["vcofficerdefend"] = Enum.KeyCode.World52,
    ["vcofficerorder"] = Enum.KeyCode.World52,
    ["vcofficerfollow"] = Enum.KeyCode.World52
}
local v_u_14 = {}
_G.keysheld = v_u_14
local v_u_15 = CFrame.new(-989.573303, -47.5857697, -269.546356, -0.00920395833, -0.154053047, 0.988019824, -1.16415294e-10, 0.988061666, 0.154059574, -0.999957621, 0.00141795783, -0.00909407903)
local v16 = CFrame.new(-1006.08014, -45.7059174, -270.692413, -0.000193573345, -0.987494469, 0.15765366, -0, 0.15765366, 0.987494469, -1, 0.000191152605, -0.000030517549)
local v_u_17 = tick()
local v18 = {
    ["alt"] = "Alternate Action",
    ["reload"] = "Reload / Extra Action",
    ["flipcam"] = "Flip Camera",
    ["checkammo"] = "Check Ammo / Special Action",
    ["dropweapon"] = "Emergency Reload Drop",
    ["viewobj"] = "View Objectives / Objective Tool",
    ["voicelines"] = "Voice Lines",
    ["firstperson"] = "First Person",
    ["crouch"] = "Crouch",
    ["equipment"] = "Class Equipment",
    ["swapteam"] = "Swap Team / Surrender",
    ["hidehud"] = "Hide Hud",
    ["playerlist"] = "Player List",
    ["spectateleft"] = "Spectate Left",
    ["spectateright"] = "Spectate Right",
    ["menu"] = "Menu",
    ["shiftlock"] = "Shift Lock",
    ["cleanface"] = "Wipe Face",
    ["reset"] = "Reset Character",
    ["vchealing"] = "Voice Command: Request Medic",
    ["vcthanks"] = "Voice Command: Thank You",
    ["vcdanger"] = "Voice Command: Danger There",
    ["vchelp"] = "Voice Command: Need Support",
    ["vcammo"] = "Voice Command: Request Ammo",
    ["vcofficerdefend"] = "Officer Command: Defend Here",
    ["vcofficerorder"] = "Officer Command: Compound Order",
    ["vcofficerfollow"] = "Officer Command: Follow Me"
}
local v_u_19 = {}
local v_u_20 = nil
local function v_u_21() --[[ Line: 141 ]]
    --[[ Upvalues: (copy 1): v_u_2, (copy 2): l_CurrentCamera_0 ]]
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "button",
        ["location"] = l_CurrentCamera_0
    }, true)
end;
for _, v_u_22 in ipairs(v_u_7:WaitForChild("keybinds", 100):GetChildren()) do
    local l_KeyCode_0 = Enum.KeyCode[v_u_22.Value]
    if l_KeyCode_0 == nil then
        l_KeyCode_0 = Enum.KeyCode[v12[v_u_22.Name]]
    end;
    v_u_19[v_u_22.Name] = l_KeyCode_0
    local v23 = v_u_22.Value == "World52" and "Unbound" or v_u_22.Value
    local l_Name_0 = v12[v_u_22.Name].Name
    local v24 = l_Name_0 == "World52" and "Unbound" or l_Name_0
    local v_u_25 = l_Parent_0.loadout_menu.settingsframe.keybinds.ex:Clone()
    v_u_25.Name = v_u_22.Name
    v_u_25.label.Text = v18[v_u_22.Name] .. " - Default: " .. "[" .. v24 .. "]"
    v_u_25.button.label.Text = v23
    v_u_25.Visible = true
    v_u_25.button.MouseButton1Click:Connect(function() --[[ Line: 177 ]]
        --[[ Upvalues: (ref 1): v_u_20, (copy 2): v_u_21, (copy 3): v_u_25, (copy 4): l_RenderStepped_0, (copy 5): v_u_19, (copy 6): v_u_22, (copy 7): v_u_1 ]]
        if _G.using_controller ~= true then
            if v_u_20 ~= "" then
                v_u_21()
                v_u_20 = ""
                v_u_25.button.label.Text = "Input a Key or [Delete] to unbind."
                repeat
                    l_RenderStepped_0:Wait()
                until v_u_20 ~= "";
                if v_u_20 == "Delete" then
                    v_u_25.button.label.Text = "Unbound"
                    v_u_19[v_u_22.Name] = "World52"
                    v_u_1.game_handler:FireServer("change_setting", v_u_22, "World52")
                    return;
                end;
                v_u_25.button.label.Text = v_u_20
                v_u_19[v_u_22.Name] = Enum.KeyCode[v_u_20]
                v_u_1.game_handler:FireServer("change_setting", v_u_22, v_u_20)
            end;
        end;
    end)
    v_u_25.Parent = l_Parent_0.loadout_menu.settingsframe.keybinds
end;
local function v_u_26() --[[ Line: 211 ]]
    --[[ Upvalues: (copy 1): v_u_2 ]]
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "hover",
        ["location"] = workspace,
        ["soundgroup"] = "none"
    }, true)
end;
_G.get_keybinds = function(p27) --[[ Line: 220 ]]
    --[[ Upvalues: (copy 1): v_u_13, (copy 2): v_u_19 ]]
    if _G.using_controller == true then
        return v_u_13[p27];
    else
        return v_u_19[p27];
    end;
end;
_G.aim_sens = v_u_7.aim_sens.Value
_G.scope_sens = v_u_7.scope_sens.Value
local function _(p_u_28, _) --[[ Line: 234 ]]
    p_u_28:GetPropertyChangedSignal("Text"):Connect(function() --[[ Line: 235 ]]
        --[[ Upvalues: (copy 1): p_u_28 ]]
        p_u_28.Text = p_u_28.Text:gsub("[^%d{.}]", "")
    end)
end;
local function _(p_u_29) --[[ Name: set_sensbox ]] --[[ Line: 240 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): v_u_7, (copy 3): v_u_1 ]]
    local l_Text_0 = p_u_29.Text
    p_u_29.Text = _G[p_u_29.Parent.Name]
    p_u_29:GetPropertyChangedSignal("Text"):Connect(function() --[[ Line: 235 ]]
        --[[ Upvalues: (copy 1): p_u_29 ]]
        p_u_29.Text = p_u_29.Text:gsub("[^%d{.}]", "")
    end)
    p_u_29.FocusLost:Connect(function(p30) --[[ Line: 247 ]]
        --[[ Upvalues: (ref 1): v_u_21, (copy 2): p_u_29, (ref 3): v_u_7, (ref 4): v_u_1, (ref 5): l_Text_0 ]]
        v_u_21()
        local v31 = tonumber(p_u_29.Text)
        local v32 = v31 == nil and 0 or v31
        if p30 == true and string.len((tostring(v32))) < 20 then
            local v33 = math.clamp(v32, 0.01, 2)
            p_u_29.Text = tostring(v33)
            local v34 = v_u_7:FindFirstChild(p_u_29.Parent.Name)
            if v34 then
                v34.Value = v33
                v_u_1.game_handler:FireServer("change_sens", v34, v33)
                _G[v34.Name] = v33
            end;
        else
            p_u_29.Text = l_Text_0
        end;
        l_Text_0 = p_u_29.Text
    end)
end;
local l_inputbox_0 = l_Parent_0.loadout_menu.settingsframe.aim_sens.inputbox
local l_Text_1 = l_inputbox_0.Text
l_inputbox_0.Text = _G[l_inputbox_0.Parent.Name]
l_inputbox_0:GetPropertyChangedSignal("Text"):Connect(function() --[[ Line: 235 ]]
    --[[ Upvalues: (copy 1): l_inputbox_0 ]]
    l_inputbox_0.Text = l_inputbox_0.Text:gsub("[^%d{.}]", "")
end)
l_inputbox_0.FocusLost:Connect(function(p35) --[[ Line: 247 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): l_inputbox_0, (copy 3): v_u_7, (copy 4): v_u_1, (ref 5): l_Text_1 ]]
    v_u_21()
    local v36 = tonumber(l_inputbox_0.Text)
    local v37 = v36 == nil and 0 or v36
    if p35 == true and string.len((tostring(v37))) < 20 then
        local v38 = math.clamp(v37, 0.01, 2)
        l_inputbox_0.Text = tostring(v38)
        local v39 = v_u_7:FindFirstChild(l_inputbox_0.Parent.Name)
        if v39 then
            v39.Value = v38
            v_u_1.game_handler:FireServer("change_sens", v39, v38)
            _G[v39.Name] = v38
        end;
    else
        l_inputbox_0.Text = l_Text_1
    end;
    l_Text_1 = l_inputbox_0.Text
end)
local l_inputbox_1 = l_Parent_0.loadout_menu.settingsframe.scope_sens.inputbox
local l_Text_2 = l_inputbox_1.Text
l_inputbox_1.Text = _G[l_inputbox_1.Parent.Name]
l_inputbox_1:GetPropertyChangedSignal("Text"):Connect(function() --[[ Line: 235 ]]
    --[[ Upvalues: (copy 1): l_inputbox_1 ]]
    l_inputbox_1.Text = l_inputbox_1.Text:gsub("[^%d{.}]", "")
end)
l_inputbox_1.FocusLost:Connect(function(p40) --[[ Line: 247 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): l_inputbox_1, (copy 3): v_u_7, (copy 4): v_u_1, (ref 5): l_Text_2 ]]
    v_u_21()
    local v41 = tonumber(l_inputbox_1.Text)
    local v42 = v41 == nil and 0 or v41
    if p40 == true and string.len((tostring(v42))) < 20 then
        local v43 = math.clamp(v42, 0.01, 2)
        l_inputbox_1.Text = tostring(v43)
        local v44 = v_u_7:FindFirstChild(l_inputbox_1.Parent.Name)
        if v44 then
            v44.Value = v43
            v_u_1.game_handler:FireServer("change_sens", v44, v43)
            _G[v44.Name] = v43
        end;
    else
        l_inputbox_1.Text = l_Text_2
    end;
    l_Text_2 = l_inputbox_1.Text
end)
delay(1, function() --[[ Line: 285 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0 ]]
    if l_LocalPlayer_0.PlayerGui:FindFirstChild("Chat") then
        for _, v45 in ipairs(l_LocalPlayer_0.PlayerGui.Chat:FindFirstChild("Frame"):GetChildren()) do
            if v45.Name ~= "ChatBarParentFrame" then
                v45.Visible = false
            end;
        end;
        l_LocalPlayer_0.PlayerGui.Chat.Frame:FindFirstChild("ChatBarParentFrame").Position = UDim2.new(0, 0, 0, 0)
    end;
end)
s_StarterGui_0:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
s_StarterGui_0:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)
l_Parent_0.core_game.customchat.CanvasPosition = Vector2.new(0, 99999)
l_Parent_0.loadout_menu.customisationframe.Visible = true
local l_cosmeticsframe_0 = l_Parent_0.loadout_menu.cosmeticsframe
v_u_1.audio_relay.OnClientEvent:connect(function(p46) --[[ Line: 306 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): v_u_2 ]]
    if not l_Parent_0:FindFirstChild("loadingmenu") then
        v_u_2:soundHandler(p46, true)
    end;
end)
v_u_1.effects_relay.OnClientEvent:connect(function(p47, p48, p49) --[[ Line: 314 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): v_u_3 ]]
    if not l_Parent_0:FindFirstChild("loadingmenu") then
        v_u_3(p47, p48, true, p49)
    end;
end)
v_u_1.weaponfx_relay.OnClientEvent:connect(function(p50, p51, p52) --[[ Line: 322 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): v_u_4 ]]
    if l_Parent_0:FindFirstChild("loadingmenu") then
        return;
    elseif not _G.get_settings or (_G.get_settings("disablevfx") ~= true or p50 == "weapon_visibility") then
        v_u_4(p50, p51, true, p52)
    end;
end)
local v_u_53 = tick()
local v_u_54 = Vector3.new()
_G.in_menu = false
l_Parent_0.core_game.deathscreen.Visible = true
local v_u_55 = {
    ["customisationframe"] = CFrame.new(-855.380554, -37.5723038, -87.4337311, -0.536861718, -0.00862193294, 0.843626201, -0, 0.999947786, 0.0102195535, -0.843670249, 0.00548648695, -0.536833644),
    ["settingsframe"] = CFrame.new(-1091.45032, -47.1583939, -93.1225662, -0.131943166, 0.0780073032, 0.9881832, -9.31322575e-10, 0.99689889, -0.0786953047, -0.99125737, -0.0103833089, -0.131533965),
    ["cosmeticsframe"] = CFrame.new(-1001.29175, -51.9431763, -89.3858032, -0.0297527406, -0.0837327093, 0.99604398, -0, 0.996485114, 0.0837697908, -0.999557316, 0.00249238079, -0.0296481624),
    ["serversframe"] = CFrame.new(-1026.33459, -51.4710541, -16.4650669, 0.203517914, -0.0647065863, 0.976930678, -1.86264515e-9, 0.997813642, 0.0660897642, -0.9790712, -0.0134504531, 0.203072965),
    ["creditsframe"] = CFrame.new(-1003.13055, -50.5555115, -172.711517, 0.438015103, -0.223542437, 0.870730579, -0, 0.968589485, 0.24866572, -0.898967624, -0.108919345, 0.424256831)
}
_G.cam_menu_positions = v_u_55
_G.cam_menu_at = "customisationframe"
_G.voice_command_select = nil
local v_u_56 = {}
local v_u_57 = false
local v_u_58 = 0
local v_u_59 = nil
for _, v_u_60 in ipairs(l_Parent_0.core_game.voicewheel:GetChildren()) do
    v_u_60.bar.button.Rotation = -v_u_60.Rotation
    v_u_60.bar.button.MouseEnter:connect(function() --[[ Line: 369 ]]
        --[[ Upvalues: (copy 1): v_u_26, (copy 2): v_u_60 ]]
        v_u_26()
        _G.voice_command_select = v_u_60
    end)
    v_u_60.bar.button.MouseLeave:connect(function() --[[ Line: 374 ]]
        --[[ Upvalues: (copy 1): v_u_26 ]]
        v_u_26()
        _G.voice_command_select = nil
    end)
end;
local l_serversframe_0 = l_Parent_0.loadout_menu.serversframe
local v_u_61 = nil
local v_u_62 = {}
local v_u_63 = {
    ["control"] = "Control Points",
    ["assault"] = "Assault Objectives",
    ["push"] = "Territory Push",
    ["train"] = "Armoured Train",
    ["infection"] = "???",
    ["laststand"] = "Last Stand",
    ["truce"] = "The Truce",
    ["training"] = "Training"
}
local v_u_64 = {
    ["control"] = {},
    ["assault"] = {},
    ["push"] = {},
    ["laststand"] = {},
    ["truce"] = {},
    ["infection"] = {}
}
local function f_toMS(p65) --[[ Name: toMS ]] --[[ Line: 381 ]]
    return string.format("%02i:%02i", p65 / 60 % 60, p65 % 60);
end;
for _, v_u_66 in ipairs(l_serversframe_0.filters:GetChildren()) do
    v_u_66.MouseButton1Click:Connect(function() --[[ Line: 414 ]]
        --[[ Upvalues: (copy 1): v_u_21, (copy 2): v_u_66, (ref 3): v_u_61 ]]
        v_u_21()
        if v_u_66.ImageColor3 == Color3.new(1, 1, 1) then
            v_u_66.ImageColor3 = Color3.new(0, 0, 0)
            v_u_66.inner.TextColor3 = Color3.new(1, 1, 1)
        else
            v_u_66.ImageColor3 = Color3.new(1, 1, 1)
            v_u_66.inner.TextColor3 = Color3.new(0, 0, 0)
        end;
        v_u_61()
    end)
end;
local function v_u_71() --[[ Line: 429 ]]
    --[[ Upvalues: (copy 1): l_serversframe_0, (copy 2): v_u_62 ]]
    if l_serversframe_0.Visible == false then
        return;
    end;
    for _, v67 in ipairs(l_serversframe_0.menu.scroll:GetChildren()) do
        if v67.Name ~= "ex" and (v67.Name ~= "UIListLayout" and v67:FindFirstChild("region")) then
            local v68 = true
            for v69, v70 in pairs(v_u_62) do
                if v70 == true then
                    if v67.region.Value == v69 then
                        v68 = true
                        break;
                    end;
                    v68 = false
                end;
            end;
            if l_serversframe_0.filters.filterlow.ImageColor3 == Color3.new(1, 1, 1) and v67.players.Value <= 4 then
                v68 = false
            end;
            if l_serversframe_0.filters.filterfull.ImageColor3 == Color3.new(1, 1, 1) and v67.players.Value >= 30 then
                v68 = false
            end;
            if l_serversframe_0.filters.filternew.ImageColor3 == Color3.new(1, 1, 1) and v67.lifetime.Value >= 1200 then
                v68 = false
            end;
            if v68 == true then
                v67.Visible = true
            else
                v67.Visible = false
            end;
        end;
    end;
end;
local function v_u_74(p_u_72) --[[ Line: 479 ]]
    --[[ Upvalues: (copy 1): l_serversframe_0, (copy 2): v_u_62, (copy 3): v_u_21, (ref 4): v_u_61 ]]
    if l_serversframe_0.regionfilter.scroll:FindFirstChild(p_u_72) == nil then
        v_u_62[p_u_72] = false
        local v_u_73 = l_serversframe_0.regionfilter.scroll.ex:Clone()
        v_u_73.Name = p_u_72
        v_u_73.inner.Text = p_u_72
        v_u_73.Visible = true
        v_u_73.MouseButton1Click:Connect(function() --[[ Line: 489 ]]
            --[[ Upvalues: (ref 1): v_u_21, (ref 2): v_u_62, (copy 3): p_u_72, (copy 4): v_u_73, (ref 5): v_u_61 ]]
            v_u_21()
            v_u_62[p_u_72] = not v_u_62[p_u_72]
            if v_u_62[p_u_72] == true then
                v_u_73.ImageColor3 = Color3.new(1, 1, 1)
                v_u_73.inner.TextColor3 = Color3.new(0, 0, 0)
            else
                v_u_73.ImageColor3 = Color3.new(0, 0, 0)
                v_u_73.inner.TextColor3 = Color3.new(1, 1, 1)
            end;
            v_u_61()
        end)
        v_u_73.Parent = l_serversframe_0.regionfilter.scroll
    end;
end;
local function v_u_77(p75, p76) --[[ Line: 510 ]]
    --[[ Upvalues: (copy 1): v_u_63, (copy 2): v_u_62, (copy 3): v_u_74 ]]
    if p75 then
        p75.region.Value = p76.serverregion
        p75.players.Value = p76.serverplayers
        p75.lifetime.Value = p76.serverlifetime
        p75.LayoutOrder = 100 - p76.serverplayers
        p75.playercount.Text = "Soldiers: " .. p76.serverplayers .. " / 32"
        p75.servermission.Text = "Mission: " .. (v_u_63[p76.servergamemode] or "Unknown")
        local l_servertitle_0 = p75.servertitle
        local l_servername_0 = p76.servername
        local l_serverregion_0 = p76.serverregion
        local l_serverlifetime_0 = p76.serverlifetime
        l_servertitle_0.Text = l_servername_0 .. " - " .. l_serverregion_0 .. " - " .. string.format("%02i:%02i", l_serverlifetime_0 / 60 % 60, l_serverlifetime_0 % 60)
        if v_u_62[p76.serverregion] == nil then
            v_u_74(p76.serverregion)
        end;
    end;
end;
local function v_u_80(p_u_78) --[[ Line: 529 ]]
    --[[ Upvalues: (copy 1): l_serversframe_0, (copy 2): v_u_21, (copy 3): v_u_77, (ref 4): v_u_71 ]]
    if p_u_78 ~= nil and (p_u_78:FindFirstChild("serverplayers") ~= nil and (p_u_78:FindFirstChild("servergamemode") ~= nil and (p_u_78:FindFirstChild("servername") ~= nil and (p_u_78:FindFirstChild("serverregion") ~= nil and p_u_78:FindFirstChild("serverlifetime") ~= nil)))) then
        local v79 = l_serversframe_0.menu.scroll:FindFirstChild(p_u_78.Name)
        if v79 == nil then
            v79 = l_serversframe_0.menu.scroll.ex:Clone()
            v79.Name = p_u_78.Name
            v79.join.MouseButton1Click:Connect(function() --[[ Line: 542 ]]
                --[[ Upvalues: (copy 1): p_u_78, (ref 2): v_u_21 ]]
                if p_u_78.Name ~= "ex" then
                    v_u_21()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, p_u_78.Name)
                end;
            end)
            v79.Visible = true
            v79.Parent = l_serversframe_0.menu.scroll
        end;
        if v79 then
            v_u_77(v79, {
                ["serverplayers"] = p_u_78.serverplayers.Value,
                ["servergamemode"] = p_u_78.servergamemode.Value,
                ["servername"] = p_u_78.servername.Value,
                ["serverregion"] = p_u_78.serverregion.Value,
                ["serverlifetime"] = p_u_78.serverlifetime.Value
            })
        end;
        v_u_71()
    end;
end;
local function v83() --[[ Line: 572 ]]
    --[[ Upvalues: (copy 1): l_serversframe_0, (copy 2): v_u_77, (copy 3): v_u_80, (ref 4): v_u_71 ]]
    if l_serversframe_0.Visible ~= false then
        for _, v81 in ipairs(workspace.serverStuff.serverlist:GetChildren()) do
            if v81.Name ~= "ex" and (v81:FindFirstChild("servername") and v81:FindFirstChild("serverlifetime")) then
                local v82 = l_serversframe_0.menu.scroll:FindFirstChild(v81.Name)
                if v82 then
                    v_u_77(v82, {
                        ["serverplayers"] = v81.serverplayers.Value,
                        ["servergamemode"] = v81.servergamemode.Value,
                        ["servername"] = v81.servername.Value,
                        ["serverregion"] = v81.serverregion.Value,
                        ["serverlifetime"] = v81.serverlifetime.Value
                    })
                else
                    v_u_80(v81)
                end;
            end;
        end;
        v_u_71()
    end;
end;
local v_u_84 = tick()
local function _() --[[ Line: 605 ]]
    --[[ Upvalues: (copy 1): l_serversframe_0, (copy 2): v_u_80 ]]
    if l_serversframe_0.Visible ~= false then
        for _, v85 in ipairs(l_serversframe_0.menu.scroll:GetChildren()) do
            if v85.Name ~= "ex" and v85.Name ~= "UIListLayout" then
                v85:Destroy()
            end;
        end;
        for _, v86 in ipairs(workspace.serverStuff.serverlist:GetChildren()) do
            if v86.Name ~= "ex" and (v86:FindFirstChild("servername") and v86:FindFirstChild("serverlifetime")) then
                v_u_80(v86)
            end;
        end;
    end;
end;
workspace.serverStuff.serverlist.ChildAdded:Connect(v_u_80)
workspace.serverStuff.serverlist.ChildRemoved:Connect(v83)
local v_u_87 = {}
local v_u_88 = 0
local function v_u_92() --[[ Line: 634 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0, (ref 2): v_u_87 ]]
    local l_nation_team_0 = workspace.nation_team
    if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
        l_nation_team_0 = workspace.empire_team
    end;
    v_u_87 = {}
    for _, v89 in ipairs(l_nation_team_0:GetChildren()) do
        if v89:FindFirstChild("Humanoid") and (v89.Humanoid.Health > 0 and v89:FindFirstChild("Torso")) then
            table.insert(v_u_87, v89)
        end;
    end;
    table.sort(v_u_87, function(p90, p91) --[[ Line: 646 ]]
        return p90.Name > p91.Name;
    end)
end;
local function v_u_95(p93, p94) --[[ Line: 651 ]]
    --[[ Upvalues: (copy 1): v_u_92, (ref 2): v_u_88, (ref 3): v_u_87, (copy 4): l_CurrentCamera_0, (copy 5): l_Parent_0, (copy 6): s_UserInputService_0, (copy 7): v_u_55 ]]
    v_u_92()
    v_u_88 = v_u_88 + p93
    if v_u_88 <= 0 then
        v_u_88 = #v_u_87
    elseif v_u_88 > #v_u_87 then
        v_u_88 = 1
    end;
    if #v_u_87 > 0 and v_u_87[v_u_88] then
        l_CurrentCamera_0.FieldOfView = 90
        l_CurrentCamera_0.CameraType = Enum.CameraType.Follow
        l_CurrentCamera_0.CameraSubject = v_u_87[v_u_88].Torso
        l_Parent_0.core_game.deathscreen.bottomframe.lowertext.Text = v_u_87[v_u_88].Name
    end;
    if #v_u_87 <= 0 and (p94 and p94 == true) then
        s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
        l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
        l_CurrentCamera_0.FieldOfView = 40
        l_CurrentCamera_0.CFrame = v_u_55[_G.cam_menu_at]
    end;
end;
local l_endoftruce_0 = l_Parent_0.core_game.endoftruce
local function v_u_106(_, _, p96, _) --[[ Line: 683 ]]
    --[[ Upvalues: (copy 1): l_endoftruce_0, (copy 2): l_values_0, (copy 3): l_RenderStepped_0, (copy 4): v_u_2 ]]
    l_endoftruce_0.text1.TextTransparency = 1
    l_endoftruce_0.text2.TextTransparency = 1
    l_endoftruce_0.text3.TextTransparency = 1
    l_endoftruce_0.text4.TextTransparency = 1
    l_endoftruce_0.text5.TextTransparency = 1
    l_endoftruce_0.text6.TextTransparency = 1
    l_endoftruce_0.BackgroundTransparency = 1
    l_endoftruce_0.Visible = true
    l_endoftruce_0.text6.Text = ({
        "\"There is a better future for all of us, enemy or foe, even amongst the bleakest nights.\"\nSergeant Thomas (1889 - 1919)",
        "\"I want to see the sky again, and I know that we hold on long enough, some day we will.\"\nSergeant Eric (1887 - 1917)",
        "\"Even in the darkest of nights, eventually, dawn will break over the horizon for us all.\"\nKnight Commander Gennadiya (1888 - 1920)",
        "\"We act like monsters, but even the most vicious of monsters have a heart still, perhaps that rings true for us as well.\"\nKnight Reinhold (1886 - 1918)",
        "\"I know there is a future where we both can witness the sun together again. We just have to keep holding on.\"\nLieutenant Nancy (1887 - 1917)",
        "\"The world is a beautiful thing, and by extension, we are beautiful. Every single one of us, and one day, we will show it.\"\nGrand Knight Anneliese (1888 - 1921)"
    })[p96]
    l_endoftruce_0.text4.Text = l_values_0.nationdeaths.Value .. " Royal Nation Casualties counted."
    l_endoftruce_0.text5.Text = l_values_0.empiredeaths.Value .. " Golden Empire Casualties counted."
    local v97 = tick()
    local v98 = 1.5
    repeat
        l_RenderStepped_0:wait()
        local v99 = (tick() - v97) / v98
        l_endoftruce_0.text1.TextTransparency = v_u_2:lerp(1, 0, v99)
        l_endoftruce_0.BackgroundTransparency = v_u_2:lerp(1, 0.5, v99)
    until v98 <= tick() - v97;
    l_endoftruce_0.text1.TextTransparency = 0
    l_endoftruce_0.BackgroundTransparency = 0.5
    v_u_2:s_wait(2)
    for v100 = 1, 5 do
        local v101 = tick()
        repeat
            l_RenderStepped_0:wait()
            l_endoftruce_0["text" .. v100 + 1].TextTransparency = v_u_2:lerp(1, 0, (tick() - v101) / v98)
        until v98 <= tick() - v101;
        l_endoftruce_0["text" .. v100 + 1].TextTransparency = 0
        v_u_2:s_wait(2)
    end;
    v_u_2:s_wait(8)
    local v102 = tick()
    local v103 = 3
    while true do
        l_RenderStepped_0:wait()
        local v104 = (tick() - v102) / v103
        for v105 = 1, 6 do
            l_endoftruce_0["text" .. v105].TextTransparency = v_u_2:lerp(0, 1, v104)
        end;
        l_endoftruce_0.BackgroundTransparency = v_u_2:lerp(0.5, 1, v104)
        if v103 <= tick() - v102 then
            l_endoftruce_0["text" .. 1].TextTransparency = 1
            l_endoftruce_0["text" .. 2].TextTransparency = 1
            l_endoftruce_0["text" .. 3].TextTransparency = 1
            l_endoftruce_0["text" .. 4].TextTransparency = 1
            l_endoftruce_0["text" .. 5].TextTransparency = 1
            l_endoftruce_0["text" .. 6].TextTransparency = 1
            l_endoftruce_0.Visible = false
            return;
        end;
    end;
end;
local l_endofgame_0 = l_Parent_0.core_game.endofgame
local function v_u_115(p107, _, p108, p109) --[[ Line: 767 ]]
    --[[ Upvalues: (copy 1): l_endofgame_0, (copy 2): l_values_0, (copy 3): v_u_2, (copy 4): l_CurrentCamera_0, (copy 5): l_RenderStepped_0, (copy 6): l_Parent_0 ]]
    local v110, v111
    if p107 == "nation" then
        v110 = {
            "\"I have witnessed executions of families and the necks of children contorted beyond human, this is reason enough to fight.\"\nSergeant Major Thomas (1889 - 1920)",
            "\"Every day this war drags on, I only wish it would end faster, but these Empire cultists would pray to see it longer.\"\nSergeant Bessie (1895 - 1921)",
            "\"Always look forward to brighter future built on unity and prosperity, not blind fanaticism of a single ruler.\"\nSergeant Major Roy (1890 - 1922)",
            "\"Every life lost under the dirt will always be remembered, do not let their souls be in vain when faced with the Empire.\"\nLieutenant Lawrence (1890 - 1922)",
            "\"Do not let the faces of these angels fool you, because they are a mere facade of the devil that they claim is us.\"\nSergeant Claude (1891 - 1921)",
            "\"Evil they call us, but I have never seen such brutality from men who claim to follow the word of God and justice.\"\nCorporal Rosa (1899 - 1923)",
            "\"The Empire only wants to enact its twisted, perversion of faith and justice, and they are too blind to even see that.\"\nLieutenant Marguerite (1888 - 1922)",
            "\"We fight for a better future, the Golden Empire fights to purge and cleanse anyone they deem a heretic, even their own.\"\nCorporal Dalila (1892 - 1921)",
            "\"They caused this war and now they want to blame us for prolonging it\226\128\148like we all should just roll over and die\226\128\148to hell with that.\"\nLieutenant Smith (1884 - 1920)",
            "\"I fight because my family deserves better, they deserve a life of peace un-burdened by the eyes of lunatic book-worshippers.\"\nSergeant Glen (1890 - 1921)",
            "\"They have long since forsaken the God they claim to serve, their blood stained with maniacal, corrupted zealotry.\"\nLieutenant Geneva (1883 - 1921)",
            "\"I saw a man who took seven rifle rounds continue towards us, sword in hand.. that is when I knew we were fighting demons.\"\nCorporal Joe (1895 - 1921)",
            "\"The faith the Empire preaches is merely a lure to drag men and women to the deepest depths of anguish and agony.\"\nSergeant Eugene (1885 - 1919)",
            "\"If just for a moment, whenever I take a life... the whispers silence themselves under the beating of my heart.\"\nCorporal Elvira (1892 - 1923)",
            "\"If a thousand must be sacrificed to save ten thousand, then so be it. I would gladly give my life to save ten others.\"\nLieutenant Sylvester (1883 - 1921)",
            "\"It only took my brother 2 months to kick the bucket during his service. How long do you think I\226\128\153ll make it?\"\nPrivate First Class Jonathan (1900 - 1921)",
            "\"For honor and glory. Not to the false ideals the Empire propagates, but to the country I pledged my life to.\"\nSergeant Perry (1899 - 1922)"
        }
        v111 = {
            "With aid from Solace, the land became a key manufacturing center for the Nation\226\128\153s war effort. Royalist soldiers greatly appreciated the influx of ammunition.",
            "The sector became a prolific mining ground for the Nation, their armourers greatly thankful the new deposits of material.",
            "The Nation used their new land for training an swath of new recruits, most of them joining in lieu of the campaign\226\128\153s success.",
            "The region soon became prime for real estate development - cheap housing proved essential for many struggling Nation families."
        }
    else
        v110 = {
            "\"The Empire is the sword, our loyalty is the shield and we will see a future without evil and tyranny.\"\nInquisitor Ottilie (1890 - 1920)",
            "\"Corruption is the path of the Royal Nation whom their kings cling to\226\128\148but under the Golden Empire\226\128\148we will always be kindred spirits.\"\nInquisitor Elsbeth (1886 - 1920)",
            "\"My father wanted to change the lives for the better but avarice of the Kings deludes even the brightest of minds.\"\nArmsman Julius (1900 - 1922)",
            "\"We have naught but faith in these tunnels, yet despite that, it shines brighter than any lantern of the abhorrent Nation.\"\nKnight Commander Ferdinand (1889 - 1921)",
            "\"Pity and shame it is that we can serve in the Golden Empire but once in our lifetime.\"\nGrand Knight Eugen (1901 - 1923)",
            "\"The Royal Nation is pestilence, a plague to a beautiful future and I bear nothing but contempt to these dogs.\"\nGrand Knight Leonard (1888 - 1922)",
            "\"The day their dogs tore apart my innocent brother for the crimes of a fat King, I can never forgive ever again.\"\nSquire Edwin (1899 - 1923)",
            "\"I wish for a life where souls were valued for more than coin, fame and selfish desires to trample those beneath you.\"\nSquire Alwin (1902 - 1922)",
            "\"I dream to see the sky again, and bask in the light of our sun, but not in a world stained by the fear of the Royal Nation.\"\nKnight Allochka (1896 - 1921)",
            "\"They want to rule with fear, corruption and greed, then so be it\226\128\148we will fight with vengeance, fury and judgement.\"\nKnight Phyllis (1895 - 1923)",
            "\"A battlefield is no better than hell itself. That is why, to expunge this hell from Earth, we must fight with all our heart.\"\nGrand Knight Beckford (1890 - 1920)",
            "\"The Nation dogs will devour each other under the pretense of freedom. Unity is the only way to repair this broken world.\"\nInquisitor Gennadiya (1887 - 1922)",
            "\"A pity that they continue to be repelled by the blinding, unfaltering light of the Empire. Pride is the worst of all sins, after all.\"\nKnight Harry (1897 - 1922)",
            "\"Staring into the blood pooling beneath me, I remembered the twinkling of the stars overhead when I was a child.\"\nArmsman Elizabeth (1901 - 1923)",
            "\"All the lives we have sacrificed shant be in vain. We will see to it that everything they stood for is avenged.\"\nKnight Commander Anni (1890 - 1922)",
            "\"Their bombs destroyed the world... my world. I won\226\128\153t let those devils take everything I worked to build away from me again.\nKnight Werner (1898 - 1923)\"",
            "\"From its very roots, the Nation is a plague. They merely destroy, while we have the ability to create and rebuild.\"\nArmsman Helen (1899 - 1920)"
        }
        v111 = {
            "To stave off an outbreak of the Cave Plague, the Empire utilized the sector to establish medical centers for the Mortician Wing and poor families.",
            "Through negotiations with Solace, the region became a large source of the Empire and Solace\226\128\153s food supply via the creation of new greenhouses and farms.",
            "With the sector stabilized, the Empire took to establishing schools and research centers for civilian use. The literacy rate would peak amongst the unfortunate soon after.",
            "In the wake of the Empire\226\128\153s victory, the sector became a prolific religious center for many devout Imperial civilians, giving hope for a better future."
        }
    end;
    l_endofgame_0.bg.Visible = false
    l_endofgame_0.text1.Visible = false
    l_endofgame_0.text1extra.Visible = false
    l_endofgame_0.text2.TextTransparency = 1
    l_endofgame_0.text3.TextTransparency = 1
    l_endofgame_0.text3nation.TextTransparency = 1
    l_endofgame_0.text3empire.TextTransparency = 1
    l_endofgame_0.text4.TextTransparency = 1
    l_endofgame_0.BackgroundTransparency = 0
    l_endofgame_0.Visible = true
    local v112 = v110[p108]
    l_endofgame_0.text2.Text = v111[p109]
    l_endofgame_0.text4.Text = v112
    l_endofgame_0.text3.Text = l_values_0.totalevacs.Value .. " Soldiers have been able to survive this campaign."
    l_endofgame_0.text3nation.Text = l_values_0.nationdeaths.Value .. " Royal Nation Casualties counted."
    l_endofgame_0.text3empire.Text = l_values_0.empiredeaths.Value .. " Golden Empire Casualties counted."
    v_u_2:s_wait(4)
    l_endofgame_0.text1extra.Text = l_values_0.mapname.Value .. " Campaign Complete"
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "endmatchreveal",
        ["location"] = l_CurrentCamera_0
    }, true)
    if p107 == "nation" then
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "nation_start",
            ["volume_adjust"] = -0.5,
            ["location"] = l_CurrentCamera_0
        }, true)
        l_endofgame_0.bg.Image = "rbxassetid://17512646559"
        l_endofgame_0.bg.ImageColor3 = Color3.fromRGB(107, 50, 124)
        l_endofgame_0.text1.Text = "Royal Nation Victory"
        l_endofgame_0.text1.TextColor3 = Color3.fromRGB(107, 50, 124)
        l_endofgame_0.text1extra.TextColor3 = Color3.fromRGB(107, 50, 124)
    elseif p107 == "empire" then
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "empire_start",
            ["volume_adjust"] = -0.5,
            ["location"] = l_CurrentCamera_0
        }, true)
        l_endofgame_0.bg.Image = "rbxassetid://17512646697"
        l_endofgame_0.bg.ImageColor3 = Color3.fromRGB(245, 205, 48)
        l_endofgame_0.text1.Text = "Golden Empire Victory"
        l_endofgame_0.text1.TextColor3 = Color3.fromRGB(245, 205, 48)
        l_endofgame_0.text1extra.TextColor3 = Color3.fromRGB(245, 205, 48)
    end;
    l_endofgame_0.text1.Visible = true
    l_endofgame_0.text1extra.Visible = true
    l_endofgame_0.bg.Visible = true
    v_u_2:s_wait(3)
    tick()
    for v113 = 1, 3 do
        local v114 = tick()
        -- ::l13:: (Possible bug with goto)
        l_RenderStepped_0:wait()
        l_endofgame_0["text" .. v113 + 1].TextTransparency = v_u_2:lerp(1, 0, (tick() - v114) / 1.5)
        if v113 == 2 then
            l_endofgame_0.text3nation.TextTransparency = l_endofgame_0["text" .. v113 + 1].TextTransparency
            l_endofgame_0.text3empire.TextTransparency = l_endofgame_0["text" .. v113 + 1].TextTransparency
        end;
        if tick() - v114 < 1.5 then
            continue;
        end;
        l_endofgame_0["text" .. v113 + 1].TextTransparency = 0
        if v113 == 2 then
            l_endofgame_0.text3nation.TextTransparency = 0
            l_endofgame_0.text3empire.TextTransparency = 0
        end;
        v_u_2:s_wait(3)
    end;
    repeat
        l_RenderStepped_0:Wait()
    until l_values_0.gamestate.Value ~= "gameend";
    l_endofgame_0.Visible = false
    _G.fadetoblack = tick()
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "endmatchshow",
        ["location"] = l_CurrentCamera_0
    }, true)
    l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
    repeat
        l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
        _G.fadetoblack = tick()
        l_RenderStepped_0:Wait()
    until l_values_0.gamestate.Value ~= "gameend";
end;
local l_endofmatch_0 = l_Parent_0.core_game.endofmatch
local function v_u_123(p116, p117, _, p118) --[[ Line: 948 ]]
    --[[ Upvalues: (copy 1): l_endofmatch_0, (copy 2): l_values_0, (copy 3): v_u_7, (copy 4): v_u_2, (copy 5): l_CurrentCamera_0, (copy 6): l_RenderStepped_0, (copy 7): l_Parent_0 ]]
    l_endofmatch_0.text1.Visible = false
    l_endofmatch_0.text2.Visible = false
    l_endofmatch_0.text3.Visible = false
    l_endofmatch_0.text4.Visible = false
    l_endofmatch_0.bg.Visible = false
    if p116 == "nation" then
        l_endofmatch_0.bg.Image = "rbxassetid://17512646559"
        l_endofmatch_0.bg.ImageColor3 = Color3.fromRGB(107, 50, 124)
        l_endofmatch_0.text1.Text = "Royal Nation Success"
        l_endofmatch_0.text1.TextColor3 = Color3.fromRGB(107, 50, 124)
    elseif p116 == "empire" then
        l_endofmatch_0.bg.Image = "rbxassetid://17512646697"
        l_endofmatch_0.bg.ImageColor3 = Color3.fromRGB(245, 205, 48)
        l_endofmatch_0.text1.Text = "Golden Empire Success"
        l_endofmatch_0.text1.TextColor3 = Color3.fromRGB(245, 205, 48)
    elseif p116 == "fight" then
        l_endofmatch_0.bg.Image = "rbxassetid://99319291144715"
        l_endofmatch_0.bg.ImageColor3 = Color3.fromRGB(170, 0, 0)
        l_endofmatch_0.text1.Text = "Complete Massacre"
        l_endofmatch_0.text1.TextColor3 = Color3.fromRGB(170, 0, 0)
    end;
    local v119 = 3
    if p116 == "fight" then
        l_endofmatch_0.text2.Text = "The war zone is left completely uninhabited with no victors."
        l_endofmatch_0.text3.Text = "The dead will rot in their graves, their bodies to never be recovered."
        l_endofmatch_0.text4.Text = l_values_0.empiredeaths.Value + l_values_0.nationdeaths.Value .. " lives have been lost in the campaign."
        v119 = 4
    else
        l_endofmatch_0.text2.Text = p117 .. " lives were lost in the battle."
        if v_u_7.kills.Value > 0 then
            if v_u_7.kills.Value == 1 then
                l_endofmatch_0.text3.Text = "You have taken a single life this battle. Do you feel guilt?"
            else
                l_endofmatch_0.text3.Text = "You have taken " .. v_u_7.kills.Value .. " of those lives."
            end;
        else
            l_endofmatch_0.text3.Text = "You took no lives this battle."
        end;
        if v_u_7.heals.Value > v_u_7.kills.Value then
            if v_u_7.heals.Value == 1 then
                l_endofmatch_0.text3.Text = "You have saved a single life this battle. Do you feel relieved?"
            else
                l_endofmatch_0.text3.Text = "You have saved " .. v_u_7.heals.Value .. " lives this battle."
            end;
        end;
        if l_values_0.surrenders.Value > 0 then
            v119 = 4
            local v120 = {
                "Jaeger Corps",
                "Old Guards",
                "Officer Watch",
                "Soldat Brigade",
                "Rook Division",
                "Lancer Legion",
                "Mortician Wing"
            }
            if l_values_0.surrenders.Value == 1 then
                l_endofmatch_0.text4.Text = "A single soul has surrendered, soon to be stationed as a sole prisoner with the " .. v120[p118] .. "."
            elseif l_values_0.surrenders.Value >= 2 then
                l_endofmatch_0.text4.Text = l_values_0.surrenders.Value .. " souls have surrendered, soon to be stationed as prisoners with the " .. v120[p118] .. "."
            end;
        end;
        if l_values_0.evacs.Value > 0 then
            v119 = 4
            if l_values_0.evacs.Value == 1 then
                l_endofmatch_0.text4.Text = "No opposing souls were able to escape."
            elseif l_values_0.evacs.Value == 2 then
                l_endofmatch_0.text4.Text = "A single life was able to escape the horrors of this battle."
            elseif l_values_0.evacs.Value >= 3 then
                l_endofmatch_0.text4.Text = l_values_0.evacs.Value - 1 .. " souls were able to escape this battle to live another day."
            end;
        end;
    end;
    l_endofmatch_0.Visible = true
    v_u_2:s_wait(3)
    for v121 = 1, v119 do
        if v121 == 1 then
            l_endofmatch_0.bg.Visible = true
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "endmatchreveal",
                ["location"] = l_CurrentCamera_0
            }, true)
            if p116 == "fight" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "gameend",
                    ["location"] = l_CurrentCamera_0
                }, true)
            end;
        else
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "endmatchshow",
                ["location"] = l_CurrentCamera_0
            }, true)
        end;
        l_endofmatch_0["text" .. v121].Visible = true
        v_u_2:s_wait(2)
    end;
    local v122 = tick()
    while l_values_0.gamestate.Value == "gameend" do
        l_RenderStepped_0:Wait()
        if tick() - v122 >= 3 then
            break;
        end;
    end;
    _G.fadetoblack = tick()
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "endmatchshow",
        ["location"] = l_CurrentCamera_0
    }, true)
    l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
    l_endofmatch_0.Visible = false
    repeat
        l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
        _G.fadetoblack = tick()
        l_RenderStepped_0:Wait()
    until l_values_0.gamestate.Value ~= "gameend";
end;
local function v_u_135(p124, p125, p126) --[[ Line: 1097 ]]
    --[[ Upvalues: (copy 1): l_values_0, (copy 2): l_LocalPlayer_0, (copy 3): v_u_2, (copy 4): l_CurrentCamera_0, (ref 5): v_u_57, (copy 6): l_Parent_0, (copy 7): v_u_56, (copy 8): l_RenderStepped_0, (ref 9): v_u_135 ]]
    if l_values_0.gamemode.Value == "infection" then
        return;
    elseif p125 == "message_nondread" and (l_LocalPlayer_0.Character:FindFirstChild("dreadnought") or l_LocalPlayer_0.Character:FindFirstChild("class") and l_LocalPlayer_0.Character.class.Value == "dread") then
        return;
    else
        if p125 == "objlost" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = l_values_0.gamemode.Value == "assault" and "ad_objective_lost" or "lost" .. math.random(1, 2),
                ["location"] = l_CurrentCamera_0
            }, true)
        elseif p125 == "objgot" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = l_values_0.gamemode.Value == "assault" and "ad_objective_capture" or "capture" .. math.random(1, 2),
                ["location"] = l_CurrentCamera_0
            }, true)
        elseif p125 == "message" or (p125 == "message_nondread" or p125 == "roundstart") then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "message",
                ["location"] = l_CurrentCamera_0
            }, true)
            if p125 == "roundstart" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "countdown",
                    ["location"] = l_CurrentCamera_0
                }, true)
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and "empire_start" or "nation_start",
                    ["location"] = l_CurrentCamera_0
                }, true)
            end;
        elseif p125 == "elite" then
            if l_values_0.Parent.conscriptmode.Value == true then
                return;
            end;
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "elite_available",
                ["location"] = l_CurrentCamera_0
            }, true)
        end;
        v_u_57 = true
        local v127 = l_Parent_0.alert:Clone()
        local l_nationleft_0 = v127.icons.nationleft
        local l_nationright_0 = v127.icons.nationright
        if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
            v127.icons.nationleft.Visible = false
            v127.icons.nationright.Visible = false
            v127.icons.empireleft.Visible = true
            v127.icons.empireright.Visible = true
            l_nationleft_0 = v127.icons.empireleft
            l_nationright_0 = v127.icons.empireright
            v127.scroll.toptext.Text = "QUEEN\'S WILL"
        end;
        v127.Visible = true
        v127.Parent = l_Parent_0
        if p126 == true then
            table.remove(v_u_56, 1)
        else
            for _ = 1, 5 do
                l_nationleft_0.ImageTransparency = l_nationleft_0.ImageTransparency - 0.2
                l_nationright_0.ImageTransparency = l_nationright_0.ImageTransparency - 0.2
                v_u_2:s_wait(0.03)
            end;
        end;
        l_nationleft_0.ImageTransparency = 0
        l_nationright_0.ImageTransparency = 0
        v_u_2:s_wait(0.5)
        local v128 = tick()
        local v129 = 0.5
        repeat
            l_RenderStepped_0:wait()
            local v130 = (tick() - v128) / v129
            v127.scroll.Size = UDim2.new(0, 0, 0.6, 0):Lerp(UDim2.new(0.3, 0, 0.6, 0), v130)
            v127.icons.Size = UDim2.new(0, 0, 0.6, 0):Lerp(UDim2.new(0.3, 0, 0.6, 0), v130)
        until v129 <= tick() - v128;
        v127.scroll.Size = UDim2.new(0.3, 0, 0.6, 0)
        v127.icons.Size = UDim2.new(0.3, 0, 0.6, 0)
        for v131 = 1, string.len(p124) do
            v127.maintext.Text = string.sub(p124, 1, v131)
            if string.sub(p124, v131, v131 + 1) == "  " then
                v_u_2:s_wait(0.5)
            end;
            v_u_2:s_wait(0.03)
        end;
        v127.maintext.Text = p124
        v_u_2:s_wait(3)
        local v132 = tick()
        local v133 = 0.5
        repeat
            l_RenderStepped_0:wait()
            local v134 = (tick() - v132) / v133
            v127.maintext.TextTransparency = v134
            v127.maintext.TextStrokeTransparency = v134
            v127.scroll.Size = UDim2.new(0.3, 0, 0.6, 0):Lerp(UDim2.new(0, 0, 0.6, 0), v134)
            v127.icons.Size = UDim2.new(0.3, 0, 0.6, 0):Lerp(UDim2.new(0, 0, 0.6, 0), v134)
        until v133 <= tick() - v132;
        v127.scroll.Size = UDim2.new(0, 0, 0.6, 0)
        v127.icons.Size = v127.scroll.Size
        v127.maintext.TextTransparency = 1
        v127.maintext.TextStrokeTransparency = 1
        if #v_u_56 > 0 then
            v127:Destroy()
            v_u_135(v_u_56[1][1], v_u_56[1][2], true)
        else
            v_u_57 = false
            for _ = 1, 5 do
                l_nationleft_0.ImageTransparency = l_nationleft_0.ImageTransparency + 0.2
                l_nationright_0.ImageTransparency = l_nationright_0.ImageTransparency + 0.2
                v_u_2:s_wait(0.03)
            end;
            v127:Destroy()
        end;
    end;
end;
make_gamemode_intro = function() --[[ Line: 1257 ]]
    --[[ Upvalues: (copy 1): l_values_0, (copy 2): l_Parent_0, (copy 3): l_LocalPlayer_0 ]]
    if _G.get_settings("hidegamemodebrief") ~= true then
        if l_values_0.gamemode.Value == "control" then
            l_Parent_0.core_game.gamemode_title.Text = "Control Points"
            l_Parent_0.core_game.gamemode_description.Text = "Control Points to drain enemy Reinforcements"
        elseif l_values_0.gamemode.Value == "push" then
            l_Parent_0.core_game.gamemode_title.Text = "Territory Push"
            l_Parent_0.core_game.gamemode_description.Text = "Control all 5 Points by capturing them sequentially"
        elseif l_values_0.gamemode.Value == "assault" then
            l_Parent_0.core_game.gamemode_title.Text = "Assault"
            l_Parent_0.core_game.gamemode_description.Text = ""
            if l_values_0.gamemode_specific.attacking_team.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and true or (l_values_0.gamemode_specific.attacking_team.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and true or false) then
                l_Parent_0.core_game.gamemode_title.Text = "Assault - Attacking"
                l_Parent_0.core_game.gamemode_description.Text = "Capture 3 Objectives sequentially"
            else
                l_Parent_0.core_game.gamemode_title.Text = "Assault - Defending"
                l_Parent_0.core_game.gamemode_description.Text = "Drain enemy Reinforcements and prevent capture of Objectives"
            end;
        elseif l_values_0.gamemode.Value == "train" then
            l_Parent_0.core_game.gamemode_title.Text = "Armoured Train"
            l_Parent_0.core_game.gamemode_description.Text = ""
            if l_values_0.gamemode_specific.attacking_team.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and true or (l_values_0.gamemode_specific.attacking_team.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and true or false) then
                l_Parent_0.core_game.gamemode_title.Text = "Armoured Train - Train Side"
                l_Parent_0.core_game.gamemode_description.Text = "Capture Control Points to drain enemy Reinforcements. Defend the Armoured Train."
            else
                l_Parent_0.core_game.gamemode_title.Text = "Armoured Train - Opposing Side"
                l_Parent_0.core_game.gamemode_description.Text = "Capture Control Points or destroy the Armoured Train to drain enemy Reinforcements"
            end;
        elseif l_values_0.gamemode.Value == "truce" then
            l_Parent_0.core_game.gamemode_title.Text = "Truce Decision"
            l_Parent_0.core_game.gamemode_description.Text = "Vote to an end of this Campaign"
        elseif l_values_0.gamemode.Value == "laststand" then
            l_Parent_0.core_game.gamemode_title.Text = "Last Stand"
            l_Parent_0.core_game.gamemode_description.Text = ""
            if l_values_0.gamemode_specific.attacking_team.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and true or (l_values_0.gamemode_specific.attacking_team.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and true or false) then
                l_Parent_0.core_game.gamemode_title.Text = "Last Stand - Attacking"
                l_Parent_0.core_game.gamemode_description.Text = "Breach the Stronghold and eliminate the remaining enemies"
            else
                l_Parent_0.core_game.gamemode_title.Text = "Last Stand - Defending"
                l_Parent_0.core_game.gamemode_description.Text = "Hold out until rescue arrives"
            end;
        else
            if l_values_0.gamemode.Value ~= "infection" then
                return;
            end;
            l_Parent_0.core_game.gamemode_title.Text = "???"
            l_Parent_0.core_game.gamemode_description.Text = "Something horrible is coming"
        end;
        if workspace.serverStuff.modifier.Value == "" or workspace.serverStuff.modifier.Value == "none" then
            l_Parent_0.core_game.gamemode_modifier.Text = "Standard Operation"
        else
            l_Parent_0.core_game.gamemode_modifier.Text = "Abnormality: " .. (workspace.serverStuff.modifier.Value == "fogofwar" and "Cave Fog" or (workspace.serverStuff.modifier.Value == "heavyrocks" and "Hard Rocks" or (workspace.serverStuff.modifier.Value == "shockspawns" and "Elite Reinforcement" or (workspace.serverStuff.modifier.Value == "conscriptlantern" and "Lantern Shortage" or ""))))
        end;
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_label, TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_title, TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_description, TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_modifier, TweenInfo.new(0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 1
        }):Play()
        if l_LocalPlayer_0.Character == nil or (l_LocalPlayer_0.Character.Parent == nil or not l_LocalPlayer_0.Character:FindFirstChild("HumanoidRootPart")) then
            repeat
                game:GetService("RunService").RenderStepped:Wait()
            until l_LocalPlayer_0.Character ~= nil and (l_LocalPlayer_0.Character.Parent ~= nil and not l_LocalPlayer_0.Character:FindFirstChild("HumanoidRootPart"));
        end;
        local l_Position_0 = l_LocalPlayer_0.Character.HumanoidRootPart.Position
        task.wait(1)
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_label, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 0
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_title, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.1), {
            ["TextTransparency"] = 0
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_description, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2), {
            ["TextTransparency"] = 0
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_modifier, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.3), {
            ["TextTransparency"] = 0
        }):Play()
        l_Parent_0.core_game.gamemode_title.Visible = true
        l_Parent_0.core_game.gamemode_description.Visible = true
        l_Parent_0.core_game.gamemode_label.Visible = true
        l_Parent_0.core_game.gamemode_modifier.Visible = true
        task.wait(3)
        repeat
            game:GetService("RunService").RenderStepped:Wait()
        until l_LocalPlayer_0.Character == nil or (l_LocalPlayer_0.Character.Parent == nil or (not l_LocalPlayer_0.Character:FindFirstChild("HumanoidRootPart") or (l_LocalPlayer_0.Character.Humanoid.Health <= 0 or (l_LocalPlayer_0.Character.HumanoidRootPart.Position - l_Position_0).Magnitude >= 4)));
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_label, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_title, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_description, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.4), {
            ["TextTransparency"] = 1
        }):Play()
        game:GetService("TweenService"):Create(l_Parent_0.core_game.gamemode_modifier, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.6), {
            ["TextTransparency"] = 1
        }):Play()
        task.wait(2)
        l_Parent_0.core_game.gamemode_title.Visible = false
        l_Parent_0.core_game.gamemode_description.Visible = false
        l_Parent_0.core_game.gamemode_label.Visible = false
        l_Parent_0.core_game.gamemode_modifier.Visible = false
    end;
end;
local function v_u_139(p136) --[[ Line: 1406 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): l_LocalPlayer_0 ]]
    local l_TextColor3_0 = l_Parent_0.playerlist.empireteam.TextColor3
    local v137
    if p136.Team == game.Teams["Royal Nation"] then
        l_TextColor3_0 = l_Parent_0.playerlist.nationteam.TextColor3
        v137 = "nation"
    else
        v137 = "empire"
    end;
    local v138 = l_Parent_0.playerlist.ex:Clone()
    v138.Name = "b" .. p136.Name
    if p136 == l_LocalPlayer_0 then
        v138.Name = "a" .. p136.Name
        v138.bg.ImageColor3 = l_TextColor3_0
        v138.rankbg.ImageColor3 = l_TextColor3_0
        v138.classbg.ImageColor3 = l_TextColor3_0
    end;
    v138.playername.Text = p136.Name
    v138.Visible = true
    if v137 == "empire" then
        v138.Parent = l_Parent_0.playerlist.empirelist
    else
        v138.Parent = l_Parent_0.playerlist.royallist
    end;
end;
local function v_u_143() --[[ Line: 1445 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): v_u_139 ]]
    for _, v140 in ipairs(l_Parent_0.playerlist.empirelist:GetChildren()) do
        if v140:IsA("Frame") then
            v140:Destroy()
        end;
    end;
    for _, v141 in ipairs(l_Parent_0.playerlist.royallist:GetChildren()) do
        if v141:IsA("Frame") then
            v141:Destroy()
        end;
    end;
    for _, v142 in ipairs(game.Players:GetPlayers()) do
        v_u_139(v142)
    end;
end;
_G.get_settings = function(p144) --[[ Line: 1462 ]]
    --[[ Upvalues: (copy 1): v_u_7 ]]
    local v145 = v_u_7.settings:FindFirstChild(p144)
    local v146
    if v145 then
        v146 = v145.Value
    else
        v146 = false
    end;
    return v146;
end;
local l_music_0 = workspace.music
local function v_u_151(p147, p148) --[[ Line: 1473 ]]
    --[[ Upvalues: (copy 1): l_music_0, (copy 2): v_u_2, (copy 3): l_RenderStepped_0 ]]
    if _G.get_settings("mutemusic") == true then
        l_music_0:Stop()
        l_music_0.musicchange:Stop()
    else
        local v149 = l_music_0
        local l_musicchange_0 = l_music_0.musicchange
        if v149.IsPlaying == true then
            v149 = l_music_0.musicchange
            l_musicchange_0 = l_music_0
        end;
        l_musicchange_0.Looped = false
        if p148 == true then
            v149.Looped = true
        else
            v149.Looped = false
        end;
        if p147 ~= "stop" then
            v149.SoundId = p147.SoundId
            v149.Volume = p147.Volume
            v149:Play()
        end;
        local l_Volume_0 = l_musicchange_0.Volume
        local v150 = tick()
        while _G.get_settings("mutemusic") ~= true do
            l_musicchange_0.Volume = v_u_2:lerp(l_Volume_0, 0, (tick() - v150) / 2)
            l_RenderStepped_0:wait()
            if tick() - v150 > 2 then
                return;
            end;
        end;
        l_music_0:Stop()
        l_music_0.musicchange:Stop()
    end;
end;
local v_u_152 = nil
local v_u_153 = 0
workspace.menus.ServersRoom.servers_guy.Humanoid:LoadAnimation(game.ReplicatedStorage.animations.npcs.radioguy):Play(0, 1, 0.5)
local l_appearancerig_0 = workspace.menus.AppearanceRoom.appearancerig
local v_u_154 = 0
l_cosmeticsframe_0.rotateleft.MouseButton1Click:Connect(function() --[[ Line: 1529 ]]
    --[[ Upvalues: (copy 1): v_u_21, (ref 2): v_u_154 ]]
    v_u_21()
    v_u_154 = v_u_154 - 22.5
end)
l_cosmeticsframe_0.rotateright.MouseButton1Click:Connect(function() --[[ Line: 1534 ]]
    --[[ Upvalues: (copy 1): v_u_21, (ref 2): v_u_154 ]]
    v_u_21()
    v_u_154 = v_u_154 + 22.5
end)
local v155 = l_appearancerig_0.Humanoid:LoadAnimation(game.ReplicatedStorage.animations.menu.nation_none)
v155.Priority = Enum.AnimationPriority.Idle
v155:Play(0, 1, 0.5)
local v_u_156 = l_appearancerig_0.Humanoid:LoadAnimation(game.ReplicatedStorage.animations.npcs.helmet_inspect)
local v_u_157 = l_appearancerig_0.Humanoid:LoadAnimation(game.ReplicatedStorage.animations.npcs.accessory_inspect)
local l_loadout_menu_0 = l_Parent_0.loadout_menu
local l_purchase_item_0 = l_loadout_menu_0.purchase_item
local v158 = v_u_154
local v_u_159 = v_u_135
local v_u_160 = v83
local v_u_161 = nil
local v_u_162 = ""
local v_u_163 = nil
local v_u_164 = 0
for _, v_u_165 in ipairs(l_Parent_0.loadout_menu.menubuttons:GetChildren()) do
    if v_u_165:IsA("ImageButton") then
        v_u_165.MouseButton1Click:Connect(function() --[[ Line: 1558 ]]
            --[[ Upvalues: (ref 1): v_u_20, (copy 2): v_u_165, (copy 3): v_u_21, (copy 4): l_Parent_0, (ref 5): v_u_58, (ref 6): v_u_153, (ref 7): v_u_152, (ref 8): v_u_163, (ref 9): v_u_161, (copy 10): l_LocalPlayer_0, (ref 11): v_u_84, (ref 12): v_u_160, (copy 13): l_purchase_item_0, (ref 14): v_u_162, (copy 15): l_CurrentCamera_0, (copy 16): v_u_55 ]]
            if v_u_20 ~= "" then
                if v_u_165.ImageColor3 ~= Color3.new(1, 1, 1) then
                    v_u_21()
                    for _, v166 in ipairs(l_Parent_0.loadout_menu.menubuttons:GetChildren()) do
                        if v166:IsA("ImageButton") then
                            v166.ImageColor3 = Color3.new(0, 0, 0)
                            l_Parent_0.loadout_menu:FindFirstChild(v166.Name).Visible = false
                        end;
                    end;
                    v_u_165.ImageColor3 = Color3.new(1, 1, 1)
                    l_Parent_0.loadout_menu:FindFirstChild(v_u_165.Name).Visible = true
                    l_Parent_0.loadout_menu.toplabel.Text = v_u_165.title.Value
                    _G.cam_menu_at = v_u_165.Name
                    v_u_58 = tick()
                    if v_u_165.Name == "settingsframe" then
                        if tick() - v_u_153 >= 300 then
                            v_u_153 = tick()
                            local l_settings_guy_0 = workspace.menus.SettingsRoom.settings_guy
                            local v167 = game.ReplicatedStorage.animations.npcs:FindFirstChild("engineer" .. math.random(1, 4))
                            if v_u_152 then
                                v_u_152:Destroy()
                            end;
                            v_u_152 = l_settings_guy_0.Humanoid:LoadAnimation(v167)
                            v_u_152:Play(0, 1, 0.5)
                        end;
                    elseif v_u_165.Name == "customisationframe" then
                        v_u_163("all")
                    elseif v_u_165.Name == "cosmeticsframe" then
                        v_u_161(l_LocalPlayer_0.Team)
                    elseif v_u_165.Name == "serversframe" then
                        v_u_84 = tick()
                        v_u_160()
                    end;
                    if l_purchase_item_0.Visible == true then
                        v_u_162 = ""
                        l_purchase_item_0.Visible = false
                    end;
                    l_CurrentCamera_0.CFrame = v_u_55[v_u_165.Name] - v_u_55[v_u_165.Name].lookVector * 3
                end;
            end;
        end)
    end;
end;
local l_settings_0 = l_Parent_0.loadout_menu.settingsframe.settings
local v168 = v_u_7.settings:GetChildren()
table.sort(v168, function(p169, p170) --[[ Line: 1627 ]]
    return p169.Name > p170.Name;
end)
for _, v_u_171 in ipairs(v168) do
    if v_u_171:FindFirstChild("text") and v_u_171:FindFirstChild("category") then
        local v172 = l_settings_0.ex:Clone()
        v172.Name = v_u_171.Name
        v172.label.Text = v_u_171.text.Value
        local v173 = l_settings_0:FindFirstChild(v_u_171.category.Value)
        if v173 then
            v172.LayoutOrder = v173.LayoutOrder + #l_settings_0:GetChildren()
        end;
        if v_u_171:FindFirstChild("desc") then
            v172.label.Text = v172.label.Text .. " (?)"
            v172.label.MouseEnter:Connect(function() --[[ Line: 1646 ]]
                --[[ Upvalues: (copy 1): v_u_26, (copy 2): l_Parent_0, (copy 3): v_u_171 ]]
                v_u_26()
                l_Parent_0.loadout_menu.helpmenupopup.Visible = true
                l_Parent_0.loadout_menu.helpmenupopup.frame.msg.Text = v_u_171.desc.Value
            end)
            v172.label.MouseLeave:Connect(function() --[[ Line: 1651 ]]
                --[[ Upvalues: (copy 1): l_Parent_0 ]]
                l_Parent_0.loadout_menu.helpmenupopup.Visible = false
            end)
        end;
        v172.Visible = true
        v172.Parent = l_settings_0
    end;
end;
local function v_u_180(p174, p175) --[[ Line: 1663 ]]
    --[[ Upvalues: (copy 1): l_Parent_0 ]]
    local v176 = Color3.new(1, 1, 1)
    local v177 = Color3.new(0, 0, 0)
    local v178
    if p175 == false then
        v177 = Color3.new(1, 1, 1)
        v176 = Color3.new(0, 0, 0)
        v178 = "OFF"
    else
        v178 = "ON"
    end;
    p174.settingsframe.label.Text = v178
    p174.settingsframe.label.TextColor3 = v177
    p174.settingsframe.ImageColor3 = v176
    if p174.Name == "hidechat" then
        l_Parent_0.core_game.customchat.Visible = not p175
        return;
    elseif p174.Name == "transpcrosshair" then
        l_Parent_0.core_game.genericcrosshair.icon.TextTransparency = p175 == true and 0.5 or 0
        return;
    elseif p174.Name == "lowgraphics" then
        game.Lighting.GlobalShadows = not p175
        if p175 == true then
            game.MaterialService:SetBaseMaterialOverride(Enum.Material.Basalt, "Blank")
            game.MaterialService:SetBaseMaterialOverride(Enum.Material.Rock, "Blank")
            game.ReplicatedStorage.effects.muzzle_flash.smoke_flash_heavy.FlipbookLayout = Enum.ParticleFlipbookLayout.None
            game.ReplicatedStorage.effects.muzzle_flash.smoke_flash_heavy.Texture = "rbxassetid://5513499509"
        else
            game.MaterialService:SetBaseMaterialOverride(Enum.Material.Basalt, "Basalt")
            game.MaterialService:SetBaseMaterialOverride(Enum.Material.Rock, "Rock")
            game.ReplicatedStorage.effects.muzzle_flash.smoke_flash_heavy.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
            game.ReplicatedStorage.effects.muzzle_flash.smoke_flash_heavy.Texture = "rbxassetid://13019995915"
        end;
    else
        if p174.Name == "disablebloodscreen" then
            for _, v179 in ipairs(l_Parent_0.core_game.splatters:GetChildren()) do
                if v179.Name ~= "ex" then
                    v179:Destroy()
                end;
            end;
        end;
        return;
    end;
end;
for _, v181 in ipairs(v168) do
    local v182 = l_settings_0:FindFirstChild(v181.Name)
    if v182 then
        v_u_180(v182, v181.Value)
    end;
end;
for _, v_u_183 in ipairs(l_settings_0:GetChildren()) do
    if v_u_183:IsA("ImageLabel") then
        v_u_183.settingsframe.MouseButton1Click:Connect(function() --[[ Line: 1733 ]]
            --[[ Upvalues: (copy 1): v_u_21, (copy 2): v_u_7, (copy 3): v_u_183, (copy 4): v_u_180, (copy 5): v_u_1 ]]
            v_u_21()
            local v184 = v_u_7.settings:FindFirstChild(v_u_183.Name)
            if v184 then
                v184.Value = not v184.Value
                v_u_180(v_u_183, v184.Value)
                v_u_1.game_handler:FireServer("change_setting", v184, v184.Value)
            end;
        end)
    end;
end;
_G.popupmsg = function(p_u_185, p_u_186, p_u_187) --[[ Line: 1748 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): s_Debris_0, (copy 3): v_u_2, (copy 4): l_RenderStepped_0 ]]
    spawn(function() --[[ Line: 1749 ]]
        --[[ Upvalues: (ref 1): l_Parent_0, (copy 2): p_u_185, (ref 3): s_Debris_0, (copy 4): p_u_187, (copy 5): p_u_186, (ref 6): v_u_2, (ref 7): l_RenderStepped_0 ]]
        if not l_Parent_0.core_game.textpopups:FindFirstChild(p_u_185) then
            local v188 = l_Parent_0.core_game.textpopups.ex:Clone()
            s_Debris_0:AddItem(v188, p_u_187 + 2)
            v188.Name = p_u_185
            v188.Text = p_u_186
            v188.Visible = true
            v188.Parent = l_Parent_0.core_game.textpopups
            local v189 = tick()
            local v190 = 0.5
            repeat
                v188.TextTransparency = v_u_2:lerp(1, 0, (tick() - v189) / v190)
                v188.TextStrokeTransparency = v188.TextTransparency
                l_RenderStepped_0:Wait()
            until v190 <= tick() - v189;
            v188.TextTransparency = 0
            v188.TextStrokeTransparency = v188.TextTransparency
            v_u_2:s_wait(p_u_187)
            local v191 = tick()
            local v192 = 0.5
            repeat
                v188.TextTransparency = v_u_2:lerp(0, 1, (tick() - v191) / v192)
                v188.TextStrokeTransparency = v188.TextTransparency
                l_RenderStepped_0:Wait()
            until v192 <= tick() - v191;
            v188:Destroy()
        end;
    end)
end;
local v_u_193 = require(game.ReplicatedStorage.shared.wardialogue)
local function v_u_198(p194) --[[ Line: 1791 ]]
    --[[ Upvalues: (copy 1): v_u_2, (copy 2): l_Parent_0, (copy 3): l_LocalPlayer_0, (copy 4): l_RenderStepped_0 ]]
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "dogtag",
        ["location"] = workspace,
        ["soundgroup"] = "none"
    }, true)
    if l_Parent_0.core_game.dogtags:FindFirstChild("dogtag") then
        l_Parent_0.core_game.dogtags.dogtag:Destroy()
    end;
    local v195 = l_Parent_0.core_game.dogtags.ex:Clone()
    v195.Name = "dogtag"
    if p194.forceside == nil then
        if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
            v195.tag.Image = "rbxassetid://131972806860871"
        end;
    elseif p194.forceside == "empire" then
        v195.tag.Image = "rbxassetid://131972806860871"
    end;
    v195.age.Text = "Age " .. p194.age
    v195.name.Text = p194.name
    v195.rank.Text = p194.rank
    v195.Visible = true
    v195.Parent = l_Parent_0.core_game.dogtags
    local v196 = tick()
    while v195 and v195:FindFirstChild("flash") do
        if v195.flash.ImageTransparency < 1 then
            v195.flash.Size = v195.flash.Size + UDim2.new(0, 2, 0, 2)
            v195.flash.ImageTransparency = v195.flash.ImageTransparency + 0.05
        end;
        v_u_2:s_wait(0.03)
        if tick() - v196 >= 5 then
            local v197 = tick()
            v195.Name = "fading"
            while v195 and v195:FindFirstChild("flash") do
                v195.age.TextTransparency = v_u_2:lerp(0, 1, (tick() - v197) / 2)
                v195.age.TextStrokeTransparency = v195.age.TextTransparency
                v195.name.TextTransparency = v195.age.TextTransparency
                v195.name.TextStrokeTransparency = v195.age.TextTransparency
                v195.rank.TextTransparency = v195.age.TextTransparency
                v195.rank.TextStrokeTransparency = v195.age.TextTransparency
                v195.tag.ImageTransparency = v195.age.TextTransparency
                l_RenderStepped_0:Wait()
                if tick() - v197 >= 2 then
                    v195:Destroy()
                    return;
                end;
            end;
            return;
        end;
    end;
end;
local v_u_199 = "soldat"
local v_u_200 = nil
for v201, _ in pairs(v_u_193) do
    v_u_193[v201] = v_u_2:randomiseTbl(v_u_193[v201])
end;
suffixMe = function(p202) --[[ Name: suffixMe ]] --[[ Line: 1868 ]]
    local v203 = p202 % 10
    local v204 = p202 % 100
    if v203 == 1 and v204 ~= 11 then
        return p202 .. "st";
    elseif v203 == 2 and v204 ~= 12 then
        return p202 .. "nd";
    elseif v203 == 3 and v204 ~= 13 then
        return p202 .. "rd";
    else
        return p202 .. "th";
    end;
end;
local v_u_205 = {
    ["none"] = {},
    ["conscriptlantern"] = {},
    ["shockspawns"] = {},
    ["fogofwar"] = {},
    ["heavyrocks"] = {}
}
local v_u_206 = {
    "(Camellia)",
    "(Glory)",
    "(Rose)",
    "(Hydrangea)",
    "(Acacia)",
    "(Daisy)",
    "(Belladonna)",
    "(Lily)",
    "(Marigold)",
    "(Violet)",
    "(Daffodil)",
    "(Daphne)",
    "(Ixora)",
    "(Jasmine)",
    "(Lilac)",
    "(Quince)",
    "(Aconitum)",
    "(Lavender)",
    "(Peony)",
    "(Nymphea)",
    "(Alchemilla)",
    "(Aconite)",
    "(Hyacinth)",
    "(Helenium)",
    "(Dahlia)",
    "(Poppy)",
    "(Primrose)",
    "(Erica)",
    "(Scilla)",
    "(Narcissus)",
    "(Lycoris)",
    "(Iris)",
    "(Aster)",
    "(Lobelia)",
    "(Cherry)",
    "(Magnolia)",
    "(Sunflower)",
    "(Dandelion)",
    "(Hibiscus)",
    "(Chrysanthemum)",
    "(Ghost)",
    "(Devastator)",
    "(Ravager)",
    "(Savant)",
    "(Reaper)",
    "(Executioner)",
    "(Viper)",
    "(Wolfhunter)",
    "(Acolyte)",
    "(Deathseeker)",
    "(Crusader)",
    "(Warlord)",
    "(Justice)",
    "(Unbreakable)",
    "(Headhunter)",
    "(Ace)",
    "(Savage)",
    "(Oathkeeper)",
    "(Tyrant)",
    "(Raven)",
    "(Fortune)",
    "(Phantom)",
    "(Vigilance)",
    "(Insurgence)",
    "(Dauntless)",
    "(Hammerhead)",
    "(Silencer)",
    "(Darkhorse)",
    "(Raider)",
    "(Nightmare)",
    "(Peacemaker)",
    "(Scorpion)",
    "(Widowmaker)",
    "(Atlas)",
    "(Heartbreaker)",
    "(Conquest)",
    "(Mortalis)",
    "(Voidbringer)",
    "(Cyclone)",
    "(Shadow)",
    "(Seraph)",
    "(Cherub)",
    "(Throne)",
    "(Dominion)",
    "(Virtue)",
    "(Power)",
    "(Prinicipality)",
    "(Archangel)",
    "(Angel)",
    "(Star)",
    "(Exodus)",
    "(Revelation)",
    "(Genesis)",
    "(Ezra)",
    "(Psalm)",
    "(Proverb)",
    "(Leviticus)",
    "(Solomon)",
    "(Lament)",
    "(Requiem)",
    "(Iron)",
    "(Gold)",
    "(Steel)",
    "(Bronze)",
    "(Silver)",
    "(Brass)",
    "(Copper)",
    "(Tin)",
    "(Soul)",
    "(Blood)",
    "(Cain)"
}
v_u_1.game_handler.OnClientEvent:Connect(function(p207, p208, p209, p210, p211) --[[ Line: 2005 ]]
    --[[ Upvalues: (copy 1): v_u_193, (copy 2): v_u_2, (copy 3): l_CurrentCamera_0, (copy 4): v_u_206, (copy 5): l_Parent_0, (copy 6): s_UserInputService_0, (copy 7): l_RenderStepped_0, (copy 8): l_LocalPlayer_0, (copy 9): v_u_64, (copy 10): v_u_26, (copy 11): v_u_63, (copy 12): v_u_205, (copy 13): v_u_21, (copy 14): s_Debris_0, (copy 15): v_u_1, (copy 16): l_values_0, (copy 17): s_GamepadService_0, (ref 18): v_u_17, (copy 19): v_u_15, (copy 20): v_u_10, (ref 21): v_u_57, (copy 22): v_u_56, (ref 23): v_u_159, (copy 24): v_u_198, (copy 25): l_purchase_item_0, (ref 26): v_u_162, (copy 27): l_loadout_menu_0, (ref 28): v_u_199, (ref 29): v_u_54, (ref 30): v_u_53, (ref 31): v_u_59, (copy 32): v_u_123, (copy 33): v_u_106, (copy 34): v_u_115, (copy 35): v_u_143, (copy 36): v_u_151, (ref 37): v_u_200 ]]
    if p207 == "hitmarker" then
        _G.flash_hitmarker(p208)
        return;
    elseif p207 == "warmap_refresh_dialogue" then
        for v212, _ in pairs(v_u_193) do
            v_u_193[v212] = v_u_2:randomiseTbl(v_u_193[v212])
        end;
        return;
    elseif p207 == "endpose_go" then
        if l_CurrentCamera_0:FindFirstChild("cc") then
            l_CurrentCamera_0.cc.Saturation = 0
        end;
        local v213 = suffixMe(p209) .. " Infantry Regiment."
        if p208 == "empire" and p210 then
            v213 = suffixMe(p209) .. " " .. v_u_206[p210] .. " Battalion."
        end;
        l_Parent_0.remembertext.Text = "\'Remember the fallen.\'\n" .. v213
        if p208 == "empire" then
            game.Lighting.endposesat.TintColor = Color3.fromRGB(255, 235, 203)
        else
            game.Lighting.endposesat.TintColor = Color3.fromRGB(244, 255, 255)
        end;
        game.Lighting.endposesat.Enabled = true
        l_Parent_0.core_game.deathscreen.Visible = false
        l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
        _G.fadetoblack = tick()
        s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
        l_CurrentCamera_0.FieldOfView = 40
        l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
        l_CurrentCamera_0.CFrame = CFrame.new(-974.428955, -51.8881607, -368.655762, 0.0156116411, -0.0467474945, 0.998784781, 5.82076609e-11, 0.998906612, 0.0467531867, -0.999878228, -0.000729893916, 0.0155945681)
    elseif p207 == "warmap_refresh" then
        for _, v214 in ipairs(l_Parent_0.core_game.splatters:GetChildren()) do
            if v214.Name ~= "ex" then
                v214:Destroy()
            end;
        end;
        local v215 = workspace.WarRoom:FindFirstChild("mainMap")
        if v215 and (v215:FindFirstChild("modes") and v215:FindFirstChild("mapname")) then
            l_Parent_0.warmap.modeside.Visible = false
            l_Parent_0.warmap.gameresults.Visible = false
            l_Parent_0.warmap.modeside.campaignname.Text = v215.mapname.Value .. " Campaign"
            for _, v216 in ipairs(l_Parent_0.warmap.nodes:GetChildren()) do
                if v216.Name ~= "ex" then
                    v216:Destroy()
                end;
            end;
            local v217 = 0
            local v218 = 0
            for _, v_u_219 in ipairs(v215.completed:GetChildren()) do
                if v_u_219.Name == "empire" or v_u_219.Name == "nation" then
                    if v_u_219.Name == "empire" then
                        v218 = v218 + 1
                    end;
                    if v_u_219.Name == "nation" then
                        v217 = v217 + 1
                    end;
                    if v_u_219:FindFirstChild("piece_placed") == nil then
                        local l_warmapempire_0 = game.ReplicatedStorage.misc.warmapempire
                        if v_u_219.Name == "nation" then
                            l_warmapempire_0 = game.ReplicatedStorage.misc.warmapnation
                        end;
                        local v_u_220 = l_warmapempire_0:Clone()
                        v_u_220.Name = "piece_placed"
                        delay(math.random(10, 30) / 10, function() --[[ Line: 2096 ]]
                            --[[ Upvalues: (copy 1): v_u_219, (ref 2): v_u_220, (ref 3): l_RenderStepped_0, (ref 4): v_u_2 ]]
                            local v221 = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
                            local v222 = v_u_219.CFrame * CFrame.new(0, math.random(15, 30) / 10, 0) * v221
                            v_u_220:PivotTo(v222)
                            local v223 = v_u_219.CFrame * v221
                            v_u_220.Parent = v_u_219
                            local v224 = tick()
                            local v225 = 0.4
                            repeat
                                v_u_220:PivotTo(v222:Lerp(v223, 1 - math.cos((tick() - v224) / v225 * 3.141592653589793 * 0.5)))
                                l_RenderStepped_0:Wait()
                            until v225 < tick() - v224;
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "warpiece",
                                ["location"] = workspace,
                                ["pitchvariation"] = 0.1,
                                ["soundgroup"] = "none"
                            }, true)
                            v_u_220:PivotTo(v223)
                            local v226 = math.random(8, 15)
                            if math.random(1, 2) == 1 then
                                v226 = -v226
                            end;
                            local v227 = CFrame.Angles(math.rad(v226), 0, 0) * CFrame.new(0, 0.1, 0)
                            local v228 = tick()
                            local v229 = 0.15
                            repeat
                                v_u_220:PivotTo(v223:Lerp(v223 * v227, (tick() - v228) / v229))
                                l_RenderStepped_0:Wait()
                            until v229 < tick() - v228;
                            v_u_220:PivotTo(v223 * v227)
                            local v230 = tick()
                            local v231 = 0.3
                            repeat
                                v_u_220:PivotTo((v223 * v227):Lerp(v223, (math.sin((tick() - v230) / v231 * 3.141592653589793 * 0.5))))
                                l_RenderStepped_0:Wait()
                            until v231 < tick() - v230;
                            v_u_220:PivotTo(v223)
                        end)
                    end;
                end;
            end;
            local v_u_232 = l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and "empire" or "nation"
            local v_u_233 = nil
            local v_u_234 = nil
            for _, v_u_235 in ipairs(v215.modes:GetChildren()) do
                local v_u_236 = l_Parent_0.warmap.nodes.ex:Clone()
                local v_u_237 = string.sub(v_u_235.Name, 1, -2)
                if v_u_237 == "truce" or v_u_237 == "laststand" then
                    v_u_234 = v_u_237
                    v_u_236.ImageColor3 = Color3.fromRGB(157, 100, 182)
                    if workspace.serverStuff.teamvoting.Value == game.Teams["Golden Empire"] then
                        v_u_236.ImageColor3 = Color3.fromRGB(255, 255, 127)
                    end;
                    if v_u_237 == "truce" then
                        v_u_236.ImageColor3 = Color3.fromRGB(150, 150, 150)
                    end;
                    v_u_236.votes.TextColor3 = v_u_236.ImageColor3
                    v_u_236.voted.ImageColor3 = v_u_236.ImageColor3
                    v_u_236.voted.Visible = true
                end;
                local v238 = string.len(v_u_235.Name)
                local v_u_239 = tonumber((string.sub(v_u_235.Name, v238, v238 + 1)))
                local v240 = v_u_64[v_u_237]
                if v240 then
                    v_u_236.Image = "rbxassetid://" .. v240[1]
                    v_u_236.icon.Image = "rbxassetid://" .. v240[2]
                    v_u_236.voted.Image = "rbxassetid://" .. v240[3]
                end;
                v_u_236.Name = v_u_235.Name
                v_u_236.Visible = true
                v_u_236.Parent = l_Parent_0.warmap.nodes
                v_u_236.MouseEnter:Connect(function() --[[ Line: 2221 ]]
                    --[[ Upvalues: (ref 1): v_u_26, (copy 2): v_u_236, (ref 3): v_u_234, (ref 4): l_Parent_0, (ref 5): l_LocalPlayer_0, (copy 6): v_u_237, (ref 7): v_u_233, (ref 8): v_u_63, (copy 9): v_u_235, (ref 10): v_u_193, (ref 11): v_u_232, (copy 12): v_u_239, (ref 13): v_u_205, (ref 14): l_RenderStepped_0, (ref 15): v_u_2 ]]
                    v_u_26()
                    v_u_236.selected.Visible = true
                    if v_u_234 == nil then
                        l_Parent_0.warmap.gameresults.Visible = true
                    end;
                    if workspace.serverStuff.warmapvoted:FindFirstChild(l_LocalPlayer_0.Name) == nil and (l_LocalPlayer_0.Team == workspace.serverStuff.teamvoting.Value and (v_u_237 ~= "laststand" and v_u_237 ~= "truce")) then
                        v_u_236.clickvote.Visible = true
                    end;
                    if v_u_233 == v_u_236 then
                        return;
                    else
                        v_u_233 = v_u_236
                        l_Parent_0.warmap.modeside.Visible = true
                        l_Parent_0.warmap.modeside.gamemode.Text = v_u_63[v_u_237]
                        l_Parent_0.warmap.modeside.extra.Text = ""
                        l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.new(1, 1, 1)
                        local v241 = ""
                        if v_u_237 == "assault" then
                            l_Parent_0.warmap.modeside.extra.Text = "Royal Nation Attacking"
                            l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.fromRGB(157, 100, 182)
                            if v_u_235:FindFirstChild("forceattacker") and v_u_235.forceattacker.Value == "empire" then
                                l_Parent_0.warmap.modeside.extra.Text = "Golden Empire Attacking"
                                l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.fromRGB(255, 255, 127)
                            end;
                            v241 = v_u_193["assault_" .. v_u_232 .. "_attack"][v_u_239]
                            if v_u_235:FindFirstChild("forceattacker") and (v_u_235.forceattacker.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] or v_u_235.forceattacker.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) then
                                v241 = v_u_193["assault_" .. v_u_232 .. "_defend"][v_u_239]
                            end;
                        elseif v_u_237 == "control" then
                            l_Parent_0.warmap.modeside.extra.Text = "Three Compounds Scouted"
                            v241 = v_u_193["control_" .. v_u_232][v_u_239]
                            if v_u_235:FindFirstChild("compounds") then
                                if v_u_235.compounds.Value == 1 then
                                    l_Parent_0.warmap.modeside.extra.Text = "Singular Compound Spotted"
                                elseif v_u_235.compounds.Value == 2 then
                                    l_Parent_0.warmap.modeside.extra.Text = "Two Compounds Sighted"
                                end;
                            end;
                        elseif v_u_237 == "push" then
                            v241 = v_u_193["push_" .. v_u_232][v_u_239]
                            l_Parent_0.warmap.modeside.extra.Text = "Tug of War"
                        elseif v_u_237 == "laststand" then
                            l_Parent_0.warmap.modeside.extra.Text = "Royal Nation Stronghold"
                            l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.fromRGB(157, 100, 182)
                            if v_u_235:FindFirstChild("forceattacker") and v_u_235.forceattacker.Value == "nation" then
                                l_Parent_0.warmap.modeside.extra.Text = "Golden Empire Stronghold"
                                l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.fromRGB(255, 255, 127)
                            end;
                            v241 = v_u_193["laststand_" .. v_u_232 .. "_attack"][v_u_239]
                            if v_u_235:FindFirstChild("forceattacker") and (v_u_235.forceattacker.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] or v_u_235.forceattacker.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) then
                                v241 = v_u_193["laststand_" .. v_u_232 .. "_defend"][v_u_239]
                            end;
                        elseif v_u_237 == "truce" then
                            l_Parent_0.warmap.modeside.extra.Text = "End this Campaign"
                            v241 = v_u_193["truce_" .. v_u_232][v_u_239]
                        elseif v_u_237 == "infection" then
                            l_Parent_0.warmap.modeside.extra.Text = "???"
                            l_Parent_0.warmap.modeside.extra.TextColor3 = Color3.fromRGB(157, 100, 182)
                            v241 = v_u_193.infection[1]
                        end;
                        local v242 = not v_u_235:FindFirstChild("modifier") and "none" or v_u_235.modifier.Value
                        if v_u_205[v242] then
                            l_Parent_0.warmap.modeside.mutators.Image = v_u_205[v242][1]
                            l_Parent_0.warmap.modeside.mutatortitle.Text = v_u_205[v242][2]
                            l_Parent_0.warmap.modeside.mutatordesc.Text = v_u_205[v242][3]
                        end;
                        l_Parent_0.warmap.modeside.desc.Text = ""
                        local v243 = not l_Parent_0.warmap.modeside.Selectable
                        l_Parent_0.warmap.modeside.Selectable = v243
                        if v_u_236:FindFirstChild("visited") == nil then
                            l_RenderStepped_0:Wait()
                            local l_StringValue_0 = Instance.new("StringValue")
                            l_StringValue_0.Name = "visited"
                            l_StringValue_0.Parent = v_u_236
                            local v244 = 0
                            for v245 = 1, string.len(v241) do
                                if l_Parent_0.warmap.modeside.Selectable ~= v243 or l_Parent_0.warmap.Visible == false then
                                    return;
                                end;
                                if tick() - v244 >= 0.1 then
                                    v244 = tick()
                                    v_u_2:soundHandler({
                                        ["directory"] = {},
                                        ["soundfile"] = "typewriter" .. math.random(1, 4),
                                        ["location"] = workspace,
                                        ["soundgroup"] = "none"
                                    }, true)
                                end;
                                l_Parent_0.warmap.modeside.desc.Text = string.sub(v241, 1, v245)
                                v_u_2:s_wait(0.01)
                                if l_Parent_0.warmap.modeside.Selectable ~= v243 or l_Parent_0.warmap.Visible == false then
                                    return;
                                end;
                            end;
                        else
                            l_Parent_0.warmap.modeside.desc.Text = v241
                        end;
                    end;
                end)
                v_u_236.MouseLeave:Connect(function() --[[ Line: 2383 ]]
                    --[[ Upvalues: (copy 1): v_u_236 ]]
                    v_u_236.selected.Visible = false
                    v_u_236.clickvote.Visible = false
                end)
                v_u_236.MouseButton1Click:Connect(function() --[[ Line: 2389 ]]
                    --[[ Upvalues: (copy 1): v_u_237, (ref 2): l_LocalPlayer_0, (copy 3): v_u_236, (ref 4): v_u_21, (ref 5): v_u_2, (ref 6): s_Debris_0, (ref 7): v_u_1, (copy 8): v_u_235 ]]
                    if v_u_237 ~= "laststand" and v_u_237 ~= "truce" then
                        if workspace.serverStuff.warmapvoted:FindFirstChild(l_LocalPlayer_0.Name) == nil and l_LocalPlayer_0.Team == workspace.serverStuff.teamvoting.Value then
                            v_u_236.clickvote.Visible = false
                            v_u_21()
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "voted",
                                ["location"] = workspace,
                                ["soundgroup"] = "none"
                            }, true)
                            local l_StringValue_1 = Instance.new("StringValue")
                            s_Debris_0:AddItem(l_StringValue_1, 1)
                            l_StringValue_1.Name = l_LocalPlayer_0.Name
                            l_StringValue_1.Parent = workspace.serverStuff.warmapvoted
                            v_u_236.ImageColor3 = Color3.fromRGB(157, 100, 182)
                            if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                                v_u_236.ImageColor3 = Color3.fromRGB(255, 255, 127)
                            end;
                            v_u_236.votes.TextColor3 = v_u_236.ImageColor3
                            v_u_236.voted.ImageColor3 = v_u_236.ImageColor3
                            v_u_236.voted.Visible = true
                            v_u_1.game_handler:FireServer("warmap_vote", v_u_235)
                            spawn(function() --[[ Line: 2426 ]]
                                --[[ Upvalues: (ref 1): v_u_236, (ref 2): s_Debris_0, (ref 3): v_u_2 ]]
                                local v246 = v_u_236.voted:Clone()
                                v246.ZIndex = 10
                                s_Debris_0:AddItem(v246, 1)
                                v246.Name = "flash"
                                v246.ImageTransparency = 0
                                v246.Visible = true
                                v246.Parent = v_u_236
                                for _ = 1, 15 do
                                    v246.ImageTransparency = v246.ImageTransparency + 0.06
                                    v246.Size = v246.Size + UDim2.new(0, 4, 0, 4)
                                    v_u_2:s_wait(0.03)
                                end;
                                if v246 then
                                    v246:Destroy()
                                end;
                            end)
                        end;
                    end;
                end)
                spawn(function() --[[ Line: 2453 ]]
                    --[[ Upvalues: (copy 1): v_u_236, (ref 2): v_u_2, (ref 3): l_RenderStepped_0 ]]
                    local v247 = tick()
                    repeat
                        v_u_236.ImageTransparency = v_u_2:lerp(1, 0, (tick() - v247) / 1)
                        v_u_236.icon.ImageTransparency = v_u_236.ImageTransparency
                        l_RenderStepped_0:Wait()
                    until tick() - v247 >= 1;
                    if v_u_236 then
                        v_u_236.ImageTransparency = 0
                    end;
                end)
            end;
            if v_u_234 == nil then
                l_Parent_0.warmap.gameresults.empirewins.Text = "Successes - " .. v218
                l_Parent_0.warmap.gameresults.nationwins.Text = v217 .. " - Successes"
            end;
            l_Parent_0.warmap.modeside.teamvoting.Text = "Golden Empire Voting"
            l_Parent_0.warmap.modeside.teamvoting.TextColor3 = Color3.fromRGB(255, 255, 127)
            l_Parent_0.warmap.modeside.voting_iconA.Image = "rbxassetid://17512646697"
            l_Parent_0.warmap.modeside.voting_iconA.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
            l_Parent_0.warmap.modeside.voting_iconB.Image = l_Parent_0.warmap.modeside.voting_iconA.Image
            l_Parent_0.warmap.modeside.voting_iconB.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
            if workspace.serverStuff.teamvoting.Value == game.Teams["Royal Nation"] then
                l_Parent_0.warmap.modeside.teamvoting.Text = "Royal Nation Voting"
                l_Parent_0.warmap.modeside.teamvoting.TextColor3 = Color3.fromRGB(107, 50, 124)
                l_Parent_0.warmap.modeside.voting_iconA.Image = "rbxassetid://17512646559"
                l_Parent_0.warmap.modeside.voting_iconA.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
                l_Parent_0.warmap.modeside.voting_iconB.Image = l_Parent_0.warmap.modeside.voting_iconA.Image
                l_Parent_0.warmap.modeside.voting_iconB.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
            end;
            if v_u_234 == "laststand" then
                l_Parent_0.warmap.modeside.teamvoting.Text = "Golden Empire Victory"
                if workspace.serverStuff.teamvoting.Value == game.Teams["Royal Nation"] then
                    l_Parent_0.warmap.modeside.teamvoting.Text = "Royal Nation Victory"
                end;
            elseif v_u_234 == "truce" then
                l_Parent_0.warmap.modeside.teamvoting.Text = "Truce Decision"
                l_Parent_0.warmap.modeside.teamvoting.TextColor3 = Color3.fromRGB(255, 255, 255)
                l_Parent_0.warmap.modeside.voting_iconA.Image = "rbxassetid://17519619825"
                l_Parent_0.warmap.modeside.voting_iconA.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
                l_Parent_0.warmap.modeside.voting_iconB.Image = l_Parent_0.warmap.modeside.voting_iconA.Image
                l_Parent_0.warmap.modeside.voting_iconB.ImageColor3 = l_Parent_0.warmap.modeside.teamvoting.TextColor3
            end;
        end;
        l_Parent_0.core_game.crosshair.Visible = false
        l_Parent_0.core_game.genericcrosshair.Visible = false
        l_Parent_0.dot_crosshair.Visible = false
        if l_values_0.gamestate.Value == "warmap" and l_Parent_0.loadout_menu.Visible == false then
            l_Parent_0.core_game.deathscreen.Visible = false
            s_UserInputService_0.MouseIconEnabled = true
            s_GamepadService_0:EnableGamepadCursor(l_Parent_0.warmap)
            l_Parent_0.core_game.fadetoblack.BackgroundTransparency = 0
            _G.fadetoblack = tick()
            v_u_17 = tick()
            s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
            l_CurrentCamera_0.FieldOfView = 40
            l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
            l_CurrentCamera_0.CFrame = v_u_15
            return;
        end;
    elseif p207 == "load_skin" then
        if _G.get_settings("toggleskins") == true then
            return;
        end;
        if p208 and (p208[1] and (p208[2] and (p208[3] and p208[4]))) then
            v_u_10.apply_skin(p208[1], p208[2], p208[3], p208[4])
            return;
        end;
    elseif p207 == "check_hairs" then
        if _G.get_settings("disablehairs") ~= true then
            return;
        end;
        if p208 then
            for _, v248 in ipairs(p208:GetChildren()) do
                if v248:IsA("Accessory") then
                    v248:Destroy()
                end;
            end;
            return;
        end;
    else
        if p207 == "alert" then
            if v_u_57 == true then
                table.insert(v_u_56, { p208, p209 })
            else
                v_u_159(p208, p209)
            end;
        end;
        if p207 == "gamemode_intro" then
            make_gamemode_intro()
            return;
        end;
        if p207 == "trap_triggered" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "traptriggered" .. math.random(1, 2),
                ["location"] = workspace,
                ["soundgroup"] = "none"
            }, true)
            return;
        end;
        if p207 == "dogtag_got" then
            v_u_198(p208)
            return;
        end;
        if p207 == "global_alert" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "global_message",
                ["location"] = workspace,
                ["soundgroup"] = "none"
            }, true)
            if p209 and p209 == true then
                l_Parent_0.globalmessage.maintext.servertext.Text = "Private Server Message from Bandit Group"
                l_Parent_0.globalmessage.maintext.servertext.TextColor3 = Color3.fromRGB(50, 70, 200)
            else
                l_Parent_0.globalmessage.maintext.servertext.Text = "Server Message from Solace Coalition"
                l_Parent_0.globalmessage.maintext.servertext.TextColor3 = Color3.fromRGB(50, 200, 70)
            end;
            l_Parent_0.globalmessage.maintext.Text = p208
            l_Parent_0.globalmessage.Visible = true
            local v249 = tick()
            repeat
                l_RenderStepped_0:Wait()
            until tick() - v249 >= 15;
            l_Parent_0.globalmessage.Visible = false
            return;
        end;
        if p207 == "print_console" then
            print(p208)
            return;
        end;
        if p207 == "purchase_reset" then
            if p208 == true then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "unlock",
                    ["location"] = l_CurrentCamera_0
                }, true)
            end;
            l_purchase_item_0.purchase.Text = "Acquire"
            if v_u_162 == p209 then
                l_purchase_item_0.Visible = false
            end;
            local v250 = l_loadout_menu_0.customisationframe.scroll:FindFirstChild(p209)
            if v250 and v250:FindFirstChild("weaponlocked") then
                v250.weaponlocked.Visible = false
            end;
            if v_u_199 == p209 then
                l_loadout_menu_0.customisationframe.class_locked_warning.Visible = false
            end;
            for _, v251 in ipairs(l_loadout_menu_0.cosmeticsframe.scroll:GetChildren()) do
                if p209 == v251.Name .. "_accessory" and (v251:FindFirstChild("skinlocked") and v251:FindFirstChild("valuse")) then
                    v251.skinlocked.Visible = false
                end;
            end;
            return;
        end;
        if p207 == "killcam" then
            if _G.killcam_outline then
                _G.killcam_outline:Destroy()
                _G.killcam_outline = nil
            end;
            v_u_54 = l_CurrentCamera_0.CFrame.Position + Vector3.new(0, 1, 0)
            v_u_53 = tick()
            v_u_59 = p208
            l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
            if p208 then
                _G.killcam_outline = game.ReplicatedStorage.misc.killcam_highlight:Clone()
                s_Debris_0:AddItem(_G.killcam_outline, 8)
                _G.killcam_outline.Parent = p208.Parent
                return;
            end;
        else
            if p207 == "endofround" then
                v_u_123(p208, p209, p210, p211)
                return;
            end;
            if p207 == "truceendofround" then
                v_u_106(p208, p209, p210, p211)
                return;
            end;
            if p207 == "endofgame" then
                v_u_115(p208, p209, p210, p211)
                return;
            end;
            if p207 == "refresh_playerlist" then
                v_u_143()
                return;
            end;
            if p207 == "music" then
                if _G.get_settings("mutemusic") ~= true then
                    v_u_151(p208)
                end;
            end;
            if p207 == "stop_music" then
                v_u_151("stop")
                return;
            end;
            if p207 == "looped_music" or (p207 == "tension_music" or p207 == "eor_music") then
                if _G.get_settings("mutemusic") ~= true then
                    if p207 == "looped_music" then
                        if p209 and string.sub(p209, 1, 3) == "set" then
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = p209 .. "_eorstart",
                                ["location"] = workspace.notarget
                            }, true)
                        end;
                    elseif p207 == "tension_music" or p207 == "eor_music" then
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "tension_start",
                            ["location"] = workspace.notarget
                        }, true)
                    end;
                    v_u_151(p208, true)
                end;
            end;
            if p207 == "advance_track" then
                if _G.get_settings("mutemusic") ~= true then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = p208,
                        ["location"] = workspace.notarget
                    }, true)
                end;
            end;
            if p207 == "team_theme" then
                local v252 = game.ReplicatedStorage.sound_library.music:FindFirstChild((l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and "empire" or "nation") .. "_theme" .. p208)
                if v252 then
                    v_u_151(v252)
                    return;
                end;
            else
                if p207 == "server_message" then
                    _G.popupmsg(p208.core, p208.msg, p208.dur)
                    return;
                end;
                if p207 == "send_surrendermessage" then
                    _G.popupmsg("surrenderoption", "You are given the option to Surrender for Medal Gain with [" .. (_G.using_controller == true and "X while Un-Equipped" or _G.get_keybinds("swapteam").Name) .. "]", 3)
                    return;
                end;
                if p207 == "enlistmentmessage" then
                    _G.popupmsg("enlistmentoption", "You are given the opportunity to Enlist to the opposing side for increased Medal Gain with [" .. (_G.using_controller == true and "X while Un-Equipped" or _G.get_keybinds("swapteam").Name) .. "]", 8)
                    return;
                end;
                if p207 == "variantunlock" then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "unlock",
                        ["location"] = workspace.notarget
                    }, true)
                    _G.popupmsg("variantunlock", p208 .. " Modification Acquired.", 3)
                    v_u_200()
                    return;
                end;
                if p207 == "refresh_menu" then
                    v_u_200()
                    return;
                end;
                if p207 == "set_spawn" or p207 == "exfilset_spawn" then
                    l_LocalPlayer_0.Character.HumanoidRootPart.Anchored = true
                    for _ = 1, 10 do
                        l_LocalPlayer_0.Character.HumanoidRootPart.Anchored = true
                        if p208 and (l_LocalPlayer_0.Character and (l_LocalPlayer_0.Character:FindFirstChild("HumanoidRootPart") and (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") and l_LocalPlayer_0.Character.Humanoid.Health > 0))) then
                            l_LocalPlayer_0.Character.HumanoidRootPart.CFrame = p208.CFrame
                        end;
                        if p207 == "exfilset_spawn" and p209 then
                            l_CurrentCamera_0.CFrame = CFrame.new(l_CurrentCamera_0.CFrame.Position, p209)
                        end;
                        l_RenderStepped_0:Wait()
                    end;
                    l_LocalPlayer_0.Character.HumanoidRootPart.Anchored = true
                    if p207 == "set_spawn" then
                        v_u_2:s_wait(0.25)
                    end;
                    l_LocalPlayer_0.Character.HumanoidRootPart.Anchored = false
                end;
            end;
        end;
    end;
end)
local v_u_253 = 1
local v_u_254 = 1
local function v264(p255, p256, p257) --[[ Line: 2819 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (ref 2): v_u_253, (ref 3): v_u_254, (copy 4): v_u_5 ]]
    local v258 = #l_Parent_0.core_game.customchat:GetChildren()
    local v259 = v258 - 2 >= 65 and l_Parent_0.core_game.customchat:FindFirstChild(v_u_253)
    if v259 then
        v259:Destroy()
        v_u_253 = v_u_253 + 1
    end;
    if v258 <= 5 then
        l_Parent_0.core_game.customchat.CanvasPosition = Vector2.new(0, 99999)
    end;
    local v260 = l_Parent_0.core_game.customchat.msg:Clone()
    v260.Name = v_u_254
    v260.LayoutOrder = v_u_254
    local v261 = "#FFD454"
    local v262
    if p256 == "server" or (p256 == "npc" or not (p256:IsA("Player") and (p256:FindFirstChild("playerstats") and p256.playerstats:FindFirstChild("rank")))) then
        v262 = ""
    else
        local l_Value_0 = p256.playerstats.rank.Value
        if p256.Team == game.Teams["Royal Nation"] then
            v262 = v_u_5.ranks_nation[l_Value_0]
            v261 = "#7F16AF"
        else
            v262 = v_u_5.ranks_empire[l_Value_0]
        end;
    end;
    local v263 = string.gsub(string.gsub(string.gsub(p255, "&amp;gt;", ">"), "&amp;lt;", "<"), "&amp;amp;", "&")
    if p256 == "server" or p256 == "npc" then
        v260.playername.Text = "<b><font color=\"#C8001C\">SERVER</font></b>: "
        v260.playertext.Text = "SERVER: " .. v263
    elseif p257 and p257 == true then
        v260.playername.Text = "<b><font color=\"" .. v261 .. "\">" .. "(TEAM) " .. v262 .. " " .. p256.Name .. "</font></b>: "
        v260.playertext.Text = "(TEAM) " .. v262 .. " " .. p256.Name .. ": " .. v263
    else
        v260.playername.Text = "<b><font color=\"" .. v261 .. "\">" .. v262 .. " " .. p256.Name .. "</font></b>: "
        v260.playertext.Text = v262 .. " " .. p256.Name .. ": " .. v263
    end;
    if p256 == "npc" and (p257 and (p257:FindFirstChild("rank") and p257:FindFirstChild("name"))) then
        v260.playername.Text = "<b><font color=\"" .. ((p257.rank.Value == "BDT" or p257.rank.Value == "MAR") and "#FF2511" or (p257.rank.Value == "CON" and "#EDEADE" or "#7F16AF")) .. "\">" .. p257.rank.Value .. " " .. p257.name.Value .. "</font></b>: "
        v260.playertext.Text = p257.rank.Value .. " " .. p257.name.Value .. ": " .. v263
    end;
    v260.Visible = true
    v260.Parent = l_Parent_0.core_game.customchat
    v_u_254 = v_u_254 + 1
end;
_G.chat_handler = v264
v_u_1.chat_handler.OnClientEvent:Connect(v264)
l_LocalPlayer_0.CharacterAdded:Connect(function() --[[ Line: 2901 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0 ]]
    game:GetService("SoundService").mainSoundGroup.comp.Enabled = false
    game:GetService("SoundService").maskSoundGroup.comp.Enabled = false
    if l_CurrentCamera_0:FindFirstChild("blur") then
        l_CurrentCamera_0.blur.Size = 0
    end;
end)
local v_u_265 = false
local v_u_266 = 0
l_loadout_menu_0.xpbar.internal.Size = UDim2.new(v_u_7.duty.Value / v_u_5.level_req, 0, 1, 0)
l_loadout_menu_0.medalcount.Text = v_u_7.medals.Value
v_u_7.medals.Changed:Connect(function(_) --[[ Line: 2917 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0, (copy 2): v_u_7 ]]
    l_loadout_menu_0.medalcount.Text = v_u_7.medals.Value
end)
v_u_7.duty.Changed:Connect(function(_) --[[ Line: 2920 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0, (copy 2): v_u_7, (copy 3): v_u_5 ]]
    l_loadout_menu_0.xpbar.internal.Size = UDim2.new(v_u_7.duty.Value / v_u_5.level_req, 0, 1, 0)
end)
v_u_7.time_played.Changed:Connect(function(_) --[[ Line: 2926 ]]
    --[[ Upvalues: (copy 1): v_u_7, (copy 2): l_loadout_menu_0 ]]
    if v_u_7.time_played.Value < 60 then
        l_loadout_menu_0.timeplayed.Text = v_u_7.time_played.Value .. " minutes"
    else
        l_loadout_menu_0.timeplayed.Text = tostring(math.ceil(v_u_7.time_played.Value / 60 * 10) / 10) .. " hours"
    end;
end)
l_loadout_menu_0.timeplayed.Text = tostring(math.ceil(v_u_7.time_played.Value / 60 * 10) / 10) .. " hours"
l_loadout_menu_0.customisationframe.inv_weight_popup.MouseEnter:Connect(function() --[[ Line: 2936 ]]
    --[[ Upvalues: (copy 1): v_u_26, (copy 2): l_loadout_menu_0 ]]
    v_u_26()
    l_loadout_menu_0.customisationframe.weight_popup.Visible = true
end)
l_loadout_menu_0.customisationframe.inv_weight_popup.MouseLeave:Connect(function() --[[ Line: 2940 ]]
    --[[ Upvalues: (copy 1): v_u_26, (copy 2): l_loadout_menu_0 ]]
    v_u_26()
    l_loadout_menu_0.customisationframe.weight_popup.Visible = false
end)
l_loadout_menu_0.medalprogress.MouseEnter:Connect(function() --[[ Line: 2945 ]]
    --[[ Upvalues: (copy 1): v_u_26, (copy 2): l_loadout_menu_0 ]]
    v_u_26()
    l_loadout_menu_0.medalprogresspopup.Visible = true
end)
l_loadout_menu_0.medalprogress.MouseLeave:Connect(function() --[[ Line: 2949 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0 ]]
    l_loadout_menu_0.medalprogresspopup.Visible = false
end)
local v_u_267 = nil
local function _(p268, p269, p270) --[[ Line: 2956 ]]
    p268.bar.inner.Size = UDim2.new(math.clamp(p269 / p270, 0, 1), 0, 1, 0)
end;
local l_statslower_0 = l_loadout_menu_0.customisationframe.statsside.statslower
local v_u_271 = false
local v_u_272 = nil
local v_u_273 = nil
local v_u_274 = workspace.notarget:WaitForChild("idle_spawn_rig", 10)
v_u_274.Name = math.random(1, 1000000)
local v_u_275 = true
local v_u_276 = false
_G.fadetoblack = 0
local v_u_277 = false
local function v_u_282(p278, p279, p280) --[[ Line: 2977 ]]
    --[[ Upvalues: (ref 1): v_u_277, (ref 2): v_u_162, (copy 3): l_purchase_item_0, (copy 4): v_u_7 ]]
    if p280 == true then
        v_u_277 = true
    else
        v_u_277 = false
    end;
    v_u_162 = p278
    local v281 = v_u_277 == true and "10 Medals" or "a Medal"
    l_purchase_item_0.label.Text = "Unlock " .. p279 .. "?"
    l_purchase_item_0.labellower.Text = "Requires " .. v281 .. " (You have " .. v_u_7.medals.Value .. ")"
    if v_u_277 == true and v_u_7.specials.accessoryticket.Value == true then
        l_purchase_item_0.labellower.Text = "Free Unlock (One Time Only)"
    end;
    l_purchase_item_0.Visible = true
end;
l_purchase_item_0.MouseButton1Click:Connect(function() --[[ Line: 2998 ]]
    --[[ Upvalues: (copy 1): l_purchase_item_0, (ref 2): v_u_162, (copy 3): v_u_21, (ref 4): v_u_277, (copy 5): v_u_7, (copy 6): v_u_1 ]]
    if l_purchase_item_0.purchase.Text == "Acquire" and v_u_162 ~= "" then
        v_u_21()
        if (v_u_277 == true and v_u_7.specials.accessoryticket.Value == true and 0 or (v_u_277 == true and 10 or 1)) > v_u_7.medals.Value then
            l_purchase_item_0.purchase.Text = "Not Enough Medals"
            delay(2, function() --[[ Line: 3012 ]]
                --[[ Upvalues: (ref 1): l_purchase_item_0 ]]
                l_purchase_item_0.purchase.Text = "Acquire"
            end)
        else
            l_purchase_item_0.purchase.Text = "Working.."
            v_u_1.game_handler:FireServer("purchase_item", v_u_162)
        end;
    else
        return;
    end;
end)
local function v_u_287(p283, p284) --[[ Line: 3023 ]]
    --[[ Upvalues: (ref 1): v_u_276, (ref 2): v_u_275 ]]
    v_u_276 = true
    p284:WaitForChild("Head", 1000)
    p284:WaitForChild("Torso", 1000)
    p284:WaitForChild("Left Arm", 1000)
    p284:WaitForChild("Right Arm", 1000)
    p284:WaitForChild("Left Leg", 1000)
    p284:WaitForChild("Right Leg", 1000)
    for _, v285 in ipairs(p283:GetChildren()) do
        if v285:IsA("Accessory") then
            if v285.AccessoryType == Enum.AccessoryType.Hair then
                v285.Parent = p284
                if v285:FindFirstChild("Handle") and v285.Handle:FindFirstChild("AccessoryWeld") then
                    v285.Handle.AccessoryWeld.Part1 = p284.Head
                end;
                v285.Handle.CanCollide = false
                v285.Handle.CanQuery = false
                local v286 = v285.Handle:FindFirstChild("Mesh") or v285.Handle:FindFirstChild("SpecialMesh")
                if v286 then
                    v286.TextureId = "rbxassetid://10442685772"
                end;
            end;
        elseif p284:FindFirstChild(v285.Name) and v285:IsA("BasePart") then
            p284:FindFirstChild(v285.Name).Color = v285.Color
        end;
        if v285:IsA("Hat") or (v285:IsA("ParticleEmitter") or (v285:IsA("Fire") or v285:IsA("Sparkles"))) then
            v285:Destroy()
        end;
    end;
    local l_StringValue_2 = Instance.new("StringValue")
    l_StringValue_2.Name = "appearance_loaded"
    l_StringValue_2.Parent = p284
    v_u_275 = true
    p283:Destroy()
end;
local function v_u_304(p288, p289, p290) --[[ Line: 3082 ]]
    --[[ Upvalues: (copy 1): l_RenderStepped_0, (copy 2): v_u_10, (copy 3): v_u_5, (copy 4): l_cosmeticsframe_0, (copy 5): v_u_7 ]]
    repeat
        l_RenderStepped_0:Wait()
    until p288:FindFirstChild("appearance_loaded");
    local v291 = game.ReplicatedStorage.outfits.nation:FindFirstChild(p289.Name)
    local v292
    if p290 == game.Teams["Golden Empire"] then
        v291 = game.ReplicatedStorage.outfits.empire:FindFirstChild(p289.Name)
        v292 = "empire"
    else
        v292 = "nation"
    end;
    if p288:FindFirstChild("shirt") then
        p288.shirt:Destroy()
    end;
    if p288:FindFirstChild("pants") then
        p288.pants:Destroy()
    end;
    if p288:FindFirstChild("extralift") then
        p288.extralift:Destroy()
    end;
    if p288:FindFirstChild("helmet") then
        p288.helmet:Destroy()
    end;
    if p288:FindFirstChild("accessories") then
        p288.accessories:Destroy()
    end;
    if v291 then
        v291.shirt:Clone().Parent = p288
        v291.pants:Clone().Parent = p288
    end;
    local v293 = 1
    local v294 = v291:FindFirstChild("helmet")
    local l_Value_1 = p289.helmet.Value
    if p290 == game.Teams["Golden Empire"] then
        l_Value_1 = p289.helmetempire.Value
    end;
    for _, v295 in ipairs(p288:GetChildren()) do
        if v295.Name == "Torso" or (v295.Name == "Right Arm" or (v295.Name == "Left Arm" or (v295.Name == "Right Leg" or (v295.Name == "Left Leg" or v295.Name == "Head")))) then
            v295.Transparency = 0
        end;
    end;
    local l_Model_0 = Instance.new("Model")
    l_Model_0.Name = "accessories"
    l_Model_0.Parent = p288
    local v296 = p289:FindFirstChild("accessoryone")
    if v296 and v296.Value ~= "none" then
        v_u_10:add_accessory(p288, v296.Value, p290)
    end;
    local v297 = p289:FindFirstChild("accessorytwo")
    if v297 and v297.Value ~= "none" then
        v_u_10:add_accessory(p288, v297.Value, p290)
    end;
    if l_Value_1 ~= "default" and l_Value_1 ~= "none" then
        v294 = game.ReplicatedStorage.outfits.hats:FindFirstChild(l_Value_1 .. "_" .. v292)
    end;
    local v298 = (l_Value_1 == "none" or v294:FindFirstChild("showhair")) and 0 or v293
    for _, v299 in ipairs(p288:GetChildren()) do
        if v299:IsA("Accessory") and v299:FindFirstChild("Handle") then
            v299.Handle.Transparency = v298
            local v300 = v299.Handle:FindFirstChild("Mesh") or v299.Handle:FindFirstChild("SpecialMesh")
            if v300 then
                v300.TextureId = "rbxassetid://10442685772"
                v300.VertexColor = Vector3.new(unpack(v_u_5.hair_colours[p289.haircolour.Value]))
            end;
        end;
        if v299:IsA("BasePart") and (v299.Name == "Head" or (v299.Name == "Torso" or (v299.Name == "Left Arm" or (v299.Name == "Left Leg" or (v299.Name == "Right Arm" or v299.Name == "Right Leg"))))) then
            v299.Color = Color3.new(unpack(v_u_5.skin_colours[p289.skincolour.Value]))
        end;
    end;
    l_cosmeticsframe_0.hat_x.Visible = false
    l_cosmeticsframe_0.hat_y.Visible = false
    l_cosmeticsframe_0.hat_z.Visible = false
    if l_Value_1 ~= "default" and l_Value_1 ~= "none" then
        l_cosmeticsframe_0.hat_x.Visible = true
        l_cosmeticsframe_0.hat_y.Visible = true
        l_cosmeticsframe_0.hat_z.Visible = true
    end;
    if v294 then
        local v301 = v294:Clone()
        v301.Name = "helmet"
        v301.Transparency = 1
        local l_Weld_0 = Instance.new("Weld")
        l_Weld_0.Part1 = v301
        l_Weld_0.Part0 = p288.Head
        l_Weld_0.Parent = v301
        local v302 = l_Value_1 ~= "default" and l_Value_1 ~= "none" and v301:FindFirstChild("hatweld")
        if v302 then
            v302.C1 = CFrame.new(v_u_7.hat_x.Value - 0.5, v_u_7.hat_y.Value - 0.5, v_u_7.hat_z.Value - 0.5)
        end;
        if l_Value_1 == "none" and v301:FindFirstChild("knock") then
            v301.knock:Destroy()
        end;
        v301.Parent = p288
        if v291:FindFirstChild("extralift") and (l_Value_1 == "default" or l_Value_1 == "none") then
            local v303 = v291.extralift:Clone()
            v303.Transparency = 1
            local l_Weld_1 = Instance.new("Weld")
            l_Weld_1.Part1 = v303
            l_Weld_1.Part0 = p288.Head
            l_Weld_1.Parent = v303
            v303.Parent = p288
            if l_Value_1 == "none" and (v292 == "empire" and (p289.Name == "lancer" and v303)) then
                v303:Destroy()
            end;
        end;
    end;
end;
spawn(function() --[[ Line: 3234 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0, (copy 2): l_RenderStepped_0, (copy 3): v_u_287, (copy 4): v_u_274, (copy 5): l_appearancerig_0 ]]
    repeat
        local v305 = game.ReplicatedStorage.cached_playeroutfits:FindFirstChild(l_LocalPlayer_0.Name)
        l_RenderStepped_0:Wait()
    until v305 ~= nil;
    if v305 then
        v_u_287(v305:Clone(), v_u_274)
        v_u_287(v305:Clone(), l_appearancerig_0)
    end;
end)
spawn(function() --[[ Line: 3247 ]]
    --[[ Upvalues: (copy 1): v_u_274, (copy 2): l_RenderStepped_0, (ref 3): v_u_275, (copy 4): l_LocalPlayer_0, (ref 5): v_u_271, (ref 6): v_u_273, (ref 7): v_u_163 ]]
    v_u_274:WaitForChild("Humanoid", 1000)
    repeat
        l_RenderStepped_0:Wait()
    until v_u_275 == true;
    for _, v306 in ipairs(v_u_274:GetChildren()) do
        if v306:IsA("Shirt") or (v306:IsA("Pants") or v306:IsA("ShirtGraphic")) then
            v306:Destroy()
        end;
        if v306:IsA("CharacterMesh") then
            v306:Destroy()
        end;
    end;
    v_u_274:WaitForChild("Torso", 1000).Anchored = false
    v_u_274:WaitForChild("Left Arm", 1000).Anchored = false
    v_u_274:WaitForChild("Right Arm", 1000).Anchored = false
    v_u_274:WaitForChild("Left Leg", 1000).Anchored = false
    v_u_274:WaitForChild("Right Leg", 1000).Anchored = false
    v_u_274:WaitForChild("Head", 1000).Anchored = false
    local v307 = game.ReplicatedStorage.outfits.torso:Clone()
    v307.lantern:Destroy()
    v307.nationlantern:Destroy()
    v307.conscriptlantern:Destroy()
    v307.Name = "torsobelt"
    local l_Weld_2 = Instance.new("Weld")
    l_Weld_2.Part0 = v307
    l_Weld_2.Part1 = v_u_274:WaitForChild("Torso", 1000)
    l_Weld_2.Parent = v307
    v307.Parent = v_u_274
    v307.dogtags.empiretag.tag.srf.label.Text = l_LocalPlayer_0.Name
    v307.dogtags.nationtag.tag.srf.label.Text = l_LocalPlayer_0.Name
    v_u_271 = true
    v_u_273 = l_LocalPlayer_0.Team
    v_u_163("all")
end)
local l_previewpoint_0 = workspace.previewpoint
local l_previewviewport_0 = l_Parent_0.loadout_menu.customisationframe.previewviewport
local l_Camera_0 = Instance.new("Camera")
l_Camera_0.FieldOfView = 40
l_Camera_0.CFrame = l_previewpoint_0.CFrame * CFrame.new(0, 0, 6)
l_previewviewport_0.CurrentCamera = l_Camera_0
local function _() --[[ Line: 3305 ]]
    --[[ Upvalues: (copy 1): l_previewviewport_0 ]]
    l_previewviewport_0.Visible = false
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
        l_previewviewport_0.worldmodel.preview:Destroy()
    end;
end;
local function v_u_312(p308, p309) --[[ Line: 3312 ]]
    --[[ Upvalues: (copy 1): l_previewviewport_0, (copy 2): v_u_10, (copy 3): l_previewpoint_0, (copy 4): v_u_8 ]]
    l_previewviewport_0.Visible = false
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
        l_previewviewport_0.worldmodel.preview:Destroy()
    end;
    local v310 = game.ReplicatedStorage.weapon_models:FindFirstChild(p308)
    if v310 then
        if p309 and v_u_10.model_replacements[p308] == true then
            v310 = game.ReplicatedStorage.weapon_skins:FindFirstChild(p308):FindFirstChild(p309)
        end;
        if v310 == nil then
            return;
        end;
        local v311 = v310:Clone()
        if v311.PrimaryPart == nil then
            v311.PrimaryPart = v311:FindFirstChild("hitbox")
        end;
        if p309 and v_u_10.model_replacements[p308] ~= true then
            v_u_10.apply_skin(v311, p308, p309)
        end;
        if v311.PrimaryPart then
            l_previewviewport_0.Visible = true
            v311.PrimaryPart.Anchored = true
            v311.Name = "preview"
            v311:PivotTo(l_previewpoint_0.CFrame)
            if v_u_8[p308] then
                if v_u_8[p308].size == 2 then
                    v311:PivotTo(l_previewpoint_0.CFrame * CFrame.new(0, 0, -1))
                elseif v_u_8[p308].size == 1 then
                    v311:PivotTo(l_previewpoint_0.CFrame * CFrame.new(0, 0, 3))
                end;
            end;
            if p308 == "cavsword" then
                v311:PivotTo(l_previewpoint_0.CFrame * CFrame.new(0, 0, -3.5))
            end;
            if p308 == "club" or p308 == "pick" then
                v311:PivotTo(l_previewpoint_0.CFrame * CFrame.new(0, 0, 1))
            end;
            v311.Parent = l_previewviewport_0.worldmodel
        end;
    end;
end;
local function v_u_330(p313) --[[ Line: 3370 ]]
    --[[ Upvalues: (ref 1): v_u_271, (copy 2): v_u_274, (copy 3): l_previewviewport_0, (copy 4): v_u_7, (ref 5): v_u_199, (copy 6): v_u_8, (copy 7): l_LocalPlayer_0, (copy 8): v_u_10, (copy 9): v_u_304, (ref 10): v_u_272 ]]
    if v_u_271 == false then
        return;
    elseif v_u_274 ~= nil and v_u_274:FindFirstChild("Torso") ~= nil then
        l_previewviewport_0.Visible = false
        if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
            l_previewviewport_0.worldmodel.preview:Destroy()
        end;
        local v314 = v_u_274:FindFirstChild("torsobelt")
        local v315 = v_u_7.class_setup:FindFirstChild(v_u_199)
        if p313 == "all" then
            if v_u_274:FindFirstChild("fakeknife") then
                v_u_274.fakeknife:Destroy()
            end;
            if v_u_274:FindFirstChild("morticianrig") then
                v_u_274.morticianrig:Destroy()
            end;
            v314.nationbelt.leather.Transparency = 1
            v314.nationbelt.metal.Transparency = 1
            v314.nationbelt.metaltwo.Transparency = 1
            v314.dogtags.nationtag.Transparency = 1
            v314.dogtags.nationtag.nationtag.Transparency = 1
            v314.dogtags.nationtag.tag.srf.Enabled = false
            v314.empirebelt.leather.Transparency = 1
            v314.empirebelt.metal.Transparency = 1
            v314.dogtags.empiretag.Transparency = 1
            v314.dogtags.empiretag.empiretag.Transparency = 1
            v314.dogtags.empiretag.tag.srf.Enabled = false
            local l_knife_0 = game.ReplicatedStorage.weapon_models.knife
            local l_knife_1 = v_u_8.knife
            if v315.melee.Value == "club" then
                l_knife_0 = game.ReplicatedStorage.weapon_models.club
                l_knife_1 = v_u_8.club
            end;
            if v315.melee.Value == "machete" then
                l_knife_0 = game.ReplicatedStorage.weapon_models.machete
                l_knife_1 = v_u_8.machete
            end;
            if v315.melee.Value == "bottle" then
                l_knife_0 = game.ReplicatedStorage.weapon_models.bottle
                l_knife_1 = v_u_8.bottle
            end;
            if l_knife_1.alt_team_model and l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                l_knife_0 = game.ReplicatedStorage.weapon_models:FindFirstChild(l_knife_1.alt_team_model)
            end;
            if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
                v314.nationbelt.leather.Transparency = 0
                v314.nationbelt.metal.Transparency = 0
                v314.nationbelt.metaltwo.Transparency = 0
                v314.dogtags.nationtag.Transparency = 0
                v314.dogtags.nationtag.nationtag.Transparency = 0
                v314.dogtags.nationtag.tag.srf.Enabled = true
            else
                v314.empirebelt.leather.Transparency = 0
                v314.empirebelt.metal.Transparency = 0
                v314.dogtags.empiretag.Transparency = 0
                v314.dogtags.empiretag.empiretag.Transparency = 0
                v314.dogtags.empiretag.tag.srf.Enabled = true
            end;
            if v_u_7.skins.knife2.Value ~= "stock" and v315.melee.Value == "knife" then
                l_knife_0 = game.ReplicatedStorage.weapon_skins.knife:FindFirstChild(v_u_7.skins.knife2.Value)
            end;
            if v315.melee.Value == "knife" then
                if v_u_274:FindFirstChild("sheath_knife") then
                    v_u_274.sheath_knife:Destroy()
                end;
                v_u_10:add_sheath(v_u_274, "knife", v_u_7.skins.knife2.Value, nil, l_LocalPlayer_0.Team)
            end;
            if v_u_7.skins.club2.Value ~= "stock" and v315.melee.Value == "club" then
                l_knife_0 = game.ReplicatedStorage.weapon_skins.club:FindFirstChild(v_u_7.skins.club2.Value)
            end;
            if v_u_274:FindFirstChild("sheath_cavsword") then
                v_u_274.sheath_cavsword:Destroy()
            end;
            if v_u_274:FindFirstChild("sheath_cavsword") then
                v_u_274.sheath_cavsword:Destroy()
            end;
            local v316 = l_knife_0:Clone()
            v316.Name = "fakeknife"
            local l_Weld_3 = Instance.new("Weld")
            l_Weld_3.Name = "knifesetup"
            l_Weld_3.Part0 = v_u_274.Torso
            l_Weld_3.Part1 = v316.hitbox
            l_Weld_3.C0 = l_knife_1.holsterc0
            l_Weld_3.C1 = l_knife_1.holsterc1
            l_Weld_3.Parent = v316
            v316.Parent = v_u_274
            if v_u_199 == "mortician" then
                local v317 = game.ReplicatedStorage.outfits.mortician:Clone()
                v317.Name = "morticianrig"
                local l_Weld_4 = Instance.new("Weld")
                l_Weld_4.Name = "mortsteup"
                l_Weld_4.Part0 = v_u_274.Torso
                l_Weld_4.Part1 = v317
                l_Weld_4.Parent = v317
                v317.Parent = v_u_274
            end;
        end;
        local l_empire_0 = game.ReplicatedStorage.outfits.empire
        if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
            l_empire_0 = game.ReplicatedStorage.outfits.nation
        end;
        v_u_304(v_u_274, v_u_7.cosmetic_setup:FindFirstChild(v_u_199), l_LocalPlayer_0.Team)
        l_empire_0:FindFirstChild(v_u_199)
        if p313 == "all" then
            if v_u_274:FindFirstChild("weppreview") then
                v_u_274.weppreview:Destroy()
            end;
            if v_u_274:FindFirstChild("holsterpreview") then
                v_u_274.holsterpreview:Destroy()
            end;
            if v_u_274.Torso:FindFirstChild("holsterpreview") then
                v_u_274.Torso:FindFirstChild("holsterpreview")
            end;
            if v_u_274["Right Arm"]:FindFirstChild("weppreview") then
                v_u_274["Right Arm"]:FindFirstChild("weppreview")
            end;
            if v_u_274["Left Arm"]:FindFirstChild("weppreview") then
                v_u_274["Left Arm"]:FindFirstChild("weppreview")
            end;
            local v318 = l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and "empire_" or "nation_"
            local l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "none"]
            local v319 = false
            for v320, l_variant_0 in ipairs({ v315.primary.Value, v315.secondary.Value }) do
                if l_variant_0 ~= "" then
                    local v322 = v_u_8[l_variant_0]
                    if v322 then
                        local l_size_0 = v322.size
                        local v323
                        if v322.variant == "" then
                            v323 = l_variant_0
                        else
                            local l_variant_0 = v322.variant
                            v323 = l_variant_0
                        end;
                        local v324 = v322.variant == "remington" and "dbgun" or v323
                        local v325 = (v322.variant == "steyr" or v322.variant == "saa") and 1 or (l_variant_0 == "walker" and 1 or l_size_0)
                        if v319 == false then
                            if v325 >= 2 then
                                l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "rifle"]
                                if v324 == "dbgun" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "db"]
                                elseif v324 == "henry" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "henry"]
                                elseif v324 == "lance" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "lance"]
                                elseif v324 == "crossbow" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "crossbow"]
                                end;
                            else
                                l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "pistol"]
                                if v324 == "cavsword" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "cavsword"]
                                elseif v324 == "vanguardshield" then
                                    l_menu_0 = game.ReplicatedStorage.animations.menu[v318 .. "shield"]
                                end;
                            end;
                        end;
                        local v326 = game.ReplicatedStorage.weapon_models:FindFirstChild(l_variant_0)
                        if v322.alt_team_model and l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                            v326 = game.ReplicatedStorage.weapon_models:FindFirstChild(v322.alt_team_model)
                        end;
                        local v327 = v_u_7.skins:FindFirstChild(l_variant_0 .. math.clamp(v320, 1, 2))
                        if v327 and (v327.Value ~= "stock" and v_u_10.model_replacements[l_variant_0] == true) then
                            v326 = game.ReplicatedStorage.weapon_skins:FindFirstChild(l_variant_0):FindFirstChild(v327.Value)
                        end;
                        local l_Right Arm_0 = v_u_274["Right Arm"]
                        if v322.lefthand == true then
                            l_Right Arm_0 = v_u_274["Left Arm"]
                        end;
                        local l_equipc0_0 = v322.equipc0
                        local l_equipc1_0 = v322.equipc1
                        local v328 = "weppreview"
                        if v319 == true then
                            if v320 == 2 then
                                l_equipc0_0 = v322.alt_holsterc0
                                l_equipc1_0 = v322.alt_holsterc1
                            else
                                l_equipc0_0 = v322.holsterc0
                                l_equipc1_0 = v322.holsterc1
                            end;
                            l_Right Arm_0 = v_u_274.Torso
                            v328 = "holsterpreview"
                        elseif v322.variant == "remington" then
                            l_equipc1_0 = l_equipc1_0 * CFrame.new(-1, 0.5, 0)
                        end;
                        local v329 = v326:Clone()
                        if v322.variant ~= "" then
                            v_u_10:modify_variant(v329, v322.variant)
                        end;
                        v329.Name = v328
                        local l_Motor6D_0 = Instance.new("Motor6D")
                        l_Motor6D_0.Name = v328
                        l_Motor6D_0.Part0 = l_Right Arm_0
                        l_Motor6D_0.Part1 = v329.hitbox
                        l_Motor6D_0.C0 = l_equipc0_0
                        l_Motor6D_0.C1 = l_equipc1_0
                        l_Motor6D_0.Parent = l_Right Arm_0
                        v329.Parent = v_u_274
                        if v327 and v327.Value ~= "stock" then
                            v_u_10.apply_skin(v329, l_variant_0, v327.Value)
                        end;
                        if v324 == "cavsword" and v_u_7.skins:FindFirstChild("cavsword" .. v320) then
                            v_u_10:add_sheath(v_u_274, "cavsword", v_u_7.skins["cavsword" .. v320].Value, v320, l_LocalPlayer_0.Team)
                        end;
                        v319 = true
                    end;
                end;
            end;
            if v_u_272 then
                v_u_272:Destroy()
            end;
            v_u_272 = v_u_274.Humanoid:LoadAnimation(l_menu_0)
            v_u_272:Play(0, 1, 0.25)
        end;
    end;
end;
local l_assist_hover_0 = l_loadout_menu_0.customisationframe.statsside.assist_hover
local l_stats_assist_0 = l_loadout_menu_0.customisationframe.statsside.stats_assist
local l_statsrange_0 = l_loadout_menu_0.customisationframe.statsside.statsrange
local l_masterylist_0 = l_loadout_menu_0.customisationframe.statsside.masterylist
local v_u_331 = nil
local function v_u_336(p332) --[[ Line: 3681 ]]
    --[[ Upvalues: (copy 1): v_u_7, (copy 2): l_masterylist_0 ]]
    if p332 ~= nil then
        local v333 = v_u_7.weapon_stats:FindFirstChild(p332)
        for _, v334 in ipairs(l_masterylist_0.statslist:GetChildren()) do
            if v334:IsA("TextLabel") then
                v334.Visible = false
            end;
        end;
        if v333 then
            l_masterylist_0.statslist.list1.Visible = true
            l_masterylist_0.statslist.list1.Text = "Murders: " .. v333.Value
            local v335 = v_u_7.weapon_stats:FindFirstChild(p332 .. "headshots")
            if v335 then
                l_masterylist_0.statslist.list2.Visible = true
                l_masterylist_0.statslist.list2.Text = "Heads Taken: " .. v335.Value
            end;
            if (p332 == "knife" or (p332 == "club" or (p332 == "bottle" or (p332 == "machete" or p332 == "cavsword")))) and (v_u_7.weapon_stats:FindFirstChild("nation_tags") and v_u_7.weapon_stats:FindFirstChild("empire_tags")) then
                l_masterylist_0.statslist.list2.Visible = true
                l_masterylist_0.statslist.list2.Text = "Nation Dog-Tags Taken: " .. v_u_7.weapon_stats.nation_tags.Value
                l_masterylist_0.statslist.list3.Visible = true
                l_masterylist_0.statslist.list3.Text = "Empire Dog-Tags Taken: " .. v_u_7.weapon_stats.empire_tags.Value
            end;
            if p332 == "firstaid" then
                l_masterylist_0.statslist.list1.Text = "Lives Saved: " .. v333.Value
            end;
            if p332 == "whistle" then
                l_masterylist_0.statslist.list1.Text = "Advance Orders Given: " .. v333.Value
                l_masterylist_0.statslist.list2.Visible = true
                l_masterylist_0.statslist.list2.Text = "Defend Orders Given: " .. v_u_7.weapon_stats.whistle_defend.Value
                l_masterylist_0.statslist.list3.Visible = true
                l_masterylist_0.statslist.list3.Text = "Focus Orders Given: " .. v_u_7.weapon_stats.whistle_focus.Value
            end;
            if p332 == "binocs" then
                l_masterylist_0.statslist.list1.Text = "Enemies Spotted: " .. v333.Value
                l_masterylist_0.statslist.list2.Visible = true
                l_masterylist_0.statslist.list2.Text = "Enemies Marked with Binoculars: " .. v_u_7.weapon_stats.binocs_manual.Value
                l_masterylist_0.statslist.list3.Visible = true
                l_masterylist_0.statslist.list3.Text = "Flare Murders: " .. v_u_7.weapon_stats.flare.Value
            end;
            if p332 == "soldat" then
                l_masterylist_0.statslist.list1.Text = "Ammunition given to Allies: " .. v333.Value
            end;
            if p332 == "mortician" then
                l_masterylist_0.statslist.list1.Text = "Syrettes given to Allies: " .. v333.Value
            end;
            if p332 == "vanguard" then
                l_masterylist_0.statslist.list1.Text = "Allies Rallied: " .. v333.Value
            end;
        end;
        if p332 == "jaegerkit" and v_u_7.weapon_stats:FindFirstChild("tinbomb") then
            l_masterylist_0.statslist.list1.Visible = true
            l_masterylist_0.statslist.list1.Text = "Mantraps Triggered: " .. v_u_7.weapon_stats.mantrap.Value
            l_masterylist_0.statslist.list2.Visible = true
            l_masterylist_0.statslist.list2.Text = "Tin Bomb Murders: " .. v_u_7.weapon_stats.tinbomb.Value
            l_masterylist_0.statslist.list3.Visible = true
            l_masterylist_0.statslist.list3.Text = "Gas Shell Murders: " .. v_u_7.weapon_stats.gastrap.Value
            l_masterylist_0.statslist.list4.Visible = true
            l_masterylist_0.statslist.list4.Text = "Dynamite Murders: " .. v_u_7.weapon_stats.dynamite.Value
            l_masterylist_0.statslist.list5.Visible = true
            l_masterylist_0.statslist.list5.Text = "Shotshell Murders: " .. v_u_7.weapon_stats.shotshell.Value
            l_masterylist_0.statslist.list6.Visible = true
            l_masterylist_0.statslist.list6.Text = "Lantern Lure Murders: " .. v_u_7.weapon_stats.lightlure.Value
        end;
        if p332 == "hammer" and v_u_7.weapon_stats:FindFirstChild("hammer_Barricade") then
            l_masterylist_0.statslist.list1.Visible = true
            l_masterylist_0.statslist.list1.Text = "Barricades Constructed: " .. v_u_7.weapon_stats.hammer_Barricade.Value
            l_masterylist_0.statslist.list3.Visible = true
            l_masterylist_0.statslist.list3.Text = "Palisades Constructed: " .. v_u_7.weapon_stats.hammer_Palisade.Value
            l_masterylist_0.statslist.list5.Visible = true
            l_masterylist_0.statslist.list5.Text = "Caches Constructed: " .. v_u_7.weapon_stats.hammer_Cache.Value
            l_masterylist_0.statslist.list2.Visible = true
            l_masterylist_0.statslist.list2.Text = "Barbed Wires Constructed: " .. v_u_7.weapon_stats["hammer_Barbed Wire"].Value
            l_masterylist_0.statslist.list4.Visible = true
            l_masterylist_0.statslist.list4.Text = "Sandbags Constructed: " .. v_u_7.weapon_stats.hammer_Sandbags.Value
            l_masterylist_0.statslist.list6.Visible = true
            l_masterylist_0.statslist.list6.Text = "Murders: " .. v_u_7.weapon_stats.hammer.Value
        end;
    end;
end;
local v_u_337 = true
l_assist_hover_0.MouseButton1Click:Connect(function() --[[ Line: 3791 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): l_previewviewport_0, (ref 3): v_u_337, (copy 4): l_stats_assist_0 ]]
    v_u_21()
    l_previewviewport_0.Visible = false
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
        l_previewviewport_0.worldmodel.preview:Destroy()
    end;
    v_u_337 = not v_u_337
    l_stats_assist_0.Visible = v_u_337
end)
local v_u_338 = { l_statsrange_0.rangestats, l_statsrange_0.handlingstats }
local v_u_339 = { "Damage Range Info", "Weapon Performance Info" }
local v_u_340 = 1
l_statsrange_0.nextpage.MouseButton1Click:Connect(function() --[[ Line: 3803 ]]
    --[[ Upvalues: (copy 1): l_statsrange_0, (copy 2): v_u_21, (ref 3): v_u_340, (copy 4): v_u_338, (copy 5): v_u_339 ]]
    if l_statsrange_0.Visible == true then
        v_u_21()
        v_u_340 = v_u_340 + 1
        if v_u_340 > #v_u_338 then
            v_u_340 = 1
        end;
        for _, v341 in ipairs(v_u_338) do
            v341.Visible = false
        end;
        l_statsrange_0.toptext.Text = v_u_339[v_u_340]
        v_u_338[v_u_340].Visible = true
    end;
end)
local v_u_342 = tick()
local v_u_343 = nil
local function v345(p_u_344) --[[ Line: 3825 ]]
    --[[ Upvalues: (copy 1): l_RenderStepped_0 ]]
    for _ = 1, 2 do
        p_u_344.MouseWheelForward:Connect(function() --[[ Line: 3827 ]]
            --[[ Upvalues: (copy 1): p_u_344, (ref 2): l_RenderStepped_0 ]]
            local l_CanvasPosition_0 = p_u_344.CanvasPosition
            l_RenderStepped_0:Wait()
            p_u_344.CanvasPosition = l_CanvasPosition_0 - Vector2.new(0, 4)
        end)
        p_u_344.MouseWheelBackward:Connect(function() --[[ Line: 3833 ]]
            --[[ Upvalues: (copy 1): p_u_344, (ref 2): l_RenderStepped_0 ]]
            local l_CanvasPosition_1 = p_u_344.CanvasPosition
            l_RenderStepped_0:Wait()
            p_u_344.CanvasPosition = l_CanvasPosition_1 + Vector2.new(0, 4)
        end)
    end;
end;
v345(l_loadout_menu_0.customisationframe.statsside.descscroll)
v345(l_loadout_menu_0.customisationframe.statsside.perklore_lower.scroll)
v345(l_loadout_menu_0.customisationframe.statsside.stats_assist.scroll)
local v_u_346 = false
l_loadout_menu_0.customisationframe.statsside.viewlore.MouseButton1Click:Connect(function() --[[ Line: 3848 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0, (copy 2): v_u_21, (ref 3): v_u_346, (copy 4): l_statsrange_0, (copy 5): l_statslower_0 ]]
    if l_loadout_menu_0.customisationframe.statsside.viewlore.Visible == true then
        v_u_21()
        v_u_346 = not v_u_346
        l_statsrange_0.Visible = not v_u_346
        l_statslower_0.Visible = not v_u_346
        l_loadout_menu_0.customisationframe.statsside.perklore_lower.Visible = v_u_346
        if v_u_346 == true then
            l_loadout_menu_0.customisationframe.statsside.viewlore.Text = "Show Stats & Details"
            return;
        end;
        l_loadout_menu_0.customisationframe.statsside.viewlore.Text = "Show History & Lore"
    end;
end)
local function v_u_363(p_u_347) --[[ Line: 3865 ]]
    --[[ Upvalues: (copy 1): l_stats_assist_0, (copy 2): l_assist_hover_0, (copy 3): l_loadout_menu_0, (copy 4): l_statsrange_0, (copy 5): l_masterylist_0, (copy 6): l_previewviewport_0, (copy 7): v_u_8, (copy 8): v_u_5, (copy 9): v_u_6, (copy 10): l_LocalPlayer_0, (ref 11): v_u_199, (copy 12): v_u_7, (ref 13): v_u_346, (ref 14): v_u_337, (copy 15): v_u_19, (copy 16): v_u_13, (ref 17): v_u_343, (ref 18): v_u_331, (copy 19): v_u_336, (ref 20): v_u_266, (copy 21): v_u_10, (copy 22): v_u_26, (copy 23): v_u_312, (ref 24): v_u_342, (copy 25): v_u_21, (ref 26): v_u_265, (copy 27): v_u_1, (ref 28): v_u_330, (copy 29): l_statslower_0, (copy 30): v_u_339, (ref 31): v_u_340 ]]
    l_stats_assist_0.Visible = false
    l_assist_hover_0.Visible = false
    l_loadout_menu_0.customisationframe.statsside.Visible = false
    l_statsrange_0.Visible = false
    l_loadout_menu_0.customisationframe.statsside.statslower.Visible = false
    l_loadout_menu_0.customisationframe.statsside.perklore_lower.Visible = false
    l_loadout_menu_0.customisationframe.statsside.viewlore.Visible = false
    l_masterylist_0.Visible = false
    l_previewviewport_0.Visible = false
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
        l_previewviewport_0.worldmodel.preview:Destroy()
    end;
    local v348 = v_u_8[p_u_347] or v_u_5.perks[p_u_347] or (v_u_5.conscript_kits[p_u_347] or v_u_6[p_u_347])
    if v348 then
        local l_icon_0 = v348.icon
        if v348 and (v348.alt_team_icon and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) then
            l_icon_0 = v348.alt_team_icon
        end;
        l_loadout_menu_0.customisationframe.statsside.wepicon.Size = UDim2.new(0.55, 0, 0.55, 0)
        if v_u_5.perks[p_u_347] or v_u_5.conscript_kits[p_u_347] then
            l_loadout_menu_0.customisationframe.statsside.wepicon.Size = UDim2.new(0.5, 0, 0.5, 0)
        end;
        l_loadout_menu_0.customisationframe.statsside.wepicon.Image = "rbxassetid://" .. l_icon_0
        l_loadout_menu_0.customisationframe.statsside.wepnametext.Text = v348.name
        l_loadout_menu_0.customisationframe.statsside.descscroll.CanvasPosition = Vector2.new(0, 0)
        l_loadout_menu_0.customisationframe.statsside.descscroll.desc.Text = v348.desc
        if v_u_199 == "lancer" and v348.lancerdesc ~= nil then
            l_loadout_menu_0.customisationframe.statsside.descscroll.desc.Text = "[Lancer Exclusive]\n" .. v348.lancerdesc
        end;
        l_loadout_menu_0.customisationframe.statsside.perklore_lower.scroll.desc.Text = v348.lore
        if p_u_347 == "mpistol" and (v_u_7:FindFirstChild("weapon_stats") and (v_u_7.weapon_stats:FindFirstChild("mpistol") and v_u_7.weapon_stats.mpistol.Value >= 1911)) then
            l_loadout_menu_0.customisationframe.statsside.perklore_lower.scroll.desc.Text = "The boy once found a beautiful waterfall, hidden away from the eyes of his peers, a land not in jurisdiction of either the Golden Empire nor Royal Nation, un-marked, never discovered and never reported.\n\nHe kept to himself, often desperately trying to forget the past, knowing that every minute of doing so haunts him, so he fled to the waterfall.\n\nThen he came face to face with a girl, rifle raised, ready to take his life.. but yet hesitated.\n\nWhy? He was the enemy, there wasn\'t any reason not to\226\128\148even if this area was off limits\226\128\148nobody would know.\n\nThey spoke, they spoke of the lives they\'ve taken, they spoke of the lives that saved them, they spoke of the war and the fragility of life.\n\nIt wasn\'t long until they met with a Solace Priest in secrecy, he talked of a tunnel that could bring one to the outside, but he warned: a demon was coming for all of them and you can\'t escape it.\n\nThey found a dead Bandit, brandishing a rare surface-era pistol, glued to his hands with melted oil and fat, driven mad by the curse.\n\nA gift from the Gods said the Priest.\n\nThe Priest adorned it with gold and engravings, said to bring luck against the demons that lurk these halls, before disappearing into the catacombs\226\128\148never to be seen again.\n\nThe girl stayed by his side until the end, she begged, crying as the weight of the shadows clawed her insides out as she dug her own grave in the only place that was safe.\n\nThe boy ran, and he kept running, until the shadows enveloped the world.\n\nHe knew he could make it, because he defied death.\n\nAnd he\'ll do it again."
        end;
        l_loadout_menu_0.customisationframe.statsside.perklore_lower.scroll.CanvasPosition = Vector2.new(0, 0)
        l_loadout_menu_0.customisationframe.statsside.Visible = true
        if v_u_346 == true then
            l_loadout_menu_0.customisationframe.statsside.perklore_lower.Visible = true
        end;
        if v348.assists ~= nil then
            l_assist_hover_0.Visible = true
            l_stats_assist_0.Visible = v_u_337
            for _, v349 in ipairs(l_stats_assist_0.scroll:GetChildren()) do
                if v349.Name ~= "ex" and v349.Name ~= "UIListLayout" then
                    v349:Destroy()
                end;
            end;
            for v350, v351 in ipairs(v348.assists) do
                local v352 = l_stats_assist_0.scroll.ex:Clone()
                v352.Name = "assists"
                v352.LayoutOrder = v350
                local v353 = "- " .. v351
                local v354 = v_u_19
                if _G.using_controller == true then
                    v354 = v_u_13
                end;
                local v355 = string.gsub(string.gsub(string.gsub(string.gsub(v353, "@ALT", v354.alt.Name), "@CHECK", v354.checkammo.Name), "@RELOAD", v354.reload.Name), "@EQUIP", v354.equipment.Name)
                local v356
                if _G.using_controller == true then
                    v356 = string.gsub(string.gsub(string.gsub(string.gsub(v355, "@WALKER1", "DPadLeft"), "@WALKER2", "DPadRight"), "@WALKER3", "DPadUp"), "@WALKER4", "DPadDown")
                else
                    v356 = string.gsub(string.gsub(string.gsub(string.gsub(v355, "@WALKER1", "1"), "@WALKER2", "2"), "@WALKER3", "3"), "@WALKER4", "4")
                end;
                v352.Text = v356
                v352.Visible = true
                v352.Parent = l_stats_assist_0.scroll
            end;
        end;
        local v357 = v_u_7.weapon_stats:FindFirstChild(p_u_347)
        if v357 or (p_u_347 == "jaegerkit" or p_u_347 == "hammer") == true then
            l_masterylist_0.skinsubtext.Text = ""
            l_masterylist_0.skinlist.Visible = false
            for _, v358 in ipairs(l_masterylist_0.skinlist:GetChildren()) do
                if v358.Name ~= "UIListLayout" and v358.Name ~= "ex" then
                    v358:Destroy()
                end;
            end;
            l_masterylist_0.Visible = true
            if l_stats_assist_0.Visible == true then
                l_masterylist_0.Position = UDim2.new(-0.525, 0, 1.05, 0)
            else
                l_masterylist_0.Position = UDim2.new(-0.525, 0, 0, 0)
            end;
            if v_u_343 ~= nil then
                v_u_343:Disconnect()
                v_u_343 = nil
            end;
            v_u_331 = p_u_347
            v_u_336(v_u_331)
            local v_u_359 = v_u_7.skins:FindFirstChild(p_u_347 .. math.clamp(v_u_266, 0, 2))
            if v_u_359 and v_u_10.skins[p_u_347] ~= nil then
                l_masterylist_0.skinlist.Visible = true
                for v360 = 1, #v_u_10.skins[p_u_347] do
                    local l_skins_0 = v_u_10.skins[p_u_347][v360]
                    if l_skins_0 and (not l_skins_0.spec or v_u_7.specials:FindFirstChild(l_skins_0.spec) ~= nil and v_u_7.specials:FindFirstChild(l_skins_0.spec).Value == true) then
                        local v_u_361 = l_masterylist_0.skinlist.ex:Clone()
                        v_u_361.Name = l_skins_0.int
                        v_u_361.col.ImageColor3 = l_skins_0.col
                        local l_IntValue_0 = Instance.new("IntValue")
                        l_IntValue_0.Name = "killreq"
                        l_IntValue_0.Value = l_skins_0.kill_req
                        if v357.Value < l_IntValue_0.Value then
                            v_u_361.skinlocked.Visible = true
                        end;
                        if v_u_359.Value == l_skins_0.int then
                            v_u_361.ImageColor3 = Color3.new(1, 1, 1)
                        end;
                        v_u_361.Visible = true
                        v_u_361.MouseEnter:Connect(function() --[[ Line: 4029 ]]
                            --[[ Upvalues: (ref 1): v_u_26, (ref 2): v_u_312, (copy 3): p_u_347, (copy 4): l_skins_0, (ref 5): l_masterylist_0 ]]
                            v_u_26()
                            v_u_312(p_u_347, l_skins_0.int)
                            l_masterylist_0.skinsubtext.Text = l_skins_0.name .. " - (" .. l_skins_0.kill_req .. " lives taken)"
                        end)
                        v_u_361.MouseButton1Click:Connect(function() --[[ Line: 4038 ]]
                            --[[ Upvalues: (copy 1): v_u_361, (ref 2): v_u_342, (ref 3): v_u_21, (ref 4): v_u_265, (copy 5): v_u_359, (ref 6): v_u_1, (copy 7): l_skins_0, (ref 8): l_masterylist_0, (ref 9): v_u_330 ]]
                            if v_u_361.skinlocked.Visible ~= true then
                                if tick() - v_u_342 >= 0.5 then
                                    v_u_342 = tick()
                                    v_u_21()
                                    v_u_265 = true
                                    if v_u_361.ImageColor3 == Color3.new(1, 1, 1) then
                                        v_u_359.Value = "stock"
                                        v_u_1.game_handler:FireServer("change_skin", v_u_359, "stock")
                                        v_u_361.ImageColor3 = Color3.new(0, 0, 0)
                                    else
                                        v_u_359.Value = l_skins_0.int
                                        v_u_1.game_handler:FireServer("change_skin", v_u_359, l_skins_0.int)
                                        v_u_361.ImageColor3 = Color3.new(1, 1, 1)
                                    end;
                                    for _, v362 in ipairs(l_masterylist_0.skinlist:GetChildren()) do
                                        if v362:IsA("ImageButton") and (v362.Name ~= "ex" and v362 ~= v_u_361) then
                                            v362.ImageColor3 = Color3.new(0, 0, 0)
                                        end;
                                    end;
                                    v_u_330("all")
                                end;
                            end;
                        end)
                        v_u_361.Parent = l_masterylist_0.skinlist
                    end;
                end;
            end;
        end;
        if v348.tooltype and v348.tooltype == "gun" then
            l_loadout_menu_0.customisationframe.statsside.viewlore.Visible = true
            l_statslower_0.statline1.bar.inner.Size = UDim2.new(math.clamp((v348.animations == "crossbow" and 280 or (v348.damage + v348.range_damage / 2 + v348.far_damage / 2) * v348.pellets) / 300, 0, 1), 0, 1, 0)
            l_statslower_0.statline2.bar.inner.Size = UDim2.new(math.clamp((50 - v348.accuracy) / 50, 0, 1), 0, 1, 0)
            l_statslower_0.statline3.bar.inner.Size = UDim2.new(math.clamp(v348.accuracy / v348.moving_accuracy / 1, 0, 1), 0, 1, 0)
            l_statslower_0.statline4.bar.inner.Size = UDim2.new(math.clamp((60 - v348.recoil * (v348.recoil_count / 6)) / 60, 0, 1), 0, 1, 0)
            if v348.display_fire_rate then
                l_statslower_0.statline5.insidetext.Text = v348.display_fire_rate
            else
                l_statslower_0.statline5.insidetext.Text = math.ceil(60 / (v348.fire_rate + v348.cycle + v348.cycle_rest))
            end;
            if v348.hidereserves then
                l_statslower_0.statline6.insidetext.Text = v348.capacity
            else
                l_statslower_0.statline6.insidetext.Text = v348.capacity .. " | " .. v348.ammo_reserves * v348.capacity .. "/" .. v348.ammo_reserves_max * v348.capacity
            end;
            l_statsrange_0.Visible = true
            l_statsrange_0.handlingstats.Visible = false
            l_statsrange_0.rangestats.Visible = true
            l_statsrange_0.toptext.Text = v_u_339[1]
            v_u_340 = 1
            l_statsrange_0.rangestats.rangeclose.Text = "<" .. v348.range .. " std"
            l_statsrange_0.rangestats.rangeclose.insidetext.Text = v348.damage * v348.pellets
            l_statsrange_0.rangestats.rangemid.Text = v348.range .. " std"
            l_statsrange_0.rangestats.rangemid.insidetext.Text = v348.range_damage * v348.pellets
            l_statsrange_0.rangestats.rangelong.Text = v348.far .. " std"
            l_statsrange_0.rangestats.rangelong.insidetext.Text = v348.far_damage * v348.pellets
            if v348.animations == "crossbow" then
                l_statsrange_0.rangestats.rangeclose.Text = "< 999 std"
                l_statsrange_0.rangestats.rangeclose.insidetext.Text = "199"
                l_statsrange_0.rangestats.rangemid.Text = ""
                l_statsrange_0.rangestats.rangemid.insidetext.Text = ""
                l_statsrange_0.rangestats.rangelong.Text = ""
                l_statsrange_0.rangestats.rangelong.insidetext.Text = ""
            end;
            l_statsrange_0.handlingstats.penpower.insidetext.TextColor3 = ({
                Color3.fromRGB(170, 0, 0),
                Color3.fromRGB(170, 58, 7),
                Color3.fromRGB(255, 228, 120),
                Color3.fromRGB(79, 255, 108),
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(255, 0, 0)
            })[v348.pen + 1]
            l_statsrange_0.handlingstats.penpower.insidetext.Text = ({
                "Little",
                "Weak",
                "Decent",
                "Strong",
                "Powerful",
                "Devastating"
            })[v348.pen + 1]
            l_statsrange_0.handlingstats.aimspeed.insidetext.Text = v348.draw_speed .. "s | " .. v348.aim_speed .. "s"
            l_statsrange_0.handlingstats.reloadfull.insidetext.Text = math.ceil(((v348.reload_loop + v348.reload_loop_after) * v348.capacity + v348.reload_start + v348.reload_end) * 100) / 100 .. "s"
            if v_u_346 == true then
                l_statsrange_0.Visible = false
                l_statslower_0.Visible = false
            else
                l_statsrange_0.Visible = true
                l_statslower_0.Visible = true
            end;
        end;
        l_loadout_menu_0.customisationframe.statsside.viewlore.Visible = false
        l_loadout_menu_0.customisationframe.statsside.perklore_lower.Visible = true
    end;
end;
local function v_u_371(p_u_364, p_u_365) --[[ Line: 4167 ]]
    --[[ Upvalues: (copy 1): v_u_8, (copy 2): v_u_5, (copy 3): v_u_6, (copy 4): l_LocalPlayer_0, (copy 5): l_loadout_menu_0, (ref 6): v_u_267, (copy 7): v_u_26, (copy 8): v_u_363, (copy 9): v_u_21, (copy 10): l_previewviewport_0, (ref 11): v_u_266, (ref 12): v_u_200 ]]
    local v366 = p_u_364 == "" and {
        ["name"] = "Empty",
        ["icon"] = "17768266447",
        ["size"] = 1
    } or (v_u_8[p_u_364] or v_u_5.perks[p_u_364] or (v_u_5.conscript_kits[p_u_364] or v_u_6[p_u_364]))
    local l_icon_1 = v366.icon
    if v366 and (v366.alt_team_icon and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) then
        l_icon_1 = v366.alt_team_icon
    end;
    local v_u_367 = l_loadout_menu_0.customisationframe.weapons.ex:Clone()
    local v_u_368 = #l_loadout_menu_0.customisationframe.weapons:GetChildren()
    v_u_367.Name = p_u_365
    v_u_367.LayoutOrder = #l_loadout_menu_0.customisationframe:GetChildren()
    v_u_367.wepicon.Image = "rbxassetid://" .. l_icon_1
    v_u_367.wepname.Text = v366.name
    v_u_367.cat.Text = p_u_365
    if v366.size and (v366.size == 2 and p_u_365 ~= "Equipment Strap") then
        v_u_367.Size = UDim2.new(1, 0, 0.09, 0)
    end;
    if p_u_365 == "Primary Sling" or (p_u_365 == "Secondary Holster" or (p_u_365 == "Perk Slot" or (p_u_365 == "Melee Sheath" or p_u_365 == "Conscript Kits"))) then
        v_u_367.openselection.Visible = true
        if p_u_365 == "Primary Sling" and v_u_267 == "primary" or (p_u_365 == "Secondary Holster" and v_u_267 == "secondary" or (p_u_365 == "Perk Slot" and v_u_267 == "perk" or (p_u_365 == "Melee Sheath" and v_u_267 == "melee" or p_u_365 == "Conscript Kits" and v_u_267 == "kit"))) then
            v_u_367.BackgroundColor3 = Color3.new(1, 1, 1)
            v_u_367.wepname.TextColor3 = Color3.new(0, 0, 0)
            v_u_367.wepicon.ImageColor3 = Color3.new(0, 0, 0)
        end;
    end;
    v_u_367.Visible = true
    v_u_367.Parent = l_loadout_menu_0.customisationframe.weapons
    v_u_367.MouseEnter:Connect(function() --[[ Line: 4209 ]]
        --[[ Upvalues: (ref 1): v_u_26, (ref 2): v_u_363, (copy 3): p_u_364 ]]
        v_u_26()
        v_u_363(p_u_364)
    end)
    v_u_367.MouseButton1Click:Connect(function() --[[ Line: 4214 ]]
        --[[ Upvalues: (ref 1): v_u_21, (ref 2): l_previewviewport_0, (ref 3): v_u_266, (copy 4): v_u_368, (copy 5): v_u_367, (ref 6): v_u_363, (copy 7): p_u_364, (ref 8): l_loadout_menu_0, (ref 9): v_u_267, (copy 10): p_u_365, (ref 11): v_u_200 ]]
        v_u_21()
        l_previewviewport_0.Visible = false
        if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
            l_previewviewport_0.worldmodel.preview:Destroy()
        end;
        local v369 = false
        v_u_266 = v_u_368 - 1
        if v_u_367.BackgroundColor3 == Color3.new(1, 1, 1) then
            v_u_266 = 0
            v369 = true
        else
            v_u_363(p_u_364)
        end;
        l_loadout_menu_0.customisationframe.scroll.Visible = false
        l_loadout_menu_0.customisationframe.modbutton.Visible = false
        l_loadout_menu_0.customisationframe.altline.Visible = false
        for _, v370 in ipairs(l_loadout_menu_0.customisationframe.weapons:GetChildren()) do
            if v370:IsA("ImageButton") then
                v370.BackgroundColor3 = Color3.new(0, 0, 0)
                v370.wepname.TextColor3 = Color3.new(1, 1, 1)
                v370.openselection.TextColor3 = Color3.new(1, 1, 1)
                v370.wepicon.ImageColor3 = Color3.new(1, 1, 1)
            end;
        end;
        if v369 == false then
            v_u_367.BackgroundColor3 = Color3.new(1, 1, 1)
            v_u_367.wepname.TextColor3 = Color3.new(0, 0, 0)
            v_u_367.wepicon.ImageColor3 = Color3.new(0, 0, 0)
            if v_u_367.openselection.Visible == true then
                v_u_267 = "primary"
                if p_u_365 == "Secondary Holster" then
                    v_u_267 = "secondary"
                elseif p_u_365 == "Perk Slot" then
                    v_u_267 = "perk"
                elseif p_u_365 == "Melee Sheath" then
                    v_u_267 = "melee"
                elseif p_u_365 == "Conscript Kits" then
                    v_u_267 = "kit"
                end;
                v_u_367.openselection.TextColor3 = Color3.new(0, 0, 0)
                l_loadout_menu_0.customisationframe.scroll.Visible = true
                l_loadout_menu_0.customisationframe.altline.Visible = true
                l_loadout_menu_0.customisationframe.scroll.CanvasPosition = Vector2.new(0, 0)
                v_u_200()
            end;
        end;
    end)
end;
local v_u_372 = 2
local function v_u_380() --[[ Line: 4275 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0, (copy 2): v_u_7, (ref 3): v_u_199, (ref 4): v_u_372, (copy 5): v_u_8 ]]
    for _, v373 in ipairs(l_loadout_menu_0.customisationframe.inv_weights:GetChildren()) do
        if v373.Name ~= "ex" and v373.Name ~= "layout" then
            v373:Destroy()
        end;
    end;
    local v374 = v_u_7.class_setup:FindFirstChild(v_u_199)
    local v375 = v_u_372
    local v376 = v_u_8[v374.primary.Value]
    if v376 then
        v375 = v375 - v376.size
    end;
    local v377 = v_u_8[v374.secondary.Value]
    if v377 then
        v375 = v375 - v377.size
    end;
    for v378 = v_u_372, 1, -1 do
        local v379 = l_loadout_menu_0.customisationframe.inv_weights.ex:Clone()
        v379.Name = "weight"
        v379.Visible = true
        if v375 < v378 then
            v379.taken.Visible = true
        else
            v379.ammo.Visible = true
        end;
        v379.Parent = l_loadout_menu_0.customisationframe.inv_weights
    end;
end;
local function v_u_386(p381, p382) --[[ Line: 4309 ]]
    --[[ Upvalues: (copy 1): v_u_7, (ref 2): v_u_199, (ref 3): v_u_372, (copy 4): l_loadout_menu_0, (ref 5): v_u_267, (ref 6): v_u_265, (copy 7): v_u_371, (copy 8): v_u_6, (copy 9): v_u_380 ]]
    local v383 = v_u_7.class_setup:FindFirstChild(p381)
    v_u_199 = p381
    if v383 then
        v_u_372 = 2
        if p381 == "soldat" then
            v_u_372 = 3
        end;
        if v383.perk.Value == "extrainv" then
            v_u_372 = v_u_372 + 1
        end;
        if p382 == nil then
            l_loadout_menu_0.customisationframe.altline.Visible = false
            l_loadout_menu_0.customisationframe.scroll.Visible = false
            l_loadout_menu_0.customisationframe.modbutton.Visible = false
            l_loadout_menu_0.customisationframe.statsside.Visible = false
            v_u_267 = nil
            l_loadout_menu_0.customisationframe.weight_popup.Visible = false
        end;
        v_u_265 = true
        for _, v384 in ipairs(l_loadout_menu_0.customisationframe.weapons:GetChildren()) do
            if v384.Name ~= "ex" and v384.Name ~= "layout" then
                v384:Destroy()
            end;
        end;
        if v_u_199 == "conscript" then
            v_u_371(v383.kit.Value, "Conscript Kits")
            v_u_371(v383.melee.Value, "Melee Sheath")
            v_u_371("pick", "Mining Pick Belt")
        else
            if v_u_199 == "lancer" then
                v_u_371("lance", "Lance Sling")
            elseif v_u_199 == "vanguard" then
                v_u_371("vanguardshield", "Shield Sling")
            else
                v_u_371(v383.primary.Value, "Primary Sling")
            end;
            v_u_371(v383.secondary.Value, "Secondary Holster")
            v_u_371(v383.melee.Value, "Melee Sheath")
            if v_u_199 == "rook" then
                v_u_371("pickaxe", "Heavy Pick Sling")
            else
                v_u_371("pick", "Mining Pick Belt")
            end;
            v_u_371("firstaid", "First Aid Pouch")
            local v385 = "Equipment Strap"
            if v_u_199 == "mortician" then
                v_u_371("stimbottle", "Stimulants Pouch")
            elseif v_u_199 == "rook" then
                v_u_371("hammer", "Hammer Holder")
            elseif v_u_199 == "jaeger" then
                v_u_371("jaegerkit", "Trapper Kit")
            elseif v_u_199 == "officer" then
                v_u_371("binocs", "Binoculars Pouch")
            elseif v_u_199 == "soldat" then
                v_u_371("soldatskill", "Combat Experience")
            elseif v_u_199 == "lancer" then
                v_u_371("lancerstim", "Injector Strap")
            elseif v_u_199 == "vanguard" then
                v_u_371("flagpole", "Flag Bundle")
                v385 = "Guardian Spirit"
            end;
            if v_u_6[p381] then
                v_u_371(p381 == "rook" and "rooklauncher" or (p381 == "lancer" and "throwaxe" or (p381 == "officer" and "whistle" or p381)), v385)
            end;
            v_u_371(v383.perk.Value, "Perk Slot")
        end;
        v_u_380()
    end;
end;
local function v_u_389(p387) --[[ Line: 4406 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): v_u_7, (copy 3): v_u_1, (copy 4): l_loadout_menu_0, (ref 5): v_u_199, (ref 6): v_u_162, (copy 7): l_purchase_item_0, (ref 8): v_u_330, (copy 9): v_u_386 ]]
    if p387.ImageColor3 ~= Color3.new(1, 1, 1) then
        v_u_21()
        v_u_7.class.Value = p387.Name
        v_u_1.game_handler:FireServer("change_class", p387.Name)
        for _, v388 in ipairs(l_loadout_menu_0.customisationframe.classes:GetChildren()) do
            if v388:IsA("ImageButton") then
                v388.ImageColor3 = Color3.new(0, 0, 0)
                v388.inner.TextColor3 = Color3.new(1, 1, 1)
            end;
        end;
        p387.ImageColor3 = Color3.new(1, 1, 1)
        p387.inner.TextColor3 = Color3.new(0, 0, 0)
        v_u_199 = p387.Name
        l_loadout_menu_0.customisationframe.class_locked_warning.Visible = false
        v_u_162 = ""
        l_purchase_item_0.Visible = false
        v_u_330("all")
        v_u_386(p387.Name)
    end;
end;
local v_u_390 = v_u_331
local v_u_391 = v_u_273
local v_u_392 = v_u_265
local v_u_393 = v_u_372
local v_u_394 = v_u_267
local v_u_395 = v_u_330
for v396, v397 in pairs(v_u_5.classes) do
    if v396 ~= "engineer" and v396 ~= "dread" then
        local v_u_398 = l_loadout_menu_0.customisationframe.classes.ex:Clone()
        v_u_398.Name = v396
        v_u_398.LayoutOrder = v397.order
        v_u_398.inner.Text = v397.name
        v_u_398.Visible = true
        local v399 = game.ReplicatedStorage.outfits.icons:FindFirstChild(v396)
        if v399 then
            v_u_398.classicon.Image = v399.Texture
        end;
        v_u_398.MouseButton1Click:Connect(function() --[[ Line: 4453 ]]
            --[[ Upvalues: (copy 1): v_u_389, (copy 2): v_u_398 ]]
            v_u_389(v_u_398)
        end)
        v_u_398.Parent = l_loadout_menu_0.customisationframe.classes
        if v396 == v_u_7.class.Value then
            v_u_389(v_u_398)
            local v400 = false
            v_u_392 = v400
        end;
        local v401 = l_cosmeticsframe_0.classes.ex:Clone()
        v401.Name = v396
        v401.LayoutOrder = v397.order
        v401.inner.Text = v397.name
        v401.Visible = true
        if v396 == "conscript" then
            v_u_398.Visible = false
            v401.Visible = false
        end;
        if v399 then
            v401.classicon.Image = v399.Texture
        end;
        v401.Parent = l_cosmeticsframe_0.classes
    end;
end;
local l_Royal Nation_0 = game.Teams["Royal Nation"]
local l_soldat_0 = v_u_7.cosmetic_setup.soldat
local v_u_402 = nil
local function f_set_hat_scale(p_u_403) --[[ Name: set_hat_scale ]] --[[ Line: 4492 ]]
    --[[ Upvalues: (copy 1): v_u_7, (copy 2): v_u_21, (copy 3): v_u_1, (copy 4): v_u_304, (copy 5): l_appearancerig_0, (ref 6): l_soldat_0, (ref 7): l_Royal Nation_0 ]]
    local v_u_404 = v_u_7:FindFirstChild(p_u_403.Parent.Name)
    if v_u_404 ~= nil then
        local l_Text_3 = p_u_403.Text
        p_u_403.Text = v_u_404.Value
        p_u_403:GetPropertyChangedSignal("Text"):Connect(function() --[[ Line: 235 ]]
            --[[ Upvalues: (copy 1): p_u_403 ]]
            p_u_403.Text = p_u_403.Text:gsub("[^%d{.}]", "")
        end)
        p_u_403.FocusLost:Connect(function(p405) --[[ Line: 4505 ]]
            --[[ Upvalues: (ref 1): v_u_21, (copy 2): p_u_403, (copy 3): v_u_404, (ref 4): v_u_1, (ref 5): v_u_304, (ref 6): l_appearancerig_0, (ref 7): l_soldat_0, (ref 8): l_Royal Nation_0, (ref 9): l_Text_3 ]]
            v_u_21()
            local v406 = tonumber(p_u_403.Text)
            local v407 = v406 == nil and 0 or v406
            if p405 == true and string.len((tostring(v407))) < 20 then
                local v408 = math.clamp(v407, 0, 1)
                p_u_403.Text = tostring(v408)
                v_u_404.Value = v408
                v_u_1.game_handler:FireServer("change_hat_pos", v_u_404, v408)
                v_u_304(l_appearancerig_0, l_soldat_0, l_Royal Nation_0)
            else
                p_u_403.Text = l_Text_3
            end;
            l_Text_3 = p_u_403.Text
        end)
    end;
end;
f_set_hat_scale(l_cosmeticsframe_0.hat_x.inputbox)
f_set_hat_scale(l_cosmeticsframe_0.hat_y.inputbox)
f_set_hat_scale(l_cosmeticsframe_0.hat_z.inputbox)
local function v_u_410(p409) --[[ Line: 4538 ]]
    --[[ Upvalues: (ref 1): l_Royal Nation_0, (copy 2): l_cosmeticsframe_0, (copy 3): v_u_304, (copy 4): l_appearancerig_0, (ref 5): l_soldat_0 ]]
    l_Royal Nation_0 = p409
    l_cosmeticsframe_0.empireteam.ImageColor3 = Color3.new(0, 0, 0)
    l_cosmeticsframe_0.royalteam.ImageColor3 = Color3.new(0, 0, 0)
    if p409 == game.Teams["Golden Empire"] then
        l_cosmeticsframe_0.empireteam.ImageColor3 = Color3.new(1, 1, 1)
    else
        l_cosmeticsframe_0.royalteam.ImageColor3 = Color3.new(1, 1, 1)
    end;
    v_u_304(l_appearancerig_0, l_soldat_0, l_Royal Nation_0)
end;
l_cosmeticsframe_0.empireteam.MouseButton1Click:Connect(function() --[[ Line: 4552 ]]
    --[[ Upvalues: (ref 1): l_Royal Nation_0, (copy 2): v_u_21, (ref 3): v_u_410 ]]
    if l_Royal Nation_0 ~= game.Teams["Golden Empire"] then
        v_u_21()
        l_Royal Nation_0 = game.Teams["Golden Empire"]
        v_u_410(l_Royal Nation_0)
    end;
end)
l_cosmeticsframe_0.royalteam.MouseButton1Click:Connect(function() --[[ Line: 4562 ]]
    --[[ Upvalues: (ref 1): l_Royal Nation_0, (copy 2): v_u_21, (ref 3): v_u_410 ]]
    if l_Royal Nation_0 ~= game.Teams["Royal Nation"] then
        v_u_21()
        l_Royal Nation_0 = game.Teams["Royal Nation"]
        v_u_410(l_Royal Nation_0)
    end;
end)
local function v_u_423(p_u_411, p_u_412, p_u_413, p414) --[[ Line: 4574 ]]
    --[[ Upvalues: (copy 1): l_cosmeticsframe_0, (ref 2): l_soldat_0, (copy 3): v_u_7, (ref 4): v_u_164, (copy 5): v_u_157, (ref 6): v_u_402, (copy 7): v_u_304, (copy 8): l_appearancerig_0, (ref 9): l_Royal Nation_0, (copy 10): v_u_21, (copy 11): l_purchase_item_0, (ref 12): v_u_162, (copy 13): v_u_282, (copy 14): v_u_156, (copy 15): v_u_1 ]]
    local v_u_415 = l_cosmeticsframe_0.scroll.ex:Clone()
    v_u_415.Name = p_u_413
    v_u_415.display.Text = p_u_411
    v_u_415.valuse.Value = p_u_412
    v_u_415.LayoutOrder = #l_cosmeticsframe_0.scroll:GetChildren()
    v_u_415.Visible = true
    local v_u_416 = l_soldat_0:FindFirstChild(p_u_412)
    if v_u_416 and v_u_416.Value == p_u_413 then
        v_u_415.ImageColor3 = Color3.new(1, 1, 1)
    end;
    if p_u_412 == "accessory" then
        local v417 = l_soldat_0:FindFirstChild("accessoryone")
        if v417 and v417.Value == p_u_413 then
            v_u_415.ImageColor3 = Color3.new(1, 1, 1)
            v_u_415.valuse.Value = "accessoryone"
        else
            v417 = v_u_416
        end;
        v_u_416 = l_soldat_0:FindFirstChild("accessorytwo")
        if v_u_416 and v_u_416.Value == p_u_413 then
            v_u_415.ImageColor3 = Color3.new(1, 1, 1)
            v_u_415.valuse.Value = "accessorytwo"
        else
            v_u_416 = v417
        end;
        local v418 = v_u_7.unlocks:FindFirstChild(p_u_413 .. "_accessory")
        if v418 and v418.Value == false then
            v_u_415.skinlocked.Visible = true
        end;
        v_u_415.preview.Visible = true
        v_u_415.preview.MouseButton1Click:Connect(function() --[[ Line: 4611 ]]
            --[[ Upvalues: (ref 1): v_u_164, (ref 2): v_u_157, (ref 3): v_u_402, (ref 4): l_soldat_0, (copy 5): p_u_413, (ref 6): v_u_304, (ref 7): l_appearancerig_0, (ref 8): l_Royal Nation_0, (ref 9): v_u_21 ]]
            if tick() - v_u_164 >= 1 then
                v_u_164 = tick()
                v_u_157:Play(0.2, 1, 0.5)
            end;
            if v_u_402 then
                v_u_402:Destroy()
            end;
            v_u_402 = l_soldat_0:Clone()
            if v_u_402:FindFirstChild("accessoryone") then
                v_u_402.accessoryone.Value = p_u_413
            end;
            if v_u_402:FindFirstChild("accessorytwo") then
                v_u_402.accessorytwo.Value = "none"
            end;
            v_u_304(l_appearancerig_0, v_u_402, l_Royal Nation_0)
            v_u_21()
        end)
    end;
    if p414 ~= nil then
        v_u_415.coloruse.Visible = true
        v_u_415.coloruse.BackgroundColor3 = Color3.new(unpack(p414))
    end;
    v_u_415.MouseButton1Click:Connect(function() --[[ Line: 4640 ]]
        --[[ Upvalues: (copy 1): v_u_415, (ref 2): v_u_21, (ref 3): l_soldat_0, (copy 4): p_u_412, (ref 5): l_purchase_item_0, (ref 6): v_u_162, (copy 7): p_u_413, (ref 8): v_u_282, (copy 9): p_u_411, (ref 10): v_u_416, (ref 11): v_u_164, (ref 12): v_u_157, (ref 13): l_cosmeticsframe_0, (ref 14): l_Royal Nation_0, (ref 15): v_u_156, (ref 16): v_u_402, (ref 17): v_u_1, (ref 18): v_u_304, (ref 19): l_appearancerig_0 ]]
        if v_u_415.ImageColor3 == Color3.new(0, 0, 0) then
            v_u_21()
            local v419 = l_soldat_0
            if p_u_412 == "accessory" then
                if v_u_415.skinlocked.Visible == true then
                    if l_purchase_item_0.Visible == true and v_u_162 == p_u_413 .. "_accessory" then
                        v_u_162 = ""
                        l_purchase_item_0.Visible = false
                    else
                        v_u_282(p_u_413 .. "_accessory", p_u_411, true)
                    end;
                end;
                local v420 = l_soldat_0:FindFirstChild("accessoryone")
                local v421 = l_soldat_0:FindFirstChild("accessorytwo")
                if v420 and v421 then
                    if v420.Value ~= "none" and v421.Value ~= "none" then
                        return;
                    end;
                    if v420.Value == "none" then
                        v_u_416 = v420
                    elseif v421.Value == "none" then
                        v_u_416 = v421
                    end;
                end;
                if tick() - v_u_164 >= 1 then
                    v_u_164 = tick()
                    v_u_157:Play(0.2, 1, 0.5)
                end;
            else
                for _, v422 in ipairs(l_cosmeticsframe_0.scroll:GetChildren()) do
                    if v422.Name ~= "ex" and (v422:FindFirstChild("display") and (v422:FindFirstChild("valuse") and v422.valuse.Value == p_u_412)) then
                        v422.ImageColor3 = Color3.new(0, 0, 0)
                    end;
                end;
                if p_u_412 == "helmet" or p_u_412 == "helmetempire" then
                    if tick() - v_u_164 >= 1 and (l_Royal Nation_0 == game.Teams["Royal Nation"] and p_u_412 == "helmet" and true or (l_Royal Nation_0 == game.Teams["Golden Empire"] and p_u_412 == "helmetempire" and true or false)) == true then
                        v_u_164 = tick()
                        v_u_156:Play(0.2, 1, 1)
                    end;
                elseif p_u_412 == "haircolour" or p_u_412 == "skincolour" then
                    if v_u_402 then
                        v_u_402:Destroy()
                    end;
                    v_u_402 = l_soldat_0:Clone()
                    if v_u_402:FindFirstChild("helmet") then
                        v_u_402.helmet.Value = "none"
                    end;
                    if v_u_402:FindFirstChild("helmetempire") then
                        v_u_402.helmetempire.Value = "none"
                    end;
                    if v_u_402:FindFirstChild("haircolour") and p_u_412 == "haircolour" then
                        v_u_402.haircolour.Value = p_u_413
                    end;
                    if v_u_402:FindFirstChild("skincolour") and p_u_412 == "skincolour" then
                        v_u_402.skincolour.Value = p_u_413
                    end;
                    v419 = v_u_402
                end;
            end;
            v_u_415.ImageColor3 = Color3.new(1, 1, 1)
            v_u_416.Value = p_u_413
            v_u_1.game_handler:FireServer("change_cosmetics", v_u_416, p_u_413)
            v_u_304(l_appearancerig_0, v419, l_Royal Nation_0)
        elseif p_u_412 == "accessory" then
            v_u_415.ImageColor3 = Color3.new(0, 0, 0)
            v_u_415.valuse.Value = "accessory"
            v_u_416.Value = "none"
            v_u_1.game_handler:FireServer("change_cosmetics", v_u_416, "none")
            v_u_304(l_appearancerig_0, l_soldat_0, l_Royal Nation_0)
            v_u_21()
        end;
    end)
    v_u_415.Parent = l_cosmeticsframe_0.scroll
end;
local function v_u_439() --[[ Line: 4761 ]]
    --[[ Upvalues: (copy 1): l_cosmeticsframe_0, (copy 2): v_u_304, (copy 3): l_appearancerig_0, (ref 4): l_soldat_0, (ref 5): l_Royal Nation_0, (copy 6): v_u_423, (copy 7): v_u_10, (copy 8): v_u_5 ]]
    local v424 = nil
    for _, v425 in ipairs(l_cosmeticsframe_0.customisationoptions:GetChildren()) do
        if v425.Name ~= "UIListLayout" and v425.ImageColor3 == Color3.new(1, 1, 1) then
            v424 = v425
        end;
    end;
    if v424 then
        for _, v426 in ipairs(l_cosmeticsframe_0.scroll:GetChildren()) do
            if v426.Name ~= "UIListLayout" and v426.Name ~= "ex" then
                v426:Destroy()
            end;
        end;
        v_u_304(l_appearancerig_0, l_soldat_0, l_Royal Nation_0)
        l_cosmeticsframe_0.scroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        if v424.Name == "helmet" then
            if l_soldat_0.Name ~= "officer" then
                v_u_423("<font color=\"#ffff7f\">Standard Issue Helmet</font>", "helmetempire", "default", nil)
                v_u_423("<font color=\"#aa00ff\">Standard Issue Helmet</font>", "helmet", "default", nil)
            end;
            v_u_423("<font color=\"#ffff7f\">None</font>", "helmetempire", "none", nil)
            v_u_423("<font color=\"#aa00ff\">None</font>", "helmet", "none", nil)
            for v427, v428 in pairs(v_u_10.hats) do
                if v_u_10.nation_officerhats[v427] == nil then
                    v_u_423("<font color=\"#ffff7f\">" .. v428 .. "</font>", "helmetempire", v427, nil)
                    v_u_423("<font color=\"#aa00ff\">" .. v428 .. "</font>", "helmet", v427, nil)
                end;
            end;
            if l_soldat_0.Name == "officer" then
                for v429, v430 in pairs(v_u_10.nation_officerhats) do
                    v_u_423("<font color=\"#ffff7f\">" .. v_u_10.hats[v429] .. "</font>", "helmetempire", v429, nil)
                    v_u_423("<font color=\"#aa00ff\">" .. v430 .. "</font>", "helmet", v429, nil)
                end;
                return;
            end;
        else
            if v424.Name == "gender" then
                v_u_423("Male", v424.Name, "m", nil)
                v_u_423("Female", v424.Name, "f", nil)
                v_u_423("Random", v424.Name, "r", nil)
                return;
            end;
            if v424.Name == "haircolour" then
                for v431 = 1, #v_u_5.hair_colours do
                    v_u_423("Colour " .. v431, v424.Name, v431, v_u_5.hair_colours[v431])
                end;
                return;
            end;
            if v424.Name == "skincolour" then
                for v432 = 1, #v_u_5.skin_colours do
                    v_u_423("Tone " .. v432, v424.Name, v432, v_u_5.skin_colours[v432])
                end;
                return;
            end;
            if v424.Name == "language" then
                v_u_423("<font color=\"#ffff7f\">Random</font>", "empirevoice", "random", nil)
                v_u_423("<font color=\"#aa00ff\">Random</font>", "nationvoice", "random", nil)
                for v433, v434 in pairs(v_u_10.languages_empire) do
                    v_u_423(v434, "empirevoice", v433, nil)
                end;
                for v435, v436 in pairs(v_u_10.languages_nation) do
                    v_u_423(v436, "nationvoice", v435, nil)
                end;
                return;
            end;
            if v424.Name == "accessories" then
                l_cosmeticsframe_0.scroll.UIListLayout.SortOrder = Enum.SortOrder.Name
                for v437, v438 in pairs(v_u_10.accessories) do
                    v_u_423(v438, "accessory", v437, nil)
                end;
            end;
        end;
    end;
end;
local function v_u_443(p440) --[[ Line: 4857 ]]
    --[[ Upvalues: (copy 1): l_cosmeticsframe_0, (ref 2): l_soldat_0, (copy 3): v_u_7, (copy 4): v_u_439, (copy 5): v_u_304, (copy 6): l_appearancerig_0, (ref 7): l_Royal Nation_0 ]]
    for _, v441 in ipairs(l_cosmeticsframe_0.classes:GetChildren()) do
        if v441.Name ~= "ex" and v441:FindFirstChild("classicon") then
            v441.ImageColor3 = Color3.new(0, 0, 0)
        end;
    end;
    local v442 = l_cosmeticsframe_0.classes:FindFirstChild(p440)
    if v442 then
        v442.ImageColor3 = Color3.new(1, 1, 1)
        l_soldat_0 = v_u_7.cosmetic_setup:FindFirstChild(p440)
        v_u_439()
        v_u_304(l_appearancerig_0, l_soldat_0, l_Royal Nation_0)
    end;
end;
v_u_443("soldat")
for _, v_u_444 in ipairs(l_cosmeticsframe_0.classes:GetChildren()) do
    if v_u_444.Name ~= "ex" and v_u_444:FindFirstChild("inner") then
        v_u_444.MouseButton1Click:Connect(function() --[[ Line: 4878 ]]
            --[[ Upvalues: (copy 1): v_u_444, (copy 2): v_u_21, (copy 3): v_u_443 ]]
            if v_u_444.ImageColor3 == Color3.new(0, 0, 0) then
                v_u_21()
                v_u_443(v_u_444.Name)
            end;
        end)
    end;
end;
for _, v_u_445 in ipairs(l_cosmeticsframe_0.customisationoptions:GetChildren()) do
    if v_u_445.Name ~= "UIListLayout" then
        v_u_445.MouseButton1Click:Connect(function() --[[ Line: 4890 ]]
            --[[ Upvalues: (copy 1): v_u_445, (copy 2): l_cosmeticsframe_0, (copy 3): v_u_21, (copy 4): v_u_439 ]]
            if v_u_445.ImageColor3 == Color3.new(0, 0, 0) then
                for _, v446 in ipairs(l_cosmeticsframe_0.customisationoptions:GetChildren()) do
                    if v446.Name ~= "UIListLayout" then
                        v446.ImageColor3 = Color3.new(0, 0, 0)
                    end;
                end;
                v_u_445.ImageColor3 = Color3.new(1, 1, 1)
                v_u_21()
                l_cosmeticsframe_0.categoryselection.Text = v_u_445.textuse.Value
                v_u_439()
            end;
        end)
    end;
end;
local function v458(p_u_447, p_u_448) --[[ Line: 4913 ]]
    --[[ Upvalues: (copy 1): v_u_8, (copy 2): v_u_5, (copy 3): v_u_6, (copy 4): l_loadout_menu_0, (copy 5): l_LocalPlayer_0, (copy 6): v_u_7, (copy 7): v_u_26, (copy 8): v_u_363, (copy 9): v_u_21, (copy 10): l_purchase_item_0, (ref 11): v_u_162, (copy 12): v_u_282, (ref 13): v_u_199, (ref 14): v_u_393, (ref 15): v_u_394, (copy 16): v_u_1, (ref 17): v_u_395, (ref 18): v_u_200, (copy 19): v_u_386 ]]
    local v_u_449 = p_u_447 == "" and {
        ["name"] = "Empty",
        ["icon"] = "17768266447",
        ["size"] = 1
    } or (v_u_8[p_u_447] or v_u_5.perks[p_u_447] or (v_u_5.conscript_kits[p_u_447] or v_u_6[p_u_447]))
    if v_u_449 then
        local v_u_450 = l_loadout_menu_0.customisationframe.scroll.ex:Clone()
        v_u_450.Name = p_u_447
        if v_u_449.size and v_u_449.size == 2 then
            v_u_450.Size = UDim2.new(1, 0, 0.075, 0)
        end;
        local l_icon_2 = v_u_449.icon
        if v_u_449.alt_team_icon then
            if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                l_icon_2 = v_u_449.alt_team_icon
            end;
            local l_StringValue_3 = Instance.new("StringValue")
            l_StringValue_3.Name = "alticon1"
            l_StringValue_3.Value = v_u_449.alt_team_icon
            l_StringValue_3.Parent = v_u_450
            local l_StringValue_4 = Instance.new("StringValue")
            l_StringValue_4.Name = "alticon2"
            l_StringValue_4.Value = v_u_449.icon
            l_StringValue_4.Parent = v_u_450
        end;
        v_u_450.wepicon.Image = "rbxassetid://" .. l_icon_2
        if p_u_447 == "" or (p_u_448 == true or p_u_448 == "melee") then
            v_u_450.weaponweight.ex.Visible = false
            v_u_450.wepicon.Size = UDim2.new(1.75, 0, 1.75, 0)
            v_u_450.Size = UDim2.new(1, 0, 0.1, 0)
        end;
        v_u_450.LayoutOrder = 0
        if v_u_449 and v_u_449.size then
            v_u_450.LayoutOrder = 6 - v_u_449.size
        end;
        if p_u_447 == "" then
            v_u_450.LayoutOrder = 0
        elseif p_u_447 == "lebel" then
            v_u_450.LayoutOrder = 1
        end;
        local l_StringValue_5 = Instance.new("StringValue")
        l_StringValue_5.Name = "valtype"
        l_StringValue_5.Value = "weapons"
        l_StringValue_5.Parent = v_u_450
        local v451 = v_u_7.unlocks:FindFirstChild(p_u_447)
        if v451 and v451.Value == false then
            v_u_450.weaponlocked.Visible = true
            if v_u_449.variant and v_u_449.variant ~= "" then
                v_u_450.Visible = false
            end;
            if p_u_447 == "mpistol" then
                if v_u_7.specials.success.Value == false then
                    v_u_450.Visible = false
                else
                    v_u_450.Visible = true
                end;
            end;
        end;
        if p_u_448 == true or (p_u_448 == "melee" or p_u_448 == "kits") then
            l_StringValue_5.Value = "perks"
            if p_u_448 == "melee" then
                l_StringValue_5.Value = "melee"
            end;
            if p_u_448 == "kits" then
                l_StringValue_5.Value = "kits"
            end;
        else
            for v452 = 1, v_u_449.size - 1 do
                local v453 = v_u_450.weaponweight.ex:Clone()
                v453.Name = "ex" .. v452
                v453.Parent = v_u_450.weaponweight
            end;
        end;
        v_u_450.Visible = true
        v_u_450.Parent = l_loadout_menu_0.customisationframe.scroll
        if p_u_448 == true and l_StringValue_5.Value == "perks" then
            if v_u_7.specials.lold.Value == true then
                if p_u_447 == "cursed" then
                    v_u_450.weaponlocked.Visible = false
                    v_u_450.Visible = true
                else
                    v_u_450.Visible = false
                end;
            elseif p_u_447 == "cursed" then
                v_u_450.Visible = false
                if v_u_7.specials.yip.Value == true then
                    v_u_450.Visible = true
                end;
            end;
        end;
        v_u_450.MouseEnter:Connect(function() --[[ Line: 5038 ]]
            --[[ Upvalues: (ref 1): v_u_26, (ref 2): v_u_363, (copy 3): p_u_447 ]]
            v_u_26()
            v_u_363(p_u_447)
        end)
        v_u_450.MouseButton1Click:Connect(function() --[[ Line: 5044 ]]
            --[[ Upvalues: (copy 1): v_u_450, (ref 2): v_u_21, (ref 3): l_purchase_item_0, (ref 4): v_u_162, (copy 5): p_u_447, (ref 6): v_u_282, (ref 7): v_u_449, (ref 8): v_u_7, (ref 9): v_u_199, (ref 10): v_u_393, (ref 11): v_u_8, (ref 12): v_u_394, (copy 13): p_u_448, (ref 14): v_u_1, (ref 15): v_u_395, (ref 16): v_u_200, (ref 17): v_u_386 ]]
            if v_u_450.BackgroundColor3 ~= Color3.new(1, 1, 1) then
                v_u_21()
                if v_u_450.weaponlocked.Visible == true then
                    if l_purchase_item_0.Visible == true and v_u_162 == p_u_447 then
                        v_u_162 = ""
                        l_purchase_item_0.Visible = false
                    else
                        v_u_282(p_u_447, v_u_449.name)
                    end;
                end;
                local v454 = v_u_7.class_setup:FindFirstChild(v_u_199)
                if v454 then
                    local v455 = v_u_393
                    local l_secondary_0 = v454.secondary
                    local l_primary_0 = v454.primary
                    local v456 = v_u_8[v454.primary.Value]
                    if v_u_394 == "primary" then
                        l_secondary_0 = v454.primary
                        l_primary_0 = v454.secondary
                        v456 = v_u_8[v454.secondary.Value]
                    end;
                    if v456 and (p_u_448 ~= true and (p_u_448 ~= "melee" and p_u_448 ~= "kits")) then
                        v455 = v455 - v456.size
                    end;
                    if (v_u_199 == "lancer" or v_u_199 == "vanguard") and (v_u_394 == "secondary" and (p_u_448 ~= true and v455 - v_u_449.size < 0)) then
                        return;
                    end;
                    if v_u_394 == "perk" then
                        l_secondary_0 = v454.perk
                        if p_u_447 ~= "extrainv" and l_secondary_0.Value == "extrainv" then
                            local v457 = v_u_8[v454.secondary.Value]
                            if v457 and (v456 and v457.size + v456.size > v455 - 1) then
                                v454.secondary.Value = ""
                                v_u_1.game_handler:FireServer("change_weps", v454.secondary, "")
                            end;
                        end;
                    end;
                    if v_u_394 == "melee" then
                        l_secondary_0 = v454.melee
                    end;
                    if v_u_394 == "kit" then
                        l_secondary_0 = v454.kit
                    end;
                    l_secondary_0.Value = p_u_447
                    v_u_1.game_handler:FireServer("change_weps", l_secondary_0, p_u_447)
                    if p_u_448 ~= true and (p_u_448 ~= "kits" and v455 - v_u_449.size < 0) then
                        l_primary_0.Value = ""
                        v_u_1.game_handler:FireServer("change_weps", l_primary_0, "")
                    end;
                    v_u_395("all")
                    v_u_200()
                    v_u_386(v_u_199, true)
                end;
            end;
        end)
    end;
end;
v458("none", true)
for v459, _ in pairs(v_u_5.perks) do
    if v459 ~= "none" then
        v458(v459, true)
    end;
end;
for v460, _ in pairs(v_u_5.conscript_kits) do
    if v460 ~= "none" then
        v458(v460, "kits")
    end;
end;
v458("")
v458("lebel")
v458("scho")
v458("knife", "melee")
v458("club", "melee")
v458("machete", "melee")
v458("bottle", "melee")
for v461, v462 in pairs(v_u_8) do
    if v461 ~= "lebel" and v461 ~= "scho" then
        local v463 = false
        if v462.tooltype == "gun" or v461 == "cavsword" then
            v463 = v462.blacklist == false and true or v463
        end;
        if v463 == true then
            v458(v461)
        end;
    end;
end;
local v_u_464 = false
l_loadout_menu_0.customisationframe.modbutton.MouseButton1Click:Connect(function() --[[ Line: 5173 ]]
    --[[ Upvalues: (copy 1): l_loadout_menu_0, (copy 2): v_u_21, (ref 3): v_u_464, (ref 4): v_u_200 ]]
    if l_loadout_menu_0.customisationframe.modbutton.Visible ~= false then
        v_u_21()
        v_u_464 = not v_u_464
        if v_u_464 == true then
            l_loadout_menu_0.customisationframe.modbutton.ImageColor3 = Color3.new(1, 1, 1)
        else
            l_loadout_menu_0.customisationframe.modbutton.ImageColor3 = Color3.new(0, 0, 0)
        end;
        v_u_200()
    end;
end)
local function _() --[[ Line: 5189 ]]
    --[[ Upvalues: (copy 1): v_u_7, (ref 2): v_u_199, (ref 3): v_u_393, (copy 4): v_u_8, (ref 5): v_u_394, (copy 6): l_loadout_menu_0, (ref 7): v_u_464 ]]
    local v465 = v_u_7.class_setup:FindFirstChild(v_u_199)
    if v465 then
        local v466 = v_u_393
        local v467 = v_u_8[v465.primary.Value]
        if v_u_394 == "primary" then
            v467 = v_u_8[v465.secondary.Value]
        end;
        if v467 then
            v466 = v466 - v467.size
        end;
        l_loadout_menu_0.customisationframe.modbutton.Visible = false
        local v468 = v465:FindFirstChild(v_u_394)
        for _, v469 in pairs(l_loadout_menu_0.customisationframe.scroll:GetChildren()) do
            if v469:IsA("ImageButton") and v469:FindFirstChild("valtype") then
                v469.Visible = false
                if v_u_394 == "primary" or v_u_394 == "secondary" then
                    if v469.valtype.Value == "weapons" then
                        v469.Visible = true
                        if v_u_464 == true then
                            v469.Visible = false
                        end;
                        if workspace.serverStuff.medievalmode.Value == true and (v469.Name ~= "" and (v469.Name ~= "crossbow" and (v469.Name ~= "cavsword" and v469.Name ~= "henry"))) then
                            v469.Visible = false
                        end;
                    end;
                elseif v_u_394 == "perk" then
                    if v469.valtype.Value == "perks" then
                        v469.Visible = true
                        if v_u_7.specials.lold.Value == true then
                            v469.Visible = false
                            if v469.Name == "cursed" then
                                v469.Visible = true
                            end;
                        elseif v469.Name == "cursed" then
                            v469.Visible = false
                            if v_u_7.specials.yip.Value == true then
                                v469.Visible = true
                            end;
                        end;
                    end;
                elseif v_u_394 == "kit" then
                    if v469.valtype.Value == "kits" then
                        v469.Visible = true
                    end;
                elseif v_u_394 == "melee" and v469.valtype.Value == "melee" then
                    v469.Visible = true
                    if v469.Name == "machete" or v469.Name == "bottle" then
                        v469.Visible = false
                        if v_u_7:FindFirstChild("weapon_stats") then
                            local v470 = v_u_7.weapon_stats:FindFirstChild("knife")
                            if v469.Name == "bottle" then
                                v470 = v_u_7.weapon_stats:FindFirstChild("club")
                            end;
                            if v470 and v470.Value >= 1000 then
                                v469.Visible = true
                            end;
                        end;
                    end;
                end;
                v469.weighticon.Visible = false
                local v471 = v_u_8[v469.Name]
                if v469.Name == v468.Value then
                    v469.BackgroundColor3 = Color3.new(1, 1, 1)
                    v469.wepicon.ImageColor3 = Color3.new(0, 0, 0)
                    v469.weaponweight.ex.ImageColor3 = Color3.new(0, 0, 0)
                    if v469.weaponweight:FindFirstChild("ex1") then
                        v469.weaponweight.ex1.ImageColor3 = Color3.new(0, 0, 0)
                    end;
                else
                    v469.weaponweight.ex.ImageColor3 = Color3.new(1, 1, 1)
                    if v469.weaponweight:FindFirstChild("ex1") then
                        v469.weaponweight.ex1.ImageColor3 = Color3.new(1, 1, 1)
                    end;
                    v469.BackgroundColor3 = Color3.new(0, 0, 0)
                    v469.wepicon.ImageColor3 = Color3.new(1, 1, 1)
                    if v471 and (v471.size ~= 0 and v466 - v471.size < 0) then
                        v469.weighticon.Visible = true
                    end;
                end;
                if v471 and (v471.variant ~= "" and (v_u_394 == "primary" or v_u_394 == "secondary")) then
                    local v472 = v_u_7.unlocks:FindFirstChild(v469.Name)
                    local v473
                    if v472 and v472.Value == true then
                        l_loadout_menu_0.customisationframe.modbutton.Visible = true
                        v473 = true
                    else
                        v473 = false
                    end;
                    v469.varianticon.Visible = true
                    v469.Visible = false
                    v469.weaponlocked.Visible = true
                    if v_u_464 == true and v473 == true then
                        v469.Visible = true
                        v469.weaponlocked.Visible = false
                    end;
                end;
                if v469.Name == "mpistol" and (v_u_394 == "primary" or v_u_394 == "secondary") and (v469.Visible and (v_u_7.specials.success.Value ~= true or v_u_464 ~= false)) then
                    v469.Visible = false
                end;
                if v_u_394 == "melee" or v_u_394 == "kit" then
                    v469.weighticon.Visible = false
                end;
            end;
        end;
    end;
end;
local function v_u_474() --[[ Line: 5346 ]]
    --[[ Upvalues: (copy 1): s_GamepadService_0, (copy 2): v_u_21, (copy 3): l_previewviewport_0, (ref 4): v_u_392, (copy 5): l_Parent_0, (copy 6): l_loadout_menu_0, (copy 7): l_values_0, (copy 8): s_UserInputService_0, (copy 9): l_CurrentCamera_0, (copy 10): v_u_95, (copy 11): l_LocalPlayer_0 ]]
    s_GamepadService_0:DisableGamepadCursor()
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
    v_u_21()
    l_previewviewport_0.Visible = false
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") then
        l_previewviewport_0.worldmodel.preview:Destroy()
    end;
    if v_u_392 == true then
        v_u_392 = false
        _G.popupmsg("loadoutchanges", "Changes will be applied on the next Respawn.", 1.5)
    end;
    l_Parent_0.core_game.Visible = true
    l_loadout_menu_0.Visible = false
    if l_values_0.gamestate.Value == "endpose" or l_values_0.gamestate.Value == "warmap" then
        game.Lighting.endposesat.Enabled = true
        l_Parent_0.core_game.deathscreen.Visible = false
        s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
        l_CurrentCamera_0.FieldOfView = 40
        l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
        if l_values_0.gamestate.Value == "warmap" then
            s_UserInputService_0.MouseIconEnabled = true
            s_GamepadService_0:EnableGamepadCursor(l_Parent_0.warmap)
            return;
        end;
    else
        if l_Parent_0.core_game.deathscreen.Visible == true then
            v_u_95(0, true)
            return;
        end;
        if l_LocalPlayer_0.Character and l_LocalPlayer_0.Character:FindFirstChild("Humanoid") then
            l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
            l_CurrentCamera_0.CameraSubject = l_LocalPlayer_0.Character.Humanoid
        end;
    end;
end;
l_loadout_menu_0.backout.MouseButton1Click:Connect(function() --[[ Line: 5390 ]]
    --[[ Upvalues: (ref 1): v_u_20, (copy 2): v_u_474 ]]
    if v_u_20 ~= "" then
        v_u_474()
    end;
end)
l_loadout_menu_0.settingsframe.playtut.MouseButton1Click:Connect(function() --[[ Line: 5400 ]]
    --[[ Upvalues: (copy 1): v_u_21, (copy 2): v_u_1 ]]
    if tick() - 0 > 5 then
        v_u_21()
        v_u_1.game_handler:FireServer("play_tutorial")
    end;
end)
_G.flash_hitmarker = function(p475) --[[ Line: 5410 ]]
    --[[ Upvalues: (copy 1): l_Parent_0, (copy 2): s_Debris_0, (copy 3): v_u_2 ]]
    local v476 = l_Parent_0.core_game.hitmarkers.mark:Clone()
    s_Debris_0:AddItem(v476, 2)
    v476.Visible = true
    if p475 == "kill" then
        v476.ImageColor3 = Color3.new(0.9, 0, 0)
    elseif p475 == "armour" then
        v476.ImageColor3 = Color3.new(0.9, 0.9, 0)
    end;
    v476.Parent = l_Parent_0
    for _ = 1, 15 do
        v476.ImageTransparency = v476.ImageTransparency + 0.075
        v_u_2:s_wait(0.03)
    end;
    v476:Destroy()
end;
s_UserInputService_0.InputChanged:Connect(function(p477, _) --[[ Name: OnInputChanged ]] --[[ Line: 5433 ]]
    --[[ Upvalues: (copy 1): v_u_14 ]]
    if p477.KeyCode == Enum.KeyCode.Thumbstick1 then
        if p477.Position.Y >= 0.7 then
            v_u_14[Enum.KeyCode.W] = true
            return;
        end;
        v_u_14[Enum.KeyCode.W] = false
    end;
end)
local v_u_478 = 0
s_UserInputService_0.InputBegan:Connect(function(p479, p480) --[[ Line: 5447 ]]
    --[[ Upvalues: (copy 1): v_u_14, (copy 2): s_UserInputService_0, (copy 3): l_Parent_0, (copy 4): l_values_0, (copy 5): v_u_7, (copy 6): v_u_1, (ref 7): v_u_478, (ref 8): v_u_20, (copy 9): l_loadout_menu_0, (copy 10): l_LocalPlayer_0, (copy 11): v_u_336, (ref 12): v_u_390, (copy 13): v_u_474, (copy 14): s_GamepadService_0, (copy 15): v_u_21, (ref 16): v_u_391, (ref 17): v_u_395, (copy 18): v_u_386, (copy 19): v_u_5, (copy 20): l_CurrentCamera_0, (copy 21): v_u_55, (copy 22): v_u_95 ]]
    if p480 == true and (p479.KeyCode == Enum.KeyCode.ButtonA or p479.KeyCode == Enum.KeyCode.ButtonR3) == false then
        return;
    else
        if p479.UserInputType == Enum.UserInputType.MouseButton1 or p479.KeyCode == Enum.KeyCode.ButtonR2 then
            v_u_14.m1 = true
        end;
        if (p479.UserInputType == Enum.UserInputType.MouseButton2 or p479.KeyCode == Enum.KeyCode.ButtonL2) and s_UserInputService_0.MouseBehavior == Enum.MouseBehavior.LockCenter then
            v_u_14.m2 = true
        end;
        if (p479.KeyCode == Enum.KeyCode.ButtonA or p479.KeyCode == Enum.KeyCode.ButtonB) and (l_Parent_0.core_game.deathscreen.Visible == true and (l_Parent_0.core_game.deathscreen.spawnframe.Visible == true and l_values_0.gamemode.Value == "train")) then
            if p479.KeyCode == Enum.KeyCode.ButtonA then
                local v481 = v_u_7.spawn_point.Value == "train" and "base" or "train"
                v_u_7.spawn_point.Value = v481
                v_u_1.game_handler:FireServer("change_spawn", v_u_7.spawn_point, v481)
            elseif p479.KeyCode == Enum.KeyCode.ButtonB and l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.Visible == true then
                if tick() - v_u_478 <= 1 then
                    return;
                end;
                if l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.BackgroundColor3 == Color3.new(0, 0, 0) then
                    v_u_478 = tick()
                    v_u_1.game_handler:FireServer("respawn_engineer")
                end;
            end;
        end;
        if p479.KeyCode then
            v_u_14[p479.KeyCode] = true
        end;
        if v_u_20 == "" then
            if p479.KeyCode then
                v_u_20 = p479.KeyCode.Name
            end;
        else
            if p479.KeyCode == _G.get_keybinds("playerlist") then
                if workspace.serverStuff.trainingmode.Value == true then
                    return;
                end;
                l_Parent_0.playerlist.Visible = true
                game.Lighting.worldblur.Enabled = true
                l_Parent_0.playerlistdarken.Visible = true
            end;
            if p479.KeyCode == _G.get_keybinds("menu") then
                if workspace.serverStuff.trainingmode.Value == true then
                    return;
                end;
                l_loadout_menu_0.Visible = not l_loadout_menu_0.Visible
                l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
                v_u_336(v_u_390)
                if l_loadout_menu_0.Visible == false then
                    l_Parent_0.core_game.Visible = true
                    v_u_474()
                else
                    s_UserInputService_0.MouseIconEnabled = true
                    s_GamepadService_0:EnableGamepadCursor(l_Parent_0.loadout_menu)
                    l_Parent_0.core_game.Visible = false
                    v_u_21()
                    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
                    if v_u_391 ~= l_LocalPlayer_0.Team then
                        v_u_395("all")
                        v_u_386(v_u_7.class.Value)
                    end;
                    local l_ranks_empire_full_0 = v_u_5.ranks_empire_full[v_u_7.rank.Value]
                    if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
                        l_ranks_empire_full_0 = v_u_5.ranks_nation_full[v_u_7.rank.Value]
                    end;
                    l_loadout_menu_0.rank.Text = l_ranks_empire_full_0
                    s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
                    l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
                    l_CurrentCamera_0.FieldOfView = 40
                    l_CurrentCamera_0.CFrame = v_u_55[_G.cam_menu_at]
                    for _, v482 in ipairs(l_Parent_0.loadout_menu.customisationframe.scroll:GetChildren()) do
                        if v482:FindFirstChild("alticon1") then
                            if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                                v482.wepicon.Image = "rbxassetid://" .. v482.alticon1.Value
                            else
                                v482.wepicon.Image = "rbxassetid://" .. v482.alticon2.Value
                            end;
                        end;
                    end;
                end;
            end;
            if l_Parent_0.core_game.deathscreen.Visible == true and l_loadout_menu_0.Visible == false then
                if p479.KeyCode == _G.get_keybinds("spectateleft") then
                    v_u_95(-1)
                end;
                if p479.KeyCode == _G.get_keybinds("spectateright") then
                    v_u_95(1)
                end;
            end;
        end;
    end;
end)
s_UserInputService_0.InputEnded:Connect(function(p483, p484) --[[ Line: 5586 ]]
    --[[ Upvalues: (copy 1): v_u_14, (copy 2): l_Parent_0 ]]
    local v485 = p483.KeyCode == Enum.KeyCode.ButtonA
    if p483.KeyCode then
        v_u_14[p483.KeyCode] = nil
    end;
    if p483.UserInputType == Enum.UserInputType.MouseButton1 or p483.KeyCode == Enum.KeyCode.ButtonR2 then
        v_u_14.m1 = nil
    end;
    if p483.UserInputType == Enum.UserInputType.MouseButton2 or p483.KeyCode == Enum.KeyCode.ButtonL2 then
        v_u_14.m2 = nil
    end;
    if p484 ~= true or v485 ~= false then
        if p483.KeyCode == _G.get_keybinds("playerlist") then
            l_Parent_0.playerlist.Visible = false
            game.Lighting.worldblur.Enabled = false
            l_Parent_0.playerlistdarken.Visible = false
        end;
    end;
end)
if l_LocalPlayer_0.Character == nil then
    s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
    l_CurrentCamera_0.FieldOfView = 40
    l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
    l_CurrentCamera_0.CFrame = v_u_55[_G.cam_menu_at]
    l_Parent_0.core_game.deathscreen.Visible = true
    v_u_95(1, true)
end;
l_CurrentCamera_0.FieldOfView = 40
v_u_143()
game.Players.PlayerAdded:Connect(function(p486) --[[ Line: 5632 ]]
    --[[ Upvalues: (copy 1): v_u_139 ]]
    v_u_139(p486)
end)
game.Players.PlayerRemoving:Connect(function(p487) --[[ Line: 5635 ]]
    --[[ Upvalues: (copy 1): l_Parent_0 ]]
    local v488 = l_Parent_0.playerlist.empirelist:GetChildren()
    for _, v489 in ipairs(l_Parent_0.playerlist.royallist:GetChildren()) do
        table.insert(v488, v489)
    end;
    for _, v490 in ipairs(v488) do
        if v490.Name == p487.Name or v490.Name == "b" .. p487.Name then
            v490:Destroy()
        end;
    end;
end)
local v491 = CFrame.new(1, 0.5, 0, -4.37113883e-8, 0, 1, -0, 0.99999994, 0, -1, 0, -4.37113883e-8)
local v492 = CFrame.new(-1, 0.5, 0, -4.37113883e-8, 0, -1, 0, 0.99999994, 0, 1, 0, -4.37113883e-8)
local v493 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
local v494 = tick()
local v495 = tick()
local v496 = {
    workspace.notarget,
    workspace.evacs,
    workspace.nation_team,
    workspace.empire_team,
    l_CurrentCamera_0,
    workspace.constructions
}
local v_u_497 = v_u_478
for _, v_u_498 in ipairs(l_Parent_0.core_game.deathscreen.spawnframe.spawns:GetChildren()) do
    if v_u_498:IsA("ImageButton") and v_u_498:FindFirstChild("truename") then
        v_u_498.MouseButton1Click:Connect(function() --[[ Line: 5662 ]]
            --[[ Upvalues: (copy 1): v_u_498, (copy 2): v_u_21, (copy 3): v_u_7, (copy 4): v_u_1 ]]
            if v_u_498.BackgroundColor3 ~= Color3.new(1, 1, 1) then
                v_u_21()
                v_u_498.BackgroundColor3 = Color3.new(1, 1, 1)
                v_u_7.spawn_point.Value = v_u_498.Name
                v_u_1.game_handler:FireServer("change_spawn", v_u_7.spawn_point, v_u_498.Name)
            end;
        end)
        v_u_498.MouseEnter:Connect(function() --[[ Line: 5672 ]]
            --[[ Upvalues: (copy 1): v_u_26, (copy 2): l_Parent_0, (copy 3): v_u_498 ]]
            v_u_26()
            l_Parent_0.core_game.deathscreen.spawnframe.toptext.Text = v_u_498.truename.Value
        end)
    end;
end;
l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.MouseButton1Click:Connect(function() --[[ Line: 5679 ]]
    --[[ Upvalues: (copy 1): v_u_21, (ref 2): v_u_497, (copy 3): l_Parent_0, (copy 4): v_u_1 ]]
    v_u_21()
    if tick() - v_u_497 > 1 then
        if l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.BackgroundColor3 == Color3.new(0, 0, 0) then
            v_u_497 = tick()
            v_u_1.game_handler:FireServer("respawn_engineer")
        end;
    end;
end)
local v499 = false
local v500 = {
    ".----",
    "..---",
    "...--",
    "....-",
    ".....",
    "-....",
    "--...",
    "---..",
    "----."
}
while true do
    local v501 = math.clamp((tick() - _G.fadetoblack) / 1, 0, 1)
    local v502 = v501 * v501 * (3 - 2 * v501)
    if l_cosmeticsframe_0.Visible == true then
        l_appearancerig_0.HumanoidRootPart.CFrame = l_appearancerig_0.HumanoidRootPart.CFrame:Lerp(CFrame.new(-1010.6731, -52.8111839, -86.7182159, 0.173648566, 0, -0.984807014, 0, 1, 0, 0.984809875, 0, 0.173648059) * CFrame.Angles(0, math.rad(v158), 0), 0.1)
    end;
    l_Parent_0.core_game.fadetoblack.BackgroundTransparency = v_u_2:lerp(0, 1, v502)
    l_Parent_0.warmap.fadetoblack.BackgroundTransparency = l_Parent_0.core_game.fadetoblack.BackgroundTransparency
    local v503 = s_UserInputService_0:GetLastInputType()
    if v503 == Enum.UserInputType.Gamepad1 or (v503 == Enum.UserInputType.Gamepad2 or (v503 == Enum.UserInputType.Gamepad3 or v503 == Enum.UserInputType.Gamepad4)) then
        _G.using_controller = true
    else
        _G.using_controller = false
    end;
    if workspace.serverStuff.conscriptmode.Value == true then
        if l_loadout_menu_0.Visible == true then
            for _, v504 in ipairs(l_loadout_menu_0.customisationframe.classes:GetChildren()) do
                if v504:IsA("ImageButton") then
                    if v504.Name == "conscript" then
                        v504.Visible = true
                        v_u_389(v504)
                    else
                        v504.Visible = false
                    end;
                end;
            end;
            for _, v505 in ipairs(l_loadout_menu_0.cosmeticsframe.classes:GetChildren()) do
                if v505:IsA("ImageButton") then
                    if v505.Name == "conscript" then
                        v505.Visible = true
                        if v505.ImageColor3 == Color3.new(0, 0, 0) then
                            v_u_443("conscript")
                        end;
                    else
                        v505.Visible = false
                    end;
                end;
            end;
        end;
        game.Lighting.Ambient = Color3.new(0, 0, 0)
        game.Lighting.EnvironmentDiffuseScale = 0
        game.Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        game.Lighting.ExposureCompensation = 0
        game.Lighting.FogColor = Color3.new(0, 0, 0)
    end;
    if workspace.serverStuff.modifier.Value == "fogofwar" and (l_values_0.gamestate.Value == "ingame" or l_values_0.gamestate.Value == "gameend") then
        game.Lighting.FogColor = Color3.fromRGB(53, 53, 53)
        game.Lighting.FogEnd = 100
    else
        game.Lighting.FogColor = Color3.fromRGB(53, 53, 53)
        game.Lighting.FogEnd = 1000
    end;
    if l_loadout_menu_0.Visible == true then
        local v506 = s_UserInputService_0:GetMouseLocation()
        l_loadout_menu_0.customisationframe.weight_popup.Position = UDim2.fromOffset(v506.X, v506.Y)
        l_loadout_menu_0.medalprogresspopup.Position = UDim2.fromOffset(v506.X, v506.Y)
        l_loadout_menu_0.helpmenupopup.Position = UDim2.fromOffset(v506.X, v506.Y)
        l_loadout_menu_0.region.Text = "Server Region: " .. l_values_0.Parent.region.Value .. (" - Server Lifetime: " .. f_toMS(l_values_0.Parent.serverLifetime.Value)) .. " - Server Name: " .. l_values_0.Parent.servername.Value
        for _, v507 in ipairs(workspace.menus.specs:GetChildren()) do
            if v_u_7:FindFirstChild("specials") then
                local v508 = v_u_7.specials:FindFirstChild(v507.Name)
                if v508 then
                    if v508.Value == 0 then
                        v507.gui.Enabled = false
                    elseif v507.gui.Enabled == false then
                        v507.gui.Enabled = true
                        if v500[v508.Value] then
                            v507.gui.label.Text = v500[v508.Value]
                        end;
                    end;
                end;
            end;
        end;
    end;
    if l_previewviewport_0.worldmodel:FindFirstChild("preview") and l_previewviewport_0.worldmodel.preview.PrimaryPart then
        l_previewviewport_0.worldmodel.preview:PivotTo(l_previewviewport_0.worldmodel.preview.PrimaryPart.CFrame * CFrame.Angles(0, 0.008726646259971648, 0))
    end;
    local v509 = workspace.nation_team:GetChildren()
    for _, v510 in ipairs(workspace.empire_team:GetChildren()) do
        table.insert(v509, v510)
    end;
    for _, v511 in ipairs(workspace.evacs:GetChildren()) do
        table.insert(v509, v511)
    end;
    local v512 = l_LocalPlayer_0.Character and (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") and (l_LocalPlayer_0.Character.Humanoid.Health > 0 and (l_LocalPlayer_0.Character:FindFirstChild("perk") and l_LocalPlayer_0.Character.perk.Value == "tracker"))) and true or false
    if l_Parent_0.core_game.deathscreen.spawnframe.Visible == true then
        local l_rein_arrive_0 = l_values_0.empirerein.rein_arrive
        if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
            l_rein_arrive_0 = l_values_0.nationrein.rein_arrive
        end;
        local l_Value_2 = l_rein_arrive_0.Value
        if game:GetService("RunService"):IsStudio() == true then
            l_Value_2 = false
        end;
        if workspace.serverStuff.values.gamemode_specific.engineer_respawn_cd:FindFirstChild(l_LocalPlayer_0.Name) or (l_values_0.gamestate.sub.Value == "endgame" or (l_Value_2 == true or l_LocalPlayer_0:FindFirstChild("currentlyrespawning"))) then
            l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.Text = "Engineer Un-available"
            l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.BackgroundColor3 = Color3.new(0.8, 0, 0)
        else
            l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.Text = "Enlist as Engineer"
            if _G.using_controller == true then
                l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.Text = "Enlist as Engineer (B Button)"
            end;
            l_Parent_0.core_game.deathscreen.spawnframe.engineerrespawn.BackgroundColor3 = Color3.new(0, 0, 0)
        end;
    end;
    for _, v513 in ipairs(v509) do
        if v513.Name ~= l_LocalPlayer_0.Name and (v513.Name ~= l_LocalPlayer_0.Name .. "_ragdoll" and (v513:FindFirstChild("HumanoidRootPart") and (v513:FindFirstChild("Head") and (v513:FindFirstChild("Humanoid") and (v513:FindFirstChild("charPos") and v513.charPos:FindFirstChild("ping")))))) then
            if v513:FindFirstChild("footstep_trail") and (v513.footstep_trail:FindFirstChild("trail") and v513.footstep_trail.trail.Enabled == true) then
                v513.footstep_trail.trail.Enabled = false
            end;
            if v512 == true then
                local l_nation_team_1 = workspace.nation_team
                if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
                    l_nation_team_1 = workspace.empire_team
                end;
                if v513.Parent == l_nation_team_1 then
                    local v514 = v513:FindFirstChild("footstep_trail")
                    if v514 == nil then
                        local v515 = game.ReplicatedStorage.misc.footstep_trail:Clone()
                        local l_Weld_5 = Instance.new("Weld")
                        l_Weld_5.Part0 = v513.HumanoidRootPart
                        l_Weld_5.Part1 = v515
                        l_Weld_5.Parent = v515
                        v515.Parent = v513
                        v515.trail.Enabled = true
                    else
                        v514.trail.Enabled = true
                    end;
                end;
            end;
            local v516 = (v513:FindFirstChild("exec") or v513:FindFirstChild("execing")) and true or false
            if v513:FindFirstChild("bodyshielded") and (v513.bodyshielded.Value and (v513.bodyshielded.Value:FindFirstChild("HumanoidRootPart") and (v513.bodyshielded.Value:FindFirstChild("Humanoid") and v513.bodyshielded.Value.Humanoid.Health > 0))) then
                v513.HumanoidRootPart.Anchored = true
                v513.HumanoidRootPart.CFrame = v513.bodyshielded.Value.HumanoidRootPart.CFrame + v513.bodyshielded.Value.HumanoidRootPart.CFrame.lookVector * 1.5
            end;
            if v513:FindFirstChild("bodyshield") and (v513.bodyshield.Value and (v513.bodyshield.Value:FindFirstChild("HumanoidRootPart") and (v513.bodyshield.Value:FindFirstChild("Humanoid") and v513.bodyshield.Value.Humanoid.Health > 0))) then
                v513.bodyshield.Value.HumanoidRootPart.Anchored = true
                v513.bodyshield.Value.HumanoidRootPart.CFrame = v513.HumanoidRootPart.CFrame + v513.HumanoidRootPart.CFrame.lookVector * 1.5
            end;
            if v516 == false then
                if (v513.HumanoidRootPart.Position - v513.charPos.Value.p).magnitude < 8 then
                    v513.HumanoidRootPart.Anchored = true
                    v513.HumanoidRootPart.CFrame = v513.HumanoidRootPart.CFrame:Lerp(v513.charPos.Value + v513.charPos.velocity.Value * math.ceil(v513.charPos.ping.Value, 0, 0.2) * 0.05, 0.4)
                else
                    v513.HumanoidRootPart.Anchored = false
                end;
            end;
            if v513.HumanoidRootPart:FindFirstChild("topplayer") and (v513.HumanoidRootPart.topplayer:FindFirstChild("playername") and (v513.HumanoidRootPart.topplayer:FindFirstChild("maxdist") and v513.HumanoidRootPart.topplayer:FindFirstChild("playermessage"))) then
                v513.HumanoidRootPart.topplayer.Size = UDim2.new(10, 0, 2, 0)
                if (v513.HumanoidRootPart.Position - l_CurrentCamera_0.CFrame.Position).Magnitude >= 16 then
                    v513.HumanoidRootPart.topplayer.Size = UDim2.new(0, 225, 0, 40)
                end;
                if (v513.HumanoidRootPart.Position - l_CurrentCamera_0.CFrame.Position).Magnitude > 30 then
                    v513.HumanoidRootPart.topplayer.playermessage.Visible = false
                else
                    v513.HumanoidRootPart.topplayer.playermessage.Visible = true
                end;
                local v517 = l_LocalPlayer_0.Character and (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") and (l_LocalPlayer_0.Character.Humanoid.Health > 0 and (l_LocalPlayer_0.Character:FindFirstChild("class") and (l_LocalPlayer_0.Character.class.Value == "officer" or l_LocalPlayer_0.Character.class.Value == "dread")))) and 200 or v513.HumanoidRootPart.topplayer.maxdist.Value
                if _G.get_settings ~= nil then
                    v517 = _G.get_settings("hideallclassicons") == true and 0.1 or (_G.get_settings("hideextendedicons") == true and 30 or v517)
                end;
                v513.HumanoidRootPart.topplayer.MaxDistance = v517
                if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and v513.Parent == workspace.nation_team or l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and v513.Parent == workspace.empire_team then
                    if l_LocalPlayer_0.Character and (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") and (l_LocalPlayer_0.Character.Humanoid.Health > 0 and l_Parent_0.core_game.deathscreen.Visible == false)) then
                        v513.HumanoidRootPart.topplayer.Enabled = true
                        if _G.core_checkers and (_G.core_checkers.friendly_target and _G.core_checkers.friendly_target.Parent == v513) then
                            v513.HumanoidRootPart.topplayer.playername.Visible = true
                        else
                            v513.HumanoidRootPart.topplayer.playername.Visible = false
                        end;
                    else
                        v513.HumanoidRootPart.topplayer.Enabled = false
                    end;
                else
                    v513.HumanoidRootPart.topplayer.Enabled = false
                end;
                if l_Parent_0.core_game.deathscreen.Visible == false and (_G.core_checkers and (_G.core_checkers.aiming and _G.core_checkers.aiming == true)) then
                    v513.HumanoidRootPart.topplayer.Enabled = false
                end;
                if l_LocalPlayer_0:FindFirstChild("showtags") then
                    v513.HumanoidRootPart.topplayer.Enabled = true
                    v513.HumanoidRootPart.topplayer.playername.Visible = true
                    v513.HumanoidRootPart.topplayer.MaxDistance = 10000
                end;
            end;
            if v513.charPos:FindFirstChild("camRot") and (v513:FindFirstChild("crouching") and (v513:FindFirstChild("leaning") and (v513:FindFirstChild("Torso") and (v513:FindFirstChild("HumanoidRootPart") and (v513.HumanoidRootPart:FindFirstChild("RootJoint") and v513.Torso:FindFirstChild("Neck")))))) then
                local l_Value_3 = v513.charPos.camRot.Value
                local v518 = 0
                local v519 = v513:FindFirstChildOfClass("Tool")
                local v520 = (not v519 or (not v519:FindFirstChild("weapon") or v519.weapon.Value == "firstaid")) and 0 or math.rad(l_Value_3 * 50)
                local v521 = CFrame.new(0, 0, 0)
                if v513.crouching.Value == true then
                    v521 = CFrame.new(0, 0, -0.85)
                end;
                local v522 = CFrame.new(0, 0, 0)
                if v513.leaning.Value == "right" then
                    v522 = CFrame.new(-0.25, 0, 0) * CFrame.Angles(0, -0.17453292519943295, 0)
                elseif v513.leaning.Value == "left" then
                    v522 = CFrame.new(0.25, 0, 0) * CFrame.Angles(0, 0.17453292519943295, 0)
                end;
                if v519 and (v519:FindFirstChild("weapon") and (v519.weapon.Value == "vanguardshield" and v520 <= -0.3)) then
                    v518 = v520 + 0.3
                end;
                local v523 = v492 * CFrame.Angles(0, 0, -v520 + v518)
                local v524 = v491 * CFrame.Angles(0, 0, v520)
                if v513:FindFirstChild("bodyshield") then
                    v523 = v492
                end;
                if v516 == true then
                    v521 = CFrame.new(0, 0, 0)
                    v522 = CFrame.new(0, 0, 0)
                    v523 = v492
                    v524 = v491
                    l_Value_3 = 0
                end;
                v513.Torso["Right Shoulder"].C0 = v513.Torso["Right Shoulder"].C0:Lerp(v524, 0.2)
                v513.Torso["Left Shoulder"].C0 = v513.Torso["Left Shoulder"].C0:Lerp(v523, 0.2)
                v513.Torso.Neck.C0 = v513.Torso.Neck.C0:Lerp(v493 * CFrame.Angles(-math.rad(l_Value_3 * 40), 0, 0), 0.2)
                v513.HumanoidRootPart.RootJoint.C0 = v513.HumanoidRootPart.RootJoint.C0:Lerp(CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) * v521 * v522, 0.075)
            end;
        end;
    end;
    if l_values_0.gamestate.Value == "ingame" then
        if l_values_0.gamestate.sub.Value == "endgame" then
            l_Parent_0.core_game.scoreframe.center.TextColor3 = Color3.new(0.9, 0, 0)
        else
            l_Parent_0.core_game.scoreframe.center.TextColor3 = Color3.new(1, 1, 1)
        end;
        l_Parent_0.core_game.scoreframe.center.Text = f_toMS(l_values_0.gametime.Value)
        local v525 = { game.Teams["Golden Empire"], game.Teams["Royal Nation"] }
        local v526 = { l_values_0.empiretickets, l_values_0.nationtickets }
        local v527 = { l_values_0.empirerein, l_values_0.nationrein }
        local v528 = { l_values_0.empirerein.rein_arrive.Value, l_values_0.nationrein.rein_arrive.Value }
        local v529 = { l_values_0.empirerein.wait_players.Value, l_values_0.nationrein.wait_players.Value }
        local v530 = { l_Parent_0.core_game.scoreframe.empireside, l_Parent_0.core_game.scoreframe.nationside }
        l_Parent_0.core_game.scoreframe.empireside.Visible = true
        l_Parent_0.core_game.scoreframe.nationside.Visible = true
        if l_values_0.gamemode.Value == "truce" then
            l_Parent_0.core_game.scoreframe.empireside.Visible = false
            l_Parent_0.core_game.scoreframe.nationside.Visible = false
        end;
        for v531, v532 in ipairs(v530) do
            if v532.Name == "empireside" then
                v532.bar.BackgroundColor3 = Color3.fromRGB(240, 240, 140)
            else
                v532.bar.BackgroundColor3 = Color3.fromRGB(146, 25, 167)
            end;
            if v526[v531].Value > 0 then
                if v526[v531].inf.Value == true then
                    v532.num.Text = "\226\136\158"
                    v532.bar.Size = UDim2.new(1, 0, 1, 0)
                    if v526[v531].overtime.Value == true then
                        v532.num.Text = "OVERTIME"
                        v532.bar.BackgroundColor3 = Color3.new(0.8 + math.abs((math.sin(tick() * 2))) / 7, 0, 0)
                    end;
                else
                    v532.num.Text = v526[v531].Value
                    v532.bar.Size = UDim2.new(v526[v531].Value / l_values_0.base_tickets.Value, 0, 1, 0)
                end;
                if v527[v531].Value >= v527[v531].duration.Value then
                    v532.rein.Text = "Reinforcements Available"
                    if v529[v531] ~= 0 then
                        v532.rein.Text = "Waiting For " .. v529[v531] .. " Soldiers"
                    end;
                else
                    v532.rein.Text = "Reinforcements In: " .. math.ceil(v527[v531].duration.Value - v527[v531].Value)
                end;
                local v533
                if l_values_0.gamemode.Value == "laststand" and (v532.Name == "empireside" and l_values_0.gamemode_specific.attacking_team.Value == "nation" or v532.Name == "nationside" and l_values_0.gamemode_specific.attacking_team.Value == "empire") then
                    v532.bar.Size = UDim2.new(1, 0, 1, 0)
                    v532.num.Text = "LAST STAND"
                    v532.rein.Text = "Reinforcements on Standby"
                    v533 = false
                else
                    v533 = true
                end;
                if l_values_0.gamemode.Value == "truce" then
                    v532.bar.Size = UDim2.new(1, 0, 1, 0)
                    v532.num.Text = "TRUCE"
                    v533 = false
                end;
                if v528[v531] == true and v533 == true then
                    v532.rein.Text = "Reinforcements Imminent"
                    if (l_LocalPlayer_0.Character == nil or (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") == nil or l_LocalPlayer_0.Character.Humanoid.Health <= 0)) and (l_LocalPlayer_0.Team == v525[v531] and tick() - v494 >= 1) then
                        v494 = tick()
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "respawn_imminent",
                            ["location"] = l_CurrentCamera_0
                        }, true)
                    end;
                end;
            else
                v532.num.Text = "0"
                v532.bar.Size = UDim2.new(0, 0, 1, 0)
                v532.rein.Text = "No Reinforcements"
            end;
        end;
        l_Parent_0.core_game.scoreframe.Visible = true
    else
        l_Parent_0.core_game.scoreframe.Visible = false
    end;
    if workspace.serverStuff.trainingmode.Value == true then
        l_Parent_0.core_game.scoreframe.Visible = false
    end;
    if l_Parent_0.playerlist.Visible == true then
        local v534 = l_Parent_0.playerlist.empirelist:GetChildren()
        for _, v535 in ipairs(l_Parent_0.playerlist.royallist:GetChildren()) do
            table.insert(v534, v535)
        end;
        for _, v536 in ipairs(v534) do
            local v537 = game.Players:FindFirstChild((string.sub(v536.Name, 2, 10000)))
            if v537 and (v537:FindFirstChild("data_loaded") and (v537:FindFirstChild("playerstats") and v537.playerstats:FindFirstChild("class"))) then
                local l_Value_4 = v537.playerstats.rank.Value
                local v538
                if v537.Team == game.Teams["Royal Nation"] then
                    v538 = v_u_5.ranks_nation[l_Value_4]
                else
                    v538 = v_u_5.ranks_empire[l_Value_4]
                end;
                v536.rankbg.rank.Text = v538
                local v539 = game.ReplicatedStorage.outfits.icons:FindFirstChild(v537.playerstats.class.Value)
                if v537.Character and v537.Character:FindFirstChild("elitekit") then
                    v539 = game.ReplicatedStorage.outfits.elites.icons:FindFirstChild(v537.Character.elitekit.Value)
                end;
                if v537.Character and v537.Character:FindFirstChild("dreadnought") then
                    v539 = game.ReplicatedStorage.outfits.icons.dread
                end;
                if v539 then
                    v536.classbg.iconuse.Image = v539.Texture
                end;
                v536.playername.Text = v537.Name
                if v537.Character == nil or (v537.Character:FindFirstChild("class") == nil or (v537.Character:FindFirstChild("Humanoid") == nil or v537.Character:FindFirstChild("Humanoid").Health <= 0)) then
                    v536.crossout.Visible = true
                else
                    v536.crossout.Visible = false
                    local l_Name_1 = v537.Name
                    if v537.Character:FindFirstChild("perk") and (v537.Character.perk.Value ~= "none" and (v537.Character.perk.Value ~= "cursed" and (v537.Character:FindFirstChild("elitekit") == nil and v_u_5.perks[v537.Character.perk.Value]))) then
                        l_Name_1 = v_u_5.perks[v537.Character.perk.Value].name .. " " .. v537.Name
                    end;
                    v536.playername.Text = l_Name_1
                end;
            end;
        end;
    end;
    l_Parent_0.warmap.Visible = false
    l_Parent_0.remembertext.Visible = false
    game.Lighting.endposesat.Enabled = false
    if l_CurrentCamera_0.CameraType == Enum.CameraType.Scriptable and l_loadout_menu_0.Visible == false then
        l_LocalPlayer_0.CameraMaxZoomDistance = 10
        if tick() - v_u_53 <= 3 and (v_u_59 ~= nil and (v_u_59.Parent and v_u_59.Parent:FindFirstChild("Humanoid"))) then
            l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame:Lerp(CFrame.new(v_u_54, v_u_59.Position), 0.1)
        end;
        if l_values_0.gamestate.Value == "warmap" then
            l_Parent_0.warmap.Visible = true
            local v540 = math.clamp((tick() - v_u_17) / 3, 0, 1)
            l_CurrentCamera_0.CFrame = v_u_15:Lerp(v16, v540 * v540 * (3 - 2 * v540))
            local v541 = workspace.WarRoom:FindFirstChild("mainMap")
            if v541 and v541:FindFirstChild("modes") then
                for _, v542 in ipairs(v541.modes:GetChildren()) do
                    local v543 = l_Parent_0.warmap.nodes:FindFirstChild(v542.Name)
                    if v543 then
                        local v544 = l_CurrentCamera_0:WorldToViewportPoint(v542.Position)
                        v543.Position = UDim2.new(0, v544.X - 15, 0, v544.Y - 15)
                        if v542:FindFirstChild("voted") then
                            v543.votes.Text = v542.voted.Value
                            v543.votes.Visible = true
                        else
                            v543.votes.Visible = false
                        end;
                    end;
                end;
            end;
        end;
        if l_values_0.gamestate.Value == "endpose" then
            l_Parent_0.remembertext.Visible = true
            game.Lighting.endposesat.Enabled = true
            l_CurrentCamera_0.CFrame = CFrame.new(-974.428955, -51.8881607, -368.655762, 0.0156116411, -0.0467474945, 0.998784781, 5.82076609e-11, 0.998906612, 0.0467531867, -0.999878228, -0.000729893916, 0.0155945681)
        end;
    end;
    if l_values_0.gamestate.Value ~= "endpose" and l_CurrentCamera_0.CFrame == CFrame.new(-974.428955, -51.8881607, -368.655762, 0.0156116411, -0.0467474945, 0.998784781, 5.82076609e-11, 0.998906612, 0.0467531867, -0.999878228, -0.000729893916, 0.0155945681) then
        l_CurrentCamera_0.CFrame = v_u_55.customisationframe
    end;
    if l_values_0.gamestate.Value == "lobby" then
        s_UserInputService_0.MouseDeltaSensitivity = 1
        s_UserInputService_0.MouseIconEnabled = true
        s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
        l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
        if l_Parent_0.loadout_menu.Visible == false then
            l_Parent_0.core_game.Visible = true
            if l_LocalPlayer_0.Character and l_LocalPlayer_0.Character:FindFirstChild("Humanoid") then
                if v499 == false then
                    _G.fadetoblack = tick()
                    v499 = true
                end;
                l_Parent_0.core_game.Visible = true
                s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
                l_CurrentCamera_0.FieldOfView = 70
                l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
                l_CurrentCamera_0.CameraSubject = l_LocalPlayer_0.Character.Humanoid
            else
                _G.fadetoblack = tick()
                v499 = false
            end;
        end;
    else
        v499 = false
    end;
    if workspace.serverStuff.trainingmode.Value == true then
        l_loadout_menu_0.totalblackout.Visible = true
        l_Parent_0.core_game.deathscreen.totalblackout.Visible = true
    end;
    local v545 = math.sin(math.clamp((tick() - v_u_58) / 1.5, 0, 1) * 3.141592653589793 * 0.5)
    local v546 = v_u_55[_G.cam_menu_at]
    if l_loadout_menu_0.Visible == true then
        l_CurrentCamera_0.CFrame = (v546 - v546.lookVector * 3):Lerp(v546, v545)
        local v547 = {}
        for _, v548 in ipairs((game.Players:GetPlayers())) do
            if v548:FindFirstChild("playerstats") and (v548.playerstats:FindFirstChild("class") and v548.Team == l_LocalPlayer_0.Team) then
                if v547[v548.playerstats.class.Value] then
                    v547[v548.playerstats.class.Value] = v547[v548.playerstats.class.Value] + 1
                else
                    v547[v548.playerstats.class.Value] = 1
                end;
            end;
        end;
        for _, v549 in ipairs(l_loadout_menu_0.customisationframe.classes:GetChildren()) do
            local v550 = v549:FindFirstChild("classcount")
            if v550 and v549.Name ~= "ex" then
                if v547[v549.Name] == nil then
                    v550.Text = 0
                else
                    v550.Text = v547[v549.Name]
                end;
            end;
        end;
    end;
    l_loadout_menu_0.blackout.BackgroundTransparency = v_u_2:lerp(0, 1, v545)
    if _G.get_settings("dynamicreverb") == true then
        game.SoundService.AmbientReverb = Enum.ReverbType.StoneRoom
    elseif tick() - v495 >= 0.5 then
        v495 = tick()
        if v_u_2:raycastline({
            ["point"] = l_CurrentCamera_0.CFrame.Position,
            ["destination"] = CFrame.new(l_CurrentCamera_0.CFrame.Position).UpVector,
            ["range"] = 20,
            ["layermask"] = v496
        }) then
            game.SoundService.AmbientReverb = Enum.ReverbType.StoneRoom
        else
            game.SoundService.AmbientReverb = Enum.ReverbType.ConcertHall
        end;
    end;
    l_Parent_0.core_game.deathscreen.spawnframe.Visible = false
    if l_values_0.gamemode.Value == "train" and (l_values_0.gamemode_specific.attacking_team.Value == "nation" and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] or l_values_0.gamemode_specific.attacking_team.Value == "empire" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) and l_values_0.gamestate.Value == "ingame" then
        l_Parent_0.core_game.deathscreen.spawnframe.Visible = true
    end;
    if l_Parent_0.core_game.deathscreen.spawnframe.Visible == true and l_Parent_0.core_game.deathscreen.Visible == true then
        for _, v551 in ipairs(l_Parent_0.core_game.deathscreen.spawnframe.spawns:GetChildren()) do
            if v551:IsA("ImageButton") then
                if v551.Name == v_u_7.spawn_point.Value then
                    v551.BackgroundColor3 = Color3.new(1, 1, 1)
                else
                    v551.BackgroundColor3 = Color3.new(0, 0, 0)
                end;
            end;
        end;
    end;
    l_RenderStepped_0:wait()
end;
