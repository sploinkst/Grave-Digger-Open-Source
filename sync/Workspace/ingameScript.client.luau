game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
local l_LocalPlayer_0 = game.Players.LocalPlayer
local l_Character_0 = l_LocalPlayer_0.Character
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local s_UserInputService_0 = game:GetService("UserInputService")
local l_CurrentCamera_0 = workspace.CurrentCamera
local v_u_1 = l_Character_0:WaitForChild("Humanoid", 100)
local l_remotes_0 = workspace.remotes
local v_u_2 = require(game.ReplicatedStorage.shared.bFunctions)
local l_core_game_0 = l_LocalPlayer_0.PlayerGui:FindFirstChild("main").core_game
local v_u_3 = require(game.ReplicatedStorage.shared.base)
local v_u_4 = require(game.ReplicatedStorage.shared.visualEffects)
local v5 = require(game.ReplicatedStorage.shared.equipments)
local s_Debris_0 = game:GetService("Debris")
local v_u_6 = l_Character_0:WaitForChild("HumanoidRootPart", 100)
local v_u_7 = l_LocalPlayer_0:WaitForChild("playerstats", 100)
local v_u_8 = l_Character_0:WaitForChild("perk", 100)
local v_u_9 = l_Character_0:WaitForChild("class", 100)
local v_u_10 = v5[v_u_9.Value]
local v_u_11 = l_Character_0:WaitForChild("equipment", 100)
local v_u_12 = l_Character_0:WaitForChild("chems", 100)
local v_u_13 = {}
for _, v14 in ipairs(game.ReplicatedStorage.weapon_modules:GetChildren()) do
    v_u_13[v14.Name] = require(v14)
end;
local s_GamepadService_0 = game:GetService("GamepadService")
game:GetService("RunService"):UnbindFromRenderStep("MainLoop")
v_u_1:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
v_u_1:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
s_UserInputService_0.MouseIconEnabled = true
s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
l_core_game_0.akimbocrosshair.Visible = false
l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
spawn(function() --[[ Line: 41 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0 ]]
    if _G.get_settings("autofirstperson") == true then
        l_LocalPlayer_0.CameraMode = Enum.CameraMode.LockFirstPerson
    end;
end)
if l_core_game_0.Parent.loadout_menu.Visible == false then
    if l_LocalPlayer_0.PlayerGui:FindFirstChild("loadingmenu") == nil and l_LocalPlayer_0.PlayerGui:FindFirstChild("loadingdone") == nil then
        s_GamepadService_0:DisableGamepadCursor()
    end;
    l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
    l_CurrentCamera_0.CameraSubject = v_u_1
    l_core_game_0.Visible = true
else
    s_GamepadService_0:EnableGamepadCursor(l_core_game_0.Parent.loadout_menu)
    s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
    l_CurrentCamera_0.CameraType = Enum.CameraType.Scriptable
    l_CurrentCamera_0.FieldOfView = 40
    l_CurrentCamera_0.CFrame = _G.cam_menu_positions[_G.cam_menu_at]
end;
local v15 = workspace.serverStuff:WaitForChild("empire_spawnroom", 100)
local v16 = workspace.serverStuff:WaitForChild("nation_spawnroom", 100)
local v17, v_u_18
if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
    v17 = v15
    v_u_18 = v16
else
    v17 = v16
    v_u_18 = v15
end;
if v_u_18:FindFirstChild("spawnprotection") then
    for _, v19 in ipairs(v_u_18.spawnprotection:GetChildren()) do
        v19.CanCollide = false
        v19.CanQuery = false
        v19.CanTouch = false
    end;
end;
if v17:FindFirstChild("spawnprotection") then
    for _, v20 in ipairs(v17.spawnprotection:GetChildren()) do
        v20.CanCollide = true
        v20.CanQuery = true
        v20.CanTouch = true
    end;
end;
for _, v21 in ipairs(l_core_game_0.splatters:GetChildren()) do
    if v21.Name ~= "ex" then
        v21:Destroy()
    end;
end;
v15.basecenter.bb.Enabled = false
v16.basecenter.bb.Enabled = false
l_core_game_0.Parent.dot_crosshair.Visible = false
l_core_game_0.helmetoverlay.Visible = false
local v_u_22 = game.ReplicatedStorage.misc.clickerhighlight:Clone()
if _G.get_settings and _G.get_settings("disableinteractionhighlight") == true then
    v_u_22:Destroy()
    v_u_22 = nil
end;
if l_Character_0:FindFirstChild("dreadnought") then
    l_core_game_0.helmetoverlay.Visible = true
end;
delay(1, function() --[[ Line: 111 ]]
    --[[ Upvalues: (copy 1): l_core_game_0, (copy 2): l_CurrentCamera_0, (copy 3): v_u_1, (copy 4): l_Character_0 ]]
    if l_core_game_0.Parent.loadout_menu.Visible == false then
        l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
        l_CurrentCamera_0.CameraSubject = v_u_1
    end;
    if l_Character_0 and (v_u_1 and v_u_1.Health > 0) then
        l_core_game_0.deathscreen.Visible = false
    end;
    if _G.killcam_outline then
        _G.killcam_outline:Destroy()
        _G.killcam_outline = nil
    end;
end)
if _G.killcam_outline then
    _G.killcam_outline:Destroy()
    _G.killcam_outline = nil
end;
repeat
    local l_keysheld_0 = _G.keysheld
    l_RenderStepped_0:Wait()
until l_keysheld_0 ~= nil;
if workspace.serverStuff.values.gamemode.Value == "truce" then
    spawn(function() --[[ Line: 139 ]]
        --[[ Upvalues: (ref 1): v_u_18, (copy 2): v_u_2, (copy 3): l_CurrentCamera_0, (copy 4): l_remotes_0 ]]
        local v23 = v_u_18:WaitForChild("trucepos", 100)
        local v_u_24 = v23:WaitForChild("trucegui", 100)
        if v23 and (v_u_24 and (v_u_24:FindFirstChild("voted") == nil and (v_u_24:FindFirstChild("fightvote") and v_u_24:FindFirstChild("trucevote")))) then
            v_u_24.trucevote.MouseButton1Click:Connect(function() --[[ Line: 148 ]]
                --[[ Upvalues: (copy 1): v_u_24, (ref 2): v_u_2, (ref 3): l_CurrentCamera_0, (ref 4): l_remotes_0 ]]
                if not v_u_24:FindFirstChild("voted") then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "button",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "voted",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "dogtag",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    local l_StringValue_0 = Instance.new("StringValue")
                    l_StringValue_0.Name = "voted"
                    l_StringValue_0.Parent = v_u_24
                    v_u_24.trucevote.Text = "Voted"
                    l_remotes_0.game_handler:FireServer("trucevoting", "truce")
                    v_u_24.fightvote:Destroy()
                end;
            end)
            v_u_24.fightvote.MouseButton1Click:Connect(function() --[[ Line: 182 ]]
                --[[ Upvalues: (copy 1): v_u_24, (ref 2): v_u_2, (ref 3): l_CurrentCamera_0, (ref 4): l_remotes_0 ]]
                if not v_u_24:FindFirstChild("voted") then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "button",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "voted",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "votefight",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    local l_StringValue_1 = Instance.new("StringValue")
                    l_StringValue_1.Name = "voted"
                    l_StringValue_1.Parent = v_u_24
                    v_u_24.fightvote.Text = "Voted"
                    l_remotes_0.game_handler:FireServer("trucevoting", "fight")
                    v_u_24.trucevote:Destroy()
                end;
            end)
        end;
    end)
end;
local v_u_25 = l_core_game_0.scoreframe.objective_uis:FindFirstChild(workspace.serverStuff.values.gamemode.Value)
for _, v26 in ipairs(l_core_game_0.scoreframe.objective_uis:GetChildren()) do
    v26.Visible = false
    if v26.Name ~= "ex" then
        for _, v27 in ipairs(v26:GetChildren()) do
            if v27.Name ~= "UIListLayout" and v27.Name ~= "objpiece" then
                v27:Destroy()
            end;
        end;
    end;
end;
local v_u_28 = Color3.fromRGB(167, 83, 170)
local v_u_29 = Color3.fromRGB(255, 248, 47)
local v_u_30 = {}
local v_u_31 = false
if v_u_25 then
    if v_u_25.Name == "push" then
        for _, v32 in ipairs(v_u_25.objpiece:GetChildren()) do
            if v32.Name ~= "UIListLayout" then
                v32:Destroy()
            end;
        end;
        l_core_game_0.objpopup.Position = UDim2.new(0.5, 0, 0.11, 0)
    else
        l_core_game_0.objpopup.Position = UDim2.new(0.5, 0, 0.1, 0)
    end;
    if v_u_25.Name == "train" then
        for _, v33 in ipairs(v_u_25.UIListLayout:GetChildren()) do
            if v33.Name ~= "UIListLayout" and v33.Name ~= "homeicon" then
                v33:Destroy()
            end;
        end;
        l_core_game_0.objpopup.Position = UDim2.new(0.5, 0, 0.11, 0)
    end;
    for _, v34 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
        local v35 = l_core_game_0.scoreframe.objective_uis.ex:Clone()
        v35.Name = v34.Name
        v35.Parent = v_u_25
        if v_u_25.Name == "push" then
            v35.Parent = v_u_25.objpiece
        end;
        if v_u_25.Name == "train" then
            if v34.Name == "objectiveA" then
                v35.LayoutOrder = 1
            elseif v34.Name == "objectiveB" then
                v35.LayoutOrder = 5
            end;
            v35.Parent = v_u_25.UIListLayout
        end;
    end;
    if v_u_25.Name == "assault" then
        v_u_25.objpiece.TextColor3 = v_u_28
        local v36
        if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
            v_u_25.objpiece.TextColor3 = v_u_29
            v36 = "empire"
        else
            v36 = "nation"
        end;
        if workspace.serverStuff.values.gamemode_specific.attacking_team.Value == v36 then
            v_u_25.objpiece.Text = "ATTACK"
        else
            v_u_25.objpiece.Text = "DEFEND"
        end;
    end;
    if v_u_25.Name == "train" then
        v_u_25.objpiece.top.TextColor3 = v_u_28
        local v37
        if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
            v_u_25.objpiece.top.TextColor3 = v_u_29
            v37 = "empire"
        else
            v37 = "nation"
        end;
        if workspace.serverStuff.values.gamemode_specific.attacking_team.Value ~= "empire" then
            v_u_29 = v_u_28
        end;
        v_u_25.objpiece.BackgroundColor3 = v_u_29
        v_u_25.objpiece.train.gradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, v_u_29), ColorSequenceKeypoint.new(0.9999, v_u_29), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)) })
        v_u_25.UIListLayout.homeicon.ImageColor3 = v_u_29
        if workspace.serverStuff.values.gamemode_specific.attacking_team.Value == v37 then
            v_u_25.objpiece.top.Text = "DEFEND"
        else
            v_u_25.objpiece.top.Text = "ATTACK"
        end;
    end;
    if v_u_25.Name == "laststand" then
        local v38
        if workspace.serverStuff.values.gamemode_specific.attacking_team.Value == "nation" then
            v38 = v_u_29
        else
            v38 = v_u_28
        end;
        v_u_25.objpiece.gatehealth.bar.BackgroundColor3 = v38
        v_u_25.objpiece.top.TextColor3 = v38
    end;
end;
l_core_game_0.fadetoblack.BackgroundTransparency = 0
_G.fadetoblack = tick()
l_core_game_0.crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
l_core_game_0.crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
l_core_game_0.scoreframe.objective_uis.Visible = false
if v_u_18 then
    v_u_18:WaitForChild("basecenter", 100).bb.Enabled = true
end;
for _, v39 in ipairs(l_core_game_0.rotating_indicator:GetChildren()) do
    if v39.Name ~= "ex" then
        v39:Destroy()
    end;
end;
local v_u_40 = workspace.serverStuff:WaitForChild("empire_spawnroom", 100)
local v_u_41 = workspace.serverStuff:WaitForChild("nation_spawnroom", 100)
local v_u_42 = v_u_40:FindFirstChild("empire_spawnprot")
local v_u_43 = v_u_41:FindFirstChild("nation_spawnprot")
local l_ObjectValue_0 = Instance.new("ObjectValue")
l_ObjectValue_0.Name = "turret_mounted"
l_ObjectValue_0.Parent = l_Character_0
local v_u_44
if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
    v_u_44 = v_u_43
else
    v_u_44 = v_u_42
end;
local v_u_45 = {
    workspace.notarget,
    workspace.evacs,
    workspace.throwables,
    l_Character_0,
    l_Character_0.Parent,
    l_CurrentCamera_0,
    v_u_44
}
local v_u_46 = {
    workspace.notarget,
    workspace.evacs,
    workspace.throwables,
    workspace.bodies,
    l_Character_0,
    l_CurrentCamera_0,
    v_u_44
}
local v_u_47 = {
    workspace.notarget,
    workspace.evacs,
    workspace.throwables,
    workspace.nation_team,
    workspace.empire_team,
    workspace.bodies,
    l_CurrentCamera_0,
    v_u_44
}
local v_u_48 = {
    workspace.notarget,
    workspace.evacs,
    workspace.throwables,
    workspace.constructions,
    workspace.nation_team,
    workspace.empire_team,
    workspace.bodies,
    workspace.serverStuff,
    l_CurrentCamera_0
}
if workspace.serverStuff.trainingmode.Value == true then
    v_u_48 = {
        workspace.notarget,
        workspace.evacs,
        workspace.throwables,
        workspace.constructions,
        workspace.nation_team,
        workspace.empire_team,
        workspace.bodies,
        l_CurrentCamera_0
    }
    spawn(function() --[[ Line: 398 ]]
        game:GetService("ContentProvider"):PreloadAsync(game.ReplicatedStorage.animations.npcs.training:GetChildren())
    end)
end;
for _, v49 in ipairs(l_CurrentCamera_0:GetChildren()) do
    v49:Destroy()
end;
local v_u_50 = OverlapParams.new()
v_u_50.FilterDescendantsInstances = { workspace.constructions }
v_u_50.FilterType = Enum.RaycastFilterType.Include
v_u_50.MaxParts = 10
local v_u_51 = OverlapParams.new()
v_u_51.FilterDescendantsInstances = { l_Character_0 }
v_u_51.FilterType = Enum.RaycastFilterType.Include
v_u_51.MaxParts = 10
local v_u_52 = game.ReplicatedStorage.misc.healthbb:Clone()
v_u_52.bb.Enabled = false
v_u_52.Parent = l_CurrentCamera_0
local v_u_53 = game.ReplicatedStorage.misc.equipment_bb:Clone()
v_u_53.bb.progress.frame1.img.ImageTransparency = 1
v_u_53.bb.progress.frame2.img.ImageTransparency = 1
v_u_53.bb.count.TextTransparency = 1
v_u_53.Parent = l_CurrentCamera_0
local v_u_54 = game.ReplicatedStorage.misc.assist_icon:Clone()
v_u_54.Parent = l_CurrentCamera_0
local v_u_55 = l_CurrentCamera_0:FindFirstChild("ammo_check")
if v_u_55 == nil then
    v_u_55 = game.ReplicatedStorage.misc.ammo_check:Clone()
    v_u_55.Parent = l_CurrentCamera_0
end;
v_u_1.AutoRotate = true
local l_Part_0 = Instance.new("Part")
l_Part_0.Name = "lockpart"
l_Part_0.Transparency = 1
l_Part_0.Anchored = true
l_Part_0.CanCollide = false
l_Part_0.Locked = true
l_Part_0.Massless = true
l_Part_0.CanQuery = false
l_Part_0.Parent = l_CurrentCamera_0
if l_CurrentCamera_0:FindFirstChild("camroot") then
    l_CurrentCamera_0.camroot:Destroy()
end;
l_core_game_0.healthlow.ImageTransparency = 1
l_core_game_0.morale.ImageTransparency = 1
l_core_game_0.injuredhealth.ImageTransparency = 1
l_core_game_0.holdbreath.ImageTransparency = 1
l_core_game_0.deathscreen.Visible = false
l_core_game_0.deathscreen.bottomframe.lowertext.Text = ""
l_core_game_0.binocsoverlay.Visible = false
local l_Attachment_0 = Instance.new("Attachment")
l_Attachment_0.Name = "a0"
l_Attachment_0.Parent = v_u_6
local l_Attachment_1 = Instance.new("Attachment")
l_Attachment_1.Name = "a1"
l_Attachment_1.Parent = l_Part_0
local v_u_56 = game.ReplicatedStorage.misc.alignment:Clone()
v_u_56.Attachment0 = l_Attachment_0
v_u_56.Attachment1 = l_Attachment_1
v_u_56.Parent = v_u_6
l_core_game_0.traitortext.Visible = false
l_core_game_0.crosshair.main.Visible = true
local l_BoolValue_0 = Instance.new("BoolValue")
l_BoolValue_0.Name = "action"
l_BoolValue_0.Value = false
l_BoolValue_0.Parent = l_Character_0
local v_u_57 = l_CurrentCamera_0:FindFirstChild("blur")
if v_u_57 == nil then
    v_u_57 = Instance.new("BlurEffect")
    v_u_57.Name = "blur"
    v_u_57.Size = 0
    v_u_57.Parent = l_CurrentCamera_0
end;
v_u_57.Size = 0
local v_u_58 = l_CurrentCamera_0:FindFirstChild("cc")
if v_u_58 == nil then
    v_u_58 = Instance.new("ColorCorrectionEffect")
    v_u_58.Name = "cc"
    v_u_58.Saturation = 0
    v_u_58.Parent = l_CurrentCamera_0
end;
v_u_58.Saturation = 0
game.SoundService.mainSoundGroup.Volume = v_u_3.default_soundgroup
game.SoundService.radioSoundGroup.Volume = v_u_3.default_radiogroup
workspace.ambience.Volume = v_u_3.default_ambience
game:GetService("SoundService").mainSoundGroup.comp.Enabled = false
game:GetService("SoundService").maskSoundGroup.comp.Enabled = false
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
for _, v59 in ipairs(l_core_game_0.inventory:GetChildren()) do
    if v59.Name ~= "ex" and v59.Name ~= "UIListLayout" then
        v59:Destroy()
    end;
end;
local v_u_60 = game.ReplicatedStorage.misc.screen:Clone()
v_u_60.Parent = l_CurrentCamera_0
l_core_game_0.inventory.Visible = true
l_core_game_0.objpopup.Visible = false
l_core_game_0.barrelobstruction.Visible = false
if v_u_8.Value == "ghost" then
    game.ReplicatedStorage.misc.apparitionlight:Clone().Parent = v_u_6
end;
if l_core_game_0:FindFirstChild("vignette") then
    l_core_game_0.vignette:Destroy()
end;
if v_u_8.Value == "cursed" then
    local v61 = game.ReplicatedStorage.sound_library.tutorial.warsounds:Clone()
    v61.Volume = 0.2
    v61.Parent = l_CurrentCamera_0
    v61:Play()
    game.ReplicatedStorage.misc.vignette:Clone().Parent = l_core_game_0
end;
local function v_u_67(p62) --[[ Line: 554 ]]
    --[[ Upvalues: (copy 1): v_u_13, (copy 2): l_core_game_0, (copy 3): l_LocalPlayer_0 ]]
    if not p62:FindFirstChild("no_backpack") then
        local v63 = not game.ReplicatedStorage.weapon_modules:FindFirstChild(p62.weapon.Value) and "empty" or v_u_13[p62.weapon.Value]
        local v64 = l_core_game_0.inventory:FindFirstChild("empty" .. p62.slot.Value)
        if v64 then
            v64:Destroy()
        end;
        if v63 and l_core_game_0.inventory:FindFirstChild(p62.weapon.Value .. p62.slot.Value) == nil then
            local v65 = l_core_game_0.inventory.ex:Clone()
            v65.Visible = true
            v65.LayoutOrder = p62.slot.Value
            v65.Name = p62.weapon.Value .. p62.slot.Value
            local v66
            if v63 == "empty" then
                v66 = "17768266447"
            else
                v66 = v63.icon
                if v63 and (v63.alt_team_icon and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) then
                    v66 = v63.alt_team_icon
                end;
            end;
            v65.icon.Image = "rbxassetid://" .. v66
            v65.num.Text = p62.slot.Value
            v65.Parent = l_core_game_0.inventory
        end;
    end;
end;
local v_u_68 = {}
for _, v69 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
    if v69:IsA("Tool") and (v69:FindFirstChild("slot") and v69:FindFirstChild("weapon")) then
        v_u_67(v69)
        v_u_68[v69.slot.Value] = v69
    end;
end;
delay(2, function() --[[ Line: 598 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0, (copy 2): v_u_67, (copy 3): v_u_68 ]]
    for _, v70 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
        if v70:IsA("Tool") and (v70:FindFirstChild("slot") and (v70:FindFirstChild("weapon") and (v70.Name ~= "empty" and v70.weapon.Value ~= "empty"))) then
            v_u_67(v70)
            v_u_68[v70.slot.Value] = v70
        end;
    end;
end)
local v_u_71 = {}
for _, v72 in ipairs(game.ReplicatedStorage.animations.shared:GetChildren()) do
    v_u_71[v72.Name] = l_Character_0.Humanoid:LoadAnimation(v72)
    v_u_71[v72.Name].Priority = Enum.AnimationPriority.Action3
end;
for _, v73 in ipairs(game.ReplicatedStorage.animations.equipment:GetChildren()) do
    v_u_71[v73.Name] = l_Character_0.Humanoid:LoadAnimation(v73)
    v_u_71[v73.Name].Priority = Enum.AnimationPriority.Action2
end;
v_u_71.left_axethrow.Priority = Enum.AnimationPriority.Action3
v_u_71.right_axethrow.Priority = Enum.AnimationPriority.Action3
v_u_71.left_axesheath.Priority = Enum.AnimationPriority.Action2
v_u_71.right_axesheath.Priority = Enum.AnimationPriority.Action2
v_u_71.ladder_climb.Priority = Enum.AnimationPriority.Action2
local v_u_74 = nil
if l_Character_0:FindFirstChild("spawnanim") then
    local v75 = game.ReplicatedStorage.animations.spawns:FindFirstChild(l_Character_0.spawnanim.Value)
    if v75 then
        local v76 = v75:GetChildren()
        local v77 = v76[math.random(1, #v76)]
        if workspace.serverStuff.trainingmode.Value == true then
            v77 = game.ReplicatedStorage.animations.spawns.lie.lie2
        end;
        v_u_74 = l_Character_0.Humanoid:LoadAnimation(v77)
        v_u_74.Priority = Enum.AnimationPriority.Action4
        spawn(function() --[[ Line: 642 ]]
            --[[ Upvalues: (ref 1): v_u_74 ]]
            if v_u_74 then
                v_u_74:Play(0, 1, 0.2)
            end;
        end)
    end;
end;
local v_u_78 = tick()
local function _() --[[ Name: break_spawnanim ]] --[[ Line: 651 ]]
    --[[ Upvalues: (copy 1): v_u_78, (ref 2): v_u_74 ]]
    if tick() - v_u_78 > 0.3 then
        if v_u_74 then
            v_u_74:Stop(0.4)
            v_u_74:Destroy()
            v_u_74 = nil
        end;
    end;
end;
v_u_71.miss_flinch1.Priority = Enum.AnimationPriority.Action4
v_u_71.miss_flinch2.Priority = Enum.AnimationPriority.Action4
v_u_71.miss_flinch3.Priority = Enum.AnimationPriority.Action4
v_u_71.miss_flinch4.Priority = Enum.AnimationPriority.Action4
v_u_71.flinch_head1.Priority = Enum.AnimationPriority.Action4
v_u_71.flinch_head2.Priority = Enum.AnimationPriority.Action4
v_u_71.injured_left.Priority = Enum.AnimationPriority.Action2
v_u_71.injured_right.Priority = Enum.AnimationPriority.Action2
v_u_71.burning_left.Priority = Enum.AnimationPriority.Action2
v_u_71.burning_right.Priority = Enum.AnimationPriority.Action2
v_u_71.burning_heavy.Priority = Enum.AnimationPriority.Action4
v_u_71.leg_aiming.Priority = Enum.AnimationPriority.Core
v_u_71.crouch_idle.Priority = Enum.AnimationPriority.Idle
v_u_71.crouch_arms.Priority = Enum.AnimationPriority.Idle
v_u_71.walk_forward.Priority = Enum.AnimationPriority.Idle
v_u_71.walk_injured.Priority = Enum.AnimationPriority.Idle
v_u_71.walk_left.Priority = Enum.AnimationPriority.Idle
v_u_71.walk_right.Priority = Enum.AnimationPriority.Idle
v_u_71.crouchwalk_forward.Priority = Enum.AnimationPriority.Idle
v_u_71.crouchwalk_left.Priority = Enum.AnimationPriority.Idle
v_u_71.crouchwalk_right.Priority = Enum.AnimationPriority.Idle
v_u_71.jump_midair.Priority = Enum.AnimationPriority.Movement
v_u_71.arms_midair.Priority = Enum.AnimationPriority.Movement
v_u_71.jump_land.Priority = Enum.AnimationPriority.Movement
v_u_71.sprinting_arms.Priority = Enum.AnimationPriority.Movement
v_u_71.sprinting_lean.Priority = Enum.AnimationPriority.Action2
v_u_71.sprinting_full.Priority = Enum.AnimationPriority.Action2
v_u_71.ammo_restock_left.Priority = Enum.AnimationPriority.Action2
v_u_71.ammo_restock_right.Priority = Enum.AnimationPriority.Action2
v_u_71.restock_weapons.Priority = Enum.AnimationPriority.Action2
v_u_71.helmet_restock.Priority = Enum.AnimationPriority.Action2
v_u_71.cache_restock.Priority = Enum.AnimationPriority.Action2
v_u_71.retrieve_telescope.Priority = Enum.AnimationPriority.Action2
v_u_71.retrieve_lewisshield.Priority = Enum.AnimationPriority.Action2
v_u_71.drop_rifle.Priority = Enum.AnimationPriority.Action2
v_u_71.drop_pistol.Priority = Enum.AnimationPriority.Action2
v_u_71.compass_right.Priority = Enum.AnimationPriority.Action2
v_u_71.compass_left.Priority = Enum.AnimationPriority.Action2
v_u_71.facewipe_left.Priority = Enum.AnimationPriority.Action2
v_u_71.facewipe_right.Priority = Enum.AnimationPriority.Action2
v_u_71.cough_left.Priority = Enum.AnimationPriority.Action2
v_u_71.cough_right.Priority = Enum.AnimationPriority.Action2
v_u_71.request_larm.Priority = Enum.AnimationPriority.Action2
v_u_71.request_rarm.Priority = Enum.AnimationPriority.Action2
v_u_71.mortheal_left.Priority = Enum.AnimationPriority.Action2
v_u_71.mortheal_right.Priority = Enum.AnimationPriority.Action2
v_u_71.coverexplosion_rarm.Priority = Enum.AnimationPriority.Action2
v_u_71.coverexplosion_larm.Priority = Enum.AnimationPriority.Action2
v_u_71.fall1.Priority = Enum.AnimationPriority.Action4
v_u_71.fall2.Priority = Enum.AnimationPriority.Action4
v_u_71.fallbeartrap.Priority = Enum.AnimationPriority.Action4
v_u_71.fallroll.Priority = Enum.AnimationPriority.Action4
v_u_71.fallvanguard.Priority = Enum.AnimationPriority.Action4
v_u_71.shieldknock.Priority = Enum.AnimationPriority.Action3
v_u_71.lewisknock.Priority = Enum.AnimationPriority.Action3
v_u_71.back_wall_right.Priority = Enum.AnimationPriority.Action2
v_u_71.back_wall_left.Priority = Enum.AnimationPriority.Action2
for _, v79 in ipairs({
    v_u_71.raise_flag,
    v_u_71.burning_left,
    v_u_71.burning_right,
    v_u_71.burning_heavy
}) do
    v79.KeyframeReached:connect(function(p80) --[[ Line: 743 ]]
        --[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_2 ]]
        if string.sub(p80, 1, 4) == "gsfx" then
            if l_Character_0 == nil or l_Character_0:FindFirstChild("HumanoidRootPart") == nil then
                return;
            end;
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = string.sub(p80, 6, 100) .. math.random(1, #game.ReplicatedStorage.sound_library.tools.shared.gsfx:FindFirstChild((string.sub(p80, 6, 100))):GetChildren()),
                ["pitchvariation"] = 0.1,
                ["location"] = l_Character_0.HumanoidRootPart
            })
        end;
    end)
end;
local v_u_81 = {
    ["aiming"] = false,
    ["aim_time"] = 0,
    ["aim_sound"] = false,
    ["morale"] = false,
    ["adsing"] = false,
    ["accuracy_modifier"] = 1,
    ["handling_modifier"] = 1,
    ["draw_modifier"] = 1,
    ["jump_tick"] = 0,
    ["force_jump_tick"] = 0,
    ["in_air"] = false,
    ["in_air_timer"] = 0,
    ["floor"] = nil,
    ["check_ammo"] = 0,
    ["int_speed"] = 0,
    ["base_speed"] = v_u_3.base_walkspeed,
    ["speed_mod"] = 0,
    ["last_damage"] = 0,
    ["flip_cam"] = false,
    ["jumped_air"] = false,
    ["air_just_jumped"] = 0,
    ["shift_locked"] = true,
    ["sprinting"] = false,
    ["sprinting_max_speed"] = false,
    ["sprint_ticker"] = tick(),
    ["sprint_block"] = false,
    ["sprint_wall_stopper"] = 0,
    ["sprint_force_stop"] = 0,
    ["sprint_slowed_aim"] = 0,
    ["gun_crosshair"] = false,
    ["inventory_display"] = tick(),
    ["queue_inv"] = nil,
    ["inv_swapping"] = true,
    ["inv_block_reason"] = "",
    ["moving_accuracy"] = tick(),
    ["standing_still"] = tick(),
    ["lifetime"] = tick(),
    ["fall_damage_interrupt"] = 0,
    ["last_fall_damage_roll"] = tick(),
    ["crouching"] = false,
    ["crouching_cd"] = tick(),
    ["no_swap_ticker"] = 0,
    ["holding_breath"] = false,
    ["hold_breathtime"] = 0,
    ["hold_breathmax"] = v_u_3.base_holdbreath_time,
    ["hold_breathregen"] = v_u_3.base_holdbreath_regen,
    ["hold_breathaccuracy"] = v_u_3.base_holdbreath_maxaccuracy,
    ["healing_anim_self"] = false,
    ["equipment_show_cd"] = 0,
    ["equipment_ticker"] = 0,
    ["charging"] = false,
    ["charging_direction"] = nil,
    ["slow_rotate"] = false,
    ["friendly_target"] = nil,
    ["selection_box_selected"] = "",
    ["sick"] = false
}
_G.ping_locked = false
local l_Value_0 = workspace.serverStuff.serverTick.Value
local v_u_82 = tick()
local v_u_83 = tick()
local l_selectionboxes_0 = l_core_game_0.selectionboxes
l_selectionboxes_0.Visible = false
l_selectionboxes_0.selectedoption.Text = ""
for _, v84 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
    if v84.Name ~= "UIListLayout" and v84.Name ~= "ex" then
        v84:Destroy()
    end;
end;
local function v_u_87(p85) --[[ Line: 856 ]]
    --[[ Upvalues: (copy 1): l_selectionboxes_0 ]]
    if l_selectionboxes_0.Visible ~= false then
        if p85:FindFirstChild("display") and p85:FindFirstChild("highlighted") then
            l_selectionboxes_0.selectedoption.Text = p85.display.Value
            for _, v86 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
                if v86:FindFirstChild("highlighted") and v86.Visible == true then
                    v86.highlighted.Visible = false
                end;
            end;
            p85.highlighted.Visible = true
        end;
    end;
end;
v_u_81.create_selectionbox = function(p88, p_u_89, p90, p91, p92) --[[ Line: 871 ]]
    --[[ Upvalues: (copy 1): v_u_1, (copy 2): l_selectionboxes_0, (copy 3): v_u_87, (copy 4): v_u_81 ]]
    if v_u_1 == nil or v_u_1.Health <= 0 then
        for _, v93 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
            if v93.Name ~= "UIListLayout" and v93.Name ~= "ex" then
                v93:Destroy()
            end;
        end;
    else
        local v_u_94 = l_selectionboxes_0.selections.ex:Clone()
        v_u_94.Name = p_u_89
        v_u_94.internal.Value = p_u_89
        v_u_94.display.Value = p88
        v_u_94.LayoutOrder = p92
        v_u_94.num.Text = p92
        if p91 ~= nil then
            v_u_94.Name = p91
        end;
        v_u_94.icon.Image = "rbxassetid://" .. p90
        v_u_94.Parent = l_selectionboxes_0.selections
        v_u_94.MouseEnter:Connect(function() --[[ Line: 895 ]]
            --[[ Upvalues: (ref 1): v_u_87, (copy 2): v_u_94 ]]
            v_u_87(v_u_94)
        end)
        v_u_94.MouseLeave:Connect(function() --[[ Line: 899 ]]
            --[[ Upvalues: (ref 1): l_selectionboxes_0, (copy 2): v_u_94 ]]
            if l_selectionboxes_0.Visible ~= false then
                l_selectionboxes_0.selectedoption.Text = ""
                v_u_94.highlighted.Visible = false
            end;
        end)
        v_u_94.MouseButton1Click:Connect(function() --[[ Line: 907 ]]
            --[[ Upvalues: (ref 1): l_selectionboxes_0, (ref 2): v_u_81, (copy 3): p_u_89 ]]
            if l_selectionboxes_0.Visible ~= false then
                l_selectionboxes_0.Visible = false
                l_selectionboxes_0.selectedoption.Text = ""
                v_u_81.selection_box_selected = p_u_89
            end;
        end)
    end;
end;
v_u_81.display_selections = function(p95) --[[ Line: 917 ]]
    --[[ Upvalues: (copy 1): v_u_81, (copy 2): l_selectionboxes_0, (copy 3): v_u_87 ]]
    v_u_81.selection_box_selected = ""
    l_selectionboxes_0.selectedoption.Text = ""
    for _, v96 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
        if v96:FindFirstChild("highlighted") then
            v96.highlighted.Visible = false
            for _, v97 in ipairs(p95) do
                if v96.internal.Value == v97 then
                    v96.Visible = true
                    break;
                end;
                v96.Visible = false
            end;
        end;
    end;
    l_selectionboxes_0.Visible = true
    if _G.using_controller == true then
        for _, v98 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
            if v98:IsA("ImageButton") and (v98.Visible == true and (v98:FindFirstChild("highlighted") and (v98:FindFirstChild("num") and (v98:FindFirstChild("internal") and v98.num.Text == "1")))) then
                v_u_87(v98)
                return;
            end;
        end;
    end;
end;
if _G.get_settings("oldeliteorder") == true then
    v_u_81.create_selectionbox("Storm Trooper (Soldat)", "soldat", 91411577441927, "1storm", 1)
    v_u_81.create_selectionbox("Flame Trooper (Mortician)", "mortician", 87666811826102, "2flame", 2)
    v_u_81.create_selectionbox("Radio Trooper (Officer)", "officer", 91848564547336, "3radio", 3)
    v_u_81.create_selectionbox("Anti-Material Trooper (Rook)", "rook", 118411408826732, "4rook", 4)
    v_u_81.create_selectionbox("Trench Trooper (Lancer)", "lancer", 121228156023729, "5trench", 5)
    v_u_81.create_selectionbox("Bulwark Trooper (Vanguard)", "vanguard", 127864303840900, "6bulwark", 6)
    v_u_81.create_selectionbox("Geist Trooper (Jaeger)", "jaeger", 104974838934360, "7jaeger", 7)
    v_u_81.create_selectionbox("Ocelot Trooper (Cowboy)", "ocelot", 132627134022314, "8ocelot", 8)
else
    v_u_81.create_selectionbox("Storm Trooper (Soldat)", "soldat", 91411577441927, "1storm", 1)
    v_u_81.create_selectionbox("Anti-Material Trooper (Rook)", "rook", 118411408826732, "2rook", 2)
    v_u_81.create_selectionbox("Flame Trooper (Mortician)", "mortician", 87666811826102, "3flame", 3)
    v_u_81.create_selectionbox("Radio Trooper (Officer)", "officer", 91848564547336, "4radio", 4)
    v_u_81.create_selectionbox("Geist Trooper (Jaeger)", "jaeger", 104974838934360, "5jaeger", 5)
    v_u_81.create_selectionbox("Trench Trooper (Lancer)", "lancer", 121228156023729, "6trench", 6)
    v_u_81.create_selectionbox("Bulwark Trooper (Vanguard)", "vanguard", 127864303840900, "7bulwark", 7)
    v_u_81.create_selectionbox("Ocelot Trooper (Cowboy)", "ocelot", 132627134022314, "8ocelot", 8)
end;
v_u_81.create_selectionbox("Thank You", "thanks", 13738539975, "1thanks", 1)
v_u_81.create_selectionbox("Request Healing", "healing", 13492314435, "2healing", 2)
v_u_81.create_selectionbox("Request Ammo", "ammo", 6011908706, "3ammo", 3)
v_u_81.create_selectionbox("Danger There", "danger", 8019313215, "4danger", 4)
v_u_81.create_selectionbox("Need Support", "help", 7059344100, "5help", 5)
v_u_81.create_selectionbox("Follow Me", "officerfollow", 90807912793699, "6follow", 6)
v_u_81.create_selectionbox("Compound Order", "officerorder", 87643853907391, "7order", 7)
v_u_81.create_selectionbox("Defend Here", "officerdefend", 7461510428, "8defend", 8)
local v_u_99 = false
local v_u_100 = 0
local v_u_101 = 0
local v102 = Enum.RenderPriority.Character.Value - 5
l_core_game_0.voicewheel.Visible = false
if l_LocalPlayer_0.PlayerGui:FindFirstChild("loadingmenu") then
    v_u_81.shift_locked = false
end;
if v_u_8.Value == "marksman" then
    v_u_81.hold_breathmax = 1000
    v_u_81.hold_breathregen = v_u_81.hold_breathregen * 0.5
    v_u_81.hold_breathaccuracy = v_u_81.hold_breathaccuracy * 0.5
