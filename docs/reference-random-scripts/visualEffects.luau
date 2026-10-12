local v_u_29 = {
    ["faketag_hand"] = function(p1) --[[ Line: 69 ]]
        if p1.char and p1.char:FindFirstChild("Left Arm") then
            local v2 = workspace.throwables:FindFirstChild("wellertag" .. p1.char.Name)
            if v2 then
                v2:Destroy()
                return;
            end;
            local v3 = game.ReplicatedStorage.misc.wellertag:Clone()
            v3.Name = "wellertag" .. p1.char.Name
            local l_Weld_0 = Instance.new("Weld")
            l_Weld_0.Name = "wellertagweld"
            l_Weld_0.Part0 = v3
            l_Weld_0.Part1 = p1.char["Left Arm"]
            l_Weld_0.Parent = v3
            v3.Parent = workspace.throwables
        end;
    end,
    ["lancer_handaxe"] = function(p4) --[[ Line: 136 ]]
        if p4.char and (p4.char:FindFirstChild("Humanoid") and (p4.char.Humanoid.Health > 0 and (p4.char:FindFirstChild("Left Arm") and p4.char:FindFirstChild("Right Arm")))) then
            local v5 = workspace.throwables:FindFirstChild(p4.char.Name .. "_lancer_axe_piece")
            if v5 then
                v5:Destroy()
                return;
            end;
            local v6 = p4.handuse and p4.char:FindFirstChild(p4.handuse)
            if v6 then
                local v7 = game.ReplicatedStorage.weapon_models.throwaxe:Clone()
                v7.Name = p4.char.Name .. "_lancer_axe_piece"
                local l_Weld_1 = Instance.new("Weld")
                l_Weld_1.Part0 = v6
                l_Weld_1.Part1 = v7.hitbox
                l_Weld_1.C0 = CFrame.new(-0.0744018555, -1.04323936, -0.407714844, -1, 0, 0, 0, 0, -0.999999881, 0, -1, 0)
                l_Weld_1.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                l_Weld_1.Parent = v7
                v7.Parent = workspace.throwables
            end;
        end;
    end,
    ["lowgraphics_flare"] = function(p8) --[[ Line: 166 ]]
        if _G.get_settings("lowgraphics") == true and (p8 and p8.flare) then
            local v9 = p8.flare:FindFirstChild("spark1")
            if v9 then
                v9:Destroy()
            end;
            local v10 = p8.flare:FindFirstChild("spark2")
            if v10 then
                v10:Destroy()
            end;
            local v11 = p8.flare:FindFirstChild("flarepoint") and p8.flare.flarepoint:FindFirstChild("flare2")
            if v11 then
                v11:Destroy()
            end;
        end;
    end,
    ["reset_limbpos"] = function(p12) --[[ Line: 187 ]]
        if p12 and (p12.rs and (p12.ls and (p12.ne and p12.rj))) then
            p12.rs.C0 = CFrame.new(1, 0.5, 0, -4.37113883e-8, 0, 1, -0, 0.99999994, 0, -1, 0, -4.37113883e-8)
            p12.ls.C0 = CFrame.new(-1, 0.5, 0, -4.37113883e-8, 0, -1, 0, 0.99999994, 0, 1, 0, -4.37113883e-8)
            p12.ne.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            p12.rj.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
        end;
    end,
    ["clear_face"] = function(p13) --[[ Line: 270 ]]
        if p13 and p13.face then
            local v14 = p13.face:FindFirstChild("dirtoverlay")
            if v14 then
                v14:Destroy()
            end;
            local v15 = p13.face:FindFirstChild("dirtoverlay2")
            if v15 then
                v15:Destroy()
            end;
            local v16 = p13.face:FindFirstChild("bloodoverlay")
            if v16 then
                v16:Destroy()
            end;
            local v17 = p13.face:FindFirstChild("bloodoverlay2")
            if v17 then
                v17:Destroy()
            end;
        end;
    end,
    ["destroy_compasses"] = function(p18) --[[ Line: 501 ]]
        if p18.char then
            for _, v19 in ipairs(workspace.throwables:GetChildren()) do
                if v19.Name == p18.char.Name .. "_compass" then
                    v19:Destroy()
                end;
            end;
        end;
    end,
    ["play_deathline"] = function(p20) --[[ Line: 672 ]]
        if p20 and (p20.voice and (p20.voiceline and p20.gender)) then
            local l_voiceline_0 = p20.voiceline
            if _G.get_settings and (_G.get_settings("disabledeathyells") == true and (string.sub(l_voiceline_0.Name, 1, 6) == "m_fall" or (string.sub(l_voiceline_0.Name, 1, 6) == "f_fall" or (string.sub(l_voiceline_0.Name, 1, 6) == "m_rare" or string.sub(l_voiceline_0.Name, 1, 6) == "f_rare")))) then
                l_voiceline_0 = game.ReplicatedStorage.sound_library.voices:FindFirstChild(p20.gender .. "_yell" .. math.random(1, 15))
            end;
            p20.voice.Volume = l_voiceline_0.Volume
            p20.voice.SoundId = l_voiceline_0.SoundId
            p20.voice:Play()
        end;
    end,
    ["weldingfx"] = function(p21) --[[ Line: 1337 ]]
        if p21 and (p21.weldfx and (p21.weldfx:FindFirstChild("loop") and (p21.weldfx:FindFirstChild("firefx") and p21.state))) then
            if p21.state == "start" then
                p21.weldfx.loop:Play()
                p21.weldfx.firefx.Enabled = true
                p21.weldfx.welding.flash.Enabled = false
                p21.weldfx.welding.sparks.Enabled = false
                return;
            end;
            if p21.state == "weldfx" then
                p21.weldfx.electricloop:Play()
                p21.weldfx.welding.flash.Enabled = true
                p21.weldfx.welding.sparks.Enabled = true
                return;
            end;
            p21.weldfx.loop:Stop()
            p21.weldfx.electricloop:Stop()
            p21.weldfx.firefx.Enabled = false
            p21.weldfx.welding.flash.Enabled = false
            p21.weldfx.welding.sparks.Enabled = false
        end;
    end,
    ["destroy_fakes"] = function(p22) --[[ Line: 1789 ]]
        if p22.char and (p22.char.Parent == workspace.notarget or (p22.char.Parent == workspace.nation_team or p22.char.Parent == workspace.empire_team)) then
            for _, v23 in ipairs(p22.char:GetDescendants()) do
                if (v23:IsA("Motor6D") or v23:IsA("Weld")) and string.sub(v23.Name, -4, (string.len(v23.Name))) == "fake" then
                    v23:Destroy()
                end;
            end;
        end;
    end,
    ["char_dead"] = function(p24) --[[ Line: 2441 ]]
        if p24.char_chosen and p24.char_chosen:FindFirstChild("HumanoidRootPart") then
            if p24.old_char then
                local v25 = p24.old_char:FindFirstChild("footstep_trail")
                if v25 then
                    v25:Destroy()
                end;
                if p24.old_char:FindFirstChild("HumanoidRootPart") and p24.old_char.HumanoidRootPart:FindFirstChild("apparitionlight") then
                    p24.old_char.HumanoidRootPart.apparitionlight:Destroy()
                end;
            end;
            for _, v26 in ipairs(p24.char_chosen:GetChildren()) do
                if v26:IsA("Highlight") then
                    v26:Destroy()
                end;
            end;
            if p24.executing and p24.executing == false then
                for _, v27 in ipairs(p24.char_chosen:GetDescendants()) do
                    if v27:IsA("BasePart") then
                        v27.Anchored = false
                    end;
                end;
                p24.char_chosen.HumanoidRootPart.Anchored = false
                if p24.char_chosen:FindFirstChild("Humanoid") then
                    for _, v28 in ipairs(p24.char_chosen.Humanoid:GetPlayingAnimationTracks()) do
                        v28:Stop(0)
                        v28:Destroy()
                    end;
                end;
            end;
        end;
    end
}
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local v_u_30 = require(game.ReplicatedStorage.shared.bFunctions)
local s_Debris_0 = game:GetService("Debris")
local v_u_31 = tick()
local v_u_32 = tick()
local v_u_33 = tick()
local function _(p34, p35, p36, p37) --[[ Name: quadBezier ]] --[[ Line: 16 ]]
    return (1 - p34) ^ 2 * p35 + 2 * (1 - p34) * p34 * p36 + p34 ^ 2 * p37;
end;
local v_u_38 = {
    workspace.notarget,
    workspace.throwables,
    workspace.nation_team,
    workspace.empire_team,
    workspace.bodies
}
local l_CurrentCamera_0 = workspace.CurrentCamera
v_u_29.officer_flaregun = function(p39) --[[ Line: 24 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_29, (copy 3): v_u_30 ]]
    if p39.char and (p39.char:FindFirstChild("Humanoid") and (p39.char.Humanoid.Health > 0 and p39.char:FindFirstChild("Left Arm"))) then
        local v_u_40 = game.ReplicatedStorage.misc.flaregun:Clone()
        s_Debris_0:AddItem(v_u_40, 1)
        local l_Weld_2 = Instance.new("Weld")
        local l_Left Arm_0 = p39.char["Left Arm"]
        local v41 = CFrame.new(0.16884613, -0.862862587, -0.442581177, -1, 0, 0, 0, 0, -0.99999994, 0, -1, 0)
        if p39.arm_use == false then
            v41 = v41 * CFrame.new(0.4, 0, 0)
            l_Left Arm_0 = p39.char["Right Arm"]
        end;
        l_Weld_2.Part0 = l_Left Arm_0
        l_Weld_2.Part1 = v_u_40
        l_Weld_2.C0 = v41
        l_Weld_2.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        l_Weld_2.Parent = v_u_40
        v_u_40.Parent = workspace.notarget
        delay(0.4, function() --[[ Line: 45 ]]
            --[[ Upvalues: (copy 1): v_u_40, (ref 2): s_Debris_0, (ref 3): v_u_29, (ref 4): v_u_30 ]]
            if v_u_40 and (v_u_40:FindFirstChild("unfired") and (v_u_40:FindFirstChild("muzzle") and v_u_40:FindFirstChild("fired"))) then
                s_Debris_0:AddItem(v_u_40, 0.4)
                v_u_40.unfired.Transparency = 1
                v_u_40.fired.Transparency = 0
                v_u_29.muzzle_flash({
                    ["point"] = v_u_40.muzzle.CFrame,
                    ["weapon_name"] = "rooklauncher",
                    ["noflash"] = true
                })
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "flare_fire" .. math.random(1, 2),
                    ["location"] = v_u_40
                }, true)
            end;
        end)
    end;
end;
v_u_29.lancer_fakestim = function(p42) --[[ Line: 92 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30 ]]
    if p42.char and (p42.char:FindFirstChild("lancerstim2") or p42.char:FindFirstChild("lancerstim6")) and workspace.notarget:FindFirstChild(p42.char.Name .. "_lancerstim") == nil then
        local v43 = p42.char:FindFirstChild("lancerstim2") or p42.char:FindFirstChild("lancerstim6")
        local v44 = v43:FindFirstChild("hitbox") or v43:FindFirstChild("unequipped")
        if v44 then
            local v_u_45 = game.ReplicatedStorage.weapon_models.lancerstim:Clone()
            s_Debris_0:AddItem(v_u_45, 5)
            v_u_45.Name = p42.char.Name .. "_lancerstim"
            v_u_45.parts.inside:Destroy()
            v_u_45.hitbox.CanCollide = true
            v_u_45.hitbox.CanTouch = true
            v_u_45:SetPrimaryPartCFrame(v44.CFrame)
            v_u_45.Parent = workspace.notarget
            local v_u_46 = false
            local v_u_47 = nil
            v_u_47 = v_u_45.hitbox.Touched:Connect(function(p48) --[[ Line: 113 ]]
                --[[ Upvalues: (copy 1): v_u_45, (ref 2): v_u_46, (ref 3): v_u_30, (ref 4): v_u_47 ]]
                if v_u_45 and (v_u_45:FindFirstChild("hitbox") and (v_u_45.Parent == workspace.notarget and (p48:IsDescendantOf(workspace.notarget) ~= true and (p48:IsDescendantOf(workspace.empire_team) ~= true and (p48:IsDescendantOf(workspace.nation_team) ~= true and (p48:IsDescendantOf(workspace.bodies) ~= true and v_u_46 == false)))))) then
                    v_u_46 = true
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "rscclip" .. math.random(1, 2),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_45.hitbox
                    }, true)
                    v_u_47:Disconnect()
                end;
            end)
        end;
    end;
end;
v_u_29.fake_shield_parts = function(p49) --[[ Line: 197 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30 ]]
    if p49.part and (p49.part:FindFirstChild("health") and p49.transp) then
        if p49.transp == 1 then
            local v_u_50 = p49.part:Clone()
            for _, v51 in ipairs(v_u_50:GetChildren()) do
                if v51:IsA("BasePart") then
                    if v51.Name == "decal" then
                        v51.Decal.Transparency = 0
                    else
                        v51.Transparency = 0
                        if p49.broken_piece and v51:FindFirstChild("damaged") then
                            v51.damaged.Transparency = 0
                        end;
                    end;
                end;
            end;
            s_Debris_0:AddItem(v_u_50, 10)
            v_u_50.Massless = false
            v_u_50.CanCollide = true
            v_u_50.CanQuery = false
            v_u_50.CanTouch = true
            v_u_50.CollisionGroup = "MiscCollision"
            v_u_50.CFrame = p49.part.CFrame
            v_u_50.Parent = workspace.notarget
            v_u_50.Velocity = v_u_50.Velocity + Vector3.new(math.random(-10, 10), math.random(10, 10), math.random(-10, 10))
            local v_u_52 = false
            local v_u_53 = nil
            v_u_53 = v_u_50.Touched:Connect(function(p54) --[[ Line: 231 ]]
                --[[ Upvalues: (copy 1): v_u_50, (ref 2): v_u_52, (ref 3): v_u_30, (ref 4): v_u_53 ]]
                if v_u_50 and (v_u_50.Parent == workspace.notarget and (p54:IsDescendantOf(workspace.notarget) ~= true and (p54:IsDescendantOf(workspace.empire_team) ~= true and (p54:IsDescendantOf(workspace.nation_team) ~= true and (p54:IsDescendantOf(workspace.bodies) ~= true and v_u_52 == false))))) then
                    v_u_52 = true
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "metal" .. math.random(1, 3),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_50
                    }, true)
                    v_u_53:Disconnect()
                end;
            end)
        end;
        for _, v55 in ipairs(p49.part:GetChildren()) do
            if v55:IsA("BasePart") then
                if v55.Name == "decal" then
                    v55.Decal.Transparency = p49.transp
                else
                    v55.Transparency = p49.transp
                    if v55:FindFirstChild("damaged") then
                        v55.damaged.Transparency = 1
                    end;
                end;
            end;
        end;
    end;
