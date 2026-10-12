local v_u_22 = {
    ["debugline"] = function(_, p1, p2, p3) --[[ Name: debugline ]] --[[ Line: 6 ]]
        local l_Part_0 = Instance.new("Part")
        game:GetService("Debris"):AddItem(l_Part_0, p3 or 1)
        l_Part_0.Material = "Neon"
        l_Part_0.BrickColor = BrickColor.new("Bright red")
        l_Part_0.Name = "debugRay"
        l_Part_0.Transparency = 0.5
        l_Part_0.Anchored = true
        l_Part_0.CanCollide = false
        l_Part_0.Locked = true
        local l_magnitude_0 = (p1 - p2).magnitude
        l_Part_0.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -l_magnitude_0 / 2)
        l_Part_0.Size = Vector3.new(0.25, 0.25, l_magnitude_0)
        l_Part_0.BrickColor = BrickColor.new("Bright red")
        l_Part_0.Material = "Neon"
        l_Part_0.Parent = workspace.notarget
        return l_Part_0;
    end,
    ["fast_spawn"] = function(_, p_u_4, ...) --[[ Name: fast_spawn ]] --[[ Line: 29 ]]
        assert(type(p_u_4) == "function")
        local v_u_5 = { ... }
        local v_u_6 = select("#", ...)
        local l_BindableEvent_0 = Instance.new("BindableEvent")
        l_BindableEvent_0.Event:Connect(function() --[[ Line: 36 ]]
            --[[ Upvalues: (copy 1): p_u_4, (copy 2): v_u_5, (copy 3): v_u_6 ]]
            p_u_4(unpack(v_u_5, 1, v_u_6))
        end)
        l_BindableEvent_0:Fire()
        l_BindableEvent_0:Destroy()
    end,
    ["lerp"] = function(_, p7, p8, p9) --[[ Name: lerp ]] --[[ Line: 44 ]]
        return p7 * (1 - p9) + p8 * p9;
    end,
    ["handle_perc"] = function(_, p10, p11) --[[ Name: handle_perc ]] --[[ Line: 55 ]]
        return p10 * (p11 / 100);
    end,
    ["soundHandler"] = function(_, p_u_12, p13) --[[ Name: soundHandler ]] --[[ Line: 59 ]]
        local l_sound_library_0 = game.ReplicatedStorage.sound_library
        if p_u_12.directory then
            for _, v14 in ipairs(p_u_12.directory) do
                l_sound_library_0 = l_sound_library_0:FindFirstChild(v14)
            end;
        end;
        local v_u_15 = l_sound_library_0:FindFirstChild(p_u_12.soundfile)
        if v_u_15 then
            if workspace.CurrentCamera and (p_u_12.location and (p_u_12.location.Parent and (p_u_12.location.Parent:IsA("BasePart") and (workspace.CurrentCamera.CFrame.p - p_u_12.location.Parent.Position).magnitude > v_u_15.RollOffMaxDistance + 50))) then
                return;
            end;
            v_u_15 = v_u_15:Clone()
            if p_u_12.pitch then
                v_u_15.Pitch = p_u_12.pitch
            end;
            if p_u_12.pitchvariation and typeof(p_u_12.pitchvariation) == "number" then
                v_u_15.Pitch = v_u_15.Pitch + math.random(-p_u_12.pitchvariation * 100, p_u_12.pitchvariation * 100) / 100
            end;
            if p_u_12.pitch_adjust then
                v_u_15.Pitch = v_u_15.Pitch + p_u_12.pitch_adjust
            end;
            if p_u_12.volume_adjust then
                v_u_15.Volume = v_u_15.Volume + math.clamp(p_u_12.volume_adjust, -1.5, 1.5)
            end;
            if p_u_12.client_volume and p13 ~= true then
                v_u_15.Volume = v_u_15.Volume + p_u_12.client_volume
            end;
            if p_u_12.gun_volume and (p_u_12.gun_volume == true and (_G.get_settings and _G.get_settings("reducegunvolume") == true)) then
                v_u_15.Volume = v_u_15.Volume * 0.7
            end;
            if game.Players.LocalPlayer and (game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("loadingmenu")) then
                v_u_15.Volume = v_u_15.Volume / 10
            end;
            if p_u_12.force_max_dist and p_u_12.force_max_dist <= v_u_15.RollOffMaxDistance then
                v_u_15.RollOffMinDistance = p_u_12.force_max_dist / 3
                v_u_15.RollOffMaxDistance = p_u_12.force_max_dist
                v_u_15.RollOffMaxDistance = math.clamp(v_u_15.RollOffMaxDistance, 0, 100)
                v_u_15.RollOffMinDistance = math.clamp(v_u_15.RollOffMinDistance, 0, 100)
            end;
            if p_u_12.location then
                v_u_15.Parent = p_u_12.location
            else
                v_u_15.Parent = workspace
            end;
            if p_u_12.soundgroup then
                if p_u_12.soundgroup == "none" then
                    v_u_15.SoundGroup = nil
                else
                    v_u_15.SoundGroup = game:GetService("SoundService"):FindFirstChild(p_u_12.soundgroup)
                end;
            else
                v_u_15.SoundGroup = game:GetService("SoundService"):FindFirstChild("mainSoundGroup")
            end;
            v_u_15:Play()
            if v_u_15.Looped == false then
                spawn(function() --[[ Line: 136 ]]
                    --[[ Upvalues: (copy 1): p_u_12, (ref 2): v_u_15 ]]
                    if p_u_12.location then
                        local v16 = 1
                        for _, v17 in ipairs(p_u_12.location:GetChildren()) do
                            local v18
                            if v17.Name == v_u_15.Name then
                                v16 = v16 + 1
                                v18 = true
                            else
                                v18 = false
                            end;
                            if v16 >= 8 and (v17 ~= v_u_15 and (v17:IsA("Sound") and (v17.TimePosition > 0.1 and v18 == true))) then
                                v17:Destroy()
                            end;
                        end;
                    end;
                end)
                v_u_15.Ended:connect(function() --[[ Line: 151 ]]
                    --[[ Upvalues: (ref 1): v_u_15 ]]
                    v_u_15:Destroy()
                end)
            end;
        end;
        if p13 ~= true and game:GetService("RunService"):IsServer() ~= true then
            workspace.remotes.audio_relay:FireServer(p_u_12)
        end;
        return v_u_15;
    end,
    ["randomiseTbl"] = function(_, p19) --[[ Name: randomiseTbl ]] --[[ Line: 259 ]]
        local v20 = {}
        if p19[1] ~= nil then
            for v21 = 1, #p19 do
                table.insert(v20, math.random(1, #v20 + 1), p19[v21])
            end;
        end;
        return v20;
    end
}
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local l_remotes_0 = workspace.remotes
v_u_22.s_wait = function(_, p23) --[[ Name: s_wait ]] --[[ Line: 48 ]]
    --[[ Upvalues: (copy 1): l_RenderStepped_0 ]]
    local v24 = tick()
    repeat
        l_RenderStepped_0:wait()
    until p23 < tick() - v24;
end;
v_u_22.deepCopy = function(_, p25) --[[ Name: deepCopy ]] --[[ Line: 164 ]]
    --[[ Upvalues: (copy 1): v_u_22 ]]
    local v26 = {}
    for v27, v29 in pairs(p25) do
        if type(v29) == "table" then
            local v29 = v_u_22:deepCopy(v29)
        end;
        v26[v27] = v29
    end;
    return v26;
end;
v_u_22.raycastline = function(_, p30) --[[ Name: raycastline ]] --[[ Line: 175 ]]
    --[[ Upvalues: (copy 1): l_remotes_0 ]]
    local v31 = p30.layermask == nil and {} or p30.layermask
    local v32 = {}
    for _ = 1, 20 do
        local v33, v34, v35, v36 = workspace:FindPartOnRayWithIgnoreList(Ray.new(p30.point, p30.destination.unit * (p30.range or 999.999)), v32)
        if not v33 or v33 == workspace.Terrain then
            return v33, v34, v35, v36;
        end;
        local v37 = true
        for _, v38 in pairs(v31) do
            if v33:IsDescendantOf(v38) or v33 == v38 then
                table.insert(v32, v33)
                v37 = false
            end;
        end;
        if v33:IsA("Truss") then
            table.insert(v32, v33)
            v37 = false
        end;
        if v33.Locked == true then
            v33:FindFirstChild("clicker")
            table.insert(v32, v33)
            v37 = false
        end;
        if p30.flamer and (p30.flamer == true and (v33.Parent and (v33.Parent.Parent and (v33.Parent.Name == "Barbed Wire" or v33.Parent.Parent.Name == "Barbed Wire")))) then
            table.insert(v32, v33)
            v37 = false
        end;
        if v33.Name == "bullet_whizz" and p30.get_whizzbox ~= true then
            if p30.bullet then
                local v39 = game.Players:GetPlayerFromCharacter(v33.Parent)
                if v39 and v39 ~= game.Players.LocalPlayer then
                    l_remotes_0.game_handler:FireServer(p30.atmos and p30.atmos == "suppressor" and "flich_target_nosnap" or "flinch_target", v39, p30.point)
                end;
            end;
            table.insert(v32, v33)
            v37 = false
        end;
        if v33.Name == "click" then
            table.insert(v32, v33)
            v37 = false
        end;
        if p30.get_clicker == true then
            table.insert(v32, v33)
            v37 = v33 and v33:FindFirstChild("clicker") and true or false
        end;
        if v37 == true then
            return v33, v34, v35, v36;
        end;
    end;
end;
v_u_22.inLoS = function(_, p40) --[[ Name: inLoS ]] --[[ Line: 271 ]]
    --[[ Upvalues: (copy 1): v_u_22 ]]
    return v_u_22:raycastline({
        ["point"] = p40.pointB,
        ["destination"] = -(p40.pointB - p40.pointA),
        ["range"] = p40.range,
        ["layermask"] = p40.mask,
        ["hit_locked"] = p40.hit_locked
    });
end;
return v_u_22;