end;
local v_u_103 = nil
local v_u_104 = tick()
local v_u_105 = {
    92904376126712,
    115368253261443,
    125399080412483,
    132798049017638,
    98455730095525,
    75875394654743
}
local function v_u_112() --[[ Line: 1007 ]]
    --[[ Upvalues: (copy 1): v_u_1, (copy 2): l_core_game_0, (copy 3): v_u_105, (copy 4): v_u_2, (copy 5): l_RenderStepped_0 ]]
    if v_u_1 == nil or v_u_1.Health <= 0 then
        return;
    elseif _G.get_settings("disablebloodscreen") ~= true then
        local v106 = l_core_game_0.splatters.ex:Clone()
        v106.img.Image = "rbxassetid://" .. v_u_105[math.random(1, 6)]
        v106.img.Rotation = math.random(0, 360)
        local v107 = math.random(-100, 100) / 100
        v106.Visible = true
        v106.img.Size = UDim2.new(1 + v107, 0, 1 + v107)
        v106.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(10, 90) / 100, 0)
        v106.Name = "splat"
        v106.Parent = l_core_game_0.splatters
        local v108 = tick()
        local v109 = tick()
        math.random(15, 30)
        local v110 = math.random(20, 50)
        while v106 ~= nil and v106:FindFirstChild("img") ~= nil do
            local v111 = tick() - v108
            if v106.Name == "splat" then
                if v110 <= tick() - v108 then
                    if tick() - v109 >= 0.03 then
                        v109 = tick()
                        local l_img_0 = v106.img
                        l_img_0.ImageTransparency = l_img_0.ImageTransparency + 0.05
                    end;
                else
                    v106.img.ImageTransparency = v_u_2:lerp(0, 0.5, (math.clamp(v111 / 2, 0, 1)))
                end;
            elseif tick() - v109 >= 0.03 then
                v109 = tick()
                local l_img_1 = v106.img
                l_img_1.ImageTransparency = l_img_1.ImageTransparency + 0.05
                v106.Position = v106.Position + UDim2.new(0, v106.Name == "facewipe_left" and -2 or 2, 0, 0)
            end;
            l_RenderStepped_0:Wait()
            if v106 == nil or (v106:FindFirstChild("img") == nil or v106.img.ImageTransparency >= 1) then
                if v106 then
                    v106:Destroy()
                end;
                return;
            end;
        end;
    end;
end;
local function v_u_114() --[[ Line: 1068 ]]
    --[[ Upvalues: (ref 1): v_u_104, (copy 2): v_u_2, (copy 3): v_u_6, (copy 4): v_u_8, (copy 5): v_u_9, (copy 6): l_Character_0, (copy 7): v_u_81, (ref 8): v_u_74, (copy 9): v_u_71, (copy 10): l_core_game_0, (copy 11): s_Debris_0 ]]
    if tick() - v_u_104 >= 0.35 then
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "bullet_whizz" .. math.random(1, 5),
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_6
        })
        if v_u_8.Value == "leather" then
            return;
        end;
        if v_u_9.Value == "vanguard" then
            return;
        end;
        if l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "mortician" and v_u_81.aiming == true) then
            return;
        end;
        if l_Character_0:FindFirstChild("dreadnought") then
            return;
        end;
        if v_u_74 then
            return;
        end;
        if l_Character_0:FindFirstChild("exec") == nil and l_Character_0:FindFirstChild("execing") == nil then
            v_u_71["miss_flinch" .. math.random(1, 4)]:Play(0.05, 0.5, 2)
        end;
        v_u_104 = tick()
        local v_u_113 = l_core_game_0.flinch:Clone()
        s_Debris_0:AddItem(v_u_113, 1)
        v_u_113.Visible = l_core_game_0
        v_u_113.Parent = l_core_game_0
        spawn(function() --[[ Line: 1107 ]]
            --[[ Upvalues: (copy 1): v_u_113, (ref 2): v_u_2 ]]
            for _ = 1, 20 do
                v_u_113.ImageTransparency = v_u_113.ImageTransparency + 0.05
                v_u_2:s_wait(0.03)
            end;
            if v_u_113 then
                v_u_113:Destroy()
            end;
        end)
    end;
end;
_G.firing_movement_handler = function(p_u_115, p116, p117) --[[ Line: 1119 ]]
    --[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_81 ]]
    if l_Character_0:FindFirstChild("chems") and l_Character_0.chems:FindFirstChild("hal") == nil or (l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "quickdraw" or p117 == true) then
        if l_Character_0:FindFirstChild("cowboy") and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
            return;
        end;
        v_u_81.int_speed = v_u_81.int_speed - p_u_115
        delay(p116, function() --[[ Line: 1125 ]]
            --[[ Upvalues: (ref 1): v_u_81, (copy 2): p_u_115 ]]
            v_u_81.int_speed = v_u_81.int_speed + p_u_115
        end)
    end;
end;
local function _(p118) --[[ Line: 1131 ]]
    --[[ Upvalues: (copy 1): v_u_3, (copy 2): v_u_9 ]]
    if p118 and p118:FindFirstChild("core") then
        local l_dynamite_hiss_volume_default_0 = v_u_3.dynamite_hiss_volume_default
        local l_dynamite_hiss_range_default_0 = v_u_3.dynamite_hiss_range_default
        if v_u_9.Value == "jaeger" then
            l_dynamite_hiss_volume_default_0 = v_u_3.dynamite_hiss_volume_jaeger
            l_dynamite_hiss_range_default_0 = v_u_3.dynamite_hiss_range_jaeger
        end;
        p118.core.loop.Volume = l_dynamite_hiss_volume_default_0
        p118.core.loop.RollOffMaxDistance = l_dynamite_hiss_range_default_0
    end;
end;
local v_u_119 = 0
local v_u_120 = 0
local v_u_121 = 0
local function v_u_130(p122, p123, p124) --[[ Line: 1153 ]]
    --[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_8, (copy 3): v_u_81, (ref 4): v_u_121, (copy 5): s_Debris_0, (copy 6): v_u_6, (copy 7): v_u_1, (copy 8): l_RenderStepped_0, (copy 9): v_u_71, (copy 10): v_u_2, (copy 11): l_remotes_0 ]]
    if l_Character_0:FindFirstChild("dreadnought") then
        return;
    elseif v_u_8.Value ~= "knockdown" or (p124 == true or tick() - v_u_81.last_fall_damage_roll > 0.5) then
        if tick() - v_u_81.fall_damage_interrupt > 0 then
            v_u_81.last_fall_damage_roll = tick()
            v_u_121 = tick()
            local v125 = 0.75
            local v126 = 1
            if p124 == true then
                v125 = v125 * 0.7
                v126 = v126 / 0.7
            end;
            if v_u_8.Value == "knockdown" and p124 ~= true then
                p122 = "roll"
                local v127, v128
                if l_Character_0:FindFirstChild("cowboy") and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
                    v125 = 2
                    v126 = 0.15
                    v127 = 0.2
                    v128 = 1.35
                else
                    v125 = 1.6
                    v126 = 0.55
                    v127 = 0.4
                    v128 = 1
                end;
                local l_BodyPosition_0 = Instance.new("BodyPosition")
                s_Debris_0:AddItem(l_BodyPosition_0, v127)
                l_BodyPosition_0.Name = "knockBackBP"
                l_BodyPosition_0.P = 7
                l_BodyPosition_0.D = 15
                l_BodyPosition_0.MaxForce = Vector3.new(inf, inf, inf)
                l_BodyPosition_0.Position = v_u_6.Position + v_u_6.CFrame.lookVector * 50 * v128
                l_BodyPosition_0.Parent = v_u_6
                spawn(function() --[[ Line: 1195 ]]
                    --[[ Upvalues: (ref 1): v_u_1, (ref 2): v_u_81, (ref 3): l_RenderStepped_0 ]]
                    local v129 = tick()
                    while v_u_1 ~= nil and v_u_1.Health > 0 do
                        v_u_81.sprint_ticker = 0
                        l_RenderStepped_0:Wait()
                        if tick() - v129 >= 1 then
                            return;
                        end;
                    end;
                end)
            end;
            v_u_81.crouching_cd = tick()
            v_u_81.crouching = false
            v_u_71["fall" .. p122]:Play(0.05, 1, v125)
            v_u_81.fall_damage_interrupt = tick() + v126
        end;
        if p122 ~= "beartrap" then
            if v_u_8.Value == "knockdown" and p124 ~= true then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "roll",
                    ["location"] = l_Character_0.Torso
                })
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "rollfall",
                    ["location"] = l_Character_0.Torso
                })
            elseif p122 == "vanguard" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "armour_fall" .. math.random(1, 3),
                    ["location"] = l_Character_0.Torso
                })
            else
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "falldamage1",
                    ["location"] = l_Character_0.Torso
                })
            end;
        end;
        if p123 == true and p122 ~= "roll" then
            l_remotes_0.game_handler:FireServer("fall_damage")
        end;
    end;
end;
_G.knockdownproc = function(p131) --[[ Line: 1251 ]]
    --[[ Upvalues: (copy 1): v_u_2, (copy 2): l_Character_0, (copy 3): v_u_81, (copy 4): v_u_4, (copy 5): v_u_130 ]]
    if p131 and p131 == true then
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "bayo_miss" .. math.random(1, 2),
            ["location"] = l_Character_0.HumanoidRootPart
        })
        v_u_81.recoil_kick(10, 10, 5, true)
        v_u_4("mine_impact", {
            ["point"] = l_Character_0.HumanoidRootPart.Position + l_Character_0.HumanoidRootPart.CFrame.lookVector
        })
    end;
    v_u_81.fall_damage_interrupt = 0
    v_u_130(2, false, true)
end;
v_u_81.recoil_kick = function(p_u_132, p_u_133, p_u_134, p_u_135) --[[ Line: 1267 ]]
    --[[ Upvalues: (copy 1): l_core_game_0, (copy 2): v_u_2, (copy 3): v_u_81, (copy 4): v_u_12, (copy 5): v_u_8, (copy 6): l_Character_0, (ref 7): v_u_103, (ref 8): v_u_100, (copy 9): l_CurrentCamera_0 ]]
    if l_core_game_0.Parent.loadout_menu.Visible ~= true then
        v_u_2:fast_spawn(function() --[[ Line: 1271 ]]
            --[[ Upvalues: (copy 1): p_u_132, (copy 2): p_u_133, (ref 3): v_u_81, (ref 4): v_u_12, (ref 5): v_u_8, (ref 6): l_Character_0, (ref 7): v_u_103, (copy 8): p_u_135, (ref 9): l_core_game_0, (ref 10): v_u_100, (ref 11): l_CurrentCamera_0, (ref 12): v_u_2, (copy 13): p_u_134 ]]
            local v136 = p_u_132 / 10
            local v137 = math.random(-p_u_133 * 10, p_u_133 * 10) / 100
            if v_u_81.sick == true then
                v136 = v136 * 1.75
                v137 = v137 * 1.75
            end;
            if v_u_12:FindFirstChild("inap") then
                v136 = v136 * 1.5
                v137 = v137 * 1.5
            end;
            if v_u_8.Value == "marksman" then
                v136 = v136 / 2
                v137 = v137 / 2
            end;
            if l_Character_0:FindFirstChild("flagbuff") then
                v136 = v136 / 1.5
                v137 = v137 / 1.5
            end;
            if l_Character_0:FindFirstChild("buff_focus") or l_Character_0:FindFirstChild("buff_elite") then
                v136 = v136 / 1.5
                v137 = v137 / 1.5
            end;
            if v_u_103 and (v_u_103:FindFirstChild("akimbo") and (v_u_103.akimbo.Value == true and v_u_103:FindFirstChild("akimbo_aiming"))) then
                v136 = v136 / 1.5
                v137 = v137 / 1.5
            end;
            if v_u_12 and (v_u_12:FindFirstChild("hyd") and v_u_81.sick == false) then
                v136 = v136 / 2
                v137 = v137 / 2
            end;
            if v_u_81.holding_breath == true then
                v136 = v136 / 1.5
                v137 = v137 / 1.5
            end;
            if _G.using_controller and _G.using_controller == true then
                v136 = v136 / 1.5
                v137 = v137 / 1.5
            end;
            if p_u_135 and p_u_135 == true then
                spawn(function() --[[ Line: 1322 ]]
                    --[[ Upvalues: (ref 1): l_core_game_0, (ref 2): v_u_100, (ref 3): l_CurrentCamera_0, (ref 4): v_u_2 ]]
                    if l_core_game_0.Parent.loadout_menu.Visible ~= true then
                        v_u_100 = 0.5
                        for _ = 1, 4 do
                            if l_core_game_0.Parent.loadout_menu.Visible == true then
                                return;
                            end;
                            l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0, 0, (math.rad(2)))
                            v_u_2:s_wait(0.015)
                        end;
                        v_u_100 = 0
                    end;
                end)
            end;
            l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(math.rad(v136), math.rad(v137), 0)
            for _ = 1, p_u_134 do
                l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(math.rad(v136), math.rad(v137), 0)
                v_u_2:s_wait(0.015)
            end;
        end)
    end;
end;
local function _() --[[ Line: 1348 ]]
    --[[ Upvalues: (copy 1): l_core_game_0, (copy 2): v_u_2, (copy 3): l_CurrentCamera_0 ]]
    if l_core_game_0.Parent.loadout_menu.Visible ~= true then
        v_u_2:fast_spawn(function() --[[ Line: 1352 ]]
            --[[ Upvalues: (ref 1): l_CurrentCamera_0, (ref 2): l_core_game_0, (ref 3): v_u_2 ]]
            local v138 = math.random(-30, 30) / 100
            l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v138), 0)
            for _ = 1, 6 do
                if l_core_game_0.Parent.loadout_menu.Visible == true then
                    return;
                end;
                l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(-0.006981317007977318, math.rad(-v138), 0)
                v_u_2:s_wait(0.03)
            end;
            for _ = 1, 6 do
                if l_core_game_0.Parent.loadout_menu.Visible == true then
                    return;
                end;
                l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v138), 0)
                v_u_2:s_wait(0.03)
            end;
        end)
    end;
end;
local function v_u_143(p139, p140, p141) --[[ Line: 1374 ]]
    --[[ Upvalues: (ref 1): v_u_103, (copy 2): l_BoolValue_0, (copy 3): v_u_4, (copy 4): l_Character_0, (copy 5): v_u_71, (copy 6): v_u_2 ]]
    if p141 == false then
        local v142 = (p140 == "cache_restock" or p140 == "restock_player_full") and "cache_restock" or (v_u_103 and v_u_103:FindFirstChild("lefthanded") and "ammo_restock_right" or (math.random(1, 2) == 1 and v_u_103 == nil and "ammo_restock_right" or "ammo_restock_left"))
        if p139 == "ammo_restock" and l_BoolValue_0.Value == false then
            v_u_4("ammo_stock", {
                ["char"] = l_Character_0,
                ["anim"] = v142
            })
            v_u_71[v142]:Play(0.1)
        end;
    else
        v_u_71.helmet_restock:Play(0.1)
        delay(0.2, function() --[[ Line: 1395 ]]
            --[[ Upvalues: (ref 1): v_u_2, (ref 2): l_Character_0 ]]
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "helmet",
                ["location"] = l_Character_0.Torso
            })
        end)
        delay(0.5, function() --[[ Line: 1402 ]]
            --[[ Upvalues: (ref 1): v_u_2, (ref 2): l_Character_0 ]]
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "helmetadjust",
                ["location"] = l_Character_0.Torso
            })
        end)
    end;
    v_u_2:soundHandler({
        ["directory"] = {},
        ["soundfile"] = "ammopickup",
        ["location"] = l_Character_0.Torso
    })
end;
local v_u_144 = tick()
local v_u_145 = v_u_103
local function v_u_167(p_u_146, p_u_147, p_u_148) --[[ Line: 1417 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0, (copy 2): l_core_game_0, (copy 3): s_Debris_0, (copy 4): l_CurrentCamera_0, (copy 5): v_u_6, (copy 6): v_u_2, (copy 7): l_RenderStepped_0 ]]
    if p_u_147 and p_u_148 then
        if p_u_146 == "ping_area" and (p_u_147.Name ~= l_LocalPlayer_0.Name and _G.get_settings("muteofficers") == true) then
            return;
        end;
        if p_u_146 == "ping_danger" and _G.get_settings("disabledangerpings") == true then
            return;
        end;
        local v_u_149 = p_u_146 == "ping_danger" and 1 or 3
        local v_u_150 = l_core_game_0.rotating_indicator.ex:Clone()
        v_u_150.Name = p_u_147.Parent.Name
        s_Debris_0:AddItem(v_u_150, v_u_149 + 1)
        if p_u_146 == "send_request_healing" then
            v_u_150.icon.Image = "rbxassetid://13492314435"
        end;
        if p_u_146 == "send_request_officerfollow" then
            v_u_150.icon.Image = "rbxassetid://9657060536"
        end;
        if p_u_146 == "ping_defend" then
            v_u_150.icon.Image = "rbxassetid://7461510428"
        end;
        if p_u_146 == "ping_area" then
            v_u_150.icon.Image = "rbxassetid://9953839287"
        end;
        if p_u_146 == "ping_danger" then
            v_u_150.icon.Image = "rbxassetid://8019313215"
        end;
        if p_u_146 == "hunt_target" then
            v_u_150.icon.Image = "rbxassetid://16682879119"
        end;
        v_u_150.Visible = false
        v_u_150.Parent = l_core_game_0.rotating_indicator
        local v_u_151 = tick()
        spawn(function() --[[ Line: 1462 ]]
            --[[ Upvalues: (copy 1): p_u_148, (copy 2): v_u_150, (copy 3): p_u_147, (copy 4): p_u_146, (ref 5): l_CurrentCamera_0, (ref 6): v_u_6, (copy 7): v_u_151, (ref 8): v_u_149, (ref 9): v_u_2, (ref 10): l_RenderStepped_0 ]]
            local v152 = { UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5) }
            local v153 = { UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5) }
            local v154 = 0
            local v155 = 0
            while true do
                local v156 = p_u_148
                if tostring((typeof(v156))) ~= "Vector3" then
                    v156 = v156.Position
                end;
                if not v_u_150 or (not v_u_150:FindFirstChild("icon") or (v156 == nil or (v_u_150.icon.ImageTransparency >= 1 or p_u_147 == nil))) or (p_u_146 == "send_request_ammo" or (p_u_146 == "hunt_target" or p_u_146 == "send_request_healing")) and (p_u_147.Character == nil or (p_u_147.Character:FindFirstChild("Humanoid") == nil or p_u_147.Character.Humanoid.Health <= 0)) or p_u_146 == "send_request_healing" and (p_u_147.Character == nil or (p_u_147.Character:FindFirstChild("Humanoid") == nil or p_u_147.Character.Humanoid.Health >= 100)) then
                    if v_u_150 and v_u_150:FindFirstChild("icon") then
                        v_u_150:Destroy()
                    end;
                    return;
                end;
                local l_CFrame_0 = l_CurrentCamera_0.CFrame
                local v157 = CFrame.lookAt(l_CurrentCamera_0.CFrame.Position, v156)
                local _, v158 = l_CFrame_0:ToOrientation()
                local _, v159 = v157:ToOrientation()
                local v160 = math.deg(v158 - v159)
                local v161, v162 = l_CurrentCamera_0:WorldToViewportPoint(v156)
                v_u_150.Visible = true
                if v162 == true then
                    local v163 = math.clamp((tick() - v155) / 0.25, 0, 1)
                    local v164 = v163 * v163 * (3 - v163 * 2)
                    v154 = tick()
                    v_u_150.Position = v153[1]:Lerp(UDim2.new(0, v161.X, 0, v161.Y), v164)
                    v_u_150.AnchorPoint = v153[2]:Lerp(Vector2.new(0, 0), v164)
                    v152[1] = v_u_150.Position
                    v152[2] = v_u_150.AnchorPoint
                    v_u_150.Rotation = 0
                    v_u_150.icon.Rotation = 0
                    v_u_150.icon.Position = UDim2.new(0.5, 0, 0.5, 0)
                    v_u_150.arrow.Visible = false
                    if p_u_146 == "ping_area" then
                        v_u_150.icon.Position = UDim2.new(0.5, 0, 1, 0)
                        v_u_150.dist.Visible = true
                        v_u_150.dist.Text = math.ceil((v_u_6.Position - v156).magnitude)
                    end;
                else
                    local v165 = math.clamp((tick() - v154) / 0.25, 0, 1)
                    local v166 = v165 * v165 * (3 - v165 * 2)
                    v155 = tick()
                    v_u_150.Position = v152[1]:Lerp(UDim2.new(0.5, 0, 0.5, 0), v166)
                    v_u_150.AnchorPoint = v152[2]:Lerp(Vector2.new(0.5, 0.5), v166)
                    v153[1] = v_u_150.Position
                    v153[2] = v_u_150.AnchorPoint
                    v_u_150.icon.Position = UDim2.new(0, 0, -8, 0)
                    v_u_150.Rotation = v160
                    v_u_150.icon.Rotation = -v_u_150.Rotation
                    v_u_150.dist.Visible = false
                    v_u_150.arrow.Visible = true
                end;
                if v_u_149 <= tick() - v_u_151 then
                    v_u_150.icon.ImageTransparency = v_u_2:lerp(0, 1, (tick() - v_u_151 - v_u_149) / 1)
                    v_u_150.arrow.TextTransparency = v_u_150.icon.ImageTransparency
                    v_u_150.dist.TextTransparency = v_u_150.icon.ImageTransparency
                end;
                l_RenderStepped_0:Wait()
            end;
        end)
    end;
end;
local function v_u_176() --[[ Line: 1584 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): l_core_game_0 ]]
    local v168 = 10000
    local v169 = nil
    for _, v170 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
        local v171 = v170:FindFirstChild("objcenter")
        if v171 and v170:FindFirstChild("team") then
            local v172, v173 = l_CurrentCamera_0:WorldToViewportPoint(v171.Position)
            if v173 then
                local v174 = Vector2.new(v172.X, v172.Y)
                local v175 = l_core_game_0.AbsoluteSize / 2
                local l_Magnitude_0 = (v174 - v175).Magnitude
                if l_Magnitude_0 < v168 and l_Magnitude_0 < v175.Magnitude / 4 then
                    v169 = v170
                    v168 = l_Magnitude_0
                end;
            end;
        end;
    end;
    return v169;
end;
for _, v177 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
    if v177:FindFirstChild("objcenter") and (v177.objcenter:FindFirstChild("obj_icon") and v177.objcenter.obj_icon:FindFirstChild("toppingofficer")) then
        for _, v178 in ipairs(v177.objcenter.obj_icon:GetChildren()) do
            if v178.Name == "toppingofficer" then
                v178:Destroy()
            end;
        end;
    end;
end;
local function v_u_187(p179) --[[ Line: 1624 ]]
    --[[ Upvalues: (copy 1): v_u_25, (copy 2): v_u_2, (copy 3): l_CurrentCamera_0, (ref 4): v_u_144, (copy 5): l_LocalPlayer_0, (copy 6): s_Debris_0, (copy 7): l_RenderStepped_0 ]]
    if p179 == nil then
        return;
    elseif _G.get_settings("muteofficers") ~= true then
        local v180 = v_u_25:FindFirstChild(p179)
        if v_u_25.Name == "push" then
            v180 = v_u_25.objpiece:FindFirstChild(p179)
        end;
        if v_u_25.Name == "train" then
            v180 = v_u_25.UIListLayout:FindFirstChild(p179)
        end;
        if v180 and (v180.Visible == true and (v180:FindFirstChild("lockicon") and (v180:FindFirstChild("officerorder") and v180.lockicon.Visible == false))) then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "ping" .. math.random(1, 2),
                ["location"] = l_CurrentCamera_0
            }, true)
            if tick() - v_u_144 > 4 then
                v_u_144 = tick() - 4
            end;
            local v_u_181 = v180.officerorder:Clone()
            v_u_181.Name = "toppingofficer"
            v_u_181.ImageColor3 = Color3.fromRGB(107, 50, 124)
            if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                v_u_181.ImageColor3 = Color3.fromRGB(245, 205, 48)
            end;
            s_Debris_0:AddItem(v_u_181, 1.5)
            v_u_181.Visible = true
            local l_Size_0 = v_u_181.Size
            v_u_181.Size = v_u_181.Size + UDim2.new(0, 10, 0, 10)
            local v182 = workspace.serverStuff.objectives:FindFirstChild(p179)
            local v_u_183
            if v182 and (v182:FindFirstChild("objcenter") and v182.objcenter:FindFirstChild("obj_icon")) then
                v_u_183 = v_u_181:Clone()
                s_Debris_0:AddItem(v_u_183, 1.5)
                v_u_183.Parent = v182.objcenter.obj_icon
            else
                v_u_183 = nil
            end;
            v_u_181.Parent = v180
            spawn(function() --[[ Line: 1677 ]]
                --[[ Upvalues: (copy 1): v_u_181, (copy 2): l_Size_0, (ref 3): v_u_2, (ref 4): v_u_183, (ref 5): l_RenderStepped_0 ]]
                local l_Size_1 = v_u_181.Size
                local v184 = tick()
                while v_u_181 ~= nil do
                    local v185 = math.clamp((tick() - v184) / 1, 0, 1)
                    local v186 = math.clamp((tick() - v184) / 0.5, 0, 1)
                    v_u_181.Size = l_Size_1:Lerp(l_Size_0, v186 * v186 * (3 - v186 * 2))
                    v_u_181.ImageTransparency = v_u_2:lerp(0, 1, v185)
                    if v_u_183 ~= nil then
                        v_u_183.Size = v_u_181.Size
                        v_u_183.ImageTransparency = v_u_181.ImageTransparency
                    end;
                    l_RenderStepped_0:Wait()
                    if tick() - v184 >= 1 then
                        if v_u_181 then
                            v_u_181:Destroy()
                        end;
                        if v_u_183 then
                            v_u_183:Destroy()
                        end;
                        return;
                    end;
                end;
            end)
        end;
    end;
end;
local v_u_188 = tick()
local v_u_199 = l_remotes_0.interaction_handler.OnClientEvent:Connect(function(p189, p190, p191, p192) --[[ Line: 1721 ]]
    --[[ Upvalues: (copy 1): v_u_143, (copy 2): v_u_187, (copy 3): l_BoolValue_0, (copy 4): v_u_71, (copy 5): v_u_3, (copy 6): v_u_9, (copy 7): v_u_2, (copy 8): l_Character_0, (ref 9): v_u_188, (copy 10): l_CurrentCamera_0, (copy 11): l_core_game_0, (copy 12): s_Debris_0, (copy 13): v_u_1, (copy 14): l_RenderStepped_0, (copy 15): v_u_28, (copy 16): l_LocalPlayer_0, (copy 17): v_u_29, (ref 18): v_u_145, (copy 19): v_u_4, (copy 20): v_u_167 ]]
    if p189 == "ammo_restock" then
        v_u_143(p189, p190, p191)
    elseif p189 == "officer_mark_objective" then
        if p190 then
            v_u_187(p190)
            return;
        end;
    else
        if p189 == "stopaction" then
            l_BoolValue_0.Value = false
            return;
        end;
        if p189 == "playanimation" then
            if p190 and (p190.animation and v_u_71[p190.animation]) then
                if p190.delay then
                    task.wait(p190.delay)
                end;
                v_u_71[p190.animation]:Play(p190.fadein or 0.1, p190.weight or 1, p190.speed or 1)
            end;
        end;
        if p189 == "stopanimation" then
            if p190 and (p190.animation and v_u_71[p190.animation]) then
                if p190.delay then
                    task.wait(p190.delay)
                end;
                v_u_71[p190.animation]:Stop(p190.fadeout or 0.1)
            end;
        end;
        if p189 == "on_spawn" then
            for _, v193 in workspace.constructions:GetChildren() do
                if v193.Name == "Dynamite Stack" and v193 then
                    if v193:FindFirstChild("core") then
                        local l_dynamite_hiss_volume_default_1 = v_u_3.dynamite_hiss_volume_default
                        local l_dynamite_hiss_range_default_1 = v_u_3.dynamite_hiss_range_default
                        if v_u_9.Value == "jaeger" then
                            l_dynamite_hiss_volume_default_1 = v_u_3.dynamite_hiss_volume_jaeger
                            l_dynamite_hiss_range_default_1 = v_u_3.dynamite_hiss_range_jaeger
                        end;
                        v193.core.loop.Volume = l_dynamite_hiss_volume_default_1
                        v193.core.loop.RollOffMaxDistance = l_dynamite_hiss_range_default_1
                    end;
                end;
            end;
            return;
        end;
        if p189 == "grenade_retrieve" then
            v_u_71.cache_restock:Play(0.1)
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "nadepickup",
                ["location"] = l_Character_0.HumanoidRootPart
            })
            return;
        end;
        if p189 == "retrieve_telescope" or (p189 == "retrieve_banner" or (p189 == "retrieve_lewisshield" or p189 == "retrieve_vanguardshield")) then
            v_u_71[p189 == "retrieve_vanguardshield" and "retrieve_lewisshield" or p189]:Play(0.1)
            if p189 == "retrieve_telescope" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "telescope_ready",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                delay(0.2, function() --[[ Line: 1784 ]]
                    --[[ Upvalues: (ref 1): v_u_2, (ref 2): l_Character_0 ]]
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "telescope_retrieve",
                        ["location"] = l_Character_0.HumanoidRootPart
                    })
                end)
                return;
            end;
            if p189 == "retrieve_lewisshield" or p189 == "retrieve_vanguardshield" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "shield_ready",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "shield_pickup",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                return;
            end;
            if p189 == "retrieve_banner" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "rally_flag1",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "rally_flag2",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                return;
            end;
        elseif p189 == "pinged_enemy" then
            if tick() - v_u_188 >= 2 then
                v_u_188 = tick()
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "pinged_by",
                    ["location"] = l_CurrentCamera_0
                }, true)
                local v194 = l_core_game_0.healthlow:Clone()
                s_Debris_0:AddItem(v194, 1)
                v194.Name = "pinged"
                v194.ImageColor3 = Color3.fromRGB(170, 0, 0)
                v194.ImageTransparency = 0.7
                v194.Visible = true
                v194.Parent = l_core_game_0
                while v194 ~= nil and (v_u_1 ~= nil and v_u_1.Health > 0) do
                    v194.ImageTransparency = v194.ImageTransparency + 0.01
                    l_RenderStepped_0:Wait()
                    if v194.ImageTransparency >= 1 then
                        v194:Destroy()
                        return;
                    end;
                end;
                v194:Destroy()
                return;
            end;
        elseif p189 == "enemy_pinged" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "ping_enemy",
                ["location"] = l_CurrentCamera_0
            }, true)
            if p190 and (p191 and (p190:FindFirstChild("Humanoid") and (p190.Humanoid.Health > 0 and p190:FindFirstChild("HumanoidRootPart")))) then
                local v195 = p191 == "short" and 1 or 9
                local v196 = tick()
                local v197 = game.ReplicatedStorage.misc.marked_enemy:Clone()
                s_Debris_0:AddItem(v197, v195 + 1.5)
                v197.Parent = workspace.pings
                v197.Adornee = p190:FindFirstChild("HumanoidRootPart")
                if p192 and p192 == true then
                    v197.bgicon.ImageColor3 = v_u_28
                    if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
                        v197.bgicon.ImageColor3 = v_u_29
                    end;
                    v197.bgicon.ZIndex = 10
                end;
                while p190 ~= nil and (p190:FindFirstChild("Humanoid") ~= nil and p190.Humanoid.Health > 0) do
                    if v195 <= tick() - v196 then
                        v197.bgicon.ImageTransparency = v_u_2:lerp(0, 1, (tick() - v196 - v195) / 1)
                    end;
                    l_RenderStepped_0:wait()
                    if tick() - v196 >= v195 + 1 then
                        break;
                    end;
                end;
                if v197 then
                    v197:Destroy()
                    return;
                end;
            end;
        elseif p189 == "medical_heal" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "healed",
                ["location"] = l_Character_0.Torso
            })
            local v198 = v_u_145 and v_u_145:FindFirstChild("lefthanded") and "mortheal_right" or (math.random(1, 2) == 1 and v_u_145 == nil and "mortheal_right" or "mortheal_left")
            if l_BoolValue_0.Value == false then
                v_u_4("ammo_stock", {
                    ["char"] = l_Character_0,
                    ["anim"] = v198,
                    ["stim"] = true
                })
                v_u_71[v198]:Play(0.1)
                return;
            end;
        else
            if p189 == "flag_raise" then
                v_u_71.change_flag:Play(0.1)
                return;
            end;
            if p189 == "send_request_ammo" or (p189 == "send_request_officerfollow" or (p189 == "send_request_healing" or (p189 == "ping_area" or (p189 == "ping_danger" or p189 == "ping_defend")))) then
                v_u_167(p189, p190, p191)
            end;
        end;
    end;
end)
local function v_u_204(p200, p201) --[[ Line: 1929 ]]
    --[[ Upvalues: (copy 1): l_core_game_0 ]]
    local v202 = l_core_game_0.tutorialcontrols.ex:Clone()
    v202.Name = p200
    v202.LayoutOrder = #l_core_game_0.tutorialcontrols:GetChildren()
    local v203
    if p200 == "jump" then
        v203 = _G.using_controller == true and "A" or "Space"
    elseif p200 == "sprint" then
        v203 = _G.using_controller == true and "LButton" or "Shift"
    elseif p200 == "inventory" then
        v203 = _G.using_controller == true and "DPad" or "123456"
    elseif p200 == "aimgun" then
        v203 = _G.using_controller == true and "LT" or "Mouse 2"
    elseif p200 == "firegun" then
        v203 = _G.using_controller == true and "RT" or "Mouse 1"
    else
        v203 = p200 == "unequip" and "DPad Up" or _G.get_keybinds(p200).Name
    end;
    v202.Text = "[" .. v203 .. "] - " .. p201
    v202.Visible = true
    v202.Parent = l_core_game_0.tutorialcontrols
end;
local l_BindableEvent_0 = Instance.new("BindableEvent")
l_BindableEvent_0.Parent = script
l_BindableEvent_0.Event:connect(function() --[[ Line: 1994 ]]
    --[[ Upvalues: (copy 1): l_remotes_0 ]]
    l_remotes_0.game_handler:FireServer("resetself")
end)
spawn(function() --[[ Line: 2000 ]]
    --[[ Upvalues: (copy 1): l_BindableEvent_0 ]]
    repeat
        local v206 = pcall(function() --[[ Line: 2002 ]]
            --[[ Upvalues: (ref 1): l_BindableEvent_0 ]]
            local v205 = l_BindableEvent_0
            if workspace.serverStuff.trainingmode.Value == true then
                v205 = false
            end;
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", v205)
        end)
        task.wait(1)
    until v206;
end)
if workspace.serverStuff.trainingmode.Value == true then
    l_core_game_0.tutorialobj.Visible = true
    l_core_game_0.tutorialcontrols.Visible = true
    delay(5, function() --[[ Line: 2020 ]]
        --[[ Upvalues: (copy 1): v_u_204 ]]
        v_u_204("sprint", "Sprint")
        v_u_204("jump", "Jump / Mantle")
        v_u_204("firstperson", "Change Perspective")
        if _G.using_controller == false then
            v_u_204("flipcam", "Flip Camera")
            v_u_204("shiftlock", "Shift Lock")
        end;
    end)
end;
local v_u_207 = 0
local v208 = "Press [" .. _G.get_keybinds("menu").Name .. "] to open the Loadout Menu."
local v209 = {
    "Crouching with [" .. _G.get_keybinds("crouch").Name .. "] lets you walk over Traps without triggering them.",
    "View your objectives with [" .. _G.get_keybinds("viewobj").Name .. "]. Play the objective.",
    "Most weapons have an alternate action with [" .. _G.get_keybinds("alt").Name .. "].",
    "You can drop your guns mid-reload to draw a backup with [" .. _G.get_keybinds("dropweapon").Name .. "].",
    "Use Steady Aim by Sprinting while standing still and aiming, allowing you to make accurate shots.",
    "Do not forget your Class Equipment with [" .. _G.get_keybinds("equipment").Name .. "].",
    "Remember to thank your fellow allies with [" .. _G.get_keybinds("voicelines").Name .. "].",
    "As Soldat or Mortician, tap [" .. _G.get_keybinds("equipment").Name .. "] to assist your allies.",
    "As a Rook, double tap [" .. _G.get_keybinds("checkammo").Name .. "] to destroy all your Buildings of a selected type",
    "Press [" .. _G.get_keybinds("checkammo").Name .. "] with your First Aid Kit to check your health state.",
    "Use [" .. _G.get_keybinds("alt").Name .. "] with your First Aid Kit to take a pill, curing sickness.",
    "Check your firearm\'s ammunition with [" .. _G.get_keybinds("checkammo").Name .. "], the white bar is your reserve ammunition.",
    "You cannot sprint after taking damage, do not get caught out of position and use cover.",
    "Remember to stand still when shooting, as moving hurts accuracy.",
    "Sprinting requires a moment to build up speed, so keep moving.",
    "Your lantern will reveal you around corners and through walls, be mindful.",
    "Perform surgery with your First Aid Kit when you are injured, you can tell when your vision and hearing gets impaired.",
    "Aim with your First Aid Kit to perform surgery on injured allies, it is faster to be healed than to heal yourself.",
    "Helmets save lives.",
    "Click on a Banner on an team captured objective to raise your flag, improving Morale to you and allies.",
    "Thin wooden walls can be shot through at close range, reducing damage and helmet penetration.",
    "Shotguns aren\'t powerful enough to penetrate walls, and Pistols have weaker penetration power.",
    "Soldiers can handle 30u of chemicals in the bloodstream. Any more will make them Sick.",
    "The average Soldier has 200ml of Health, the state of needing Surgery is less than 100ml.",
    "If your side loses a battle, you can evacuate and survive if you hold out long enough.",
    "Shock Troopers are powerful classes obtained through Shock Trooper Kits - marked with a skull icon when authorised.",
    "Shock Troopers that successfully evacuate after a losing battle will appear in the next skirmish",
    "Melee Charges are not effective from very close distances. Charge from farther away for an instant kill.",
    "Soldats focus on firearms training, handling their weapons quicker, with increased accuracy.",
    "Officers capture objectives faster, counting as an extra Soldier.",
    "When using a Binoculars as Officer, click on opposing soldiers to mark them, bypassing any marking immunity.",
    "Rooks are more resistant to explosives and shrapnel due to their armour.",
    "Morticians perform Surgery on their allies faster and restore them to full Health.",
    "As a Vanguard, stay still when guarding your allies to actually provide them cover.",
    "Jaegers are able to sense enemy Soldiers mining nearby.",
    "Jaegers tip their bullets and melee in Pox, contributing to their enemies\' Sickness.",
    "Lancers wear special armour that makes them resistant to melee attacks.",
    "The \'Judgement\' Breech Rifle deals significant damage to Buildings.",
    "The \'Judgement\' Breech Rifle comes fitted with a Bayonet, increasing melee damage and allowing Charges.",
    "The \'Talon\' Army Revolver can be quickly hip-fired without aiming, though at questionable accuracy.",
    "Firearms with silencers do not reveal your position on kill.",
    "Melee weapons are particularly good at destroying Buildings.",
    "Avoid digging straight tunnels, it will lead to you and your team\'s demise.",
    "You can view and change the keybinds by checking Settings in your Loadout Menu on [" .. _G.get_keybinds("menu").Name .. "].",
    "Building Ammo Caches as Rook at your base is good etiquette for your allies.",
    "Read the Tool Tips in the Loadout Menu on [" .. _G.get_keybinds("menu").Name .. "] to learn more about certain tools.",
    "Use your Pick to mine for cover, rather than trying to take fights out in the open.",
    "Remember that after performing Surgery, you are still vulnerable, give your body a moment to recover."
}
if _G.hint_cycle == nil then
    _G.hint_cycle = 1