end;
local v_u_56 = game.ReplicatedStorage.misc.sf:GetChildren()
v_u_29.apply_character_overlay = function(p57) --[[ Line: 291 ]]
    --[[ Upvalues: (copy 1): v_u_56 ]]
    if _G.get_settings("disablebloodbody") == true then
        return;
    end;
    if not (p57 and (p57.char and (p57.char:FindFirstChild("Humanoid") and (p57.limbs and p57.rands)))) then
        -- ::l4:: (Possible bug with goto)
        return;
    end;
    for v58, v59 in ipairs(p57.limbs) do
        local v60 = p57.char:FindFirstChild(v59)
        if v59 == "Helmet" then
            if p57.char:FindFirstChild("helmet") and (p57.char.helmet:FindFirstChild("knock") and (p57.char.helmet.knock:FindFirstChild("overlay") and p57.char.helmet:FindFirstChild("nopaint") == nil)) then
                v60 = p57.char.helmet.knock.overlay
                break;
            end;
        else
            -- ::l12:: (Possible bug with goto)
            if v59 == "Facemask" then
                if p57.char:FindFirstChild("extralift") and (p57.char.extralift:FindFirstChild("main") and (p57.char.extralift.main:FindFirstChild("overlay") and p57.char.extralift:FindFirstChild("nopaint") == nil)) then
                    v60 = p57.char.extralift.main.overlay
                    break;
                end;
            else
                -- ::l19:: (Possible bug with goto)
                if v60 then
                    local v61 = not p57.kind and "bloodoverlay" or p57.kind
                    if v60 and v60:FindFirstChild(v61 .. "2") == nil then
                        if v59 == "Helmet" or v59 == "Facemask" then
                            v60.Transparency = 0
                            local v62 = v_u_56[p57.rands[v58]]:Clone()
                            if v60:FindFirstChild(v61) then
                                v62.Name = v61 .. "2"
                                local v63 = v60:Clone()
                                for _, v64 in ipairs(v63:GetChildren()) do
                                    v64:Destroy()
                                end;
                                v63.Size = v63.Size * 1.02
                                v63.Transparency = 0
                                v63.Name = v61 .. "2"
                                v63.CFrame = v60.CFrame
                                local l_Weld_3 = Instance.new("Weld")
                                l_Weld_3.Part0 = v63
                                l_Weld_3.Part1 = v60
                                l_Weld_3.Parent = v63
                                v63.Parent = v60
                                v62.Parent = v63
                            else
                                v62.Name = v61
                                v62.Parent = v60
                            end;
                            if p57.kind and p57.kind == "dirtoverlay" then
                                v62.Color = Color3.fromRGB(69, 58, 47)
                            end;
                            if p57.kind and p57.kind == "burnoverlay" then
                                v62.Color = Color3.fromRGB(200, 90, 0)
                            end;
                        else
                            local l_overlaylimb_0 = game.ReplicatedStorage.misc.overlaylimb
                            if v59 == "Torso" then
                                l_overlaylimb_0 = game.ReplicatedStorage.misc.overlaytorso
                            end;
                            if v59 == "Head" then
                                l_overlaylimb_0 = game.ReplicatedStorage.misc.overlayhead
                            end;
                            local v65 = l_overlaylimb_0:Clone()
                            v65.Name = v61
                            local v66 = v_u_56[p57.rands[v58]]:Clone()
                            v66.Parent = v65
                            if v60:FindFirstChild(v61) then
                                v65.Name = v61 .. "2"
                                v65.Size = v65.Size * 1.02
                            end;
                            if p57.kind and p57.kind == "dirtoverlay" then
                                v66.Color = Color3.fromRGB(69, 58, 47)
                            end;
                            if p57.kind and p57.kind == "burnoverlay" then
                                v66.Color = Color3.fromRGB(200, 90, 0)
                            end;
                            v65.CFrame = v60.CFrame
                            local l_Weld_4 = Instance.new("Weld")
                            l_Weld_4.Part0 = v60
                            l_Weld_4.Part1 = v65
                            l_Weld_4.Parent = v65
                            if v59 == "Torso" then
                                l_Weld_4.C1 = CFrame.Angles(0, 1.5707963267948966 - 3.141592653589793 * math.random(0, 1), 0)
                            elseif v59 == "Head" then
                                l_Weld_4.C1 = CFrame.Angles(0, 3.141592653589793, 0)
                            else
                                l_Weld_4.C1 = CFrame.Angles(0, 1.5707963267948966 * math.random(1, 4), 0)
                            end;
                            v65.Parent = v60
                        end;
                    end;
                end;
            end;
        end;
    end;
    break;
end;
local function _(p67, p68) --[[ Line: 426 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0 ]]
    return (p68 or 150) <= (l_CurrentCamera_0.CFrame.Position - p67).Magnitude;
end;
v_u_29.create_compass = function(p69) --[[ Line: 438 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): l_RenderStepped_0 ]]
    if p69 and (p69.char and (p69.part and (p69.part.Parent == p69.char and (p69.team and (p69.part.Name == "Right Arm" or p69.part.Name == "Left Arm"))))) then
        if (l_CurrentCamera_0.CFrame.Position - p69.part.Position).Magnitude >= 150 == true then
            return;
        else
            local l_nationcompass_0 = game.ReplicatedStorage.misc.nationcompass
            if p69.team == game.Teams["Golden Empire"] then
                l_nationcompass_0 = game.ReplicatedStorage.misc.empirecompass
            end;
            local v70 = l_nationcompass_0:Clone()
            v70.Name = p69.char.Name .. "_compass"
            local l_Weld_5 = Instance.new("Weld")
            l_Weld_5.Part0 = p69.part
            l_Weld_5.Part1 = v70.base
            if p69.part.Name == "Left Arm" then
                l_Weld_5.C0 = CFrame.new(0.591651917, -0.828273058, -0.127166748, 0, 1, 0, -0.999999821, 0, 0, 0, 0, 1)
            else
                l_Weld_5.C0 = CFrame.new(-0.597251892, -0.828273058, -0.127410889, 0, -1, 0, -0.99999994, 0, 0, 0, 0, -1)
            end;
            l_Weld_5.Parent = v70
            v70.Parent = workspace.throwables
            if _G.get_settings("lowgraphics") == true then
                v70.base.lid_rotate.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, 0, 2.443460952792061)
            else
                local v71 = tick()
                while v70 and (p69.char and (p69.char:FindFirstChild("Torso") and (v70.Parent and (v70.Parent == workspace.throwables and (v70:FindFirstChild("base") and v70.base:FindFirstChild("lid_rotate")))))) do
                    local l_Y_0 = (p69.char.Torso.Orientation - workspace.northpoint.Orientation).Y
                    local v72 = math.clamp((tick() - v71) / 0.6, 0, 1)
                    v70.base.lid_rotate.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1):Lerp(CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, 0, 2.443460952792061), v72 * v72 * (3 - v72 * 2))
                    v70.base.compass_rotate.C1 = v70.base.compass_rotate.C1:Lerp(CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, math.rad(l_Y_0), 0), 0.1)
                    l_RenderStepped_0:Wait()
                end;
            end;
        end;
    else
        return;
    end;
end;
v_u_29.sharpening_spark = function(p_u_73) --[[ Line: 513 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0 ]]
    if p_u_73.part then
        if (l_CurrentCamera_0.CFrame.Position - p_u_73.part.Position).Magnitude >= 150 == true then
            return;
        end;
        delay(0.05, function() --[[ Line: 520 ]]
            --[[ Upvalues: (copy 1): p_u_73, (ref 2): s_Debris_0 ]]
            if p_u_73.part then
                local l_Attachment_0 = Instance.new("Attachment")
                s_Debris_0:AddItem(l_Attachment_0, 0.5)
                l_Attachment_0.Parent = p_u_73.part
                l_Attachment_0.Position = Vector3.new(0.458, -0.935, 0)
                local v74 = game.ReplicatedStorage.effects.sharpeningspark:Clone()
                v74.Parent = l_Attachment_0
                v74:Emit(math.random(6, 8))
            end;
        end)
    end;
end;
v_u_29.highlight_code = function(p75) --[[ Line: 537 ]]
    --[[ Upvalues: (copy 1): v_u_30 ]]
    if p75.part and p75.message then
        p75.part.BrickColor = BrickColor.new("Black")
        p75.part.Material = Enum.Material.SmoothPlastic
        p75.part.PointLight.Enabled = false
        if p75.part:FindFirstChild("a1") and p75.part.a1:FindFirstChild("flare") then
            p75.part.a1.flare.Enabled = false
        end;
        v_u_30:s_wait(2)
        if p75.part and p75.message then
            while p75.part ~= nil do
                for v76 = 1, string.len(p75.message) do
                    if p75.part == nil then
                        return;
                    end;
                    local v77 = string.sub(p75.message, v76, v76)
                    local v78 = v77 == "." and 0.2 or 0.5
                    if v77 == " " then
                        v_u_30:s_wait(1)
                    else
                        p75.part.BrickColor = BrickColor.new("Institutional white")
                        p75.part.Material = Enum.Material.Neon
                        if p75.part:FindFirstChild("a1") and p75.part.a1:FindFirstChild("flare") then
                            p75.part.a1.flare.Enabled = true
                        end;
                        v_u_30:s_wait(v78)
                        if p75.part == nil then
                            return;
                        end;
                        p75.part.BrickColor = BrickColor.new("Really black")
                        p75.part.Material = Enum.Material.SmoothPlastic
                        if p75.part:FindFirstChild("a1") and p75.part.a1:FindFirstChild("flare") then
                            p75.part.a1.flare.Enabled = false
                        end;
                        v_u_30:s_wait(0.1)
                    end;
                end;
                if p75.part == nil then
                    return;
                end;
                v_u_30:s_wait(4)
            end;
            return;
        end;
    end;
end;
v_u_29.highlight_flash = function(p79) --[[ Line: 609 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_30, (copy 3): l_RenderStepped_0 ]]
    if p79.part and (p79.duration and p79.colour) then
        if p79.part:FindFirstChild("Torso") and (l_CurrentCamera_0.CFrame.Position - p79.part.Torso.Position).Magnitude >= 150 == true then
            return;
        end;
        if p79.teamuse and (game.Players.LocalPlayer and game.Players.LocalPlayer.Team ~= p79.teamuse) then
            return;
        end;
        if p79.part:FindFirstChild("highlight_system") and (p79.part.highlight_system:FindFirstChild("ticker") and p79.part.highlight_system:FindFirstChild("duration")) then
            p79.part.highlight_system.OutlineColor = p79.colour
            p79.part.highlight_system.ticker.Value = tick()
            p79.part.highlight_system.duration.Value = p79.duration
            return;
        end;
        local v80 = game.ReplicatedStorage.misc.highlight_flash:Clone()
        v80.Name = "highlight_system"
        v80.OutlineColor = p79.colour
        local l_NumberValue_0 = Instance.new("NumberValue")
        l_NumberValue_0.Name = "ticker"
        l_NumberValue_0.Value = tick()
        l_NumberValue_0.Parent = v80
        local l_NumberValue_1 = Instance.new("NumberValue")
        l_NumberValue_1.Name = "duration"
        l_NumberValue_1.Value = p79.duration
        l_NumberValue_1.Parent = v80
        v80.Parent = p79.part
        tick()
        while true do
            if v80 == nil or (l_NumberValue_0 == nil or l_NumberValue_1 == nil) then
                return;
            end;
            v80.OutlineTransparency = v_u_30:lerp(0, 1, (tick() - l_NumberValue_0.Value) / l_NumberValue_1.Value)
            l_RenderStepped_0:Wait()
            if tick() - l_NumberValue_0.Value >= l_NumberValue_1.Value then
                if v80 then
                    v80:Destroy()
                end;
                break;
            end;
        end;
    else
        -- -- -- ::l2:: (Possible bug with goto) (Possible bug with goto) (Possible bug with goto)
        return;
    end;
end;
v_u_29.mort_smokefx = function(p81) --[[ Line: 691 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p81.point and p81.color then
        if (l_CurrentCamera_0.CFrame.Position - p81.point).Magnitude >= 150 == true then
            return;
        end;
        local v82 = game.ReplicatedStorage.effects.mortsmoke:Clone()
        s_Debris_0:AddItem(v82, 4)
        v82.CFrame = CFrame.new(p81.point) * CFrame.new(0, 1, 0)
        v82.Parent = workspace.notarget
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "smoke" .. math.random(1, 2),
            ["location"] = v82
        }, true)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "break" .. math.random(1, 3),
            ["location"] = v82
        }, true)
        for _, v83 in ipairs(v82:GetChildren()) do
            if not v83:IsA("Sound") then
                if v83.Name == "glass" then
                    v83.shards:Emit(math.random(8, 12))
                else
                    v83.Color = ColorSequence.new(p81.color)
                    if v83.Name == "smokelarge" then
                        v83:Emit(math.random(1, 2))
                    elseif v83.Name == "smokelinger" then
                        v83:Emit(math.random(2, 3))
                    else
                        v83:Emit(math.random(8, 12))
                    end;
                end;
            end;
        end;
    end;
