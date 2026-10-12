local v_u_101 = {
    ["lewis_rotate"] = function(p1) --[[ Line: 408 ]]
        if p1.main ~= nil and (p1.main.model ~= nil and (p1.main.model:FindFirstChild("parts") ~= nil and p1.main.model.parts:FindFirstChild("magazine") ~= nil)) then
            if p1.main.model.parts.magazine:FindFirstChild("spin") then
                p1.main.model.parts.magazine.spin.C1 = p1.main.model.parts.magazine.spin.C1 * CFrame.Angles(0, 0.2617993877991494, 0)
            end;
        end;
    end,
    ["lewis_magazine"] = function(p2) --[[ Line: 420 ]]
        local v3 = p2.main and (p2.main.model and (p2.main.model:FindFirstChild("parts") and (p2.main.model.parts:FindFirstChild("magazine") and p2.main.model.parts.magazine:FindFirstChild("rounds")))) and (p2.main.model.parts.magazine.Transparency ~= 1 and (p2.main and (p2.main.core and (p2.main.core.ammo_mag and p2.main.model.parts.magazine.rounds:FindFirstChild(p2.main.core.ammo_mag + 1)))))
        if v3 then
            v3.Transparency = 1
        end;
    end,
    ["grenade_pin_return"] = function(p4) --[[ Line: 456 ]]
        if p4.main and (p4.main.model and p4.main.model:FindFirstChild("special")) then
            local v5 = p4.main.model.special:FindFirstChild("pin")
            if v5 and (p4.main.model:FindFirstChild("hitbox") and p4.main.model.hitbox:FindFirstChild("pinweld")) then
                v5.Transparency = 0
            end;
        end;
    end,
    ["bomb_invisible"] = function(p6) --[[ Line: 469 ]]
        if p6.main and (p6.main.model and (p6.main.model:FindFirstChild("parts") and p6.main.model.parts:FindFirstChild("bomb"))) then
            p6.main.model.parts.bomb.Transparency = 1
        end;
    end,
    ["bomb_visible"] = function(p7) --[[ Line: 475 ]]
        if p7.main and (p7.main.model and (p7.main.model:FindFirstChild("parts") and p7.main.model.parts:FindFirstChild("bomb"))) then
            p7.main.model.parts.bomb.Transparency = 0
        end;
    end,
    ["cylinder_fire"] = function(p8) --[[ Line: 481 ]]
        local v9 = p8.main.model:FindFirstChild("cylinder")
        if v9 and p8.main.model.parts:FindFirstChild("cylinder") then
            local v10 = p8.main.weapon == "pieper" and 7 or 6
            local l_Value_0 = v9.Value
            if p8.saa == true then
                l_Value_0 = l_Value_0 - 1
            end;
            if l_Value_0 > 0 then
                v10 = l_Value_0
            end;
            local v11 = p8.main.model.parts.cylinder:FindFirstChild("round" .. v10)
            if v11 and (v11:FindFirstChild("bullet") and v11.bullet:IsA("BasePart")) then
                if p8.load == true then
                    v11.Transparency = 0
                    v11.bullet.Transparency = 0
                    return;
                end;
                v11.bullet.Transparency = 1
            end;
        end;
    end,
    ["cylinder_forcecylinder"] = function(p12) --[[ Line: 741 ]]
        if p12.main ~= nil and (p12.main.model ~= nil and (p12.main.model:FindFirstChild("hitbox") ~= nil or p12.main.model:FindFirstChild("hitbox2") ~= nil)) then
            local v13 = p12.main.model:FindFirstChild("hitbox") or p12.main.model:FindFirstChild("hitbox2")
            local v14 = p12.main.model:FindFirstChild("cylinder")
            if v14 and (p12.main.model.parts:FindFirstChild("cylinder") and v13:FindFirstChild("cylinder")) then
                v14.Value = 1
                v14.cycle.Value = 0
                v13.cylinder.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            end;
        end;
    end,
    ["walker_setcylinder"] = function(p15) --[[ Line: 762 ]]
        if p15.main ~= nil and (p15.cylinder_state ~= nil and p15.main.model ~= nil) then
            local v16 = p15.main.model:FindFirstChild("hitbox") or p15.main.model:FindFirstChild("unequipped")
            local v17 = p15.main.model:FindFirstChild("cylinder")
            if v17 and p15.main.model.parts:FindFirstChild("cylinder") then
                v17.Value = p15.cylinder_state
                v17.cycle.Value = p15.cylinder_state - 1
                v16.cylinder.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, 0, (math.rad(60 * v17.cycle.Value)))
            end;
        end;
    end,
    ["walker_setstate"] = function(p18) --[[ Line: 870 ]]
        if p18.main ~= nil and (p18.walker_slot ~= nil and (p18.walker_state ~= nil and p18.main.model ~= nil)) then
            if p18.main.model.parts:FindFirstChild("cylinder") then
                local v19 = p18.main.model.parts.cylinder:FindFirstChild("round" .. p18.walker_slot)
                local l_walker_state_0 = p18.walker_state
                if l_walker_state_0 and v19 then
                    if l_walker_state_0.ball == true or l_walker_state_0.ball == "half" then
                        v19.Transparency = 0
                        if l_walker_state_0.ball == "half" then
                            v19.ballfront.Transparency = 0
                        else
                            v19.ballfront.Transparency = 1
                        end;
                    else
                        v19.Transparency = 1
                        v19.ballfront.Transparency = 1
                    end;
                    if l_walker_state_0.cap == true or l_walker_state_0.cap == "fired" then
                        v19.cap.Transparency = 0
                        v19.cap.Color = Color3.fromRGB(204, 168, 101)
                        if l_walker_state_0.cap == "fired" then
                            v19.cap.Color = Color3.fromRGB(109, 93, 64)
                        end;
                    else
                        v19.cap.Transparency = 1
                    end;
                    if l_walker_state_0.powder == false then
                        v19.gunpowder.Transparency = 1
                        return;
                    end;
                    v19.gunpowder.Transparency = 0
                end;
            end;
        end;
    end,
    ["rsc_newclip"] = function(p20) --[[ Line: 991 ]]
        if p20.main and (p20.main.model and (p20.main.model:FindFirstChild("parts") and (p20.main.model.parts:FindFirstChild("clip") and p20.main.model.parts.clip:FindFirstChild("round1")))) then
            p20.main.model.parts.clip.Transparency = 0
            for _, v21 in ipairs(p20.main.model.parts.clip:GetChildren()) do
                if v21:IsA("BasePart") then
                    v21.Transparency = 0
                    v21.bullet.Transparency = 0
                end;
            end;
        end;
    end,
    ["rsc_clip_update"] = function(p22) --[[ Line: 1035 ]]
        if p22.main ~= nil and (p22.main.core ~= nil and (p22.main.model ~= nil and (p22.main.model:FindFirstChild("parts") ~= nil and p22.main.model.parts:FindFirstChild("clip") ~= nil))) then
            local v23 = p22.main.model.parts:FindFirstChild("clip")
            if v23 then
                for v24 = 1, 5 do
                    local v25 = v23:FindFirstChild("round" .. v24)
                    if v25 then
                        if p22.main.core.ammo_mag <= v24 then
                            v25.Transparency = 1
                            v25.bullet.Transparency = 1
                        else
                            v25.Transparency = 0
                            v25.bullet.Transparency = 0
                        end;
                    end;
                end;
            end;
        end;
    end,
    ["casing_visibility"] = function(p26) --[[ Line: 1057 ]]
        if p26.main ~= nil and (p26.main.model ~= nil and (p26.main.model:FindFirstChild("parts") ~= nil and p26.main.model.parts:FindFirstChild("casing") ~= nil)) then
            p26.main.model.parts.casing.Transparency = p26.transp
            local v27 = p26.main.model.parts.casing:FindFirstChild("bullet")
            if v27 then
                v27.Transparency = p26.transp
            end;
        end;
    end,
    ["crossbow_bolt_visibility"] = function(p28) --[[ Line: 1069 ]]
        if p28.main ~= nil and (p28.main.model ~= nil and (p28.main.model:FindFirstChild("parts") ~= nil and p28.main.model.parts:FindFirstChild("bolt") ~= nil)) then
            p28.main.model.parts.bolt.Transparency = p28.transp
            p28.main.model.parts.bolt.string.Transparency = p28.transp
            p28.main.model.parts.bolt.bullet.Transparency = p28.transp
        end;
    end,
    ["crossbow_lever_visibility"] = function(p29) --[[ Line: 1088 ]]
        if p29.main ~= nil and (p29.main.model ~= nil and (p29.main.model:FindFirstChild("parts") ~= nil and p29.main.model.parts:FindFirstChild("goatsfoot") ~= nil)) then
            p29.main.model.parts.goatsfoot.Transparency = p29.transp
            p29.main.model.parts.goatsfoot.armspart.leverarms.Transparency = p29.transp
            p29.main.model.parts.goatsfoot.leverpart.lever.Transparency = p29.transp
        end;
    end,
    ["blank_visbility"] = function(p30) --[[ Line: 1108 ]]
        if p30.main ~= nil and (p30.main.model ~= nil and (p30.main.model:FindFirstChild("parts") ~= nil and p30.main.model.parts:FindFirstChild("blankcasing") ~= nil)) then
            p30.main.model.parts.blankcasing.Transparency = p30.transp
            p30.main.model.parts.blankcasing.blank.Transparency = p30.transp
        end;
    end,
    ["riflegrenade_visible"] = function(p31) --[[ Line: 1128 ]]
        if p31.main ~= nil and (p31.main.model ~= nil and (p31.main.model:FindFirstChild("parts") ~= nil and p31.main.model.parts:FindFirstChild("riflegrenade") ~= nil)) then
            p31.main.model.parts.riflegrenade.Transparency = 0
            local v32 = p31.main.model.parts.riflegrenade:FindFirstChild("connector")
            if v32 then
                v32.Transparency = 0
                p31.main.model.parts.riflegrenade.nadepart1.Transparency = 0
                p31.main.model.parts.riflegrenade.nadepart2.Transparency = 0
            end;
        end;
    end,
    ["riflegrenade_invisible"] = function(p33) --[[ Line: 1141 ]]
        if p33.main ~= nil and (p33.main.model ~= nil and (p33.main.model:FindFirstChild("parts") ~= nil and p33.main.model.parts:FindFirstChild("riflegrenade") ~= nil)) then
            p33.main.model.parts.riflegrenade.Transparency = 1
            local v34 = p33.main.model.parts.riflegrenade:FindFirstChild("connector")
            if v34 then
                v34.Transparency = 1
                p33.main.model.parts.riflegrenade.nadepart1.Transparency = 1
                p33.main.model.parts.riflegrenade.nadepart2.Transparency = 1
            end;
        end;
    end,
    ["riflegrenade_fired"] = function(p35) --[[ Line: 1154 ]]
        if p35.main ~= nil and (p35.main.model ~= nil and (p35.main.model:FindFirstChild("parts") ~= nil and p35.main.model.parts:FindFirstChild("riflegrenade") ~= nil)) then
            local v36 = p35.main.model.parts.riflegrenade:FindFirstChild("nadepart1")
            if v36 then
                v36.Transparency = 1
                p35.main.model.parts.riflegrenade.nadepart2.Transparency = 1
            end;
        end;
    end,
    ["set_shell_colour"] = function(p37) --[[ Line: 1190 ]]
        if p37.main ~= nil and (p37.shell_colour ~= nil and (p37.main.model ~= nil and (p37.main.model:FindFirstChild("parts") ~= nil and p37.main.model.parts:FindFirstChild("casing") ~= nil))) then
            p37.main.model.parts.casing.Color = p37.shell_colour
        end;
    end,
    ["mauser_stock_on"] = function(p38) --[[ Line: 1368 ]]
        if p38.main and (p38.main.model and (p38.main.model:FindFirstChild("parts") and p38.main.model.parts:FindFirstChild("stock"))) then
            p38.main.model.parts.stock.Transparency = 0
            p38.main.model.parts.stock.stockpart.Transparency = 0
        end;
    end,
    ["mauser_stock_off"] = function(p39) --[[ Line: 1375 ]]
        if p39.main and (p39.main.model and (p39.main.model:FindFirstChild("parts") and p39.main.model.parts:FindFirstChild("stock"))) then
            p39.main.model.parts.stock.Transparency = 1
            p39.main.model.parts.stock.stockpart.Transparency = 1
        end;
    end,
    ["springfield_ammoskin_check"] = function(p40) --[[ Line: 1401 ]]
        if p40.main and (p40.main.model and (p40.main.model:FindFirstChild("parts") and (p40.main.model.parts:FindFirstChild("casing") and (p40.main.model:FindFirstChild("accessorypart") and (p40.main.model.accessorypart:FindFirstChild("extra") and p40.main.model.accessorypart.extra:FindFirstChild("spareammo1A")))))) then
            if p40.main.model.accessorypart.extra.spareammo1A.Transparency == 0 then
                p40.main.model.accessorypart.extra.spareammo1A.Transparency = 1
                p40.main.model.accessorypart.extra.spareammo1B.Transparency = 1
                return;
            end;
            p40.main.model.accessorypart.extra.spareammo2A.Transparency = 1
            p40.main.model.accessorypart.extra.spareammo2B.Transparency = 1
        end;
    end,
    ["springfield_bolt_off"] = function(p41) --[[ Line: 1421 ]]
        if p41.main and (p41.main.model and (p41.main.model:FindFirstChild("parts") and p41.main.model.parts:FindFirstChild("bolt"))) then
            p41.main.model.parts.bolt.Transparency = 1
            p41.main.model.parts.bolt.hammer.Transparency = 1
            p41.main.model.parts.bolt.boltpiece.bolthandles.Transparency = 1
        end;
    end,
    ["springfield_bolt_on"] = function(p42) --[[ Line: 1429 ]]
        if p42.main and (p42.main.model and (p42.main.model:FindFirstChild("parts") and p42.main.model.parts:FindFirstChild("bolt"))) then
            p42.main.model.parts.bolt.Transparency = 0
            p42.main.model.parts.bolt.hammer.Transparency = 0
            p42.main.model.parts.bolt.boltpiece.bolthandles.Transparency = 0
        end;
    end,
    ["springfield_pedersen_on"] = function(p43) --[[ Line: 1437 ]]
        if p43.main and (p43.main.model and (p43.main.model:FindFirstChild("parts") and p43.main.model.parts:FindFirstChild("pedersen"))) then
            p43.main.model.parts.pedersen.Transparency = 0
            p43.main.model.parts.pedersen.pedersonhandle.Transparency = 0
        end;
    end,
    ["springfield_pedersen_off"] = function(p44) --[[ Line: 1444 ]]
        if p44.main and (p44.main.model and (p44.main.model:FindFirstChild("parts") and p44.main.model.parts:FindFirstChild("pedersen"))) then
            p44.main.model.parts.pedersen.Transparency = 1
            p44.main.model.parts.pedersen.pedersonhandle.Transparency = 1
        end;
    end,
    ["springfield_pedersen_mag_on"] = function(p45) --[[ Line: 1451 ]]
        if p45.main and (p45.main.model and (p45.main.model:FindFirstChild("parts") and p45.main.model.parts:FindFirstChild("pedersenmag"))) then
            p45.main.model.parts.pedersenmag.Transparency = 0
            p45.main.model.parts.pedersenmag.casing.Transparency = 0
            p45.main.model.parts.pedersenmag.casing.bullet.Transparency = 0
        end;
    end,
    ["springfield_pedersen_mag_off"] = function(p46) --[[ Line: 1459 ]]
        if p46.main and (p46.main.model and (p46.main.model:FindFirstChild("parts") and p46.main.model.parts:FindFirstChild("pedersenmag"))) then
            p46.main.model.parts.pedersenmag.Transparency = 1
            p46.main.model.parts.pedersenmag.casing.Transparency = 1
            p46.main.model.parts.pedersenmag.casing.bullet.Transparency = 1
        end;
    end,
    ["magazine_last_round"] = function(p47) --[[ Line: 1494 ]]
        if p47.main and (p47.main.model and (p47.main.model:FindFirstChild("parts") and (p47.main.model.parts:FindFirstChild("magazine") and p47.main.model.parts.magazine.Transparency ~= 1))) then
            p47.main.model.parts.magazine.casing.Transparency = 1
            p47.main.model.parts.magazine.casing.bullet.Transparency = 1
        end;
    end,
    ["m_new_mag"] = function(p48) --[[ Line: 1520 ]]
        if p48.main and (p48.main.model and (p48.main.model:FindFirstChild("parts") and p48.main.model.parts:FindFirstChild("magazine"))) then
            p48.main.model.parts.magazine.Transparency = 0
            for v49 = 1, 7 do
                local v50 = p48.main.model.parts.magazine:FindFirstChild("round" .. v49)
                if v50 and v50:FindFirstChild("bullet") then
                    v50.Transparency = 0
                    v50.bullet.Transparency = 0
                end;
            end;
        end;
    end,
    ["m_mag_update"] = function(p51) --[[ Line: 1535 ]]
        if p51.main and (p51.main.model and (p51.main.model:FindFirstChild("parts") and (p51.main.model.parts:FindFirstChild("magazine") and (p51.main.model.parts.magazine.Transparency ~= 1 and (p51.main and (p51.main.core and p51.main.core.ammo_mag)))))) then
            local v52 = p51.main.model.parts.magazine:FindFirstChild("round" .. p51.main.core.ammo_mag)
            if v52 and v52:FindFirstChild("bullet") then
                v52.Transparency = 1
                v52.bullet.Transparency = 1
            end;
        end;
    end,
    ["magazine_new"] = function(p53) --[[ Line: 1602 ]]
        if p53.main and (p53.main.model and (p53.main.model:FindFirstChild("parts") and (p53.main.model.parts:FindFirstChild("magazine") and p53.main.model.parts.magazine.Transparency == 1))) then
            p53.main.model.parts.magazine.Transparency = 0
            if p53.main.model.parts.magazine:FindFirstChild("casing") then
                p53.main.model.parts.magazine.casing.Transparency = 0
                p53.main.model.parts.magazine.casing.bullet.Transparency = 0
            end;
            if p53.main.model.parts.magazine:FindFirstChild("magparts") then
                p53.main.model.parts.magazine.magparts.Transparency = 0
            end;
            if p53.main.model.parts.magazine:FindFirstChild("spacer") then
                p53.main.model.parts.magazine.spacer.Transparency = 0
            end;
            if p53.main.model.parts.magazine:FindFirstChild("spinner") then
                p53.main.model.parts.magazine.spinner.Transparency = 0
            end;
            if p53.main.model.parts.magazine:FindFirstChild("rounds") then
                for _, v54 in ipairs(p53.main.model.parts.magazine.rounds:GetChildren()) do
                    if v54:IsA("BasePart") then
                        v54.Transparency = 0
                    end;
                end;
                p53.main.model.parts.magazine.spin.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            end;
        end;
    end,
    ["springfield_pedersen_jammed"] = function(p55) --[[ Line: 1630 ]]
        if p55.main and (p55.main.model and (p55.main.model:FindFirstChild("special") and p55.main.model.special:FindFirstChild("jammedcasing"))) then
            p55.main.model.special.jammedcasing.Transparency = 0
        end;
    end,
    ["set_chamber_empty"] = function(p56) --[[ Line: 1638 ]]
        if p56.main and (p56.main.model and (p56.main.model:FindFirstChild("parts") and p56.main.model.parts:FindFirstChild("casing"))) then
            p56.main.model.parts.casing.bullet.Transparency = 1
        end;
    end,
    ["set_chamber_full"] = function(p57) --[[ Line: 1644 ]]
        if p57.main and (p57.main.model and (p57.main.model:FindFirstChild("parts") and p57.main.model.parts:FindFirstChild("casing"))) then
            p57.main.model.parts.casing.bullet.Transparency = 0
        end;
    end,
    ["clip_visibility"] = function(p58) --[[ Line: 1661 ]]
        if p58.main and (p58.main.model and (p58.main.model:FindFirstChild("parts") and (p58.main.model.parts:FindFirstChild("clip") and (p58.main.model.parts.clip:FindFirstChild("bullets") and p58.main.model.parts.clip.bullets:FindFirstChild("bullet"))))) then
            p58.main.model.parts.clip.Transparency = p58.visibility
            p58.main.model.parts.clip.bullets.Transparency = p58.visibility
            p58.main.model.parts.clip.bullets.bullet.Transparency = p58.visibility
            if p58.main.model.parts.clip:FindFirstChild("topbullet") then
                p58.main.model.parts.clip.topbullet.Transparency = p58.visibility
                p58.main.model.parts.clip.topbullet.bullet.Transparency = p58.visibility
            end;
        end;
    end,
    ["clip_bullets_invisible"] = function(p59) --[[ Line: 1721 ]]
        if p59.main and (p59.main.model and (p59.main.model:FindFirstChild("parts") and (p59.main.model.parts:FindFirstChild("clip") and p59.main.model.parts.clip.Transparency ~= 1))) then
            p59.main.model.parts.clip.bullets.Transparency = 1
            p59.main.model.parts.clip.bullets.bullet.Transparency = 1
            if p59.main.model.parts.clip:FindFirstChild("topbullet") then
                p59.main.model.parts.clip.topbullet.Transparency = 1
                p59.main.model.parts.clip.topbullet.bullet.Transparency = 1
            end;
        end;
    end,
    ["firstaid_reset"] = function(p60) --[[ Line: 1736 ]]
        if p60.main and (p60.main.model and (p60.main.model:FindFirstChild("parts") and p60.main.model.parts:FindFirstChild("tweezers"))) then
            p60.main.model.parts.tweezers.round.Transparency = 1
            p60.main.model.parts.tweezers.pellet.Transparency = 1
            p60.main.model.parts.tweezers.shrapnel.Transparency = 1
        end;
    end,
    ["firstaid_tweezer_blood"] = function(p61) --[[ Line: 1745 ]]
        p61.main.model.parts.tweezers.fxpoint.bit1:Emit(math.random(2, 4))
        p61.main.model.parts.tweezers.fxpoint.bit2:Emit(math.random(2, 4))
    end,
    ["firstaid_tweezer_round"] = function(p62) --[[ Line: 1750 ]]
        local l_round_0 = p62.main.model.parts.tweezers.round
        if p62.main and (p62.main.core and p62.main.core.surgery_extra ~= nil) then
            if p62.main.core.surgery_extra == "shrapnel" then
                l_round_0 = p62.main.model.parts.tweezers.shrapnel
            elseif p62.main.core.surgery_extra == "pellet" then
                l_round_0 = p62.main.model.parts.tweezers.pellet
            end;
        end;
        l_round_0.Transparency = 0
    end,
    ["henry_offhandround"] = function(p63) --[[ Line: 1791 ]]
        if p63.main and (p63.main.char and (p63.main.char:FindFirstChild("Left Arm") and (p63.main.model and (p63.main.model:FindFirstChild("parts") and p63.visibility ~= nil)))) then
            local v64 = 0
            if p63.main.char:FindFirstChild("fake_henryround") and p63.main.char.fake_henryround:FindFirstChild("bullet") then
                local v65 = p63.visibility == false and 1 or v64
                p63.main.char.fake_henryround.Transparency = v65
                p63.main.char.fake_henryround.bullet.Transparency = v65
                p63.main.char.fake_henryround.bullet2.Transparency = v65
                return;
            end;
            local v66 = p63.main.model.parts:FindFirstChild("casing")
            if v66 then
                local v67 = v66:Clone()
                v67.Name = "fake_henryround"
                v67.CFrame = p63.main.char["Left Arm"].CFrame
                local l_Weld_0 = Instance.new("Weld")
                l_Weld_0.Part0 = p63.main.char["Left Arm"]
                l_Weld_0.Part1 = v67
                l_Weld_0.C1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                l_Weld_0.C0 = CFrame.new(0.305747986, -0.9812603, 0.117313385, 0, 0, -1, -0.939690828, 0.342019469, 0, 0.342019528, 0.939691186, 0)
                l_Weld_0.Parent = v67
                v67.Parent = p63.main.char
            end;
        end;
    end,
    ["stimbottle_invis"] = function(p68) --[[ Line: 1921 ]]
        if p68.main and (p68.main.model and (p68.main.model:FindFirstChild("hitbox") and (p68.main.model:FindFirstChild("parts") and (p68.main.model:FindFirstChild("body") and (p68.main.model.body:FindFirstChild("bottle") and p68.main.model.parts:FindFirstChild("insidewater")))))) then
            p68.main.model.body.bottle.Transparency = 1
            p68.main.model.parts.insidewater.Transparency = 1
        end;
    end,
    ["stimbottle_new"] = function(p69) --[[ Line: 1950 ]]
        if p69.main and (p69.main.model and (p69.main.model:FindFirstChild("hitbox") and (p69.main.model:FindFirstChild("parts") and (p69.main.model:FindFirstChild("body") and (p69.main.model.body:FindFirstChild("bottle") and p69.main.model.parts:FindFirstChild("insidewater")))))) then
            p69.main.model.body.bottle.Transparency = 0.2
            p69.main.model.parts.insidewater.Transparency = 0
            p69.main.model.parts.insidewater.Color = Color3.fromRGB(199, 199, 199)
        end;
    end,
    ["stimbottle_changecolour"] = function(p70) --[[ Line: 1958 ]]
        if p70.main and (p70.colour and (p70.main.model and (p70.main.model:FindFirstChild("hitbox") and (p70.main.model:FindFirstChild("parts") and (p70.main.model:FindFirstChild("body") and (p70.main.model.body:FindFirstChild("bottle") and p70.main.model.parts:FindFirstChild("insidewater"))))))) then
            p70.main.model.parts.insidewater.Color = p70.colour
        end;
    end,
    ["weapon_visibility"] = function(p71) --[[ Line: 2096 ]]
        local l_char_0 = p71.main.char
        if l_char_0 == nil or (l_char_0:FindFirstChild("Right Arm") == nil or (l_char_0:FindFirstChild("Left Arm") == nil or (l_char_0:FindFirstChild("Humanoid") == nil or l_char_0.Parent ~= workspace.nation_team and (l_char_0.Parent ~= workspace.empire_team and (l_char_0.Parent ~= workspace.notarget and l_char_0.Parent ~= workspace.evacs))))) then
            return;
        else
            local v72 = CFrame.new(0, 0, 0)
            local l_Right Arm_0 = l_char_0["Right Arm"]
            if p71.main.module.lefthand == true or p71.flipped == true then
                l_Right Arm_0 = l_char_0["Left Arm"]
            end;
            local v73 = l_char_0:FindFirstChild(p71.main.module.holster_point)
            if p71.flipped == true then
                v72 = CFrame.new(0, 0, -0.5)
            end;
            local v74 = p71.main.module.equipc0 * v72
            local l_equipc1_0 = p71.main.module.equipc1
            local v75 = "Motor6D"
            local v76 = p71.main.model:FindFirstChild("hitbox") or (p71.main.model:FindFirstChild("unequipped") or p71.main.model:FindFirstChild("hitbox2"))
            if p71.state == "holster" or p71.state == "dropped" then
                v75 = "Weld"
                v74 = p71.main.module.holsterc0
                l_equipc1_0 = p71.main.module.holsterc1
                if p71.slot and p71.slot == 2 then
                    v74 = p71.main.module.alt_holsterc0
                    l_equipc1_0 = p71.main.module.alt_holsterc1
                end;
                if v76 then
                    v76.Name = "unequipped"
                end;
                if p71.state == "holster" and (l_char_0:FindFirstChild("crossbow1") and (l_char_0:FindFirstChild("crossbow2") and (p71.main.model.Name == "crossbow1" or p71.main.model.Name == "crossbow2"))) and (p71.main.model:FindFirstChild("parts") and (p71.main.model.parts:FindFirstChild("string") and p71.main.model.parts.string:FindFirstChild("root"))) then
                    local v77 = p71.main.model.Name == "crossbow2" and "B" or "A"
                    local v78 = p71.main.model.parts.string:FindFirstChild("rootA") or (p71.main.model.parts.string:FindFirstChild("rootB") or p71.main.model.parts.string:FindFirstChild("root"))
                    local v79 = v78:FindFirstChild("arm1_l") or (v78:FindFirstChild("arm1_lA") or v78:FindFirstChild("arm1_lB"))
                    local v80 = v79:FindFirstChild("arm2_l") or (v79:FindFirstChild("arm2_lA") or v79:FindFirstChild("arm2_lB"))
                    local v81 = v80:FindFirstChild("arm3_l") or (v80:FindFirstChild("arm3_lA") or v80:FindFirstChild("arm3_lB"))
                    local v82 = v78:FindFirstChild("arm1_r") or (v78:FindFirstChild("arm1_rA") or v78:FindFirstChild("arm1_rB"))
                    local v83 = v82:FindFirstChild("arm2_r") or (v82:FindFirstChild("arm2_rA") or v82:FindFirstChild("arm2_rB"))
                    local v84 = l_Right Arm_0
                    l_Right Arm_0 = v73
                    v73 = v84
                    for _, v85 in ipairs({
                        v78,
                        v79,
                        v80,
                        v81,
                        v82,
                        v83,
                        v83:FindFirstChild("arm3_r") or (v83:FindFirstChild("arm3_rA") or v83:FindFirstChild("arm3_rB"))
                    }) do
                        v85.Name = v85.Name .. v77
                        local v86 = v73
                        v73 = l_Right Arm_0
                        l_Right Arm_0 = v86
                        v84 = l_Right Arm_0
                        l_Right Arm_0 = v73
                        v73 = v84
                    end;
                else
                    local v87 = l_Right Arm_0
                    l_Right Arm_0 = v73
                    v73 = v87
                end;
            elseif v76 then
                if p71.dual and p71.dual == true then
                    v76.Name = "hitbox2"
                else
                    v76.Name = "hitbox"
                    if p71.flipped == true and (p71.main.model and p71.main.originweapon == "mares") then
                        v76.Name = "hitbox2"
                    end;
                end;
                if l_char_0:FindFirstChild("crossbow1") and (l_char_0:FindFirstChild("crossbow2") and (p71.main.model.Name == "crossbow1" or p71.main.model.Name == "crossbow2")) and (p71.main.model:FindFirstChild("parts") and (p71.main.model.parts:FindFirstChild("string") and (p71.main.model.parts.string:FindFirstChild("rootA") or (p71.main.model.parts.string:FindFirstChild("rootB") or p71.main.model.parts.string:FindFirstChild("root"))))) then
                    local v88 = p71.main.model.parts.string:FindFirstChild("rootA") or (p71.main.model.parts.string:FindFirstChild("rootB") or p71.main.model.parts.string:FindFirstChild("root"))
                    local v89 = v88:FindFirstChild("arm1_l") or (v88:FindFirstChild("arm1_lA") or v88:FindFirstChild("arm1_lB"))
                    local v90 = v89:FindFirstChild("arm2_l") or (v89:FindFirstChild("arm2_lA") or v89:FindFirstChild("arm2_lB"))
                    local v91 = v90:FindFirstChild("arm3_l") or (v90:FindFirstChild("arm3_lA") or v90:FindFirstChild("arm3_lB"))
                    local v92 = v88:FindFirstChild("arm1_r") or (v88:FindFirstChild("arm1_rA") or v88:FindFirstChild("arm1_rB"))
                    local v93 = v92:FindFirstChild("arm2_r") or (v92:FindFirstChild("arm2_rA") or v92:FindFirstChild("arm2_rB"))
                    for _, v94 in ipairs({
                        v88,
                        v89,
                        v90,
                        v91,
                        v92,
                        v93,
                        v93:FindFirstChild("arm3_r") or (v93:FindFirstChild("arm3_rA") or v93:FindFirstChild("arm3_rB"))
                    }) do
                        local v95 = string.len(v94.Name)
                        if string.sub(v94.Name, v95, v95) == "A" or string.sub(v94.Name, v95, v95) == "B" then
                            v94.Name = string.sub(v94.Name, 0, v95 - 1)
                        end;
                    end;
                end;
            end;
            local v96 = v73:FindFirstChild(p71.main.originweapon .. p71.slot .. "fake")
            if v96 then
                v96:Destroy()
            end;
            local v97 = v73:FindFirstChild(p71.main.originweapon .. p71.slot)
            if v97 and v97.Parent:IsA("BasePart") then
                v97:Destroy()
            end;
            if p71.state == "dropped" then
                local v98 = l_Right Arm_0:FindFirstChild(p71.main.originweapon .. p71.slot)
                if v98 and v98.Parent:IsA("BasePart") then
                    v98:Destroy()
                end;
                local v99 = l_Right Arm_0:FindFirstChild(p71.main.originweapon .. p71.slot .. "fake")
                if v99 and v99.Parent:IsA("BasePart") then
                    v99:Destroy()
                end;
            end;
            if p71.destroy ~= true then
                local v100 = Instance.new(v75)
                v100.Name = p71.main.originweapon .. p71.slot .. "fake"
                v100.Part0 = l_Right Arm_0
                v100.Part1 = v76
                v100.C0 = v74
                v100.C1 = l_equipc1_0
                v100.Parent = l_Right Arm_0
            end;
        end;
    end
}
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local v_u_102 = require(game.ReplicatedStorage.shared.bFunctions)
local s_Debris_0 = game:GetService("Debris")
local v_u_103 = PhysicalProperties.new(0.1, 2, 1, 100, 1)
local v_u_104 = {
    ["lebel"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward"
    },
    ["pugsley"] = {
        ["casing_sound"] = "large",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["mgturret"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "left"
    },
    ["browningmg"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward"
    },
    ["springfield"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward",
        ["roundscale"] = 1.3
    },
    ["rsc"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["mondragon"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "steyr",
        ["roundscale"] = 1.25
    },
    ["autosg"] = {
        ["casing_sound"] = "shotgun",
        ["ejection"] = "forwardleft"
    },
    ["trench"] = {
        ["casing_sound"] = "shotgun",
        ["ejection"] = "forward",
        ["roundscale"] = 1.1
    },
    ["enfield"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["lewis"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["rooklauncher"] = {
        ["casing_sound"] = "large",
        ["ejection"] = "right"
    },
    ["henry"] = {
        ["casing_sound"] = "large",
        ["ejection"] = "right"
    },
    ["mosin"] = {
        ["casing_sound"] = "rifle",
        ["ejection"] = "forward",
        ["roundscale"] = 1.3
    },
    ["dbgun"] = {
        ["casing_sound"] = "shotgun",
        ["ejection"] = "forward"
    },
    ["remington"] = {
        ["casing_sound"] = "shotgun",
        ["ejection"] = "forward"
    },
    ["scho"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["mpgun"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "forward",
        ["roundscale"] = 1.25
    },
    ["pieper"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "forward",
        ["roundscale"] = 1.1
    },
    ["saa"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "forward"
    },
    ["mauser"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "mauser",
        ["roundscale"] = 1.25
    },
    ["mausercarbine"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "mauser",
        ["roundscale"] = 1.25
    },
    ["steyr"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "steyr"
    },
    ["mpistol"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "mpistol"
    },
    ["lever"] = {
        ["casing_sound"] = "revolver",
        ["ejection"] = "lever",
        ["roundscale"] = 1.75
    },
    ["mares"] = v_u_104.lever
}
local function _(p105, p106) --[[ Line: 157 ]]
    return (p106 or 150) <= (workspace.CurrentCamera.CFrame.Position - p105).Magnitude;
end;
local function _(p_u_107, p_u_108, p_u_109) --[[ Line: 171 ]]
    --[[ Upvalues: (copy 1): v_u_102 ]]
    if _G.get_settings("lowgraphics") ~= true then
        local v_u_110 = 0
        local v_u_111 = 3
        local v_u_112 = nil
        v_u_112 = p_u_107.Touched:Connect(function(p113) --[[ Line: 178 ]]
            --[[ Upvalues: (ref 1): v_u_110, (ref 2): v_u_111, (copy 3): p_u_108, (copy 4): p_u_109, (ref 5): v_u_102, (copy 6): p_u_107, (ref 7): v_u_112 ]]
            if p113.CanQuery == true and (p113.CanCollide == true and (p113:IsDescendantOf(workspace.notarget) ~= true and (p113:IsDescendantOf(workspace.bodies) ~= true and (p113:IsDescendantOf(workspace.nation_team) ~= true and (p113:IsDescendantOf(workspace.empire_team) ~= true and tick() - v_u_110 >= 0.1))))) then
                v_u_110 = tick()
                v_u_111 = v_u_111 - 1
                local v114 = { p_u_108 }
                local v115 = p_u_109 .. math.random(1, 2)
                if (p_u_109 == "rifle" or (p_u_109 == "large" or (p_u_109 == "revolver" or p_u_109 == "shotgun"))) and p113.Material then
                    if p113.Material == Enum.Material.Wood or p113.Material == Enum.Material.WoodPlanks then
                        v115 = p_u_109 .. "_wood" .. math.random(1, 2)
                    elseif p113.Material == Enum.Material.Metal or (p113.Material == Enum.Material.CorrodedMetal or p113.Material == Enum.Material.DiamondPlate) then
                        v115 = p_u_109 .. "_metal" .. math.random(1, 2)
                    end;
                end;
                v_u_102:soundHandler({
                    ["directory"] = v114,
                    ["soundfile"] = v115,
                    ["pitchvariation"] = 0.1,
                    ["location"] = p_u_107
                }, true)
                if v_u_111 <= 0 then
                    v_u_112:Disconnect()
                end;
            end;
        end)
    end;
end;
local function v_u_132(p116, p117, p118, p119) --[[ Line: 213 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_103, (copy 3): v_u_102 ]]
    local v_u_120 = p116:Clone()
    s_Debris_0:AddItem(v_u_120, _G.get_settings("lowgraphics") == true and 3 or 10)
    if typeof(p118) == "table" and p118.roundscale then
        local v121 = p119 == "pedersen" and 2 or p118.roundscale
        v_u_120.Size = v_u_120.Size * v121
        local v122 = v_u_120:FindFirstChild("bullet") and v_u_120:FindFirstChild("Weld")
        if v122 then
            v122.C0 = CFrame.new(v122.C0.Position * v121) * (v122.C0 - v122.C0.Position)
            v122.C1 = CFrame.new(v122.C1.Position * v121) * (v122.C1 - v122.C1.Position)
            v_u_120.bullet.Size = v_u_120.bullet.Size * v121
        end;
    end;
    v_u_120.CollisionGroup = "MiscCollision"
    v_u_120.CanCollide = true
    v_u_120.CanQuery = false
    v_u_120.CanTouch = true
    v_u_120.Massless = true
    v_u_120.CustomPhysicalProperties = v_u_103
    v_u_120.Transparency = 0
    if v_u_120 ~= nil and v_u_120:FindFirstChild("blank") then
        v_u_120.blank.Transparency = 0
        p117 = true
    end;
    if v_u_120 ~= nil and (v_u_120:FindFirstChild("bullet") ~= nil and v_u_120.bullet:IsA("BasePart")) then
        v_u_120.bullet.Massless = true
    end;
    if ((_G.get_settings("lowgraphics") == true or (workspace.CurrentCamera.CFrame.Position - v_u_120.Position).magnitude >= 75) and true or p117) ~= true then
        local v_u_123 = game.ReplicatedStorage.effects.casing_smoke:Clone()
        v_u_123.Parent = v_u_120
        delay(math.random(10, 20) / 10, function() --[[ Line: 275 ]]
            --[[ Upvalues: (copy 1): v_u_120, (copy 2): v_u_123 ]]
            if v_u_120 and v_u_120:FindFirstChild("casing_smoke") then
                v_u_123.Enabled = false
            end;
        end)
    end;
    if typeof(p118) == "table" then
        p118 = p118.casing_sound
    end;
    local v_u_124 = p119 == "pedersen" and "revolver" or p118
    if _G.get_settings("lowgraphics") ~= true then
        local v_u_125 = 0
        local v_u_126 = 3
        local v_u_127 = nil
        local v_u_128 = "casings"
        v_u_127 = v_u_120.Touched:Connect(function(p129) --[[ Line: 178 ]]
            --[[ Upvalues: (ref 1): v_u_125, (ref 2): v_u_126, (copy 3): v_u_128, (copy 4): v_u_124, (ref 5): v_u_102, (copy 6): v_u_120, (ref 7): v_u_127 ]]
            if p129.CanQuery == true and (p129.CanCollide == true and (p129:IsDescendantOf(workspace.notarget) ~= true and (p129:IsDescendantOf(workspace.bodies) ~= true and (p129:IsDescendantOf(workspace.nation_team) ~= true and (p129:IsDescendantOf(workspace.empire_team) ~= true and tick() - v_u_125 >= 0.1))))) then
                v_u_125 = tick()
                v_u_126 = v_u_126 - 1
                local v130 = { v_u_128 }
                local v131 = v_u_124 .. math.random(1, 2)
                if (v_u_124 == "rifle" or (v_u_124 == "large" or (v_u_124 == "revolver" or v_u_124 == "shotgun"))) and p129.Material then
                    if p129.Material == Enum.Material.Wood or p129.Material == Enum.Material.WoodPlanks then
                        v131 = v_u_124 .. "_wood" .. math.random(1, 2)
                    elseif p129.Material == Enum.Material.Metal or (p129.Material == Enum.Material.CorrodedMetal or p129.Material == Enum.Material.DiamondPlate) then
                        v131 = v_u_124 .. "_metal" .. math.random(1, 2)
                    end;
                end;
                v_u_102:soundHandler({
                    ["directory"] = v130,
                    ["soundfile"] = v131,
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_120
                }, true)
                if v_u_126 <= 0 then
                    v_u_127:Disconnect()
                end;
            end;
        end)
    end;
    v_u_120.Parent = workspace.notarget
    return v_u_120;
end;
v_u_101.db_eject = function(p133) --[[ Line: 298 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p133.main and (p133.main.model and (p133.main.model:FindFirstChild("parts") and (p133.main.model.parts:FindFirstChild("shell1") and p133.main.model.parts:FindFirstChild("shell2")))) then
        local l_shell1_0 = p133.main.model.parts.shell1
        if p133.alt and p133.alt == true then
            l_shell1_0 = p133.main.model.parts.shell2
        end;
        local v134 = l_shell1_0:FindFirstChild("ejection_smoke")
        if v134 == nil then
            v134 = game.ReplicatedStorage.effects.ejection_smoke:Clone()
            v134.Parent = l_shell1_0
        end;
        v134:Emit(1)
        local v_u_135 = v_u_132(l_shell1_0, nil, p133.stats)
        v_u_135.Velocity = v_u_135.Velocity + v_u_135.CFrame.rightVector * 10
        spawn(function() --[[ Line: 317 ]]
            --[[ Upvalues: (copy 1): v_u_135 ]]
            v_u_135.RotVelocity = v_u_135.RotVelocity + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
        end)
        l_shell1_0.Transparency = 1
        l_shell1_0.int.Transparency = 1
    end;
end;
v_u_101.remington_shelleject = function(p136) --[[ Line: 327 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p136.main and (p136.main.model and (p136.main.model:FindFirstChild("parts") and p136.main.model.parts:FindFirstChild("casing"))) then
        local l_casing_0 = p136.main.model.parts.casing
        local v137 = l_casing_0:FindFirstChild("ejection_smoke")
        if v137 == nil then
            v137 = game.ReplicatedStorage.effects.ejection_smoke:Clone()
            v137.Parent = l_casing_0
        end;
        v137:Emit(1)
        local v_u_138 = v_u_132(l_casing_0, nil, p136.stats)
        v_u_138.Velocity = v_u_138.Velocity + v_u_138.CFrame.rightVector * 10
        spawn(function() --[[ Line: 343 ]]
            --[[ Upvalues: (copy 1): v_u_138 ]]
            v_u_138.RotVelocity = v_u_138.RotVelocity + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
        end)
        l_casing_0.Transparency = 1
        l_casing_0.bullet.Transparency = 1
        if p136.main.model:FindFirstChild("accessorypart") and p136.main.model.accessorypart:FindFirstChild("extra") then
            local v139 = p136.main.model.accessorypart.extra:FindFirstChild("weldtobarrel")
            if v139 and (v139:FindFirstChild("shell") and (v139:FindFirstChild("shellback") and (v139:FindFirstChild("chaindisappear1") and v139:FindFirstChild("chaindisappear2")))) then
                v139.shell.Transparency = 1
                v139.shellback.Transparency = 1
                v139.chaindisappear1.Transparency = 1
                v139.chaindisappear2.Transparency = 1
            end;
        end;
    end;
end;
v_u_101.db_shell_insert = function(p140) --[[ Line: 365 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    if p140.main and (p140.main.model and (p140.main.model:FindFirstChild("parts") and (p140.main.model.parts:FindFirstChild("shell1") and p140.main.model.parts:FindFirstChild("shell2")))) then
        v_u_101.hand_shell_invisible(p140)
        local l_shell1_1 = p140.main.model.parts.shell1
        if p140.alt and p140.alt == true then
            l_shell1_1 = p140.main.model.parts.shell2
        end;
        l_shell1_1.Transparency = 0
        l_shell1_1.int.Transparency = 0
    end;
end;
v_u_101.db_shell1_eject = function(p141) --[[ Line: 378 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    v_u_101.db_eject(p141)
end;
v_u_101.db_shell1_insert = function(p142) --[[ Line: 382 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    v_u_101.db_shell_insert(p142)
end;
v_u_101.db_shell2_eject = function(p143) --[[ Line: 386 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p143.alt = true
    v_u_101.db_eject(p143)
end;
v_u_101.db_shell2_insert = function(p144) --[[ Line: 391 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p144.alt = true
    v_u_101.db_shell_insert(p144)
end;
v_u_101.db_shell_double_eject = function(p145) --[[ Line: 396 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    v_u_101.db_eject(p145)
    p145.alt = true
    v_u_101.db_eject(p145)
end;
v_u_101.db_shell_double_insert = function(p146) --[[ Line: 402 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    v_u_101.db_shell_insert(p146)
    p146.alt = true
    v_u_101.db_shell_insert(p146)
end;
v_u_101.grenade_pin = function(p147) --[[ Line: 434 ]]
    --[[ Upvalues: (copy 1): s_Debris_0 ]]
    if p147.main and (p147.main.model and p147.main.model:FindFirstChild("special")) then
        local v148 = p147.main.model.special:FindFirstChild("pin")
        if v148 and (p147.main.model:FindFirstChild("hitbox") and p147.main.model.hitbox:FindFirstChild("pinweld")) then
            local v149 = v148:Clone()
            s_Debris_0:AddItem(v149, 5)
            v149.Size = v149.Size * 2
            v149.CollisionGroup = "MiscCollision"
            v149.CanCollide = true
            v149.Parent = workspace.notarget
            v149.Velocity = v149.Velocity + v149.CFrame.upVector + Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 0.5
            v148.Transparency = 1
        end;
    end;
end;
v_u_101.cylinder_empty = function(p150) --[[ Line: 511 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p150.main.model.parts:FindFirstChild("cylinder") then
        local v151 = false
        for _, v152 in ipairs(p150.main.model.parts.cylinder:GetChildren()) do
            if v152:FindFirstChild("bullet") and v152.Transparency == 0 then
                local v153 = (not p150.eject_fired_only or (p150.eject_fired_only ~= true or v152.bullet.Transparency ~= 0)) and true or false
                if p150.eject_unfired_only and (p150.eject_unfired_only == true and v152.bullet.Transparency == 1) then
                    v153 = false
                end;
                if v153 == true then
                    v151 = v152.bullet.Transparency == 1 and true or v151
                    if not p150.eject_unfired_only == true then
                        local v_u_154 = v_u_132(v152, v152.bullet.Transparency == 0, p150.stats)
                        v_u_154.CFrame = v152.CFrame
                        if p150.main.weapon == "pieper" then
                            v_u_154.Velocity = v_u_154.Velocity + v_u_154.CFrame.rightVector * 8
                        elseif p150.eject_fired_only == nil then
                            v_u_154.Velocity = Vector3.new(0, 10, 0)
                            v_u_154.RotVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
                            spawn(function() --[[ Line: 552 ]]
                                --[[ Upvalues: (copy 1): v_u_154 ]]
                                v_u_154.Velocity = v_u_154.Velocity + Vector3.new(math.random(-20, 20), math.random(20, 20), math.random(-20, 20)) / 5
                            end)
                        end;
                    end;
                    v152.bullet.Transparency = 1
                    v152.Transparency = 1
                end;
            end;
        end;
        if v151 == true then
            local v155 = p150.main.model.parts.cylinder:FindFirstChild("ejection_smoke")
            if v155 == nil then
                v155 = game.ReplicatedStorage.effects.ejection_smoke:Clone()
                v155.Parent = p150.main.model.parts.cylinder
            end;
            v155:Emit(1)
        end;
    end;
end;
v_u_101.cylinder_empty_fired = function(p156) --[[ Line: 579 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p156.eject_fired_only = true
    v_u_101.cylinder_empty(p156)
end;
v_u_101.cylinder_empty_unfired = function(p157) --[[ Line: 584 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p157.eject_unfired_only = true
    v_u_101.cylinder_empty(p157)
end;
v_u_101.cylinder_load = function(p158) --[[ Line: 589 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p158.load = true
    v_u_101.cylinder_fire(p158)
end;
v_u_101.saa_load = function(p159) --[[ Line: 594 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p159.load = true
    p159.saa = true
    v_u_101.cylinder_fire(p159)
end;
v_u_101.saa_eject = function(p160) --[[ Line: 600 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    local v161 = p160.main.model:FindFirstChild("cylinder")
    if v161 and p160.main.model.parts:FindFirstChild("cylinder") then
        local v162 = v161.Value - 1
        local v163 = p160.main.model.parts.cylinder:FindFirstChild("round" .. (v162 <= 0 and 6 or v162))
        if v163 then
            local v164 = v_u_132(v163, false, p160.stats)
            v164.CFrame = v163.CFrame
            v164.Velocity = v164.Velocity - v164.CFrame.rightVector * 5
            v163.bullet.Transparency = 1
            v163.Transparency = 1
        end;
    end;
end;
v_u_101.cylinder_rotate = function(p_u_165) --[[ Line: 623 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): l_RenderStepped_0 ]]
    if p_u_165.main == nil or (p_u_165.main.model == nil or p_u_165.main.model:FindFirstChild("hitbox") == nil and p_u_165.main.model:FindFirstChild("hitbox2") == nil) then
        return;
    end;
    local v_u_166 = p_u_165.main.model:FindFirstChild("hitbox") or p_u_165.main.model:FindFirstChild("hitbox2")
    local v167 = p_u_165.main.model:FindFirstChild("cylinder")
    if v167 and (p_u_165.main.model.parts:FindFirstChild("cylinder") and v_u_166:FindFirstChild("cylinder")) then
        local v168 = p_u_165.twice and p_u_165.twice == true and 2 or 1
        local v169, v170
        if p_u_165.main.weapon == "pieper" then
            v169 = 7
            v170 = 51.4285714286
        else
            v169 = 6
            v170 = 60
        end;
        for v171 = 1, v168 do
            delay(v171 == 2 and 0.125 or 0.05, function() --[[ Line: 653 ]]
                --[[ Upvalues: (copy 1): p_u_165, (copy 2): v_u_166, (ref 3): v_u_102 ]]
                if p_u_165 and (p_u_165.main and (p_u_165.main.model and v_u_166)) then
                    if p_u_165.main.weapon == "saa" then
                        v_u_102:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "saa_rotate",
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_166
                        }, true)
                        return;
                    end;
                    if p_u_165.main.weapon == "scho" then
                        v_u_102:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "cylinder_rotate",
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_166
                        }, true)
                    end;
                end;
            end)
        end;
        if p_u_165.otherdir and p_u_165.otherdir == true then
            v168 = -v168
        end;
        v167.Value = v167.Value + v168
        if v169 < v167.Value then
            v167.Value = v167.Value - v169
        end;
        if v167.Value <= 0 then
            v167.Value = v169
        end;
        local l_cylinder_0 = v_u_166.cylinder
        local v172 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(math.rad(v170 * v167.cycle.Value), 0, 0)
        if v167:FindFirstChild("inverse") then
            v168 = -v168
        end;
        local v173 = v172 * CFrame.Angles(math.rad(v170 * v168), 0, 0)
        v167.cycle.Value = v167.cycle.Value + v168
        local v174 = tick()
        local v175 = p_u_165.main.weapon == "pieper" and 0.1 or (p_u_165.main.weapon == "saa" and 0.15 or 0.2)
        if p_u_165.speedval then
            v175 = p_u_165.speedval - 0.02
        end;
        while true do
            local v176 = (tick() - v174) / v175
            if l_cylinder_0 == nil then
                return;
            end;
            l_cylinder_0.C1 = v172:Lerp(v173, v176)
            l_RenderStepped_0:Wait()
            if v175 < tick() - v174 then
                if l_cylinder_0 == nil then
                    return;
                end;
                l_cylinder_0.C1 = v173
                break;
            end;
        end;
    else
        -- ::l9:: (Possible bug with goto)
        return;
    end;
end;
v_u_101.cylinder_rotate_other = function(p177) --[[ Line: 731 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p177.otherdir = true
    v_u_101.cylinder_rotate(p177)
end;
v_u_101.cylinder_rotate_twice = function(p178) --[[ Line: 736 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p178.twice = true
    v_u_101.cylinder_rotate(p178)
end;
v_u_101.walker_cylinder_rotate = function(p_u_179) --[[ Line: 787 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): l_RenderStepped_0 ]]
    if p_u_179.main == nil or p_u_179.main.model == nil then
        return;
    end;
    local v_u_180 = p_u_179.main.model:FindFirstChild("hitbox") or p_u_179.main.model:FindFirstChild("unequipped")
    local v181 = p_u_179.main.model:FindFirstChild("cylinder")
    if v181 and p_u_179.main.model.parts:FindFirstChild("cylinder") then
        delay(0.05, function() --[[ Line: 804 ]]
            --[[ Upvalues: (copy 1): p_u_179, (copy 2): v_u_180, (ref 3): v_u_102 ]]
            if p_u_179 and (p_u_179.main and (p_u_179.main.model and v_u_180)) then
                v_u_102:soundHandler({
                    ["directory"] = {},
                    ["soundfile"] = "cylinder_rotate",
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_180
                }, true)
            end;
        end)
        local v182 = not p_u_179.add_amount and 1 or p_u_179.add_amount
        for v183 = 1, v182 do
            v181.Value = v181.Value + 1
            if v181.Value > 6 then
                v181.Value = 1
            end;
            if v183 >= 2 then
                delay(0.05 * v183, function() --[[ Line: 828 ]]
                    --[[ Upvalues: (copy 1): p_u_179, (copy 2): v_u_180, (ref 3): v_u_102 ]]
                    if p_u_179 and (p_u_179.main and (p_u_179.main.model and v_u_180)) then
                        v_u_102:soundHandler({
                            ["directory"] = {},
                            ["soundfile"] = "cylinder_rotate",
                            ["pitchvariation"] = 0.1,
                            ["location"] = v_u_180
                        }, true)
                    end;
                end)
            end;
        end;
        local l_cylinder_1 = v_u_180.cylinder
        local v184 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.Angles(0, 0, (math.rad(60 * v181.cycle.Value)))
        local v185 = v184 * CFrame.Angles(0, 0, 1.0471975511965976)
        v181.cycle.Value = v181.cycle.Value + v182
        local v186 = tick()
        while true do
            local v187 = (tick() - v186) / 0.2
            if l_cylinder_1 == nil then
                return;
            end;
            l_cylinder_1.C1 = v184:Lerp(v185, v187)
            l_RenderStepped_0:Wait()
            if tick() - v186 > 0.2 then
                if l_cylinder_1 == nil then
                    return;
                end;
                l_cylinder_1.C1 = v185
                break;
            end;
        end;
    else
        -- ::l7:: (Possible bug with goto)
        return;
    end;
end;
v_u_101.walker_cylinderbreak = function(p188) --[[ Line: 917 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p188.main ~= nil and p188.main.model ~= nil then
        if p188.main.model.parts:FindFirstChild("cylinder") then
            local v189 = v_u_132(p188.main.model.parts.cylinder, false, "rscclip")
            v189.CFrame = p188.main.model.parts.cylinder.CFrame
            v189.Parent = workspace.notarget
            v189.Velocity = Vector3.new(math.random(-20, 20), 60, math.random(-20, 20)) / 10
            v189.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
            p188.main.model.parts.cylinder:Destroy()
        end;
    end;
end;
v_u_101.walker_dropcap = function(p190) --[[ Line: 938 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p190.main ~= nil and (p190.cap_drop ~= nil and p190.main.model ~= nil) then
        if p190.main.model.parts:FindFirstChild("cylinder") then
            local v191 = p190.main.model.parts.cylinder:FindFirstChild("round" .. p190.cap_drop)
            if v191 and v191:FindFirstChild("cap") then
                local v192 = v_u_132(v191.cap, true, "walkercap")
                v192.CFrame = v191.cap.CFrame
                v192.Parent = workspace.notarget
            end;
        end;
    end;
end;
v_u_101.walker_setallstates = function(p193) --[[ Line: 959 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    if p193.main ~= nil and (p193.walker_states ~= nil and p193.main.model ~= nil) then
        if p193.main.model.parts:FindFirstChild("cylinder") then
            for v194 = 1, 6 do
                local v195 = p193.main.model.parts.cylinder:FindFirstChild("round" .. v194)
                local l_walker_states_0 = p193.walker_states[v194]
                if l_walker_states_0 and v195 then
                    p193.walker_slot = v194
                    p193.walker_state = l_walker_states_0
                    v_u_101.walker_setstate(p193)
                end;
            end;
        end;
    end;
end;
v_u_101.rsc_eject_casing = function(p196) --[[ Line: 1005 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    if p196.main and (p196.main.core and p196.main.core.ammo_mag > 0) then
        v_u_101.eject_livecasing(p196)
    end;
end;
v_u_101.rsc_clip_eject = function(p197) --[[ Line: 1015 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p197.main and (p197.main.model and (p197.main.model:FindFirstChild("parts") and p197.main.model.parts:FindFirstChild("clip"))) then
        v_u_132(p197.main.model.parts.clip, true, "rscclip").CFrame = p197.main.model.parts.clip.CFrame
        p197.main.model.parts.clip.Transparency = 1
        for _, v198 in ipairs(p197.main.model.parts.clip:GetChildren()) do
            if v198:IsA("BasePart") then
                v198.Transparency = 1
                v198.bullet.Transparency = 1
            end;
        end;
    end;
end;
v_u_101.crossbow_bolt_visible = function(p199) --[[ Line: 1078 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p199.transp = 0
    v_u_101.crossbow_bolt_visibility(p199)
end;
v_u_101.crossbow_bolt_invisible = function(p200) --[[ Line: 1083 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p200.transp = 1
    v_u_101.crossbow_bolt_visibility(p200)
end;
v_u_101.crossbow_lever_visible = function(p201) --[[ Line: 1097 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p201.transp = 0
    v_u_101.crossbow_lever_visibility(p201)
end;
v_u_101.crossbow_lever_invisible = function(p202) --[[ Line: 1102 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p202.transp = 1
    v_u_101.crossbow_lever_visibility(p202)
end;
v_u_101.blank_visible = function(p203) --[[ Line: 1116 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p203.transp = 0
    v_u_101.blank_visbility(p203)
end;
v_u_101.blank_invisible = function(p204) --[[ Line: 1122 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p204.transp = 1
    v_u_101.blank_visbility(p204)
end;
v_u_101.riflegrenade_discard = function(p205) --[[ Line: 1165 ]]
    --[[ Upvalues: (copy 1): v_u_132, (copy 2): v_u_101 ]]
    if p205.main ~= nil and (p205.main.model ~= nil and (p205.main.model:FindFirstChild("parts") ~= nil and p205.main.model.parts:FindFirstChild("riflegrenade") ~= nil)) then
        local v206 = v_u_132(p205.main.model.parts.riflegrenade, true, "clip")
        v206.CFrame = p205.main.model.parts.riflegrenade.CFrame
        v206.Velocity = -v206.CFrame.rightVector * 10 + Vector3.new(math.random(-50, 50), math.random(5, 10), math.random(-50, 50)) / 15
        v_u_101.riflegrenade_invisible(p205)
    end;
end;
v_u_101.casing_visible = function(p207) --[[ Line: 1178 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p207.transp = 0
    v_u_101.casing_visibility(p207)
end;
v_u_101.casing_invisible = function(p208) --[[ Line: 1184 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p208.transp = 1
    v_u_101.casing_visibility(p208)
end;
v_u_101.eject_links = function(p209) --[[ Line: 1198 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p209.main == nil or (p209.main.model == nil or (p209.main.model:FindFirstChild("parts") == nil or p209.main.model.parts:FindFirstChild("link") == nil)) then
        return;
    elseif _G.get_settings("lowgraphics") ~= true then
        local v210 = v_u_132(p209.main.model.parts.link, true, "revolver")
        v210.CFrame = p209.main.model.parts.link.CFrame
        v210.Transparency = 0
        v210.Velocity = p209.main.model.parts.link.CFrame.lookVector * 10 + Vector3.new(math.random(-20, 20), 80, math.random(-20, 20)) / 10
        v210.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
    end;
end;
v_u_101.eject_casing = function(p_u_211) --[[ Line: 1215 ]]
    --[[ Upvalues: (copy 1): v_u_101, (copy 2): v_u_132 ]]
    if p_u_211.main ~= nil and (p_u_211.main.model ~= nil and (p_u_211.main.model:FindFirstChild("parts") ~= nil and p_u_211.main.model.parts:FindFirstChild("casing") ~= nil)) then
        local l_CFrame_0 = p_u_211.main.model.special.ejection.CFrame
        local l_casing_1 = p_u_211.main.model.parts.casing
        if p_u_211.main.core and (p_u_211.main.core.blank_round_loaded and p_u_211.main.core.blank_round_loaded == true) then
            l_casing_1 = p_u_211.main.model.parts:FindFirstChild("blankcasing") or l_casing_1
        end;
        local v_u_212
        if p_u_211.main.core and (p_u_211.main.core.pedersen_device and p_u_211.main.core.pedersen_device == true) then
            l_casing_1 = p_u_211.main.model.parts.pedersenmag.casing
            v_u_212 = "pedersen"
            l_CFrame_0 = p_u_211.main.model.special.pedersenejection.CFrame
            if p_u_211.main.model:FindFirstChild("special") and p_u_211.main.model.special:FindFirstChild("jammedcasing") then
                p_u_211.main.model.special.jammedcasing.Transparency = 1
            end;
        else
            v_u_212 = nil
        end;
        if p_u_211.force_ejection_area then
            l_CFrame_0 = p_u_211.force_ejection_area
        end;
        if p_u_211.main and (p_u_211.main.core and (p_u_211.main.core.load_order ~= nil and p_u_211.main.core.load_order[1])) then
            if p_u_211.main.core.load_order[1] == "slug" then
                p_u_211.shell_colour = Color3.fromRGB(26, 25, 26)
            else
                p_u_211.shell_colour = Color3.fromRGB(202, 197, 163)
            end;
            v_u_101.set_shell_colour(p_u_211)
        end;
        local v_u_213 = v_u_132(l_casing_1, p_u_211.keep_bullet, p_u_211.stats, v_u_212)
        v_u_213.CFrame = l_CFrame_0
        v_u_213.Transparency = 0
        if v_u_213:FindFirstChild("bullet") and v_u_213.bullet:IsA("BasePart") then
            v_u_213.bullet.Transparency = 0
            if p_u_211.keep_bullet then
                v_u_213.bullet.Massless = true
            else
                v_u_213.bullet:Destroy()
            end;
        end;
        if v_u_213:FindFirstChild("bullet2") then
            if p_u_211.keep_bullet then
                v_u_213.bullet2.Massless = true
            else
                v_u_213.bullet2:Destroy()
            end;
        end;
        if p_u_211.main and (p_u_211.main.core and (p_u_211.main.core.load_order ~= nil and p_u_211.main.core.load_order[2])) then
            if p_u_211.main.core.load_order[2] == "slug" then
                p_u_211.shell_colour = Color3.fromRGB(26, 25, 26)
            else
                p_u_211.shell_colour = Color3.fromRGB(202, 197, 163)
            end;
            v_u_101.set_shell_colour(p_u_211)
        end;
        if _G.get_settings("lowgraphics") ~= true then
            local v214 = p_u_211.main.model.special.ejection:FindFirstChild("ejection_smoke")
            if v214 == nil then
                v214 = game.ReplicatedStorage.effects.ejection_smoke:Clone()
                v214.Parent = p_u_211.main.model.special.ejection
            end;
            if p_u_211.keep_bullet ~= true then
                v214:Emit(1)
            end;
        end;
        spawn(function() --[[ Line: 1309 ]]
            --[[ Upvalues: (copy 1): p_u_211, (ref 2): v_u_212, (copy 3): v_u_213 ]]
            if p_u_211.stats.ejection ~= "none" then
                local l_ejection_0 = p_u_211.stats.ejection
                if v_u_212 == "pedersen" then
                    v_u_213.Velocity = -(v_u_213.CFrame.lookVector * 2)
                elseif l_ejection_0 == "forward" then
                    v_u_213.Velocity = v_u_213.CFrame.lookVector * 15 + Vector3.new(0, 10, 0)
                elseif l_ejection_0 == "forwardleft" then
                    v_u_213.Velocity = v_u_213.CFrame.lookVector * 10 + -v_u_213.CFrame.rightVector * 15 + Vector3.new(0, 5, 0)
                elseif l_ejection_0 == "mauser" or (l_ejection_0 == "lever" or l_ejection_0 == "steyr") then
                    local l_rightVector_0 = v_u_213.CFrame.rightVector
                    if l_ejection_0 == "lever" then
                        l_rightVector_0 = v_u_213.CFrame.lookVector
                    elseif l_ejection_0 == "steyr" then
                        l_rightVector_0 = v_u_213.CFrame.upVector
                    end;
                    v_u_213.Velocity = l_rightVector_0 * 20 + Vector3.new(math.random(-50, 50), math.random(25, 50), math.random(-50, 50)) / 10
                elseif l_ejection_0 == "mpistol" then
                    v_u_213.Velocity = v_u_213.CFrame.upVector * 15 - v_u_213.CFrame.rightVector * 20 - v_u_213.CFrame.lookVector * 5 + Vector3.new(math.random(-50, 50), math.random(25, 50), math.random(-50, 50)) / 10
                elseif l_ejection_0 == "right" then
                    v_u_213.Velocity = v_u_213.CFrame.rightVector * 20 + Vector3.new(math.random(-20, 20), 80, math.random(-20, 20)) / 10
                elseif l_ejection_0 == "left" then
                    v_u_213.Velocity = -v_u_213.CFrame.rightVector * 10 + Vector3.new(math.random(-20, 20), 80, math.random(-20, 20)) / 10
                end;
                v_u_213.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * 2
            end;
        end)
    end;
end;
v_u_101.eject_livecasing = function(p215) --[[ Line: 1353 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p215.keep_bullet = true
    v_u_101.eject_casing(p215)
end;
v_u_101.eject_dynamiccasing = function(p216) --[[ Line: 1358 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    if p216.main.core.ammo_mag >= 0 then
        if p216.main.core.ammo_mag > 0 and p216.main.core.force_block_fire == false then
            p216.keep_bullet = true
        end;
        v_u_101.eject_casing(p216)
    end;
end;
v_u_101.mauser_dropammo = function(p217) --[[ Line: 1382 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): v_u_132 ]]
    for _ = 1, p217.main.core.ammo_mag - 1 do
        v_u_102:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "round_fall" .. math.random(1, 3),
            ["location"] = p217.main.model.hitbox
        }, true)
        v_u_132(p217.main.model.parts.casing, true, p217.stats).CFrame = p217.main.model.special.ejection.CFrame * CFrame.Angles(math.rad((math.random(-30, 30))), math.rad((math.random(-30, 30))), (math.rad((math.random(-30, 30)))))
        v_u_102:s_wait(0.03)
    end;
end;
v_u_101.springfield_pedersen_mag_eject = function(p218) --[[ Line: 1467 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p218.main and (p218.main.model and (p218.main.model:FindFirstChild("parts") and (p218.main.model.parts:FindFirstChild("pedersenmag") and p218.main.model.parts.pedersenmag.Transparency ~= 1))) then
        local v_u_219 = v_u_132(p218.main.model.parts.pedersenmag, true, "mag")
        if p218.main and (p218.main.core and (p218.main.core.ammo_mag and p218.main.core.ammo_mag <= 1)) then
            v_u_219.casing:Destroy()
        end;
        v_u_219.CFrame = p218.main.model.parts.pedersenmag.CFrame
        v_u_219.Velocity = v_u_219.CFrame.upVector * 5
        spawn(function() --[[ Line: 1483 ]]
            --[[ Upvalues: (copy 1): v_u_219 ]]
            v_u_219.RotVelocity = v_u_219.RotVelocity + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) / 3
        end)
        p218.main.model.parts.pedersenmag.Transparency = 1
        p218.main.model.parts.pedersenmag.casing.Transparency = 1
        p218.main.model.parts.pedersenmag.casing.bullet.Transparency = 1
    end;
end;
v_u_101.m_mag_eject = function(p220) --[[ Line: 1502 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p220.main and (p220.main.model and (p220.main.model:FindFirstChild("parts") and (p220.main.model.parts:FindFirstChild("magazine") and p220.main.model.parts.magazine.Transparency ~= 1))) then
        v_u_132(p220.main.model.parts.magazine, true, "mag").CFrame = p220.main.model.parts.magazine.CFrame
        p220.main.model.parts.magazine.Transparency = 1
        for v221 = 1, 7 do
            local v222 = p220.main.model.parts.magazine:FindFirstChild("round" .. v221)
            if v222 and v222:FindFirstChild("bullet") then
                v222.Transparency = 1
                v222.bullet.Transparency = 1
            end;
        end;
    end;
end;
v_u_101.magazine_eject_throw = function(p223) --[[ Line: 1549 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p223.thrown = true
    v_u_101.magazine_eject(p223)
end;
v_u_101.magazine_eject = function(p224) --[[ Line: 1554 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p224.main and (p224.main.model and (p224.main.model:FindFirstChild("parts") and (p224.main.model.parts:FindFirstChild("magazine") and p224.main.model.parts.magazine.Transparency ~= 1))) then
        local v_u_225 = v_u_132(p224.main.model.parts.magazine, true, "largemag")
        if p224.main and (p224.main.core and (p224.main.core.ammo_mag and (p224.main.core.ammo_mag <= 0 and v_u_225:FindFirstChild("casing")))) then
            v_u_225.casing:Destroy()
        end;
        v_u_225.CFrame = p224.main.model.parts.magazine.CFrame
        spawn(function() --[[ Line: 1570 ]]
            --[[ Upvalues: (copy 1): v_u_225 ]]
            v_u_225.RotVelocity = v_u_225.RotVelocity + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) / 3
        end)
        if p224.thrown and p224.thrown == true then
            v_u_225.Velocity = v_u_225.Velocity - v_u_225.CFrame.lookVector * 10
        end;
        p224.main.model.parts.magazine.Transparency = 1
        if p224.main.model.parts.magazine:FindFirstChild("casing") then
            p224.main.model.parts.magazine.casing.Transparency = 1
            p224.main.model.parts.magazine.casing.bullet.Transparency = 1
        end;
        if p224.main.model.parts.magazine:FindFirstChild("magparts") then
            p224.main.model.parts.magazine.magparts.Transparency = 1
        end;
        if p224.main.model.parts.magazine:FindFirstChild("spacer") then
            p224.main.model.parts.magazine.spacer.Transparency = 1
        end;
        if p224.main.model.parts.magazine:FindFirstChild("spinner") then
            p224.main.model.parts.magazine.spinner.Transparency = 1
        end;
        if p224.main.model.parts.magazine:FindFirstChild("rounds") then
            for _, v226 in ipairs(p224.main.model.parts.magazine.rounds:GetChildren()) do
                if v226:IsA("BasePart") then
                    v226.Transparency = 1
                end;
            end;
        end;
    end;
end;
v_u_101.clip_visible = function(p227) --[[ Line: 1650 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p227.visibility = 0
    v_u_101.clip_visibility(p227)
end;
v_u_101.clip_invisible = function(p228) --[[ Line: 1655 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p228.visibility = 1
    v_u_101.clip_visibility(p228)
end;
v_u_101.clip_eject = function(p229) --[[ Line: 1676 ]]
    --[[ Upvalues: (copy 1): v_u_132 ]]
    if p229.main and (p229.main.model and (p229.main.model:FindFirstChild("parts") and (p229.main.model.parts:FindFirstChild("clip") and p229.main.model.parts.clip.Transparency ~= 1))) then
        local v_u_230 = v_u_132(p229.main.model.parts.clip, true, "clip")
        v_u_230.CFrame = p229.main.model.parts.clip.CFrame
        v_u_230.bullets:Destroy()
        v_u_230.Velocity = v_u_230.CFrame.upVector * 10 + Vector3.new(math.random(-50, 50), math.random(5, 10), math.random(-50, 50)) / 15
        spawn(function() --[[ Line: 1689 ]]
            --[[ Upvalues: (copy 1): v_u_230 ]]
            v_u_230.RotVelocity = v_u_230.RotVelocity + Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)) / 2
        end)
        p229.main.model.parts.clip.Transparency = 1
        p229.main.model.parts.clip.bullets.Transparency = 1
        p229.main.model.parts.clip.bullets.bullet.Transparency = 1
        if p229.main.model.parts.clip:FindFirstChild("topbullet") then
            p229.main.model.parts.clip.topbullet.Transparency = 1
            p229.main.model.parts.clip.topbullet.bullet.Transparency = 1
        end;
    end;
end;
v_u_101.clip_eject_springfield = function(p231) --[[ Line: 1705 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): v_u_101 ]]
    if p231.main and (p231.main.model and (p231.main.model:FindFirstChild("parts") and (p231.main.model.parts:FindFirstChild("clip") and p231.main.model.parts.clip.Transparency ~= 1))) then
        p231.springfield = true
        v_u_102:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "clip_remove",
            ["pitchvariation"] = 0.1,
            ["location"] = p231.main.model.hitbox
        }, true)
        v_u_101.clip_eject(p231)
    end;
end;
v_u_101.firstaid_tweezer_throw = function(p232) --[[ Line: 1765 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_103 ]]
    if p232.main and (p232.main.model and p232.main.model:FindFirstChild("parts")) then
        local l_round_1 = p232.main.model.parts.tweezers.round
        if p232.main and (p232.main.core and p232.main.core.surgery_extra ~= nil) then
            if p232.main.core.surgery_extra == "shrapnel" then
                l_round_1 = p232.main.model.parts.tweezers.shrapnel
            elseif p232.main.core.surgery_extra == "pellet" then
                l_round_1 = p232.main.model.parts.tweezers.pellet
            end;
        end;
        l_round_1.Transparency = 1
        local v233 = l_round_1:Clone()
        s_Debris_0:AddItem(v233, 5)
        v233.Transparency = 0
        v233.CanCollide = true
        v233.CollisionGroup = "MiscCollision"
        v233.CustomPhysicalProperties = v_u_103
        v233.Parent = workspace.notarget
        v233.CFrame = l_round_1.CFrame
        v233.Velocity = v233.Velocity + p232.main.char.Torso.CFrame.lookVector * 2
    end;
end;
v_u_101.henry_offhandvisible = function(p234) --[[ Line: 1828 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p234.visibility = true
    v_u_101.henry_offhandround(p234)
end;
v_u_101.henry_offhandinvisible = function(p235) --[[ Line: 1833 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p235.visibility = false
    v_u_101.henry_offhandround(p235)
end;
v_u_101.stim_load = function(p236) --[[ Line: 1838 ]]
    --[[ Upvalues: (copy 1): v_u_102 ]]
    local v237 = p236.main and (p236.main.model and (p236.main.model:FindFirstChild("parts") and (p236.main.model:FindFirstChild("vial") and (p236.main.model:FindFirstChild("hitbox") and (p236.main.core and (p236.main.core.stim_selected and game.ReplicatedStorage.outfits.mortician:FindFirstChild("stim" .. p236.main.core.stim_selected)))))))
    if v237 then
        v_u_102:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "load",
            ["pitchvariation"] = 0.1,
            ["location"] = p236.main.model.hitbox
        }, true)
        p236.main.model.parts.vial.inside.BrickColor = v237.vial.inside.BrickColor
        p236.main.model.parts.vial.Transparency = 0.5
        p236.main.model.parts.vial.inside.Transparency = 0
        p236.main.model.parts.vial.inside.mesh.Scale = Vector3.new(1, 1, 1)
        p236.main.model.parts.vial.inside.mesh.Offset = Vector3.new(0, 0, 0)
    end;
end;
v_u_101.stim_unload = function(p238) --[[ Line: 1868 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): s_Debris_0, (copy 3): v_u_103 ]]
    if p238.main and (p238.main.model and (p238.main.model:FindFirstChild("parts") and (p238.main.model.parts:FindFirstChild("vial") and p238.main.model.parts.vial.Transparency ~= 1))) then
        v_u_102:soundHandler({
            ["directory"] = {},
            ["soundfile"] = "unload",
            ["pitchvariation"] = 0.1,
            ["location"] = p238.main.model.hitbox
        }, true)
        local v_u_239 = p238.main.model.parts.vial:Clone()
        s_Debris_0:AddItem(v_u_239, 5)
        v_u_239.CollisionGroup = "MiscCollision"
        v_u_239.CanCollide = true
        v_u_239.CanTouch = true
        p238.main.model.parts.vial.Transparency = 1
        p238.main.model.parts.vial.inside.Transparency = 1
        v_u_239.CustomPhysicalProperties = v_u_103
        v_u_239.Parent = workspace.notarget
        v_u_239.CFrame = p238.main.model.parts.vial.CFrame
        if _G.get_settings("lowgraphics") == true then
            return;
        end;
        local v_u_240 = 0
        local v_u_241 = 3
        local v_u_242 = nil
        local v_u_243 = "casings"
        local v_u_244 = "glass"
        v_u_242 = v_u_239.Touched:Connect(function(p245) --[[ Line: 178 ]]
            --[[ Upvalues: (ref 1): v_u_240, (ref 2): v_u_241, (copy 3): v_u_243, (copy 4): v_u_244, (ref 5): v_u_102, (copy 6): v_u_239, (ref 7): v_u_242 ]]
            if p245.CanQuery == true and (p245.CanCollide == true and (p245:IsDescendantOf(workspace.notarget) ~= true and (p245:IsDescendantOf(workspace.bodies) ~= true and (p245:IsDescendantOf(workspace.nation_team) ~= true and (p245:IsDescendantOf(workspace.empire_team) ~= true and tick() - v_u_240 >= 0.1))))) then
                v_u_240 = tick()
                v_u_241 = v_u_241 - 1
                local v246 = { v_u_243 }
                local v247 = v_u_244 .. math.random(1, 2)
                if (v_u_244 == "rifle" or (v_u_244 == "large" or (v_u_244 == "revolver" or v_u_244 == "shotgun"))) and p245.Material then
                    if p245.Material == Enum.Material.Wood or p245.Material == Enum.Material.WoodPlanks then
                        v247 = v_u_244 .. "_wood" .. math.random(1, 2)
                    elseif p245.Material == Enum.Material.Metal or (p245.Material == Enum.Material.CorrodedMetal or p245.Material == Enum.Material.DiamondPlate) then
                        v247 = v_u_244 .. "_metal" .. math.random(1, 2)
                    end;
                end;
                v_u_102:soundHandler({
                    ["directory"] = v246,
                    ["soundfile"] = v247,
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_239
                }, true)
                if v_u_241 <= 0 then
                    v_u_242:Disconnect()
                end;
            end;
        end)
    end;
end;
v_u_101.stim_empty_vial = function(p248) --[[ Line: 1900 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_103, (copy 3): v_u_102 ]]
    if p248.main and (p248.main.char and p248.main.char:FindFirstChild("Left Arm")) then
        local v_u_249 = game.ReplicatedStorage.outfits.mortician.stim1.vial:Clone()
        s_Debris_0:AddItem(v_u_249, 5)
        v_u_249.inside:Destroy()
        v_u_249.CollisionGroup = "MiscCollision"
        v_u_249.CanCollide = true
        v_u_249.CanTouch = true
        v_u_249.CustomPhysicalProperties = v_u_103
        v_u_249.Parent = workspace.notarget
        v_u_249.CFrame = p248.main.char["Left Arm"].CFrame - p248.main.char["Left Arm"].CFrame.upVector * 1
        if _G.get_settings("lowgraphics") == true then
            return;
        end;
        local v_u_250 = 0
        local v_u_251 = 3
        local v_u_252 = nil
        local v_u_253 = "casings"
        local v_u_254 = "glass"
        v_u_252 = v_u_249.Touched:Connect(function(p255) --[[ Line: 178 ]]
            --[[ Upvalues: (ref 1): v_u_250, (ref 2): v_u_251, (copy 3): v_u_253, (copy 4): v_u_254, (ref 5): v_u_102, (copy 6): v_u_249, (ref 7): v_u_252 ]]
            if p255.CanQuery == true and (p255.CanCollide == true and (p255:IsDescendantOf(workspace.notarget) ~= true and (p255:IsDescendantOf(workspace.bodies) ~= true and (p255:IsDescendantOf(workspace.nation_team) ~= true and (p255:IsDescendantOf(workspace.empire_team) ~= true and tick() - v_u_250 >= 0.1))))) then
                v_u_250 = tick()
                v_u_251 = v_u_251 - 1
                local v256 = { v_u_253 }
                local v257 = v_u_254 .. math.random(1, 2)
                if (v_u_254 == "rifle" or (v_u_254 == "large" or (v_u_254 == "revolver" or v_u_254 == "shotgun"))) and p255.Material then
                    if p255.Material == Enum.Material.Wood or p255.Material == Enum.Material.WoodPlanks then
                        v257 = v_u_254 .. "_wood" .. math.random(1, 2)
                    elseif p255.Material == Enum.Material.Metal or (p255.Material == Enum.Material.CorrodedMetal or p255.Material == Enum.Material.DiamondPlate) then
                        v257 = v_u_254 .. "_metal" .. math.random(1, 2)
                    end;
                end;
                v_u_102:soundHandler({
                    ["directory"] = v256,
                    ["soundfile"] = v257,
                    ["pitchvariation"] = 0.1,
                    ["location"] = v_u_249
                }, true)
                if v_u_251 <= 0 then
                    v_u_252:Disconnect()
                end;
            end;
        end)
    end;
end;
v_u_101.stimbottle_dispose = function(p258) --[[ Line: 1928 ]]
    --[[ Upvalues: (copy 1): s_Debris_0, (copy 2): v_u_103, (copy 3): v_u_102 ]]
    if p258.main and (p258.main.model and (p258.main.model:FindFirstChild("hitbox") and (p258.main.model:FindFirstChild("parts") and (p258.main.model:FindFirstChild("body") and (p258.main.model.body:FindFirstChild("bottle") and p258.main.model.parts:FindFirstChild("insidewater")))))) then
        local v259 = p258.main.model:Clone()
        s_Debris_0:AddItem(v259, 5)
        v259.hitbox.CanCollide = true
        v259.hitbox.CanTouch = true
        v259.hitbox.CollisionGroup = "MiscCollision"
        v259.hitbox.CustomPhysicalProperties = v_u_103
        p258.main.model.body.bottle.Transparency = 1
        p258.main.model.parts.insidewater.Transparency = 1
        v259.Parent = workspace.notarget
        v259.hitbox.CFrame = p258.main.model.hitbox.CFrame
        local l_hitbox_0 = v259.hitbox
        if _G.get_settings("lowgraphics") == true then
            return;
        end;
        local v_u_260 = 0
        local v_u_261 = 3
        local v_u_262 = nil
        local v_u_263 = "casings"
        local v_u_264 = "glass"
        v_u_262 = l_hitbox_0.Touched:Connect(function(p265) --[[ Line: 178 ]]
            --[[ Upvalues: (ref 1): v_u_260, (ref 2): v_u_261, (copy 3): v_u_263, (copy 4): v_u_264, (ref 5): v_u_102, (copy 6): l_hitbox_0, (ref 7): v_u_262 ]]
            if p265.CanQuery == true and (p265.CanCollide == true and (p265:IsDescendantOf(workspace.notarget) ~= true and (p265:IsDescendantOf(workspace.bodies) ~= true and (p265:IsDescendantOf(workspace.nation_team) ~= true and (p265:IsDescendantOf(workspace.empire_team) ~= true and tick() - v_u_260 >= 0.1))))) then
                v_u_260 = tick()
                v_u_261 = v_u_261 - 1
                local v266 = { v_u_263 }
                local v267 = v_u_264 .. math.random(1, 2)
                if (v_u_264 == "rifle" or (v_u_264 == "large" or (v_u_264 == "revolver" or v_u_264 == "shotgun"))) and p265.Material then
                    if p265.Material == Enum.Material.Wood or p265.Material == Enum.Material.WoodPlanks then
                        v267 = v_u_264 .. "_wood" .. math.random(1, 2)
                    elseif p265.Material == Enum.Material.Metal or (p265.Material == Enum.Material.CorrodedMetal or p265.Material == Enum.Material.DiamondPlate) then
                        v267 = v_u_264 .. "_metal" .. math.random(1, 2)
                    end;
                end;
                v_u_102:soundHandler({
                    ["directory"] = v266,
                    ["soundfile"] = v267,
                    ["pitchvariation"] = 0.1,
                    ["location"] = l_hitbox_0
                }, true)
                if v_u_261 <= 0 then
                    v_u_262:Disconnect()
                end;
            end;
        end)
    end;
end;
v_u_101.stim_pushpart = function(p268) --[[ Line: 1964 ]]
    --[[ Upvalues: (copy 1): v_u_102, (copy 2): l_RenderStepped_0 ]]
    if p268.main and (p268.main.model and (p268.main.model:FindFirstChild("hitbox") and (p268.main.model.hitbox:FindFirstChild("push") and (p268.main.model:FindFirstChild("parts") and p268.main.model.parts:FindFirstChild("vial"))))) then
        local l_push_0 = p268.main.model.hitbox.push
        local v269 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        local v270 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0, -0.6, 0)
        if p268.pushin == nil then
            v_u_102:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "pushout",
                ["location"] = p268.main.model.hitbox
            }, true)
            if l_push_0.C1 == v270 then
                return;
            end;
        else
            v_u_102:soundHandler({
                ["directory"] = {},
                ["soundfile"] = "use",
                ["location"] = p268.main.model.hitbox
            }, true)
        end;
        local v271 = tick()
        while true do
            if p268.main == nil or (p268.main.model == nil or p268.main.model:FindFirstChild("hitbox") == nil) then
                return;
            end;
            local v272 = (tick() - v271) / 0.2
            if p268.pushin == true then
                l_push_0.C1 = v270:Lerp(v269, v272)
                p268.main.model.parts.vial.inside.mesh.Scale = (Vector3.new(1, 1, 1)):Lerp(Vector3.new(0, 1, 1), v272)
                p268.main.model.parts.vial.inside.mesh.Offset = (Vector3.new(0, 0, 0)):Lerp(Vector3.new(0.3, 0, 0), v272)
            else
                l_push_0.C1 = v269:Lerp(v270, v272)
            end;
            l_RenderStepped_0:Wait()
            if tick() - v271 >= 0.2 then
                if p268.main == nil or (p268.main.model == nil or p268.main.model:FindFirstChild("hitbox") == nil) then
                    return;
                end;
                if p268.pushin == true then
                    l_push_0.C1 = v269
                    p268.main.model.parts.vial.inside.Transparency = 1
                    return;
                end;
                l_push_0.C1 = v270
                break;
            end;
        end;
    else
        -- ::l2:: (Possible bug with goto)
        return;
    end;
end;
v_u_101.hand_visibility = function(p273) --[[ Line: 2028 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    local l_char_1 = p273.main.char
    if l_char_1 ~= nil and l_char_1:FindFirstChild("Left Arm") ~= nil then
        if l_char_1 and (l_char_1:FindFirstChild("Left Arm") and (l_char_1:FindFirstChild("Right Arm") and l_char_1:FindFirstChild("Torso"))) then
            local l_Left Arm_0 = l_char_1["Left Arm"]
            if p273.main.module.lefthand == true then
                l_Left Arm_0 = l_char_1["Right Arm"]
            end;
            local v274 = l_Left Arm_0:FindFirstChild(p273.main.weapon .. "_round")
            if v274 then
                local v275 = p273.visible == true and 0 or 1
                if p273.main and (p273.main.core and (p273.main.core.ammo_mag and p273.main.core.loading_slugs ~= nil)) then
                    if p273 and (p273.main and (p273.main.model and (p273.main.model:FindFirstChild("parts") and p273.main.core.ammo_mag <= 0))) then
                        if p273.main.core.loading_slugs == true then
                            p273.shell_colour = Color3.fromRGB(26, 25, 26)
                        else
                            p273.shell_colour = Color3.fromRGB(202, 197, 163)
                        end;
                        v_u_101.set_shell_colour(p273)
                    end;
                    if p273.main.core.loading_slugs == true then
                        v274.Color = Color3.fromRGB(26, 25, 26)
                    else
                        v274.Color = Color3.fromRGB(202, 197, 163)
                    end;
                end;
                v274.Transparency = v275
                local v276 = v274:FindFirstChild("bullet")
                if v276 and v276:IsA("BasePart") then
                    v276.Transparency = v275
                end;
                local v277 = v274:FindFirstChild("bullet2")
                if v277 and v277:IsA("BasePart") then
                    v277.Transparency = v275
                end;
                local v278 = v274:FindFirstChild("int")
                if v278 and v278:IsA("BasePart") then
                    v278.Transparency = v275
                end;
            end;
        end;
    end;
end;
v_u_101.hand_shell_visible = function(p279) --[[ Line: 2087 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    p279.visible = true
    v_u_101.hand_visibility(p279)
end;
v_u_101.hand_shell_invisible = function(p280) --[[ Line: 2092 ]]
    --[[ Upvalues: (copy 1): v_u_101 ]]
    v_u_101.hand_visibility(p280)
end;
return function(p_u_281, p_u_282, p283, p284, p285) --[[ Line: 2256 ]]
    --[[ Upvalues: (copy 1): v_u_104, (copy 2): v_u_102, (copy 3): v_u_101 ]]
    p_u_282.origin = p284
    p_u_282.stats = v_u_104[p_u_282.main.weapon]
    local v_u_286 = nil
    if p285 == nil then
        v_u_102:fast_spawn(function() --[[ Line: 2264 ]]
            --[[ Upvalues: (ref 1): v_u_286, (ref 2): v_u_101, (copy 3): p_u_281, (copy 4): p_u_282 ]]
            v_u_286 = v_u_101[p_u_281](p_u_282)
        end)
    else
        v_u_286 = v_u_101[p_u_281](p_u_282)
    end;
    if p283 == nil and game:GetService("RunService"):IsServer() ~= true then
        workspace.remotes.weaponfx_relay:FireServer(p_u_281, p_u_282)
    end;
    return v_u_286;
end;