end;
if _G.hint_table == nil then
    _G.hint_table = v_u_2:randomiseTbl(v209)
    table.insert(_G.hint_table, 1, v208)
end;
if workspace.serverStuff.trainingmode.Value == false and (_G.get_settings("disablehints") == false and (_G.hint_table and _G.hint_cycle)) then
    v_u_207 = tick()
    l_core_game_0.hint_popup.Visible = true
    l_core_game_0.hint_popup.Text = "Hint: " .. _G.hint_table[_G.hint_cycle]
    l_core_game_0.hint_popup.TextTransparency = 0
    _G.hint_cycle = _G.hint_cycle + 1
    if _G.hint_cycle > #_G.hint_table then
        _G.hint_cycle = 1
    end;
else
    l_core_game_0.hint_popup.Visible = false
end;
_G.core_checkers = v_u_81
local v_u_210 = 0
local v_u_211 = 0
local v_u_212 = 0
local v_u_213 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0)
local v_u_214 = CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0)
local v_u_215 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
CFrame.new(-1, -1, 0, -4.37113883e-8, 0, -1, 0, 0.99999994, 0, 1, 0, -4.37113883e-8)
CFrame.new(1, -1, 0, -4.37113883e-8, 0, 1, -0, 0.99999994, 0, -1, 0, -4.37113883e-8)
local l_values_0 = workspace.serverStuff.values
if l_values_0.gamemode.Value == "train" and (l_values_0.gamestate.sub.Value ~= "endgame" and tick() - _G.global_hint >= 60) then
    _G.popupmsg("hint", (l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and l_values_0.gamemode_specific.attacking_team.Value == "nation" or l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and l_values_0.gamemode_specific.attacking_team.Value == "empire") and "Use your Repair Tool on a damaged Armoured Train to Repair it." or "Remember to grab an Anti-Armour Grenade from any Cache and use it on the Armoured Train.", 3)
end;
tick()
local v_u_216 = false
local v_u_217 = tick()
local v_u_218 = false
local function v_u_223(p219, p220) --[[ Line: 2164 ]]
    --[[ Upvalues: (copy 1): v_u_2 ]]
    local v221, v222
    if p220 == "invis" then
        v221 = 1
        v222 = 1
    else
        v221 = 0.5
        v222 = 0
    end;
    if p220 == "fade" then
        v221 = 0.95
        v222 = 0.9
    end;
    p219.bar.BackgroundTransparency = v_u_2:lerp(p219.bar.BackgroundTransparency, v221, 0.1)
    p219.bgicon.ImageTransparency = v_u_2:lerp(p219.bgicon.ImageTransparency, v222, 0.1)
    p219.lockicon.ImageTransparency = p219.bgicon.ImageTransparency
    p219.label.TextTransparency = p219.bgicon.ImageTransparency
    p219.label.TextStrokeTransparency = p219.bgicon.ImageTransparency
    p219.enemyin.BackgroundTransparency = p219.enemyin.exact.Value + p219.bgicon.ImageTransparency
end;
local v_u_224 = {
    ["forward"] = v_u_71.walk_forward,
    ["injured"] = v_u_71.walk_injured,
    ["left"] = v_u_71.walk_left,
    ["right"] = v_u_71.walk_right,
    ["crouchforward"] = v_u_71.crouchwalk_forward,
    ["crouchleft"] = v_u_71.crouchwalk_left,
    ["crouchright"] = v_u_71.crouchwalk_right,
    ["full_sprint"] = v_u_71.sprinting_full,
    ["lean_sprint"] = v_u_71.sprinting_lean
}
l_core_game_0.inventoryitemname.item.Text = ""
local v_u_225 = tick()
local v_u_226 = math.random(2, 4)
local function v_u_229(p227) --[[ Line: 2205 ]]
    --[[ Upvalues: (ref 1): v_u_225, (ref 2): v_u_226, (copy 3): v_u_81, (copy 4): l_Character_0, (copy 5): l_core_game_0, (copy 6): v_u_2, (copy 7): l_CurrentCamera_0, (copy 8): v_u_12, (ref 9): v_u_145, (copy 10): v_u_71, (copy 11): l_remotes_0 ]]
    if tick() - v_u_225 > v_u_226 and (v_u_81.holding_breath ~= true and not l_Character_0:FindFirstChild("drinking")) then
        v_u_225 = tick()
        if l_core_game_0.Parent.loadout_menu.Visible ~= true then
            v_u_2:fast_spawn(function() --[[ Line: 1352 ]]
                --[[ Upvalues: (ref 1): l_CurrentCamera_0, (ref 2): l_core_game_0, (ref 3): v_u_2 ]]
                local v228 = math.random(-30, 30) / 100
                l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v228), 0)
                for _ = 1, 6 do
                    if l_core_game_0.Parent.loadout_menu.Visible == true then
                        return;
                    end;
                    l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(-0.006981317007977318, math.rad(-v228), 0)
                    v_u_2:s_wait(0.03)
                end;
                for _ = 1, 6 do
                    if l_core_game_0.Parent.loadout_menu.Visible == true then
                        return;
                    end;
                    l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v228), 0)
                    v_u_2:s_wait(0.03)
                end;
            end)
        end;
        v_u_226 = math.random(2, 4)
        if v_u_12:FindFirstChild("int") then
            v_u_226 = math.random(15, 20) / 10
        end;
        v_u_71[v_u_145 and v_u_145:FindFirstChild("lefthanded") and "cough_right" or (math.random(1, 2) == 1 and v_u_145 == nil and "cough_right" or "cough_left")]:Play(0.1, 1, 1.5)
        l_remotes_0.game_handler:FireServer("cough", l_Character_0.gender.Value .. "_cough" .. math.random(1, 2), p227)
    end;
end;
local v_u_230 = 0
local v_u_231 = 0
local function v_u_235(p232) --[[ Line: 2230 ]]
    --[[ Upvalues: (ref 1): v_u_230, (copy 2): v_u_9, (copy 3): v_u_2, (copy 4): l_CurrentCamera_0, (copy 5): v_u_47, (ref 6): v_u_231, (copy 7): s_Debris_0, (copy 8): l_RenderStepped_0 ]]
    if tick() - v_u_230 <= 2 then
        return;
    end;
    if v_u_9.Value ~= "jaeger" then
        return;
    end;
    if v_u_2:raycastline({
        ["point"] = l_CurrentCamera_0.CFrame.Position,
        ["destination"] = CFrame.new(l_CurrentCamera_0.CFrame.Position, p232).LookVector,
        ["range"] = (l_CurrentCamera_0.CFrame.Position - p232).Magnitude - 1,
        ["layermask"] = v_u_47
    }) then
        v_u_230 = tick()
        if tick() - v_u_231 >= 5 then
            v_u_231 = tick()
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "sonar",
                ["location"] = l_CurrentCamera_0
            }, true)
        end;
        local v233 = game.ReplicatedStorage.misc.sonar:Clone()
        s_Debris_0:AddItem(v233, 2)
        v233.CFrame = CFrame.new(p232)
        v233.Parent = workspace.Camera
        while true do
            if v233 == nil then
                return;
            end;
            local v234 = (tick() - v_u_230) / 1.5
            v233.ping.Size = UDim2.new(0, 20, 0, 20):Lerp(UDim2.new(0, 60, 0, 60), v234)
            v233.ping.bgicon.ImageTransparency = v234
            l_RenderStepped_0:Wait()
            if tick() - v_u_230 >= 1.5 then
                if v233 then
                    v233:Destroy()
                end;
                break;
            end;
        end;
    else
        -- ::l6:: (Possible bug with goto)
        return;
    end;
end;
local v_u_236 = 0
local v_u_237 = false
local v_u_238 = 0
local l_nation_team_0 = workspace.nation_team
if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
    l_nation_team_0 = workspace.empire_team
end;
local v_u_239 = 0
local v_u_240 = 0
local v_u_241 = tick()
local v_u_242 = 20
local v_u_243 = tick()
local v_u_244 = false
local v_u_245 = v_u_9.Value == "conscript" and 0.1 or 5
local v_u_246 = false
local v_u_247 = 0
local v_u_248 = 0
local v_u_249 = 0
local v_u_250 = 0
local v_u_251 = 0
local v_u_252 = 0
local v_u_253 = tick()
local v_u_254 = tick()
local v_u_255 = tick()
local v_u_256 = "inhale"
local v_u_257 = 1.5
local v_u_258 = 1
local v_u_259 = 1
local v_u_260 = false
local v_u_261 = 0
local v_u_262 = { 0, 0, 0 }
local v_u_263 = 0
if _G.check_train_force then
    _G.check_train_force = tick()
end;
if v_u_9.Value == "officer" then
    l_core_game_0.voicewheel.officerdefend.Visible = true
    l_core_game_0.voicewheel.officerfollow.Visible = true
    l_core_game_0.voicewheel.officerorder.Visible = true
else
    l_core_game_0.voicewheel.officerdefend.Visible = false
    l_core_game_0.voicewheel.officerfollow.Visible = false
    l_core_game_0.voicewheel.officerorder.Visible = false