end;
v_u_29.axe_bounce = function(p84) --[[ Line: 742 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_29, (copy 3): s_Debris_0, (copy 4): v_u_30 ]]
    if p84.point then
        if (l_CurrentCamera_0.CFrame.Position - p84.point).Magnitude >= 150 == true then
            return;
        end;
        v_u_29.mine_impact({
            ["point"] = p84.point
        })
        local v_u_85 = game.ReplicatedStorage.weapon_models.throwaxe:Clone()
        s_Debris_0:AddItem(v_u_85, 10)
        v_u_85:SetPrimaryPartCFrame(CFrame.new(p84.point) * CFrame.new(0, 0.5, 0))
        v_u_85.hitbox.CanCollide = true
        v_u_85.hitbox.CanTouch = true
        v_u_85.hitbox.CollisionGroup = "MiscCollision"
        v_u_85.Parent = workspace.notarget
        local v_u_86 = 4
        local v_u_87 = 0
        local v_u_88 = nil
        v_u_88 = v_u_85.hitbox.Touched:Connect(function(p89) --[[ Line: 766 ]]
            --[[ Upvalues: (ref 1): v_u_87, (copy 2): v_u_85, (ref 3): v_u_30, (ref 4): v_u_86, (ref 5): v_u_88 ]]
            if p89.CanQuery == true and (p89.CanCollide == true and tick() - v_u_87 >= 0.5) then
                v_u_87 = tick()
                if v_u_85 and v_u_85:FindFirstChild("hitbox") then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "metal" .. math.random(1, 3),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_85.hitbox
                    }, true)
                end;
                v_u_86 = v_u_86 - 1
                if v_u_86 <= 0 then
                    v_u_88:Disconnect()
                end;
            end;
        end)
        v_u_85.hitbox.Velocity = Vector3.new(math.random(-10, 10), math.random(10, 20), math.random(-10, 10))
        v_u_85.hitbox.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "wall_" .. math.random(1, 4),
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_85.hitbox
        }, true)
    end;
end;
v_u_29.arrow_bounce = function(p90) --[[ Line: 798 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_29, (copy 3): s_Debris_0, (copy 4): v_u_30 ]]
    if p90.point then
        if (l_CurrentCamera_0.CFrame.Position - p90.point).Magnitude >= 150 == true then
            return;
        end;
        v_u_29.mine_impact({
            ["point"] = p90.point
        })
        local v_u_91 = game.ReplicatedStorage.misc:FindFirstChild("brokenbolt" .. math.random(1, 2)):Clone()
        s_Debris_0:AddItem(v_u_91, 10)
        v_u_91.CFrame = CFrame.new(p90.point)
        v_u_91.CollisionGroup = "MiscCollision"
        v_u_91.Parent = workspace.notarget
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "arrow_impact_break",
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_91
        }, true)
        if p90.mat and (p90.mat == Enum.Material.Metal or p90.mat == Enum.Material.CorrodedMetal) then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "metalwall_" .. math.random(1, 4),
                ["pitchvariation"] = 0.1,
                ["volume_adjust"] = -0.2,
                ["pitch_adjust"] = 0.5,
                ["location"] = v_u_91
            }, true)
        end;
        if v_u_91.Name == "brokenbolt2" then
            local v92 = game.ReplicatedStorage.misc.brokenbolt2B:Clone()
            s_Debris_0:AddItem(v92, 10)
            v92.CFrame = CFrame.new(p90.point)
            v92.CollisionGroup = "MiscCollision"
            v92.Parent = workspace.notarget
            v92.Velocity = Vector3.new(math.random(-10, 10), math.random(2, 5), math.random(-10, 10))
            v92.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
        end;
        local v_u_93 = 4
        local v_u_94 = 0
        local v_u_95 = nil
        v_u_95 = v_u_91.Touched:Connect(function(p96) --[[ Line: 851 ]]
            --[[ Upvalues: (ref 1): v_u_94, (copy 2): v_u_91, (ref 3): v_u_30, (ref 4): v_u_93, (ref 5): v_u_95 ]]
            if p96.CanQuery == true and (p96.CanCollide == true and tick() - v_u_94 >= 0.5) then
                v_u_94 = tick()
                if v_u_91 then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "arrow_piece" .. math.random(1, 2),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_91
                    }, true)
                end;
                v_u_93 = v_u_93 - 1
                if v_u_93 <= 0 then
                    v_u_95:Disconnect()
                end;
            end;
        end)
        v_u_91.Velocity = Vector3.new(math.random(-10, 10), math.random(2, 5), math.random(-10, 10))
        v_u_91.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
    end;
end;
v_u_29.remington_bounce = function(p97) --[[ Line: 878 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_29, (copy 3): s_Debris_0, (copy 4): v_u_30 ]]
    if p97.point and p97.model then
        if (l_CurrentCamera_0.CFrame.Position - p97.point).Magnitude >= 150 == true then
            return;
        end;
        v_u_29.mine_impact({
            ["point"] = p97.point
        })
        local v_u_98 = p97.model:Clone()
        for _, v99 in ipairs(v_u_98:GetDescendants()) do
            if v99:IsA("BasePart") and v99.Transparency ~= 1 then
                v99.Transparency = 0
            end;
        end;
        local v_u_100 = v_u_98:FindFirstChild("hitbox") or v_u_98:FindFirstChild("unequipped")
        v_u_98.PrimaryPart = v_u_100
        s_Debris_0:AddItem(v_u_98, 10)
        v_u_98:SetPrimaryPartCFrame(CFrame.new(p97.point) * CFrame.new(0, 0.5, 0))
        v_u_100.CanCollide = true
        v_u_100.CanTouch = true
        v_u_100.CollisionGroup = "MiscCollision"
        local v_u_101
        if v_u_100:FindFirstChild("barrelpivot") and (v_u_98:FindFirstChild("parts") and v_u_98.parts:FindFirstChild("barrelpivot")) then
            v_u_101 = v_u_98.parts.barrelpivot:FindFirstChild("barrel")
            v_u_100.barrelpivot:Destroy()
        else
            v_u_101 = nil
        end;
        v_u_98.Parent = workspace.notarget
        local v_u_102 = tick()
        local v_u_103 = nil
        v_u_103 = v_u_100.Touched:Connect(function(p104) --[[ Line: 918 ]]
            --[[ Upvalues: (copy 1): v_u_102, (copy 2): v_u_98, (copy 3): v_u_100, (ref 4): v_u_30, (ref 5): v_u_103 ]]
            if p104.CanQuery == true and (p104.CanCollide == true and (p104.Transparency ~= 1 and tick() - v_u_102 >= 0.2)) then
                if v_u_98 and v_u_100 then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "clatter_small" .. math.random(1, 3),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_100
                    }, true)
                end;
                v_u_103:Disconnect()
            end;
        end)
        v_u_100.Velocity = Vector3.new(math.random(-10, 10), math.random(10, 20), math.random(-10, 10)) * 2
        v_u_100.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
        if v_u_101 then
            v_u_101.CanCollide = true
            v_u_101.CanTouch = true
            v_u_101.CollisionGroup = "MiscCollision"
            v_u_101.Velocity = Vector3.new(math.random(-10, 10), math.random(10, 20), math.random(-10, 10)) * 2
            v_u_101.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
            local v_u_105 = tick()
            local v_u_106 = nil
            v_u_106 = v_u_101.Touched:Connect(function(p107) --[[ Line: 944 ]]
                --[[ Upvalues: (copy 1): v_u_105, (ref 2): v_u_101, (ref 3): v_u_30, (ref 4): v_u_106 ]]
                if p107.CanQuery == true and (p107.CanCollide == true and (p107.Transparency ~= 1 and tick() - v_u_105 >= 0.2)) then
                    if v_u_101 then
                        v_u_30:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "clatter_small" .. math.random(1, 3),
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_101
                        }, true)
                    end;
                    v_u_106:Disconnect()
                end;
            end)
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "hit_surface" .. math.random(1, 3),
            ["pitchvariation"] = 0.1,
            ["location"] = v_u_100
        }, true)
    end;
end;
v_u_29.enfield_grenadebounce = function(p108) --[[ Line: 971 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p108.point then
        if (l_CurrentCamera_0.CFrame.Position - p108.point).Magnitude >= 150 == true then
            return;
        end;
        local v_u_109 = game.ReplicatedStorage.projectiles.riflenade:Clone()
        s_Debris_0:AddItem(v_u_109, 10)
        v_u_109.CFrame = CFrame.new(p108.point) * CFrame.new(0, 0.5, 0)
        v_u_109.Anchored = false
        v_u_109.trail:Destroy()
        v_u_109.CanCollide = true
        v_u_109.CanTouch = true
        v_u_109.CollisionGroup = "MiscCollision"
        v_u_109.Parent = workspace.notarget
        local v_u_110 = 4
        local v_u_111 = 0
        local v_u_112 = nil
        v_u_112 = v_u_109.Touched:Connect(function(p113) --[[ Line: 992 ]]
            --[[ Upvalues: (ref 1): v_u_111, (copy 2): v_u_109, (ref 3): v_u_30, (ref 4): v_u_110, (ref 5): v_u_112 ]]
            if p113.CanQuery == true and (p113.CanCollide == true and tick() - v_u_111 >= 0.5) then
                v_u_111 = tick()
                if v_u_109 then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "metal" .. math.random(1, 3),
                        ["pitchvariation"] = 0.1,
                        ["location"] = v_u_109
                    }, true)
                end;
                v_u_110 = v_u_110 - 1
                if v_u_110 <= 0 then
                    v_u_112:Disconnect()
                end;
            end;
        end)
        v_u_109.Velocity = Vector3.new(math.random(-10, 10), math.random(10, 20), math.random(-10, 10))
        v_u_109.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "metal" .. math.random(1, 3),
            ["pitchvariation"] = 0.1,
            ["volume_adjust"] = 1,
            ["location"] = v_u_109
        }, true)
    end;
end;
v_u_29.projectile_fire = function(p114) --[[ Line: 1025 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30 ]]
    local l_org_0 = p114.org
    local l_orgface_0 = p114.orgface
    local l_speed_0 = p114.speed
    local l_drop_0 = p114.drop
    local l_amtdrop_0 = p114.amtdrop
    local l_layermask_0 = p114.layermask
    local l_rooklauncher_0 = game.ReplicatedStorage.projectiles.rooklauncher
    local v115, v116
    if p114.wep and p114.wep == "stimbottle" then
        l_rooklauncher_0 = game.ReplicatedStorage.projectiles.bottle
        v115 = math.random(-60, 60)
        v116 = true
    else
        v115 = 0
        v116 = false
    end;
    if p114.wep and p114.wep == "throwaxe" then
        l_rooklauncher_0 = game.ReplicatedStorage.projectiles.throwaxe
        v116 = true
    end;
    if p114.wep and p114.wep == "enfield" then
        l_rooklauncher_0 = game.ReplicatedStorage.projectiles.riflenade
    end;
    if p114.wep and p114.wep == "remington" then
        l_rooklauncher_0 = game.ReplicatedStorage.projectiles.riflenade
        v116 = true
    end;
    if p114.wep and p114.wep == "crossbow" then
        l_rooklauncher_0 = game.ReplicatedStorage.projectiles.bolt
    end;
    local v117 = l_rooklauncher_0:Clone()
    s_Debris_0:AddItem(v117, 10)
    local v118
    if p114.wep and (p114.wep == "remington" and (p114.extra and p114.extra:FindFirstChild("hitbox"))) then
        v118 = p114.extra:Clone()
        local l_Weld_6 = Instance.new("Weld")
        l_Weld_6.Part0 = v118.hitbox
        l_Weld_6.Part1 = v117
        l_Weld_6.C1 = CFrame.Angles(0, -1.5707963267948966, 0)
        l_Weld_6.Parent = v118
        v118.Parent = v117
    else
        v118 = nil
    end;
    v117.Parent = workspace.notarget
    if v117:FindFirstChild("spin") then
        v117.spin:Play()
    end;
    for v119 = 1, 100 do
        local v120, v121 = v_u_30:raycastline({
            ["point"] = l_org_0,
            ["destination"] = l_orgface_0,
            ["range"] = l_speed_0,
            ["layermask"] = l_layermask_0
        })
        if v117 then
            v117.CFrame = CFrame.new(l_org_0, l_org_0 + l_orgface_0) * CFrame.Angles(math.rad(v115), 0, 0)
            if v116 == true then
                v115 = v115 - 10
            end;
        end;
        if v120 ~= nil then
            break;
        end;
        if l_drop_0 <= v119 then
            l_orgface_0 = l_orgface_0 - Vector3.new(0, l_amtdrop_0, 0)
        end;
        v_u_30:s_wait(0.03)
        l_org_0 = v121
    end;
    if v117:FindFirstChild("spin") then
        v117.spin:Stop()
    end;
    if v117 then
        if v118 then
            v118:Destroy()
        end;
        v117.part.Transparency = 1
        if v117:FindFirstChild("part2") then
            v117.part2.Transparency = 1
        end;
        if v117:FindFirstChild("part3") then
            v117.part3.Transparency = 1
        end;
        v117.Anchored = true
        s_Debris_0:AddItem(v117, 2)
    end;
end;
v_u_29.firebomb_fx = function(p_u_122) --[[ Line: 1139 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): l_RenderStepped_0, (copy 3): v_u_30 ]]
    if p_u_122.part then
        if (l_CurrentCamera_0.CFrame.Position - p_u_122.part.Position).Magnitude >= 150 == true then
            return;
        end;
        p_u_122.part.light.Enabled = true
        delay(0.1, function() --[[ Line: 1147 ]]
            --[[ Upvalues: (copy 1): p_u_122, (ref 2): l_RenderStepped_0 ]]
            if p_u_122.part and p_u_122.part:FindFirstChild("light") then
                tick()
                for _ = 1, 20 do
                    if p_u_122 == nil or (p_u_122.part == nil or p_u_122.part:FindFirstChild("light") == nil) then
                        return;
                    end;
                    local v123 = tick()
                    local l_light_0 = p_u_122.part.light
                    l_light_0.Brightness = l_light_0.Brightness - 0.05
                    repeat
                        l_RenderStepped_0:Wait()
                    until tick() - v123 >= 0.03;
                end;
            end;
        end)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "fire",
            ["location"] = p_u_122.part
        }, true)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "ignite",
            ["location"] = p_u_122.part
        }, true)
        p_u_122.part.embers:Emit(math.random(10, 20))
        p_u_122.part.fire_flash:Emit(1)
        p_u_122.part.shards:Emit(math.random(8, 10))
        p_u_122.part.fire_spread:Emit(math.random(10, 20))
    end;