end;
local function v_u_278(p264) --[[ Line: 2364 ]]
    --[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_1, (copy 3): v_u_6, (ref 4): v_u_236, (copy 5): v_u_176, (copy 6): l_LocalPlayer_0, (ref 7): v_u_145, (copy 8): v_u_2, (copy 9): l_CurrentCamera_0, (copy 10): v_u_47, (copy 11): l_remotes_0, (copy 12): v_u_68, (copy 13): l_BoolValue_0, (copy 14): v_u_71 ]]
    local v265 = p264 == "healing" and v_u_1.Health < 100 and true or (p264 == "ammo" and (l_Character_0:FindFirstChild("full_ammo") and l_Character_0.full_ammo.Value == false) and true or false)
    if p264 == "thanks" and (l_Character_0:FindFirstChild("thankyou") and (l_Character_0.thankyou.Value ~= l_Character_0 and (l_Character_0.thankyou.Value:FindFirstChild("HumanoidRootPart") and (l_Character_0.thankyou.Value.HumanoidRootPart.Position - v_u_6.Position).magnitude <= 60))) then
        v265 = true
        v_u_236 = 0
    end;
    local v266 = (p264 == "danger" or (p264 == "help" or (p264 == "officerfollow" or p264 == "officerdefend"))) and true or v265
    local v267
    if p264 == "officerorder" then
        v267 = v_u_176()
        if v267 == nil then
            v266 = false
        else
            v266 = true
        end;
    else
        v267 = nil
    end;
    if l_Character_0:FindFirstChild("request_cd_" .. p264) then
        v266 = false
    end;
    if v266 == true and tick() - v_u_236 >= 2 then
        v_u_236 = tick()
        local v268 = nil
        local v269 = {
            "Ammo! I need Ammo!",
            "Ammo! I need it!",
            "Ammo! I need Ammo now!",
            "Ammo! I need some Ammo!",
            "Ammo! I\'m running low!",
            "Ammo! Could use some more!",
            "Ammo! Quickly!"
        }
        if l_LocalPlayer_0.Character:FindFirstChild("language") and p264 == "ammo" then
            local l_Value_1 = l_LocalPlayer_0.Character.language.Value
            v268 = l_Value_1 == "german" and { "Munition! Ich brauche es!", "Munition! Ich brauche Munition!", "Munition! Mein Vorrat geht zur Neige!" } or (l_Value_1 == "brazil" and { "Muni\195\167\195\163o! Preciso de muni\195\167\195\163o, por favor!", "Muni\195\167\195\163o! Estou quase sem muni\195\167\195\163o!", "Muni\195\167\195\163o! Rapidamente!" } or (l_Value_1 == "polish" and { "Amunicja! Potrzebuj\196\153 amunicji!", "Amunicja! Potrzebuj\196\153 wi\196\153cej!", "Amunicja! Szybko!" } or (l_Value_1 == "russian" and { "\208\159\208\176\209\130\209\128\208\190\208\189\209\139! \208\156\208\189\208\181 \208\189\209\131\208\182\208\189\209\139 \208\191\208\176\209\130\209\128\208\190\208\189\209\139!", "\208\159\208\176\209\130\209\128\208\190\208\189\209\139! \208\156\208\189\208\181 \208\177\209\139 \208\181\209\137\209\145!", "\208\159\208\176\209\130\209\128\208\190\208\189\209\139! \208\161\208\186\208\190\209\128\208\190 \208\183\208\176\208\186\208\190\208\189\209\135\208\176\209\130\209\129\209\143!" } or v268)))
        end;
        if p264 == "ammo" and (v_u_145 and (v_u_145:FindFirstChild("empty_ammo") and v_u_145.empty_ammo.Value == true)) then
            v269 = {
                "Ammo now! I\'m out of ammo!",
                "Ammo now! I\'m outta ammo!",
                "Ammo now! I\'m empty!",
                "Ammo now! I\'m all out!",
                "Ammo now! Got nothing in reserve!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_2 = l_LocalPlayer_0.Character.language.Value
                if l_Value_2 == "german" then
                    v268 = { "Munition jetzt! Meine Waffe ist leer!", "Munition jetzt! Ich halte nicht mehr lange durch!", "Munition jetzt! Ich habe nichts mehr!" }
                elseif l_Value_2 == "brazil" then
                    v268 = { "Muni\195\167\195\163o agora! Gastei tudo!", "Muni\195\167\195\163o agora! Estou completamente sem!", "Muni\195\167\195\163o agora! Acabou tudo!" }
                elseif l_Value_2 == "polish" then
                    v268 = { "Amunicja natychmiast! Moje \197\130adownice s\196\133 puste!", "Amunicja, teraz! Nic mi ju\197\188 nie zosta\197\130o!", "Amunicja natychmiast! M\195\179j pistolet jest pusty!" }
                elseif l_Value_2 == "russian" then
                    v268 = { "\208\159\208\176\209\130\209\128\208\190\208\189\209\139, \209\129\208\181\208\185\209\135\208\176\209\129! \208\163 \208\188\208\181\208\189\209\143 \208\178\209\129\209\145!", "\208\159\208\176\209\130\209\128\208\190\208\189\209\139, \209\129\208\181\208\185\209\135\208\176\209\129! \208\163 \208\188\208\181\208\189\209\143 \208\183\208\176\208\186\208\190\208\189\209\135\208\184\208\187\208\184\209\129\209\140!", "\208\159\208\176\209\130\209\128\208\190\208\189\209\139, \209\129\208\181\208\185\209\135\208\176\209\129! \208\163 \208\188\208\181\208\189\209\143 \208\177\208\190\208\187\209\140\209\136\208\181 \208\189\208\181\209\130!" }
                end;
            end;
        end;
        if p264 == "healing" then
            v269 = {
                "Medic! I need a medic!",
                "Medic! I need a doctor!",
                "Medic! I need one!",
                "Medic! I\'m dying over here!",
                "Medic! I\'m hurt badly!",
                "Medic! I need help!",
                "Medic! I\'m about to die!",
                "Medic! I can\'t keep going!",
                "Medic! Need help here!",
                "Medic! I\'m fading, fast!",
                "Medic! I\'m bleeding out!",
                "Medic! Assistance, please!",
                "Medic! I can barely stand!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_3 = l_LocalPlayer_0.Character.language.Value
                if l_Value_3 == "german" then
                    v268 = { "Doktor! Meine Wunden sind schwer!", "Doktor! Ich brauche sofortige Hilfe!", "Doktor! Kommen Sie schnell her!" }
                elseif l_Value_3 == "brazil" then
                    v268 = { "M\195\169dico! Preciso de ajuda aqui!", "M\195\169dico! Estou gravemente ferido!", "M\195\169dico! R\195\161pido!" }
                elseif l_Value_3 == "polish" then
                    v268 = { "Lekarzu! Potrzebuj\196\153 pomocy, natychmiast!", "Lekarzu! Umieram tutaj!", "Lekarzu! Kurwa, wykrwawiam si\196\153!" }
                elseif l_Value_3 == "russian" then
                    v268 = { "\208\156\208\181\208\180\208\184\208\186! \208\175 \209\129\208\184\208\187\209\140\208\189\208\190 \209\128\208\176\208\189\208\181\208\189!", "\208\156\208\181\208\180\208\184\208\186! \208\156\208\189\208\181 \208\189\209\131\208\182\208\189\208\176 \208\191\208\190\208\188\208\190\209\137\209\140!", "\208\156\208\181\208\180\208\184\208\186! \208\156\208\189\208\181 \208\189\209\131\208\182\208\181\208\189 \208\178\209\128\208\176\209\135!" }
                end;
            end;
        end;
        if p264 == "thanks" then
            v269 = {
                "Thank you, soldier.",
                "Many thanks, soldier.",
                "Thank you, friend.",
                "Many thanks, friend.",
                "Thanks, mate.",
                "Thanks for the help.",
                "Appreciate it."
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_4 = l_LocalPlayer_0.Character.language.Value
                if l_Value_4 == "german" then
                    v268 = { "Danke, Freund.", "Gott segne dich, Soldat.", "Vielen Dank, Genosse." }
                elseif l_Value_4 == "brazil" then
                    v268 = { "Obrigado, amigo.", "Obrigado pela ajuda.", "Muito obrigado." }
                elseif l_Value_4 == "polish" then
                    v268 = { "Dzi\196\153kuj\196\153 Ci.", "Dzi\196\153kuj\196\153 za pomoc.", "Dzi\196\153kuj\196\153 bardzo, \197\188o\197\130nierzu." }
                elseif l_Value_4 == "russian" then
                    v268 = { "\208\161\208\191\208\176\209\129\208\184\208\177\208\190, \209\130\208\190\208\178\208\176\209\128\208\184\209\137.", "\208\145\208\187\208\176\208\179\208\190\208\180\208\176\209\128\209\142 \209\130\208\181\208\177\209\143, \208\180\209\128\209\131\208\179.", "\208\175 \209\134\208\181\208\189\209\142 \209\130\208\178\208\190\209\142 \208\191\208\190\208\188\208\190\209\137\209\140." }
                end;
            end;
        end;
        if p264 == "danger" then
            v269 = {
                "Watch out, over there!",
                "Danger over there!",
                "Danger ahead, look out!",
                "Look out, danger ahead!",
                "Danger ahead!",
                "Careful, danger ahead!",
                "Heads up, over there!",
                "Eyes peeled, right there!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_5 = l_LocalPlayer_0.Character.language.Value
                v268 = l_Value_5 == "german" and { "Vorsicht, da dr\195\188ben!", "Gefahr voraus!", "Seid dort vorsichtig!" } or (l_Value_5 == "brazil" and { "Cuidado, perigo \195\160 frente!", "Aten\195\167\195\163o, ali!", "Fiquem alertas por ali!" } or (l_Value_5 == "polish" and { "Uwa\197\188aj tam!", "Niebezpiecze\197\132stwo!", "Przygotujcie bro\197\132, co\197\155 tam jest!" } or (l_Value_5 == "russian" and { "\208\158\209\129\209\130\208\190\209\128\208\190\208\182\208\189\208\190, \209\130\208\176\208\188 \208\190\208\191\208\176\209\129\208\189\208\190!", "\208\162\208\176\208\188 \208\190\208\191\208\176\209\129\208\189\208\190!", "\208\145\208\181\209\128\208\181\208\179\208\184\209\130\208\181\209\129\209\140, \209\130\208\176\208\188 \208\190\208\191\208\176\209\129\208\189\208\190!" } or v268)))
            end;
            if l_Character_0:FindFirstChild("binoc_ping_cd") == nil then
                local l_StringValue_2 = Instance.new("StringValue")
                game:GetService("Debris"):AddItem(l_StringValue_2, 2)
                l_StringValue_2.Name = "binoc_ping_cd"
                l_StringValue_2.Parent = l_Character_0
                local _, v270 = v_u_2:raycastline({
                    ["point"] = l_CurrentCamera_0.CFrame.Position,
                    ["destination"] = l_CurrentCamera_0.CFrame.LookVector,
                    ["range"] = 500,
                    ["layermask"] = v_u_47
                })
                if v270 then
                    l_remotes_0.interaction_handler:FireServer(v_u_68[3], "danger_ping", v270)
                end;
            end;
        end;
        if p264 == "help" then
            v269 = {
                "I need support over here!",
                "Need some support!",
                "Support! I need some support!",
                "Give me some support!",
                "I need backup on me!",
                "Could use some help over here!",
                "Someone support me!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_6 = l_LocalPlayer_0.Character.language.Value
                if l_Value_6 == "german" then
                    v268 = { "Ich brauche Unterst\195\188tzung!", "Ich brauche hier Verst\195\164rkung!", "Ich brauche Hilfe!" }
                elseif l_Value_6 == "brazil" then
                    v268 = { "Preciso de algum apoio!", "Eu bem que preciso de ajuda aqui!", "Algu\195\169m me apoie!" }
                elseif l_Value_6 == "polish" then
                    v268 = { "Potrzebuj\196\153 wsparcia!", "Wesprzyj mnie, prosz\196\153!", "Dajcie mi troch\196\153 wsparcia!" }
                elseif l_Value_6 == "russian" then
                    v268 = { "\208\156\208\189\208\181 \208\189\209\131\208\182\208\189\208\176 \208\191\208\190\208\180\208\180\208\181\209\128\208\182\208\186\208\176!", "\208\159\208\190\208\180\208\180\208\181\209\128\208\182\208\184\209\130\208\181 \208\188\208\181\208\189\209\143, \208\186\209\130\208\190-\208\189\208\184\208\177\209\131\208\180\209\140!", "\208\156\208\189\208\181 \208\177\209\139 \208\190\209\135\208\181\208\189\209\140 \208\191\209\128\208\184\208\179\208\190\208\180\208\184\208\187\208\176\209\129\209\140 \208\191\208\190\208\188\208\190\209\137\209\140!" }
                end;
            end;
        end;
        if p264 == "officerfollow" then
            v269 = {
                "Follow me, now!",
                "On me! Follow!",
                "Follow me, Soldiers!",
                "This way! With me, Soldiers!",
                "Come with me, Soldiers!",
                "Form up on me!",
                "Follow my lead, friends!",
                "Soldiers, on me!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_7 = l_LocalPlayer_0.Character.language.Value
                if l_Value_7 == "german" then
                    v268 = { "Folgen Sie mir!", "Komm mit mir!", "Hier entlang, Soldaten!" }
                elseif l_Value_7 == "brazil" then
                    v268 = { "Siga-me, agora!", "Por aqui, camaradas!", "Eu vou na frente, sigam-me!" }
                elseif l_Value_7 == "polish" then
                    v268 = { "Pod\196\133\197\188ajcie za mn\196\133, \197\188o\197\130nierze!", "Chod\197\186 za mn\196\133!", "Prosz\196\153 ze mn\196\133!" }
                elseif l_Value_7 == "russian" then
                    v268 = { "\208\151\208\176 \208\188\208\189\208\190\208\185!", "\208\161\208\187\208\181\208\180\209\131\208\185\209\130\208\181 \208\183\208\176 \208\188\208\189\208\190\208\185!", "\208\148\208\181\209\128\208\182\208\184\209\130\208\181\209\129\209\140 \209\129\208\190 \208\188\208\189\208\190\208\185!" }
                end;
            end;
        end;
        if p264 == "officerdefend" then
            v269 = {
                "Defend this position, now!",
                "Hold this area, now!",
                "Defend this sector, Soldiers!",
                "Hold the line, Soldiers!",
                "Secure this area!",
                "Don\'t let them take this position!",
                "Hold your ground, here!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_8 = l_LocalPlayer_0.Character.language.Value
                v268 = l_Value_8 == "german" and { "Verteidigt dieses Gebiet!", "Halten Sie diese Position!", "Lasst nicht zu, dass sie dieses Gebiet einnehmen!" } or (l_Value_8 == "brazil" and { "Defendam esta \195\161rea!", "Mantenha esta posi\195\167\195\163o!", "N\195\163o os deixem tomar esta \195\161rea!" } or (l_Value_8 == "polish" and { "Bro\197\132cie tego obszaru!", "Utrzymajcie t\196\153 pozycj\196\153!", "Nie pozw\195\179lcie im przej\196\133\196\135 tego terenu!" } or (l_Value_8 == "russian" and { "\208\158\208\177\208\190\209\128\208\190\208\189\209\143\208\185\209\130\208\181 \209\141\209\130\209\131 \208\191\208\190\208\183\208\184\209\134\208\184\209\142!", "\208\148\208\181\209\128\208\182\208\184\209\130\208\181 \209\141\209\130\209\131 \208\190\208\186\209\128\208\181\209\129\209\130\208\189\208\190\209\129\209\130\209\140!", "\208\157\208\181 \208\180\208\176\208\185\209\130\208\181 \208\184\208\188 \208\183\208\176\208\189\209\143\209\130\209\140 \209\141\209\130\209\131 \208\191\208\190\208\183\208\184\209\134\208\184\209\142!" } or v268)))
            end;
            if v_u_6 then
                l_remotes_0.interaction_handler:FireServer(v_u_68[3], "defend_ping", v_u_6.Position)
            end;
        end;
        if p264 == "officerorder" and (v267 and v267:FindFirstChild("team")) then
            v269 = {
                "Take this Compound, now!",
                "Attack this Compound, now!",
                "We need to take this Compound, now!",
                "Get on this Compound, now!",
                "Assault this Compound, now!",
                "Everyone, take and hold this Compound!",
                "Prioritize this Compound, attack it now!",
                "Seize this Compound and ensure its capture!"
            }
            if l_LocalPlayer_0.Character:FindFirstChild("language") then
                local l_Value_9 = l_LocalPlayer_0.Character.language.Value
                v268 = l_Value_9 == "german" and { "Greifen Sie diese Anlage an!", "Wir m\195\188ssen diese Verbindung jetzt einnehmen!", "Hilf mir, diese Anlage anzugreifen!" } or (l_Value_9 == "brazil" and { "Ataquem este complexo!", "Precisamos pegar esse composto agora mesmo!", "Ajude-me a atacar este complexo!" } or (l_Value_9 == "polish" and { "Zaatakujcie ten kompleks!", "Musimy natychmiast zdoby\196\135 ten zwi\196\133zek chemiczny!", "Pom\195\179\197\188 mi zaatakowa\196\135 ten kompleks!" } or (l_Value_9 == "russian" and { "\208\151\208\176\209\133\208\178\208\176\209\130\208\184\209\130\208\181 \209\141\209\130\209\131 \209\130\208\190\209\135\208\186\209\131, \209\129\208\181\208\185\209\135\208\176\209\129 \208\182\208\181!", "\208\157\208\181\208\188\208\181\208\180\208\187\208\181\208\189\208\189\208\190 \208\176\209\130\208\176\208\186\209\131\208\185\209\130\208\181 \209\130\208\190\209\135\208\186\209\131!", "\208\151\208\176\208\185\208\188\208\184\209\130\208\181 \209\141\209\130\209\131 \209\130\208\190\209\135\208\186\209\131!" } or v268)))
            end;
            if (l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and "empire" or "nation") == v267.team.Value then
                v269 = {
                    "Defend this Compound, now!",
                    "Hold this Compound, now!",
                    "Don\'t let this Compound fall!",
                    "Reinforce this Compound!",
                    "We cannot let this Compound be taken!",
                    "Stay strong, keep them off this Compound!"
                }
                if l_LocalPlayer_0.Character:FindFirstChild("language") then
                    local l_Value_10 = l_LocalPlayer_0.Character.language.Value
                    if l_Value_10 == "german" then
                        v268 = { "Verteidigt diese Anlage!", "Verst\195\164rken Sie diese Verbindung!", "Lasst nicht zu, dass sie dieses Gel\195\164nde einnehmen!" }
                    elseif l_Value_10 == "brazil" then
                        v268 = { "Defendam este complexo!", "Reforce este composto!", "N\195\163o os deixem tomar este complexo!" }
                    elseif l_Value_10 == "polish" then
                        v268 = { "Bro\197\132cie tego kompleksu!", "Wzmocnijcie ten kompleks!", "Nie pozw\195\179lcie im przej\196\133\196\135 tego kompleksu!" }
                    elseif l_Value_10 == "russian" then
                        v268 = { "\208\151\208\176\209\137\208\184\209\137\208\176\208\185\209\130\208\181 \209\141\209\130\209\131 \209\130\208\190\209\135\208\186\209\131!", "\208\157\208\181 \208\180\208\176\208\185\209\130\208\181 \208\184\208\188 \208\183\208\176\209\133\208\178\208\176\209\130\208\184\209\130\209\140 \209\141\209\130\209\131 \209\130\208\190\209\135\208\186\209\131!", "\208\148\208\181\209\128\208\182\208\184\209\130\208\181 \209\141\209\130\209\131 \209\131\209\130\208\190\209\135\208\186\209\131!" }
                    end;
                end;
            end;
            if v_u_6 then
                l_remotes_0.interaction_handler:FireServer(v_u_68[3], "compound_order", v267.Name)
            end;
        end;
        local v271 = v269[math.random(1, #v269)]
        local v272
        if v268 == nil then
            v272 = nil
        else
            v272 = v268[math.random(1, #v268)]
        end;
        if v272 == nil or l_LocalPlayer_0.playerstats.settings.languagevoices.Value ~= true then
            _G.popupmsg(p264 .. "request", l_LocalPlayer_0.Name .. ": " .. v271, 1)
        else
            _G.popupmsg(p264 .. "request", l_LocalPlayer_0.Name .. ": " .. v272, 1)
        end;
        local v273 = l_Character_0:FindFirstChild("Torso")
        if l_BoolValue_0.Value == false then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "unready" .. math.random(1, 4),
                ["pitchvariation"] = 0.1,
                ["location"] = v_u_6
            })
            v273 = l_Character_0:FindFirstChild("Left Arm")
            local v274, v275, v276
            if p264 == "danger" or p264 == "officerorder" then
                v274 = "point_larm"
                v275 = 1
                v276 = "point_rarm"
            else
                v274 = "request_larm"
                v275 = 0.5
                v276 = "request_rarm"
            end;
            if p264 == "thanks" then
                v274 = "thanks_larm"
                v275 = 1
                v276 = "thanks_rarm"
            end;
            local v277 = v_u_71[v274]
            if math.random(1, 2) == 1 and v_u_145 == nil or v_u_145 and v_u_145:FindFirstChild("lefthanded") then
                v277 = v_u_71[v276]
                v273 = l_Character_0:FindFirstChild("Right Arm")
            end;
            if ((not v_u_145 or (not v_u_145:FindFirstChild("guarding") or v_u_145.guarding.Value ~= true)) and true or false) == true then
                v277:Play(0.1, 1, v275)
            end;
        end;
        l_remotes_0.game_handler:FireServer("send_request_" .. p264, v271, v273, v272)
    end;
end;
spawn(function() --[[ Line: 2916 ]]
    --[[ Upvalues: (copy 1): l_BoolValue_0, (ref 2): v_u_145, (copy 3): l_Character_0, (copy 4): v_u_81, (copy 5): l_RenderStepped_0, (copy 6): l_remotes_0, (copy 7): l_core_game_0 ]]
    if workspace.serverStuff.shocktroopermode.Value == true then
        if l_BoolValue_0.Value == true or v_u_145 ~= nil then
            return;
        end;
        if l_Character_0:FindFirstChild("breakout_elitekit") then
            return;
        end;
        l_BoolValue_0.Value = true
        v_u_81.selection_box_selected = ""
        v_u_81.display_selections({
            "soldat",
            "mortician",
            "officer",
            "rook",
            "lancer",
            "jaeger",
            "vanguard"
        })
        tick()
        repeat
            l_RenderStepped_0:wait()
        until v_u_81.selection_box_selected ~= "" or v_u_81.queue_inv ~= nil;
        if v_u_81.selection_box_selected == "" or v_u_81.selection_box_selected == "none" then
            v_u_81.selection_box_selected = "soldat"
        end;
        if v_u_81.selection_box_selected ~= "none" then
            v_u_81.no_swap_ticker = tick()
            l_remotes_0.game_handler:FireServer("shocktrooper_modeselect", v_u_81.selection_box_selected)
            spawn(function() --[[ Line: 2947 ]]
                --[[ Upvalues: (ref 1): v_u_81, (ref 2): l_RenderStepped_0, (ref 3): l_Character_0 ]]
                repeat
                    v_u_81.no_swap_ticker = tick()
                    l_RenderStepped_0:Wait()
                until l_Character_0:FindFirstChild("elitekit") or l_Character_0:FindFirstChild("breakout_elitekit");
            end)
        end;
        l_core_game_0.selectionboxes.Visible = false
        v_u_81.selection_box_selected = ""
        l_BoolValue_0.Value = false
    end;
end)
local v_u_279 = l_LocalPlayer_0:GetMouse()
v_u_279.TargetFilter = workspace.notarget
local v_u_280 = {
    ["cavsword"] = true,
    ["wex"] = true
}
local v_u_281 = tick()
game:GetService("RunService"):BindToRenderStep("MainLoop", v102, function() --[[ Line: 2975 ]]
    --[[ Upvalues: (copy 1): v_u_1, (ref 2): v_u_207, (copy 3): l_core_game_0, (copy 4): v_u_2, (copy 5): l_values_0, (copy 6): v_u_42, (copy 7): v_u_43, (ref 8): v_u_44, (copy 9): l_Character_0, (copy 10): v_u_81, (copy 11): l_CurrentCamera_0, (ref 12): v_u_99, (copy 13): l_LocalPlayer_0, (ref 14): v_u_218, (copy 15): v_u_6, (ref 16): v_u_255, (ref 17): v_u_256, (ref 18): v_u_145, (ref 19): l_keysheld_0, (ref 20): v_u_246, (ref 21): v_u_22, (copy 22): v_u_279, (copy 23): v_u_47, (ref 24): v_u_144, (copy 25): v_u_278, (copy 26): l_ObjectValue_0, (copy 27): v_u_13, (copy 28): l_remotes_0, (copy 29): l_BoolValue_0, (copy 30): v_u_71, (ref 31): v_u_281, (ref 32): l_Value_0, (ref 33): v_u_82, (ref 34): v_u_83, (copy 35): v_u_45, (copy 36): v_u_60, (copy 37): v_u_229, (ref 38): v_u_252, (ref 39): v_u_18, (copy 40): v_u_51, (ref 41): v_u_242, (ref 42): v_u_241, (ref 43): v_u_243, (ref 44): v_u_244, (copy 45): l_RenderStepped_0, (ref 46): v_u_55, (copy 47): v_u_53, (copy 48): v_u_10, (copy 49): v_u_11, (ref 50): v_u_245, (copy 51): v_u_25, (copy 52): v_u_223, (copy 53): v_u_41, (copy 54): v_u_40, (copy 55): v_u_8, (copy 56): v_u_12, (copy 57): v_u_3, (ref 58): v_u_101, (ref 59): v_u_212, (copy 60): v_u_9, (ref 61): v_u_57, (ref 62): v_u_58, (ref 63): v_u_247, (copy 64): v_u_130, (ref 65): v_u_216, (ref 66): v_u_210, (ref 67): v_u_211, (ref 68): v_u_74, (copy 69): v_u_78, (copy 70): l_Part_0, (copy 71): v_u_280, (ref 72): v_u_238, (ref 73): l_nation_team_0, (copy 74): v_u_4, (ref 75): v_u_240, (ref 76): v_u_239, (copy 77): v_u_30, (copy 78): v_u_167, (copy 79): v_u_214, (copy 80): v_u_213, (ref 81): v_u_261, (ref 82): v_u_262, (copy 83): v_u_215, (ref 84): v_u_237, (ref 85): v_u_217, (ref 86): v_u_48, (ref 87): v_u_257, (ref 88): v_u_258, (ref 89): v_u_259, (ref 90): v_u_248, (ref 91): v_u_249, (ref 92): v_u_250, (ref 93): v_u_251, (copy 94): s_UserInputService_0, (copy 95): v_u_56, (ref 96): v_u_100, (ref 97): v_u_263, (copy 98): v_u_46, (copy 99): v_u_52, (copy 100): v_u_54, (copy 101): v_u_50, (ref 102): v_u_253, (ref 103): v_u_254, (copy 104): s_Debris_0, (copy 105): v_u_224, (ref 106): v_u_260 ]]
    if v_u_1 == nil or v_u_1.Health <= 0 then
        return;
    end;
    if tick() - v_u_207 > 5 then
        l_core_game_0.hint_popup.TextTransparency = v_u_2:lerp(l_core_game_0.hint_popup.TextTransparency, 1, 0.1)
    end;
    if workspace.serverStuff.trainingmode.Value == true then
        l_core_game_0.customchat.Visible = true
    end;
    if l_values_0.gamemode.Value == "train" and (v_u_42 and v_u_43) then
        local v282 = v_u_42:GetChildren()
        for _, v283 in ipairs(v_u_43:GetChildren()) do
            table.insert(v282, v283)
        end;
        if v282 then
            for _, v284 in ipairs(v282) do
                if v284:IsA("BasePart") and v284.Name == "trainspawnprot" then
                    if v284.Parent == v_u_44 then
                        v284.CanQuery = false
                        v284.CanCollide = false
                    else
                        v284.CanQuery = true
                        v284.CanCollide = true
                    end;
                end;
            end;
        end;
    end;
    if l_Character_0 and (l_Character_0:FindFirstChild("Right Arm") and (l_Character_0:FindFirstChild("Left Arm") and (l_Character_0:FindFirstChild("Right Leg") and l_Character_0:FindFirstChild("Left Leg")))) then
        local v285 = (v_u_81.mosin_scope == nil or v_u_81.mosin_scope.Parent ~= l_CurrentCamera_0) and 0 or 1
        l_Character_0["Right Arm"].LocalTransparencyModifier = v285
        l_Character_0["Left Arm"].LocalTransparencyModifier = v285
        l_Character_0["Right Leg"].LocalTransparencyModifier = 0
        l_Character_0["Left Leg"].LocalTransparencyModifier = 0
    end;
    if _G.get_settings("toggleads") ~= true then
        v_u_99 = false
    end;
    if l_LocalPlayer_0.PlayerGui:FindFirstChild("ready") then
        v_u_218 = true
        v_u_6.Anchored = true
        return;
    end;
    if v_u_218 == true then
        v_u_218 = false
        v_u_6.Anchored = false
    end;
    if l_Character_0:FindFirstChild("dreadnought") and (v_u_1.Health <= 1000 and 0.9 or 1.3) <= tick() - v_u_255 then
        local v286 = workspace.serverStuff.trainingmode.Value ~= true and "maskSoundGroup" or nil
        v_u_255 = tick()
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = l_Character_0.gender.Value .. "_" .. v_u_256 .. math.random(1, 3),
            ["soundgroup"] = v286,
            ["location"] = l_Character_0.Head
        })
        if v_u_256 == "inhale" then
            v_u_256 = "exhale"
        else
            v_u_256 = "inhale"
        end;
    end;
    if l_core_game_0:FindFirstChild("vignette") and (l_Character_0:FindFirstChild("dreadnought") == nil and tick() - v_u_255 >= 1.3) then
        v_u_255 = tick()
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = l_Character_0.gender.Value .. "_" .. v_u_256 .. math.random(1, 3),
            ["volume_adjust"] = -0.1,
            ["location"] = l_Character_0.Head
        }, true)
        if v_u_256 == "inhale" then
            v_u_256 = "exhale"
        else
            v_u_256 = "inhale"
        end;
    end;
    for _, v287 in ipairs(workspace.constructions:GetChildren()) do
        if (v287.Name == "Cache" or v287.Name == "Rally Banner") and (v287:FindFirstChild("health") and (v287.health.Value > 0 and v287:FindFirstChild("team"))) then
            if v287:FindFirstChild("click") and v287.click:FindFirstChild("ammoicon") then
                if v287.team.Value == l_LocalPlayer_0.Team then
                    v287.click.ammoicon.Enabled = true
                else
                    v287.click.ammoicon.Enabled = false
                end;
            elseif v287:FindFirstChild("bounding") and v287.bounding:FindFirstChild("flagicon") then
                if v287.team.Value == l_LocalPlayer_0.Team then
                    v287.bounding.flagicon.Enabled = true
                else
                    v287.bounding.flagicon.Enabled = false
                end;
            end;
        end;
        if v287.Name ~= "Rally Banner" and (v287:FindFirstChild("owner") and (v287:FindFirstChild("health") and v287:FindFirstChild("core"))) then
            local v288 = v287:FindFirstChild("deployable_highlight")
            if v_u_145 and (v_u_145:FindFirstChild("weapon") and _G.get_settings("disablehighlightconstructs") ~= true) then
                if v_u_145.weapon.Value == "hammer" or v_u_145.weapon.Value == "jaegerkit" then
                    if v287.owner.Value == l_LocalPlayer_0.Name then
                        if v288 == nil then
                            game.ReplicatedStorage.misc.deployable_highlight:Clone().Parent = v287
                        end;
                    elseif v288 then
                        v288:Destroy()
                    end;
                elseif v288 then
                    v288:Destroy()
                end;
            elseif v288 then
                v288:Destroy()
            end;
        end;
    end;
    if l_Character_0:FindFirstChild("rimlight") and l_Character_0.rimlight.Enabled == true then
        l_Character_0.rimlight.Enabled = false
    end;
    if (l_keysheld_0[Enum.KeyCode.LeftShift] == true or l_keysheld_0[Enum.KeyCode.ButtonL3] == true) and (tick() - v_u_81.in_air_timer < 0.35 and (v_u_81.aiming == false and v_u_81.sprint_block == false)) then
        v_u_81.sprinting = true
        if _G.get_settings("togglesprint") == true or l_keysheld_0[Enum.KeyCode.ButtonL3] == true then
            v_u_246 = true
        end;
    else
        v_u_81.sprinting = false
    end;
    if v_u_22 and v_u_22 ~= nil then
        local v289 = v_u_2:raycastline({
            ["point"] = l_CurrentCamera_0.CFrame.Position,
            ["destination"] = CFrame.new(l_CurrentCamera_0.CFrame.Position, v_u_279.Hit.Position).LookVector,
            ["range"] = 6 + (l_CurrentCamera_0.CFrame.Position - v_u_6.Position).Magnitude,
            ["get_clicker"] = true,
            ["layermask"] = v_u_47
        })
        if v289 and (v289:IsA("BasePart") and (v289.Parent and (v289.Name ~= "Terrain" and v_u_145 == nil))) then
            v_u_22.Parent = v289.Parent
        else
            v_u_22.Parent = nil
        end;
    end;
    if v_u_246 == true then
        if v_u_81.sprint_block == false and (v_u_81.aiming == false and tick() - v_u_81.in_air_timer < 0.35) then
            v_u_81.sprinting = true
        else
            v_u_246 = false
            v_u_81.sprinting = false
        end;
    end;
    if l_Character_0:FindFirstChild("dreadnought") then
        v_u_81.sprinting = false
    end;
    if l_keysheld_0[_G.get_keybinds("viewobj")] then
        if workspace.serverStuff.trainingmode.Value == true and l_Character_0:FindFirstChild("compass_active") == nil then
            return;
        end;
        v_u_144 = tick()
    end;
    if l_keysheld_0[_G.get_keybinds("voicelines")] and (l_keysheld_0[_G.get_keybinds("voicelines")] == true and l_core_game_0.Visible == true) then
        if workspace.serverStuff.trainingmode.Value == true then
            return;
        end;
        l_core_game_0.voicewheel.Visible = true
        for _, v290 in ipairs(l_core_game_0.voicewheel:GetChildren()) do
            if v290 == _G.voice_command_select then
                v290.bar.button.Size = UDim2.new(99.00000000000001, 0, 0.77, 0)
            else
                v290.bar.button.Size = UDim2.new(90, 0, 0.7, 0)
            end;
        end;
    else
        if _G.voice_command_select ~= nil then
            v_u_278(_G.voice_command_select.Name)
            _G.voice_command_select = nil
        end;
        l_core_game_0.voicewheel.Visible = false
    end;
    local v291
    if tick() - v_u_81.fall_damage_interrupt <= 0 or l_ObjectValue_0.Value ~= nil then
        v291 = 15
        v_u_81.sprinting = false
        v_u_81.crouching = false
        v_u_246 = false
    else
        v291 = 0
    end;
    local v_u_292 = l_Character_0:FindFirstChild("dreadnought") and v_u_145 == nil and l_LocalPlayer_0.Backpack:FindFirstChild("\'Devils Kiss\' Machine Gun")
    if v_u_292 then
        spawn(function() --[[ Line: 3235 ]]
            --[[ Upvalues: (ref 1): v_u_145, (ref 2): v_u_81, (ref 3): v_u_1, (copy 4): v_u_292 ]]
            if v_u_145 == nil then
                v_u_81.inventory_display = tick()
                v_u_1:EquipTool(v_u_292)
            end;
        end)
    end;
    if l_ObjectValue_0.Value == nil then
        if v_u_145 and v_u_145:FindFirstChild("mounted_weapon") then
            v_u_1:UnequipTools()
        end;
        l_core_game_0.crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
        l_core_game_0.crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
    elseif l_ObjectValue_0.Value:FindFirstChild("centerpoint") and (l_ObjectValue_0.Value:FindFirstChild("turret_weapon") and (l_ObjectValue_0.Value:FindFirstChild("in_use") and l_ObjectValue_0.Value.in_use.Value == l_Character_0)) then
        if v_u_145 == nil then
            local v293 = l_LocalPlayer_0.Backpack:FindFirstChild(v_u_13[l_ObjectValue_0.Value.turret_weapon.Value].name)
            if v293 then
                v_u_81.inventory_display = tick()
                v_u_1:EquipTool(v293)
            end;
        elseif v_u_145:FindFirstChild("weapon") and v_u_145.weapon.Value ~= l_ObjectValue_0.Value.turret_weapon.Value then
            l_ObjectValue_0.Value = nil
        end;
        if l_ObjectValue_0.Value ~= nil then
            if (v_u_6.Position - l_ObjectValue_0.Value.centerpoint.Position).magnitude > 6 then
                l_ObjectValue_0.Value = nil
            end;
            if l_ObjectValue_0.Value ~= nil then
                l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
                local l_Position_0 = (l_CurrentCamera_0.CFrame + l_CurrentCamera_0.CFrame.LookVector * 100).Position
                if l_ObjectValue_0.Value:FindFirstChild("rig") and (l_ObjectValue_0.Value.rig:FindFirstChild("mg") and l_ObjectValue_0.value.rig.mg:FindFirstChild("muzzle")) then
                    local l_rig_0 = l_ObjectValue_0.Value.rig
                    local v294, v295, _ = CFrame.new(l_rig_0.turretpivot.Position + Vector3.new(0, 1, 0), l_Position_0):ToOrientation()
                    l_rig_0:PivotTo(l_ObjectValue_0.Value.centerpoint.CFrame * CFrame.fromOrientation(v295, 0, 0) * CFrame.Angles(math.rad(90 - l_ObjectValue_0.Value.centerpoint.Rotation.Y), 0, 0))
                    l_rig_0.mg:PivotTo(l_rig_0.mgpivot_outer.CFrame * CFrame.fromOrientation(math.clamp(v294, -0.6, 0.6), 0, 0))
                    local _, v296 = v_u_2:raycastline({
                        ["point"] = l_rig_0.mg.muzzle.Position,
                        ["destination"] = l_rig_0.mg.muzzle.CFrame.LookVector,
                        ["range"] = 500,
                        ["layermask"] = v_u_47
                    })
                    local v297 = l_CurrentCamera_0:WorldToViewportPoint(v296)
                    l_core_game_0.crosshair.Position = UDim2.new(0, v297.X, 0, v297.Y)
                    l_core_game_0.crosshair.AnchorPoint = Vector2.new(0, 0)
                end;
                if tick() - v_u_81.fall_damage_interrupt > 0 then
                    l_remotes_0.game_handler:FireServer("turret_rotate", l_Position_0, l_ObjectValue_0.Value)
                end;
            end;
        end;
    else
        l_ObjectValue_0.Value = nil
    end;
    if l_Character_0:FindFirstChild("exec") and (l_Character_0:FindFirstChild("bodyshielded") and l_BoolValue_0.Value == false) then
        v_u_1:UnequipTools()
    end;
    if v_u_1:GetState() == Enum.HumanoidStateType.Climbing then
        if v_u_6.Velocity.Magnitude >= 1 then
            if v_u_71.ladder_climb.IsPlaying == false then
                v_u_71.ladder_climb:Play(0.1, 1, 0.5)
            else
                v_u_71.ladder_climb:AdjustSpeed(0.5)
            end;
            if tick() - v_u_281 >= 0.6 then
                v_u_281 = tick()
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "step" .. math.random(1, 4),
                    ["volume_adjust"] = -0.2,
                    ["location"] = v_u_6
                })
            end;
        elseif v_u_71.ladder_climb.IsPlaying == true then
            v_u_71.ladder_climb:AdjustSpeed(0)
        end;
    elseif v_u_71.ladder_climb.IsPlaying == true then
        v_u_71.ladder_climb:Stop(0.1)
    end;
    if l_Value_0 == workspace.serverStuff.serverTick.Value then
        if tick() - v_u_82 >= 2 then
            _G.ping_locked = true
            if tick() - v_u_83 >= 2 then
                v_u_83 = tick()
                if _G.chat_handler then
                    _G.chat_handler("You are experiencing connection issues.", "server")
                end;
            end;
        end;
    else
        l_Value_0 = workspace.serverStuff.serverTick.Value
        v_u_82 = tick()
        _G.ping_locked = false
    end;
    if _G.ping_locked == true then
        l_Character_0.Torso.Anchored = true
    else
        l_Character_0.Torso.Anchored = false
    end;
    local v298 = v_u_6.CFrame:vectorToObjectSpace(v_u_6.Velocity)
    if v298.z > 2 then
        v_u_81.sprinting = false
    end;
    if v_u_145 and (v_u_145:FindFirstChild("guarding") and v_u_145.guarding.Value == true) then
        v_u_81.sprinting = false
        v_u_246 = false
    end;
    l_core_game_0.binocsoverlay.Visible = false
    if (l_keysheld_0.m2 == true or (v_u_99 == true or (v_u_145 and (v_u_145:FindFirstChild("akimbo") and (v_u_145.akimbo.Value == true and (v_u_145:FindFirstChild("akimbo_aiming") and v_u_145.akimbo_aiming.Value == true))) and true or false) == true)) and v_u_81.shift_locked == true then
        if v_u_145 then
            v_u_81.aiming = true
            if v_u_145:FindFirstChild("weapon") and v_u_145.weapon.Value == "binocs" then
                local _, v299 = v_u_2:raycastline({
                    ["point"] = l_CurrentCamera_0.CFrame.Position + l_CurrentCamera_0.CFrame.LookVector * ((l_CurrentCamera_0.CFrame.Position - v_u_6.Position).magnitude - 1),
                    ["destination"] = l_CurrentCamera_0.CFrame.lookVector,
                    ["range"] = 1000,
                    ["layermask"] = v_u_45
                })
                if v299 then
                    l_core_game_0.binocsoverlay.rangefinder.Text = math.ceil((v_u_6.Position - v299).Magnitude) .. " studs"
                end;
            end;
        else
            v_u_81.aiming = false
        end;
    else
        v_u_81.aiming = false
    end;
    for _, v301 in ipairs(workspace.pings:GetChildren()) do
        if not v301:IsA("BillboardGui") then
            local v301 = v301:FindFirstChildOfClass("BillboardGui")
        end;
        if v301:IsA("BillboardGui") then
            local v302 = v_u_81.aiming == true and 0.8 or 0
            if v301:FindFirstChild("bgicon") then
                v301.bgicon.ImageTransparency = v302
            end;
            if v301:FindFirstChild("lowertext") then
                v301.lowertext.TextTransparency = v302
            end;
        end;
    end;
    if v_u_60 then
        v_u_60.CFrame = l_CurrentCamera_0.CFrame + l_CurrentCamera_0.CFrame.LookVector * (2.5 - 1 * (l_CurrentCamera_0.FieldOfView / 90))
        for _, v303 in ipairs(v_u_60:GetChildren()) do
            if v303:FindFirstChild("smoke") then
                v303.smoke.Enabled = false
            end;
            if v303:FindFirstChild("fire") then
                v303.fire.Enabled = false
            end;
        end;
    end;
    for _, l_hitbox_0 in ipairs(workspace.throwables:GetChildren()) do
        if l_hitbox_0.Name == "smokespread" or l_hitbox_0.Name == "nebel" and (l_hitbox_0:FindFirstChild("body") and l_hitbox_0:FindFirstChild("smoke_active")) then
            if l_hitbox_0.Name == "nebel" and l_hitbox_0:FindFirstChild("hitbox") then
                local l_hitbox_0 = l_hitbox_0.hitbox
            end;
            if (v_u_6.Position - l_hitbox_0.Position).Magnitude <= 6.5 then
                for _, v305 in ipairs(v_u_60:GetChildren()) do
                    if v305:FindFirstChild("smoke") then
                        v305.smoke.Enabled = true
                    end;
                end;
                if (l_Character_0:FindFirstChild("gasmask") and true or false) == false then
                    v_u_229(true)
                end;
                break;
            end;
        end;
    end;
    if v_u_1:FindFirstChild("burning_light") or v_u_1:FindFirstChild("burning_heavy") then
        if tick() - v_u_252 >= 1 then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "fire_ignite" .. math.random(1, 5),
                ["location"] = l_CurrentCamera_0
            }, true)
            if l_Character_0:FindFirstChild("dreadnought") == nil then
                local v306 = l_Character_0.gender.Value .. "_fire" .. math.random(1, 4)
                if v_u_1:FindFirstChild("burning_heavy") then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "fire_extra" .. math.random(1, 3),
                        ["location"] = v_u_6
                    })
                end;
                l_remotes_0.game_handler:FireServer("burningline", v306)
            end;
        end;
        v_u_252 = tick()
        for _, v307 in ipairs(v_u_60:GetChildren()) do
            if v307:FindFirstChild("fire") then
                if v_u_1:FindFirstChild("burning_heavy") then
                    v307.fire.Rate = 20
                else
                    v307.fire.Rate = 10
                end;
                v307.fire.Enabled = true
            end;
        end;
    end;
    local v308 = Color3.new(1, 1, 1)
    l_core_game_0.traitortext.Visible = false
    if l_values_0.gamestate.Value == "ingame" then
        local l_Position_1 = v_u_18.basecenter.Position
        local v309 = l_values_0.gamemode.Value == "train" and 80 or 65
        if l_values_0.evacs.Value == 1 then
            v309 = v309 + 25
        end;
        if l_values_0.gamestate.sub.Value == "endgame" and (l_Character_0.Parent ~= workspace.evacs and (l_values_0.gamemode.Value ~= "infection" and l_values_0.gamemode.Value ~= "laststand")) then
            if v_u_18 and (l_values_0.teamlosing.Value ~= nil and (l_LocalPlayer_0.Team == l_values_0.teamlosing.Value and (v309 < (v_u_6.Position - l_Position_1).magnitude or v_u_6.Position.Y >= 52))) then
                l_core_game_0.traitortext.Visible = true
                if l_Character_0:FindFirstChild("traitormark") then
                    l_core_game_0.traitortext.Text = "You are branded as a deserter for non-compliance!\nYou will automatically surrender soon!"
                    v308 = Color3.fromRGB(255, 137, 137)
                else
                    l_core_game_0.traitortext.Text = "Return to base immediately!\nYou will be branded as a deserter if you do not comply!"
                end;
            end;
            if l_values_0.teamlosing.Value == nil then
                l_core_game_0.traitortext.Visible = false
            end;
        end;
        if l_values_0.gamemode.Value == "infection" and (workspace.serverStuff.objectives:FindFirstChild("objectiveA") and (l_LocalPlayer_0.Team == game.Teams["Royal Nation"] and l_values_0.teamlosing.Value ~= nil)) then
            if #workspace:GetPartsInPart(workspace.serverStuff.objectives.objectiveA.capture, v_u_51) <= 0 then
                v308 = Color3.fromRGB(255, 137, 137)
                l_core_game_0.traitortext.Visible = true
                l_core_game_0.traitortext.Text = "Return to the Objective!\nYou automatically become Infected in " .. math.ceil(v_u_242 / 2 - (tick() - v_u_241)) .. " seconds!"
                v_u_243 = tick()
                if tick() - v_u_241 >= v_u_242 / 2 and (v_u_244 == false and l_Character_0:FindFirstChild("execing") == nil) then
                    v_u_244 = true
                    l_remotes_0.game_handler:FireServer("surrender_forced")
                end;
            elseif tick() - v_u_243 >= 10 then
                v_u_241 = tick()
            else
                v_u_241 = v_u_241 + l_RenderStepped_0:Wait()
            end;
        end;
        if l_values_0.gamestate.sub.Value == "endgame" or not l_Character_0:FindFirstChild("dreadnought") then
            if v_u_18 and (l_values_0.gamestate.sub.Value ~= "endgame" and (l_values_0.early_game.Value and (l_Character_0:FindFirstChild("elitekit") and (l_values_0.nationtickets.Value >= 40 and (l_values_0.empiretickets.Value >= 40 and ((v_u_6.Position - l_Position_1).magnitude < v309 and v_u_242 <= tick() - v_u_241)))))) then
                l_core_game_0.traitortext.Visible = true
                l_core_game_0.traitortext.Text = "By staying in the base as a Shock Trooper, you acknowledge\nthe possibility of punishment for refusal to complete objectives without reason"
            end;
        elseif v_u_18 then
            if (v_u_6.Position - l_Position_1).magnitude < v309 then
                l_core_game_0.traitortext.Visible = true
                l_core_game_0.traitortext.Text = "Deliver Judgement to the opposition, or condemn yourself as a coward.\nYou only have one choice in the matter."
                v_u_243 = tick()
                if tick() - v_u_241 >= v_u_242 / 2 then
                    v308 = Color3.fromRGB(255, 137, 137)
                    l_core_game_0.traitortext.Text = "Leave the safety of your base immediately or you will be condemned.\nThis is your final warning."
                end;
                if tick() - v_u_241 >= v_u_242 * 1.5 and (v_u_244 == false and l_Character_0:FindFirstChild("execing") == nil) then
                    v_u_244 = true
                    l_remotes_0.game_handler:FireServer("resetself")
                end;
            elseif tick() - v_u_243 >= 10 then
                v_u_241 = tick()
            else
                v_u_241 = v_u_241 + l_RenderStepped_0:Wait()
            end;
        end;
        if workspace.serverStuff:FindFirstChild("game_setup") and workspace.serverStuff.game_setup:FindFirstChild("outofbounds") then
            local l_outofbounds_0 = workspace.serverStuff.game_setup.outofbounds
            if l_outofbounds_0.team.Value == nil or l_outofbounds_0.team.Value == l_LocalPlayer_0.Team then
                if #workspace:GetPartsInPart(workspace.serverStuff.game_setup.outofbounds, v_u_51) > 0 then
                    v308 = Color3.fromRGB(255, 137, 137)
                    l_core_game_0.traitortext.Visible = true
                    l_core_game_0.traitortext.Text = "Return to your objective!\nYou automatically surrender in " .. math.ceil(v_u_242 - (tick() - v_u_241)) .. " seconds!"
                    v_u_243 = tick()
                    if v_u_242 <= tick() - v_u_241 and (v_u_244 == false and l_Character_0:FindFirstChild("execing") == nil) then
                        v_u_244 = true
                        l_remotes_0.game_handler:FireServer("surrender_forced")
                    end;
                elseif tick() - v_u_243 >= 10 then
                    v_u_241 = tick()
                else
                    v_u_241 = v_u_241 + l_RenderStepped_0:Wait()
                end;
            end;
        end;
    end;
    v_u_55.bg.ammo.TextStrokeTransparency = v_u_2:lerp(v_u_55.bg.ammo.TextStrokeTransparency, tick() - v_u_81.check_ammo <= 1.5 and 0 or 1, 0.1)
    v_u_55.bg.ammo.TextTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.count.TextStrokeTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.count.TextTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.maxammo.bg.ImageTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.maxammo.inner.bar.BackgroundTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.walkertext.TextTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_55.bg.walkertext.TextStrokeTransparency = v_u_55.bg.ammo.TextStrokeTransparency
    v_u_53.bb.count.TextTransparency = v_u_2:lerp(v_u_53.bb.count.TextTransparency, tick() - v_u_81.equipment_show_cd <= 5 and 0 or 1, 0.1)
    v_u_53.bb.progress.frame1.img.ImageTransparency = v_u_53.bb.count.TextTransparency
    v_u_53.bb.progress.frame2.img.ImageTransparency = v_u_53.bb.count.TextTransparency
    if v_u_10 and (v_u_11 and v_u_11:FindFirstChild("max")) then
        v_u_53.bb.count.Text = v_u_11.Value
        if v_u_11.Value == v_u_11.max.Value then
            v_u_53.bb.progress.frame1.Visible = false
            v_u_53.bb.progress.frame2.Visible = false
        else
            v_u_53.bb.progress.frame1.Visible = true
            v_u_53.bb.progress.frame2.Visible = true
            v_u_53.bb.progress.frame1.img.grad.Rotation = 0
            v_u_53.bb.progress.frame2.img.grad.Rotation = -180
            local v310 = 1
            local l_cd_0 = v_u_10.cd
            if l_Character_0:FindFirstChild("equipment_long") and (not l_LocalPlayer_0.Character:FindFirstChild("equipment_short") and v_u_10.cd_long) then
                l_cd_0 = v_u_10.cd_long
            end;
            local v311 = math.clamp((tick() - v_u_81.equipment_ticker) / l_cd_0, 0, 1)
            local v312 = 360 * v311
            if v311 >= 0.5 then
                v_u_53.bb.progress.frame1.img.grad.Rotation = 180
                v312 = -360 + v312
                v310 = 2
            end;
            v_u_53.bb.progress["frame" .. v310].img.grad.Rotation = v312
        end;
        if l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson then
            v_u_53.CFrame = l_CurrentCamera_0.CFrame + l_CurrentCamera_0.CFrame.LookVector * 2 - l_CurrentCamera_0.CFrame.UpVector * 1
        else
            v_u_53.CFrame = v_u_6.CFrame * CFrame.new(2, 2, 0)
        end;
    end;
    v_u_145 = l_Character_0:FindFirstChildOfClass("Tool")
    l_core_game_0.objpopup.Visible = false
    local v313 = tick() - v_u_144 <= v_u_245 and (v_u_81.aiming == true and "invis" or "") or "invis"
    l_core_game_0.scoreframe.objective_uis.Visible = false
    local v314 = true
    if v_u_25 and v_u_25.Name == "train" then
        v_u_25.objpiece.train.gradient.Offset = Vector2.new(0, 1.1 - l_values_0.gamemode_specific.train_track_on.trainhealth.Value / l_values_0.gamemode_specific.train_track_on.trainhealthmax.Value)
        if workspace.serverStuff.values.gamemode_specific.train_track_on.train_damaged.Value == false then
            v_u_25.objpiece.train.gradient.Enabled = true
            v_u_25.objpiece.train.ImageColor3 = Color3.new(1, 1, 1)
        else
            v_u_25.objpiece.train.gradient.Enabled = false
            v_u_25.objpiece.train.ImageColor3 = Color3.new(0.9, 0, 0)
        end;
        local v315 = math.clamp(math.abs(l_values_0.gamemode_specific.train_track_on.progress.Value) / 390, 0, 1)
        if l_values_0.gamemode_specific.train_track_on.progress.Value < 0 then
            v315 = -v315
        end;
        v_u_25.objpiece.train.Position = UDim2.new(v315 / 2 + 0.5, 0, 0.5, 0)
    end;
    local v316 = 0
    local v317 = 0
    for _, v318 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
        if v318:FindFirstChild("capture") and (l_values_0.gamestate.sub.Value == "" and v_u_25 ~= nil) then
            local v319 = v318.objcenter:FindFirstChild("obj_icon")
            if v319 then
                if v318:FindFirstChild("team") then
                    if v318.team.Value == "empire" then
                        v317 = v317 + 1
                    elseif v318.team.Value == "nation" then
                        v316 = v316 + 1
                    end;
                end;
                l_core_game_0.scoreframe.objective_uis.Visible = true
                v_u_25.Visible = true
                local v320 = v_u_25:FindFirstChild(v318.Name)
                if v_u_25.Name == "push" then
                    v320 = v_u_25.objpiece:FindFirstChild(v318.Name)
                end;
                if v_u_25.Name == "train" then
                    v320 = v_u_25.UIListLayout:FindFirstChild(v318.Name)
                end;
                if v320 then
                    for _, v321 in ipairs(v320:GetChildren()) do
                        local v322 = v319:FindFirstChild(v321.Name)
                        if v322 then
                            v321.Size = v322.Size
                            v321.BackgroundColor3 = v322.BackgroundColor3
                            if v321:IsA("ImageLabel") then
                                v321.Image = v322.Image
                                v321.ImageColor3 = v322.ImageColor3
                                v321.Visible = v322.Visible
                            end;
                            if v321:IsA("TextLabel") then
                                v321.Text = v322.Text
                                v321.TextColor3 = v322.TextColor3
                            end;
                            if v321.Name == "enemyin" then
                                v321.BackgroundTransparency = v322.exact.Value
                            end;
                        end;
                    end;
                    if v_u_25.Name == "control" then
                        v320.Visible = true
                    end;
                    if v_u_25.Name == "assault" then
                        v320.Visible = not v320.lockicon.Visible
                        v314 = false
                    end;
                    if v_u_25.Name == "train" then
                        v320.Visible = true
                        v314 = true
                    end;
                    if v_u_25.Name == "push" then
                        v320.Visible = true
                        local v323 = v_u_25.UIListLayout.arrows:FindFirstChild(v318.Name)
                        if v323 and v318:FindFirstChild("team") then
                            v323.Visible = true
                            if v318.team.Value == "nation" then
                                v323.ImageColor3 = Color3.fromRGB(167, 83, 170)
                                v323.Rotation = 90
                            elseif v318.team.Value == "empire" then
                                v323.ImageColor3 = Color3.fromRGB(255, 248, 47)
                                v323.Rotation = -90
                            else
                                v323.Visible = false
                            end;
                        end;
                    end;
                end;
                v319.Enabled = true
                local v324
                if (v_u_6.Position - v318.objcenter.Position).Magnitude <= 105 then
                    v324 = v313 == "" and "fade" or v313
                    if #workspace:GetPartsInPart(v318.capture, v_u_51) > 0 then
                        v319.Enabled = false
                        v324 = ""
                        if v314 == true then
                            l_core_game_0.objpopup.Visible = true
                            for _, v325 in ipairs(l_core_game_0.objpopup:GetChildren()) do
                                local v326 = v319:FindFirstChild(v325.Name)
                                if v326 then
                                    v325.Size = v326.Size
                                    v325.BackgroundTransparency = v326.BackgroundTransparency
                                    v325.BackgroundColor3 = v326.BackgroundColor3
                                    if v325:IsA("ImageLabel") then
                                        v325.Image = v326.Image
                                        v325.ImageColor3 = v326.ImageColor3
                                        v325.ImageTransparency = v326.ImageTransparency
                                    end;
                                    if v325:IsA("TextLabel") then
                                        v325.Text = v326.Text
                                        v325.TextColor3 = v326.TextColor3
                                        v325.TextTransparency = v326.TextTransparency
                                    end;
                                    v325.Visible = v326.Visible
                                end;
                            end;
                        end;
                    end;
                else
                    v324 = v313
                end;
                v_u_223(v319, v324)
            end;
        end;
    end;
    local v327 = workspace.serverStuff.trainingmode.Value == true and (workspace.serverStuff:FindFirstChild("game_setup") and workspace.serverStuff.game_setup:FindFirstChild("objindicator")) and workspace.serverStuff.game_setup.objindicator:FindFirstChild("bb")
    if v327 then
        v327.label.TextTransparency = v_u_2:lerp(v327.label.TextTransparency, tick() - v_u_144 <= v_u_245 and 0 or 1, 0.1)
        v327.label.TextStrokeTransparency = v327.label.TextTransparency
    end;
    if v_u_25.Name == "push" then
        if v317 == 2 and v316 == 2 then
            v_u_25.UIListLayout.left.Size = UDim2.new(0.25, 0, 0.05, 0)
            v_u_25.UIListLayout.right.Size = UDim2.new(0.25, 0, 0.05, 0)
        elseif v317 == 3 and v316 == 2 or v317 == 2 and v316 == 3 then
            v_u_25.UIListLayout.left.Size = UDim2.new(0.5, 0, 0.05, 0)
            v_u_25.UIListLayout.right.Size = UDim2.new(0.5, 0, 0.05, 0)
        elseif v317 == 4 and v316 == 1 then
            v_u_25.UIListLayout.left.Size = UDim2.new(0.75, 0, 0.05, 0)
            v_u_25.UIListLayout.right.Size = UDim2.new(0.25, 0, 0.05, 0)
        elseif v317 == 1 and v316 == 4 then
            v_u_25.UIListLayout.left.Size = UDim2.new(0.25, 0, 0.05, 0)
            v_u_25.UIListLayout.right.Size = UDim2.new(0.75, 0, 0.05, 0)
        end;
    end;
    if v_u_25 and v_u_25.Name == "laststand" then
        l_core_game_0.scoreframe.objective_uis.Visible = true
        v_u_25.Visible = true
        local v328 = v_u_41
        if l_values_0.gamemode_specific.attacking_team.Value == "nation" then
            v328 = v_u_40
        end;
        if v328 and (v328:FindFirstChild("gate") and v328.gate:FindFirstChild("bombsneed")) then
            v_u_25.objpiece.Visible = true
            v_u_25.objpiece.gatehealth.bar.Size = UDim2.new(v328.gate.bombsneed.Value / v328.gate.bombsneed.max.Value, 0, 0.8, 0)
        else
            v_u_25.objpiece.Visible = false
        end;
    end;
    l_core_game_0.healthlow.ImageTransparency = v_u_2:lerp(l_core_game_0.healthlow.ImageTransparency, v_u_1.Health <= 99 and 0 or 1, 0.1)
    if l_Character_0:FindFirstChild("morale") then
        if v_u_8.Value ~= "vet" then
            l_core_game_0.morale.ImageTransparency = v_u_2:lerp(l_core_game_0.morale.ImageTransparency, 0.95, 0.1)
            if v_u_81.morale == false then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "morale",
                    ["location"] = l_CurrentCamera_0
                }, true)
            end;
        end;
        v_u_81.morale = true
    else
        v_u_81.morale = false
        l_core_game_0.morale.ImageTransparency = v_u_2:lerp(l_core_game_0.morale.ImageTransparency, 1, 0.1)
    end;
    local v329 = 1
    local v330 = 0
    local v331 = #v_u_12:GetChildren() >= 1 and (#v_u_12:GetChildren() == 2 and 0.4 or 0.2) or 0
    if v_u_12:FindFirstChild("int") then
        v_u_81.sprinting = false
        v_u_246 = false
    end;
    if l_Character_0:FindFirstChild("crippled") then
        v_u_81.sprinting = false
        v_u_246 = false
    end;
    if #v_u_12:GetChildren() > v_u_3.chem_tolerance or v_u_12:FindFirstChild("int") then
        v_u_81.sick = true
        v_u_229()
        v331 = -0.8
    else
        v_u_81.sick = false
    end;
    local v332 = v_u_1.Health < 100 and v_u_81.aiming == false
    local v333
    if v_u_1:FindFirstChild("burning_light") then
        v332 = false
        v333 = true
    else
        v333 = false
    end;
    if v_u_145 and v_u_145:FindFirstChild("guarding") then
        v332 = false
        v333 = false
    elseif l_Character_0:FindFirstChild("dreadnought") then
        v332 = false
        v333 = false
    end;
    if v_u_1:FindFirstChild("burning_heavy") then
        v332 = false
        v333 = false
        if v_u_71.burning_heavy.IsPlaying == false then
            v_u_71.burning_heavy:Play(0.3, 1, 0.75)
            v_u_71.burning_heavy.TimePosition = math.random(0, 15) / 10
        end;
    end;
    if v332 == false then
        v_u_71.injured_left:Stop(0.15)
        v_u_71.injured_right:Stop(0.15)
    else
        local l_injured_left_0 = v_u_71.injured_left
        local l_injured_right_0 = v_u_71.injured_right
        if v_u_145 and v_u_145:FindFirstChild("lefthanded") then
            l_injured_left_0 = v_u_71.injured_right
            l_injured_right_0 = v_u_71.injured_left
        end;
        if l_injured_left_0.IsPlaying == false then
            l_injured_left_0:Play(0.15, 1, 0.5)
        end;
        l_injured_right_0:Stop(0.15)
    end;
    if v333 == false then
        v_u_71.burning_left:Stop(0.3)
        v_u_71.burning_right:Stop(0.3)
    else
        local l_burning_right_0 = v_u_71.burning_right
        local l_burning_left_0 = v_u_71.burning_left
        if v_u_145 and v_u_145:FindFirstChild("lefthanded") then
            l_burning_right_0 = v_u_71.burning_left
            l_burning_left_0 = v_u_71.burning_right
        end;
        if l_burning_right_0.IsPlaying == false then
            l_burning_right_0:Play(0.15, 1, 1)
        end;
        l_burning_left_0:Stop(0.15)
    end;
    if tick() - v_u_101 <= 5 then
        local v334 = math.sin(tick() * 1.5) / 10
        game:GetService("SoundService").mainSoundGroup.comp.Enabled = true
        game:GetService("SoundService").maskSoundGroup.comp.Enabled = true
        v330 = 2 + math.abs(v334 * 50)
    end;
    if v_u_1.Health < 100 then
        game:GetService("SoundService").mainSoundGroup.comp.Enabled = true
        game:GetService("SoundService").maskSoundGroup.comp.Enabled = true
        if tick() - v_u_212 >= 1.5 then
            v_u_212 = tick()
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "heartbeat",
                ["location"] = l_CurrentCamera_0
            }, true)
        end;
        local v335 = math.sin(tick() * 1.5) / 10
        v330 = 5 + math.abs(v335 * 50)
        l_core_game_0.injuredhealth.Size = l_core_game_0.injuredhealth.Size:Lerp(UDim2.new(1.1 - v335, 0, 1.1 - v335, 0), 0.1)
        v329 = 0.5
    else
        game:GetService("SoundService").mainSoundGroup.comp.Enabled = false
        game:GetService("SoundService").maskSoundGroup.comp.Enabled = false
    end;
    l_core_game_0.injuredhealth.ImageTransparency = v_u_2:lerp(l_core_game_0.injuredhealth.ImageTransparency, v329, 0.1)
    if v_u_9.Value == "conscript" then
        v330 = v330 / 2
    end;
    v_u_57.Size = v_u_2:lerp(v_u_57.Size, v330, 0.1)
    v_u_58.Saturation = v_u_2:lerp(v_u_58.Saturation, v331, 0.1)
    v_u_58.TintColor = v_u_58.TintColor:Lerp(v308, 0.1)
    if tick() - v_u_81.air_just_jumped <= 0.1 then
        v_u_81.jumped_air = true
    else
        v_u_81.jumped_air = false
    end;
    local v336 = v_u_6.Position + v_u_6.CFrame.RightVector * 0.5
    local v337, _ = v_u_2:raycastline({
        ["point"] = v336,
        ["destination"] = -CFrame.new(v336, v336 + Vector3.new(0, 50, 0)).LookVector,
        ["range"] = 5,
        ["layermask"] = v_u_47
    })
    if v337 == nil then
        local v338 = v_u_6.Position - v_u_6.CFrame.RightVector * 0.5
        v337 = v_u_2:raycastline({
            ["point"] = v338,
            ["destination"] = -CFrame.new(v338, v338 + Vector3.new(0, 50, 0)).LookVector,
            ["range"] = 5,
            ["layermask"] = v_u_47
        })
    end;
    if v337 or tick() - v_u_81.lifetime <= 1 then
        if v_u_81.in_air == true then
            v_u_81.air_just_jumped = 0
            local v339 = v_u_8.Value == "knockdown" and (l_keysheld_0[Enum.KeyCode.Space] == true or l_keysheld_0[Enum.KeyCode.ButtonA] == true) and (tick() - v_u_247 >= 2 and l_Character_0.HumanoidRootPart.Velocity.Magnitude >= 22) and (l_Character_0:FindFirstChild("cowboy") and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") and -5 or -30) or -70
            if v_u_6.Velocity.Y <= -19 then
                v_u_71.jump_land:Play(0.1, 0.8, 2)
                local v340
                if l_Character_0:FindFirstChild("dreadnought") then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "armour_fall" .. math.random(1, 3),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_6
                    })
                    v340 = 0.75
                else
                    v340 = 0
                end;
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "land",
                    ["volume_adjust"] = v340,
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_6
                })
            end;
            if v_u_6.Velocity.Y <= v339 then
                if v339 <= -30 then
                    v_u_247 = tick()
                end;
                v_u_130(math.random(1, 2), true)
            end;
        end;
        if v_u_71.jump_midair.IsPlaying == true then
            v_u_71.jump_midair:Stop(0.2)
        end;
        if v_u_71.arms_midair.IsPlaying == true then
            v_u_71.arms_midair:Stop(0.3)
        end;
        v_u_81.in_air = false
        v_u_81.in_air_timer = tick()
        v_u_81.floor = v337
        v_u_216 = false
    else
        if v_u_71.jump_midair.IsPlaying == false then
            v_u_71.jump_midair:Play(0.2, 1, 0.5)
        end;
        if v_u_71.arms_midair.IsPlaying == false then
            v_u_71.arms_midair:Play(0.2, 1, 0.5)
        end;
        v_u_81.floor = nil
        v_u_81.in_air = true
        v_u_210 = 0
        v_u_211 = 0
        v_u_81.jump_tick = tick()
        v_u_81.crouching_cd = tick()
        v_u_81.crouching = false
        if tick() - v_u_81.air_just_jumped <= 0.2 then
            v_u_81.air_just_jumped = tick()
        end;
        if v_u_81.jumped_air == true then
            v_u_81.aim_time = tick()
        end;
        if tick() - v_u_81.in_air_timer >= 0.35 then
            v_u_81.sprinting = false
            v_u_246 = false
        end;
    end;
    local v341 = l_CurrentCamera_0.CFrame:ToEulerAnglesYXZ()
    local v342 = 0
    local v343 = _G.get_settings("transpcrosshair") == true and 0.5 or 0
    l_core_game_0.akimbocrosshair.Visible = false
    if v_u_145 then
        if v_u_74 ~= nil and (tick() - v_u_78 > 0.3 and v_u_74) then
            v_u_74:Stop(0.4)
            v_u_74:Destroy()
            v_u_74 = nil
        end;
        if v_u_145.weapon.Value ~= "firstaid" then
            v342 = math.rad(v341 * 50)
        end;
        if v_u_145:FindFirstChild("akimbo") and (v_u_145.akimbo.Value == true and (l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "akimbo")) then
            if _G.get_settings("staticcrosshair") == true or (l_core_game_0.crosshair.Visible ~= true or v_u_81.gun_crosshair ~= true) then
                v343 = 0.5
            else
                l_core_game_0.akimbocrosshair.Visible = true
                v343 = 0.5
            end;
        end;
        local v344 = l_Character_0:FindFirstChild(v_u_145.weapon.Value .. v_u_145.slot.Value)
        local v345 = v_u_55 and v344 and (v344:FindFirstChild("hitbox") or v344:FindFirstChild("unequipped"))
        if v345 then
            v_u_55.CFrame = v345.CFrame + v_u_6.CFrame.rightVector * 0.5 + v_u_6.CFrame.upVector * 1
        end;
        if l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson then
            v_u_55.CFrame = l_CurrentCamera_0.CFrame + l_CurrentCamera_0.CFrame.LookVector * 1 + l_CurrentCamera_0.CFrame.RightVector * 1 - l_CurrentCamera_0.CFrame.UpVector * 0.5
        end;
    else
        l_core_game_0.barrelobstruction.Visible = false
        l_core_game_0.crosshair.Size = UDim2.new(0, 0, 0, 0)
        l_core_game_0.crosshair.Visible = false
        l_core_game_0.genericcrosshair.Visible = true
    end;
    l_core_game_0.crosshair.main.left.BackgroundTransparency = v343
    l_core_game_0.crosshair.main.right.BackgroundTransparency = v343
    l_core_game_0.crosshair.main.up.BackgroundTransparency = v343
    l_core_game_0.crosshair.main.down.BackgroundTransparency = v343
    local v346 = v_u_74 ~= nil and 0 or v341
    local v347 = CFrame.new()
    local v348 = CFrame.new()
    CFrame.new()
    local v349 = ""
    local v350
    if v_u_81.aiming == true and (v_u_145 and (v_u_145:FindFirstChild("pistol") and (l_ObjectValue_0.Value == nil and (not v_u_145 or (not v_u_145:FindFirstChild("bipod") or tick() - v_u_145.bipod.Value > v_u_3.bulwark_buffer)) and true or false) == true)) then
        local l_rightVector_0 = v_u_6.CFrame.rightVector
        if v_u_81.flip_cam == true then
            l_rightVector_0 = -v_u_6.CFrame.rightVector
            v350 = "left"
        else
            v350 = "right"
        end;
        local v351, _ = v_u_2:raycastline({
            ["point"] = v_u_6.Position + Vector3.new(0, 1, 0) - l_rightVector_0,
            ["destination"] = v_u_6.CFrame.lookVector,
            ["range"] = 5,
            ["layermask"] = v_u_47
        })
        if v351 then
            local v352, _ = v_u_2:raycastline({
                ["point"] = l_CurrentCamera_0.CFrame.Position,
                ["destination"] = l_CurrentCamera_0.CFrame.LookVector,
                ["range"] = 5,
                ["layermask"] = v_u_47
            })
            if v352 == nil then
                if v350 == "right" then
                    v347 = CFrame.new(-0.25, 0, 0) * CFrame.Angles(0, -0.17453292519943295, 0)
                    v348 = CFrame.new(0, 0.2, -0.35) * CFrame.Angles(-0.17453292519943295, 0, 0)
                else
                    v347 = CFrame.new(0.25, 0, 0) * CFrame.Angles(0, 0.17453292519943295, 0)
                    v348 = CFrame.new(0, -0.2, 0.35) * CFrame.Angles(0.17453292519943295, 0, 0)
                end;
            else
                v350 = v349
            end;
        else
            v350 = v349
        end;
    else
        v350 = v349
    end;
    if l_Character_0.Parent == workspace.nation_team or (l_Character_0.Parent == workspace.empire_team or l_Character_0.Parent == workspace.evacs) then
        l_remotes_0.player_relay:FireServer(v_u_6.CFrame, v346, v_u_6.Velocity, workspace.serverStuff.serverTick.Value, v_u_81.crouching, v350)
    end;
    local _, v353, _ = l_CurrentCamera_0.CFrame:ToOrientation()
    l_Part_0.CFrame = CFrame.new(l_CurrentCamera_0.CFrame.Position) * CFrame.fromOrientation(0, v353, 0)
    if l_Character_0:FindFirstChild("exec") or l_Character_0:FindFirstChild("execing") then
        v_u_81.crouching_cd = tick()
        v_u_81.crouching = false
        v346 = 0
        v342 = 0
    end;
    if l_Character_0:FindFirstChild("Torso") and (l_Character_0:FindFirstChild("Left Arm") and l_Character_0:FindFirstChild("Right Arm")) then
        local v354 = 0
        local v355 = 0
        local v356 = true
        local v357, v358, v359, v360
        if v_u_81.aiming == true then
            v357 = 0.95
            v358 = 0.95
            v359 = 0.95
            v360 = 0.95
            if v342 >= 0.43 or v342 <= -0.9 then
                v354 = 0.95
            end;
        else
            v358 = 0
            v359 = 0
            v357 = 0
            v360 = 0
        end;
        local v361 = v_u_81.shift_locked == true and 0.9 or v355
        local v362 = _G.get_settings("alwaysshowlance") == false and v_u_9.Value == "lancer" and 0.95 or v357
        if _G.get_settings("disabletransparent") == true or (l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson or v_u_81.shift_locked == false) then
            v358 = 0
            v359 = 0
            v362 = 0
            v354 = 0
            v361 = 0
        end;
        if _G.get_settings("disabletransparent") == true then
            v356 = false
            v360 = 0
        end;
        if l_Character_0:FindFirstChild("accessories") then
            for _, v363 in ipairs(l_Character_0.accessories:GetChildren()) do
                if v363:FindFirstChild("limb") then
                    for _, v364 in ipairs(v363:GetDescendants()) do
                        if v364:IsA("BasePart") then
                            if v363.limb.Value ~= "Torso" then
                                v364.LocalTransparencyModifier = 0
                            end;
                            if v364.Transparency ~= 1 then
                                v364.Transparency = v354
                            end;
                        end;
                    end;
                end;
            end;
        end;
        l_Character_0.Torso.Transparency = v354
        l_Character_0["Left Arm"].Transparency = v354
        l_Character_0["Right Arm"].Transparency = v354
        local v365 = nil
        local v366 = nil
        for _, v367 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
            if v367:FindFirstChild("slot") and (v367:FindFirstChild("weapon") and (v367.slot.Value == 1 or v367.slot.Value == 2)) and (v367:FindFirstChild("pistol") and v367.pistol.Value == false or v_u_280[v367.weapon.Value] == true) and v367:FindFirstChild("model") then
                if v367.slot.Value == 1 then
                    v365 = v367.model.Value
                else
                    v366 = v367.model.Value
                end;
            end;
        end;
        if v_u_145 and v_u_145:FindFirstChild("weapon") and (v_u_145:FindFirstChild("pistol") and v_u_145.pistol.Value == false or v_u_280[v_u_145.weapon.Value] == true) and (v_u_145:FindFirstChild("model") and (v_u_145:FindFirstChild("slot") and (v_u_145.slot.Value == 1 or v_u_145.slot.Value == 2))) then
            if v_u_145.slot.Value == 1 then
                v365 = v_u_145.model.Value
                v358 = 0
            else
                v366 = v_u_145.model.Value
                v359 = 0
            end;
        end;
        if (v365 ~= nil and v365:FindFirstChild("body") or v366 ~= nil and v366:FindFirstChild("body")) and v356 == true then
            if v365 then
                for _, v368 in ipairs(v365:GetDescendants()) do
                    if v368:IsA("BasePart") then
                        if v358 == 0 then
                            if v368.Transparency ~= 1 then
                                v368.Transparency = v358
                            end;
                        elseif v368.Transparency == 0 then
                            v368.Transparency = v358
                        end;
                    end;
                end;
            end;
            if v366 then
                for _, v369 in ipairs(v366:GetDescendants()) do
                    if v369:IsA("BasePart") then
                        if v359 == 0 then
                            if v369.Transparency ~= 1 then
                                v369.Transparency = v359
                            end;
                        elseif v369.Transparency == 0 then
                            v369.Transparency = v359
                        end;
                    end;
                end;
            end;
        end;
        if l_Character_0:FindFirstChild("helmet") and (l_Character_0.helmet:FindFirstChild("knock") and (l_Character_0.helmet.knock:FindFirstChild("horns") and l_LocalPlayer_0.Team == game.Teams["Golden Empire"])) then
            l_Character_0.helmet.knock.horns.Transparency = v361
            l_Character_0.helmet.knock.feather1.Transparency = v361
            l_Character_0.helmet.knock.feather2.Transparency = v361
        end;
        if l_Character_0:FindFirstChild("helmet") and (l_Character_0.helmet:FindFirstChild("knock") and (l_Character_0.helmet.knock:FindFirstChild("crown") and l_LocalPlayer_0.Team == game.Teams["Golden Empire"])) then
            l_Character_0.helmet.knock.crown.Transparency = v361
        end;
        if l_Character_0:FindFirstChild("hat") and (l_Character_0.hat:FindFirstChild("hat") and (l_Character_0.hat.hat:FindFirstChild("hatpiece") and l_Character_0.hat:FindFirstChild("invisaim"))) then
            l_Character_0.hat.hat.hatpiece.Transparency = v362
            for _, v370 in ipairs(l_Character_0.hat.hat.hatpiece:GetChildren()) do
                if v370:IsA("BasePart") then
                    v370.Transparency = v362
                end;
            end;
        end;
        if l_Character_0:FindFirstChild("lance1") and (l_Character_0.lance1:FindFirstChild("parts") and (l_Character_0.lance1.parts:FindFirstChild("flag") and l_Character_0.lance1.parts.flag:FindFirstChild("flagpiece"))) then
            l_Character_0.lance1.parts.flag.flagpiece.Transparency = v362
            for _, v371 in ipairs(l_Character_0.lance1.body:GetChildren()) do
                if v371:IsA("BasePart") then
                    v371.Transparency = v362
                end;
            end;
        end;
        if l_Character_0:FindFirstChild("lewis1") and (l_Character_0.lewis1:FindFirstChild("parts") and l_Character_0.lewis1.parts:FindFirstChild("shield")) then
            l_Character_0.lewis1.parts.shield.Transparency = v360
            if l_Character_0.lewis1:FindFirstChild("accessorypart") and l_Character_0.lewis1.accessorypart:FindFirstChild("extra") then
                for _, v372 in ipairs(l_Character_0.lewis1.accessorypart.extra:GetChildren()) do
                    if v372:IsA("BasePart") then
                        if v372.Transparency == 1 then
                            if v372:FindFirstChild("decal1") then
                                v372.decal1.Transparency = v360
                            end;
                            if v372:FindFirstChild("decal2") then
                                v372.decal2.Transparency = v360
                            end;
                            if v372:FindFirstChild("decal3") then
                                v372.decal3.Transparency = v360
                            end;
                            if v372:FindFirstChild("decal4") then
                                v372.decal4.Transparency = v360
                            end;
                            if v372:FindFirstChild("decal5") then
                                v372.decal5.Transparency = v360
                            end;
                        else
                            v372.Transparency = v360
                        end;
                    end;
                end;
            end;
        end;
        if l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "rook" and (l_Character_0:FindFirstChild("helmet") and (l_Character_0.helmet:FindFirstChild("knock") and (l_Character_0.helmet.knock:FindFirstChild("leftwing") and l_Character_0.helmet.knock:FindFirstChild("rightwing"))))) then
            l_Character_0.helmet.knock.leftwing.Transparency = v361
            l_Character_0.helmet.knock.rightwing.Transparency = v361
        end;
        if l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "lancer" and l_Character_0:FindFirstChild("lancer_elitetorso")) then
            local v373 = l_Character_0.lancer_elitetorso:FindFirstChild("nationflag")
            if v373 == nil then
                v373 = l_Character_0.lancer_elitetorso:FindFirstChild("empireflag")
            end;
            if v373 then
                v373.Transparency = v361
            end;
        end;
    end;
    local v374 = CFrame.new(0, 0, 0)
    if v_u_81.crouching == true then
        v374 = CFrame.new(0, -0.85, 0)
    end;
    if v_u_8.Value == "tracker" and tick() - v_u_238 >= 1 then
        v_u_238 = tick()
        local v375 = false
        for _, v376 in ipairs(l_nation_team_0:GetChildren()) do
            if v376:FindFirstChild("Humanoid") and (v376.Humanoid.Health > 0 and (v376.Humanoid.Health <= 99 and (v376:FindFirstChild("HumanoidRootPart") and (v376.HumanoidRootPart.Position - v_u_6.Position).magnitude <= 80))) then
                v_u_4("hearbeaticon", {
                    ["location"] = v376.HumanoidRootPart.CFrame
                }, true)
                v375 = true
            end;
        end;
        if v375 == true and tick() - v_u_240 >= 2 then
            v_u_240 = tick()
            v_u_239 = tick()
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "tracking_heartbeat",
                ["location"] = l_CurrentCamera_0,
                ["pitchvariation"] = 0.1
            }, true)
        end;
    end;
    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
        if v_u_30.mark == nil then
            v_u_30.mark = game.ReplicatedStorage.misc.hunt_light:Clone()
            v_u_30.mark_buffer = 0
            v_u_30.alertping_cd = 0
        end;
        if v_u_30.target == nil then
            v_u_30.mark.Parent = nil
            local v_u_377 = false
            local v378 = nil
            for _, v379 in ipairs(l_nation_team_0:GetChildren()) do
                if v379:FindFirstChild("Humanoid") and (v379.Humanoid.Health > 0 and (v379:FindFirstChild("HumanoidRootPart") and v379:FindFirstChild("dreadnought") == nil)) then
                    local l_magnitude_0 = (v379.HumanoidRootPart.Position - v_u_6.Position).magnitude
                    if l_magnitude_0 <= 75 then
                        v_u_377 = v379:FindFirstChild("elitekit") and true or v_u_377
                        if not v_u_377 or v_u_377 and v379:FindFirstChild("elitekit") then
                            if v379:FindFirstChild("elitekit") then
                                if v379.elitekit.Value == "jaeger" then
                                    v378 = v379
                                    break;
                                end;
                                v378 = v379
                            else
                                v378 = v379
                            end;
                        end;
                    elseif l_magnitude_0 <= 90 and v379:FindFirstChild("elitekit") then
                        return;
                    end;
                end;
            end;
            if v378 then
                v_u_30.mark_buffer = tick()
                v_u_30.target = v378
                local v380 = game.Players:GetPlayerFromCharacter(v378)
                if v380 then
                    v_u_167("hunt_target", v380, v378.Torso)
                    l_remotes_0.game_handler:FireServer("jaegermarked", v380)
                end;
                if tick() - v_u_30.alertping_cd >= 2 then
                    v_u_30.alertping_cd = tick()
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "whisper" .. math.random(1, 4),
                        ["location"] = l_CurrentCamera_0
                    }, true)
                end;
            end;
            delay(4, function() --[[ Line: 4816 ]]
                --[[ Upvalues: (ref 1): v_u_30, (ref 2): v_u_377, (ref 3): l_nation_team_0, (ref 4): v_u_6, (ref 5): l_remotes_0, (ref 6): v_u_167, (ref 7): v_u_2, (ref 8): l_CurrentCamera_0 ]]
                if v_u_30.mark ~= nil and v_u_377 == false then
                    local v381 = nil
                    for _, v382 in ipairs(l_nation_team_0:GetChildren()) do
                        if v382:FindFirstChild("Humanoid") and (v382.Humanoid.Health > 0 and (v382:FindFirstChild("HumanoidRootPart") and (v382:FindFirstChild("dreadnought") == nil and (v382 ~= v_u_30.target and (v382.HumanoidRootPart.Position - v_u_6.Position).magnitude <= 75)))) then
                            if v382:FindFirstChild("elitekit") then
                                v_u_377 = true
                            end;
                            if not v_u_377 or v_u_377 and v382:FindFirstChild("elitekit") then
                                if v382:FindFirstChild("elitekit") and v382.elitekit.Value == "jaeger" then
                                    v381 = v382
                                    break;
                                end;
                                v381 = v382
                            end;
                        end;
                    end;
                    if v381 and v_u_377 then
                        v_u_30.mark_buffer = tick()
                        l_remotes_0.game_handler:FireServer("jaegerswitch", game.Players:GetPlayerFromCharacter(v_u_30.target))
                        v_u_30.target = v381
                        local v383 = game.Players:GetPlayerFromCharacter(v381)
                        if v383 then
                            v_u_167("hunt_target", v383, v381.Torso)
                            l_remotes_0.game_handler:FireServer("jaegermarked", v383)
                        end;
                        if tick() - v_u_30.alertping_cd >= 2 then
                            v_u_30.alertping_cd = tick()
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "whisper" .. math.random(1, 4),
                                ["location"] = l_CurrentCamera_0
                            }, true)
                        end;
                    end;
                end;
            end)
        elseif v_u_30.target == nil or (v_u_30.target:FindFirstChild("Humanoid") == nil or (v_u_30.target.Humanoid.Health <= 0 or v_u_30.target:FindFirstChild("HumanoidRootPart") == nil)) then
            v_u_30.target = nil
            v_u_30.mark.Parent = nil
        else
            v_u_30.mark.Parent = v_u_30.target
            if (v_u_30.target.HumanoidRootPart.Position - v_u_6.Position).magnitude > 75 then
                if tick() - v_u_30.mark_buffer >= 6 then
                    l_remotes_0.game_handler:FireServer("jaegerlost", game.Players:GetPlayerFromCharacter(v_u_30.target))
                    v_u_30.target = nil
                    v_u_30.mark.Parent = nil
                end;
            else
                v_u_30.mark_buffer = tick()
            end;
        end;
    end;
    local v384 = (not v_u_145 or (not v_u_145:FindFirstChild("weapon") or (v_u_145.weapon.Value ~= "vanguardshield" or v342 > -0.3))) and 0 or v342 + 0.3
    local v385 = l_Character_0.Torso.CFrame:toObjectSpace(v_u_6.CFrame * CFrame.Angles(v342 - v384, v_u_6.RootJoint.CurrentAngle, 0) * CFrame.new(-1, 0.5, 0) * v374 * CFrame.Angles(0, -1.5707963267948966, 0) * v348)
    local v386 = l_Character_0.Torso.CFrame:toObjectSpace(v_u_6.CFrame * CFrame.Angles(v342, v_u_6.RootJoint.CurrentAngle, 0) * CFrame.new(1, 0.5, 0) * v374 * CFrame.Angles(0, 1.5707963267948966, 0) * v348:Inverse())
    v_u_81.adsing = false
    if l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson and (l_Character_0:FindFirstChild("execing") == nil and (v_u_81.charging == false and v_u_81.slow_rotate == false)) then
        local v387 = CFrame.new(0.5, -1.75, 0)
        if v_u_145 and (v_u_145:FindFirstChild("left_aiming") and v_u_145.left_aiming.Value == true) then
            v387 = CFrame.new(-0.4, -1.75, 0)
        end;
        if v_u_145 and (v_u_145:FindFirstChild("guarding") and (v_u_145.guarding.Value == true and v_u_81.aiming == false)) then
            v387 = CFrame.new(0.15, -1.85, 0)
        end;
        if v_u_145 and (v_u_145:FindFirstChild("akimbo") and v_u_145.akimbo.Value == true) then
            v387 = CFrame.new(0, -1.75, 0)
        end;
        v385 = l_Character_0.Torso.CFrame:toObjectSpace(l_CurrentCamera_0.CFrame * CFrame.Angles(-v384, 0, 0) * v387 * CFrame.Angles(0, v_u_6.RootJoint.CurrentAngle, 0) * CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, -1.5707963267948966, 0) * v348)
        v386 = l_Character_0.Torso.CFrame:toObjectSpace(l_CurrentCamera_0.CFrame * v387 * CFrame.Angles(0, v_u_6.RootJoint.CurrentAngle, 0) * CFrame.new(1, 0.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * v348:Inverse())
    end;
    if l_Character_0:FindFirstChild("execing") or (tick() - v_u_81.fall_damage_interrupt <= 0 or (l_core_game_0.Parent.loadout_menu.Visible == true or v_u_145 and (v_u_145.weapon.Value == "firstaid" and (v_u_81.healing_anim_self == true and l_LocalPlayer_0.CameraMode ~= Enum.CameraMode.LockFirstPerson)))) or v_u_74 ~= nil then
        v385 = v_u_214
        v386 = v_u_213
    end;
    local v388 = math.sin(time() * 5) * 0.05
    local v389 = math.cos(time() * 10) * 0.025
    local v390 = v388 * math.clamp(v_u_1.WalkSpeed / 10, 0.2, 1.3)
    local v391 = math.clamp(math.rad(-v298.x * 0.5), -0.175, 0.175)
    if v298.Magnitude <= 5 or (l_Character_0:FindFirstChild("exec") or (l_Character_0:FindFirstChild("execing") or v_u_74 ~= nil)) then
        v390 = 0
        v391 = 0
        v389 = 0
    end;
    if v_u_145 and (v_u_145:FindFirstChild("guarding") and (v_u_145.guarding.Value == true and v_u_81.aiming == false)) then
        v389 = 0
        v390 = 0
        v391 = 0
    end;
    local v392 = (v_u_9.Value == "jaeger" or (v_u_8.Value == "vet" or v_u_8.Value == "butcher")) and true or v_u_8.Value == "tracker"
    if v_u_12:FindFirstChild("inap") or (v_u_81.sick == true or (l_core_game_0:FindFirstChild("vignette") or l_Character_0:FindFirstChild("geist_hunted") and not v392)) then
        if tick() - v_u_261 >= 0.06 then
            v_u_261 = tick()
            v_u_262 = { math.rad((math.random(-10, 10))) / 14, math.rad((math.random(-10, 10))) / 14, math.rad((math.random(-10, 10))) / 14 }
        end;
    else
        v_u_262 = { 0, 0, 0 }
    end;
    if l_Character_0:FindFirstChild("geist_hunted") and not l_core_game_0.hunt_vignette:GetAttribute("active") then
        l_core_game_0.hunt_vignette.Visible = true
        l_core_game_0.hunt_vignette:SetAttribute("active", true)
        game:GetService("TweenService"):Create(l_core_game_0.hunt_vignette, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["ImageTransparency"] = v392 and 0.625 or 0.4
        }):Play()
    elseif not l_Character_0:FindFirstChild("geist_hunted") and l_core_game_0.hunt_vignette:GetAttribute("active") then
        l_core_game_0.hunt_vignette:SetAttribute("active", false)
        game:GetService("TweenService"):Create(l_core_game_0.hunt_vignette, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
            ["ImageTransparency"] = 1
        }):Play()
        delay(1, function() --[[ Line: 4991 ]]
            --[[ Upvalues: (ref 1): l_core_game_0 ]]
            l_core_game_0.hunt_vignette.Visible = false
        end)
    end;
    if l_Character_0:FindFirstChild("bodyshield") then
        v385 = v_u_214
        v389 = 0
        v390 = 0
    end;
    l_Character_0.Torso["Right Shoulder"].C0 = l_Character_0.Torso["Right Shoulder"].C0:Lerp(CFrame.Angles(v389, v390, v391) * CFrame.Angles(v_u_262[1], v_u_262[2], v_u_262[3]) * v386, 0.1)
    l_Character_0.Torso["Left Shoulder"].C0 = l_Character_0.Torso["Left Shoulder"].C0:Lerp(CFrame.Angles(v389, v390, v391) * CFrame.Angles(v_u_262[1], v_u_262[2], v_u_262[3]) * v385, 0.1)
    l_Character_0.Torso.Neck.C0 = l_Character_0.Torso.Neck.C0:Lerp(v_u_215 * CFrame.Angles(-math.rad(v346 * 40) + math.clamp(math.rad(v298.z * 0.5), -0.175, 0.175), 0, 0), 0.1)
    local v393 = 0
    local v394 = 0
    local v395 = tick() - v_u_81.inventory_display <= 2 and 0.5 or 1
    l_core_game_0.inventoryitemname.item.TextTransparency = v_u_2:lerp(l_core_game_0.inventoryitemname.item.TextTransparency, v395 == 0.5 and 0.1 or v395, 0.1)
    if (l_keysheld_0[Enum.KeyCode.Space] or l_keysheld_0[Enum.KeyCode.ButtonA]) and (v_u_216 == false and (v_u_81.in_air == true and (l_BoolValue_0.Value == false and (v_u_237 == false and l_ObjectValue_0.Value == nil)))) then
        local v396 = ""
        local v397, _ = v_u_2:raycastline({
            ["point"] = v_u_6.Position,
            ["destination"] = v_u_6.CFrame.lookVector,
            ["range"] = 2,
            ["layermask"] = v_u_47
        })
        if v397 and (not v397.Parent:FindFirstChild("Humanoid") and v397.CanCollide == true) then
            v396 = v396 .. "Y"
        end;
        local v398, _ = v_u_2:raycastline({
            ["point"] = v_u_6.Position,
            ["destination"] = v_u_6.CFrame.upVector,
            ["range"] = 3.5,
            ["layermask"] = v_u_47
        })
        if not v398 then
            v396 = v396 .. "Y"
        end;
        local v399, _ = v_u_2:raycastline({
            ["point"] = v_u_6.Position + Vector3.new(0, 2.5, 0),
            ["destination"] = v_u_6.CFrame.lookVector,
            ["range"] = 3,
            ["layermask"] = v_u_47
        })
        if not v399 then
            v396 = v396 .. "Y"
        end;
        local v400, _ = v_u_2:raycastline({
            ["point"] = v_u_6.Position + Vector3.new(0, 6, 0),
            ["destination"] = v_u_6.CFrame.lookVector,
            ["range"] = 3,
            ["layermask"] = v_u_47
        })
        if not v400 then
            v396 = v396 .. "Y"
        end;
        if v396 == "YYYY" then
            v_u_216 = true
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "mantle" .. math.random(1, 4),
                ["location"] = l_Character_0.Torso
            })
            v_u_71.mantle:Play(0.05, 1, 1)
            v_u_217 = tick()
            l_BoolValue_0.Value = true
            local l_BodyPosition_1 = Instance.new("BodyPosition")
            l_BodyPosition_1.Name = "parkourPositionThing"
            l_BodyPosition_1.MaxForce = Vector3.new(200000, 200000, 200000)
            l_BodyPosition_1.P = 2000
            l_BodyPosition_1.D = 500
            l_BodyPosition_1.Position = v_u_6.Position + Vector3.new(0, 5, 0) + v_u_6.CFrame.lookVector * 5
            l_BodyPosition_1.Parent = v_u_6
            delay(0.4, function() --[[ Line: 5089 ]]
                --[[ Upvalues: (ref 1): l_BoolValue_0, (copy 2): l_BodyPosition_1 ]]
                l_BoolValue_0.Value = false
                l_BodyPosition_1:Destroy()
            end)
        end;
    end;
    for _, v401 in ipairs(l_core_game_0.inventory:GetChildren()) do
        if v401:IsA("Frame") and v401.Name ~= "ex" then
            v401.line.BackgroundTransparency = v_u_2:lerp(v401.line.BackgroundTransparency, v395, 0.1)
            v401.icon.ImageTransparency = v401.line.BackgroundTransparency
            v401.num.TextTransparency = v401.line.BackgroundTransparency
        end;
    end;
    if (workspace.serverStuff.forcefirstperson.Value == true or l_Character_0:FindFirstChild("dreadnought")) and l_LocalPlayer_0.CameraMode ~= Enum.CameraMode.LockFirstPerson then
        l_LocalPlayer_0.CameraMode = Enum.CameraMode.LockFirstPerson
    end;
    local v402 = l_CurrentCamera_0.CFrame.RightVector * 1
    if v_u_81.flip_cam == true then
        v402 = -v402
    end;
    local v403 = l_CurrentCamera_0.CFrame.Position + l_CurrentCamera_0.CFrame.LookVector * 0.5 - v402 * 0.5
    local _, v404 = v_u_2:raycastline({
        ["point"] = v403,
        ["destination"] = CFrame.new(v403, v403 + v402).LookVector,
        ["range"] = 1.5,
        ["layermask"] = v_u_48
    })
    v_u_257 = (v403 - v404).Magnitude
    local _, v405 = v_u_2:raycastline({
        ["point"] = l_CurrentCamera_0.CFrame.Position,
        ["destination"] = CFrame.new(l_CurrentCamera_0.CFrame.Position, l_CurrentCamera_0.CFrame.Position + Vector3.new(0, 5, 0)).LookVector,
        ["range"] = 1,
        ["layermask"] = v_u_48
    })
    v_u_258 = (l_CurrentCamera_0.CFrame.Position - v405).Magnitude
    local _, v406 = v_u_2:raycastline({
        ["point"] = l_CurrentCamera_0.CFrame.Position,
        ["destination"] = CFrame.new(l_CurrentCamera_0.CFrame.Position, l_CurrentCamera_0.CFrame.Position - l_CurrentCamera_0.CFrame.LookVector * 2).LookVector,
        ["range"] = 1,
        ["layermask"] = v_u_48
    })
    v_u_259 = (l_CurrentCamera_0.CFrame.Position - v406).Magnitude
    local v407 = 90
    local v408 = 0
    local v409 = CFrame.Angles(math.clamp(math.rad(-v298.z * 0.5), -0.175, 0.175), math.clamp(math.rad(-v298.x * 0.5), -0.175, 0.175), 0)
    if l_Character_0:FindFirstChild("exec") or l_Character_0:FindFirstChild("execing") then
        v409 = CFrame.new()
    end;
    local v410 = 0
    if v_u_81.crouching == false then
        if v_u_71.crouch_idle.IsPlaying == true then
            v_u_71.crouch_idle:Stop(0.4)
        end;
        if v_u_71.crouch_arms.IsPlaying == true then
            v_u_71.crouch_arms:Stop(0.4)
        end;
        v_u_6.RootJoint.C0 = v_u_6.RootJoint.C0:Lerp(CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) * v409 * v347, 0.075)
    else
        v410 = 1
        if v_u_71.crouch_idle.IsPlaying == false and v_u_6.Velocity.Magnitude <= 5 then
            v_u_71.crouch_idle:Play(0.4, 1, 0.5)
        end;
        if v_u_71.crouch_arms.IsPlaying == false then
            v_u_71.crouch_arms:Play(0.4, 1, 0.5)
        end;
        v_u_6.RootJoint.C0 = v_u_6.RootJoint.C0:Lerp(CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0) * CFrame.new(0, 0, -0.85) * v409 * v347, 0.075)
    end;
    if workspace.serverStuff.values.gamestate.sub.Value == "endgame" and (v_u_40 and (v_u_40:FindFirstChild("basecenter") and v_u_40.basecenter:FindFirstChild("bb"))) then
        v_u_40.basecenter.bb.Enabled = true
        v_u_41.basecenter.bb.Enabled = true
    end;
    local v411 = 1
    if workspace.serverStuff.trainingmode.Value == true and l_core_game_0:FindFirstChild("vignette") then
        v_u_144 = 0
    end;
    local v412 = workspace.serverStuff.trainingmode.Value == true and 1 or (tick() - v_u_144 <= v_u_245 and 0 or v411)
    if v_u_81.mosin_scope ~= nil and (v_u_81.mosin_scope.Parent == l_CurrentCamera_0 and (v_u_81.gun_crosshair ~= true or (v_u_145 == nil or (v_u_145:FindFirstChild("weapon") == nil or (v_u_145.weapon.Value ~= "mosin" or (v_u_145:FindFirstChild("scoped") == nil or v_u_145.scoped.Value ~= true)))))) then
        if v_u_81.scope_kicked_first and v_u_81.scope_kicked_first == true then
            v_u_81.scope_kicked_first = false
            l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
        end;
        v_u_81.mosin_scope.Parent = nil
    end;
    local v413
    if v_u_248 > 0 then
        v413 = Vector3.new(math.random(-v_u_248, v_u_248), math.random(-v_u_248, v_u_248), 0) / 4
        if tick() - v_u_249 >= 0.03 then
            v_u_249 = tick()
            v_u_248 = v_u_248 - 1
            if v_u_248 < 0 then
                v_u_248 = 0
            end;
        end;
    else
        v413 = Vector3.new(0, 0, 0)
    end;
    v_u_250 = v_u_2:lerp(v_u_250, v_u_251, 0.075)
    if v_u_81.shift_locked == false then
        v_u_251 = 0
        s_UserInputService_0.MouseDeltaSensitivity = 1
        if s_UserInputService_0.MouseBehavior == Enum.MouseBehavior.LockCenter then
            s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
        end;
        l_LocalPlayer_0.CameraMaxZoomDistance = v_u_3.base_max_zoom
        if v_u_71.leg_aiming.IsPlaying == true then
            v_u_71.leg_aiming:Stop(0.3)
        end;
        v_u_81.aim_sound = false
        v_u_56.Enabled = false
        v_u_1.AutoRotate = true
        s_UserInputService_0.MouseIconEnabled = true
        v_u_81.aiming = false
        l_core_game_0.crosshair.Visible = false
        l_core_game_0.genericcrosshair.Visible = false
        v_u_1.CameraOffset = v_u_1.CameraOffset:Lerp(Vector3.new(0, -v410, v_u_100) + v413, 0.075)
        v393 = 0
    else
        v_u_251 = 0
        l_LocalPlayer_0.CameraMaxZoomDistance = v_u_3.base_min_zoom
        s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.LockCenter
        local v414 = Vector3.new(0, 0, 0)
        if v_u_81.aiming == true then
            local v415 = l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson and 0.5 or 0.3
            if v350 == "left" then
                v414 = Vector3.new(-v415, 0, 0)
                v_u_251 = -4
            elseif v350 == "right" then
                v414 = Vector3.new(v415, 0, 0)
                v_u_251 = 4
            end;
            if _G.get_settings("leaningtilt") == true then
                v_u_251 = 0
            end;
            v412 = 1
            if v_u_145 and v_u_145:FindFirstChild("weapon") then
                v_u_81.sprinting = false
                v_u_246 = false
            end;
            if v_u_71.leg_aiming.IsPlaying == false then
                v_u_71.leg_aiming:Play(0.5, 1, 1)
            end;
            if v_u_81.aim_sound == false then
                v_u_81.aim_sound = true
                v_u_81.aim_time = tick()
                if v_u_145 then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "ready" .. math.random(1, 4),
                        ["location"] = v_u_6
                    })
                end;
            end;
            local v416 = 80
            if v_u_81.speed_mod > 0 and v_u_145 then
                v393 = v_u_81.speed_mod
            end;
            if _G.aim_sens then
                s_UserInputService_0.MouseDeltaSensitivity = _G.aim_sens
            end;
            l_core_game_0.crosshair.Visible = true
            v407 = v_u_81.holding_breath == true and (v_u_8.Value == "marksman" and 55 or 60) or v416
            if v_u_145 and (v_u_145:FindFirstChild("scoped") and v_u_145.scoped.Value == true) then
                v407 = v407 / 3.5
                if v_u_145:FindFirstChild("weapon") and v_u_145.weapon.Value == "binocs" then
                    l_core_game_0.binocsoverlay.Visible = true
                    v407 = v407 / 1.5
                end;
                if _G.scope_sens then
                    s_UserInputService_0.MouseDeltaSensitivity = _G.scope_sens
                end;
            end;
            if v_u_81.gun_crosshair == true then
                l_core_game_0.crosshair.main.Visible = true
                l_core_game_0.genericcrosshair.Visible = false
                if v_u_145 and (v_u_145:FindFirstChild("weapon") and (v_u_145.weapon.Value == "mosin" and (v_u_145:FindFirstChild("scoped") and v_u_145.scoped.Value == true))) then
                    if v_u_6.Velocity.Magnitude >= 1 and tick() - v_u_263 >= 0.03 then
                        local v417 = math.sin(time() * 5) * 0.05 * 0.075
                        local v418 = math.cos(time() * 10) * 0.025 * 0.075
                        v_u_263 = tick()
                        l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(v417, 0, v418)
                    end;
                    if v_u_81.mosin_scope ~= nil then
                        if v_u_81.mosin_scope.Parent == nil then
                            v_u_81.mosin_scope.Parent = l_CurrentCamera_0
                        end;
                        if l_LocalPlayer_0.CameraMode == Enum.CameraMode.Classic then
                            v_u_81.scope_kicked_first = true
                            l_LocalPlayer_0.CameraMode = Enum.CameraMode.LockFirstPerson
                        end;
                        local v419 = CFrame.Angles(0, 0, 0)
                        if v_u_145:FindFirstChild("model") and (v_u_145.model.Value and v_u_145.model.Value:FindFirstChild("special")) then
                            local v420 = v_u_145.model.Value.special:FindFirstChild("muzzle")
                            if v420 then
                                local v421, v422, v423 = l_CurrentCamera_0.CFrame.Rotation:ToObjectSpace(v420.CFrame.Rotation):ToOrientation()
                                local v424 = v_u_81.holding_breath == true and 8 or 2
                                local v425 = v421 / v424
                                local v426 = v422 / v424
                                local v427 = v423 / v424
                                v_u_81.mosin_scope.movingpart.eyerelief.texture.OffsetStudsU = 1.5 + v426
                                v_u_81.mosin_scope.movingpart.eyerelief.texture.OffsetStudsV = 1.5 - v425
                                v419 = CFrame.Angles(v425, v426, v427)
                            end;
                        end;
                        l_core_game_0.crosshair.main.Visible = false
                        local v428 = l_CurrentCamera_0.CFrame + l_CurrentCamera_0.CFrame.LookVector * 2.5
                        v_u_81.mosin_scope:PivotTo(v428)
                        v_u_81.mosin_scope.movingpart:PivotTo(v428 * v419)
                    end;
                end;
                if (l_keysheld_0[Enum.KeyCode.LeftShift] == true or l_keysheld_0[Enum.KeyCode.ButtonL3] == true) and (v_u_6.Velocity.magnitude < 3 and (v_u_81.holding_breath == false and tick() - v_u_81.hold_breathtime > v_u_81.hold_breathregen)) then
                    v_u_81.holding_breath = true
                    v_u_81.hold_breathtime = tick()
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = l_Character_0.gender.Value .. "_inhale" .. math.random(1, 3),
                        ["soundgroup"] = v_u_9.Value == "mortician" and l_Character_0:FindFirstChild("extralift") and "maskSoundGroup" or nil,
                        ["location"] = l_Character_0.Head
                    })
                end;
            else
                l_core_game_0.crosshair.main.Visible = false
                l_core_game_0.genericcrosshair.Visible = true
            end;
        else
            s_UserInputService_0.MouseDeltaSensitivity = 1
            if v_u_81.aim_sound == true then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "unready" .. math.random(1, 4),
                    ["location"] = v_u_6
                })
            end;
            l_core_game_0.crosshair.Visible = false
            l_core_game_0.genericcrosshair.Visible = true
            v_u_81.aim_sound = false
            v_u_81.aim_time = tick()
            if v_u_71.leg_aiming.IsPlaying == true then
                v_u_71.leg_aiming:Stop(0.3)
            end;
        end;
        s_UserInputService_0.MouseIconEnabled = false
        local v429 = 1.5 - v_u_257
        local v430 = Vector3.new(1.5, 1, v_u_100)
        if v_u_81.flip_cam == true then
            v429 = -v429
            v430 = Vector3.new(-1.5, 1, v_u_100)
        end;
        local v431 = (l_CurrentCamera_0.CFrame.Position - v_u_6.Position).Magnitude >= 6.5 and Vector3.new(0, 0, 0) or Vector3.new(v429, 1 - v_u_258, 1 - v_u_259)
        if l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson then
            v431 = Vector3.new(0, (1 - v_u_258) / 2, 0)
            v430 = Vector3.new(0, 0, v_u_100 - 0.5)
        end;
        local v432 = v430 - Vector3.new(0, v410, 0.2)
        if l_ObjectValue_0.Value == nil then
            v_u_1.CameraOffset = v_u_1.CameraOffset:Lerp(v432 + v413 + v414, 0.075) - v431
        else
            v_u_1.CameraOffset = v_u_1.CameraOffset:Lerp(Vector3.new(0, 2, v_u_100 - 4) + v413, 0.075)
        end;
        v_u_1.AutoRotate = false
        if v_u_81.charging == true or (v_u_81.slow_rotate == true or tick() - v_u_81.fall_damage_interrupt < 0) then
            v_u_56.MaxAngularVelocity = 2
            v_u_56.Responsiveness = 2
            if (v_u_8.Value == "butcher" or (v_u_8.Value == "vet" or l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "lancer")) and v_u_9.Value == "lancer" then
                v_u_56.MaxAngularVelocity = 6
                v_u_56.Responsiveness = 6
            end;
            if v_u_81.slow_rotate == true then
                v_u_56.MaxAngularVelocity = 12
                v_u_56.Responsiveness = 12
            end;
        else
            v_u_56.MaxAngularVelocity = 100
            v_u_56.Responsiveness = 100
        end;
        if l_Character_0:FindFirstChild("execing") then
            v_u_56.Enabled = false
        else
            v_u_56.Enabled = true
        end;
    end;
    if v_u_74 ~= nil then
        v_u_1.AutoRotate = false
        v_u_56.Enabled = false
    end;
    local v433 = l_core_game_0.helmetoverlay.Visible == true and l_Character_0 and l_Character_0:FindFirstChild("Head")
    if v433 then
        local v434, _, _ = l_CurrentCamera_0.CFrame.Rotation:ToObjectSpace(v433.CFrame.Rotation):ToOrientation()
        l_core_game_0.helmetoverlay.Position = l_core_game_0.helmetoverlay.Position:Lerp(UDim2.new(0.5, 0, 0.5 + math.clamp(v434 / 2, -0.05, 0.05), 0), 0.1)
    end;
    l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0, 0, (math.rad(v_u_250)))
    if v_u_40:FindFirstChild("basecenter") and (v_u_40.basecenter:FindFirstChild("bb") and (v_u_41:FindFirstChild("basecenter") and v_u_41.basecenter:FindFirstChild("bb"))) then
        v_u_40.basecenter.bb.label.TextTransparency = v_u_2:lerp(v_u_40.basecenter.bb.label.TextTransparency, v412, 0.1)
        v_u_41.basecenter.bb.label.TextTransparency = v_u_2:lerp(v_u_41.basecenter.bb.label.TextTransparency, v412, 0.1)
    end;
    v_u_81.accuracy_modifier = 1
    v_u_81.handling_modifier = 1
    v_u_81.draw_modifier = 1
    if v_u_12:FindFirstChild("hal") and v_u_81.sick == false then
        local v435 = v_u_81
        v435.handling_modifier = v435.handling_modifier + 0.3
        local v436 = v_u_81
        v436.draw_modifier = v436.draw_modifier + 0.3
        v393 = v393 / 2
    end;
    if v_u_8.Value == "marksman" then
        local v437 = v_u_81
        v437.accuracy_modifier = v437.accuracy_modifier + 0.4
    end;
    if v_u_8.Value == "quickdraw" or l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot" then
        local v438 = v_u_81
        v438.draw_modifier = v438.draw_modifier + 0.5
        local v439 = v_u_81
        v439.handling_modifier = v439.handling_modifier + 0.5
        v393 = v393 / 5
    end;
    if v_u_9.Value == "soldat" then
        local v440 = v_u_81
        v440.draw_modifier = v440.draw_modifier + 0.3
        local v441 = v_u_81
        v441.accuracy_modifier = v441.accuracy_modifier + 0.3
        local v442 = v_u_81
        v442.handling_modifier = v442.handling_modifier + 0.3
    end;
    if l_Character_0:FindFirstChild("cowboy") then
        local v443 = v_u_81
        v443.draw_modifier = v443.draw_modifier + 0.3
        v393 = v393 / 2
    end;
    if l_Character_0:FindFirstChild("buff_focus") or l_Character_0:FindFirstChild("buff_elite") then
        local v444 = v_u_81
        v444.draw_modifier = v444.draw_modifier + 0.4
        local v445 = v_u_81
        v445.accuracy_modifier = v445.accuracy_modifier + 0.5
        local v446 = v_u_81
        v446.handling_modifier = v446.handling_modifier + 0.4
        v393 = v393 / 2
    end;
    if l_Character_0:FindFirstChild("tunnelratbuff") and l_Character_0:FindFirstChild("elitekit") == nil then
        local v447 = v_u_81
        v447.handling_modifier = v447.handling_modifier + 0.7
        local v448 = v_u_81
        v448.draw_modifier = v448.draw_modifier + 0.7
    end;
    if v_u_145 and (v_u_145:FindFirstChild("bipod") and (tick() - v_u_145.bipod.Value <= v_u_3.bulwark_buffer and v_u_81.aiming == true)) then
        local v449 = v_u_81
        v449.handling_modifier = v449.handling_modifier + 1
        v393 = v393 + 4
    end;
    if v_u_145 and (v_u_145:FindFirstChild("scoped") and v_u_145.scoped.Value == true) then
        if v_u_81.handling_modifier > 0.75 then
            v_u_81.handling_modifier = 0.75
        end;
        if v_u_81.aiming == true then
            v393 = v393 + 4
        end;
    end;
    if v_u_12:FindFirstChild("inap") then
        local v450 = v_u_81
        v450.accuracy_modifier = v450.accuracy_modifier * 0.4
        if v_u_81.handling_modifier > 0.75 then
            v_u_81.handling_modifier = 0.75
        end;
    end;
    if l_Character_0:FindFirstChild("ambi_penalty") then
        local v451 = v_u_81
        v451.accuracy_modifier = v451.accuracy_modifier * 0.6
    end;
    if v_u_145 and (v_u_145:FindFirstChild("weapon") and v_u_145.weapon.Value == "vanguardshield") then
        if v_u_81.handling_modifier > 0.6 then
            v_u_81.handling_modifier = 0.6
        end;
        local v452 = v_u_81
        v452.accuracy_modifier = v452.accuracy_modifier * 0.85
        if v_u_81.aiming == true then
            v393 = v_u_81.speed_mod
        end;
        if v_u_145:FindFirstChild("guarding") and v_u_145.guarding.Value == true then
            v393 = v_u_81.speed_mod
            v_u_81.jump_tick = tick()
        end;
    end;
    if l_Character_0:FindFirstChild("crippled") then
        if v_u_81.handling_modifier > 0.8 then
            v_u_81.handling_modifier = 0.8
        end;
        local v453 = v_u_81
        v453.accuracy_modifier = v453.accuracy_modifier * 0.8
    end;
    if tick() - v_u_81.sprint_slowed_aim <= 0.45 and (v_u_8.Value ~= "sprinter" and (not l_Character_0:FindFirstChild("elitekit") or l_Character_0.elitekit.Value ~= "jaeger" and (l_Character_0.elitekit.Value ~= "ocelot" and (not l_Character_0:FindFirstChild("class") or (l_Character_0.class.Value ~= "soldat" or l_Character_0.elitekit.Value ~= "soldat")))) and true or false) == true then
        if v_u_81.aiming == true then
            v_u_81.sprint_slowed_aim = tick() - 0.1
        end;
        v_u_81.handling_modifier = v_u_81.handling_modifier * 0.7
    end;
    l_core_game_0.Parent.dot_crosshair.Visible = false
    if _G.get_settings("staticcrosshair") == true then
        l_core_game_0.crosshair.main.Visible = false
        if v_u_81.shift_locked == true and (l_core_game_0.Visible == true and l_core_game_0.genericcrosshair.Visible == false) then
            l_core_game_0.Parent.dot_crosshair.Visible = true
        end;
        if _G.get_settings("transpcrosshair") == true then
            l_core_game_0.Parent.dot_crosshair.ImageTransparency = 0.5
        else
            l_core_game_0.Parent.dot_crosshair.ImageTransparency = 0
        end;
        if v_u_81.mosin_scope ~= nil and v_u_81.mosin_scope.Parent == l_CurrentCamera_0 then
            l_core_game_0.Parent.dot_crosshair.Visible = false
        end;
    end;
    if _G.get_settings("hidecrosshair") == true or (l_core_game_0.voicewheel.Visible == true or l_core_game_0.selectionboxes.Visible == true) then
        l_core_game_0.crosshair.main.Visible = false
        l_core_game_0.Parent.dot_crosshair.Visible = false
        l_core_game_0.genericcrosshair.Visible = false
        l_core_game_0.akimbocrosshair.Visible = false
        if l_core_game_0.voicewheel.Visible == true or l_core_game_0.selectionboxes.Visible == true then
            s_UserInputService_0.MouseIconEnabled = true
        end;
    end;
    if v_u_81.holding_breath == true and (tick() - v_u_81.hold_breathtime > v_u_81.hold_breathmax or (v_u_81.aiming == false or (v_u_6.Velocity.Magnitude >= 3 or l_keysheld_0[Enum.KeyCode.LeftShift] ~= true and _G.using_controller == false)) or (l_core_game_0.crosshair.Visible == false or v_u_81.gun_crosshair == false)) and (v_u_81.holding_breath == true and tick() - v_u_81.hold_breathtime >= v_u_81.hold_breathaccuracy) then
        v_u_81.hold_breathtime = tick()
        v_u_81.holding_breath = false
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = l_Character_0.gender.Value .. "_exhale" .. math.random(1, 3),
            ["soundgroup"] = v_u_9.Value == "mortician" and l_Character_0:FindFirstChild("extralift") and "maskSoundGroup" or nil,
            ["location"] = l_Character_0.Head
        })
        if l_core_game_0.Parent.loadout_menu.Visible ~= true then
            v_u_2:fast_spawn(function() --[[ Line: 1352 ]]
                --[[ Upvalues: (ref 1): l_CurrentCamera_0, (ref 2): l_core_game_0, (ref 3): v_u_2 ]]
                local v454 = math.random(-30, 30) / 100
                l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v454), 0)
                for _ = 1, 6 do
                    if l_core_game_0.Parent.loadout_menu.Visible == true then
                        return;
                    end;
                    l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(-0.006981317007977318, math.rad(-v454), 0)
                    v_u_2:s_wait(0.03)
                end;
                for _ = 1, 6 do
                    if l_core_game_0.Parent.loadout_menu.Visible == true then
                        return;
                    end;
                    l_CurrentCamera_0.CFrame = l_CurrentCamera_0.CFrame * CFrame.Angles(0.006981317007977318, math.rad(v454), 0)
                    v_u_2:s_wait(0.03)
                end;
            end)
        end;
    end;
    if v_u_81.holding_breath == true then
        local v455 = math.clamp((tick() - v_u_81.hold_breathtime) / v_u_81.hold_breathaccuracy, 0, 1)
        game.SoundService.radioSoundGroup.Volume = v_u_2:lerp(v_u_3.default_radiogroup, 0.05, v455)
        workspace.ambience.Volume = v_u_2:lerp(v_u_3.default_ambience, 0.2, v455)
        l_core_game_0.holdbreath.ImageTransparency = v_u_2:lerp(1, 0, v455)
    else
        local v456 = math.clamp((tick() - v_u_81.hold_breathtime) / v_u_81.hold_breathregen, 0, 1)
        game.SoundService.radioSoundGroup.Volume = v_u_2:lerp(0.05, v_u_3.default_radiogroup, v456)
        workspace.ambience.Volume = v_u_2:lerp(0.2, v_u_3.default_ambience, v456)
        l_core_game_0.holdbreath.ImageTransparency = v_u_2:lerp(0, 1, v456)
    end;
    local v457, v458
    if l_Character_0:FindFirstChild("medical_expertise") then
        v457 = 100
        v458 = true
    else
        v457 = 20
        v458 = false
    end;
    v_u_81.friendly_target = nil
    v_u_81.friendly_target = v_u_2:raycastline({
        ["point"] = l_CurrentCamera_0.CFrame.Position,
        ["destination"] = l_CurrentCamera_0.CFrame.lookVector,
        ["range"] = v457 + (l_CurrentCamera_0.CFrame.Position - v_u_6.Position).Magnitude,
        ["layermask"] = v_u_46,
        ["get_whizzbox"] = true
    })
    v_u_52.bb.Enabled = false
    v_u_52.bb.sick.Visible = false
    if v_u_54 ~= nil then
        v_u_54.Adornee = nil
        v_u_54.StudsOffset = Vector3.new(0, 0, 0)
        v_u_54.lowertext.Text = _G.using_controller == true and "R1" or _G.get_keybinds("equipment").Name
        if v_u_81.friendly_target and (v_u_81.friendly_target.Parent:FindFirstChild("Humanoid") and (v_u_81.friendly_target.Parent:FindFirstChild("chems") and (v_u_81.friendly_target.Parent:FindFirstChild("Torso") and (v_u_81.friendly_target.Parent.Humanoid.Health > 0 and v_u_81.friendly_target.Parent.Parent == l_Character_0.Parent)))) then
            local v459 = v_u_145 and (v_u_145:FindFirstChild("weapon") and v_u_145.weapon.Value == "firstaid") and true or (v458 == true and v_u_81.friendly_target ~= v_u_6 and true or false)
            local v460 = false
            local v461 = l_Character_0:FindFirstChild("perk")
            if v461 then
                v461 = l_Character_0.perk.Value == "healing"
            end;
            if v_u_9.Value == "mortician" and (v_u_81.friendly_target.Parent.Humanoid.Health < 100 and (v_u_11.Value > 0 and ((v_u_6.Position - v_u_81.friendly_target.Parent.Torso.Position).magnitude <= 20 and (v_u_81.friendly_target.Parent.Humanoid:FindFirstChild("burning_light") == nil and (v_u_81.friendly_target.Parent.Humanoid:FindFirstChild("burning_heavy") == nil and v_u_81.friendly_target.Parent:FindFirstChild("dreadnought") == nil))))) then
                v_u_54.StudsOffset = Vector3.new(0, 2, 0)
                v460 = true
            end;
            if v459 == false and v_u_11.Value > 0 then
                v460 = v_u_9.Value == "soldat" and true or v460
                if v_u_9.Value == "soldat" and (v_u_81.friendly_target.Parent:FindFirstChild("full_ammo") and v_u_81.friendly_target.Parent.full_ammo.Value == true) then
                    v460 = false
                end;
            end;
            if v460 == true then
                v_u_54.Adornee = v_u_81.friendly_target.Parent.Torso
            end;
            if v459 == true then
                v_u_52.bb.display.Text = "Healthy"
                v_u_52.bb.display.TextColor3 = Color3.fromRGB(190, 255, 160)
                v_u_52.bb.surgery.Visible = false
                local v462 = {
                    Color3.fromRGB(209, 255, 157),
                    Color3.fromRGB(255, 234, 112),
                    Color3.fromRGB(255, 155, 55),
                    Color3.fromRGB(255, 42, 42),
                    Color3.fromRGB(200, 0, 100)
                }
                local v463, v464
                if v_u_81.friendly_target.Parent:FindFirstChild("elitekit") then
                    v462 = {
                        Color3.fromRGB(214, 255, 160),
                        Color3.fromRGB(190, 255, 160),
                        Color3.fromRGB(209, 255, 157),
                        Color3.fromRGB(255, 234, 112),
                        Color3.fromRGB(255, 155, 55),
                        Color3.fromRGB(255, 42, 42),
                        Color3.fromRGB(200, 0, 100)
                    }
                    v463 = {
                        300,
                        200,
                        150,
                        100,
                        50,
                        10
                    }
                    v464 = {
                        "Negligible Injury",
                        "Light Injury",
                        "Moderate Injury",
                        "Heavy Injury",
                        "Severe Damage",
                        "Near Death"
                    }
                else
                    v463 = {
                        200,
                        150,
                        100,
                        50,
                        10
                    }
                    v464 = {
                        "Light Injury",
                        "Moderate Injury",
                        "Heavy Injury",
                        "Severe Damage",
                        "Near Death"
                    }
                end;
                local v465 = 0
                for v466 = 1, #v463 do
                    if v_u_81.friendly_target.Parent.Humanoid.Health < v463[v466] then
                        v465 = v466
                    end;
                end;
                if v_u_81.friendly_target.Parent:FindFirstChild("dreadnought") == nil then
                    if v465 ~= 0 then
                        v_u_52.bb.display.Text = v464[v465]
                        v_u_52.bb.display.TextColor3 = v462[v465]
                        if v_u_81.friendly_target.Parent.Humanoid.Health < 100 then
                            v_u_52.bb.surgery.Text = "Needs Surgery"
                            v_u_52.bb.surgery.TextColor3 = Color3.fromRGB(218, 0, 0)
                            v_u_52.bb.surgery.Visible = true
                        end;
                    end;
                    if v461 then
                        local l_display_0 = v_u_52.bb.display
                        l_display_0.Text = l_display_0.Text .. " (" .. math.ceil(v_u_81.friendly_target.Parent.Humanoid.Health) .. "ml)"
                    end;
                else
                    v_u_52.bb.display.Text = "Can\'t tell under this armour"
                    v_u_52.bb.display.TextColor3 = Color3.fromRGB(230, 230, 230, 230)
                    v_u_52.bb.surgery.Text = "Surgery Impossible"
                    v_u_52.bb.surgery.TextColor3 = Color3.fromRGB(200, 200, 200)
                    v_u_52.bb.surgery.Visible = true
                end;
                v_u_52.CFrame = v_u_81.friendly_target.Parent.Torso.CFrame
                v_u_52.bb.Enabled = true
                if (v458 or v461) and v_u_81.friendly_target.Parent:FindFirstChild("dreadnought") == nil then
                    local v467 = #v_u_81.friendly_target.Parent.chems:GetChildren()
                    v_u_52.bb.sick.Visible = true
                    v_u_52.bb.sick.TextColor3 = Color3.fromRGB(190, 255, 212)
                    if v467 >= 1 then
                        v_u_52.bb.sick.Text = v467 * 10 .. "u Chemicals"
                        if v_u_81.friendly_target.Parent.chems:FindFirstChild("per") then
                            v_u_52.bb.sick.Text = "Has Peridaxon"
                        elseif v_u_81.friendly_target.Parent.chems:FindFirstChild("tric") then
                            v_u_52.bb.sick.Text = "Has Tricordrazine"
                        end;
                        if v_u_81.friendly_target.Parent.chems:FindFirstChild("int") and v461 then
                            v_u_52.bb.sick.TextColor3 = Color3.fromRGB(255, 88, 88)
                            v_u_52.bb.sick.Text = "Poisoned"
                        elseif v_u_3.chem_tolerance < v467 then
                            v_u_52.bb.sick.TextColor3 = Color3.fromRGB(255, 136, 112)
                            v_u_52.bb.sick.Text = "Sick"
                        end;
                    else
                        v_u_52.bb.sick.Text = "Clean Bloodstream"
                    end;
                end;
            end;
        else
            v_u_81.friendly_target = nil
        end;
    end;
    if v_u_81.charging == true then
        v_u_81.sprinting = true
        v_u_81.sprint_ticker = 0
    end;
    local l_sprint_fullspeed_time_0 = v_u_3.sprint_fullspeed_time
    if l_Character_0:FindFirstChild("buff_advance") or l_Character_0:FindFirstChild("buff_elite") then
        l_sprint_fullspeed_time_0 = v_u_1.Health >= 100 and 0.75 or l_sprint_fullspeed_time_0
    end;
    local v468 = (v_u_8.Value == "sprinter" or l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "jaeger" or (l_Character_0.elitekit.Value == "ocelot" or l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "soldat" and l_Character_0.elitekit.Value == "soldat")))) and 0.3 or l_sprint_fullspeed_time_0
    if v_u_6.Velocity.magnitude > 1 and (v_u_74 ~= nil and (tick() - v_u_78 > 0.3 and v_u_74)) then
        v_u_74:Stop(0.4)
        v_u_74:Destroy()
        v_u_74 = nil
    end;
    if v_u_6.Velocity.magnitude > 2 then
        if l_Character_0:FindFirstChild("characterhitbox") then
            local v469 = false
            for _, v470 in ipairs((workspace:GetPartsInPart(l_Character_0.characterhitbox, v_u_50))) do
                if v470.Name == "barbwire" then
                    v469 = true
                    break;
                end;
            end;
            if v469 == true then
                if tick() - v_u_253 >= 0.8 then
                    v_u_253 = tick()
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "wire_step" .. math.random(1, 9),
                        ["location"] = v_u_6
                    })
                    l_remotes_0.game_handler:FireServer("barb_wiredamage")
                end;
                if tick() - v_u_254 >= 0.5 and v_u_8.Value ~= "sprinter" then
                    v_u_254 = tick()
                    local l_StringValue_3 = Instance.new("StringValue")
                    s_Debris_0:AddItem(l_StringValue_3, 0.6)
                    l_StringValue_3.Name = "crippled"
                    l_StringValue_3.Parent = l_Character_0
                end;
            end;
        end;
        local v471 = v298.z > 2 and "back" or (v298.z < -2 and "forward" or (v298.x > 2 and "right" or "left"))
        if v_u_81.crouching == true then
            v471 = "crouch" .. v471
        end;
        v_u_81.sprint_wall_stopper = tick()
        local v472 = 0.2 + v_u_1.WalkSpeed / 20
        if v_u_81.sprinting == true then
            if l_keysheld_0[Enum.KeyCode.W] == true and (l_keysheld_0[Enum.KeyCode.W] ~= true or l_keysheld_0[Enum.KeyCode.S] ~= true) or (v471 == "forward" or v_u_81.charging ~= false) then
                v471 = v468 <= tick() - v_u_81.sprint_ticker and "full_sprint" or "lean_sprint"
            else
                v_u_81.sprinting = false
                v_u_246 = false
            end;
        end;
        v_u_81.standing_still = tick()
        if v471 == "back" or v471 == "crouchback" then
            v472 = -v472
            if v_u_81.crouching == true then
                v471 = "crouchforward"
            else
                v471 = "forward"
            end;
        end;
        if v471 == "left" or v471 == "right" then
            v472 = v472 * 1.5
        end;
        local v473 = v471 == "forward" and (v472 > 0 and (v_u_81.crouching == false and l_Character_0:FindFirstChild("crippled"))) and "injured" or v471
        for v474, v475 in pairs(v_u_224) do
            if v474 ~= v473 then
                v475:Stop(0.4)
            end;
        end;
        if v_u_224[v473].IsPlaying == false then
            v_u_224[v473]:Play(0.5, 1, v472)
        else
            v_u_224[v473]:AdjustSpeed(v472)
        end;
        if v473 == "full_sprint" and v_u_81.sprinting == true then
            if v_u_71.sprinting_arms.IsPlaying == false then
                v_u_71.sprinting_arms:Play(0.5, 1, v472)
            else
                v_u_71.sprinting_arms:AdjustSpeed(v472)
            end;
        else
            v_u_71.sprinting_arms:Stop(0.4)
        end;
        if v_u_81.in_air == false then
            local v476 = math.clamp(0.8 - v_u_1.WalkSpeed / 40, 0.2, 2)
            if tick() - v_u_211 >= v476 * 1.2 then
                v_u_211 = tick()
                if l_Character_0:FindFirstChild("elitekit") or l_Character_0:FindFirstChild("dreadnought") then
                    local v477 = l_Character_0:FindFirstChild("dreadnought") and 0.2 or (v_u_81.sprinting == true and 0.4 or 0)
                    local v478
                    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
                        v478 = 10
                        v477 = 0
                    else
                        v478 = nil
                    end;
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "run_gear" .. math.random(1, 6),
                        ["force_max_dist"] = v478,
                        ["volume_adjust"] = v477,
                        ["location"] = v_u_6
                    })
                    if l_Character_0:FindFirstChild("dreadnought") then
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "armour" .. math.random(1, 5),
                            ["volume_adjust"] = v477,
                            ["location"] = v_u_6
                        })
                    end;
                end;
            end;
            if v476 <= tick() - v_u_210 and v_u_6.Anchored == false then
                v_u_210 = tick()
                if v_u_81.floor then
                    v_u_260 = not v_u_260
                    local v479, v480
                    if v_u_8.Value == "tunnelrat" or v_u_81.crouching == true then
                        v479 = 10
                        v480 = -0.25
                    else
                        v479 = nil
                        v480 = 0
                    end;
                    if v_u_81.sprinting == true then
                        local v481 = tick() - v_u_81.sprint_ticker
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "step" .. math.random(1, 4),
                            ["force_max_dist"] = v479,
                            ["vol_adjust"] = v480,
                            ["location"] = v_u_6
                        })
                        if v_u_81.charging == true then
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "step" .. math.random(1, 3),
                                ["location"] = v_u_6
                            })
                        end;
                        v480 = v481 >= v468 and 1 or v_u_2:lerp(0, 1, v481 / v468)
                    end;
                    if v_u_8.Value == "tunnelrat" or v_u_81.crouching == true then
                        v480 = v480 - 0.25
                    end;
                    if l_Character_0:FindFirstChild("accessories") and l_Character_0.accessories:FindFirstChild("spurs") then
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "spur" .. math.random(1, 4),
                            ["volume_adjust"] = v480 * 0.01,
                            ["force_max_dist"] = v479,
                            ["location"] = v_u_6
                        })
                    end;
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "step" .. math.random(1, 3),
                        ["volume_adjust"] = l_Character_0:FindFirstChild("dreadnought") and 0.4 or v480,
                        ["force_max_dist"] = v479,
                        ["location"] = v_u_6
                    })
                end;
            end;
        end;
    else
        v_u_71.sprinting_arms:Stop(0.4)
        v_u_81.moving_accuracy = tick() + 0.1
        if tick() - v_u_81.sprint_wall_stopper >= 0.5 or l_keysheld_0[Enum.KeyCode.W] == nil then
            v_u_81.sprint_ticker = tick()
            v_u_81.sprinting = false
            v_u_246 = false
        end;
        for _, v482 in pairs(v_u_224) do
            if v482.IsPlaying == true then
                v482:Stop(0.4)
            end;
        end;
    end;
    if tick() - v_u_81.sprint_force_stop <= 0 then
        v_u_81.sprinting = false
        v_u_246 = false
    end;
    if v_u_81.charging == true then
        v_u_81.sprinting = true
    end;
    if v_u_81.sprinting == true then
        v394 = v_u_3.sprint_fullspeed
        if v_u_1.Health >= 100 then
            if v_u_81.morale == true and v_u_8.Value ~= "vet" then
                v394 = v394 + 1.5
            end;
            if v_u_12:FindFirstChild("syn") and v_u_81.sick == false then
                v394 = v394 + 1
            end;
            if v_u_12:FindFirstChild("inap") and v_u_81.sick == false then
                v394 = v394 + 1.5
            end;
            if l_Character_0:FindFirstChild("buff_advance") or l_Character_0:FindFirstChild("buff_elite") then
                v394 = v394 + 2
            end;
            if l_Character_0:FindFirstChild("cowboy") then
                v394 = v394 + 2
            end;
            if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot" then
                v394 = v394 + 2
            end;
        end;
        if v_u_9.Value == "conscript" then
            v394 = v394 - 1.25
        end;
        v_u_81.crouching_cd = tick()
        if tick() - v_u_81.sprint_ticker < v468 then
            v_u_81.sprinting_max_speed = false
            local v483 = (tick() - v_u_81.sprint_ticker) / v468
            v394 = v_u_2:lerp(0, v394, v483)
            v408 = v_u_2:lerp(0, 15, v483)
        else
            v_u_81.sprint_slowed_aim = tick()
            v_u_81.sprinting_max_speed = true
            v408 = 15
        end;
        v_u_81.crouching = false
    else
        v_u_81.sprinting_max_speed = false
        v_u_81.sprinting = false
        v_u_246 = false
        v_u_81.sprint_ticker = tick()
    end;
    if v_u_81.crouching == true and v_u_8.Value ~= "tracker" then
        v393 = v393 + 2
    end;
    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot" then
        v393 = v393 - 4
    end;
    if l_Character_0:FindFirstChild("crippled") or (v_u_1:FindFirstChild("burning_light") or v_u_1:FindFirstChild("burning_heavy")) then
        v393 = v393 + 4
    end;
    if v_u_12:FindFirstChild("eth") then
        local v484 = v_u_81
        v484.accuracy_modifier = v484.accuracy_modifier * 0.8
        local v485 = v_u_81
        v485.draw_modifier = v485.draw_modifier * 0.8
        if v_u_81.handling_modifier > 0.8 then
            v_u_81.handling_modifier = 0.8
        end;
        v393 = v393 + 1
    end;
    if workspace.serverStuff.restorationmode.Value == true then
        v393 = v393 + 1
        if v_u_81.handling_modifier > 0.8 then
            v_u_81.handling_modifier = 0.8
        end;
        local v486 = v_u_81
        v486.accuracy_modifier = v486.accuracy_modifier * 0.5
    end;
    if l_Character_0.perk.Value == "tracker" and (tick() - v_u_239 <= 10 and (l_keysheld_0[Enum.KeyCode.W] == true and v_u_1.Health >= 100)) then
        v393 = v393 - 3
    end;
    if l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "officer" and v_u_9.Value == "officer") then
        v393 = v393 - 3
    end;
    if l_Character_0:FindFirstChild("stop_movement") then
        v393 = v393 + 5
    end;
    if v_u_81.charging == true then
        v_u_81.jump_tick = tick()
        v_u_1:Move(v_u_6.CFrame.lookVector)
        v_u_1.AutoRotate = false
        v394 = v394 + 8
        v407 = 120
    end;
    if l_core_game_0.Parent.loadout_menu.Visible == false then
        if l_LocalPlayer_0.PlayerGui:FindFirstChild("loadingdone") or (l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson or (_G.using_controller == true or l_ObjectValue_0.Value ~= nil)) then
            v_u_81.shift_locked = true
            if l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson and l_Character_0:FindFirstChild("execing") then
                l_CurrentCamera_0.CFrame = l_Character_0.Head.CFrame
            end;
        end;
        l_CurrentCamera_0.CameraType = Enum.CameraType.Custom
        l_CurrentCamera_0.CameraSubject = v_u_1
        l_CurrentCamera_0.FieldOfView = v_u_2:lerp(l_CurrentCamera_0.FieldOfView, v407 + v408, 0.1)
    else
        v_u_81.shift_locked = false
    end;
    v_u_1.WalkSpeed = v_u_81.base_speed + v_u_81.int_speed - v393 + v394 - (l_Character_0:FindFirstChild("execing") and 1000 or v291)
end)
v_u_81.internal_sound = game.ReplicatedStorage.sound_library.train_sounds.internal_sound:Clone()
v_u_81.internal_sound.Volume = 0
v_u_81.internal_sound.Parent = l_CurrentCamera_0
v_u_81.internal_sound:Play()
local v_u_487 = nil
local v_u_488 = nil
local v_u_493 = game:GetService("RunService").Heartbeat:Connect(function() --[[ Line: 6373 ]]
    --[[ Upvalues: (copy 1): v_u_1, (copy 2): v_u_6, (copy 3): v_u_25, (copy 4): v_u_2, (copy 5): v_u_47, (ref 6): v_u_488, (ref 7): v_u_237, (ref 8): v_u_487, (copy 9): v_u_81 ]]
    if v_u_1 == nil or (v_u_1.Health <= 0 or v_u_6 == nil) then
        return;
    elseif not v_u_25 or (v_u_25.Name == "train" or v_u_25.Name == "laststand") then
        local v489 = v_u_2:raycastline({
            ["point"] = v_u_6.Position,
            ["destination"] = -v_u_6.CFrame.upVector,
            ["range"] = 12,
            ["layermask"] = v_u_47
        })
        local v490 = 0
        if v_u_488 == nil and workspace.serverStuff:FindFirstChild("game_setup") then
            v_u_488 = workspace.serverStuff.game_setup:FindFirstChild("trains")
        end;
        if v489 and (v489.Parent and (v_u_488 ~= nil and v489:IsDescendantOf(v_u_488))) then
            v_u_237 = true
            v490 = v489.Name == "trainplatform" and 0.4 or v490
            local v491 = v489.Parent:FindFirstChild("center")
            if v491 == nil then
                v491 = v489.Parent.Parent:FindFirstChild("center")
            end;
            if v491 == nil then
                v491 = v489.Parent.Parent.Parent:FindFirstChild("center")
            end;
            if v491 == nil then
                v491 = v489.Parent.Parent.Parent.Parent:FindFirstChild("center")
            end;
            if v491 ~= nil then
                if v_u_487 == nil then
                    v_u_487 = v491.CFrame
                end;
                local v492 = v491.CFrame * v_u_487:inverse()
                v_u_487 = v491.CFrame
                v_u_6.CFrame = v492 * v_u_6.CFrame
            end;
        else
            v_u_237 = false
            v_u_487 = nil
        end;
        if v_u_81.internal_sound then
            v_u_81.internal_sound.Volume = v_u_2:lerp(v_u_81.internal_sound.Volume, v490, 0.1)
        end;
    end;
end)
l_remotes_0.equipment_handler.OnClientEvent:Connect(function(p494) --[[ Line: 6441 ]]
    --[[ Upvalues: (copy 1): v_u_81 ]]
    if p494 == "start_ticker" then
        v_u_81.equipment_show_cd = tick()
        v_u_81.equipment_ticker = tick()
    end;
end)
local function v_u_509() --[[ Line: 6448 ]]
    --[[ Upvalues: (copy 1): v_u_11, (copy 2): l_Character_0, (copy 3): v_u_81, (copy 4): l_BoolValue_0, (copy 5): v_u_1, (copy 6): v_u_9, (copy 7): v_u_10, (copy 8): l_LocalPlayer_0, (copy 9): l_values_0, (copy 10): l_RenderStepped_0, (ref 11): l_keysheld_0, (copy 12): v_u_2, (copy 13): v_u_6, (ref 14): v_u_145, (copy 15): v_u_71, (copy 16): l_CurrentCamera_0, (copy 17): v_u_47, (copy 18): l_remotes_0, (ref 19): v_u_82, (copy 20): v_u_8, (copy 21): v_u_4 ]]
    if v_u_11 == nil then
        return;
    end;
    if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
        return;
    end;
    if workspace.serverStuff.restorationmode.Value == true then
        return;
    end;
    v_u_81.equipment_show_cd = tick()
    if v_u_11.Value <= 0 then
        return;
    end;
    if l_BoolValue_0.Value == true then
        return;
    end;
    if v_u_1 == nil or v_u_1.Health <= 0 then
        return;
    end;
    if v_u_9 == nil then
        return;
    end;
    if v_u_10 == nil then
        return;
    end;
    if v_u_1:FindFirstChild("burning_heavy") then
        return;
    end;
    if workspace.serverStuff.trainingmode.Value == true and l_LocalPlayer_0.Character:FindFirstChild("equipmentenabled") == nil then
        return;
    end;
    if l_values_0.gamemode.Value == "infection" and (l_LocalPlayer_0.Team == game.Teams["Golden Empire"] and l_LocalPlayer_0:FindFirstChild("progenitor") == nil) then
        return;
    end;
    if v_u_9.Value == "soldat" or v_u_9.Value == "mortician" then
        l_RenderStepped_0:Wait()
        local v495 = tick()
        local v496 = false
        local v497 = false
        while true do
            if l_keysheld_0[_G.get_keybinds("equipment")] ~= true then
                v496 = true
                break;
            end;
            if l_BoolValue_0.Value == true then
                return;
            end;
            l_RenderStepped_0:Wait()
            if tick() - v495 >= 0.225 then
                break;
            end;
        end;
        if tick() - v495 >= 0.225 then
            v496 = false
            v497 = true
        end;
        if l_BoolValue_0.Value == true then
            return;
        else
            local l_friendly_target_0 = v_u_81.friendly_target
            if v496 == true and l_friendly_target_0 == nil then
                return;
            elseif v_u_9.Value == "mortician" and (l_friendly_target_0 and (l_friendly_target_0.Parent and (l_friendly_target_0.Parent:FindFirstChild("Humanoid") and l_friendly_target_0.Parent.Humanoid.Health >= 100))) then
                return;
            elseif v_u_9.Value ~= "soldat" or (not l_friendly_target_0 or (not l_friendly_target_0.Parent or (not l_friendly_target_0.Parent:FindFirstChild("full_ammo") or (l_friendly_target_0.Parent.full_ammo.Value ~= true or v496 ~= true)))) then
                if v496 == false or v497 == true then
                    l_friendly_target_0 = nil
                end;
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "generalpouch" .. math.random(1, 2),
                    ["location"] = v_u_6
                })
                v_u_71[v_u_145 and v_u_145:FindFirstChild("lefthanded") and "right_soldatammo" or (math.random(1, 2) == 1 and v_u_145 == nil and "right_soldatammo" or "left_soldatammo")]:Play(0.1, 1, 1)
                l_BoolValue_0.Value = true
                local v498 = v_u_11
                v498.Value = v498.Value - 1
                delay(0.1, function() --[[ Line: 6565 ]]
                    --[[ Upvalues: (ref 1): v_u_9, (ref 2): v_u_2, (ref 3): v_u_6, (ref 4): l_friendly_target_0, (ref 5): l_CurrentCamera_0, (ref 6): v_u_47, (ref 7): l_remotes_0 ]]
                    if v_u_9.Value == "soldat" then
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "ammo" .. math.random(1, 3),
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_6
                        })
                    elseif v_u_9.Value == "mortician" then
                        v_u_2:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "heal" .. math.random(1, 3),
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_6
                        })
                    end;
                    if v_u_9.Value == "mortician" and (l_friendly_target_0 and (l_friendly_target_0.Parent and (l_friendly_target_0.Parent:FindFirstChild("Humanoid") and l_friendly_target_0.Parent.Humanoid.Health >= 100))) then
                        l_friendly_target_0 = nil
                    end;
                    if v_u_9.Value == "soldat" and (l_friendly_target_0 and (l_friendly_target_0.Parent and (l_friendly_target_0.Parent:FindFirstChild("full_ammo") and l_friendly_target_0.Parent.full_ammo.Value == true))) then
                        l_friendly_target_0 = nil
                    end;
                    if l_friendly_target_0 == nil or (l_friendly_target_0.Parent == nil or (l_friendly_target_0.Parent:FindFirstChild("Humanoid") == nil or (l_friendly_target_0.Parent.Humanoid.Health <= 0 or (l_friendly_target_0.Parent:FindFirstChild("Torso") == nil or (l_friendly_target_0.Parent.Torso.Position - v_u_6.Position).magnitude > 20)))) then
                        local l_CFrame_1 = v_u_6.CFrame
                        local _, v499 = v_u_2:raycastline({
                            ["point"] = l_CFrame_1.Position,
                            ["destination"] = l_CurrentCamera_0.CFrame.LookVector,
                            ["range"] = 20,
                            ["layermask"] = v_u_47
                        })
                        local _, v500 = v_u_2:raycastline({
                            ["point"] = v499 - l_CurrentCamera_0.CFrame.LookVector,
                            ["destination"] = -CFrame.new().UpVector,
                            ["range"] = 1000,
                            ["layermask"] = v_u_47
                        })
                        l_remotes_0.equipment_handler:FireServer({
                            ["startpoint"] = l_CFrame_1,
                            ["endpoint"] = v500,
                            ["maxrange"] = 20,
                            ["addon"] = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, -0.1),
                            ["range"] = (l_CFrame_1.Position - v499).Magnitude
                        })
                    else
                        l_remotes_0.equipment_handler:FireServer({
                            ["startpoint"] = v_u_6.CFrame,
                            ["maxrange"] = 20,
                            ["target"] = l_friendly_target_0.Parent.Torso,
                            ["addon"] = CFrame.new(),
                            ["range"] = (v_u_6.Position - l_friendly_target_0.Parent.Torso.Position).magnitude
                        })
                    end;
                end)
                v_u_2:s_wait(0.7)
                l_BoolValue_0.Value = false
            end;
        end;
    end;
    if v_u_9.Value == "rook" or (v_u_9.Value == "officer" or (v_u_9.Value == "jaeger" or (v_u_9.Value == "vanguard" or v_u_9.Value == "conscript"))) then
        if l_Character_0:FindFirstChild("tools_loaded") == nil then
            return;
        end;
        if tick() - v_u_81.no_swap_ticker <= 0.5 then
            return;
        end;
        if tick() - v_u_82 >= 2 then
            return;
        end;
        if v_u_9.Value == "vanguard" and (v_u_145 and (v_u_145:FindFirstChild("weapon") and (v_u_145.weapon.Value == "vanguardshield" or v_u_145.weapon.Value == "lewis"))) then
            if l_Character_0:FindFirstChild("vanguardbuff_already") then
                _G.popupmsg("no_vanguardbudd", "My rally will not be effective at the moment.", 1)
            else
                l_BoolValue_0.Value = true
                local v501 = v_u_11
                v501.Value = v501.Value - 1
                delay(0.15, function() --[[ Line: 6676 ]]
                    --[[ Upvalues: (ref 1): v_u_2, (ref 2): v_u_6 ]]
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "shield_alert",
                        ["location"] = v_u_6
                    })
                end)
                l_remotes_0.equipment_handler:FireServer()
                v_u_71[v_u_145.weapon.Value == "lewis" and "lewisknock" or "shieldknock"]:Play(0.2, 1, 1)
                v_u_2:s_wait(1.2)
                l_BoolValue_0.Value = false
            end;
        end;
        if v_u_81.inv_swapping ~= true then
            if v_u_81.inv_block_reason ~= "" then
                _G.popupmsg("block_warning", v_u_81.inv_block_reason, 1)
            end;
            return;
        end;
        local v502 = l_LocalPlayer_0.Backpack:FindFirstChild("Mining Bomb Launcher")
        if v_u_9.Value == "officer" then
            v502 = l_LocalPlayer_0.Backpack:FindFirstChild("Trench Whistle")
        elseif v_u_9.Value == "jaeger" then
            v502 = l_LocalPlayer_0.Backpack:FindFirstChild("Smokescreen Bomb")
        elseif v_u_9.Value == "vanguard" then
            v502 = l_LocalPlayer_0.Backpack:FindFirstChild("Bulwark\'s Shield")
        elseif v_u_9.Value == "conscript" then
            v502 = l_LocalPlayer_0.Backpack:FindFirstChild("Conscript Lantern")
        end;
        if v502 and (v502:FindFirstChild("inactive") == nil and v502:FindFirstChild("client_inactive") == nil) then
            v_u_81.inventory_display = tick()
            v_u_1:UnequipTools()
            v_u_1:EquipTool(v502)
            return;
        end;
    elseif v_u_9.Value == "lancer" then
        if l_BoolValue_0.Value == true then
            return;
        end;
        if tick() - v_u_81.fall_damage_interrupt <= 0 then
            return;
        end;
        if l_Character_0:FindFirstChild("oathbroken") then
            _G.popupmsg("brokenoath", "I can\'t do this.", 1)
            return;
        end;
        local v503 = l_LocalPlayer_0.Backpack:FindFirstChild("Throwing Axe")
        if v503 and (v503:FindFirstChild("event") and v503:FindFirstChild("inactive") == nil) then
            l_BoolValue_0.Value = true
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "ready",
                ["location"] = l_Character_0.HumanoidRootPart
            })
            local v504 = v_u_8.Value == "marksman" and 0.1 or 0.25
            local l_left_axethrow_0 = v_u_71.left_axethrow
            local v505
            if v_u_145 and v_u_145:FindFirstChild("lefthanded") or math.random(1, 2) == 1 and v_u_145 == nil then
                l_left_axethrow_0 = v_u_71.right_axethrow
                v505 = "Right Arm"
            else
                v505 = "Left Arm"
            end;
            v_u_4("lancer_handaxe", {
                ["char"] = l_Character_0,
                ["handuse"] = v505
            })
            l_left_axethrow_0:Play(0.1, 1, 1 / v504)
            v_u_2:s_wait(v504)
            l_left_axethrow_0:AdjustSpeed(0)
            l_left_axethrow_0.TimePosition = 1
            local v506 = true
            local v507 = false
            while true do
                if v_u_1 == nil or v_u_1.Health <= 0 then
                    return;
                end;
                if tick() - v_u_81.fall_damage_interrupt <= 0 then
                    v506 = false
                    break;
                end;
                if l_keysheld_0.m1 and l_keysheld_0.m1 == true then
                    v506 = false
                    v507 = true
                    break;
                end;
                l_RenderStepped_0:Wait()
                if l_keysheld_0[_G.get_keybinds("equipment")] ~= true then
                    break;
                end;
            end;
            if v_u_1:FindFirstChild("burning_heavy") then
                v506 = false
            end;
            if v506 == true then
                l_left_axethrow_0:AdjustSpeed(1)
                v_u_2:s_wait(0.2)
                v503.event:Fire("throw_axe")
            end;
            v_u_4("lancer_handaxe", {
                ["char"] = l_Character_0
            })
            local v508 = 0.55
            if v506 == false and v507 == true then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "draw",
                    ["location"] = l_Character_0.HumanoidRootPart
                })
                l_left_axethrow_0:Stop(0.1)
                v_u_71[v505 == "Right Arm" and "right_axesheath" or "left_axesheath"]:Play(0.1, 1, 2)
                v508 = 0.3
            else
                l_left_axethrow_0:AdjustSpeed(1 / v508)
            end;
            v_u_2:s_wait(v508)
            l_BoolValue_0.Value = false
        end;
    end;