end;
v_u_29.flamer_fx = function(p_u_124) --[[ Line: 1186 ]]
    --[[ Upvalues: (copy 1): v_u_30, (copy 2): l_RenderStepped_0, (copy 3): v_u_38, (copy 4): s_Debris_0 ]]
    if p_u_124 and (p_u_124.firehitbox and (p_u_124.beampart and (p_u_124.beampart:FindFirstChild("fire") and (p_u_124.muzzlepart and (p_u_124.muzzlepart:FindFirstChild("fire_heavy") and p_u_124.state))))) then
        if p_u_124.state ~= "start" then
            if p_u_124.state == "initialsmoke" then
                p_u_124.muzzlepart.smoke_initial:Emit(math.random(2, 4))
                p_u_124.muzzlepart.smoke_spray.Enabled = true
                if p_u_124.firehitbox:FindFirstChild("nozzleloop") then
                    p_u_124.firehitbox.nozzleloop:Play()
                    return;
                end;
            else
                if p_u_124.firehitbox:FindFirstChild("flameloop") then
                    p_u_124.firehitbox.flameloop:Stop()
                end;
                if p_u_124.firehitbox:FindFirstChild("nozzleloop") then
                    p_u_124.firehitbox.nozzleloop:Stop()
                end;
                p_u_124.muzzlepart.fire_heavy.Enabled = false
                p_u_124.muzzlepart.fire_heavy.LockedToPart = false
                p_u_124.muzzlepart.firebeam.Enabled = false
                p_u_124.beampart.fire.Enabled = false
                p_u_124.beampart.smoke.Enabled = false
                p_u_124.muzzlepart.smoke_spray.Enabled = false
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "end" .. math.random(1, 4),
                    ["pitchvariation"] = 0.1,
                    ["location"] = p_u_124.muzzlepart
                }, true)
                if _G.get_settings("lowgraphics") == true then
                    return;
                end;
                p_u_124.muzzlepart.residual.Enabled = true
                delay(math.random(20, 30) / 10, function() --[[ Line: 1324 ]]
                    --[[ Upvalues: (copy 1): p_u_124 ]]
                    if p_u_124 and (p_u_124.muzzlepart and (p_u_124.muzzlepart:FindFirstChild("residual") and (p_u_124.muzzlepart:FindFirstChild("fire_heavy") and p_u_124.muzzlepart.fire_heavy.Enabled == false))) then
                        p_u_124.muzzlepart.residual.Enabled = false
                    end;
                end)
            end;
            break;
        end;
        p_u_124.muzzlepart.initial:Emit(math.random(10, 20))
        p_u_124.muzzlepart.smoke_initial:Emit(math.random(2, 4))
        p_u_124.muzzlepart.fire_heavy.Enabled = true
        p_u_124.muzzlepart.firebeam.Enabled = true
        p_u_124.muzzlepart.fire_heavy.LockedToPart = true
        p_u_124.beampart.fire.Enabled = true
        p_u_124.beampart.smoke.Enabled = true
        p_u_124.muzzlepart.smoke_spray.Enabled = false
        if p_u_124.firehitbox:FindFirstChild("nozzleloop") then
            p_u_124.firehitbox.nozzleloop:Play()
        end;
        if p_u_124.firehitbox:FindFirstChild("flameloop") then
            p_u_124.firehitbox.flameloop:Play()
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "burst" .. math.random(1, 3),
            ["pitchvariation"] = 0.1,
            ["location"] = p_u_124.firehitbox
        }, true)
        local v125 = math.random(20, 40) / 10
        local v126 = 0
        local v127 = 0
        while true do
            l_RenderStepped_0:Wait()
            if v125 <= tick() - v126 then
                v126 = tick()
                v125 = math.random(20, 40) / 10
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "flames" .. math.random(1, 5),
                    ["pitchvariation"] = 0.1,
                    ["location"] = p_u_124.firehitbox
                }, true)
            end;
            local v128 = p_u_124.muzzlepart.Position - p_u_124.muzzlepart.CFrame.lookVector * 5 - p_u_124.muzzlepart.CFrame.rightVector * 0.5
            local v129, v130 = v_u_30:raycastline({
                ["point"] = v128,
                ["destination"] = p_u_124.muzzlepart.CFrame.lookVector,
                ["range"] = 45,
                ["flamer"] = true,
                ["layermask"] = v_u_38
            })
            if v129 and (_G.get_settings("lowgraphics") ~= true and tick() - v127 >= 0.1) then
                v127 = tick()
                local v_u_131 = game.ReplicatedStorage.effects.flamerresidue:Clone()
                s_Debris_0:AddItem(v_u_131, 2)
                v_u_131.CFrame = CFrame.new(v130)
                v_u_131.Parent = workspace.notarget
                delay(math.random(10, 15) / 10, function() --[[ Line: 1255 ]]
                    --[[ Upvalues: (copy 1): v_u_131 ]]
                    if v_u_131 and v_u_131:FindFirstChild("flame") then
                        v_u_131.flame.Enabled = false
                    end;
                end)
            end;
            if p_u_124.beampart and (p_u_124.beampart:FindFirstChild("beamweld") and (p_u_124.muzzlepart:FindFirstChild("fire_heavy") and (p_u_124.firehitbox and p_u_124.firehitbox:FindFirstChild("hitboxweld")))) then
                local l_Magnitude_0 = (v128 - v130).Magnitude
                p_u_124.beampart.Size = p_u_124.beampart.Size:Lerp(Vector3.new(0.4, 0.4, l_Magnitude_0), 0.1)
                p_u_124.beampart.beamweld.C0 = p_u_124.beampart.beamweld.C0:Lerp(CFrame.new(0, 0, -l_Magnitude_0 / 2 - 2 - 5), 0.1)
                p_u_124.firehitbox.Size = Vector3.new(3, 3, l_Magnitude_0 + 2.5 - 4)
                p_u_124.firehitbox.hitboxweld.C0 = CFrame.new(0, 0, -l_Magnitude_0 / 2 + 2)
                p_u_124.muzzlepart.fire_heavy.Speed = NumberRange.new(l_Magnitude_0 * 2)
                p_u_124.muzzlepart.a1.Position = Vector3.new(0, 0, -l_Magnitude_0 - 5)
            end;
            if p_u_124 == nil or (p_u_124.muzzlepart == nil or (p_u_124.muzzlepart:FindFirstChild("fire_heavy") == nil or p_u_124.muzzlepart.fire_heavy.Enabled == false)) then
                break;
            end;
        end;
    else
        -- -- -- ::l2:: (Possible bug with goto) (Possible bug with goto) (Possible bug with goto)
        return;
    end;
end;
v_u_29.explosion_fx = function(p_u_132) --[[ Line: 1367 ]]
    --[[ Upvalues: (copy 1): v_u_30, (copy 2): l_CurrentCamera_0, (copy 3): v_u_29 ]]
    if p_u_132.part then
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "distant" .. math.random(1, 3),
            ["location"] = p_u_132.part
        }, true)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "debris" .. math.random(1, 3),
            ["location"] = p_u_132.part
        }, true)
        if p_u_132.enfield_gl and p_u_132.enfield_gl == true then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "explosion",
                ["location"] = p_u_132.part
            }, true)
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "shrapnel",
                ["location"] = p_u_132.part
            }, true)
        elseif p_u_132.atgrenade and p_u_132.atgrenade == true then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "at_explosion",
                ["pitchvariation"] = 0.1,
                ["location"] = p_u_132.part
            }, true)
        else
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "shrapnel",
                ["location"] = p_u_132.part
            }, true)
            if p_u_132.mined == true then
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "explosion",
                    ["location"] = p_u_132.part
                }, true)
            end;
        end;
        if (l_CurrentCamera_0.CFrame.Position - p_u_132.part.Position).Magnitude >= 150 == true then
            return;
        end;
        p_u_132.part.light.Enabled = true
        delay(0.05, function() --[[ Line: 1425 ]]
            --[[ Upvalues: (copy 1): p_u_132 ]]
            if p_u_132.part and p_u_132.part:FindFirstChild("light") then
                p_u_132.part.light.Enabled = false
            end;
        end)
        for _ = 1, 1 do
            p_u_132.part.smoke:Emit(math.random(8, 15))
            p_u_132.part.smoke2:Emit(math.random(1, 2))
            p_u_132.part.smokelinger:Emit(math.random(4, 6))
            p_u_132.part.sparks:Emit(math.random(10, 20))
        end;
        if p_u_132.atgrenade and p_u_132.atgrenade == true then
            p_u_132.part.fire_flash:Emit(2)
            p_u_132.part.smoke_large:Emit(3)
            v_u_29.mine_impact({
                ["normal"] = p_u_132.part.CFrame.upVector,
                ["point"] = p_u_132.part.Position
            })
        end;
        if p_u_132.part and (p_u_132.part:FindFirstChild("light") and (p_u_132.mined and p_u_132.mined == false)) then
            for _ = 1, math.random(2, 4) do
                v_u_29.ricochet_effect({
                    ["normal"] = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)),
                    ["center_part"] = p_u_132.part,
                    ["rico"] = math.random(1, 3)
                })
            end;
        end;
    end;
end;
v_u_29.tinbomb_fx = function(p_u_133) --[[ Line: 1470 ]]
    --[[ Upvalues: (copy 1): v_u_30, (copy 2): l_CurrentCamera_0, (copy 3): v_u_29, (copy 4): l_RenderStepped_0 ]]
    if p_u_133.part then
        if p_u_133.namefor and p_u_133.namefor == "Dynamite Stack" then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "explosion",
                ["location"] = p_u_133.part
            }, true)
        else
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "explosion",
                ["location"] = p_u_133.part
            }, true)
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "distant" .. math.random(1, 3),
            ["location"] = p_u_133.part
        }, true)
        if (l_CurrentCamera_0.CFrame.Position - p_u_133.part.Position).Magnitude >= 150 == true then
            return;
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "debris" .. math.random(1, 3),
            ["location"] = p_u_133.part
        }, true)
        p_u_133.part.light.Enabled = true
        delay(0.05, function() --[[ Line: 1506 ]]
            --[[ Upvalues: (copy 1): p_u_133 ]]
            if p_u_133.part and p_u_133.part:FindFirstChild("light") then
                p_u_133.part.light.Enabled = false
            end;
        end)
        p_u_133.part.smoke:Emit(math.random(8, 15))
        p_u_133.part.smokelinger:Emit(math.random(3, 5))
        p_u_133.part.sparks:Emit(math.random(10, 20))
        if p_u_133.part and p_u_133.part:FindFirstChild("light") then
            for _ = 1, math.random(6, 8) do
                v_u_29.ricochet_effect({
                    ["normal"] = p_u_133.part.CFrame.lookVector + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)),
                    ["center_part"] = p_u_133.part,
                    ["rico"] = 2
                })
                l_RenderStepped_0:Wait()
            end;
        end;
    end;
end;
v_u_29.throw_ammopack = function(p_u_134) --[[ Line: 1529 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30, (copy 3): l_RenderStepped_0 ]]
    if p_u_134.startpoint and p_u_134.maxrange then
        local l_ammopouch_0 = game.ReplicatedStorage.misc.ammopouch
        if p_u_134.medical_stim and p_u_134.medical_stim == true then
            l_ammopouch_0 = game.ReplicatedStorage.misc.medicalheal
        end;
        local v_u_135 = l_ammopouch_0:Clone()
        s_Debris_0:AddItem(v_u_135, 1)
        v_u_135.Anchored = true
        v_u_135.CollisionGroup = "MiscCollision"
        v_u_135.CanCollide = true
        v_u_135.CFrame = p_u_134.startpoint
        v_u_135.Parent = workspace.notarget
        spawn(function() --[[ Line: 1547 ]]
            --[[ Upvalues: (copy 1): p_u_134, (ref 2): v_u_30, (copy 3): v_u_135, (ref 4): l_RenderStepped_0 ]]
            local l_endpoint_0 = p_u_134.endpoint
            local v136 = v_u_30:lerp(0.1, 0.5, p_u_134.range / p_u_134.maxrange)
            local v137 = tick()
            while v_u_135 ~= nil do
                if p_u_134.target then
                    l_endpoint_0 = p_u_134.target.Position
                end;
                if l_endpoint_0 == nil then
                    return;
                end;
                local v138 = (tick() - v137) / v136
                v_u_135.CFrame = CFrame.new((1 - v138) ^ 2 * p_u_134.startpoint.Position + 2 * (1 - v138) * v138 * (p_u_134.startpoint.Position + p_u_134.startpoint.LookVector * (p_u_134.range / 2) + CFrame.new().UpVector * 2) + v138 ^ 2 * l_endpoint_0) * p_u_134.addon
                l_RenderStepped_0:Wait()
                if v136 <= tick() - v137 then
                    local v139 = tick()
                    local v140 = 0.5
                    while v_u_135 ~= nil do
                        if p_u_134.target then
                            l_endpoint_0 = p_u_134.target.Position
                        end;
                        if l_endpoint_0 == nil then
                            return;
                        end;
                        v_u_135.CFrame = CFrame.new(l_endpoint_0) * p_u_134.addon
                        l_RenderStepped_0:Wait()
                        if v140 <= tick() - v139 then
                            v_u_135:Destroy()
                            return;
                        end;
                    end;
                    return;
                end;
            end;
        end)
    end;
end;
v_u_29.ammo_stock = function(p_u_141) --[[ Line: 1598 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p_u_141 and (p_u_141.anim and (p_u_141.char and (p_u_141.char:FindFirstChild("Torso") and (p_u_141.char:FindFirstChild("Humanoid") and (p_u_141.char.Humanoid.Health > 0 and (p_u_141.char:FindFirstChild("Left Arm") and p_u_141.char:FindFirstChild("Right Arm"))))))) then
        if (l_CurrentCamera_0.CFrame.Position - p_u_141.char.Torso.Position).Magnitude >= 150 == true then
            return;
        end;
        local v142 = p_u_141.char:FindFirstChild("Left Arm")
        if p_u_141.anim == "ammo_restock_right" then
            v142 = p_u_141.char:FindFirstChild("Right Arm")
        end;
        local l_ammopouch_1 = game.ReplicatedStorage.misc.ammopouch
        local v143
        if p_u_141.stim and p_u_141.stim == true then
            l_ammopouch_1 = game.ReplicatedStorage.misc.medicalheal
            v143 = 8
        else
            v143 = 1
        end;
        local v_u_144 = l_ammopouch_1:Clone()
        s_Debris_0:AddItem(v_u_144, v143)
        local l_Weld_7 = Instance.new("Weld")
        l_Weld_7.Part0 = v142
        l_Weld_7.Part1 = v_u_144
        l_Weld_7.C0 = CFrame.new(0.535736084, -0.702087402, -0.0757308006, -0.0301536899, 0.171010092, -0.984807909, 0.171009973, -0.969845712, -0.173648074, -0.984806657, -0.173648, 0)
        if p_u_141.stim == true then
            l_Weld_7.C0 = CFrame.new(0.456132889, -1.10497975, -0.280231476, 0, 0, -1, 0, -0.99999994, 0, -1, 0, 0)
            if p_u_141.anim == "mortheal_right" then
                l_Weld_7.C0 = CFrame.new(-0.457790375, -1.10497952, -0.280231476, 0, 0, -1, 0, -0.999999821, 0, -1, 0, 0)
            end;
            delay(0.25, function() --[[ Line: 1632 ]]
                --[[ Upvalues: (copy 1): p_u_141, (ref 2): v_u_30 ]]
                if p_u_141 ~= nil and (p_u_141.anim ~= nil and (p_u_141.char ~= nil and (p_u_141.char:FindFirstChild("Torso") ~= nil and (p_u_141.char:FindFirstChild("Humanoid") ~= nil and (p_u_141.char.Humanoid.Health > 0 and (p_u_141.char:FindFirstChild("Left Arm") ~= nil and p_u_141.char:FindFirstChild("Right Arm") ~= nil)))))) then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "insert",
                        ["location"] = p_u_141.char.Torso
                    }, true)
                end;
            end)
            delay(0.7, function() --[[ Line: 1642 ]]
                --[[ Upvalues: (copy 1): p_u_141, (ref 2): v_u_30 ]]
                if p_u_141 ~= nil and (p_u_141.anim ~= nil and (p_u_141.char ~= nil and (p_u_141.char:FindFirstChild("Torso") ~= nil and (p_u_141.char:FindFirstChild("Humanoid") ~= nil and (p_u_141.char.Humanoid.Health > 0 and (p_u_141.char:FindFirstChild("Left Arm") ~= nil and p_u_141.char:FindFirstChild("Right Arm") ~= nil)))))) then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "remove",
                        ["location"] = p_u_141.char.Torso
                    }, true)
                end;
            end)
        end;
        if p_u_141.anim == "ammo_restock_right" then
            l_Weld_7.C0 = CFrame.new(-0.56237793, -0.678955078, -0.0479879379, -0.0301536582, 0.171009988, 0.98480767, 0.171009973, -0.969846129, 0.173647881, 0.984806657, 0.173648074, 0)
        end;
        l_Weld_7.Parent = v_u_144
        v_u_144.Parent = workspace.notarget
        delay(0.8, function() --[[ Line: 1662 ]]
            --[[ Upvalues: (copy 1): p_u_141, (ref 2): v_u_30, (ref 3): l_ammopouch_1, (copy 4): l_Weld_7, (copy 5): v_u_144 ]]
            if p_u_141 and (p_u_141.anim and (p_u_141.char and (p_u_141.char:FindFirstChild("Torso") and (p_u_141.char:FindFirstChild("Humanoid") and (p_u_141.char.Humanoid.Health > 0 and (p_u_141.char:FindFirstChild("Left Arm") and p_u_141.char:FindFirstChild("Right Arm"))))))) then
                if p_u_141.stim and p_u_141.stim == true then
                    v_u_30:s_wait(0.1)
                    l_ammopouch_1.CollisionGroup = "MiscCollision"
                    l_ammopouch_1.CanCollide = true
                    l_Weld_7:Destroy()
                    return;
                end;
                v_u_144:Destroy()
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "riflepouch" .. math.random(1, 2),
                    ["pitchvariation"] = 0.1,
                    ["location"] = p_u_141.char.Torso
                }, true)
            end;
        end)
    end;
end;
v_u_29.blood_drip = function(p145) --[[ Line: 1691 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_30, (copy 3): v_u_29, (copy 4): s_Debris_0 ]]
    if not _G.get_settings or _G.get_settings("disableblood") ~= true then
        if p145.part then
            if (l_CurrentCamera_0.CFrame.Position - p145.part.Position).Magnitude >= 150 == true then
                return;
            end;
            if p145.part:FindFirstChild("attach") == nil then
                local l_Attachment_1 = Instance.new("Attachment")
                l_Attachment_1.Name = "attach"
                l_Attachment_1.Parent = p145.part
            end;
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "drip" .. math.random(1, 5),
                ["pitchvariation"] = 0.1,
                ["location"] = p145.part
            }, true)
            local l_attach_0 = p145.part.attach
            tick()
            local v146 = math.random(8, 20)
            v_u_29.blood_floor({
                ["part"] = p145.part
            })
            local v147 = 0.12 * v146 + 10
            local v148 = false
            local v149 = nil
            for v150 = 1, v146 do
                if p145.part == nil then
                    return;
                end;
                tick()
                if v146 >= 16 and (v150 >= 12 and (v148 == false and p145.part)) then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "drip" .. math.random(1, 5),
                        ["pitchvariation"] = 0.1,
                        ["location"] = p145.part
                    }, true)
                    v_u_29.blood_floor({
                        ["part"] = p145.part
                    })
                    v148 = true
                end;
                if p145.part == nil then
                    return;
                end;
                local v_u_151 = game.ReplicatedStorage.effects.blooddrip:Clone()
                s_Debris_0:AddItem(v_u_151, v147 - 0.12 * v150)
                v_u_151.CollisionGroup = "MiscCollision"
                v_u_151.CFrame = p145.part.CFrame
                v_u_151.bloodbeam.Attachment0 = v_u_151.attach
                v_u_151.bloodbeam.Attachment1 = l_attach_0
                local v_u_152 = nil
                v_u_152 = v_u_151.Touched:Connect(function(p153) --[[ Line: 1765 ]]
                    --[[ Upvalues: (copy 1): v_u_151, (ref 2): v_u_152 ]]
                    if p153 and (p153.CanQuery == true and (p153.CanCollide == true and (p153:IsDescendantOf(workspace.notarget) ~= true and (p153:IsDescendantOf(workspace.bodies) ~= true and (p153:IsDescendantOf(workspace.nation_team) ~= true and p153:IsDescendantOf(workspace.empire_team) ~= true))))) then
                        v_u_151.Anchored = true
                        v_u_152:Disconnect()
                    end;
                end)
                v_u_151.Parent = workspace.notarget
                if v149 then
                    v149.bloodbeam.Attachment1 = v_u_151.attach
                end;
                l_attach_0 = v_u_151.attach
                v_u_30:s_wait(0.12)
                v149 = v_u_151
            end;
        end;
    end;
end;
v_u_29.blood_floor_loop = function(p154) --[[ Line: 1803 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_29, (copy 3): v_u_30 ]]
    if p154.part and p154.count then
        if (l_CurrentCamera_0.CFrame.Position - p154.part.Position).Magnitude >= 150 == true then
            return;
        end;
        for _ = 1, p154.count do
            if p154.part and (p154.part ~= nil and p154.part.Parent) then
                v_u_29.blood_floor(p154)
            end;
            v_u_30:s_wait(math.random(10, 20) / 10)
        end;
    end;
end;
v_u_29.blood_floordrip = function(p155) --[[ Line: 1823 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0 ]]
    if not _G.get_settings or _G.get_settings("disableblood") ~= true then
        if p155.where and p155.normal then
            if (l_CurrentCamera_0.CFrame.Position - p155.where).Magnitude >= 150 == true then
                return;
            end;
            local v156 = game.ReplicatedStorage.effects:FindFirstChild("floorblood" .. math.random(1, 2)):Clone()
            s_Debris_0:AddItem(v156, 23)
            v156.CFrame = CFrame.new(p155.where, p155.where + p155.normal) * CFrame.Angles(0, 0, (math.rad((math.random(0, 360)))))
            v156.Parent = workspace.notarget
            v156.blood:Emit(1)
        end;
    end;
end;
v_u_29.blood_floor = function(p157) --[[ Line: 1845 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_30, (copy 3): v_u_38, (copy 4): v_u_29 ]]
    if not _G.get_settings or _G.get_settings("disableblood") ~= true then
        if p157.part then
            if (l_CurrentCamera_0.CFrame.Position - p157.part.Position).Magnitude >= 150 == true then
                return;
            end;
            local v158, v159, v160 = v_u_30:raycastline({
                ["point"] = p157.part.Position,
                ["destination"] = -CFrame.new(p157.part.Position).UpVector,
                ["range"] = 10,
                ["layermask"] = v_u_38
            })
            if v158 then
                v_u_29.blood_floordrip({
                    ["where"] = v159,
                    ["normal"] = v160
                })
            end;
        end;
    end;
end;
v_u_29.bloodsmall = function(p161) --[[ Line: 1875 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0 ]]
    if (l_CurrentCamera_0.CFrame.Position - p161.position).Magnitude >= 150 ~= true then
        local v162 = game.ReplicatedStorage.effects.bloodsmall:Clone()
        s_Debris_0:AddItem(v162, 3)
        v162.CFrame = CFrame.new(p161.position)
        v162.Parent = workspace.notarget
        if p161.small ~= true then
            v162.flash:Emit(1)
            v162.med:Emit(1)
        end;
        v162.med_bits:Emit(math.random(10, 20))
        return v162;
    end;
end;
v_u_29.bullet_hole = function(p163) --[[ Line: 1896 ]]
    --[[ Upvalues: (copy 1): s_Debris_0 ]]
    if _G.get_settings("lowgraphics") == true then
        return;
    else
        local v164 = game.ReplicatedStorage.effects.bullethole:Clone()
        local v165
        if p163.targetrange and p163.targetrange == true then
            v164.hole.Color3 = Color3.fromRGB(150, 150, 150)
            v165 = 120
        else
            v165 = 8
        end;
        if p163.glass and p163.glass == true then
            v164.hole.Texture = "rbxassetid://6552137211"
            v164.Size = Vector3.new(0.5, 0.5, 0.01)
            v165 = 60
        end;
        s_Debris_0:AddItem(v164, v165)
        v164.CFrame = CFrame.new(p163.pos, p163.pos + p163.normal)
        if p163.moving and p163.hit then
            local l_WeldConstraint_0 = Instance.new("WeldConstraint")
            l_WeldConstraint_0.Enabled = true
            l_WeldConstraint_0.Part0 = p163.hit
            l_WeldConstraint_0.Part1 = v164
            v164.Anchored = false
            l_WeldConstraint_0.Parent = v164
        end;
        if p163.forceparent then
            v164.Parent = p163.forceparent
        else
            v164.Parent = workspace.notarget
        end;
    end;
end;
v_u_29.destructionfx = function(p166) --[[ Line: 1960 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if (l_CurrentCamera_0.CFrame.Position - p166.point).Magnitude >= 150 ~= true then
        local v167 = game.ReplicatedStorage.effects.destructionfx:Clone()
        s_Debris_0:AddItem(v167, 4)
        v167.CFrame = CFrame.new(p166.point)
        v167.Parent = workspace.notarget
        local v168 = "destroy" .. math.random(1, 3)
        if p166.subtle == nil then
            if p166.metalpart then
                v167.metalshard:Emit(math.random(8, 15))
                v168 = "destroy_metal" .. math.random(1, 3)
            elseif p166.sandpart then
                v167.sandfx:Emit(math.random(10, 15))
                v168 = "sand_destroy" .. math.random(1, 2)
            else
                v167.woodchip1:Emit(math.random(5, 10))
                v167.woodchip2:Emit(math.random(5, 10))
                v167.woodchip3:Emit(math.random(5, 10))
            end;
        else
            v168 = "destroy_subtle" .. math.random(1, 3)
            v167.Size = Vector3.new(1, 1, 1)
            if p166.metalpart == nil then
                v167.woodchip1:Emit(math.random(1, 3))
                v167.woodchip2:Emit(math.random(1, 3))
                v167.woodchip3:Emit(math.random(1, 3))
            else
                v167.metalshard:Emit(math.random(2, 4))
            end;
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = v168,
            ["pitchvariation"] = 0.1,
            ["location"] = v167
        }, true)
    end;
end;
v_u_29.bloodhitmarker_fx = function(p169) --[[ Line: 2011 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30, (copy 3): l_RenderStepped_0 ]]
    if p169.position then
        local v170 = game.ReplicatedStorage.misc.bloodhitmarker:Clone()
        s_Debris_0:AddItem(v170, 2)
        v170.CFrame = p169.position
        v170.bb.img.Rotation = math.random(0, 360)
        v170.Parent = workspace.notarget
        local v171 = tick()
        repeat
            v170.bb.img.ImageTransparency = v_u_30:lerp(0, 1, (tick() - v171) / 1)
            l_RenderStepped_0:Wait()
        until tick() - v171 >= 1;
        v170:Destroy()
    end;