end;
_G.debugline = false
local v_u_510 = tick()
local v_u_511 = 0
local function v_u_515(p512) --[[ Line: 6847 ]]
    --[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_81, (copy 3): v_u_68, (copy 4): l_BoolValue_0, (copy 5): l_core_game_0, (copy 6): l_RenderStepped_0, (copy 7): l_LocalPlayer_0, (copy 8): v_u_1 ]]
    if l_Character_0:FindFirstChild("tools_loaded") == nil then
        return;
    end;
    if tick() - v_u_81.no_swap_ticker <= 0.5 then
        return;
    end;
    if v_u_81.inv_swapping ~= true then
        if v_u_81.inv_block_reason ~= "" then
            _G.popupmsg("block_warning", v_u_81.inv_block_reason, 1)
        end;
        break;
    end;
    local v513 = v_u_68[p512]
    if v513 == nil then
        return;
    end;
    if type(v513) == "string" then
        return;
    end;
    if not v513:IsA("Tool") then
        return;
    end;
    if v513 and (v513.Name == "empty" or (v513:FindFirstChild("inactive") or v513:FindFirstChild("client_inactive"))) then
        return;
    end;
    if v513 == nil then
        return;
    end;
    if l_BoolValue_0.Value == true then
        if v_u_81.queue_inv ~= nil then
            v_u_81.queue_inv = p512
            return;
        end;
        v_u_81.queue_inv = p512
        while true do
            for _, v514 in ipairs(l_core_game_0.inventory:GetChildren()) do
                if v514.Name ~= "ex" and (v514.Name ~= "UIListLayout" and v514.icon.ImageColor3 ~= Color3.new(1, 1, 1)) then
                    if v_u_68[v_u_81.queue_inv] and (v_u_68[v_u_81.queue_inv]:FindFirstChild("weapon") and v514.Name == v_u_68[v_u_81.queue_inv].weapon.Value .. v_u_68[v_u_81.queue_inv].slot.Value) then
                        v514.line.BackgroundColor3 = Color3.new(1, 1, 1)
                        v_u_81.inventory_display = tick()
                    else
                        v514.line.BackgroundColor3 = Color3.new(0, 0, 0)
                    end;
                end;
            end;
            l_RenderStepped_0:Wait()
            if l_BoolValue_0.Value == false then
                break;
            end;
        end;
    else
        -- ::l21:: (Possible bug with goto)
        if v_u_81.queue_inv ~= nil then
            v513 = v_u_68[v_u_81.queue_inv]
            if v513 and v513.Parent == l_Character_0 then
                v513 = nil
            end;
        end;
        v_u_81.queue_inv = nil
        if v513 then
            if v513.Parent == l_LocalPlayer_0.Backpack then
                v_u_1:UnequipTools()
                v_u_1:EquipTool(v513)
            else
                v_u_1:UnequipTools()
            end;
        end;
        -- ::l42:: (Possible bug with goto)
        return;
    end;