end;
v_u_29.deathfx = function(p_u_172) --[[ Line: 2036 ]]
    --[[ Upvalues: (ref 1): v_u_31, (copy 2): v_u_30, (copy 3): v_u_29, (ref 4): v_u_32, (ref 5): v_u_33 ]]
    if not _G.get_settings or _G.get_settings("disablegore") ~= true then
        if p_u_172.char and (p_u_172.char:FindFirstChild("HumanoidRootPart") and p_u_172.limb) then
            local v173 = p_u_172.char:FindFirstChild(p_u_172.limb)
            if v173 and (v173.Transparency ~= 1 or v173.Name == "HeadHitbox") then
                if tick() - v_u_31 >= 0.1 then
                    v_u_31 = tick()
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "dismember" .. math.random(1, 4),
                        ["pitchvariation"] = 0.1,
                        ["location"] = p_u_172.char.Torso
                    }, true)
                end;
                local v174 = v173:FindFirstChild("dirtoverlay")
                if v174 then
                    v174:Destroy()
                end;
                local v175 = v173:FindFirstChild("dirtoverlay2")
                if v175 then
                    v175:Destroy()
                end;
                local v176 = v173:FindFirstChild("bloodoverlay")
                if v176 then
                    v176:Destroy()
                end;
                local v177 = v173:FindFirstChild("bloodoverlay2")
                if v177 then
                    v177:Destroy()
                end;
                if v173.Name ~= "Torso" then
                    local v178 = p_u_172.char:FindFirstChild("accessories")
                    if v178 then
                        for _, v179 in ipairs(v178:GetChildren()) do
                            if v179:FindFirstChild("limb") and v179.limb.Value == v173.Name then
                                v179:Destroy()
                            end;
                        end;
                    end;
                end;
                if v173.Name == "Left Arm" or (v173.Name == "Right Arm" or (v173.Name == "Right Leg" or v173.Name == "Left Leg")) then
                    v173.Transparency = 1
                    v173.Locked = true
                    local v180 = math.random(1, 4)
                    if p_u_172.rand1 then
                        v180 = p_u_172.rand1
                    end;
                    local v_u_181 = game.ReplicatedStorage.death_fx:FindFirstChild(((v173.Name == "Left Arm" or v173.Name == "Left Leg") and "leftgib" or "rightgib") .. math.random(1, 3)):Clone()
                    v_u_181.CollisionGroup = "MiscCollision"
                    delay(math.random(5, 10) / 10, function() --[[ Line: 2105 ]]
                        --[[ Upvalues: (copy 1): v_u_181 ]]
                        if v_u_181 and v_u_181:FindFirstChild("attach") then
                            v_u_181.attach.fx.Enabled = false
                        end;
                    end)
                    if v173.Name == "Left Arm" or v173.Name == "Right Arm" then
                        local v182 = p_u_172.char:FindFirstChildOfClass("Shirt")
                        if v182 then
                            v_u_181.TextureID = v182.ShirtTemplate
                        end;
                    else
                        local v183 = p_u_172.char:FindFirstChildOfClass("Pants")
                        if v183 then
                            v_u_181.TextureID = v183.PantsTemplate
                        end;
                    end;
                    v_u_181.CFrame = v173.CFrame * CFrame.Angles(math.rad((math.random(0, 360))), math.rad((math.random(0, 360))), (math.rad((math.random(0, 360)))))
                    v_u_181.Parent = p_u_172.char
                    v_u_181.Velocity = v_u_181.Velocity + Vector3.new(math.random(-15, 15), math.random(10, 20), math.random(-15, 15))
                    v_u_181.RotVelocity = v_u_181.RotVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
                    if v180 == 1 then
                        v_u_29.blood_impact({
                            ["point"] = CFrame.new(v173.Position) * CFrame.Angles(math.rad((math.random(0, 360))), math.rad((math.random(0, 360))), (math.rad((math.random(0, 360))))),
                            ["headshot"] = true
                        })
                        local v_u_184 = game.ReplicatedStorage.death_fx.torsofx:Clone()
                        v_u_184.CFrame = p_u_172.char.Torso.CFrame
                        v_u_184.BrickColor = p_u_172.char.Torso.BrickColor
                        v_u_184.Parent = p_u_172.char
                        delay(math.random(10, 30) / 10, function() --[[ Line: 2142 ]]
                            --[[ Upvalues: (copy 1): v_u_184 ]]
                            if v_u_184 and v_u_184:FindFirstChild("attach") then
                                v_u_184.attach.fx.Enabled = false
                            end;
                        end)
                        local l_Weld_8 = Instance.new("Weld")
                        l_Weld_8.Part0 = v_u_184
                        l_Weld_8.Part1 = p_u_172.char.Torso
                        if v173.Name == "Right Arm" then
                            l_Weld_8.C1 = CFrame.Angles(0, 3.141592653589793, 0)
                        elseif v173.Name == "Left Leg" then
                            l_Weld_8.C1 = CFrame.Angles(0, 0, 1.5707963267948966)
                        elseif v173.Name == "Right Leg" then
                            l_Weld_8.C1 = CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(3.141592653589793, 0, 0)
                        end;
                        l_Weld_8.Parent = v_u_184
                    else
                        local v_u_185 = game.ReplicatedStorage.death_fx:FindFirstChild((v173.Name == "Left Arm" or v173.Name == "Left Leg") and "left" or "right"):Clone()
                        v_u_185.CFrame = v173.CFrame
                        v_u_185.part1.BrickColor = v173.BrickColor
                        if v173.Name == "Left Arm" or v173.Name == "Right Arm" then
                            local v186 = p_u_172.char:FindFirstChildOfClass("Shirt")
                            if v186 then
                                v_u_185.part1.TextureID = v186.ShirtTemplate
                            end;
                        else
                            local v187 = p_u_172.char:FindFirstChildOfClass("Pants")
                            if v187 then
                                v_u_185.part1.TextureID = v187.PantsTemplate
                            end;
                        end;
                        v_u_185.Parent = p_u_172.char
                        local l_Weld_9 = Instance.new("Weld")
                        l_Weld_9.Part0 = v_u_185
                        l_Weld_9.Part1 = v173
                        l_Weld_9.Parent = v_u_185
                        delay(math.random(10, 30) / 10, function() --[[ Line: 2189 ]]
                            --[[ Upvalues: (copy 1): v_u_185 ]]
                            if v_u_185 and v_u_185:FindFirstChild("attach") then
                                v_u_185.attach.fx.Enabled = false
                            end;
                        end)
                    end;
                end;
                if v173.Name == "Torso" then
                    v173.Transparency = 1
                    v_u_29.blood_impact({
                        ["point"] = CFrame.new(v173.Position) * CFrame.Angles(math.rad((math.random(0, 360))), math.rad((math.random(0, 360))), (math.rad((math.random(0, 360))))),
                        ["headshot"] = true
                    })
                    local v188 = math.random(1, 3)
                    if p_u_172.rand2 then
                        v188 = p_u_172.rand2
                    end;
                    if p_u_172.explosion and p_u_172.explosion == true then
                        local v_u_189 = {
                            "Left Arm",
                            "Left Leg",
                            "Right Arm",
                            "Right Leg"
                        }
                        spawn(function() --[[ Line: 2215 ]]
                            --[[ Upvalues: (copy 1): v_u_189, (copy 2): p_u_172, (ref 3): v_u_29 ]]
                            for _ = 1, 4 do
                                local v190 = v_u_189[math.random(1, 4)]
                                if p_u_172.char:FindFirstChild(v190) and p_u_172.char:FindFirstChild(v190).Transparency == 0 then
                                    v_u_29.deathfx({
                                        ["char"] = p_u_172.char,
                                        ["limb"] = v190
                                    })
                                end;
                            end;
                        end)
                        if math.random(1, 2) == 1 then
                            if tick() - v_u_32 >= 0.2 then
                                v_u_32 = tick()
                                v_u_30:soundHandler({
                                    ["directory"] = {},
                                    ["soundfile"] = "gib",
                                    ["pitchvariation"] = 0.3,
                                    ["location"] = p_u_172.char.Torso
                                }, true)
                            end;
                            v188 = 5
                            for _ = 1, math.random(2, 5) do
                                local v191 = game.ReplicatedStorage.death_fx.bloodline:Clone()
                                v191:SetPrimaryPartCFrame(p_u_172.char.Torso.CFrame * CFrame.new(math.random(-10, 10) / 5, math.random(1, 10) / 5, math.random(-10, 10) / 5))
                                v191.part1.CollisionGroup = "MiscCollision"
                                v191.part2.CollisionGroup = "MiscCollision"
                                v191.Parent = p_u_172.char
                                v191.part2.Velocity = v191.part2.Velocity + Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20)) * 2
                            end;
                            for _ = 1, math.random(2, 5) do
                                local v192 = game.ReplicatedStorage.death_fx.gibpiece:Clone()
                                v192.CollisionGroup = "MiscCollision"
                                v192.CFrame = p_u_172.char.Torso.CFrame * CFrame.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10)
                                v192.Parent = p_u_172.char
                                v192.Velocity = v192.Velocity + Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20)) * 2
                            end;
                        end;
                    end;
                    local v_u_193 = game.ReplicatedStorage.death_fx:FindFirstChild("torso" .. v188):Clone()
                    v_u_193.CFrame = p_u_172.char.Torso.CFrame
                    v_u_193.main.BrickColor = p_u_172.char.Torso.BrickColor
                    v_u_193.Parent = v173
                    if v_u_193:FindFirstChild("attach") then
                        delay(math.random(3, 6), function() --[[ Line: 2265 ]]
                            --[[ Upvalues: (copy 1): v_u_193 ]]
                            if v_u_193 and v_u_193:FindFirstChild("attach") then
                                v_u_193.attach.fx.Enabled = false
                            end;
                        end)
                    end;
                    local v194 = p_u_172.char:FindFirstChildOfClass("Shirt")
                    if v194 then
                        v_u_193.main.TextureID = v194.ShirtTemplate
                    end;
                    local l_Weld_10 = Instance.new("Weld")
                    l_Weld_10.Part0 = v_u_193
                    l_Weld_10.Part1 = p_u_172.char.Torso
                    l_Weld_10.Parent = v_u_193
                    if v188 == 5 then
                        local v195 = p_u_172.char.Torso:FindFirstChild("Left Hip")
                        local v196 = p_u_172.char.Torso:FindFirstChild("Right Hip")
                        if v195 then
                            v195:Destroy()
                            if p_u_172.char.Torso:FindFirstChild("Left Hip_BSC") then
                                p_u_172.char.Torso:FindFirstChild("Left Hip_BSC"):Destroy()
                            end;
                            local l_Left Leg_0 = p_u_172.char["Left Leg"]
                            if l_Left Leg_0 then
                                l_Left Leg_0.Velocity = l_Left Leg_0.Velocity + Vector3.new(math.random(-15, 15), math.random(10, 20), math.random(-15, 15))
                                l_Left Leg_0.RotVelocity = l_Left Leg_0.RotVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
                            end;
                        end;
                        if v196 then
                            v196:Destroy()
                            if p_u_172.char.Torso:FindFirstChild("Right Hip_BSC") then
                                p_u_172.char.Torso:FindFirstChild("Right Hip_BSC"):Destroy()
                            end;
                            local l_Right Leg_0 = p_u_172.char["Right Leg"]
                            if l_Right Leg_0 then
                                l_Right Leg_0.Velocity = l_Right Leg_0.Velocity + Vector3.new(math.random(-15, 15), math.random(10, 20), math.random(-15, 15))
                                l_Right Leg_0.RotVelocity = l_Right Leg_0.RotVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
                                return;
                            end;
                        end;
                    end;
                elseif v173.Name == "HeadHitbox" then
                    if tick() - v_u_33 >= 0.2 then
                        v_u_33 = tick()
                        v_u_30:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "headgib",
                            ["pitchvariation"] = 0.2,
                            ["location"] = p_u_172.char.Torso
                        }, true)
                    end;
                    p_u_172.char.Head.Transparency = 1
                    v_u_29.blood_impact({
                        ["point"] = CFrame.new(v173.Position) * CFrame.Angles(math.rad((math.random(0, 360))), math.rad((math.random(0, 360))), (math.rad((math.random(0, 360))))),
                        ["headshot"] = true
                    })
                    local v197 = math.random(1, 3)
                    if p_u_172.rand2 then
                        v197 = p_u_172.rand2
                    end;
                    local v_u_198 = game.ReplicatedStorage.death_fx:FindFirstChild("head" .. v197):Clone()
                    v_u_198.CFrame = p_u_172.char.Torso.CFrame
                    v_u_198.main.BrickColor = p_u_172.char.Torso.BrickColor
                    v_u_198.Parent = p_u_172.char.Head
                    if p_u_172.char:FindFirstChild("helmetgone") then
                        p_u_172.char.helmetgone:Destroy()
                    end;
                    if p_u_172.char:FindFirstChild("extralift") then
                        p_u_172.char.extralift:Destroy()
                    end;
                    if v_u_198:FindFirstChild("attach") then
                        delay(math.random(3, 6), function() --[[ Line: 2349 ]]
                            --[[ Upvalues: (copy 1): v_u_198 ]]
                            if v_u_198 and v_u_198:FindFirstChild("attach") then
                                v_u_198.attach.fx.Enabled = false
                            end;
                        end)
                    end;
                    local l_Weld_11 = Instance.new("Weld")
                    l_Weld_11.Part0 = v_u_198
                    l_Weld_11.Part1 = p_u_172.char.Head
                    local v199 = math.random(3, 6)
                    local v200 = math.random(1, 3)
                    local v201 = math.random(2, 4)
                    if v197 == 1 then
                        v199 = math.random(2, 4)
                        v200 = 1
                        v201 = 0
                    elseif v197 == 2 then
                        for _, v202 in ipairs(p_u_172.char:GetChildren()) do
                            if v202:IsA("Accessory") then
                                v202:Destroy()
                            end;
                        end;
                        v199 = math.random(6, 12)
                        v200 = math.random(4, 6)
                        l_Weld_11.C1 = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
                    elseif v197 == 3 then
                        l_Weld_11.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, math.rad((math.random(50, 120))), 0)
                    end;
                    l_Weld_11.Parent = v_u_198
                    for v203 = 1, v199 + v200 do
                        local l_smallchunk_0 = game.ReplicatedStorage.death_fx.smallchunk
                        if v199 < v203 then
                            l_smallchunk_0 = game.ReplicatedStorage.death_fx.bone
                        end;
                        local v204 = l_smallchunk_0:Clone()
                        v204.CollisionGroup = "MiscCollision"
                        v204.CFrame = v173.CFrame * CFrame.new(math.random(-10, 10) / 50, math.random(-10, 10) / 50, math.random(-10, 10) / 50)
                        v204.Parent = p_u_172.char
                        v204.Velocity = v204.Velocity + Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20)) * 0.5
                    end;
                    if v201 > 0 then
                        for _ = 1, v201 do
                            local v205 = game.ReplicatedStorage.death_fx.brainchunk:Clone()
                            v205.CollisionGroup = "MiscCollision"
                            v205.CFrame = v173.CFrame * CFrame.new(math.random(-10, 10) / 50, math.random(-10, 10) / 50, math.random(-10, 10) / 50)
                            v205.Parent = p_u_172.char
                            v205.Velocity = v205.Velocity + Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20)) * 0.5
                        end;
                    end;
                end;
            end;
        end;
    end;