end;
local function v_u_521(p516) --[[ Line: 6929 ]]
    --[[ Upvalues: (ref 1): v_u_145, (copy 2): l_LocalPlayer_0, (copy 3): v_u_515 ]]
    local v517 = (not (v_u_145 and v_u_145:FindFirstChild("slot")) and 0 or v_u_145.slot.Value) + p516
    local v518 = false
    while true do
        for _, v519 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
            if v519:FindFirstChild("slot") and (v519:FindFirstChild("inactive") == nil and (v519.Name ~= "empty" and v519.slot.Value == v517)) then
                v517 = v519.slot.Value
                v518 = true
            end;
        end;
        if v518 == true then
            v_u_515((v517 >= 8 or v517 <= 0) and 1 or v517)
            return;
        end;
        local v520 = v517 + p516
        v517 = (v520 >= 8 or v520 <= 0) and (p516 < 0 and 7 or 1) or v520
    end;
end;
local v_u_522 = 0
local v_u_523 = {
    "help",
    "danger",
    "ammo",
    "healing",
    "thanks"
}
if v_u_9.Value == "officer" then
    table.insert(v_u_523, "officerfollow")
    table.insert(v_u_523, "officerorder")
    table.insert(v_u_523, "officerdefend")
end;
local function v_u_526() --[[ Line: 6986 ]]
    --[[ Upvalues: (copy 1): l_values_0, (copy 2): l_LocalPlayer_0, (copy 3): v_u_1, (copy 4): l_Character_0, (ref 5): v_u_244, (ref 6): v_u_511, (copy 7): l_remotes_0, (ref 8): v_u_510 ]]
    if workspace.serverStuff.trainingmode.Value == true then
        return;
    elseif l_values_0.teamlosing.Value == l_LocalPlayer_0.Team and (v_u_1 and (l_Character_0:FindFirstChild("surrendered") == nil and (v_u_1.Health > 0 and v_u_244 == false))) then
        if l_Character_0:FindFirstChild("dreadnought") or l_Character_0:FindFirstChild("elitekit") then
            _G.popupmsg("nosurrender", "Surrender is not an option, not for you.", 1)
            return;
        elseif v_u_1:FindFirstChild("burning_light") or v_u_1:FindFirstChild("burning_heavy") then
            _G.popupmsg("nosurrender", "I\'M BURNING RIGHT NOW!", 1)
            return;
        elseif tick() - v_u_511 <= 5 then
            v_u_244 = true
            l_remotes_0.game_handler:FireServer("surrender_manual")
        else
            v_u_511 = tick()
            _G.popupmsg("confirm_surrender", "Confirm Surrender? Press [" .. (_G.using_controller == true and "X while Un-Equipped" or _G.get_keybinds("swapteam").Name) .. "] again.", 1)
        end;
    else
        if tick() - v_u_511 <= 5 then
            if tick() - v_u_510 >= 1 then
                v_u_510 = tick()
                l_remotes_0.game_handler:FireServer("team_swap")
                return;
            end;
        else
            v_u_511 = tick()
            local v524 = _G.using_controller == true and "X while Un-Equipped" or _G.get_keybinds("swapteam").Name
            local v525 = "Confirm Defecting to opposing side? Press [" .. v524 .. "] again."
            if l_LocalPlayer_0:FindFirstChild("imbalance_reward_swap") then
                v525 = "Confirm Enlistment to opposing side? Press [" .. v524 .. "] again."
            end;
            _G.popupmsg("confirm_swap", v525, 1)
        end;
        return;
    end;
end;
s_UserInputService_0.InputBegan:Connect(function(p527, p528) --[[ Line: 7047 ]]
    --[[ Upvalues: (copy 1): l_LocalPlayer_0, (copy 2): v_u_1, (copy 3): l_Character_0, (copy 4): l_remotes_0, (copy 5): l_core_game_0, (copy 6): s_UserInputService_0, (ref 7): v_u_99, (copy 8): l_ObjectValue_0, (copy 9): l_RenderStepped_0, (ref 10): l_keysheld_0, (copy 11): v_u_81, (ref 12): v_u_74, (copy 13): v_u_2, (copy 14): v_u_6, (copy 15): v_u_523, (copy 16): v_u_278, (copy 17): v_u_509, (ref 18): v_u_145, (copy 19): v_u_526, (ref 20): v_u_144, (copy 21): l_BoolValue_0, (copy 22): v_u_71, (copy 23): v_u_4, (copy 24): v_u_9, (copy 25): l_selectionboxes_0, (copy 26): v_u_87, (copy 27): v_u_521, (copy 28): v_u_515, (ref 29): v_u_522, (copy 30): l_CurrentCamera_0 ]]
    if p528 == true and (p527.KeyCode == Enum.KeyCode.ButtonA or p527.KeyCode == Enum.KeyCode.ButtonR3) == false or l_LocalPlayer_0.PlayerGui:FindFirstChild("ready") then
        return;
    end;
    if v_u_1 == nil or v_u_1.Health <= 0 then
        return;
    end;
    if p527.KeyCode and (p527.KeyCode == _G.get_keybinds("reset") and l_Character_0:FindFirstChild("bodyshielded") == nil) then
        l_remotes_0.game_handler:FireServer("perish")
    end;
    if l_core_game_0.Parent.loadout_menu.Visible == true then
        return;
    end;
    if (p527.UserInputType == Enum.UserInputType.MouseButton2 or p527.KeyCode == Enum.KeyCode.ButtonL2) and (s_UserInputService_0.MouseBehavior == Enum.MouseBehavior.LockCenter and _G.get_settings("toggleads") == true) then
        v_u_99 = not v_u_99
    end;
    if p527.KeyCode then
        if l_Character_0:FindFirstChild("exec") then
            return;
        end;
        if l_Character_0:FindFirstChild("execing") then
            return;
        end;
        if p527.KeyCode == _G.get_keybinds("firstperson") then
            if l_core_game_0.Parent.loadout_menu.Visible == true then
                return;
            end;
            if workspace.serverStuff.forcefirstperson.Value == true then
                return;
            end;
            if l_ObjectValue_0.Value ~= nil then
                return;
            end;
            if l_Character_0:FindFirstChild("dreadnought") then
                return;
            end;
            if _G.using_controller == true then
                local v529 = tick()
                repeat
                    l_RenderStepped_0:Wait()
                until tick() - v529 >= 0.5 or l_keysheld_0[_G.get_keybinds("firstperson")] == nil;
                if tick() - v529 < 0.5 then
                    v_u_81.flip_cam = not v_u_81.flip_cam
                    return;
                end;
            end;
            if (v_u_81.mosin_scope == nil or (v_u_81.mosin_scope.Parent ~= workspace.CurrentCamera or l_LocalPlayer_0.CameraMode ~= Enum.CameraMode.LockFirstPerson)) == true then
                if l_LocalPlayer_0.CameraMode == Enum.CameraMode.Classic then
                    l_LocalPlayer_0.CameraMode = Enum.CameraMode.LockFirstPerson
                else
                    l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
                end;
            end;
        end;
        if p527.KeyCode == _G.get_keybinds("crouch") then
            if v_u_74 then
                return;
            end;
            if tick() - v_u_81.crouching_cd >= 0.2 and tick() - v_u_81.fall_damage_interrupt > 0 then
                v_u_81.crouching_cd = tick()
                v_u_81.crouching = not v_u_81.crouching
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "crouch" .. math.random(1, 4),
                    ["location"] = v_u_6
                }, true)
            end;
        end;
        for _, v530 in ipairs(v_u_523) do
            if _G.get_keybinds("vc" .. v530) and (p527.KeyCode == _G.get_keybinds("vc" .. v530) and p527.UserInputType == Enum.UserInputType.Keyboard) then
                v_u_278(v530)
            end;
        end;
        if p527.KeyCode == _G.get_keybinds("equipment") then
            v_u_509()
        end;
        if p527.KeyCode == _G.get_keybinds("swapteam") or p527.KeyCode == Enum.KeyCode.ButtonX and (v_u_145 == nil and l_core_game_0.selectionboxes.Visible == false) then
            v_u_526()
        end;
        if p527.KeyCode == _G.get_keybinds("viewobj") then
            if workspace.serverStuff.trainingmode.Value == true and l_Character_0:FindFirstChild("compass_active") == nil then
                return;
            end;
            v_u_144 = tick()
            if l_BoolValue_0.Value == false and (v_u_81.aiming == false and (workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_compass") == nil and (v_u_71.compass_right.isPlaying == false and v_u_71.compass_left.isPlaying == false))) then
                local l_Left Arm_0 = l_Character_0["Left Arm"]
                local v_u_531
                if v_u_145 and v_u_145:FindFirstChild("lefthanded") then
                    l_Left Arm_0 = l_Character_0["Right Arm"]
                    v_u_531 = "compass_right"
                else
                    v_u_531 = "compass_left"
                end;
                v_u_71[v_u_531]:Play(0.2, 1, 1)
                spawn(function() --[[ Line: 7192 ]]
                    --[[ Upvalues: (ref 1): v_u_2, (ref 2): v_u_6, (ref 3): v_u_1, (ref 4): l_Character_0, (ref 5): v_u_4, (ref 6): l_Left Arm_0, (ref 7): l_LocalPlayer_0, (ref 8): l_RenderStepped_0, (ref 9): v_u_71, (ref 10): v_u_531, (ref 11): l_BoolValue_0, (ref 12): v_u_81, (ref 13): l_keysheld_0 ]]
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "compass_open",
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_6
                    })
                    delay(0.1, function() --[[ Line: 7201 ]]
                        --[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0, (ref 3): v_u_4, (ref 4): l_Left Arm_0, (ref 5): l_LocalPlayer_0 ]]
                        if v_u_1 and (l_Character_0 and v_u_1.Health > 0) then
                            v_u_4("create_compass", {
                                ["char"] = l_Character_0,
                                ["part"] = l_Left Arm_0,
                                ["team"] = l_LocalPlayer_0.Team
                            })
                        end;
                    end)
                    local v532 = tick()
                    repeat
                        l_RenderStepped_0:Wait()
                    until tick() - v532 >= 0.5;
                    v_u_71[v_u_531]:AdjustSpeed(0)
                    v_u_71[v_u_531].TimePosition = 0.5
                    while l_BoolValue_0.Value ~= true and (v_u_81.aiming ~= true and workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_compass") ~= nil) do
                        l_RenderStepped_0:Wait()
                        if l_keysheld_0[_G.get_keybinds("viewobj")] ~= true then
                            break;
                        end;
                    end;
                    delay(0.3, function() --[[ Line: 7223 ]]
                        --[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0, (ref 3): v_u_2, (ref 4): v_u_6, (ref 5): v_u_4 ]]
                        if v_u_1 and (l_Character_0 and v_u_1.Health > 0) then
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "compass_close",
                                ["pitchvariation"] = 0.1,
                                ["location"] = v_u_6
                            })
                            v_u_4("destroy_compasses", {
                                ["char"] = l_Character_0
                            })
                        end;
                    end)
                    v_u_71[v_u_531]:AdjustSpeed(1)
                end)
            end;
        end;
        if p527.KeyCode == Enum.KeyCode.ButtonY and v_u_145 == nil then
            v_u_81.selection_box_selected = ""
            v_u_81.display_selections(v_u_9.Value == "officer" and {
                "thanks",
                "healing",
                "ammo",
                "danger",
                "help",
                "officerfollow",
                "officerorder",
                "officerdefend"
            } or {
                "thanks",
                "healing",
                "ammo",
                "danger",
                "help"
            })
            repeat
                l_RenderStepped_0:wait()
            until v_u_81.selection_box_selected ~= "" or v_u_81.queue_inv ~= nil;
            if v_u_81.queue_inv ~= nil then
                v_u_81.selection_box_selected = "none"
            end;
            if v_u_81.selection_box_selected ~= "none" then
                v_u_278(v_u_81.selection_box_selected)
            end;
            l_core_game_0.selectionboxes.Visible = false
            v_u_81.selection_box_selected = ""
        end;
        if p527.KeyCode == Enum.KeyCode.DPadLeft or p527.KeyCode == Enum.KeyCode.DPadRight then
            if l_Character_0:FindFirstChild("dreadnought") then
                return;
            end;
            local v533 = p527.KeyCode == Enum.KeyCode.DPadLeft and -1 or 1
            if l_selectionboxes_0.Visible == true then
                local v534 = 1
                for _, v535 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
                    if v535:IsA("ImageButton") and (v535.Visible == true and (v535:FindFirstChild("highlighted") and (v535:FindFirstChild("num") and (v535:FindFirstChild("internal") and v535.highlighted.Visible == true)))) then
                        v534 = v535.num.Text
                        break;
                    end;
                end;
                local v536 = tonumber(v534) + v533
                for _, v537 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
                    if v537:IsA("ImageButton") and (v537.Visible == true and (v537:FindFirstChild("highlighted") and (v537:FindFirstChild("num") and (v537:FindFirstChild("internal") and v537.num.Text == tostring(v536))))) then
                        v_u_87(v537)
                        break;
                    end;
                end;
            else
                v_u_521(v533)
            end;
        end;
        if p527.KeyCode == Enum.KeyCode.DPadDown or p527.KeyCode == Enum.KeyCode.ButtonA then
            if l_selectionboxes_0.Visible == true then
                for _, v538 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
                    if v538:IsA("ImageButton") and (v538.Visible == true and (v538:FindFirstChild("highlighted") and (v538:FindFirstChild("num") and (v538:FindFirstChild("internal") and v538.highlighted.Visible == true)))) then
                        l_selectionboxes_0.selectedoption.Text = ""
                        v_u_81.selection_box_selected = v538.internal.Value
                        break;
                    end;
                end;
            elseif v_u_81.inv_swapping == true and (l_BoolValue_0.Value == false and p527.KeyCode == Enum.KeyCode.DPadDown) then
                v_u_1:UnequipTools()
            end;
        end;
        if p527.KeyCode.Value >= 49 and p527.KeyCode.Value < 57 then
            if l_Character_0:FindFirstChild("dreadnought") then
                return;
            end;
            local v539 = false
            if l_selectionboxes_0.Visible == true then
                for _, v540 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
                    if v540:IsA("ImageButton") and (v540.Visible == true and (v540:FindFirstChild("num") and (v540:FindFirstChild("internal") and v540.num.Text == tostring(p527.KeyCode.Value - 48)))) then
                        l_selectionboxes_0.selectedoption.Text = ""
                        v_u_81.selection_box_selected = v540.internal.Value
                        v539 = true
                    end;
                end;
            end;
            if v539 == false then
                v_u_515(p527.KeyCode.Value - 48)
            end;
        end;
        if p527.KeyCode == _G.get_keybinds("hidehud") then
            if workspace.serverStuff.trainingmode.Value == true then
                return;
            end;
            if l_core_game_0.Parent.loadout_menu.Visible == false then
                l_core_game_0.Visible = not l_core_game_0.Visible
            end;
        end;
        if p527.KeyCode == _G.get_keybinds("flipcam") then
            v_u_81.flip_cam = not v_u_81.flip_cam
        end;
        if p527.KeyCode == _G.get_keybinds("shiftlock") then
            v_u_81.shift_locked = not v_u_81.shift_locked
        end;
        if p527.KeyCode == Enum.KeyCode.H and game:GetService("RunService"):IsStudio() then
            l_remotes_0.game_handler:FireServer("damageself")
        end;
        if (p527.KeyCode == _G.get_keybinds("cleanface") or p527.KeyCode == Enum.KeyCode.ButtonY and v_u_145 == nil) and (l_BoolValue_0.Value == false and (tick() - v_u_522 >= 2 and l_core_game_0.splatters:FindFirstChild("splat"))) then
            v_u_522 = tick()
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "unequip",
                ["location"] = l_CurrentCamera_0
            }, true)
            local v_u_541 = v_u_145 and v_u_145:FindFirstChild("lefthanded") and "facewipe_right" or "facewipe_left"
            v_u_71[v_u_541]:Play(0.1, 1, 1.5)
            delay(0.3, function() --[[ Line: 7408 ]]
                --[[ Upvalues: (ref 1): v_u_1, (ref 2): v_u_2, (ref 3): l_CurrentCamera_0, (ref 4): v_u_4, (ref 5): l_Character_0, (ref 6): l_core_game_0, (ref 7): v_u_541 ]]
                if v_u_1 ~= nil and v_u_1.Health > 0 then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "unready" .. math.random(1, 4),
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_4("clear_face", {
                        ["face"] = l_Character_0.Head
                    })
                    for _, v542 in ipairs(l_core_game_0.splatters:GetChildren()) do
                        if v542.Name == "splat" then
                            v542.Name = v_u_541
                        end;
                    end;
                end;
            end)
        end;
        if p527.KeyCode == Enum.KeyCode.J and game:GetService("RunService"):IsStudio() then
            _G.debugline = not _G.debugline
        end;
    end;
end)
local v_u_543 = {
    "It wasn\'t your fault.",
    "You will be remembered.",
    "You will be missed.",
    "You\'re the good guys.",
    "Remember them.",
    "We\'re waiting for you.",
    "Don\'t give up.",
    "You are a hero.",
    "A hero has to make sacrifices.",
    "You did what you had to do.",
    "We all honour you.",
    "Don\'t forget about them.",
    "Your glory will be remembered.",
    "History will talk greatly of you.",
    "What\'s done is done.",
    "You did your best.",
    "You fought for the right reasons.",
    "Don\'t look back.",
    "You have nothing to regret.",
    "Your life had meaning.",
    "Everything will be alright.",
    "You\'ll be reunited with them soon.",
    "You did a good job.",
    "Don\'t cry, it\'s almost over.",
    "You\'re heading to a better place.",
    "Keep fighting, it\'s not over yet.",
    "A better future awaits you.",
    "Don\'t think, just act.",
    "Your allies depend on you."
}
local v_u_544 = {
    "You are an example to your comrades behind you.",
    "You have contributed to a better future.",
    "There is a place reserved for heroes like you.",
    "You are a beacon of hope to your people.",
    "You give meaning to those that follow you.",
    "Books will be written about people like you.",
    "Your country is proud of you.",
    "Your actions today will be remembered forever.",
    "No-one will doubt your heroism.",
    "Tales will be told about your bravery."
}
local function v_u_546(p545) --[[ Line: 7482 ]]
    --[[ Upvalues: (copy 1): v_u_8, (ref 2): v_u_101, (copy 3): v_u_2, (copy 4): l_CurrentCamera_0 ]]
    if v_u_8.Value ~= "leather" then
        if tick() - v_u_101 >= 5.25 and p545 >= 70 then
            v_u_101 = tick()
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "earring",
                ["location"] = l_CurrentCamera_0
            }, true)
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "helmet_hit",
                ["location"] = l_CurrentCamera_0
            }, true)
        end;
    end;
end;
_G.knockback_effect = function(p547, p548) --[[ Line: 7501 ]]
    --[[ Upvalues: (copy 1): v_u_81, (copy 2): l_Character_0, (copy 3): v_u_8, (ref 4): v_u_145, (copy 5): v_u_3, (copy 6): v_u_6, (copy 7): s_Debris_0 ]]
    if v_u_81.charging == true then
        return;
    elseif l_Character_0:FindFirstChild("dreadnought") then
        return;
    elseif v_u_8.Value == "leather" then
        return;
    elseif l_Character_0:FindFirstChild("buff_defend") or l_Character_0:FindFirstChild("buff_elite") then
        return;
    elseif v_u_81.in_air == true then
        return;
    elseif v_u_145 and v_u_145:FindFirstChild("mounted_weapon") then
        return;
    elseif not v_u_145 or (not v_u_145:FindFirstChild("bipod") or tick() - v_u_145.bipod.Value > v_u_3.bulwark_buffer) then
        if v_u_6:FindFirstChild("knockBackBP") == nil then
            local l_BodyPosition_2 = Instance.new("BodyPosition")
            s_Debris_0:AddItem(l_BodyPosition_2, 0.1)
            l_BodyPosition_2.Name = "knockBackBP"
            l_BodyPosition_2.P = p547
            l_BodyPosition_2.D = 15
            l_BodyPosition_2.MaxForce = Vector3.new(inf, inf, inf)
            l_BodyPosition_2.Position = p548
            l_BodyPosition_2.Parent = v_u_6
        end;
    end;
end;
local v_u_549 = 0
local v_u_550 = 0
v_u_81.remove_tool = function(p551, p552, p553) --[[ Line: 7539 ]]
    --[[ Upvalues: (copy 1): v_u_71, (copy 2): v_u_2, (copy 3): v_u_6, (copy 4): v_u_68, (copy 5): l_core_game_0 ]]
    if p553 then
        if p553 == 1 then
            v_u_71.drop_pistol:Play(0.01, 1, 2)
        else
            v_u_71.drop_rifle:Play(0.01, 1, 2)
        end;
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "throw",
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_6
        })
        v_u_2:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "weapon_rattle" .. math.random(1, 3),
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_6
        })
    else
        local v554 = p551 and (p552 and (v_u_68[p551] and (tostring((typeof(v_u_68[p551]))) ~= "string" and v_u_68[p551]:FindFirstChild("weapon")))) and (p552 ~= "empty" and l_core_game_0.inventory:FindFirstChild(p552 .. p551))
        if v554 then
            v_u_68[p551] = "empty"
            v554.Name = "empty" .. p551
            v554.icon.Image = "rbxassetid://17768266447"
        end;
    end;
end;
local v_u_555 = 0
local v_u_602 = l_remotes_0.game_handler.OnClientEvent:Connect(function(p556, p_u_557, p558) --[[ Line: 7582 ]]
    --[[ Upvalues: (copy 1): v_u_67, (copy 2): v_u_68, (copy 3): v_u_81, (copy 4): l_RenderStepped_0, (copy 5): v_u_6, (copy 6): v_u_2, (copy 7): l_CurrentCamera_0, (copy 8): l_core_game_0, (copy 9): v_u_204, (copy 10): l_LocalPlayer_0, (copy 11): l_Character_0, (copy 12): v_u_71, (ref 13): v_u_31, (copy 14): l_remotes_0, (ref 15): v_u_555, (copy 16): v_u_9, (copy 17): v_u_8, (copy 18): v_u_1, (ref 19): v_u_145, (copy 20): l_ObjectValue_0, (copy 21): l_BoolValue_0, (copy 22): v_u_7, (copy 23): v_u_3, (copy 24): v_u_114, (ref 25): v_u_550, (ref 26): v_u_242, (copy 27): v_u_235, (copy 28): v_u_112, (copy 29): v_u_4, (copy 30): s_Debris_0, (ref 31): v_u_119, (copy 32): v_u_130, (copy 33): v_u_546, (ref 34): v_u_248, (copy 35): v_u_12, (ref 36): v_u_549 ]]
    if p556 == "add_tool" then
        if p_u_557 and (p_u_557:FindFirstChild("weapon") and p_u_557:FindFirstChild("slot")) then
            v_u_67(p_u_557)
            v_u_68[p_u_557.slot.Value] = p_u_557
            return;
        end;
    elseif p556 == "remove_tool" then
        if p_u_557 and p558 then
            v_u_81.remove_tool(p_u_557, p558)
            return;
        end;
    elseif p556 == "npcheadturn" then
        if p_u_557 and (p_u_557:FindFirstChild("Head") and p_u_557:FindFirstChild("HumanoidRootPart")) then
            local l_C0_0 = p_u_557.Torso:FindFirstChild("Neck").C0
            spawn(function() --[[ Line: 7608 ]]
                --[[ Upvalues: (ref 1): l_RenderStepped_0, (copy 2): p_u_557, (ref 3): v_u_6, (copy 4): l_C0_0 ]]
                while l_RenderStepped_0:Wait() do
                    if p_u_557 == nil or (not p_u_557:IsA("Model") or p_u_557:FindFirstChild("Head") == nil) then
                        return;
                    end;
                    p_u_557.Torso.Neck.C0 = l_C0_0 * CFrame.Angles(0, 0, (p_u_557.Head.Position - v_u_6.Position).Unit:Cross(p_u_557.Torso.CFrame.LookVector).Y + p_u_557.HumanoidRootPart.RootJoint.CurrentAngle)
                    if p_u_557:FindFirstChild("stoptracking") then
                        p_u_557.Torso.Neck.C0 = l_C0_0
                        return;
                    end;
                end;
            end)
            return;
        end;
    else
        if p556 == "tutorialchange" then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "popup",
                ["location"] = l_CurrentCamera_0
            }, true)
            local v559
            if _G.using_controller == true then
                v559 = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(p_u_557, "@PICK", "DPAD"), "@COMPASS", "DPAD UP"), "@RIFLE", "DPAD"), "@AID", "DPAD"), "@AIM", "LT"), "@FIRE", "RT")
            else
                v559 = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(p_u_557, "@PICK", "4"), "@AID", "5"), "@COMPASS", "X"), "@RIFLE", "1"), "@AIM", "MOUSE 2"), "@FIRE", "MOUSE 1")
            end;
            l_core_game_0.tutorialobj.tuttext.Text = string.gsub(string.gsub(v559, "@EQUIP", string.upper(_G.get_keybinds("equipment").Name)), "@RELOAD", string.upper(_G.get_keybinds("reload").Name))
            return;
        end;
        if p556 == "add_tutorialcontrol" then
            if p_u_557 ~= "unequip" or _G.using_controller == true then
                v_u_204(p_u_557, p558)
            end;
        end;
        if p556 == "tutorial_nightmare" then
            local v560 = game.ReplicatedStorage.sound_library.tutorial.warsounds:Clone()
            v560.Parent = l_CurrentCamera_0
            v560:Play()
            game.ReplicatedStorage.misc.vignette:Clone().Parent = l_core_game_0
            for _, v561 in ipairs(l_core_game_0.customchat:GetChildren()) do
                if v561.Name ~= "msg" and v561.Name ~= "UIListLayout" then
                    v561:Destroy()
                end;
            end;
            return;
        end;
        if p556 == "tutorial_nightmare_continue" then
            if l_CurrentCamera_0:FindFirstChild("warsounds") then
                l_CurrentCamera_0.warsounds.Volume = 1
            end;
            if l_core_game_0:FindFirstChild("tutfakeout") then
                l_core_game_0.tutfakeout:Destroy()
            end;
            game.ReplicatedStorage.misc.vignette:Clone().Parent = l_core_game_0
            for _, v562 in ipairs(l_core_game_0.customchat:GetChildren()) do
                if v562.Name ~= "msg" and v562.Name ~= "UIListLayout" then
                    v562:Destroy()
                end;
            end;
            return;
        end;
        if p556 == "tutorial_nightmare_end" then
            if l_CurrentCamera_0:FindFirstChild("warsounds") then
                l_CurrentCamera_0.warsounds.Volume = 0
            end;
            if l_core_game_0:FindFirstChild("vignette") then
                l_core_game_0.vignette:Destroy()
                return;
            end;
        else
            if p556 == "tutorial_textoverlay" then
                if not l_core_game_0.Parent:FindFirstChild("tutfakeout") then
                    if workspace:FindFirstChild("music") then
                        workspace.music:Destroy()
                    end;
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "ad_objective_lost",
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    local v_u_563 = game.ReplicatedStorage.misc.tutfakeout:Clone()
                    v_u_563.Parent = l_core_game_0.Parent
                    delay(2, function() --[[ Line: 7746 ]]
                        --[[ Upvalues: (copy 1): v_u_563, (ref 2): v_u_2, (ref 3): l_CurrentCamera_0 ]]
                        v_u_563.middletext.Text = ""
                        for v564 = 1, 29 do
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "dialogue",
                                ["location"] = l_CurrentCamera_0
                            }, true)
                            v_u_563.middletext.Text = string.sub("When will the nightmares end?", 1, v564)
                            v_u_2:s_wait(0.05)
                        end;
                        v_u_563.middletext.Text = "When will the nightmares end?"
                    end)
                end;
            end;
            if p556 == "tutorialwarp" or (p556 == "tutorial_warpmining" or p556 == "tutorial_traingate") then
                if p556 == "tutorial_warpmining" then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "hatch",
                        ["location"] = v_u_6
                    }, true)
                elseif p556 == "tutorial_traingate" then
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "traindoor",
                        ["location"] = v_u_6
                    }, true)
                end;
                l_core_game_0.fadetoblack.BackgroundTransparency = 0
                _G.fadetoblack = tick() + 0.5
                for _ = 1, 2 do
                    if p_u_557 and (l_LocalPlayer_0.Character and (l_LocalPlayer_0.Character:FindFirstChild("HumanoidRootPart") and (l_LocalPlayer_0.Character:FindFirstChild("Humanoid") and l_LocalPlayer_0.Character.Humanoid.Health > 0))) then
                        l_LocalPlayer_0.Character.HumanoidRootPart.CFrame = p_u_557.CFrame
                    end;
                    l_CurrentCamera_0.CFrame = CFrame.new(l_CurrentCamera_0.CFrame.Position, p_u_557.Position + p_u_557.CFrame.lookVector * 100)
                    l_RenderStepped_0:Wait()
                end;
                return;
            end;
            if p556 == "tutorial_getgear" then
                v_u_2:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "gear",
                    ["location"] = l_Character_0.HumanoidRootPart
                }, true)
                v_u_71.restock_weapons:Play(0.1, 1, 1)
                return;
            end;
            if p556 == "jaegermarkremoval" then
                if p_u_557 then
                    task.spawn(function() --[[ Line: 7809 ]]
                        --[[ Upvalues: (copy 1): p_u_557, (ref 2): v_u_31, (ref 3): l_remotes_0, (ref 4): l_LocalPlayer_0 ]]
                        while p_u_557 ~= nil and (p_u_557.Parent ~= nil and (p_u_557:FindFirstChild("Humanoid") and p_u_557.Humanoid.Health > 0)) do
                            task.wait()
                        end;
                        v_u_31 = true
                        l_remotes_0.game_handler:FireServer("jaegerlost", l_LocalPlayer_0)
                    end)
                end;
            end;
            if p556 == "jaegermarked" then
                if tick() - v_u_555 >= 6 then
                    v_u_555 = tick()
                    local v565 = 1.5
                    local v566 = {
                        "A chill is running up my spine..",
                        "It\'s cold all of the sudden..",
                        "I don\'t feel safe here..",
                        "I don\'t feel normal..",
                        "My fingers are getting cold..",
                        "I can\'t stop shaking..",
                        "I feel like a prey..",
                        "Something is hiding in the shadows.."
                    }
                    local v567 = {
                        "I\'m being hunted..",
                        "I\'m being tracked..",
                        "Someone is tracking me..",
                        "I feel like someone is watching me..",
                        "I feel like I\'m being watched..",
                        "I feel like I\'m being followed..",
                        "I feel like someone sees me.."
                    }
                    local v568 = {
                        "It\'s cold.",
                        "It\'s not safe here.",
                        "There\'s something in the shadows.",
                        "Something is wrong."
                    }
                    local v569 = {
                        "It\'s tracking me again.",
                        "It\'s following me again.",
                        "It\'s back for me.",
                        "It\'s back."
                    }
                    local v570 = {
                        "Someone is watching me.",
                        "I\'m being watched right now.",
                        "I\'m being tracked.",
                        "Someone is following my steps."
                    }
                    local v571 = {
                        "My sins are catching up with me..",
                        "It can sense my fear..",
                        "I can\'t hide anymore..",
                        "Help me, please.."
                    }
                    local v572 = { "The walls are shaking subtly..", "I feel strange vibrations in the walls..", "There\'s a strange presence in the tunnels.." }
                    local v573 = { "The tunnels aren\'t safe..", "There\'s someone mining around me..", "There\'s someone else in the walls.." }
                    local v574 = {
                        "My hand is quivering.",
                        "My grip tightens.",
                        "My heartbeat quickens.",
                        "My fingers are twitching."
                    }
                    local v_u_575 = {
                        "Someone is hiding.",
                        "Someone is around.",
                        "Someone is watching.",
                        "Someone is following."
                    }
                    local v576 = {
                        "..It\'s unusually quiet..",
                        "..Something\'s wrong..",
                        "..",
                        "..It\'s strangely cold..",
                        "..Something\'s not right."
                    }
                    local v577 = {
                        "..Something else is in the shadows.",
                        "..I\'m not alone in the dark.",
                        "..I\'m exposed.",
                        "..There\'s something in the darkness.",
                        "..I\'m not hidden."
                    }
                    local v578 = false
                    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
                        v_u_575 = v567
                        v574 = {
                            "Another Hunter is watching.",
                            "Another Hunter thinks of me as prey.",
                            "A Hunter is watching me.",
                            "A Hunter sees me."
                        }
                    elseif v_u_9.Value == "jaeger" or v_u_8.Value == "tracker" then
                        v_u_575 = v567
                        v574 = v570
                    elseif v_u_8.Value == "cursed" then
                        v_u_575 = v567
                        v574 = v571
                    else
                        v578 = true
                        if v_u_8.Value == "vet" then
                            v_u_575 = v569
                            v574 = v568
                        elseif v_u_8.Value == "tunnelrat" then
                            v_u_575 = v573
                            v574 = v572
                        elseif v_u_8.Value == "ghost" then
                            v_u_575 = v577
                            v574 = v576
                            v565 = 2.2
                        elseif v_u_8.Value == "butcher" then
                            v565 = 0.75
                        else
                            v_u_575 = v567
                            v574 = v566
                        end;
                    end;
                    local l_BoolValue_1 = Instance.new("BoolValue")
                    l_BoolValue_1.Name = "geist_hunted"
                    l_BoolValue_1.Parent = l_Character_0
                    _G.popupmsg("huntermessage", v574[math.random(1, #v574)], 3)
                    if v578 == true then
                        delay(v565, function() --[[ Line: 7885 ]]
                            --[[ Upvalues: (ref 1): l_Character_0, (ref 2): v_u_1, (ref 3): v_u_575 ]]
                            if l_Character_0 and (v_u_1 and v_u_1.Health > 0) then
                                _G.popupmsg("huntermessage2", v_u_575[math.random(1, #v_u_575)], 3)
                            end;
                        end)
                    end;
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "whisper" .. math.random(1, 4),
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    return;
                end;
            else
                if p556 == "jaegerlost" then
                    local v579 = {
                        "I feel relieved..",
                        "It\'s warm again..",
                        "I feel safe, for now..",
                        "I think it\'s gone..",
                        "I stopped shaking..",
                        "I feel normal again.."
                    }
                    local v580, v581, v582, v583, v584, v585, v_u_586, v587
                    if v_u_31 then
                        v_u_31 = false
                        v580 = { "..The dead silence returns.", "..I can hide in silence again.", "..The shadows are a lot safer now." }
                        v581 = { "It expired.", "It fades.", "It succumbs." }
                        v582 = { "The walls feel a lot safer now..", "The tunnels are free again..", "The strange presence has disappeared for good.." }
                        v583 = { "Seems like it failed.", "It lost.", "It will never track again." }
                        v584 = { "They\'re gone, but the nightmares are still here.." }
                        v585 = { "They\'ve died.", "They\'ve failed.", "They\'ve lost." }
                        v_u_586 = { "I win." }
                        v587 = { "The Hunter has perished.", "The Hunter loses.", "The Hunter became the prey." }
                    else
                        v580 = {
                            "..The dead silence is gone.",
                            "..I\'m hidden again.",
                            "..The shadows are safe now.",
                            "..I\'m no longer exposed."
                        }
                        v581 = { "It ran off.", "It fled.", "It escaped." }
                        v582 = { "The walls feel safer..", "The tunnels feel safe again..", "The strange presence is gone.." }
                        v583 = {
                            "Seems like it can\'t finish the job.",
                            "It\'s the one fleeing now.",
                            "It stopped tracking me.",
                            "It\'s safe again."
                        }
                        v584 = {
                            "I can finally breathe..",
                            "It\'s okay, it\'s going to be okay..",
                            "My heart is settling down..",
                            "The nightmare is over for now.."
                        }
                        v585 = { "I\'m no longer being hunted.", "I\'m not being watched anymore.", "They\'ve stopped following me." }
                        v_u_586 = { "Amateur.", "Coward.", "Fool." }
                        v587 = {
                            "The Hunter has lost my trail.",
                            "The Hunter has abandoned the chase.",
                            "The Hunter has lost track of me.",
                            "The Hunter has stopped pursuing me."
                        }
                    end;
                    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
                        v580 = v587
                    elseif v_u_9.Value == "jaeger" then
                        v580 = v585
                    elseif v_u_8.Value == "tracker" or v_u_8.Value == "cursed" then
                        v580 = v584
                    elseif v_u_8.Value == "vet" then
                        v580 = v583
                    elseif v_u_8.Value == "tunnelrat" then
                        v580 = v582
                    elseif v_u_8.Value == "butcher" then
                        v580 = v581
                    elseif v_u_8.Value ~= "ghost" then
                        v580 = v579
                    end;
                    if l_Character_0:FindFirstChild("geist_hunted") then
                        l_Character_0.geist_hunted:Destroy()
                    end;
                    _G.popupmsg("hunterlost", v580[math.random(1, #v580)], 3)
                    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
                        delay(1.5, function() --[[ Line: 7978 ]]
                            --[[ Upvalues: (ref 1): l_Character_0, (ref 2): v_u_1, (ref 3): v_u_586 ]]
                            if l_Character_0 and (v_u_1 and v_u_1.Health > 0) then
                                _G.popupmsg("hunterlost2", v_u_586[math.random(1, #v_u_586)], 3)
                            end;
                        end)
                    end;
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "whisper" .. math.random(1, 4),
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    return;
                end;
                if p556 == "jaegerswitch" then
                    local v588 = {
                        "I feel weird, but safer..",
                        "I feel uneasy, but it\'s not gone..",
                        "I feel safer, but it\'s still here..",
                        "It\'s warm again, but I feel in danger.."
                    }
                    local v589 = { "Looks like I\'m not the target anymore.", "Seems like it found someone else.", "It appears there\'s someone more important." }
                    local v590 = { "It\'s going after someone else.", "It found a better prey.", "It has found a better target." }
                    local v591 = {
                        "No, not again..",
                        "Why, why won\'t it just take me..",
                        "Am I going to let my sins repeat themselves..?",
                        "I\'m sorry, I can\'t do anything.."
                    }
                    local v592 = { "The vibrations weakened, but it\'s still here..", "The cave feel safer, but it\'s not gone..", "The temperature shifted, but it\'s still cold.." }
                    local v593 = { "It ran, but not far.", "It escaped, but not for long.", "It moved, but it\'s still here." }
                    local v594 = {
                        "..The shadows moved, it\'s going after someone else.",
                        "..The dark dissipates, it\'s tracking someone else.",
                        "",
                        "..The silence shifts, it\'s going after someone else."
                    }
                    if l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" then
                        v594 = {
                            "The Hunter is moving on to my ally.",
                            "The Hunter is hunting my ally instead.",
                            "The Hunter is tracking my ally.",
                            "The Hunter thinks I\'m not worth pursuing."
                        }
                    elseif v_u_9.Value == "jaeger" or v_u_8.Value == "tracker" then
                        v594 = v590
                    elseif v_u_8.Value == "cursed" then
                        v594 = v591
                    elseif v_u_8.Value == "vet" then
                        v594 = v589
                    elseif v_u_8.Value == "tunnelrat" then
                        v594 = v592
                    elseif v_u_8.Value == "butcher" then
                        v594 = v593
                    elseif v_u_8.Value ~= "ghost" then
                        v594 = v588
                    end;
                    if l_Character_0:FindFirstChild("geist_hunted") then
                        l_Character_0.geist_hunted:Destroy()
                    end;
                    _G.popupmsg("hunterswitch", v594[math.random(1, #v594)], 3)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "whisper" .. math.random(1, 4),
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    return;
                end;
                if p556 == "transition_flash" then
                    l_core_game_0.fadetoblack.BackgroundTransparency = 0
                    _G.fadetoblack = tick() + 1
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "exfil_runsound",
                        ["pitchvariation"] = 0.1,
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    v_u_2:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "exfil_flashsound",
                        ["pitchvariation"] = 0.1,
                        ["location"] = l_CurrentCamera_0
                    }, true)
                    return;
                end;
                if p556 == "mount_turret" then
                    if p_u_557 and (v_u_145 == nil and (p_u_557:FindFirstChild("centerpoint") and (p_u_557:FindFirstChild("torsoposition") and (p_u_557:FindFirstChild("in_use") and (l_ObjectValue_0.Value == nil and l_BoolValue_0.Value == false))))) then
                        l_ObjectValue_0.Value = p_u_557
                        v_u_6.CFrame = p_u_557.torsoposition.CFrame
                        return;
                    end;
                else
                    if p556 == "select_elitekit" then
                        if l_BoolValue_0.Value == true or v_u_145 ~= nil then
                            return;
                        elseif not l_Character_0:FindFirstChild("breakout_elitekit") then
                            l_BoolValue_0.Value = true
                            v_u_81.selection_box_selected = ""
                            if (v_u_7:FindFirstChild("time_played") and v_u_7.time_played.Value / 60 < 10 and true or _G.get_settings("elitekitselection") == true) == false then
                                local v595 = {
                                    "soldat",
                                    "mortician",
                                    "officer",
                                    "rook",
                                    "lancer",
                                    "jaeger",
                                    "vanguard"
                                }
                                if l_LocalPlayer_0.Character:FindFirstChild("cowboy") then
                                    table.insert(v595, "ocelot")
                                end;
                                v_u_81.display_selections(v595)
                            else
                                v_u_81.selection_box_selected = v_u_9.Value
                                if v_u_9.Value ~= "soldat" and (v_u_9.Value ~= "mortician" and (v_u_9.Value ~= "officer" and (v_u_9.Value ~= "lancer" and (v_u_9.Value ~= "jaeger" and (v_u_9.Value ~= "rook" and v_u_9.Value ~= "vanguard"))))) then
                                    v_u_81.selection_box_selected = "soldat"
                                end;
                            end;
                            local v596 = tick()
                            repeat
                                l_RenderStepped_0:wait()
                            until v_u_81.selection_box_selected ~= "" or (v_u_81.queue_inv ~= nil or tick() - v596 >= 3);
                            if v_u_81.queue_inv ~= nil or tick() - v596 >= 3 then
                                v_u_81.selection_box_selected = "none"
                            end;
                            if v_u_81.selection_box_selected ~= "none" then
                                v_u_81.no_swap_ticker = tick()
                                l_remotes_0.game_handler:FireServer("select_elitekit", v_u_81.selection_box_selected)
                                spawn(function() --[[ Line: 8140 ]]
                                    --[[ Upvalues: (ref 1): v_u_81, (ref 2): l_RenderStepped_0, (ref 3): l_Character_0 ]]
                                    repeat
                                        v_u_81.no_swap_ticker = tick()
                                        l_RenderStepped_0:Wait()
                                    until l_Character_0:FindFirstChild("elitekit") or l_Character_0:FindFirstChild("breakout_elitekit");
                                end)
                            end;
                            l_core_game_0.selectionboxes.Visible = false
                            v_u_81.selection_box_selected = ""
                            l_BoolValue_0.Value = false
                        end;
                    end;
                    if p556 == "reset_perk" then
                        if v_u_6 and v_u_6:FindFirstChild("apparitionlight") then
                            v_u_6.apparitionlight:Destroy()
                        end;
                        v_u_81.hold_breathmax = v_u_3.base_holdbreath_time
                        v_u_81.hold_breathregen = v_u_3.base_holdbreath_regen
                        v_u_81.hold_breathaccuracy = v_u_3.base_holdbreath_maxaccuracy
                        if p_u_557 and p_u_557 == "jaeger" then
                            game.ReplicatedStorage.misc.apparitionlight:Clone().Parent = v_u_6
                            return;
                        end;
                    elseif p556 == "flinch_target" or p556 == "flich_target_nosnap" then
                        v_u_114()
                        if p_u_557 and ((l_CurrentCamera_0.CFrame.Position - p_u_557).magnitude >= 90 and (tick() - v_u_550 >= 0.05 and p556 ~= "flich_target_nosnap")) then
                            v_u_550 = tick()
                            v_u_2:soundHandler({
                                ["directory"] = {},
                                ["soundfile"] = "snap" .. math.random(1, 3),
                                ["pitchvariation"] = 0.1,
                                ["location"] = l_CurrentCamera_0
                            }, true)
                            return;
                        end;
                    else
                        if p556 == "extend_outofbounds" then
                            v_u_242 = 40
                            delay(40, function() --[[ Line: 8198 ]]
                                --[[ Upvalues: (ref 1): v_u_242 ]]
                                v_u_242 = 20
                            end)
                            return;
                        end;
                        if p556 == "sonar_noise" then
                            v_u_235(p_u_557)
                            return;
                        end;
                        if p556 == "blood_splatter" then
                            if v_u_1 ~= nil and v_u_1.Health > 0 then
                                for _ = 1, p_u_557 do
                                    spawn(v_u_112)
                                end;
                            end;
                        end;
                        if p556 == "splatter_near_check" then
                            if v_u_1 == nil or v_u_1.Health <= 0 then
                                return;
                            end;
                            if p_u_557 and (v_u_6 and (p_u_557.Position - v_u_6.Position).magnitude <= 12) then
                                if v_u_6.CFrame.lookVector:Dot(p_u_557.Position - v_u_6.CFrame.Position) > -1 then
                                    for _ = 1, math.random(3, 5) do
                                        spawn(v_u_112)
                                    end;
                                end;
                            end;
                        elseif p556 == "overlay_near_check" then
                            if v_u_1 == nil or v_u_1.Health <= 0 then
                                return;
                            end;
                            if p_u_557 and v_u_6 then
                                local v597
                                if typeof(p_u_557) == "Instance" then
                                    v597 = p_u_557.Position
                                else
                                    v597 = p_u_557
                                end;
                                if (v597 - v_u_6.Position).magnitude <= 12 then
                                    if (p558.ignorelook and p558.ignorelook == true and 1 or (typeof(p_u_557) == "Instance" and p_u_557.Parent == l_Character_0 and 1 or v_u_6.CFrame.lookVector:Dot(v597 - v_u_6.CFrame.Position))) > -1 then
                                        v_u_4("apply_character_overlay", {
                                            ["char"] = l_Character_0,
                                            ["limbs"] = p558.limbs,
                                            ["rands"] = p558.rands,
                                            ["kind"] = p558.kind
                                        })
                                    end;
                                end;
                            end;
                        else
                            if p556 == "war_cry" then
                                delay(math.random(10, 20) / 10, function() --[[ Line: 8291 ]]
                                    --[[ Upvalues: (ref 1): v_u_1, (ref 2): l_remotes_0 ]]
                                    if v_u_1 and v_u_1.Health > 0 then
                                        l_remotes_0.game_handler:FireServer("languageline", "warcry")
                                    end;
                                end)
                                return;
                            end;
                            if p556 == "trap_triggered" then
                                if v_u_9.Value == "jaeger" then
                                    local v598 = {
                                        "A prey has triggered my " .. p_u_557 .. ".",
                                        "My " .. p_u_557 .. " has been sprung.",
                                        "I sense a prey has landed on my " .. p_u_557 .. ".",
                                        "A " .. p_u_557 .. " of mine has been activated."
                                    }
                                    _G.popupmsg("traplanded" .. math.random(1, 100), v598[math.random(1, #v598)], 2)
                                    return;
                                end;
                            else
                                if p556 == "headshot_sound" then
                                    v_u_2:soundHandler({
                                        ["directory"] = {},
                                        ["soundfile"] = l_LocalPlayer_0:FindFirstChild("hsl") and "helmets" or "headshot",
                                        ["location"] = l_CurrentCamera_0
                                    }, true)
                                    return;
                                end;
                                if p556 == "officer_buffed" then
                                    v_u_2:soundHandler({
                                        ["directory"] = {},
                                        ["soundfile"] = "morale",
                                        ["location"] = l_CurrentCamera_0
                                    }, true)
                                    local v599 = l_core_game_0.healthlow:Clone()
                                    s_Debris_0:AddItem(v599, 1)
                                    v599.Name = "buffed"
                                    v599.ImageColor3 = p_u_557
                                    v599.ImageTransparency = 0.7
                                    v599.Visible = true
                                    v599.Parent = l_core_game_0
                                    while v599 ~= nil and (v_u_1 ~= nil and v_u_1.Health > 0) do
                                        v599.ImageTransparency = v599.ImageTransparency + 0.01
                                        l_RenderStepped_0:Wait()
                                        if v599.ImageTransparency >= 1 then
                                            v599:Destroy()
                                            return;
                                        end;
                                    end;
                                    v599:Destroy()
                                    return;
                                end;
                                if p556 == "knockback" then
                                    _G.knockback_effect(p_u_557, p558)
                                    return;
                                end;
                                if p556 == "knockdown" or (p556 == "knockdown_back" or p556 == "vanguardknockdown") then
                                    if l_Character_0 ~= nil and l_Character_0:FindFirstChild("gender") ~= nil then
                                        local v600 = p556 == "vanguardknockdown" and "vanguard" or (p556 == "knockdown_back" and 1 or 2)
                                        v_u_119 = tick()
                                        l_remotes_0.game_handler:FireServer("hurtline", l_Character_0.gender.Value .. "_hurt" .. math.random(1, 10))
                                        v_u_81.fall_damage_interrupt = 0
                                        v_u_130(v600, false, true)
                                    end;
                                end;
                                if p556 == "bayonet_knockdown" then
                                    _G.knockdownproc(true)
                                    return;
                                end;
                                if p556 == "beartrap" then
                                    v_u_81.fall_damage_interrupt = 0
                                    v_u_130("beartrap", false, true)
                                    return;
                                end;
                                if p556 == "earring" then
                                    v_u_546(1000)
                                    v_u_248 = math.random(5, 10)
                                    if v_u_9.Value ~= "vanguard" then
                                        local l_coverexplosion_larm_0 = v_u_71.coverexplosion_larm
                                        if math.random(1, 2) == 1 and v_u_145 == nil or v_u_145 and v_u_145:FindFirstChild("lefthanded") then
                                            l_coverexplosion_larm_0 = v_u_71.coverexplosion_rarm
                                        end;
                                        l_coverexplosion_larm_0:Play(0.1, 1, 0.5)
                                    end;
                                end;
                                if p556 == "headshot_helmet_flinch" or p556 == "remove_helmet_flinch" then
                                    local v601 = p556 == "remove_helmet_flinch" and 1000 or p_u_557
                                    if v_u_8.Value ~= "leather" and (l_Character_0:FindFirstChild("chems") and (v_u_12:FindFirstChild("hyd") == nil or v_u_81.sick == true)) and v601 >= 70 then
                                        v_u_81.recoil_kick(5, 10, 6)
                                    end;
                                    v_u_81.sprint_force_stop = tick() + 0.75
                                    v_u_81.force_jump_tick = tick()
                                    v_u_546(v601)
                                    wait()
                                    if v_u_8.Value ~= "leather" then
                                        v_u_71["flinch_head" .. math.random(1, 2)]:Play(0.02, 0.25, 2)
                                    end;
                                end;
                                if p556 == "hit_shield" then
                                    if v_u_8.Value == "leather" then
                                        return;
                                    end;
                                    if tick() - v_u_549 >= 0.3 then
                                        v_u_549 = tick()
                                        v_u_81.recoil_kick(5, 5, 6)
                                    end;
                                    v_u_81.sprint_force_stop = tick() + 0.75
                                    v_u_81.force_jump_tick = tick()
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end)
workspace.constructions.ChildAdded:Connect(function(p603) --[[ Line: 8443 ]]
    --[[ Upvalues: (copy 1): v_u_3, (copy 2): v_u_9 ]]
    if p603.Name == "Dynamite Stack" and p603 then
        if not p603:FindFirstChild("core") then
            return;
        end;
        local l_dynamite_hiss_volume_default_2 = v_u_3.dynamite_hiss_volume_default
        local l_dynamite_hiss_range_default_2 = v_u_3.dynamite_hiss_range_default
        if v_u_9.Value == "jaeger" then
            l_dynamite_hiss_volume_default_2 = v_u_3.dynamite_hiss_volume_jaeger
            l_dynamite_hiss_range_default_2 = v_u_3.dynamite_hiss_range_jaeger
        end;
        p603.core.loop.Volume = l_dynamite_hiss_volume_default_2
        p603.core.loop.RollOffMaxDistance = l_dynamite_hiss_range_default_2
    end;
end)
_G.ear_ring = v_u_546
local v_u_604 = 0
local v_u_605 = 0
local l_Health_0 = v_u_1.Health
local v_u_613 = v_u_1.HealthChanged:connect(function(p606) --[[ Line: 8455 ]]
    --[[ Upvalues: (ref 1): l_Health_0, (ref 2): v_u_74, (copy 3): v_u_78, (copy 4): v_u_81, (copy 5): l_Character_0, (copy 6): v_u_8, (copy 7): v_u_71, (ref 8): v_u_120, (ref 9): v_u_119, (copy 10): l_remotes_0, (copy 11): l_core_game_0, (copy 12): v_u_12, (ref 13): v_u_604, (ref 14): v_u_605, (ref 15): v_u_145, (copy 16): v_u_3, (copy 17): v_u_112 ]]
    if p606 < l_Health_0 then
        local v607 = l_Health_0 - p606
        if p606 <= 0 then
            return;
        end;
        if v607 > 15 then
            if v_u_74 and (tick() - v_u_78 > 0.3 and v_u_74) then
                v_u_74:Stop(0.4)
                v_u_74:Destroy()
                v_u_74 = nil
            end;
            v_u_81.last_damage = tick()
            local v608 = "flinch" .. math.random(1, 5)
            local v609 = 2
            local v610 = 0.25
            if l_Character_0:FindFirstChild("limb_hit") then
                if l_Character_0.limb_hit.Value == "HeadHitbox" then
                    v608 = "flinch_head" .. math.random(1, 2)
                    v609 = 1
                elseif l_Character_0.limb_hit.Value == "Right Arm" then
                    v608 = "flinch_right1"
                    v610 = 0.3
                    v609 = 1.5
                elseif l_Character_0.limb_hit.Value == "Left Arm" then
                    v608 = "flinch_left1"
                    v610 = 0.3
                    v609 = 1.5
                end;
            end;
            local v611 = (not l_Character_0:FindFirstChild("elitekit") or (l_Character_0.elitekit.Value ~= "mortician" or v_u_81.aiming ~= true)) and true or false
            if v_u_8.Value == "leather" or l_Character_0:FindFirstChild("dreadnought") then
                v611 = false
            end;
            if v611 == true then
                v_u_71[v608]:Play(0.02, v610, v609)
            end;
            if v_u_8.Value ~= "leather" and (l_Character_0:FindFirstChild("dreadnought") == nil and (l_Character_0 and l_Character_0:FindFirstChild("gender"))) then
                local v612 = l_Character_0.gender.Value .. "_hurt" .. math.random(1, 10)
                if p606 <= 99 and tick() - v_u_120 >= 3 then
                    v_u_120 = tick()
                    v_u_119 = 0
                    v612 = l_Character_0.gender.Value .. "_heavy" .. math.random(1, 10)
                end;
                if tick() - v_u_119 >= 1 then
                    v_u_119 = tick()
                    l_remotes_0.game_handler:FireServer("hurtline", v612)
                end;
            end;
            if l_core_game_0.Parent.loadout_menu.Visible == false and (v_u_8.Value ~= "leather" and (l_Character_0:FindFirstChild("buff_defend") == nil and (l_Character_0:FindFirstChild("buff_elite") == nil and (l_Character_0:FindFirstChild("chems") and (v_u_12:FindFirstChild("hyd") == nil or v_u_81.sick == true))))) then
                if tick() - v_u_604 >= 4 then
                    v_u_605 = 0
                end;
                v_u_604 = tick()
                v_u_605 = v_u_605 + v607
                if workspace.serverStuff.restorationmode.Value == true then
                    v_u_605 = 200
                end;
                if v_u_145 and (v_u_145:FindFirstChild("bipod") and tick() - v_u_145.bipod.Value <= v_u_3.bulwark_buffer) then
                    v_u_605 = 0
                end;
                if v_u_605 >= 105 then
                    if math.random(1, 3) == 1 then
                        spawn(v_u_112)
                        spawn(v_u_112)
                    end;
                    v_u_605 = 0
                    v_u_81.recoil_kick(5, 10, 6)
                end;
            end;
        end;
        if v_u_81.charging ~= true then
            v_u_81.sprint_force_stop = tick() + 0.75
            v_u_81.force_jump_tick = tick()
        end;
    end;
    l_Health_0 = p606
end)
local v_u_615 = v_u_1.Changed:connect(function(p614) --[[ Line: 8571 ]]
    --[[ Upvalues: (copy 1): v_u_81, (ref 2): v_u_145, (copy 3): l_Character_0, (copy 4): l_ObjectValue_0, (ref 5): v_u_74, (copy 6): v_u_1, (copy 7): v_u_2, (copy 8): v_u_6 ]]
    if p614 == "Jump" then
        if tick() - v_u_81.jump_tick <= 0.5 or (tick() - v_u_81.fall_damage_interrupt <= 0 or (tick() - v_u_81.force_jump_tick <= 1 or v_u_81.aiming == true and (v_u_145 ~= nil and (v_u_145.weapon.Value ~= "pick" and (v_u_145.weapon.Value ~= "pickaxe" and v_u_145.weapon.Value ~= "firstaid"))))) or (v_u_81.in_air == true or (v_u_81.sprint_block == true or (l_Character_0:FindFirstChild("crippled") or (l_Character_0:FindFirstChild("stop_movement") or (l_ObjectValue_0.Value ~= nil or v_u_74 ~= nil))))) then
            v_u_1.Jump = false
        end;
        if v_u_1.Jump == true then
            v_u_2:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "jump",
                ["location"] = v_u_6
            })
            v_u_81.jumped_air = true
            v_u_81.air_just_jumped = tick()
            v_u_81.jump_tick = tick()
        end;
    end;
end)
v_u_1.Died:Connect(function() --[[ Line: 8590 ]]
    --[[ Upvalues: (copy 1): l_core_game_0, (copy 2): l_BindableEvent_0, (ref 3): v_u_22, (ref 4): v_u_74, (copy 5): v_u_30, (copy 6): l_remotes_0, (ref 7): v_u_493, (copy 8): v_u_81, (copy 9): v_u_6, (copy 10): v_u_54, (copy 11): v_u_25, (copy 12): l_selectionboxes_0, (copy 13): l_LocalPlayer_0, (copy 14): v_u_615, (copy 15): v_u_60, (copy 16): v_u_53, (copy 17): l_Character_0, (copy 18): v_u_40, (copy 19): v_u_41, (copy 20): v_u_3, (copy 21): v_u_52, (copy 22): v_u_71, (copy 23): l_values_0, (copy 24): v_u_223, (copy 25): l_CurrentCamera_0, (copy 26): s_UserInputService_0, (ref 27): v_u_57, (ref 28): v_u_58, (ref 29): v_u_55, (copy 30): v_u_56, (copy 31): l_Part_0, (copy 32): v_u_544, (copy 33): v_u_543, (copy 34): v_u_602, (copy 35): v_u_199, (copy 36): v_u_613 ]]
    l_core_game_0.hint_popup.Visible = false
    l_BindableEvent_0:Destroy()
    if v_u_22 then
        v_u_22:Destroy()
    end;
    if v_u_74 then
        v_u_74:Stop(0.4)
        v_u_74:Destroy()
        v_u_74 = nil
    end;
    if game.Players:GetPlayerFromCharacter(v_u_30.target) then
        l_remotes_0.game_handler:FireServer("jaegerlost", game.Players:GetPlayerFromCharacter(v_u_30.target))
    end;
    if v_u_30.mark then
        v_u_30.mark:Destroy()
    end;
    l_core_game_0.Visible = true
    l_core_game_0.helmetoverlay.Visible = false
    v_u_493:Disconnect()
    if v_u_81.internal_sound then
        v_u_81.internal_sound:Destroy()
    end;
    if v_u_81.mosin_scope ~= nil then
        v_u_81.mosin_scope:Destroy()
    end;
    l_core_game_0.fadetoblack.BackgroundTransparency = 1
    _G.fadetoblack = 0
    l_core_game_0.deathscreen.spawnframe.toptext.Text = "Select an Insertion Point"
    if _G.using_controller == true then
        l_core_game_0.deathscreen.spawnframe.toptext.Text = "Swap Insertion Point with [A]"
    end;
    for _, v616 in ipairs(l_core_game_0.splatters:GetChildren()) do
        if v616.Name ~= "ex" then
            v616:Destroy()
        end;
    end;
    if v_u_6 and v_u_6:FindFirstChild("apparitionlight") then
        v_u_6.apparitionlight:Destroy()
    end;
    if v_u_54 then
        v_u_54:Destroy()
    end;
    l_core_game_0.scoreframe.objective_uis.Visible = false
    if v_u_25 then
        v_u_25.Visible = false
    end;
    l_selectionboxes_0.Visible = false
    l_selectionboxes_0.selectedoption.Text = ""
    for _, v617 in ipairs(l_selectionboxes_0.selections:GetChildren()) do
        if v617.Name ~= "UIListLayout" and v617.Name ~= "ex" then
            v617:Destroy()
        end;
    end;
    for _, v618 in ipairs(workspace.throwables:GetChildren()) do
        if v618.Name == l_LocalPlayer_0.Name .. "_compass" then
            v618:Destroy()
        end;
    end;
    if v_u_6 and v_u_6:FindFirstChild("RootJoint") then
        v_u_6.RootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
    end;
    v_u_615:Disconnect()
    l_core_game_0.voicewheel.Visible = false
    l_core_game_0.barrelobstruction.Visible = false
    l_core_game_0.binocsoverlay.Visible = false
    l_core_game_0.akimbocrosshair.Visible = false
    v_u_60:Destroy()
    for _, v619 in ipairs(l_core_game_0.rotating_indicator:GetChildren()) do
        if v619.Name ~= "ex" then
            v619:Destroy()
        end;
    end;
    v_u_53:Destroy()
    game:GetService("RunService"):UnbindFromRenderStep("MainLoop")
    l_LocalPlayer_0.CameraMode = Enum.CameraMode.Classic
    l_core_game_0.Parent.dot_crosshair.Visible = false
    if l_Character_0 then
        for _, v620 in ipairs(l_Character_0:GetChildren()) do
            if v620:IsA("BasePart") then
                v620.Anchored = false
            end;
        end;
    end;
    if v_u_40 and (v_u_40:FindFirstChild("basecenter") and v_u_40.basecenter:FindFirstChild("bb")) then
        v_u_40.basecenter.bb.Enabled = false
        v_u_41.basecenter.bb.Enabled = false
    end;
    game.SoundService.mainSoundGroup.Volume = v_u_3.default_soundgroup
    game.SoundService.radioSoundGroup.Volume = v_u_3.default_radiogroup
    workspace.ambience.Volume = v_u_3.default_ambience
    v_u_52:Destroy()
    for _, v621 in ipairs(l_Character_0:GetDescendants()) do
        if (v621:IsA("Motor6D") or v621:IsA("Weld")) and string.sub(v621.Name, -4, (string.len(v621.Name))) == "fake" then
            v621:Destroy()
        end;
    end;
    for _, v622 in pairs(v_u_71) do
        v622:Stop(0)
        v622:Destroy()
    end;
    for _, v623 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
        if v623:FindFirstChild("objcenter") and l_values_0.gamestate.sub.Value == "" then
            local v624 = v623.objcenter:FindFirstChild("obj_icon")
            if v624 then
                v624.Enabled = true
                v_u_223(v624)
            end;
        end;
    end;
    l_LocalPlayer_0.CameraMaxZoomDistance = 10
    if l_core_game_0.Parent.loadout_menu.Visible == false then
        l_CurrentCamera_0.FieldOfView = 90
    end;
    s_UserInputService_0.MouseDeltaSensitivity = 1
    l_core_game_0.traitortext.Visible = false
    l_core_game_0.objpopup.Visible = false
    l_core_game_0.binocsoverlay.Visible = false
    v_u_57.Size = 0
    v_u_58.TintColor = Color3.new(1, 1, 1)
    v_u_58.Saturation = 0
    l_core_game_0.inventory.Visible = false
    v_u_55:Destroy()
    if v_u_56 then
        v_u_56:Destroy()
    end;
    if l_Part_0 then
        l_Part_0:Destroy()
    end;
    l_core_game_0.inventoryitemname.item.TextTransparency = 1
    game:GetService("SoundService").mainSoundGroup.comp.Enabled = false
    game:GetService("SoundService").maskSoundGroup.comp.Enabled = false
    local v625 = l_LocalPlayer_0:FindFirstChild("useelitedeathquote") and v_u_544 or v_u_543
    l_core_game_0.deathscreen.topframe.toptext.Text = "You have fallen in the war."
    l_core_game_0.deathscreen.topframe.lowertext.Text = v625[math.random(1, #v625)]
    l_core_game_0.deathscreen.Visible = true
    l_core_game_0.healthlow.ImageTransparency = 1
    l_core_game_0.morale.ImageTransparency = 1
    l_core_game_0.injuredhealth.ImageTransparency = 1
    l_core_game_0.holdbreath.ImageTransparency = 1
    l_core_game_0.crosshair.Visible = false
    l_core_game_0.genericcrosshair.Visible = false
    s_UserInputService_0.MouseIconEnabled = true
    s_UserInputService_0.MouseBehavior = Enum.MouseBehavior.Default
    v_u_602:Disconnect()
    v_u_199:Disconnect()
    v_u_613:Disconnect()
    wait()
    l_core_game_0.akimbocrosshair.Visible = false
    for _, v626 in ipairs(workspace.constructions:GetChildren()) do
        local v627 = v626:FindFirstChild("deployable_highlight")
        if v627 then
            v627.Enabled = false
        end;
    end;
    l_LocalPlayer_0.CameraMaxZoomDistance = 10
    if l_core_game_0.Parent.loadout_menu.Visible == false then
        l_CurrentCamera_0.FieldOfView = 90
    end;
    s_UserInputService_0.MouseDeltaSensitivity = 1
    game.SoundService.mainSoundGroup.Volume = 1
    workspace.ambience.Volume = 0.75
    if l_Character_0 then
        for _, v628 in ipairs(l_Character_0:GetChildren()) do
            if v628:IsA("BasePart") then
                v628.Anchored = false
            end;
        end;
    end;
end)