end;
v_u_29.hearbeaticon = function(p206) --[[ Line: 2416 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_30 ]]
    if p206.location then
        local v207 = game.ReplicatedStorage.misc.heartbeat:Clone()
        s_Debris_0:AddItem(v207, 3)
        v207.CFrame = p206.location
        v207.Parent = workspace.notarget
        for _ = 1, 20 do
            if not (v207 and (v207:FindFirstChild("hearticon") and v207.hearticon:FindFirstChild("icon"))) then
                return;
            end;
            local l_icon_0 = v207.hearticon.icon
            l_icon_0.ImageTransparency = l_icon_0.ImageTransparency + 0.05
            v_u_30:s_wait(0.03)
        end;
        if v207 then
            v207:Destroy()
        end;
    end;
end;
tick()
v_u_29.phos_trail = function(p208) --[[ Line: 2485 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0 ]]
    if (l_CurrentCamera_0.CFrame.Position - p208.startpoint).Magnitude >= 150 ~= true or (l_CurrentCamera_0.CFrame.Position - p208.endpoint).Magnitude >= 150 ~= true then
        local l_Magnitude_1 = (p208.startpoint - p208.endpoint).Magnitude
        local v209 = CFrame.new(p208.startpoint, p208.endpoint)
        local l_Part_0 = Instance.new("Part")
        s_Debris_0:AddItem(l_Part_0, 3)
        l_Part_0.Transparency = 1
        l_Part_0.CanCollide = false
        l_Part_0.Locked = true
        l_Part_0.CanQuery = false
        l_Part_0.Anchored = true
        l_Part_0.CFrame = v209 + v209.LookVector * (l_Magnitude_1 / 2)
        l_Part_0.Size = Vector3.new(1, 1, l_Magnitude_1)
        local v210 = game.ReplicatedStorage.effects.phostrail:Clone()
        v210.Parent = l_Part_0
        l_Part_0.Parent = workspace.notarget
        v210:Emit((math.ceil(l_Magnitude_1 / 1.5)))
    end;
end;
v_u_29.bullet_tracer = function(p211) --[[ Line: 2518 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): l_RenderStepped_0 ]]
    if (l_CurrentCamera_0.CFrame.Position - p211.startpoint).Magnitude >= 150 == true and (l_CurrentCamera_0.CFrame.Position - p211.endpoint).Magnitude >= 150 == true then
        return;
    elseif _G.get_settings("disablebullettrails") ~= true then
        local v212 = game.ReplicatedStorage.effects.bullet_tracer:Clone()
        s_Debris_0:AddItem(v212, 8)
        v212.CFrame = CFrame.new(p211.startpoint, p211.endpoint)
        if p211 and (p211.atmos_using and p211.atmos_using == "suppressor") then
            v212.trail.Enabled = false
        end;
        v212.Parent = workspace.notarget
        local v213 = math.clamp((p211.startpoint - p211.endpoint).magnitude / 8, 3, 15)
        local v214 = CFrame.new(p211.startpoint, p211.endpoint)
        local v215 = v214 + v214.LookVector * math.random(1, 15)
        for v216 = 1, v213 do
            v212.CFrame = v215:Lerp(CFrame.new(p211.endpoint, p211.endpoint + v214.LookVector * 1), v216 / v213)
            l_RenderStepped_0:Wait()
        end;
        if v212 and v212:FindFirstChild("trail") then
            s_Debris_0:AddItem(v212, 2)
            v212.Transparency = 1
        end;
    end;
end;
v_u_29.ricochet_effect = function(p_u_217) --[[ Line: 2555 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): v_u_30, (copy 3): v_u_38, (copy 4): v_u_29 ]]
    if _G.get_settings("lowgraphics") ~= true then
        if p_u_217.center_part then
            if (l_CurrentCamera_0.CFrame.Position - p_u_217.center_part.Position).Magnitude >= 150 == true then
                return;
            end;
            local v218, v_u_219, v220 = v_u_30:raycastline({
                ["point"] = p_u_217.center_part.Position,
                ["destination"] = p_u_217.normal + Vector3.new(math.random(-300, 300), math.random(-300, 300), math.random(-300, 300)) / 1000,
                ["range"] = 200,
                ["layermask"] = v_u_38
            })
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "ricochet_" .. math.random(1, 4),
                ["pitchvariation"] = 0.1,
                ["location"] = p_u_217.center_part
            }, true)
            spawn(function() --[[ Line: 2584 ]]
                --[[ Upvalues: (ref 1): v_u_29, (copy 2): p_u_217, (copy 3): v_u_219 ]]
                v_u_29.bullet_tracer({
                    ["startpoint"] = p_u_217.center_part.Position,
                    ["endpoint"] = v_u_219
                })
            end)
            if v218 then
                if v218.Material == Enum.Material.Wood or v218.Material == Enum.Material.WoodPlanks then
                    v_u_29.wood_impact({
                        ["point"] = v_u_219
                    })
                    return;
                end;
                v_u_29.mine_impact({
                    ["from"] = p_u_217.center_part.Position,
                    ["normal"] = v220,
                    ["point"] = v_u_219,
                    ["bullet"] = true,
                    ["ricochet"] = p_u_217.rico - 1
                })
            end;
        end;
    end;
end;
local function _(p221, p222) --[[ Name: invis_part_adjust ]] --[[ Line: 2612 ]]
    p221.Transparency = p222
    for _, v223 in ipairs(p221:GetChildren()) do
        if v223:IsA("BasePart") then
            if v223:FindFirstChild("decal") then
                v223.decal.Transparency = p222
            else
                v223.Transparency = p222
            end;
        end;
    end;
end;
v_u_29.helmet_adjusting = function(p224) --[[ Line: 2625 ]]
    --[[ Upvalues: (copy 1): v_u_30, (copy 2): l_RenderStepped_0 ]]
    if p224.char and (p224.char:FindFirstChild("Torso") and (p224.char:FindFirstChild("helmet") or p224.char:FindFirstChild("extralift"))) and p224.val then
        local v225 = p224.char:FindFirstChild("helmet")
        local v226 = p224.char:FindFirstChild("extralift")
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = p224.val,
            ["location"] = p224.char.Torso
        }, true)
        local v227, v228
        if p224.val == "helmet" then
            v227 = "lowered"
            v228 = "lifted"
        else
            v227 = "lifted"
            v228 = "lowered"
        end;
        local v229 = tick()
        while true do
            local v230 = (tick() - v229) / 0.2
            if v226 and (v226:FindFirstChild("main") and (v226:FindFirstChild("extrajoint") and (v226.main:FindFirstChild(v227) and v226.main:FindFirstChild(v228)))) then
                v226.extrajoint.C0 = v226.main:FindFirstChild(v228).Value:Lerp(v226.main:FindFirstChild(v227).Value, v230)
            end;
            if v225 and (v225:FindFirstChild("knock") and (v225:FindFirstChild("helmetfly") and (v225.knock:FindFirstChild(v227) and v225.knock:FindFirstChild(v228)))) then
                v225.helmetfly.C0 = v225.knock:FindFirstChild(v228).Value:Lerp(v225.knock:FindFirstChild(v227).Value, v230)
            end;
            l_RenderStepped_0:Wait()
            if tick() - v229 >= 0.2 then
                if v226 and (v226:FindFirstChild("main") and (v226:FindFirstChild("extrajoint") and v226.main:FindFirstChild(v227))) then
                    v226.extrajoint.C0 = v226.main:FindFirstChild(v227).Value
                end;
                if v225 and (v225:FindFirstChild("knock") and (v225:FindFirstChild("helmetfly") and v225.knock:FindFirstChild(v227))) then
                    v225.helmetfly.C0 = v225.knock:FindFirstChild(v227).Value
                end;
                break;
            end;
        end;
    else
        -- -- -- ::l2:: (Possible bug with goto) (Possible bug with goto) (Possible bug with goto)
        return;
    end;
end;
local v_u_231 = 0
v_u_29.mine_impact = function(p_u_232) --[[ Line: 2673 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (ref 3): v_u_231, (copy 4): v_u_30, (copy 5): v_u_29 ]]
    if p_u_232.point == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p_u_232.point).Magnitude >= 150 ~= true then
        local v_u_233 = Color3.fromRGB(255, 255, 127)
        local v_u_234 = game.ReplicatedStorage.effects.ricochet:Clone()
        s_Debris_0:AddItem(v_u_234, 3)
        v_u_234.spark.Color = ColorSequence.new(v_u_233)
        v_u_234.spark2.Color = ColorSequence.new(v_u_233)
        v_u_234.spark3.Color = ColorSequence.new(v_u_233)
        v_u_234.CFrame = CFrame.new(p_u_232.point)
        if p_u_232.from then
            v_u_234.CFrame = CFrame.new(p_u_232.point, p_u_232.from)
        end;
        v_u_234.Parent = workspace.notarget
        local v_u_235 = math.random(2, 4)
        if p_u_232.bullet then
            local v236 = 0
            if tick() - v_u_231 <= 0.05 then
                v236 = -0.5
            elseif p_u_232.pellets and p_u_232.pellets > 1 then
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "shotgun_" .. math.random(1, 4),
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_234
                }, true)
            end;
            local v237 = p_u_232.hit_mat and p_u_232.hit_mat == Enum.Material.Ice and -0.5 or v236
            local v238 = false
            if p_u_232.weapon and p_u_232.weapon == "lever" or (p_u_232.weapon == "saa" or (p_u_232.weapon == "mares" or p_u_232.weapon == "walker")) then
                v238 = math.random(1, 5) == 1 and true or v238
            end;
            if v238 == true then
                v_u_30:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "ricochet" .. math.random(1, 6),
                    ["pitchvariation"] = 0.1,
                    ["volume_adjust"] = v237,
                    ["location"] = v_u_234
                }, true)
            else
                if p_u_232.hit_targ and (p_u_232.hit_targ == "leftshield" or (p_u_232.hit_targ == "rightshield" or (p_u_232.hit_targ == "mainshield" or p_u_232.hit_targ == "topshield"))) then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "impact" .. math.random(1, 5),
                        ["pitchvariation"] = 0.1,
                        ["volume_adjust"] = v237,
                        ["location"] = v_u_234
                    }, true)
                elseif p_u_232.hit_mat and p_u_232.hit_mat == Enum.Material.Metal then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "metalwall_" .. math.random(1, 4),
                        ["pitchvariation"] = 0.1,
                        ["volume_adjust"] = v237,
                        ["location"] = v_u_234
                    }, true)
                else
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "wall_" .. math.random(1, 4),
                        ["pitchvariation"] = 0.1,
                        ["volume_adjust"] = v237,
                        ["location"] = v_u_234
                    }, true)
                end;
                if p_u_232.hit_mat and p_u_232.hit_mat == Enum.Material.Ice then
                    v_u_30:soundHandler({
                        ["directory"] = {},
                        ["soundfile"] = "water_" .. math.random(1, 4),
                        ["pitchvariation"] = 0.1,
                        ["volume_adjust"] = v237 + 0.75,
                        ["location"] = v_u_234
                    }, true)
                    local v239 = game.ReplicatedStorage.effects.waterimpact:Clone()
                    s_Debris_0:AddItem(v239, 1)
                    v239.CFrame = CFrame.new(p_u_232.point)
                    v239.Parent = workspace.notarget
                    v239.flash:Emit(1)
                    v239.watersplash:Emit(math.random(6, 12))
                end;
            end;
            if p_u_232.ricochet and p_u_232.ricochet > 0 then
                delay(0.1, function() --[[ Line: 2797 ]]
                    --[[ Upvalues: (ref 1): v_u_29, (copy 2): p_u_232, (copy 3): v_u_234 ]]
                    v_u_29.ricochet_effect({
                        ["normal"] = p_u_232.normal,
                        ["center_part"] = v_u_234,
                        ["rico"] = p_u_232.ricochet
                    })
                end)
                v_u_235 = 2
            end;
        end;
        local v_u_240, v_u_241
        if p_u_232.headhit then
            v_u_240 = 2
            v_u_241 = 0.15
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "helmet" .. math.random(1, 3),
                ["pitchvariation"] = 0.1,
                ["volume_adjust"] = tick() - v_u_231 <= 0.05 and -0.5 or 0,
                ["location"] = v_u_234
            }, true)
            if p_u_232.tooluse and p_u_232.tooluse == "gun" then
                delay(0.1, function() --[[ Line: 2830 ]]
                    --[[ Upvalues: (ref 1): v_u_29, (copy 2): p_u_232, (copy 3): v_u_234 ]]
                    v_u_29.ricochet_effect({
                        ["normal"] = p_u_232.normal,
                        ["center_part"] = v_u_234,
                        ["rico"] = p_u_232.ricochet
                    })
                end)
                v_u_235 = 2
            else
                v_u_235 = 4
            end;
        else
            v_u_241 = 0.35
            v_u_240 = 5
        end;
        v_u_231 = tick()
        spawn(function() --[[ Line: 2842 ]]
            --[[ Upvalues: (ref 1): v_u_235, (ref 2): s_Debris_0, (copy 3): v_u_233, (ref 4): v_u_241, (copy 5): v_u_234, (ref 6): v_u_240 ]]
            for _ = 1, v_u_235 do
                local v242 = game.ReplicatedStorage.effects.ricochettrail:Clone()
                s_Debris_0:AddItem(v242, 2)
                v242.Trail.Color = ColorSequence.new(v_u_233)
                v242.Trail.Lifetime = v_u_241
                v242.CFrame = v_u_234.CFrame
                v242.Parent = workspace.notarget
                v242.Velocity = Vector3.new(math.random(-100, 100), math.random(0, 100), math.random(-100, 100)) / v_u_240
            end;
        end)
    end;
end;
v_u_29.glass_break = function(p243) --[[ Line: 2855 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p243.pos and (p243.size and (p243.col and p243.transp)) then
        if (l_CurrentCamera_0.CFrame.Position - p243.pos.Position).Magnitude >= 150 == true then
            return;
        end;
        local l_Part_1 = Instance.new("Part")
        s_Debris_0:AddItem(l_Part_1, 6)
        l_Part_1.Transparency = 1
        l_Part_1.Locked = true
        l_Part_1.CanCollide = false
        l_Part_1.CanQuery = false
        l_Part_1.CanTouch = false
        l_Part_1.Size = p243.size
        l_Part_1.CFrame = p243.pos
        l_Part_1.Color = p243.col
        l_Part_1.Parent = workspace.notarget
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "glass_break" .. math.random(1, 4),
            ["pitchvariation"] = 0.1,
            ["location"] = l_Part_1
        }, true)
        for _ = 1, math.ceil(l_Part_1.Size.Magnitude + math.random(8, 12)) do
            local v244 = game.ReplicatedStorage.misc.glassshard:Clone()
            s_Debris_0:AddItem(v244, 30)
            v244.CollisionGroup = "MiscCollision"
            local v245 = l_Part_1.CFrame.UpVector * (math.random(-l_Part_1.Size.Y, l_Part_1.Size.Y) / 2) + l_Part_1.CFrame.LookVector * (math.random(-l_Part_1.Size.Z, l_Part_1.Size.Z) / 2) + l_Part_1.CFrame.RightVector * (math.random(-l_Part_1.Size.X, l_Part_1.Size.X) / 2)
            v244.Size = Vector3.new(0.02, math.random(7, 10) / 10, math.random(7, 10) / 10)
            v244.Transparency = p243.transp
            v244.Color = p243.col
            v244.CFrame = l_Part_1.CFrame + v245
            v244.CFrame = v244.CFrame * CFrame.Angles(math.rad((math.random(-180, 180))), math.rad((math.random(-180, 180))), (math.rad((math.random(-180, 180)))))
            v244.RotVelocity = v244.RotVelocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
            v244.Velocity = v244.Velocity + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) / 2
            v244.Parent = workspace.notarget
        end;
    end;
end;
v_u_29.wood_impact = function(p246) --[[ Line: 2919 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (ref 3): v_u_231, (copy 4): v_u_30 ]]
    if p246.point == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p246.point).Magnitude >= 150 ~= true then
        local l_woodchip_0 = game.ReplicatedStorage.effects.woodchip
        local v247 = math.random(8, 15)
        local v248 = math.random(8, 15)
        local v249 = math.random(8, 15)
        local v250
        if p246.sand and p246.sand == true then
            l_woodchip_0 = game.ReplicatedStorage.effects.sandimpact
            v250 = "sand"
            v248 = 1
        else
            v250 = "wood"
        end;
        if p246.glass and p246.glass == true then
            l_woodchip_0 = game.ReplicatedStorage.effects.glassimpact
            v247 = math.random(4, 8)
            v249 = math.random(10, 15)
            v250 = "glass"
            v248 = 0
        end;
        local v251 = l_woodchip_0:Clone()
        s_Debris_0:AddItem(v251, 3)
        if p246.partcol then
            v251.woodchip1.Color = ColorSequence.new(p246.partcol)
            v251.woodchip2.Color = ColorSequence.new(p246.partcol)
            v251.woodchip3.Color = ColorSequence.new(p246.partcol)
        end;
        v251.CFrame = CFrame.new(p246.point)
        v251.Parent = workspace.notarget
        local v252 = 0
        if tick() - v_u_231 <= 0.05 then
            v252 = -0.5
        elseif p246.pellets and p246.pellets > 1 then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "shotgun_" .. math.random(1, 4),
                ["pitchvariation"] = 0.1,
                ["location"] = v251
            }, true)
        end;
        if p246.arrow and p246.arrow == true then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "arrow_impactwood" .. math.random(1, 3),
                ["pitchvariation"] = 0.1,
                ["volume_adjust"] = v252,
                ["location"] = v251
            }, true)
            v252 = v252 - 0.5
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = v250 .. "_" .. math.random(1, 4),
            ["pitchvariation"] = 0.1,
            ["volume_adjust"] = v252,
            ["location"] = v251
        }, true)
        v_u_231 = tick()
        v251.woodchip1:Emit(v247)
        if v248 > 0 then
            v251.woodchip2:Emit(v248)
        end;
        v251.woodchip3:Emit(v249)
    end;
end;
v_u_29.phos_impact = function(p253) --[[ Line: 3010 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p253.posat == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p253.posat.Position).Magnitude >= 150 ~= true then
        local v254 = game.ReplicatedStorage.effects.phosimpact:Clone()
        s_Debris_0:AddItem(v254, 3)
        v254.CFrame = p253.posat
        v254.Parent = workspace.notarget
        v254.smoke:Emit(math.random(2, 3))
        v254.initial:Emit(math.random(8, 15))
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "incendiary_impact",
            ["pitchvariation"] = 0.1,
            ["location"] = v254
        }, true)
    end;
end;
v_u_29.sand_impact = function(p255) --[[ Line: 3035 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (ref 3): v_u_231, (copy 4): v_u_30 ]]
    if p255.point == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p255.point).Magnitude >= 150 ~= true then
        local v256 = game.ReplicatedStorage.effects.sandimpact:Clone()
        s_Debris_0:AddItem(v256, 3)
        v256.CFrame = CFrame.new(p255.point)
        v256.Parent = workspace.notarget
        local v257 = 0
        if tick() - v_u_231 <= 0.05 then
            v257 = -0.5
        elseif p255.pellets and p255.pellets > 1 then
            v_u_30:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "shotgun_" .. math.random(1, 4),
                ["pitchvariation"] = 0.1,
                ["location"] = v256
            }, true)
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "sand_" .. math.random(1, 4),
            ["pitchvariation"] = 0.1,
            ["volume_adjust"] = v257,
            ["location"] = v256
        }, true)
        v_u_231 = tick()
        v256.sand1:Emit(math.random(8, 15))
        v256.sand2:Emit(math.random(8, 15))
        v256.sand3:Emit(math.random(8, 15))
    end;
end;
v_u_29.muzzle_flash = function(p258) --[[ Line: 3081 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0 ]]
    if p258.point == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p258.point.Position).Magnitude >= 300 ~= true then
        if p258.after_smoke and p258.after_smoke:FindFirstChild("after_muzzle") == nil then
            local v_u_259 = game.ReplicatedStorage.effects.after_muzzle:Clone()
            s_Debris_0:AddItem(v_u_259, 3)
            v_u_259.Parent = p258.after_smoke
            delay(math.random(10, 20) / 10, function() --[[ Line: 3094 ]]
                --[[ Upvalues: (copy 1): v_u_259 ]]
                v_u_259.Enabled = false
            end)
            local v_u_260 = game.ReplicatedStorage.effects.after_muzzle_puffs:Clone()
            v_u_260.Rate = math.random(50, 150) / 100
            s_Debris_0:AddItem(v_u_260, 5)
            v_u_260.Parent = p258.after_smoke
            delay(math.random(20, 40) / 10, function() --[[ Line: 3102 ]]
                --[[ Upvalues: (copy 1): v_u_260 ]]
                v_u_260.Enabled = false
            end)
        end;
        local v261 = p258.weapon_name and (p258.weapon_name == "springfield" or p258.weapon_name == "pieper") and true or false
        local v_u_262 = game.ReplicatedStorage.effects.muzzle_flash:Clone()
        s_Debris_0:AddItem(v_u_262, 4)
        v_u_262.CFrame = p258.point
        if v261 == true then
            v_u_262.light:Destroy()
            v_u_262.light_far:Destroy()
        end;
        v_u_262.Parent = workspace.notarget
        if p258.noflash == nil and (v261 == false and math.random(1, 2) == 1) then
            v_u_262.flash:Emit(1)
            v_u_262.flash_general:Emit(1)
        end;
        local v263 = math.random(2, 4)
        local v264 = math.random(4, 6)
        local v265 = p258.weapon_name and p258.weapon_name == "rooklauncher" and 0 or 1
        if p258.weapon_size then
            local l_weapon_size_0 = p258.weapon_size
            local v266 = p258.weapon_name and (p258.weapon_name == "lebel" or (p258.weapon_name == "mgturret" or p258.weapon_name == "lewis")) and true or false
            if p258.class_use and p258.class_use.Value == "conscript" then
                v266 = false
            end;
            if v266 == true then
                l_weapon_size_0 = 0
                v265 = 0
            end;
            local v267 = p258.weapon_name and p258.weapon_name == "mpgun" and 0 or l_weapon_size_0
            if v261 == true then
                v264 = math.random(6, 8)
                v267 = 0
                v265 = 1
            end;
            local v268 = p258.weapon_name and (p258.weapon_name == "henry" or p258.weapon_name == "pugsley") and 3 or (p258.weapon_name and (p258.weapon_name == "remington" or (p258.weapon_name == "scho" or p258.weapon_name == "saa")) and 2 or v267)
            if v268 == 1 then
                v_u_262.smoke_linger_light:Emit(1)
            elseif v268 == 2 then
                v_u_262.smoke_linger_strong:Emit(1)
            elseif v268 == 3 then
                v_u_262.smoke_linger_strong:Emit(1)
                v_u_262.smoke_linger_massive:Emit(1)
            end;
        end;
        if v265 > 0 then
            v_u_262.smoke_flash_heavy:Emit(v265)
        end;
        if v263 > 0 then
            v_u_262.smoke_medium:Emit(v263)
        end;
        if v264 > 0 then
            v_u_262.smoke_forward:Emit(v264)
        end;
        delay(0.03, function() --[[ Line: 3201 ]]
            --[[ Upvalues: (copy 1): v_u_262 ]]
            if v_u_262 and v_u_262:FindFirstChild("light") then
                v_u_262.light:Destroy()
                v_u_262.light_far:Destroy()
            end;
        end)
    end;
end;
local v_u_269 = tick()
v_u_29.blood_impact = function(p270) --[[ Line: 3211 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (ref 2): v_u_269, (copy 3): s_Debris_0, (copy 4): v_u_30, (copy 5): v_u_38, (copy 6): v_u_29 ]]
    if p270.point == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p270.point.Position).Magnitude >= 150 == true then
        return;
    elseif tick() - v_u_269 > 0.05 then
        v_u_269 = tick()
        local v271 = game.ReplicatedStorage.effects.bloodsplatter:Clone()
        s_Debris_0:AddItem(v271, 2)
        v271.CFrame = p270.point
        v271.Parent = workspace.notarget
        v271.spraydirection:Emit(math.random(1, 2))
        v271.armour:Emit(math.random(4, 6))
        v271.heavyflash:Emit(1)
        v271.med:Emit(math.random(1, 2))
        v271.med_bits:Emit(math.random(10, 20))
        local v272, v273, v274 = v_u_30:raycastline({
            ["point"] = p270.point.Position,
            ["destination"] = -p270.point.LookVector,
            ["range"] = 10,
            ["layermask"] = v_u_38
        })
        if v272 then
            v_u_29.blood_floordrip({
                ["where"] = v273,
                ["normal"] = v274
            })
        end;
        if p270.headshot and p270.headshot ~= false then
            v271.flash:Emit(math.random(1, 2))
        end;
    end;
end;
v_u_29.rock_break = function(p275) --[[ Line: 3257 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p275.pos == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p275.pos).Magnitude >= 300 ~= true then
        local v276 = game.ReplicatedStorage.effects.rockbreak:Clone()
        s_Debris_0:AddItem(v276, 2)
        v276.CFrame = CFrame.new(p275.pos)
        v276.Parent = workspace.notarget
        local v277 = workspace.Terrain:GetMaterialColor(Enum.Material.Rock)
        local v278 = Color3.new(0.2 + v277.R, 0.2 + v277.G, 0.2 + v277.B)
        local v279 = math.random(4, 10)
        if p275.mining_mode and p275.mining_mode == "aimed" then
            v279 = math.random(1, 3)
        end;
        v276.rockbreak.Color = ColorSequence.new(v278)
        v276.rockfall.Color = ColorSequence.new(v278)
        local v280, v281
        if p275.quiet and p275.quiet == true then
            v279 = 1
            v280 = -0.5
            v281 = 10
        else
            v280 = 0
            v281 = nil
        end;
        v276.rockbreak:Emit(v279)
        v276.rockfall:Emit(v279)
        if math.random(1, 3) == 1 and (p275.quiet == nil or p275.quiet ~= true) then
            v276.coalbreak:Emit(math.random(3, 6))
        end;
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "break",
            ["pitchvariation"] = 0.2,
            ["volume_adjust"] = v280,
            ["force_max_dist"] = v281,
            ["location"] = v276
        }, true)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "debris" .. math.random(1, 5),
            ["pitchvariation"] = 0.2,
            ["volume_adjust"] = v280,
            ["force_max_dist"] = v281,
            ["location"] = v276
        }, true)
    end;
end;
v_u_29.hardrock_hit = function(p282) --[[ Line: 3322 ]]
    --[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): s_Debris_0, (copy 3): v_u_30 ]]
    if p282.pos == nil then
        return;
    elseif (l_CurrentCamera_0.CFrame.Position - p282.pos).Magnitude >= 50 ~= true then
        local v283 = game.ReplicatedStorage.effects.smallrock:Clone()
        s_Debris_0:AddItem(v283, 2)
        v283.CFrame = CFrame.new(p282.pos)
        v283.Parent = workspace.notarget
        local v284 = workspace.Terrain:GetMaterialColor(Enum.Material.Rock)
        local v285 = Color3.new(0.2 + v284.R, 0.2 + v284.G, 0.2 + v284.B)
        local v286 = math.random(3, 6)
        v283.rockfall.Color = ColorSequence.new(v285)
        local v287, v288
        if p282.quiet and p282.quiet == true then
            v286 = 1
            v287 = -0.5
            v288 = 10
        else
            v287 = 0
            v288 = nil
        end;
        v283.rockfall:Emit(v286)
        v_u_30:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "hardrock",
            ["pitchvariation"] = 0.2,
            ["volume_adjust"] = v287,
            ["force_max_dist"] = v288,
            ["location"] = v283
        }, true)
    end;
end;
return function(p_u_289, p_u_290, p291, p292) --[[ Line: 3369 ]]
    --[[ Upvalues: (copy 1): v_u_30, (copy 2): v_u_29 ]]
    p_u_290.origin = p292
    local v_u_293 = nil
    v_u_30:fast_spawn(function() --[[ Line: 3374 ]]
        --[[ Upvalues: (ref 1): v_u_293, (ref 2): v_u_29, (copy 3): p_u_289, (copy 4): p_u_290 ]]
        v_u_293 = v_u_29[p_u_289](p_u_290)
    end)
    if p291 == nil then
        workspace.remotes.effects_relay:FireServer(p_u_289, p_u_290)
    end;
    return v_u_293;
end;
