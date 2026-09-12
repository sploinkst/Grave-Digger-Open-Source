local l_Parent_0 = script.Parent
local l_LocalPlayer_0 = game.Players.LocalPlayer
local l_Character_0 = l_LocalPlayer_0.Character
local l_CurrentCamera_0 = workspace.CurrentCamera
local v_u_1 = require(game.ReplicatedStorage.shared.bFunctions)
local l_remotes_0 = workspace.remotes
local v_u_2 = l_Character_0:WaitForChild("action", 100)
local l_RenderStepped_0 = game:GetService("RunService").RenderStepped
local s_UserInputService_0 = game:GetService("UserInputService")
local v_u_3 = require(game.ReplicatedStorage.shared.visualEffects)
local v_u_4 = require(game.ReplicatedStorage.shared.weaponEffects)
local v_u_5 = false
local v_u_6 = l_LocalPlayer_0:GetMouse()
local l_Value_0 = l_Parent_0:WaitForChild("weapon", 100).Value
local l_Value_1 = l_Parent_0:WaitForChild("model", 100).Value
local v_u_7 = v_u_1:deepCopy(require(game.ReplicatedStorage.weapon_modules:FindFirstChild(l_Value_0)))
local l_core_game_0 = l_LocalPlayer_0.PlayerGui:FindFirstChild("main").core_game
local v_u_8 = require(game.ReplicatedStorage.shared.base)
local v_u_9 = l_Character_0:WaitForChild("Humanoid", 100)
local v_u_10
if v_u_7.variant == "" then
	v_u_10 = ""
else
	v_u_10 = l_Value_0
	v_u_7 = v_u_1:deepCopy(require(game.ReplicatedStorage.weapon_modules:FindFirstChild(v_u_10)))
	l_Value_0 = v_u_7.variant
end;
local v_u_11 = {}
local l_core_checkers_0 = _G.core_checkers
local v_u_12 = {
	["draw"] = tick(),
	["firing_ticker"] = tick(),
	["aim_sound"] = false,
	["equipped"] = false,
	["fire_buffer"] = 0,
	["fire_buffer_type"] = false,
	["state"] = "normal",
	["interrupt_reload"] = false,
	["shorted"] = false,
	["alt_mode"] = false,
	["alt_cd"] = tick(),
	["construction_mode"] = false,
	["constructing"] = "Barricade",
	["construct_holo"] = nil,
	["construct_pos"] = nil,
	["construct_ready"] = false,
	["construct_cd"] = tick(),
	["construct_constructions"] = {},
	["extra_bb"] = nil,
	["slide_locked"] = false,
	["alt_slide_locked"] = false,
	["no_steady_acc"] = false,
	["dual_wield_active"] = false,
	["dropped"] = false
}
if v_u_7.tooltype == "stims" or v_u_7.tooltype == "firstaid" then
	v_u_12.stimulants = require(game.ReplicatedStorage.shared.stimulants)
	if v_u_7.tooltype == "stims" then
		spawn(function() --[[ Line: 72 ]]
			--[[ Upvalues: (copy 1): l_core_checkers_0, (copy 2): v_u_12 ]]
			for v13 = 1, 6 do
				l_core_checkers_0.create_selectionbox(v_u_12.stimulants[v13].name, v13, v_u_12.stimulants[v13].icon, nil, v13)
			end;
		end)
	end;
end;
if v_u_7.tooltype == "whistle" then
	if _G.whistle_at == nil then
		_G.whistle_at = "advance"
	end;
	l_core_checkers_0.create_selectionbox("Advance Order", "advance", 81453171147177, "1advance", 1)
	l_core_checkers_0.create_selectionbox("Defend Order", "defend", 110211160912800, "2defend", 2)
	l_core_checkers_0.create_selectionbox("Focus Order", "focus", 138309011037793, "3focus", 3)
end;
local l_BindableEvent_0 = Instance.new("BindableEvent")
l_BindableEvent_0.Name = "event"
l_BindableEvent_0.Parent = l_Parent_0
local v_u_14 = false
local v_u_15 = tick()
if l_Value_0 == "lewis" or l_Value_0 == "enfield" and v_u_10 == "enfieldvariant" then
	if l_Value_0 == "lewis" then
		v_u_12.no_steady_acc = true
	end;
	local l_NumberValue_0 = Instance.new("NumberValue")
	l_NumberValue_0.Name = "bipod"
	l_NumberValue_0.Value = 0
	l_NumberValue_0.Parent = l_Parent_0
end;
if l_Value_0 == "pickaxe" then
	v_u_12.durability_max = 40
	v_u_12.sharpening_stones = 1
	local l_IntValue_0 = Instance.new("IntValue")
	l_IntValue_0.Name = "durability"
	l_IntValue_0.Value = v_u_12.durability_max
	l_IntValue_0.Parent = l_Parent_0
end;
if (l_Value_0 == "mosin" or l_Value_0 == "binocs") and v_u_10 == "" then
	local l_BoolValue_0 = Instance.new("BoolValue")
	l_BoolValue_0.Name = "scoped"
	l_BoolValue_0.Value = true
	l_BoolValue_0.Parent = l_Parent_0
	if l_Value_0 == "mosin" and (l_core_checkers_0.mosin_scope == nil and _G.get_settings("disablevolkscope") ~= true) then
		l_core_checkers_0.mosin_scope = game.ReplicatedStorage.misc.mosinscope:Clone()
	end;
end;
if l_Value_0 == "vanguardshield" then
	local l_BoolValue_1 = Instance.new("BoolValue")
	l_BoolValue_1.Name = "guarding"
	l_BoolValue_1.Value = false
	l_BoolValue_1.Parent = l_Parent_0
	local l_IntValue_1 = Instance.new("IntValue")
	l_IntValue_1.Name = "shield_supplies"
	l_IntValue_1.Value = 2
	l_IntValue_1.Parent = l_Parent_0
	if l_Character_0.perk.Value == "extrainv" then
		l_IntValue_1.Value = 3
	end;
	local l_IntValue_2 = Instance.new("IntValue")
	l_IntValue_2.Name = "max"
	l_IntValue_2.Value = l_IntValue_1.Value
	l_IntValue_2.Parent = l_IntValue_1
end;
local l_ammo_give_0 = v_u_7.ammo_give
if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] then
	local v16 = l_ammo_give_0 .. "_max"
	l_core_checkers_0[v16] = l_core_checkers_0[v16] + v_u_7.capacity * math.floor((math.clamp(v_u_7.ammo_reserves_max * l_Character_0.extra_ammo.Value - 1, 1, 10)))
	local v17 = l_ammo_give_0 .. "_reserves"
	l_core_checkers_0[v17] = l_core_checkers_0[v17] + v_u_7.capacity * math.floor((math.clamp(v_u_7.ammo_reserves * l_Character_0.extra_ammo.Value - 1, 1, 10)))
else
	l_core_checkers_0[l_ammo_give_0 .. "_max"] = v_u_7.capacity * math.floor(v_u_7.ammo_reserves_max * l_Character_0.extra_ammo.Value)
	l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = v_u_7.capacity * math.floor(v_u_7.ammo_reserves * l_Character_0.extra_ammo.Value)
end;
if v_u_7.ammo_reserves_max == 200 then
	l_core_checkers_0[l_ammo_give_0 .. "_max"] = 20000
	l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = 20000
end;
if l_Character_0.perk.Value == "vet" then
	l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_max"]
end;
local v_u_18
if workspace.serverStuff.values.gamemode.Value == "train" and workspace.serverStuff:FindFirstChild("game_setup") then
	v_u_18 = workspace.serverStuff.game_setup:FindFirstChild("trains")
else
	v_u_18 = nil
end;
local v_u_19 = {
	["ammo_mag"] = v_u_7.capacity,
	["force_block_fire"] = false,
	["alt_extra"] = false,
	["need_bolt"] = false
}
if workspace.serverStuff.trainingmode.Value == true and l_Value_0 == "lebel" then
	l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = 0
	v_u_19.ammo_mag = 0
end;
if l_Character_0.perk.Value == "vet" and v_u_7.chamber == true then
	v_u_19.ammo_mag = v_u_19.ammo_mag + 1
end;
if v_u_7.emplacement == true or l_Value_0 == "browningmg" then
	v_u_12.no_steady_acc = true
	v_u_19.ammo_mag = math.random(50, 70)
end;
local v20 = workspace.serverStuff:WaitForChild("empire_spawnroom", 100)
local v21 = workspace.serverStuff:WaitForChild("nation_spawnroom", 100)
local v22 = v20:FindFirstChild("empire_spawnprot")
if l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
	v22 = v21:FindFirstChild("nation_spawnprot")
end;
local v_u_23 = {
	workspace.notarget,
	workspace.evacs,
	workspace.throwables,
	workspace.bodies,
	l_Character_0,
	l_Character_0.Parent,
	l_CurrentCamera_0,
	v22
}
local v_u_24 = {
	workspace.notarget,
	workspace.evacs,
	workspace.throwables,
	l_Character_0,
	l_Character_0.Parent,
	l_CurrentCamera_0,
	v22
}
if _G.get_settings and _G.get_settings("disablebodyshoot") == true then
	table.insert(v_u_24, workspace.bodies)
end;
local v_u_25 = {
	workspace.notarget,
	workspace.evacs,
	workspace.bodies,
	workspace.throwables,
	l_Character_0,
	l_CurrentCamera_0,
	v22
}
local v_u_26 = {
	workspace.notarget,
	workspace.evacs,
	workspace.bodies,
	workspace.throwables,
	l_Character_0,
	l_CurrentCamera_0,
	workspace.nation_team,
	workspace.empire_team,
	v22
}
local v_u_27 = {
	workspace.notarget,
	workspace.evacs,
	workspace.bodies,
	workspace.throwables,
	l_Character_0,
	l_CurrentCamera_0,
	workspace.nation_team,
	workspace.empire_team,
	v22,
	workspace.constructions
}
local v_u_28 = nil
local v_u_29 = nil
local v30 = {
	["Barricade"] = "130926719066828",
	["Palisade"] = "131075569490508",
	["Sandbags"] = "129709621621618",
	["Barbed Wire"] = "92239986631707",
	["Cache"] = "106638603044659",
	["Tin Bomb"] = "89266402201210",
	["Gas Shell"] = "81547229510246",
	["Mantrap"] = "134767166459938",
	["Dynamite Stack"] = "114916851365951",
	["Shotshell Trap"] = "91573950154593",
	["Light Lure"] = "81497413008362"
}
local v_u_31
if v_u_7.tooltype == "hammer" or v_u_7.tooltype == "jaegerkit" then
	local v32 = {
		workspace.notarget,
		l_Character_0,
		l_Character_0.Parent,
		l_CurrentCamera_0,
		v22,
		workspace.bodies,
		workspace.empire_team,
		workspace.nation_team,
		workspace.pings
	}
	if v_u_7.tooltype == "hammer" then
		table.insert(v_u_26, workspace.constructions)
	end;
	for _, v33 in ipairs(workspace.serverStuff.objectives:GetChildren()) do
		if v33:FindFirstChild("capture") then
			table.insert(v32, v33.capture)
		end;
	end;
	v_u_31 = OverlapParams.new()
	v_u_31.FilterDescendantsInstances = v32
	v_u_31.FilterType = Enum.RaycastFilterType.Exclude
	v_u_31.MaxParts = 10
	local v34 = game.ReplicatedStorage.misc.constructionbb:Clone()
	v34.bb.Enabled = false
	v34.Parent = l_CurrentCamera_0
	v_u_12.extra_bb = v34
	for v35, _ in pairs(v_u_8.base_constructs) do
		if v35 ~= "Barricade" then
			table.insert(v_u_12.construct_constructions, v35)
		end;
	end;
	if v_u_7.tooltype == "jaegerkit" then
		v_u_12.los_tripwire = Instance.new("Part")
		v_u_12.los_tripwire.Anchored = true
		v_u_12.los_tripwire.Color = Color3.new(0.9, 0.9, 0.9)
		v_u_12.los_tripwire.Material = Enum.Material.SmoothPlastic
		v_u_12.los_tripwire.Transparency = 0.5
		v_u_12.los_tripwire.CanCollide = false
		v_u_12.los_tripwire.CanQuery = false
		v_u_12.construction_mode = true
		v_u_12.constructing = "Mantrap"
		v_u_12.construct_constructions = {
			"Mantrap",
			"Tin Bomb",
			"Gas Shell",
			"Dynamite Stack",
			"Shotshell Trap",
			"Light Lure"
		}
	end;
	for v36, v37 in ipairs(v_u_12.construct_constructions) do
		if l_core_game_0.selectionboxes.selections:FindFirstChild(v37) == nil then
			l_core_checkers_0.create_selectionbox(v37, v37, v30[v37], nil, v36)
		end;
	end;
else
	v_u_31 = nil
end;
if v_u_7.tooltype == "flamer" then
	local l_empire_team_0 = workspace.empire_team
	if l_LocalPlayer_0.Team == game.Teams["Golden Empire"] then
		l_empire_team_0 = workspace.nation_team
	end;
	v_u_31 = OverlapParams.new()
	v_u_31.FilterDescendantsInstances = { l_empire_team_0 }
	v_u_31.FilterType = Enum.RaycastFilterType.Include
	v_u_31.MaxParts = 20
	v_u_12.flamer_fuel = 900
	v_u_12.flamer_fuel_max = v_u_12.flamer_fuel
end;
local function _() --[[ Line: 319 ]]
	--[[ Upvalues: (ref 1): l_Value_0, (ref 2): v_u_10, (copy 3): l_Character_0, (copy 4): l_Value_1, (ref 5): v_u_7, (ref 6): v_u_19 ]]
	local v38 = l_Value_0
	if v_u_10 ~= "" then
		v38 = v_u_10
	end;
	return {
		["char"] = l_Character_0,
		["originweapon"] = v38,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	};
end;
if l_Value_0 == "mpistol" then
	local v39 = "m_mag_update"
	local v40 = {}
	local v41
	if v_u_10 == "" then
		v41 = l_Value_0
	else
		v41 = v_u_10
	end;
	v40.main = {
		["char"] = l_Character_0,
		["originweapon"] = v41,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v_u_4(v39, v40)
end;
if l_Value_0 == "walker" then
	v_u_12.no_steady_acc = true
	if _G["walkerstate" .. l_Parent_0.slot.Value] == nil or _G["walkercylinder" .. l_Parent_0.slot.Value] == nil then
		_G["walkerstate" .. l_Parent_0.slot.Value] = {
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			},
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			},
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			},
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			},
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			},
			{
				["cap"] = false,
				["ball"] = false,
				["powder"] = false
			}
		}
		_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
	end;
	local v42 = "walker_setallstates"
	local v43 = {}
	local v44
	if v_u_10 == "" then
		v44 = l_Value_0
	else
		v44 = v_u_10
	end;
	v43.main = {
		["char"] = l_Character_0,
		["originweapon"] = v44,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v43.walker_states = _G["walkerstate" .. l_Parent_0.slot.Value]
	v_u_4(v42, v43)
	local v45 = "walker_setcylinder"
	local v46 = {}
	local v47
	if v_u_10 == "" then
		v47 = l_Value_0
	else
		v47 = v_u_10
	end;
	v46.main = {
		["char"] = l_Character_0,
		["originweapon"] = v47,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v46.cylinder_state = _G["walkercylinder" .. l_Parent_0.slot.Value]
	v_u_4(v45, v46)
end;
local v_u_48
if v_u_7.tooltype == "gun" then
	local v49 = l_Value_1:WaitForChild("special", 100):WaitForChild("muzzle", 100)
	v_u_48 = game.ReplicatedStorage.misc.barrelwarning:Clone()
	v_u_48.Parent = l_CurrentCamera_0
	local l_Attachment_0 = Instance.new("Attachment")
	l_Attachment_0.Parent = v49
	local l_Attachment_1 = Instance.new("Attachment")
	l_Attachment_1.Parent = v_u_48
	v_u_48.warningbeam.Attachment0 = l_Attachment_0
	v_u_48.warningbeam.Attachment1 = l_Attachment_1
	local l_BoolValue_2 = Instance.new("BoolValue")
	l_BoolValue_2.Name = "pistol"
	l_BoolValue_2.Parent = l_Parent_0
	if v_u_7.size == 1 then
		l_BoolValue_2.Value = true
	end;
	local l_BoolValue_3 = Instance.new("BoolValue")
	l_BoolValue_3.Name = "empty_ammo"
	l_BoolValue_3.Value = false
	l_BoolValue_3.Parent = l_Parent_0
	local l_BoolValue_4 = Instance.new("BoolValue")
	l_BoolValue_4.Name = "left_aiming"
	l_BoolValue_4.Value = false
	l_BoolValue_4.Parent = l_Parent_0
	if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
		l_BoolValue_3.Value = true
	end;
else
	v_u_48 = nil
end;
local l_keysheld_0 = _G.keysheld
local function _() --[[ Line: 491 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_11, (copy 3): l_Parent_0 ]]
	v_u_12.slide_locked = true
	local l_locked_0 = v_u_11.locked
	if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) then
		l_locked_0 = v_u_11.akimbo_locked
	end;
	if l_locked_0 then
		l_locked_0:Play(0.1)
	end;
end;
local function v61(p50, p51, p52) --[[ Line: 505 ]]
	--[[ Upvalues: (ref 1): l_Value_0, (copy 2): v_u_11, (copy 3): v_u_9, (copy 4): v_u_1, (copy 5): l_Character_0, (copy 6): v_u_4, (ref 7): v_u_10, (copy 8): l_Value_1, (ref 9): v_u_7, (ref 10): v_u_19, (copy 11): v_u_3, (copy 12): v_u_12, (copy 13): l_Parent_0, (copy 14): l_remotes_0, (copy 15): l_core_checkers_0, (copy 16): l_ammo_give_0 ]]
	local v_u_53 = p51 or l_Value_0
	local v54
	if p50:IsA("ObjectValue") then
		v54 = p50.Value
	else
		v54 = p50
	end;
	local v55 = p52 or p50.Name
	v_u_11[v55] = v_u_9:LoadAnimation(v54)
	v_u_11[v55].KeyframeReached:connect(function(p56) --[[ Line: 520 ]]
		--[[ Upvalues: (ref 1): l_Value_0, (ref 2): v_u_53, (ref 3): v_u_1, (ref 4): l_Character_0, (ref 5): v_u_4, (ref 6): v_u_10, (ref 7): l_Value_1, (ref 8): v_u_7, (ref 9): v_u_19, (ref 10): v_u_3, (ref 11): v_u_12, (ref 12): v_u_11, (ref 13): l_Parent_0, (ref 14): l_remotes_0, (ref 15): l_core_checkers_0, (ref 16): l_ammo_give_0 ]]
		if string.sub(p56, 1, 3) == "sfx" then
			if l_Value_0 == "mausercarbine" then
				v_u_53 = "mauser"
			end;
			if l_Value_0 == "mares" then
				v_u_53 = "lever"
			end;
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = string.sub(p56, 5, 100),
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			return;
		elseif string.sub(p56, 1, 3) == "vfx" then
			local v57 = v_u_4
			local v58 = string.sub(p56, 5, 100)
			local v59 = {}
			local v60 = l_Value_0
			if v_u_10 ~= "" then
				v60 = v_u_10
			end;
			v59.main = {
				["char"] = l_Character_0,
				["originweapon"] = v60,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v57(v58, v59)
		elseif string.sub(p56, 1, 4) == "gsfx" then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = string.sub(p56, 6, 100) .. math.random(1, #game.ReplicatedStorage.sound_library.tools.shared.gsfx:FindFirstChild((string.sub(p56, 6, 100))):GetChildren()),
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			if string.sub(p56, 6, 100) == "sharpen" then
				v_u_3("sharpening_spark", {
					["part"] = l_Character_0["Left Arm"]
				})
				return;
			end;
		elseif p56 == "lock_start" then
			v_u_12.slide_locked = true
			local l_locked_1 = v_u_11.locked
			if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) then
				l_locked_1 = v_u_11.akimbo_locked
			end;
			if l_locked_1 then
				l_locked_1:Play(0.1)
				return;
			end;
		elseif p56 == "lock_end" then
			v_u_12.slide_locked = false
			v_u_11.locked:Stop(0.05)
			if v_u_11.akimbo_locked then
				v_u_11.akimbo_locked:Stop(0.05)
				return;
			end;
		else
			if p56 == "alt_lock_start" then
				v_u_12.alt_slide_locked = true
				v_u_11.locked_alt:Play(0.1)
				return;
			end;
			if p56 == "alt_lock_end" then
				v_u_12.alt_slide_locked = false
				v_u_11.locked_alt:Stop(0.05)
				return;
			end;
			if p56 == "crossbow_update_quiver" and l_Value_0 == "crossbow" then
				l_remotes_0.game_handler:FireServer("update_quiver", l_core_checkers_0[l_ammo_give_0 .. "_reserves"])
			end;
		end;
	end)
	v_u_11[v55].Priority = Enum.AnimationPriority.Action3
end;
local function f_updateCharacterTransparency() --[[ Name: updateCharacterTransparency ]] --[[ Line: 419 ]]
	--[[ Upvalues: (ref 1): v_u_5, (ref 2): l_Value_0, (copy 3): l_core_checkers_0, (copy 4): l_LocalPlayer_0, (copy 5): v_u_12, (copy 6): l_CurrentCamera_0, (copy 7): l_Value_1, (copy 8): l_Character_0 ]]
	if v_u_5 ~= true then
		local v62 = l_core_checkers_0.mosin_scope ~= nil and l_core_checkers_0.mosin_scope.Parent == l_CurrentCamera_0 and 1 or (_G.get_settings("disabletransparent") == true and 0 or (l_Value_0 == "vanguardshield" and (l_core_checkers_0.aiming == true or v_u_12.alt_mode == true) and 0.75 or (l_Value_0 == "binocs" and (l_core_checkers_0.aiming == true and l_LocalPlayer_0.CameraMode == Enum.CameraMode.LockFirstPerson) and 0.9 or 0)))
		for _, v63 in ipairs(l_Value_1:GetDescendants()) do
			if v63:IsA("BasePart") then
				v63.LocalTransparencyModifier = v62
			end;
		end;
		if v_u_12.dual_wield_tool and v_u_12.dual_wield_tool:FindFirstChild("model") then
			for _, v64 in ipairs(v_u_12.dual_wield_tool.model.Value:GetDescendants()) do
				if v64:IsA("BasePart") then
					v64.LocalTransparencyModifier = 0
				end;
			end;
		end;
		if l_Character_0 and (l_Character_0:FindFirstChild("Left Arm") and l_Character_0:FindFirstChild("Right Arm")) then
			local v65 = l_Character_0["Left Arm"]:FindFirstChild(l_Value_0 .. "_round") or l_Character_0["Right Arm"]:FindFirstChild(l_Value_0 .. "_round")
			if v65 then
				v65.LocalTransparencyModifier = 0
				local v66 = v65:FindFirstChild("bullet")
				if v66 then
					v66.LocalTransparencyModifier = 0
				end;
				local v67 = v65:FindFirstChild("bullet2")
				if v67 then
					v67.LocalTransparencyModifier = 0
				end;
				local v68 = v65:FindFirstChild("int")
				if v68 then
					v68.LocalTransparencyModifier = 0
				end;
			end;
			if l_Value_0 == "walker" then
				local v69 = l_Character_0["Left Arm"]:FindFirstChild("walkercapper")
				if v69 and v69:FindFirstChild("cap") then
					v69.LocalTransparencyModifier = 0
					v69.cap.LocalTransparencyModifier = 0
				end;
				local v70 = l_Character_0["Left Arm"]:FindFirstChild("walkergunpowder")
				if v70 and v70:FindFirstChild("brass") then
					v70.LocalTransparencyModifier = 0
					v70.brass.LocalTransparencyModifier = 0
				end;
			end;
		end;
	end;
end;
for _, v71 in ipairs(game.ReplicatedStorage.animations.tools:FindFirstChild(l_Value_0):GetChildren()) do
	v61(v71)
end;
if l_Value_0 == "lever" and v_u_10 == "levervariant" then
	v_u_11.aim = v_u_11.alt_changeaim
	v_u_11.aim_left = v_u_11.alt_changeaim_left
	v_u_11.fire = v_u_11.alt_changefire
	v_u_11.fire_empty = v_u_11.alt_changefire_empty
	v_u_11.fire_empty_left = v_u_11.alt_changefire_empty_left
	v_u_11.fire_last = v_u_11.alt_changefire_last
	v_u_11.fire_last_left = v_u_11.alt_changefire_last_left
	v_u_11.fire_left = v_u_11.alt_changefire_left
	v_u_12.no_steady_acc = true
end;
if l_Value_0 == "autosg" and v_u_10 == "autosgvariant" then
	v_u_11.aim = v_u_11.alt_changeaim
	v_u_11.aim_left = v_u_11.alt_changeaim_left
	v_u_11.fire = v_u_11.alt_changefire
	v_u_11.fire_last = v_u_11.alt_changefire_last
	v_u_11.fire_last_left = v_u_11.alt_changefire_last_left
	v_u_11.fire_left = v_u_11.alt_changefire_left
end;
if l_Value_0 == "remington" and v_u_10 == "remingtonvariant" then
	v_u_11.draw = v_u_11.long_draw
	v_u_11.aim = v_u_11.long_aim
	v_u_11.aim_left = v_u_11.long_aim_left
	v_u_11.held = v_u_11.long_held
	v_u_11.fire = v_u_11.long_fire
	v_u_11.fire_left = v_u_11.long_fire_left
	v_u_11.melee1 = v_u_11.long_melee1
	v_u_11.melee2 = v_u_11.long_melee2
	v_u_11.short = v_u_11.long_short
	v_u_11.check = v_u_11.long_check
	v_u_11.sprint = v_u_11.long_sprint
	v_u_11.sprint_greyhound = nil
end;
if l_Value_0 == "dbgun" and v_u_10 == "dbgunvariant" then
	v_u_11.sprint_greyhound = v_u_11.sprint_alt_greyhound
end;
if l_Value_0 == "steyr" and v_u_10 == "steyrvariant" then
	v_u_12.no_steady_acc = true
	v_u_11.draw = v_u_11.steyrdraw
	v_u_11.aim = v_u_11.alt_changeaim
	v_u_11.aim_left = v_u_11.alt_changeaim_left
	v_u_11.fire = v_u_11.alt_changefire
	v_u_11.fire_left = v_u_11.alt_changefire_left
end;
if l_Value_0 == "saa" and v_u_10 == "saavariant" then
	v_u_11.draw = v_u_11.stock_draw
	v_u_11.aim = v_u_11.stock_aim
	v_u_11.aim_left = v_u_11.stock_aim_left
	v_u_11.fire = v_u_11.stock_fire
	v_u_11.fire_left = v_u_11.stock_fire_left
	v_u_11.fire_empty = v_u_11.stock_fire_empty
	v_u_11.fire_empty_left = v_u_11.stock_fire_empty_left
end;
if l_Value_0 == "springfield" and (v_u_10 == "" and _G.get_settings("pedersenstart") == true) then
	if v_u_12.pedersen_mag == nil then
		v_u_12.pedersen_mag = 0
		if v_u_12.extra_mag == nil then
			v_u_12.extra_mag = false
		end;
		v_u_12.initial_mag = true
	end;
	if v_u_12.pedersen_mag == 0 then
		if v_u_12.initial_mag == false then
			v_u_12.extra_mag = false
		end;
		v_u_12.initial_mag = false
		v_u_12.pedersen_mag = 40
	end;
	local v72 = "springfield_pedersen_on"
	local v73 = {}
	local v74
	if v_u_10 == "" then
		v74 = l_Value_0
	else
		v74 = v_u_10
	end;
	v73.main = {
		["char"] = l_Character_0,
		["originweapon"] = v74,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v_u_4(v72, v73)
	local v75 = "springfield_bolt_off"
	local v76 = {}
	local v77
	if v_u_10 == "" then
		v77 = l_Value_0
	else
		v77 = v_u_10
	end;
	v76.main = {
		["char"] = l_Character_0,
		["originweapon"] = v77,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v_u_4(v75, v76)
	local v78 = "springfield_pedersen_mag_on"
	local v79 = {}
	local v80
	if v_u_10 == "" then
		v80 = l_Value_0
	else
		v80 = v_u_10
	end;
	v79.main = {
		["char"] = l_Character_0,
		["originweapon"] = v80,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v_u_4(v78, v79)
	v_u_12.jam_count = math.random(7, 18)
	v_u_7.fire_rate = 0.333
	v_u_7.recoil = 1
	v_u_12.last_mag = v_u_19.ammo_mag
	v_u_19.pedersen_device = true
	v_u_19.ammo_mag = v_u_12.pedersen_mag
	v_u_12.alt_mode = not v_u_12.alt_mode
end;
if l_Character_0:FindFirstChild("perk") and (l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and (v_u_7.tooltype == "gun" and l_Character_0:FindFirstChild("validforakimbo")))) then
	v_u_11.held_normal = v_u_11.held
	v_u_11.aim_normal = v_u_11.aim
	for _, v81 in ipairs(game.ReplicatedStorage.animations.tools.akimbo:GetChildren()) do
		v61(v81)
	end;
	v_u_11.draw_dual.Priority = Enum.AnimationPriority.Action3
	v_u_11.akimbo_held.Priority = Enum.AnimationPriority.Action
	v_u_11.akimbo_right.Priority = Enum.AnimationPriority.Action3
	v_u_11.akimbo_left.Priority = Enum.AnimationPriority.Action3
	v_u_11.akimbo_right_empty.Priority = Enum.AnimationPriority.Action3
	v_u_11.akimbo_left_empty.Priority = Enum.AnimationPriority.Action3
	local l_BoolValue_5 = Instance.new("BoolValue")
	l_BoolValue_5.Name = "akimbo"
	l_BoolValue_5.Value = false
	l_BoolValue_5.Parent = l_Parent_0
	local l_BoolValue_6 = Instance.new("BoolValue")
	l_BoolValue_6.Name = "akimbo_aiming"
	l_BoolValue_6.Value = false
	l_BoolValue_6.Parent = l_Parent_0
	v_u_11.short = v_u_11.akimbo_short
	local l_BoolValue_7 = Instance.new("BoolValue")
	l_BoolValue_7.Name = "mag_empty"
	l_BoolValue_7.Value = false
	l_BoolValue_7.Parent = l_Parent_0
	v_u_12.flipflop = false
	if l_Value_0 == "pieper" and (_G.pieper_alt and _G.pieper_alt == true) then
		_G.pieper_alt = false
	end;
end;
v_u_11.draw.Priority = Enum.AnimationPriority.Action2
if v_u_11.unequip then
	v_u_11.unequip.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.short then
	v_u_11.short.Priority = Enum.AnimationPriority.Action3
end;
if v_u_11.short_alt then
	v_u_11.short_alt.Priority = Enum.AnimationPriority.Action3
end;
if v_u_11.locked then
	v_u_11.locked.Priority = Enum.AnimationPriority.Action4
end;
if v_u_11.akimbo_locked then
	v_u_11.akimbo_locked.Priority = Enum.AnimationPriority.Action4
end;
if v_u_11.locked_alt then
	v_u_11.locked_alt.Priority = Enum.AnimationPriority.Action4
end;
v_u_11.held.Priority = Enum.AnimationPriority.Action
if v_u_11.sprint then
	v_u_11.sprint.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.sprint_greyhound then
	v_u_11.sprint_greyhound.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.sprint_alt_greyhound then
	v_u_11.sprint_alt_greyhound.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.sprint_dual then
	v_u_11.sprint_dual.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.sprint_normal then
	v_u_11.sprint_normal.Priority = Enum.AnimationPriority.Action
end;
v_u_11.aim.Priority = Enum.AnimationPriority.Action2
if v_u_11.aim_left then
	v_u_11.aim_left.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.bipod_aim then
	v_u_11.bipod_aim.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.alt_changeaim then
	v_u_11.alt_changeaim.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.alt_changeaim_left then
	v_u_11.alt_changeaim_left.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.blocked1 then
	v_u_11.blocked1.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.blocked2 then
	v_u_11.blocked2.Priority = Enum.AnimationPriority.Action2
end;
if v_u_11.fire then
	v_u_11.fire.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.akimbo_fire then
	v_u_11.akimbo_fire.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.fire_left then
	v_u_11.fire_left.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire then
	v_u_11.alt_changefire.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.fire_last then
	v_u_11.fire_last.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire_last then
	v_u_11.alt_changefire_last.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.fire_empty then
	v_u_11.fire_empty.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.akimbo_fire_empty then
	v_u_11.akimbo_fire_empty.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.fire_empty_left then
	v_u_11.fire_empty_left.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire_empty then
	v_u_11.alt_changefire_empty.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire_left then
	v_u_11.alt_changefire_left.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire_last_left then
	v_u_11.alt_changefire_last_left.Priority = Enum.AnimationPriority.Action
end;
if v_u_11.alt_changefire_empty_left then
	v_u_11.alt_changefire_empty_left.Priority = Enum.AnimationPriority.Action
end;
if l_Value_0 == "pieper" then
	if _G.pieper_alt == nil then
		_G.pieper_alt = false
	end;
	v_u_12.slide_locked = true
	v_u_11.locked:Play(0.1)
elseif l_Value_0 == "whistle" and _G.whistle_long == nil then
	_G.whistle_long = true
end;
if l_Value_0 == "crossbow" then
	local v82 = "crossbow_bolt_visibility"
	local v83 = {}
	local v84
	if v_u_10 == "" then
		v84 = l_Value_0
	else
		v84 = v_u_10
	end;
	v83.main = {
		["char"] = l_Character_0,
		["originweapon"] = v84,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v83.transp = 0
	v_u_4(v82, v83)
	v_u_12.slide_locked = true
	v_u_11.locked:Play(0.01)
	if l_Character_0:FindFirstChild("crossbow2") and l_Parent_0.slot.Value == 1 or l_Character_0:FindFirstChild("crossbow1") and l_Parent_0.slot.Value == 2 then
		v_u_11.locked:Stop(0.01)
	end;
end;
local v_u_85 = nil
local v_u_88 = l_remotes_0.interaction_handler.OnClientEvent:Connect(function(p86, p87) --[[ Line: 872 ]]
	--[[ Upvalues: (copy 1): l_core_checkers_0, (copy 2): l_ammo_give_0, (ref 3): v_u_7, (ref 4): v_u_19, (copy 5): l_Parent_0, (copy 6): v_u_12, (ref 7): l_Value_0, (copy 8): v_u_11, (copy 9): l_Character_0, (copy 10): v_u_2, (copy 11): v_u_1, (copy 12): v_u_3 ]]
	if p86 == "ammo_restock" then
		l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_max"] + math.clamp(v_u_7.capacity - v_u_19.ammo_mag, 0, v_u_7.capacity)
		if v_u_7.require_full_load and (v_u_7.require_full_load == true and v_u_19.ammo_mag < v_u_7.capacity) then
			l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_max"] + v_u_7.capacity
		end;
		if l_Parent_0:FindFirstChild("durability") and (v_u_12.durability_max and p87 == "restock_player_full") then
			v_u_12.sharpening_stones = 1
		end;
		if p87 == "cache_restock" or p87 == "restock_player_full" then
			if l_Parent_0:FindFirstChild("shield_supplies") and l_Parent_0.shield_supplies:FindFirstChild("max") then
				l_Parent_0.shield_supplies.Value = l_Parent_0.shield_supplies.max.Value
			end;
			if l_Parent_0:FindFirstChild("client_inactive") then
				if l_Value_0 == "remington" then
					v_u_19.ammo_mag = 1
					v_u_12.slide_locked = false
					v_u_11.locked:Stop(0.05)
				end;
				l_Parent_0.client_inactive:Destroy()
			end;
			if l_Parent_0:FindFirstChild("use_count") and l_Parent_0.use_count:FindFirstChild("max") then
				l_Parent_0.use_count.Value = l_Parent_0.use_count.max.Value
			end;
			if p87 == "restock_player_full" then
				if l_Parent_0:FindFirstChild("gl_uses") and l_Parent_0.gl_uses:FindFirstChild("max") then
					l_Parent_0.gl_uses.Value = l_Parent_0.gl_uses.max.Value
				end;
				if l_Value_0 == "springfield" then
					v_u_12.extra_mag = true
				end;
			end;
		end;
		if l_Parent_0:FindFirstChild("empty_ammo") then
			l_Parent_0.empty_ammo.Value = false
			return;
		end;
	else
		if p86 == "playtoolanimation" then
			if p87 and (p87.animation and v_u_11[p87.animation]) then
				if not p87.tool or l_core_checkers_0.equipped and l_Value_0 == p87.tool then
					if p87.delay then
						task.wait(p87.delay)
					end;
					v_u_11[p87.animation]:Play(p87.fadein or 0.1, p87.weight or 1, p87.speed or 1)
				end;
			else
				return;
			end;
		end;
		if p86 == "stoptoolanimation" then
			if p87 and (p87.animation and v_u_11[p87.animation]) then
				if not p87.tool or l_core_checkers_0.equipped and l_Value_0 == p87.tool then
					if p87.delay then
						task.wait(p87.delay)
					end;
					v_u_11[p87.animation]:Stop(p87.fadeout or 0.1)
				end;
			else
				return;
			end;
		end;
		if p86 == "shieldparry" and l_Value_0 == "vanguardshield" then
			if l_Character_0 ~= nil and l_Character_0:FindFirstChild("HumanoidRootPart") ~= nil then
				if v_u_2.Value == false then
					v_u_11["blocked" .. math.random(1, 2)]:Play(0.1, 1, 2)
				end;
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "block" .. math.random(1, 4),
					["location"] = l_Character_0.HumanoidRootPart
				})
				v_u_3("mine_impact", {
					["point"] = l_Character_0.HumanoidRootPart.Position + l_Character_0.HumanoidRootPart.CFrame.lookVector
				})
			end;
		end;
		if p86 == "retrieve_vanguardshield" and (l_Parent_0:FindFirstChild("client_inactive") and l_Value_0 == "vanguardshield") then
			l_Parent_0.client_inactive:Destroy()
		end;
	end;
end)
local function v_u_113(p89) --[[ Line: 996 ]]
	--[[ Upvalues: (copy 1): v_u_9, (copy 2): l_core_checkers_0, (copy 3): v_u_12, (copy 4): l_remotes_0, (copy 5): l_Character_0, (ref 6): v_u_7, (copy 7): v_u_2, (ref 8): v_u_19, (copy 9): v_u_11, (copy 10): v_u_3, (copy 11): l_LocalPlayer_0, (copy 12): v_u_1, (ref 13): v_u_5, (copy 14): l_keysheld_0, (copy 15): l_RenderStepped_0, (copy 16): v_u_4, (ref 17): l_Value_0, (ref 18): v_u_10, (copy 19): l_Value_1 ]]
	if v_u_9:FindFirstChild("burning_light") or v_u_9:FindFirstChild("burning_heavy") then
		return;
	end;
	local v90
	if l_core_checkers_0.aiming == true and (v_u_12.heal_target and (v_u_12.heal_target:FindFirstChild("Humanoid") and (v_u_12.heal_target:FindFirstChild("Torso") and p89 ~= true))) then
		if v_u_12.heal_target.Humanoid.Health >= 100 then
			if tick() - v_u_12.firing_ticker > 0.2 then
				v_u_12.firing_ticker = tick()
				_G.popupmsg("targetwarn_surgery", "Patient does not need Surgery.", 1)
			end;
			return;
		end;
		l_remotes_0.medical_handler:FireServer("sendhealmessage", v_u_12.heal_target)
		if (v_u_12.heal_target.Torso.Position - l_Character_0.Torso.Position).magnitude > 6 then
			if tick() - v_u_12.firing_ticker > 0.2 then
				v_u_12.firing_ticker = tick()
				_G.popupmsg("target_warnrange", "Patient is too far for Surgery.", 1)
			end;
			return;
		end;
		if v_u_12.heal_target.Humanoid:FindFirstChild("burning_light") or v_u_12.heal_target.Humanoid:FindFirstChild("burning_heavy") then
			if tick() - v_u_12.firing_ticker > 0.2 then
				v_u_12.firing_ticker = tick()
				_G.popupmsg("target_warnburn", "They\'re kind of burning right now.", 1)
			end;
			return;
		end;
		if v_u_12.heal_target:FindFirstChild("dreadnought") then
			if tick() - v_u_12.firing_ticker > 0.2 then
				v_u_12.firing_ticker = tick()
				_G.popupmsg("target_warndread", "They\'re covered head to toe in armour, I can\'t perform surgery on that thing.", 1)
			end;
			return;
		end;
		v90 = v_u_12.heal_target
	else
		v90 = nil
	end;
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier and v90 == nil then
		return;
	end;
	if l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "conscript" and (v90 == nil or p89 == true)) then
		return;
	end;
	if v_u_9.Health >= 100 and (v90 == nil and p89 ~= true) then
		if tick() - v_u_12.firing_ticker > 0.2 then
			v_u_12.firing_ticker = tick()
			_G.popupmsg("heal_warn", "I\'m not hurt enough to need Surgery.", 2)
		end;
		return;
	end;
	v_u_2.Value = true
	l_core_checkers_0.sprint_block = true
	if v90 == nil then
		l_core_checkers_0.healing_anim_self = true
	end;
	local v91 = 0.6
	local v92 = 5
	local v93 = l_Character_0.wounds:GetChildren()
	v_u_19.surgery_extra = nil
	local l_Torso_0 = l_Character_0.Torso
	local v94 = "_tweezer"
	if #v93 > 0 then
		l_Torso_0 = v93[math.random(1, #v93)]
	end;
	if l_Torso_0:IsA("StringValue") then
		v94 = l_Torso_0.Value
	end;
	if l_Torso_0:FindFirstChild("extra") then
		v_u_19.surgery_extra = l_Torso_0.extra.Value
	end;
	local v95 = l_Torso_0.Name .. v94
	if l_Character_0:FindFirstChild("medical_expertise") then
		v91 = v90 and 1.1 or v91
		v92 = 0
	end;
	if l_Character_0.perk.Value == "hippocratic" and v90 then
		v91 = (v91 < 1 and 1 or v91) * 1.1
	end;
	if l_Character_0:FindFirstChild("buff_defend") or l_Character_0:FindFirstChild("buff_elite") then
		v91 = v91 * 1.25
	end;
	if l_Character_0:FindFirstChild("flagbuff") then
		v91 = v91 * 1.2
	end;
	if l_Character_0:FindFirstChild("vanguardbuff") then
		v91 = v91 * 1.2
	end;
	local v96
	if l_Character_0.perk.Value == "healing" and v90 == nil then
		v91 = v91 * 1.1
		if p89 == true then
			v96 = false
		else
			v96 = true
		end;
	else
		v96 = false
	end;
	if l_Torso_0.Name == "Left Leg" or l_Torso_0.Name == "Right Leg" then
		v92 = v90 == nil and p89 ~= true and 100 or v92
	end;
	local v97 = true
	local v98 = v_u_11[v95] == nil and "Torso_tweezer" or v95
	if v90 then
		v92 = 0
		v98 = "tweezer_others"
		if v90:FindFirstChild("wounds") then
			local v99 = v90.wounds:GetChildren()
			local v100
			if #v99 > 0 then
				v100 = v99[math.random(1, #v99)]
			else
				v100 = nil
			end;
			if v100 ~= nil and v100:IsA("StringValue") then
				v98 = v100.Value == "_suture" and "suture_others" or v98
				if v100:FindFirstChild("extra") then
					v_u_19.surgery_extra = v100.extra.Value
				end;
			end;
		end;
		v91 = v91 * 1.1
	end;
	local v101
	if (l_Character_0:FindFirstChild("helmet") and l_Character_0.helmet:FindFirstChild("knock") or l_Character_0:FindFirstChild("extralift")) and (v90 == nil and v96 == false) then
		v_u_3("helmet_adjusting", {
			["char"] = l_Character_0,
			["val"] = "helmetoff"
		})
		v_u_11[l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "lancer" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) and "helmet_remove_lancer" or "helmet_remove"]:Play(0.05, 1, 1.5)
		l_remotes_0.game_handler:FireServer("helmet_lift", true)
		v_u_1:s_wait(0.33)
		v101 = true
	else
		v101 = false
	end;
	local v102 = tick()
	local v103
	if v90 == nil and (v96 == false and p89 ~= true) then
		local v104 = { "afterheal_water" }
		v103 = v104[math.random(1, #v104)]
		v_u_11[v103]:Play(0.3, 1, v91)
		while true do
			if v_u_9.Health >= 100 or v_u_5 == true or (tick() - l_core_checkers_0.fall_damage_interrupt <= 0 or tick() - v102 >= 0.1 and (tick() - v102 < 2.5 / v91 - 1 and l_keysheld_0.m1 == nil)) then
				v97 = false
				break;
			end;
			l_RenderStepped_0:Wait()
			if tick() - v102 >= 2.5 / v91 then
				break;
			end;
		end;
	else
		v103 = nil
	end;
	if v97 == true then
		l_core_checkers_0.int_speed = l_core_checkers_0.int_speed - v92
		v98 = p89 == true and "afterheal_item" or v98
		v_u_11[v98]:Play(0.1, 1, v91)
		local v105 = tick()
		local v106 = false
		while true do
			if v92 == 100 then
				l_core_checkers_0.crouching_cd = tick()
				l_core_checkers_0.crouching = false
			end;
			if v90 then
				if v90 == nil or (v90:FindFirstChild("Humanoid") == nil or (v90:FindFirstChild("Torso") == nil or (v90.Humanoid.Health >= 100 or v90.Humanoid.Health <= 0)) or (v90.Torso.Position - l_Character_0.Torso.Position).magnitude > 6) then
					v97 = false
					break;
				end;
				if tick() - v105 >= 1.3 / v91 then
					v97 = true
					break;
				end;
			else
				if v_u_9.Health >= 100 and (p89 ~= true and v106 ~= true) or v_u_5 == true then
					v97 = false
					break;
				end;
				local v107 = v_u_11[v98]
				if v107 and v107:GetTimeOfKeyframe("healing_done") then
					v107 = v107:GetTimeOfKeyframe("healing_done") / v91
				end;
				if v107 == nil then
					v107 = 2 / v91
				end;
				if v107 <= tick() - v105 and v97 == true then
					v106 = true
					if l_Torso_0 ~= l_Character_0.Torso then
						l_Torso_0:Destroy()
					end;
					if p89 == true then
						l_remotes_0.medical_handler:FireServer("remove_sickness")
						v97 = false
					else
						if l_Torso_0 ~= l_Character_0.Torso then
							l_Torso_0:Destroy()
						end;
						l_remotes_0.medical_handler:FireServer("healself")
						v97 = false
					end;
				end;
			end;
			if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 or tick() - v105 >= 0.1 and (tick() - v105 < 2.5 / v91 - 1 and (l_keysheld_0.m1 == nil and (l_keysheld_0[_G.get_keybinds("alt")] == nil and v106 == false))) then
				v97 = false
				break;
			end;
			l_RenderStepped_0:Wait()
			if tick() - v105 >= 2.5 / v91 then
				break;
			end;
		end;
		l_core_checkers_0.int_speed = l_core_checkers_0.int_speed + v92
	end;
	local v108 = true
	if v97 == true then
		if v90 then
			l_remotes_0.medical_handler:FireServer("healtarget", v90)
			v108 = false
		elseif p89 == true then
			l_remotes_0.medical_handler:FireServer("remove_sickness")
		else
			if l_Torso_0 ~= l_Character_0.Torso then
				l_Torso_0:Destroy()
			end;
			l_remotes_0.medical_handler:FireServer("healself")
		end;
	end;
	l_remotes_0.game_handler:FireServer("helmet_lift", false)
	if v101 == true then
		v_u_3("helmet_adjusting", {
			["char"] = l_Character_0,
			["val"] = "helmet"
		})
		v_u_11[l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "lancer" and l_LocalPlayer_0.Team == game.Teams["Golden Empire"]) and "helmet_place_lancer" or "helmet_place"]:Play(0.05, 1, 1.5)
		v_u_1:s_wait(0.33)
	end;
	local v109 = v_u_4
	local v110 = "firstaid_reset"
	local v111 = {}
	local v112 = l_Value_0
	if v_u_10 ~= "" then
		v112 = v_u_10
	end;
	v111.main = {
		["char"] = l_Character_0,
		["originweapon"] = v112,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v109(v110, v111)
	if v103 then
		v_u_11[v103]:Stop(0.05)
	end;
	if v108 == true then
		v_u_11[v98]:Stop(0.05)
	end;
	l_core_checkers_0.healing_anim_self = false
	l_core_checkers_0.sprint_block = false
	v_u_2.Value = false
end;
local function v_u_126() --[[ Line: 1373 ]]
	--[[ Upvalues: (copy 1): l_Character_0, (copy 2): v_u_12, (ref 3): l_Value_0, (copy 4): v_u_2, (copy 5): l_core_checkers_0, (ref 6): v_u_7, (copy 7): v_u_11, (copy 8): v_u_1, (copy 9): l_CurrentCamera_0, (copy 10): l_remotes_0, (copy 11): v_u_9, (copy 12): v_u_23, (copy 13): v_u_26, (copy 14): l_Parent_0, (copy 15): l_RenderStepped_0 ]]
	if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	end;
	if v_u_12.bayo_cd == nil then
		v_u_12.bayo_cd = 0
	end;
	local v114 = 3
	local v115 = 3
	local v116 = false
	if l_Character_0:FindFirstChild("class") and (l_Character_0:FindFirstChild("perk") and l_Character_0.class.Value == "lancer") then
		if l_Character_0.perk.Value == "butcher" then
			v115 = 2
			v114 = 5
		end;
		if l_Character_0.perk.Value == "vet" then
			v114 = 5
			v116 = true
		end;
	end;
	if l_Value_0 == "trench" and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "lancer") then
		v115 = 2
		v114 = 5
		v116 = true
	end;
	if tick() - v_u_12.bayo_cd <= v115 then
		return;
	end;
	if v_u_2.Value == true or l_core_checkers_0.sprint_block == true then
		return;
	end;
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 then
		return;
	end;
	if l_core_checkers_0.sprinting == true and l_core_checkers_0.sprinting_max_speed == true then
		v_u_2.Value = true
		v_u_11.charge:Stop(0.5)
		v_u_11.charge:Play(0.5, 1, 1.5)
		l_core_checkers_0.charging_direction = l_Character_0.HumanoidRootPart.CFrame.lookVector
		l_core_checkers_0.charging = true
		local v117 = tick()
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "chargestart",
			["location"] = l_CurrentCamera_0
		}, true)
		delay(0.1, function() --[[ Line: 1435 ]]
			--[[ Upvalues: (ref 1): l_remotes_0 ]]
			l_remotes_0.game_handler:FireServer("languageline", "charge")
		end)
		local v118 = game.ReplicatedStorage.sound_library.misc.charge_heartbeat:Clone()
		v118.Parent = l_CurrentCamera_0
		v118:Play()
		local v119 = false
		local v120 = {}
		local v121 = 0
		while true do
			if v_u_9 == nil or v_u_9.Health <= 0 then
				if v118 then
					v118:Destroy()
				end;
				return;
			end;
			if tick() - v117 >= 0.2 then
				local v122, _, _, _ = v_u_1:raycastline({
					["point"] = l_Character_0.Head.Position,
					["destination"] = l_Character_0.Head.CFrame.LookVector,
					["range"] = 4,
					["layermask"] = v_u_23
				})
				if v122 == nil then
					local v123 = l_Character_0.Head.Position + l_Character_0.Head.CFrame.LookVector * 4
					local l_empire_team_1 = workspace.empire_team
					if l_Character_0.Parent == l_empire_team_1 then
						l_empire_team_1 = workspace.nation_team
					end;
					for _, v124 in ipairs(l_empire_team_1:GetChildren()) do
						if v124:FindFirstChild("HumanoidRootPart") and (v124:FindFirstChild("Torso") and (v124:FindFirstChild("Humanoid") and v124.Humanoid.Health > 0)) and ((v124.HumanoidRootPart.Position - v123).Magnitude <= 3.5 and not v_u_1:raycastline({
							["point"] = l_Character_0.Head.Position,
							["destination"] = CFrame.new(l_Character_0.Head.Position, v124.Torso.Position).LookVector,
							["range"] = 10,
							["layermask"] = v_u_26
							}) == true) then
							v122 = v124.Torso
						end;
					end;
				end;
				if v122 and (v122.Parent and v120[v122.Parent.Name] == nil) then
					if not v122.Parent or (not v122.Parent:FindFirstChild("Humanoid") or (not v122.Parent:FindFirstChild("HumanoidRootPart") or (v122.Parent.Humanoid.Health <= 0 or not v122.Parent:FindFirstChild("Torso")))) then
						v119 = true
						break;
					end;
					if v122.Name == "HeadHitbox" or v122.Name == "Head" then
						v122 = v122.Parent.Torso
					end;
					v120[v122.Parent.Name] = true
					v121 = v121 + 1
					if v121 >= 3 then
						v116 = false
					end;
					local v125 = v116 == true and "skewer" or "bayonet"
					if tick() - v117 < 0.5 and (v122 and (v122.Parent and v122.Parent:FindFirstChild("Bulwark\'s Shield") == nil)) then
						v125 = "melee"
						v116 = false
					end;
					l_remotes_0.damage_handler:FireServer(v122, l_Parent_0, v125, v_u_7)
					if v116 == false then
						break;
					end;
				end;
				if l_Character_0.HumanoidRootPart.Velocity.Magnitude <= 5 and tick() - v117 >= 1 then
					break;
				end;
			end;
			if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 or tick() - l_core_checkers_0.in_air_timer > 0.5 then
				break;
			end;
			l_RenderStepped_0:Wait()
			if v114 <= tick() - v117 then
				break;
			end;
		end;
		if v119 == true then
			l_remotes_0.game_handler:FireServer("hurtline", l_Character_0.gender.Value .. "_hurt" .. math.random(1, 10))
			_G.knockdownproc(true)
		end;
		v118:Destroy()
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "chargeend",
			["location"] = l_CurrentCamera_0
		}, true)
		v_u_11.charge:Stop(0.5)
		v_u_11.charge_stop:Play(0.2, 1, 1.5)
		l_core_checkers_0.fall_damage_interrupt = tick() + (v119 == true and 2 or ((l_Value_0 == "lance" or l_Value_0 == "trench") and 1 or 1.5))
		v_u_12.bayo_cd = tick()
		v_u_2.Value = false
		l_core_checkers_0.charging = false
	end;
end;
local v_u_127 = 1
local function v_u_157(p128) --[[ Line: 1592 ]]
	--[[ Upvalues: (copy 1): l_Character_0, (copy 2): l_Parent_0, (ref 3): l_Value_0, (copy 4): v_u_12, (copy 5): v_u_2, (copy 6): l_core_checkers_0, (copy 7): l_Value_1, (ref 8): v_u_19, (copy 9): v_u_11, (ref 10): v_u_10, (ref 11): v_u_127, (ref 12): v_u_7, (copy 13): v_u_1, (copy 14): l_CurrentCamera_0, (copy 15): v_u_23, (copy 16): v_u_3, (copy 17): l_remotes_0, (copy 18): v_u_26, (copy 19): l_RenderStepped_0, (copy 20): l_keysheld_0 ]]
	if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	end;
	if l_Parent_0:FindFirstChild("client_inactive") then
		return;
	end;
	if l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
		return;
	end;
	if l_Value_0 == "lewis" then
		return;
	end;
	if v_u_12.equipped == false and p128 ~= true then
		return;
	end;
	if l_Parent_0:FindFirstChild("mounted_weapon") or l_Value_0 == "browningmg" then
		return;
	end;
	v_u_2.Value = true
	local v129, v130
	if l_Value_0 == "lance" and l_core_checkers_0.aiming == true then
		v129 = "stab"
		v130 = "stab"
	else
		v129 = "melee"
		v130 = "swing"
	end;
	local v131 = l_Value_0 == "cavsword" and p128 == true and "melee_alt" or v129
	if l_Value_0 == "lebel" and l_Value_1:FindFirstChild("bayonet") then
		v131 = "altmelee"
		v130 = "stab"
	end;
	if l_Value_0 == "crossbow" and v_u_19.ammo_mag > 0 then
		v131 = "altmelee"
		v130 = "stab"
	end;
	local v132 = l_Value_0 == "bottle" and (l_Value_1:FindFirstChild("glassbottle") and (l_Value_1:FindFirstChild("body") and l_Value_1.body:FindFirstChild("blade"))) and "altmelee" or v131
	v_u_11[v132 .. "1"]:Stop(0)
	v_u_11[v132 .. "2"]:Stop(0)
	if v_u_11.mine then
		v_u_11.mine:Stop(0)
	end;
	local v133 = v_u_10 == "henryvariant" and "meleealt" or (v_u_10 == "dbgunvariant" and v_u_127 == 1 and "meleealt" or v132)
	v_u_11[v133 .. v_u_127]:Play(0.1, 1, 1)
	if v_u_127 == 1 then
		v_u_127 = 2
	else
		v_u_127 = 1
	end;
	l_core_checkers_0.jump_tick = tick()
	local l_melee_swing_speed_0 = v_u_7.melee_swing_speed
	local v134, v135
	if l_Character_0.perk.Value == "tunnelrat" and (l_Value_0 == "pickaxe" or l_Value_0 == "pick") then
		v134 = -0.5
		v135 = 10
	else
		v134 = 0
		v135 = nil
	end;
	if (l_Value_0 == "pickaxe" or l_Value_0 == "pick") and workspace.serverStuff.restorationmode.Value == true then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 * 1.25
	end;
	if l_Character_0.perk.Value == "tunnelrat" and (l_Value_0 == "pickaxe" or l_Value_0 == "pick") then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 * 0.75
	end;
	if l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 * 0.5
	end;
	if l_Character_0.chems:FindFirstChild("mep") and l_core_checkers_0.sick == false then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 * 0.75
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "ready",
		["location"] = l_Character_0.HumanoidRootPart,
		["volume_adjust"] = v134,
		["force_max_dist"] = v135
	})
	if l_Value_0 == "lance" then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "flag" .. math.random(1, 4),
			["location"] = l_Character_0.HumanoidRootPart,
			["force_max_dist"] = v135
		})
	end;
	local v136 = (v_u_7.tooltype == "melee" or l_Value_0 == "henry" and v_u_10 ~= "henryvariant" or l_Value_0 == "trench") and 0.1 or 0.2
	if l_core_checkers_0.aiming == true then
		l_core_checkers_0.aim_time = tick()
	end;
	v_u_1:s_wait(v136)
	if v_u_12.equipped == false and p128 ~= true then
		return;
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = v130 .. math.random(1, 2),
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart,
		["volume_adjust"] = v134,
		["force_max_dist"] = v135
	})
	local v137 = l_CurrentCamera_0.CFrame.Position + l_CurrentCamera_0.CFrame.LookVector * ((l_CurrentCamera_0.CFrame.Position - l_Character_0.HumanoidRootPart.Position).Magnitude - 2)
	if l_Value_0 == "pick" or l_Value_0 == "pickaxe" then
		v137 = (l_Character_0.Head.CFrame - l_CurrentCamera_0.CFrame.LookVector * 0.5).Position
	end;
	local l_melee_range_0 = v_u_7.melee_range
	local v138 = l_Value_0 ~= "lance" and l_Value_0 ~= "trench"
	local v139
	if v133 == "stab" then
		l_melee_range_0 = l_melee_range_0 + 3
		v139 = "lancestab"
		v138 = nil
	else
		v139 = nil
	end;
	local v140, v141, v142, v143 = v_u_1:raycastline({
		["point"] = v137,
		["destination"] = l_CurrentCamera_0.CFrame.LookVector,
		["range"] = l_melee_range_0 + 1,
		["layermask"] = v_u_23
	})
	local v144 = {}
	local v145 = false
	if v140 and (v140.Material == Enum.Material.Glass and (v140.Name == "WindowBreakable" or v140.Name == "GlassWindow")) then
		v_u_3("wood_impact", {
			["point"] = v141,
			["part_hit"] = v140,
			["partcol"] = v140.Color,
			["pellets"] = 1,
			["glass"] = true
		})
		if v140.Name == "WindowBreakable" then
			v_u_3("bullet_hole", {
				["pos"] = v141,
				["normal"] = v142,
				["glass"] = true,
				["forceparent"] = v140
			}, true)
			l_remotes_0.game_handler:FireServer("window_impact", v140, 2)
		end;
	end;
	if v140 and (v140.Parent:FindFirstChild("Humanoid") or v140.Parent.Parent:FindFirstChild("health")) then
		table.insert(v144, v140)
	end;
	if v140 and (v140.Name == "leftshield" or (v140.Name == "rightshield" or (v140.Name == "mainshield" or v140.Name == "topshield"))) and (v140.Parent and (v140.Parent.Parent and (v140.Parent.Parent.Parent and v140.Parent.Parent.Parent:FindFirstChild("Torso")))) then
		table.insert(v144, v140.Parent.Parent.Parent.Torso)
	end;
	if v138 ~= nil and (v140 == nil or (v140.Parent:FindFirstChild("Humanoid") == nil or v138 == false)) then
		local l_empire_team_2 = workspace.empire_team
		if l_Character_0.Parent == l_empire_team_2 then
			l_empire_team_2 = workspace.nation_team
		end;
		local l_melee_range_1 = v_u_7.melee_range
		local v146 = v137 + l_CurrentCamera_0.CFrame.LookVector * (l_melee_range_1 / 2)
		local v147 = l_melee_range_1 / 1.5
		for _, v148 in ipairs(l_empire_team_2:GetChildren()) do
			if v148:FindFirstChild("HumanoidRootPart") and (v148:FindFirstChild("Torso") and (v148:FindFirstChild("Humanoid") and v148.Humanoid.Health > 0)) and ((v148.HumanoidRootPart.Position - v146).Magnitude <= v147 and ((not v140 or v140.Parent ~= v148) and true or false) == true) then
				table.insert(v144, v148:FindFirstChild("Torso"))
			end;
		end;
	end;
	if #v144 > 0 then
		local v149 = {}
		for _, v152 in ipairs(v144) do
			if v152.Parent:FindFirstChild("Humanoid") and (v152.Parent.Humanoid.Health > 0 and v149[v152.Parent.Name] == nil) then
				local v151 = true
				local v152
				if v152.Name == "HeadHitbox" and (l_Value_0 ~= "pickaxe" and (l_Value_0 ~= "lance" or v133 ~= "stab")) == true then
					v152 = v152.Parent.Torso
				end;
				if v152.Name == "Left Leg" or v152.Name == "Right Leg" then
					v152 = v152.Parent.Torso
				end;
				if v_u_1:raycastline({
					["point"] = l_Character_0.Head.Position,
					["destination"] = CFrame.new(l_Character_0.Head.Position, v152.Parent.Torso.Position).LookVector,
					["range"] = (l_Character_0.Head.Position - v152.Parent.Torso.Position).magnitude,
					["layermask"] = v_u_26
					}) then
					v151 = false
				end;
				if v151 == true then
					v149[v152.Parent.Name] = true
					v145 = true
					l_remotes_0.damage_handler:FireServer(v152, l_Parent_0, "melee", v_u_7, v139)
					if v138 == true then
						break;
					end;
				end;
			elseif v152.Parent and (v152.Parent.Parent and (v152.Parent.Parent:FindFirstChild("health") and v152.Parent.Parent.health.Value > 0)) then
				l_remotes_0.construction_handler:FireServer("damage", v152.Parent.Parent, l_Parent_0, "melee")
			end;
		end;
	end;
	local v153 = v140 and (v143 == Enum.Material.Rock or v143 == Enum.Material.Mud) and true or false
	if v140 and (v153 == true and (v_u_7.tooltype == "pick" and workspace.serverStuff.modifier.Value == "heavyrocks")) then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 * 1.1
	end;
	if v141.Y <= 34 then
		v153 = false
	end;
	if v145 == true or v_u_7.tooltype ~= "pick" then
		v153 = false
	end;
	local v154 = false
	if v153 == true then
		v154 = true
		if l_Character_0.perk.Value == "tunnelrat" and (l_Value_0 == "pickaxe" or l_Value_0 == "pick") then
			local l_StringValue_0 = Instance.new("StringValue")
			game:GetService("Debris"):AddItem(l_StringValue_0, 4)
			l_StringValue_0.Name = "tunnelratbuff"
			l_StringValue_0.Parent = l_Character_0
		end;
		local l_alt_mode_0 = v_u_12.alt_mode
		if l_Value_0 == "pickaxe" then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "mine",
				["pitchvariation"] = 0.1,
				["volume_adjust"] = v134,
				["force_max_dist"] = v135,
				["location"] = l_Character_0.HumanoidRootPart
			})
			if l_Parent_0.durability.Value >= 1 and (v_u_12.alt_mode == false and l_core_checkers_0.aiming == false) then
				local l_durability_0 = l_Parent_0.durability
				l_durability_0.Value = l_durability_0.Value - 1
			else
				l_alt_mode_0 = true
			end;
		end;
		if (l_Value_0 == "pick" or l_Value_0 == "pickaxe") and l_core_checkers_0.aiming == true then
			l_alt_mode_0 = "precise"
			if l_Value_0 == "pickaxe" then
				l_melee_swing_speed_0 = l_melee_swing_speed_0 * 0.8
			else
				l_melee_swing_speed_0 = l_melee_swing_speed_0 * 0.85
			end;
		end;
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "hit" .. math.random(1, 4),
			["pitchvariation"] = 0.1,
			["volume_adjust"] = v134,
			["force_max_dist"] = v135,
			["location"] = l_Character_0.HumanoidRootPart
		})
		if l_Character_0.perk.Value ~= "tunnelrat" then
			v_u_3("mine_impact", {
				["point"] = v141
			})
		end;
		v_u_11.mine:Play(0.2, 1, 1)
		l_remotes_0.mine:FireServer(CFrame.new(v141, l_Character_0.Head.Position), l_Parent_0, l_alt_mode_0, v140)
	elseif v140 and (v141 and (v140.Parent:FindFirstChild("Humanoid") == nil and (v140.Parent.Parent:FindFirstChild("health") == nil and (v140.Name ~= "leftshield" and (v140.Name ~= "rightshield" and (v140.Name ~= "mainshield" and v140.Name ~= "topshield")))))) then
		v_u_3("mine_impact", {
			["point"] = v141
		})
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "impact" .. math.random(1, 2),
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
	end;
	if v133 == "stab" then
		l_melee_swing_speed_0 = l_melee_swing_speed_0 - 0.1
	end;
	local v155 = tick()
	local v156 = false
	while true do
		if l_core_checkers_0.aiming == true then
			l_core_checkers_0.aim_time = tick()
		end;
		if l_Character_0 and (l_Character_0:FindFirstChild("perk") and (l_Character_0.perk.Value == "tunnelrat" and (l_Value_0 == "pickaxe" or l_Value_0 == "pick"))) and (l_core_checkers_0.queue_inv ~= nil and (l_core_checkers_0.queue_inv ~= 4 and v154 == true)) then
			v156 = true
			break;
		end;
		l_RenderStepped_0:wait()
		if l_melee_swing_speed_0 <= tick() - v155 then
			break;
		end;
	end;
	if (v_u_7.tooltype == "pick" or v_u_7.tooltype == "hammer") and (v156 == false and l_keysheld_0.m1 == true) then
		v_u_12.fire_buffer = tick()
	end;
	v_u_2.Value = false
end;
local v_u_158 = 0
local v_u_159 = 0
local v_u_160 = 0
local function v_u_166(p161) --[[ Line: 2061 ]]
	--[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): l_Parent_0, (ref 3): v_u_7, (copy 4): l_Character_0, (copy 5): l_core_checkers_0, (copy 6): l_ammo_give_0 ]]
	l_CurrentCamera_0.ammo_check.bg.count.Visible = false
	l_CurrentCamera_0.ammo_check.bg.ammo.Visible = false
	l_CurrentCamera_0.ammo_check.bg.walkertext.Visible = true
	l_CurrentCamera_0.ammo_check.bg.Size = UDim2.new(0, 145, 0, 55)
	local v162 = "Cap loaded."
	local v163 = "Ball loaded."
	local v164 = "Powder loaded."
	local v165 = _G["walkerstate" .. l_Parent_0.slot.Value][p161]
	if v165 then
		v162 = v165.cap == false and "No Cap.." or (v165.cap == "fired" and "Spent Cap.." or v162)
		v163 = v165.ball == "half" and "Ball not seated.." or (v165.ball == false and "No Ball.." or v163)
		if v165.powder == false then
			v164 = "No Powder."
		elseif v165.powder <= 0.2 then
			v164 = "Too little powder.."
		elseif v165.powder < 0.5 then
			v164 = "Not enough powder.."
		elseif v165.powder >= 1 then
			v164 = "Too much powder.."
		end;
	end;
	if l_CurrentCamera_0:FindFirstChild("ammo_check") then
		l_CurrentCamera_0.ammo_check.bg.walkertext.Text = v162 .. "\n" .. v163 .. "\n" .. v164 .. "\n"
		l_CurrentCamera_0.ammo_check.bg.maxammo.Visible = true
		l_CurrentCamera_0.ammo_check.bg.maxammo.inner.bar.Size = UDim2.new(1, 0, math.clamp(l_core_checkers_0[l_ammo_give_0 .. "_reserves"] / l_core_checkers_0[l_ammo_give_0 .. "_max"], 0, 1), 0)
	end;
	l_core_checkers_0.check_ammo = tick()
end;
local v_u_167 = nil
local function v_u_180(p168) --[[ Line: 2123 ]]
	--[[ Upvalues: (ref 1): l_Value_0, (copy 2): l_Parent_0, (copy 3): v_u_2, (copy 4): v_u_12, (copy 5): l_Character_0, (ref 6): v_u_7, (copy 7): v_u_4, (copy 8): l_remotes_0, (copy 9): l_core_checkers_0, (ref 10): v_u_10, (copy 11): l_Value_1, (ref 12): v_u_19, (copy 13): l_core_game_0, (copy 14): l_LocalPlayer_0, (ref 15): v_u_167, (copy 16): v_u_9 ]]
	if _G.ping_locked and _G.ping_locked == true then
		return;
	elseif l_Value_0 == "rooklauncher" or (l_Value_0 == "browningmg" or l_Value_0 == "mgturret") then
		return;
	elseif workspace.serverStuff.trainingmode.Value ~= true then
		local l_Value_2 = l_Parent_0.slot.Value
		if v_u_2.Value == true and v_u_12.state == "reload" or p168 == true then
			if l_Value_0 == "walker" then
				_G["walkerstate" .. l_Value_2] = {
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					},
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					},
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					},
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					},
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					},
					{
						["cap"] = false,
						["ball"] = false,
						["powder"] = false
					}
				}
				_G["walkercylinder" .. l_Value_2] = 1
			end;
			if v_u_12.dual_wield_tool then
				v_u_12.dual_wield_tool.event:Fire("dual_active", false)
				local v169 = l_Value_0 == "cavsword" and true or nil
				local v170
				if l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and v_u_7.tooltype == "gun") then
					v169 = true
					v170 = true
				else
					v170 = nil
				end;
				v_u_4("weapon_visibility", {
					["main"] = v_u_12.dual_wield_vfx(),
					["slot"] = v_u_12.dual_wield_tool.slot.Value,
					["state"] = "holster",
					["flipped"] = v169,
					["dual"] = v170
				}, true, nil, true)
				l_remotes_0.game_handler:FireServer("weapon_visibility", {
					["wep"] = v_u_12.dual_wield_tool,
					["state"] = "holster",
					["flipped"] = v169,
					["dual"] = v170
				})
			end;
			l_core_checkers_0.inv_block_reason = ""
			if l_Value_0 == "mauser" then
				l_core_checkers_0.inv_swapping = true
			end;
			if l_Value_0 == "lewis" then
				l_core_checkers_0.sprint_block = false
			end;
			local v171 = v_u_4
			local v172 = "weapon_visibility"
			local v173 = {}
			local v174 = l_Value_0
			if v_u_10 ~= "" then
				v174 = v_u_10
			end;
			v173.main = {
				["char"] = l_Character_0,
				["originweapon"] = v174,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v173.slot = l_Value_2
			v173.state = "dropped"
			v173.destroy = true
			v171(v172, v173, true, nil, true)
			if l_Value_0 == "henry" and l_Character_0.perk.Value == "vet" then
				local v175 = v_u_4
				local v176 = "henry_offhandround"
				local v177 = {}
				local v178 = l_Value_0
				if v_u_10 ~= "" then
					v178 = v_u_10
				end;
				v177.main = {
					["char"] = l_Character_0,
					["originweapon"] = v178,
					["weapon"] = l_Value_0,
					["model"] = l_Value_1,
					["module"] = v_u_7,
					["core"] = v_u_19
				}
				v177.visibility = false
				v175(v176, v177)
			end;
			l_remotes_0.game_handler:FireServer("weapon_visibility", {
				["wep"] = l_Parent_0,
				["state"] = "dropped"
			})
			l_core_checkers_0.remove_tool(nil, nil, l_Value_0 == "walker" and 1 or v_u_7.size)
			local v179 = l_core_game_0.inventory:FindFirstChild(l_Value_0 .. l_Value_2) or l_core_game_0.inventory:FindFirstChild(v_u_10 .. l_Value_2)
			if v179 then
				v179.Name = "empty" .. l_Value_2
				v179.icon.Image = "rbxassetid://17768266447"
				l_core_checkers_0.inventory_display = tick()
				v179.line.BackgroundColor3 = Color3.new(0, 0, 0)
				v179.icon.ImageColor3 = Color3.new(0, 0, 0)
				v179.num.TextColor3 = Color3.new(0, 0, 0)
			end;
			if l_LocalPlayer_0.Character:FindFirstChild("cowboy") and (l_LocalPlayer_0.Character:findFirstChild("elitekit") and l_LocalPlayer_0.Character.elitekit.Value == "ocelot") then
				l_remotes_0.game_handler:FireServer("ocelot_reload", l_Value_2)
			end;
			v_u_2.Value = false
			v_u_12.dropped = true
			v_u_12.state = "normal"
			v_u_167()
			v_u_9:UnequipTools()
			l_Parent_0:Destroy()
		end;
	end;
end;
local v_u_181 = tick()
local function v_u_234() --[[ Line: 2255 ]]
	--[[ Upvalues: (ref 1): v_u_160, (copy 2): l_Parent_0, (copy 3): v_u_2, (copy 4): l_core_checkers_0, (copy 5): v_u_12, (copy 6): v_u_11, (copy 7): v_u_1, (copy 8): l_Character_0, (copy 9): v_u_166, (copy 10): l_keysheld_0, (copy 11): v_u_4, (ref 12): l_Value_0, (ref 13): v_u_10, (copy 14): l_Value_1, (ref 15): v_u_7, (ref 16): v_u_19, (copy 17): l_ammo_give_0, (copy 18): l_remotes_0, (copy 19): l_RenderStepped_0, (copy 20): v_u_180, (copy 21): v_u_9 ]]
	if tick() - v_u_160 < 0 then
		return;
	end;
	if _G["walkerstate" .. l_Parent_0.slot.Value] == nil or _G["walkercylinder" .. l_Parent_0.slot.Value] == nil then
		return;
	end;
	if v_u_2.Value ~= false then
		if v_u_12.state == "walker_reload" and tick() - v_u_160 > 0 then
			v_u_160 = tick()
			v_u_12.state = "normal"
		end;
		return;
	end;
	l_core_checkers_0.inv_swapping = false
	v_u_12.state = "walker_reload"
	v_u_2.Value = true
	v_u_160 = tick()
	v_u_11.reload_idle:Play(0.1, 1, 0.5)
	v_u_11.reload_start:Play(0.4, 1, 2)
	v_u_1:s_wait(0.5)
	local v182 = false
	local v183 = 0.75
	local v184 = 0.75
	local v185 = 1.5
	local v186 = 1.5
	if l_Character_0.perk.Value == "vet" then
		v183 = v183 * 0.8
		v184 = v184 * 0.8
		v185 = v185 * 0.8
		v186 = v186 * 0.8
	end;
	while true do
		local v187 = _G["walkercylinder" .. l_Parent_0.slot.Value] - 1
		local v_u_188 = v187 <= 0 and 6 or v187
		local v_u_189 = _G["walkerstate" .. l_Parent_0.slot.Value][v_u_188]
		v_u_166(v_u_188)
		if (l_keysheld_0[Enum.KeyCode.One] == true or l_keysheld_0[Enum.KeyCode.DPadLeft] == true) and (v182 == false and tick() - v_u_160 > 0) then
			v182 = true
			v_u_160 = tick() + v183
			if v_u_189.cap == false then
				v_u_11.reload_cap_add:Play(0.1, 1, 1 / v183)
				delay(v183 / 2, function() --[[ Line: 2339 ]]
					--[[ Upvalues: (copy 1): v_u_189, (ref 2): v_u_4, (ref 3): l_Value_0, (ref 4): v_u_10, (ref 5): l_Character_0, (ref 6): l_Value_1, (ref 7): v_u_7, (ref 8): v_u_19, (ref 9): v_u_188 ]]
					v_u_189.cap = true
					local v190 = v_u_4
					local v191 = "walker_setstate"
					local v192 = {}
					local v193 = l_Value_0
					if v_u_10 ~= "" then
						v193 = v_u_10
					end;
					v192.main = {
						["char"] = l_Character_0,
						["originweapon"] = v193,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v192.walker_slot = v_u_188
					v192.walker_state = v_u_189
					v190(v191, v192)
				end)
			else
				v_u_11.reload_cap_remove:Play(0.1, 1, 1 / v183)
				delay(v183 / 2, function() --[[ Line: 2319 ]]
					--[[ Upvalues: (ref 1): v_u_4, (ref 2): l_Value_0, (ref 3): v_u_10, (ref 4): l_Character_0, (ref 5): l_Value_1, (ref 6): v_u_7, (ref 7): v_u_19, (ref 8): v_u_188, (copy 9): v_u_189 ]]
					local v194 = v_u_4
					local v195 = "walker_dropcap"
					local v196 = {}
					local v197 = l_Value_0
					if v_u_10 ~= "" then
						v197 = v_u_10
					end;
					v196.main = {
						["char"] = l_Character_0,
						["originweapon"] = v197,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v196.cap_drop = v_u_188
					v194(v195, v196)
					v_u_189.cap = false
					local v198 = v_u_4
					local v199 = "walker_setstate"
					local v200 = {}
					local v201 = l_Value_0
					if v_u_10 ~= "" then
						v201 = v_u_10
					end;
					v200.main = {
						["char"] = l_Character_0,
						["originweapon"] = v201,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v200.walker_slot = v_u_188
					v200.walker_state = v_u_189
					v198(v199, v200)
				end)
			end;
		end;
		if l_keysheld_0[_G.get_keybinds("alt")] == true and (v182 == false and tick() - v_u_160 > 0) then
			if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
				_G.popupmsg("noleadball", "I don\'t have any more Lead Balls left..", 1)
				v182 = true
			else
				v182 = true
				if v_u_189.ball == false then
					local v202 = l_core_checkers_0
					local v203 = l_ammo_give_0 .. "_reserves"
					v202[v203] = v202[v203] - 1
					if l_Parent_0:FindFirstChild("empty_ammo") and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
						l_Parent_0.empty_ammo.Value = false
					end;
					v_u_160 = tick() + v184
					v_u_11.reload_add_ball:Play(0.1, 1, 1 / v184)
					delay(v184 / 2, function() --[[ Line: 2377 ]]
						--[[ Upvalues: (copy 1): v_u_189, (ref 2): v_u_4, (ref 3): l_Value_0, (ref 4): v_u_10, (ref 5): l_Character_0, (ref 6): l_Value_1, (ref 7): v_u_7, (ref 8): v_u_19, (ref 9): v_u_188 ]]
						v_u_189.ball = "half"
						local v204 = v_u_4
						local v205 = "walker_setstate"
						local v206 = {}
						local v207 = l_Value_0
						if v_u_10 ~= "" then
							v207 = v_u_10
						end;
						v206.main = {
							["char"] = l_Character_0,
							["originweapon"] = v207,
							["weapon"] = l_Value_0,
							["model"] = l_Value_1,
							["module"] = v_u_7,
							["core"] = v_u_19
						}
						v206.walker_slot = v_u_188
						v206.walker_state = v_u_189
						v204(v205, v206)
					end)
					l_remotes_0.game_handler:FireServer("reloaded_weapon")
				else
					_G.popupmsg("ballloaded" .. v_u_188, "I already have a Lead Ball loaded.", 1)
				end;
			end;
		end;
		if l_keysheld_0[_G.get_keybinds("checkammo")] == true and (v182 == false and tick() - v_u_160 > 0) then
			v182 = true
			v_u_160 = tick() + 1
			v_u_11.reload_dump:Play(0.1, 1, 1)
			if v_u_189.ball == false then
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "powder_dump",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
				delay(0.5, function() --[[ Line: 2420 ]]
					--[[ Upvalues: (copy 1): v_u_189, (ref 2): v_u_4, (ref 3): l_Value_0, (ref 4): v_u_10, (ref 5): l_Character_0, (ref 6): l_Value_1, (ref 7): v_u_7, (ref 8): v_u_19, (ref 9): v_u_188 ]]
					v_u_189.powder = false
					local v208 = v_u_4
					local v209 = "walker_setstate"
					local v210 = {}
					local v211 = l_Value_0
					if v_u_10 ~= "" then
						v211 = v_u_10
					end;
					v210.main = {
						["char"] = l_Character_0,
						["originweapon"] = v211,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v210.walker_slot = v_u_188
					v210.walker_state = v_u_189
					v208(v209, v210)
				end)
			end;
		end;
		if (l_keysheld_0[Enum.KeyCode.Two] == true or l_keysheld_0[Enum.KeyCode.DPadRight] == true) and (v182 == false and tick() - v_u_160 > 0) then
			v182 = true
			if v_u_189.ball == false then
				if v_u_189.powder == false or v_u_189.powder < 1 then
					v_u_160 = tick() + v186
					v_u_11.reload_powder:Play(0.1, 1, 1 / v186)
					local v212 = tick()
					repeat
						v_u_160 = tick() + v186 / 2
						l_RenderStepped_0:Wait()
					until tick() - v212 >= v186 / 2;
					v_u_11.reload_powder:AdjustSpeed(0)
					v_u_11.reload_powder.TimePosition = 0.5
					if v_u_189.powder == false then
						v_u_189.powder = 0
					end;
					local l_powder_0 = v_u_189.powder
					local v213 = v_u_4
					local v214 = "walker_setstate"
					local v215 = {}
					local v216 = l_Value_0
					if v_u_10 ~= "" then
						v216 = v_u_10
					end;
					v215.main = {
						["char"] = l_Character_0,
						["originweapon"] = v216,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v215.walker_slot = v_u_188
					v215.walker_state = v_u_189
					v213(v214, v215)
					local v217 = game.ReplicatedStorage.sound_library.tools.walker.powder_pour:Clone()
					game:GetService("Debris"):AddItem(v217, 1)
					v217.TimePosition = math.random(0, 500) / 100
					v217.Parent = l_Character_0.HumanoidRootPart
					v217:Play()
					local v218 = tick()
					repeat
						v_u_166(v_u_188)
						v_u_160 = tick() + v186 / 2
						v_u_189.powder = l_powder_0 + (tick() - v218)
						l_RenderStepped_0:Wait()
					until v_u_189.powder >= 1 or l_keysheld_0[Enum.KeyCode.Two] ~= true and (l_keysheld_0[Enum.KeyCode.DPadRight] ~= true and tick() - v218 >= 0.1);
					if v217 then
						v217:Destroy()
					end;
					v_u_11.reload_powder:AdjustSpeed(1 / v186)
					v_u_11.reload_powder.TimePosition = 0.5
				else
					_G.popupmsg("toomuch" .. v_u_188, "There\'s too much powder in this chamber..", 1)
				end;
			else
				_G.popupmsg("ballblock" .. v_u_188, "I can\'t fill with a Lead Ball in the way..", 1)
			end;
		end;
		if (l_keysheld_0[Enum.KeyCode.Three] == true or l_keysheld_0[Enum.KeyCode.DPadUp] == true) and (v182 == false and tick() - v_u_160 > 0) then
			v182 = true
			v_u_160 = tick() + v185
			v_u_11.reload_lever:Play(0.1, 1, 1 / v185)
			delay(0.5, function() --[[ Line: 2513 ]]
				--[[ Upvalues: (ref 1): v_u_188, (ref 2): l_Parent_0, (ref 3): v_u_4, (ref 4): l_Value_0, (ref 5): v_u_10, (ref 6): l_Character_0, (ref 7): l_Value_1, (ref 8): v_u_7, (ref 9): v_u_19 ]]
				local v219 = v_u_188 - 1
				local v220 = v219 <= 0 and 6 or v219
				local v221 = _G["walkerstate" .. l_Parent_0.slot.Value][v220]
				if v221 and v221.ball == "half" then
					v221.ball = true
					local v222 = v_u_4
					local v223 = "walker_setstate"
					local v224 = {}
					local v225 = l_Value_0
					if v_u_10 ~= "" then
						v225 = v_u_10
					end;
					v224.main = {
						["char"] = l_Character_0,
						["originweapon"] = v225,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v224.walker_slot = v220
					v224.walker_state = v221
					v222(v223, v224)
				end;
			end)
		end;
		if (l_keysheld_0[Enum.KeyCode.Four] == true or l_keysheld_0[Enum.KeyCode.DPadDown] == true) and (v182 == false and tick() - v_u_160 > 0) then
			l_core_checkers_0.check_ammo = 0
			l_core_checkers_0.inv_swapping = true
			v_u_180(true)
			return;
		end;
		if l_keysheld_0.m1 == true and (v182 == false and tick() - v_u_160 > 0) then
			v182 = true
			v_u_160 = tick() + 0.3
			v_u_11.reload_cylinder:Play(0.1, 1, 3.4333333333333336)
			local v226 = v_u_4
			local v227 = "walker_cylinder_rotate"
			local v228 = {}
			local v229 = l_Value_0
			if v_u_10 ~= "" then
				v229 = v_u_10
			end;
			v228.main = {
				["char"] = l_Character_0,
				["originweapon"] = v229,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v226(v227, v228)
			local v230 = _G
			local v231 = "walkercylinder" .. l_Parent_0.slot.Value
			v230[v231] = v230[v231] + 1
			if _G["walkercylinder" .. l_Parent_0.slot.Value] > 6 then
				_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
			end;
		end;
		if l_keysheld_0.m1 ~= true and (l_keysheld_0[Enum.KeyCode.One] ~= true and (l_keysheld_0[Enum.KeyCode.Two] ~= true and (l_keysheld_0[Enum.KeyCode.Three] ~= true and (l_keysheld_0[Enum.KeyCode.Four] ~= true and (l_keysheld_0[_G.get_keybinds("alt")] ~= true and (l_keysheld_0[Enum.KeyCode.DPadLeft] ~= true and (l_keysheld_0[Enum.KeyCode.DPadUp] ~= true and (l_keysheld_0[Enum.KeyCode.DPadRight] ~= true and l_keysheld_0[Enum.KeyCode.DPadDown] ~= true)))))))) then
			v182 = false
		end;
		l_RenderStepped_0:Wait()
		if v_u_12.state ~= "walker_reload" or (v_u_9 == nil or (v_u_9.Health <= 0 or v_u_12.equipped == false)) then
			l_core_checkers_0.check_ammo = 0
			v_u_12.state = "normal"
			l_core_checkers_0.inv_swapping = true
			if v_u_9 and (v_u_9.Health > 0 and v_u_12.equipped == true) then
				local v232 = _G
				local v233 = "walkercylinder" .. l_Parent_0.slot.Value
				v232[v233] = v232[v233] + 1
				if _G["walkercylinder" .. l_Parent_0.slot.Value] > 6 then
					_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
				end;
				v_u_160 = tick() + 0.5
				v_u_11.reload_idle:Stop(0.1)
				v_u_11.reload_end:Play(0.1, 1, 2)
				v_u_1:s_wait(0.5)
			end;
			v_u_2.Value = false
			return;
		end;
	end;
end;
local v_u_235 = false
local function v_u_303(p236) --[[ Line: 2613 ]]
	--[[ Upvalues: (copy 1): v_u_2, (ref 2): l_Value_0, (copy 3): v_u_12, (copy 4): v_u_234, (copy 5): l_core_checkers_0, (ref 6): v_u_10, (ref 7): v_u_19, (ref 8): v_u_7, (copy 9): v_u_180, (copy 10): l_Character_0, (copy 11): l_Parent_0, (copy 12): v_u_1, (copy 13): v_u_11, (copy 14): l_ammo_give_0, (copy 15): v_u_9, (copy 16): l_RenderStepped_0, (copy 17): l_LocalPlayer_0, (ref 18): v_u_235, (copy 19): v_u_4, (copy 20): l_Value_1, (ref 21): v_u_5, (copy 22): l_remotes_0 ]]
	if v_u_2.Value == true and (l_Value_0 == "walker" and v_u_12.state == "walker_reload") then
		v_u_234()
		return;
	end;
	if v_u_2.Value == true or v_u_12.state == "reload" then
		return;
	end;
	if l_core_checkers_0.queue_inv ~= nil then
		return;
	end;
	if l_Value_0 == "walker" then
		v_u_234()
		return;
	end;
	if l_Value_0 == "mauser" and (v_u_10 == "mauservariant" and (v_u_12.equipped == true and v_u_19.ammo_mag < v_u_7.capacity)) then
		v_u_180(true)
		return;
	end;
	if l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and (l_Character_0.elitekit.Value == "ocelot" and (v_u_12.equipped and (not l_Character_0.action.Value and v_u_19.ammo_mag < v_u_7.capacity)))) then
		v_u_180(true)
		return;
	end;
	local l_ammo_mag_0 = v_u_19.ammo_mag
	local l_capacity_0 = v_u_7.capacity
	if l_Value_0 == "lebel" and v_u_12.alt_mode == true then
		l_ammo_mag_0 = l_ammo_mag_0 - 1
	end;
	local v237 = l_Value_0 == "springfield" and v_u_12.alt_mode == true and 40 or l_capacity_0
	if l_Parent_0:FindFirstChild("mounted_weapon") or l_Value_0 == "browningmg" then
		return;
	end;
	if l_Value_0 == "rooklauncher" and (l_Character_0:FindFirstChild("equipment") and l_Character_0.equipment.Value <= 0) then
		return;
	end;
	if v237 <= l_ammo_mag_0 and (l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == true and (v_u_12.dual_wield_tool and (_G.get_settings("disableakimboreloads") ~= true and p236 ~= true)))) then
		v_u_12.dual_wield_tool.event:Fire("reload_weapon_swap")
	end;
	if v237 <= l_ammo_mag_0 or (v_u_2.Value == true or tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier - 0.1) then
		return;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if l_Value_0 == "springfield" and v_u_12.alt_mode == true then
		if v_u_12.extra_mag == false then
			_G.popupmsg("nomags", "I don\'t have any more extra magazines.", 1)
		else
			v_u_2.Value = true
			v_u_12.state = "reload"
			v_u_12.extra_mag = false
			local v238 = v_u_19.ammo_mag >= 1
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "reloadstart",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_11.pedersen_mag_eject:Play(0.1, 1, 0.5)
			v_u_1:s_wait(2)
			v_u_11.pedersen_mag_in:Play(0.1, 1, 0.5)
			v_u_1:s_wait(2)
			v_u_19.ammo_mag = 40
			if v238 == true then
				v_u_19.ammo_mag = v_u_19.ammo_mag + 1
			else
				v_u_11.pedersen_charge:Play(0.1, 1, 1)
				v_u_1:s_wait(1)
			end;
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "reloadend",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_12.interrupt_reload = false
			v_u_12.state = "normal"
			v_u_2.Value = false
		end;
	end;
	if l_Value_0 == "enfield" and v_u_12.alt_mode == true then
		if v_u_10 == "enfieldvariant" then
			return;
		elseif l_Parent_0:FindFirstChild("gl_uses") == nil then
			return;
		elseif l_Parent_0.gl_uses.Value <= 0 then
			_G.popupmsg("nogl", "I don\'t have any more rifle grenades left.", 1)
			return;
		elseif v_u_19.blank_round_loaded ~= nil and v_u_19.blank_round_loaded ~= true then
			v_u_2.Value = true
			v_u_12.state = "reload"
			v_u_11.discard_grenade:Play(0.1, 1, 1)
			v_u_1:s_wait(1)
			v_u_11.blank_reload:Play(0.1, 1, 1)
			v_u_1:s_wait(1)
			v_u_11.reload_end:Play(0.1, 1, 2)
			v_u_1:s_wait(0.5)
			v_u_11.load_grenade:Play(0.1, 1, 0.6666666666666666)
			v_u_1:s_wait(1.5)
			local v239 = v_u_19
			v239.ammo_mag = v239.ammo_mag + 1
			v_u_19.blank_round_loaded = true
			v_u_12.interrupt_reload = false
			v_u_12.state = "normal"
			v_u_2.Value = false
		end;
	end;
	if v_u_7.require_full_load and (v_u_7.require_full_load == true and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] < v_u_7.capacity) then
		return;
	end;
	if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
		return;
	end;
	if l_Value_0 == "lebel" and (v_u_12.alt_mode == true and (v_u_19.force_block_fire == false and v_u_19.ammo_mag > 0)) then
		return;
	end;
	if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 then
		return;
	end;
	if l_Parent_0:FindFirstChild("mag_empty") then
		l_Parent_0.mag_empty.Value = false
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if p236 == true then
		v_u_9:EquipTool(l_Parent_0)
		local v240 = tick()
		repeat
			l_RenderStepped_0:Wait()
		until v_u_12.equipped == true or tick() - v240 >= 1;
		if v_u_12.equipped == false then
			return;
		end;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if v_u_12.equipped == false then
		return;
	end;
	if l_Value_0 == "lewis" then
		l_core_checkers_0.sprint_block = true
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "reloadstart",
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	v_u_12.state = "reload"
	v_u_12.interrupt_reload = false
	v_u_2.Value = true
	local l_reload_start_0 = v_u_7.reload_start
	local v241 = false
	local v242
	if v_u_19.ammo_mag <= 0 and v_u_11.reload_empty or l_Value_0 == "lebel" and v_u_19.ammo_mag <= 1 then
		v241 = v_u_19.ammo_mag <= 0 and true or v241
		l_reload_start_0 = v_u_7.reload_empty
		v242 = "reload_empty"
	else
		v242 = "reload_start"
	end;
	local v243 = false
	local v244 = false
	local v245 = false
	local v246 = false
	local v247 = false
	local v248
	if l_Character_0.perk.Value == "vet" then
		v248 = l_Value_0 ~= "rooklauncher" and v_u_10 ~= "springfieldvariant"
	else
		v248 = l_Value_0 == "scho" and (l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == l_Character_0.elitekit.Value)) and true or v247
	end;
	if v248 == true and v_u_11[v242 .. "_vet"] then
		v242 = v242 .. "_vet"
		if l_Value_0 == "lebel" or l_Value_0 == "scho" then
			v242 = l_Value_0 == "scho" and v_u_19.ammo_mag <= 0 and "reload_start" or (v_u_19.ammo_mag <= 0 and "reload_empty" or v242)
			if v242 == "reload_start_vet" or v242 == "reload_empty_vet" then
				l_reload_start_0 = l_reload_start_0 * 1.2
			end;
		end;
	end;
	if (l_Value_0 == "lever" or (l_Value_0 == "mares" or (l_Value_0 == "autosg" or l_Value_0 == "trench"))) and v_u_19.ammo_mag <= 0 then
		v243 = true
		if v248 == true then
			l_reload_start_0 = l_reload_start_0 * 0.9
		end;
	end;
	if l_Value_0 == "enfield" or l_Value_0 == "mondragon" then
		v244 = true
		if v_u_19.ammo_mag <= 1 then
			v242 = "reload_empty"
			v243 = true
		end;
		if v248 == true then
			v244 = false
			if v_u_19.ammo_mag > 0 then
				l_reload_start_0 = l_reload_start_0 * 1.2
				v242 = "reload_start_vet"
				v243 = false
			end;
		end;
		if l_Value_0 == "mondragon" then
			v244 = false
			v243 = false
			if v_u_19.ammo_mag > 0 then
				v242 = "reload_start"
			else
				v242 = "reload_empty"
			end;
		elseif (v_u_19.ammo_mag <= 0 or v_u_19.ammo_mag == 1 and v244 == true) and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= 5 then
			l_reload_start_0 = v_u_7.reload_start + v_u_7.reload_full
			v242 = "reload_clip_empty"
			v243 = false
		end;
	end;
	if l_Value_0 == "mpgun" or (l_Value_0 == "pugsley" or l_Value_0 == "lewis") then
		v245 = true
		v246 = true
		if v_u_19.ammo_mag <= 0 then
			local l_reload_empty_0 = v_u_7.reload_empty
			if l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == l_Character_0.elitekit.Value) then
				l_reload_empty_0 = l_reload_empty_0 * 0.6
			end;
			v_u_11.reload_bolt:Play(0.1, 1, 1 / l_reload_empty_0)
			v_u_1:s_wait(l_reload_empty_0)
		end;
		if l_Value_0 == "mpgun" and (l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == l_Character_0.elitekit.Value)) then
			l_reload_start_0 = l_reload_start_0 * 0.9
			v242 = "reload_start_soldat"
		end;
	end;
	if l_Value_0 == "mauser" or l_Value_0 == "mausercarbine" then
		v244 = true
		v245 = true
		v246 = true
		l_reload_start_0 = v_u_7.reload_full
		v242 = v248 == true and "reload_full_vet" or "reload_full"
		if v_u_19.ammo_mag > 0 then
			local l_reload_start_1 = v_u_7.reload_start
			local v249
			if v_u_19.ammo_mag == 1 then
				l_reload_start_1 = v_u_7.reload_empty
				v249 = "reload_one"
			else
				v249 = "reload_start"
			end;
			if v248 == true then
				v249 = v249 .. "_vet"
			end;
			v_u_11[v249]:Play(0.1, 1, 1 / l_reload_start_1)
			v_u_1:s_wait(l_reload_start_1)
			if v_u_19.ammo_mag > 0 and v248 == false then
				v_u_19.ammo_mag = 0
			end;
		end;
	end;
	local v250 = l_Value_0 == "remington" and true or v245
	if l_Value_0 == "lebel" then
		v243 = true
		v244 = true
		if v_u_12.alt_mode == true then
			v241 = false
			v250 = true
			v243 = false
			v244 = false
			v242 = "reload_alt"
			l_reload_start_0 = v_u_7.reload_alt
			if v_u_19.alt_extra == false then
				v242 = v_u_19.ammo_mag > 0 and "reload_alt_extra" or v242
				v_u_19.alt_extra = true
			end;
		else
			if v_u_19.force_block_fire == true then
				v242 = "reload_empty"
				v244 = false
			end;
			v_u_19.alt_extra = false
		end;
	end;
	local v251 = false
	if l_Value_0 == "steyr" then
		v244 = v248 ~= true and true or v244
		v243 = v242 == "reload_empty" and true or v243
		if v248 == true then
			v243 = false
			l_reload_start_0 = l_reload_start_0 * 1.2
			if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= v_u_7.capacity and v_u_19.ammo_mag <= 1 then
				if v_u_19.ammo_mag == 1 then
					v242 = "reload_one_vet"
					l_reload_start_0 = 0.8
				else
					v242 = nil
				end;
			elseif v_u_19.ammo_mag <= 0 then
				v242 = "reload_empty"
				v243 = true
			end;
			if v_u_10 == "steyrvariant" and v_u_19.ammo_mag <= 0 then
				v243 = true
				v242 = "reload_empty"
			end;
		end;
	end;
	if l_Value_0 == "mosin" or l_Value_0 == "springfield" then
		v244 = v248 ~= true and true or v244
		if v_u_19.ammo_mag <= 1 then
			v242 = "reload_empty"
			v243 = true
		end;
		if v248 == true then
			v243 = false
			if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= v_u_7.capacity and (v_u_19.ammo_mag <= 1 and v_u_10 ~= "springfieldvariant") then
				l_reload_start_0 = v_u_7.reload_start
				if v_u_19.ammo_mag <= 0 then
					v242 = "reload_clip_start_empty"
				elseif v_u_19.ammo_mag == 1 then
					l_reload_start_0 = l_reload_start_0 * 1.2
					v242 = "reload_clip_start_one"
				end;
			elseif v_u_19.ammo_mag <= 0 then
				v242 = "reload_empty"
				v243 = true
			elseif v_u_19.ammo_mag == 1 then
				v242 = l_Value_0 == "springfield" and "reload_start_vet" or "reload_empty_vet"
				l_reload_start_0 = l_reload_start_0 * 1.2
			else
				l_reload_start_0 = l_reload_start_0 * 1.2
				v242 = "reload_start_vet"
			end;
		end;
	end;
	if l_Value_0 == "mosin" and (v_u_10 == "mosinvariant" and (l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= v_u_7.capacity and v248 == false)) then
		if v_u_19.ammo_mag == 0 then
			l_reload_start_0 = v_u_7.reload_start
			v242 = "reload_clip_start_empty"
			v243 = false
		elseif v_u_19.ammo_mag == 1 then
			l_reload_start_0 = v_u_7.reload_start
			v242 = "reload_clip_start_empty_novet"
			v243 = false
		end;
	end;
	if l_Value_0 == "saa" then
		if v248 == true then
			l_reload_start_0 = l_reload_start_0 * 1.2
		end;
		if l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
			l_reload_start_0 = l_reload_start_0 * 0.75
		end;
		v242 = l_Character_0:FindFirstChild("cowboy") and "reload_start_vet" or v242
		if v_u_10 ~= "" then
			v242 = "reload_start"
		end;
	end;
	local v252 = false
	if l_Value_0 == "dbgun" and (v248 == true and (v_u_19.ammo_mag <= 0 and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= 2)) then
		v243 = true
		if math.random(1, 100) == 1 or l_LocalPlayer_0:FindFirstChild("doomer") then
			v252 = true
			v242 = "reload_empty_doom"
		else
			v242 = "reload_empty_vet"
		end;
	end;
	if l_Value_0 == "rooklauncher" or (l_Value_0 == "henry" or (l_Value_0 == "rsc" or l_Value_0 == "crossbow")) then
		v250 = true
		if l_Value_0 == "rsc" then
			v246 = true
			if v248 == true and v_u_19.ammo_mag <= 1 then
				v242 = "reload_start"
			end;
		end;
	end;
	if l_Value_0 == "mpistol" then
		v250 = true
		v246 = true
		if v248 == true then
			if v_u_19.ammo_mag <= 1 then
				v242 = "reload_start"
			else
				l_reload_start_0 = l_reload_start_0 * 1.3
			end;
		end;
	end;
	if l_Value_0 == "henry" and v248 == true then
		if v_u_12.alt_mode == true then
			v242 = "reload_start"
		else
			l_reload_start_0 = l_reload_start_0 * 0.8
		end;
	end;
	if l_Value_0 == "pieper" and v242 == "reload_start_vet" then
		if v_u_19.ammo_mag <= 0 then
			v242 = "reload_start"
		else
			l_reload_start_0 = l_reload_start_0 * 1.3
		end;
	end;
	if l_Value_0 == "pieper" and v_u_235 == false then
		l_reload_start_0 = l_reload_start_0 * 0.7
		v242 = "reload_partial"
	end;
	if l_Value_0 == "pieper" and v_u_12.slide_locked == true then
		v_u_12.slide_locked = false
		v_u_11.hammer_lower:Play(0.1, 1, 2)
		local v253 = v_u_4
		local v254 = "cylinder_rotate"
		local v255 = {}
		local v256 = l_Value_0
		if v_u_10 ~= "" then
			v256 = v_u_10
		end;
		v255.main = {
			["char"] = l_Character_0,
			["originweapon"] = v256,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v255.otherdir = true
		v253(v254, v255)
		v_u_1:s_wait(0.5)
	end;
	if l_core_checkers_0.morale == true and l_Value_0 ~= "rooklauncher" then
		l_reload_start_0 = l_reload_start_0 * 0.7
	end;
	if l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.elitekit.Value == l_Character_0.class.Value) then
		l_reload_start_0 = l_reload_start_0 * 0.8
	end;
	if v_u_11.fire then
		v_u_11.fire:Stop(0)
	end;
	if v242 ~= nil then
		v_u_11[v242]:Stop(0)
		v_u_11[v242]:Play(0.1, 1, 1 / l_reload_start_0)
		v_u_1:s_wait(l_reload_start_0)
		if l_Value_0 == "enfield" and v242 == "reload_clip_empty" or l_Value_0 == "mondragon" and v242 == "reload_empty" then
			l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 5
			v_u_19.ammo_mag = v_u_19.ammo_mag + 5
		end;
		if l_Value_0 == "pieper" and v_u_235 == true then
			local v257 = v_u_4
			local v258 = "cylinder_forcecylinder"
			local v259 = {}
			local v260 = l_Value_0
			if v_u_10 ~= "" then
				v260 = v_u_10
			end;
			v259.main = {
				["char"] = l_Character_0,
				["originweapon"] = v260,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v257(v258, v259)
			if v248 == true then
				local v261 = l_core_checkers_0
				local v262 = l_ammo_give_0 .. "_reserves"
				v261[v262] = v261[v262] + v_u_19.ammo_mag
				v_u_19.ammo_mag = 0
			else
				v_u_19.ammo_mag = 0
			end;
		end;
		if v_u_12.dropped == true then
			return;
		end;
	end;
	if v_u_12.equipped == false then
		return;
	end;
	if v250 == false then
		if v244 == true and (v241 == false and v248 == false) then
			v_u_19.ammo_mag = v_u_19.ammo_mag - 1
		end;
		local v263 = 0
		if v243 == true then
			v263 = v263 - 1
		end;
		if (l_Value_0 == "scho" or (l_Value_0 == "mauser" or l_Value_0 == "mausercarbine")) and v248 == false then
			v_u_19.ammo_mag = 0
		end;
		if l_Value_0 == "saa" and (v_u_19.ammo_mag <= 4 and v_u_19.ammo_mag > 0) then
			local v264 = (v_u_19.ammo_mag + 1) / 2
			local v265 = v264 ~= math.ceil(v264)
			if v264 > 0.5 then
				for _ = 1, v264 do
					local v266 = 0.25
					v_u_11.reload_loop_after_twice:Play(0.05, 1, 1 / v266)
					v_u_1:s_wait(v266)
				end;
			end;
			if v_u_12.dropped == true then
				return;
			end;
			if v265 == true then
				local v267 = 0.25
				v_u_11.reload_loop_after:Play(0.05, 1, 1 / v267)
				v_u_1:s_wait(v267)
			end;
			if v_u_12.dropped == true then
				return;
			end;
		end;
		if v_u_11.reload_loop then
			v_u_11.reload_loop.Looped = true
		end;
		local v268 = v263 + (v_u_7.capacity - v_u_19.ammo_mag)
		if l_Value_0 == "springfield" and (l_Value_1:FindFirstChild("accessorypart") and (l_Value_1.accessorypart:FindFirstChild("extra") and (l_Value_1.accessorypart.extra:FindFirstChild("spareammo1A") and (l_Value_1.accessorypart.extra:FindFirstChild("spareammo2A") and (l_Value_1.accessorypart.extra.spareammo1A.Transparency == 0 or l_Value_1.accessorypart.extra.spareammo2A.Transparency == 0))))) and (v243 == true and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 2) then
			local v269 = v_u_4
			local v270 = "springfield_ammoskin_check"
			local v271 = {}
			local v272 = l_Value_0
			if v_u_10 ~= "" then
				v272 = v_u_10
			end;
			v271.main = {
				["char"] = l_Character_0,
				["originweapon"] = v272,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v269(v270, v271)
		end;
		for v273 = 1, v268 do
			if v_u_5 == true or v_u_12.equipped == false then
				return;
			end;
			if v_u_12.dropped == true then
				return;
			end;
			if v243 == true and (l_Value_0 == "lebel" and v248 == true and 2 or 1) == l_core_checkers_0[l_ammo_give_0 .. "_reserves"] or l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
				break;
			end;
			if v_u_12.dropped == true then
				return;
			end;
			local l_reload_loop_0 = v_u_7.reload_loop
			if l_core_checkers_0.morale == true then
				l_reload_loop_0 = l_reload_loop_0 * 0.7
			end;
			if l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.elitekit.Value == l_Character_0.class.Value) then
				l_reload_loop_0 = l_reload_loop_0 * 0.8
			end;
			if l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
				l_reload_loop_0 = l_reload_loop_0 * 0.5
			end;
			local v274 = "reload_loop"
			if v_u_10 == "springfieldvariant" and l_Value_0 == "springfield" then
				if v_u_19.ammo_mag >= 23 then
					v_u_11.reload_loop.Looped = false
					l_reload_loop_0 = l_reload_loop_0 * 1.4
					v274 = "reload_heavyloop"
				elseif v_u_19.ammo_mag >= 21 then
					v_u_11.reload_loop.Looped = false
					l_reload_loop_0 = l_reload_loop_0 * 1.3
					v274 = "reload_heavyloop"
				elseif v_u_19.ammo_mag >= 19 then
					v_u_11.reload_loop.Looped = false
					l_reload_loop_0 = l_reload_loop_0 * 1.2
					v274 = "reload_heavyloop"
				elseif v_u_19.ammo_mag >= 17 then
					v_u_11.reload_loop.Looped = false
					l_reload_loop_0 = l_reload_loop_0 * 1.1
				end;
			end;
			if l_Value_0 == "dbgun" then
				if v248 == true and v243 == true then
					l_reload_loop_0 = l_reload_loop_0 * 1.4
					if v252 == true then
						v274 = "reload_dual_doom"
					else
						v274 = "reload_dual_vet"
					end;
				else
					if v_u_12.db_othershell and v_u_12.db_othershell == true then
						v_u_11[v274]:Stop(0)
						v_u_12.db_othershell = false
						v274 = "reload_loop_alt"
					end;
					v_u_12.db_othershell = true
				end;
			end;
			local v275, v276
			if v_u_10 == "mosinvariant" and v248 == false then
				v275 = true
				v276 = 0
			else
				v275 = false
				v276 = 1
			end;
			if (l_Value_0 == "mosin" or l_Value_0 == "steyr" and v_u_10 == "" or l_Value_0 == "springfield") and ((v248 == true and true or v275) == true and (v_u_19.ammo_mag <= v276 and (l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= v_u_7.capacity and v_u_10 ~= "springfieldvariant"))) then
				l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - (v_u_7.capacity - 1 - v_u_19.ammo_mag)
				v_u_19.ammo_mag = v_u_7.capacity - 1
				v274 = "reload_clip"
				l_reload_loop_0 = v_u_7.reload_full
				if v_u_10 == "mosinvariant" and v248 == false then
					l_reload_loop_0 = l_reload_loop_0 * 1.2
				end;
				v251 = true
			end;
			if (l_Value_0 == "enfield" or l_Value_0 == "mondragon") and (v_u_19.ammo_mag + 5 <= v_u_7.capacity and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] >= 5) then
				l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 4
				v_u_19.ammo_mag = v_u_19.ammo_mag + 4
				v274 = "reload_clip"
				l_reload_loop_0 = v_u_7.reload_full
				if v248 == true then
					l_reload_loop_0 = l_reload_loop_0 * 0.7
				end;
			end;
			v_u_11[v274]:Play(v273 > 1 and 0 or 0.05, 1, 1 / l_reload_loop_0)
			v_u_1:s_wait(l_reload_loop_0)
			v_u_19.ammo_mag = v_u_19.ammo_mag + 1
			if l_Value_0 ~= "saa" or (not l_Character_0:FindFirstChild("elitekit") or l_Character_0.elitekit.Value ~= "ocelot") then
				l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 1
			end;
			if l_Value_0 == "springfield" and (l_Value_1:FindFirstChild("accessorypart") and (l_Value_1.accessorypart:FindFirstChild("extra") and (l_Value_1.accessorypart.extra:FindFirstChild("spareammo1A") and (l_Value_1.accessorypart.extra:FindFirstChild("spareammo2A") and (l_Value_1.accessorypart.extra.spareammo1A.Transparency == 0 or l_Value_1.accessorypart.extra.spareammo2A.Transparency == 0))))) and (v243 == true and 2 or 1) >= l_core_checkers_0[l_ammo_give_0 .. "_reserves"] then
				local v277 = v_u_4
				local v278 = "springfield_ammoskin_check"
				local v279 = {}
				local v280 = l_Value_0
				if v_u_10 ~= "" then
					v280 = v_u_10
				end;
				v279.main = {
					["char"] = l_Character_0,
					["originweapon"] = v280,
					["weapon"] = l_Value_0,
					["model"] = l_Value_1,
					["module"] = v_u_7,
					["core"] = v_u_19
				}
				v277(v278, v279)
			end;
			if v_u_12.interrupt_reload == true or l_core_checkers_0.queue_inv ~= nil then
				if l_Value_0 == "pieper" and l_core_checkers_0.queue_inv ~= nil then
					local v281 = v_u_4
					local v282 = "cylinder_rotate"
					local v283 = {}
					local v284 = l_Value_0
					if v_u_10 ~= "" then
						v284 = v_u_10
					end;
					v283.main = {
						["char"] = l_Character_0,
						["originweapon"] = v284,
						["weapon"] = l_Value_0,
						["model"] = l_Value_1,
						["module"] = v_u_7,
						["core"] = v_u_19
					}
					v283.otherdir = true
					v281(v282, v283)
				end;
				break;
			end;
			if v_u_11.reload_loop_after then
				if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 or (v_u_19.ammo_mag >= v_u_7.capacity or l_core_checkers_0.queue_inv ~= nil) then
					break;
				end;
				local l_reload_loop_after_0 = v_u_7.reload_loop_after
				v_u_11.reload_loop_after:Play(l_reload_loop_after_0 / 2, 1, 1 / l_reload_loop_after_0)
				v_u_1:s_wait(l_reload_loop_after_0)
			end;
			if v_u_12.equipped == false then
				return;
			end;
			if v_u_19.ammo_mag >= v_u_7.capacity or v251 == true then
				break;
			end;
			if v_u_12.dropped == true then
				return;
			end;
		end;
		if v_u_11.reload_loop then
			v_u_11.reload_loop:Stop(0.1)
			v_u_11.reload_loop.Looped = false
		end;
		if l_Value_0 == "saa" and v_u_19.ammo_mag < 6 then
			for _ = 1, 6 - v_u_19.ammo_mag do
				local v285 = 0.3
				v_u_11.reload_loop_after:Play(0.05, 1, 1 / v285)
				v_u_1:s_wait(v285)
			end;
		end;
		if l_Value_0 == "pieper" and (l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 or v_u_12.interrupt_reload == true) and v_u_19.ammo_mag < 7 then
			local l_reload_loop_after_1 = v_u_7.reload_loop_after
			v_u_11.reload_loop_after:Play(0.05, 1, 1 / l_reload_loop_after_1)
			v_u_1:s_wait(l_reload_loop_after_1)
		end;
		local l_reload_end_0 = v_u_7.reload_end
		if l_core_checkers_0.morale == true then
			l_reload_end_0 = l_reload_end_0 * 0.7
		end;
		if l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.elitekit.Value == l_Character_0.class.Value) then
			l_reload_end_0 = l_reload_end_0 * 0.8
		end;
		if l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
			l_reload_end_0 = l_reload_end_0 * 0.5
		end;
		local v286 = l_Value_0 == "scho" and (l_Value_1:FindFirstChild("parts") and (l_Value_1.parts:FindFirstChild("break") and (l_Value_1.parts["break"]:FindFirstChild("snubbarrel") and l_Value_1.parts["break"].snubbarrel.Transparency == 0))) and "reload_end_vet" or "reload_end"
		if v248 == true and v_u_11[v286 .. "_vet"] then
			v286 = v286 .. "_vet"
		end;
		local v287 = l_Value_0 == "dbgun" and v252 == true and "reload_end_doom" or v286
		if v_u_11[v287] then
			v_u_11[v287]:Play(0.1, 1, 1 / l_reload_end_0)
			v_u_1:s_wait(l_reload_end_0)
		end;
		if v_u_12.dropped == true then
			return;
		end;
	else
		local v288 = false
		if l_Value_0 == "mpistol" then
			local v289 = true
			if v248 == true then
				if v_u_19.ammo_mag > 0 then
					v289 = false
					v288 = true
				end;
			else
				v_u_19.ammo_mag = 0
			end;
			if v289 == true then
				local l_reload_end_1 = v_u_7.reload_end
				local v290
				if v_u_19.ammo_mag == 0 and v_u_12.slide_locked == true then
					l_reload_end_1 = l_reload_end_1 * 0.7
					if v248 == true then
						l_reload_end_1 = l_reload_end_1 * 0.6
						v290 = "reload_end_locked_vet"
					else
						v290 = "reload_end_locked"
					end;
				else
					v290 = "reload_end"
				end;
				if l_core_checkers_0.morale == true then
					l_reload_end_1 = l_reload_end_1 * 0.7
				end;
				v_u_11[v290]:Play(0.1, 1, 1 / l_reload_end_1)
				v_u_1:s_wait(l_reload_end_1)
				if v_u_12.dropped == true then
					return;
				end;
			end;
		end;
		if l_Value_0 == "rsc" then
			local v291 = true
			if v248 == true then
				if v_u_19.ammo_mag >= 1 then
					v291 = false
					v288 = true
				else
					v288 = false
				end;
			end;
			if v291 == true then
				local l_reload_end_2 = v_u_7.reload_end
				local v292
				if v_u_19.ammo_mag == 0 and v_u_12.slide_locked == true then
					l_reload_end_2 = l_reload_end_2 * 0.5
					v292 = "reload_end_locked"
				else
					v292 = "reload_end"
				end;
				if l_core_checkers_0.morale == true then
					l_reload_end_2 = l_reload_end_2 * 0.7
				end;
				v_u_11[v292]:Play(0.1, 1, 1 / l_reload_end_2)
				v_u_1:s_wait(l_reload_end_2)
				if v248 == false then
					v_u_19.ammo_mag = 0
				end;
				if v_u_12.dropped == true then
					return;
				end;
			end;
		end;
		if v246 == true then
			local v293 = v_u_7.capacity - v_u_19.ammo_mag
			v_u_19.ammo_mag = v_u_7.capacity
			local v294 = l_core_checkers_0
			local v295 = l_ammo_give_0 .. "_reserves"
			v294[v295] = v294[v295] - v293
			if v288 == true then
				v_u_19.ammo_mag = v_u_19.ammo_mag + 1
			end;
		else
			v_u_19.ammo_mag = v_u_19.ammo_mag + 1
			if v_u_7.tooltype == "gun" then
				l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 1
			end;
		end;
		if l_Value_0 == "mpistol" then
			local v296 = v_u_4
			local v297 = "m_mag_update"
			local v298 = {}
			local v299 = l_Value_0
			if v_u_10 ~= "" then
				v299 = v_u_10
			end;
			v298.main = {
				["char"] = l_Character_0,
				["originweapon"] = v299,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v296(v297, v298)
		end;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if l_Value_0 == "henry" and v248 == true then
		if v_u_12.alt_mode == true and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] > 0 then
			v_u_12.alt_mode = false
		end;
		if l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
			v_u_12.alt_mode = true
		end;
		if v_u_12.alt_mode == false then
			v_u_11.vet_roundreplace:Play(0.1, 1, 2)
			v_u_1:s_wait(0.5)
		end;
	end;
	local v300 = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] < l_core_checkers_0[l_ammo_give_0 .. "_max"] and v_u_7.tooltype == "gun" and true or (workspace.serverStuff.trainingmode.Value == true and true or false)
	if l_Character_0:FindFirstChild("elitekit") and l_Value_0 ~= "snub" then
		v300 = false
	end;
	if v300 == true then
		l_remotes_0.game_handler:FireServer("reloaded_weapon")
	end;
	if l_Value_0 == "crossbow" then
		l_remotes_0.game_handler:FireServer("crossbow_state_handler", l_Parent_0, true)
	end;
	if l_Value_0 == "lewis" then
		l_core_checkers_0.sprint_block = false
	end;
	if v_u_12.equipped == false then
		return;
	end;
	if v_u_9 == nil or v_u_9.Health <= 0 then
		return;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	v_u_19.force_block_fire = false
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "reloadend",
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	if v243 == true then
		if l_Value_0 == "lebel" and v248 == true then
			v_u_19.ammo_mag = v_u_19.ammo_mag + 1
			l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 1
		end;
		v_u_19.ammo_mag = v_u_19.ammo_mag + 1
		l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] - 1
	end;
	if l_Parent_0:FindFirstChild("empty_ammo") and l_core_checkers_0[l_ammo_give_0 .. "_reserves"] <= 0 then
		l_Parent_0.empty_ammo.Value = true
	end;
	if l_Value_0 == "enfield" and v_u_19.blank_round_loaded == true then
		v_u_19.blank_round_loaded = false
	end;
	if v_u_12.dropped == true then
		return;
	end;
	v_u_235 = false
	v_u_12.state = "normal"
	v_u_2.Value = false
	if l_core_checkers_0.queue_inv == nil or l_core_checkers_0.queue_inv == l_Parent_0.slot.Value then
		if p236 == true then
			local v301 = l_LocalPlayer_0.Backpack:FindFirstChild("Bulwark\'s Shield") or l_LocalPlayer_0.Backpack:FindFirstChild("Cavalry Sword")
			if l_Character_0:FindFirstChild("perk") and (l_Character_0.perk.Value == "akimbo" and (l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true)) then
				for _, v302 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
					if v302:FindFirstChild("akimbo") then
						v301 = v302
						break;
					end;
				end;
			end;
			if v301 and v_u_12.interrupt_reload == false then
				v_u_9:EquipTool(v301)
			end;
		elseif l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == true and (v_u_12.dual_wield_tool and (_G.get_settings("disableakimboreloads") ~= true and v_u_12.interrupt_reload == false))) then
			v_u_12.dual_wield_tool.event:Fire("reload_weapon_swap")
		end;
	else
		v_u_12.equipped = false
	end;
	v_u_12.interrupt_reload = false
end;
local v_u_304 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Ten",
	"Eleven",
	"Twelve",
	"Thirteen",
	"Fourteen",
	"Fifteen",
	"Sixteen",
	"Seventeen",
	"Eighteen",
	"Nineteen",
	"Twenty"
}
local function v_u_313() --[[ Line: 3854 ]]
	--[[ Upvalues: (copy 1): v_u_2, (copy 2): v_u_12, (ref 3): v_u_7, (copy 4): l_core_checkers_0, (copy 5): l_Parent_0, (ref 6): l_Value_0, (copy 7): l_Character_0, (ref 8): v_u_19, (copy 9): v_u_304, (copy 10): l_CurrentCamera_0, (copy 11): l_ammo_give_0, (copy 12): v_u_166, (copy 13): v_u_11, (copy 14): v_u_1 ]]
	if v_u_2.Value ~= true and (tick() - v_u_12.draw >= v_u_7.draw_speed / l_core_checkers_0.draw_modifier - 0.1 and (not l_Parent_0:FindFirstChild("mounted_weapon") and l_Value_0 ~= "browningmg")) then
		v_u_2.Value = true
		local v305 = l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") and "More than enough." or "Full."
		local v306 = (l_Value_0 == "mpgun" or l_Value_0 == "pugsley") and 2.5 or 1.5
		local l_capacity_1 = v_u_7.capacity
		local l_ammo_give_1 = v_u_7.ammo_give
		if l_Value_0 == "springfield" and v_u_12.alt_mode == true then
			l_capacity_1 = 40
			l_ammo_give_1 = ".30 Light"
		end;
		local v307 = v_u_19.ammo_mag / l_capacity_1
		if l_Character_0.class.Value == "jaeger" and (l_Character_0:FindFirstChild("elitekit") == nil or l_Value_0 == "mondragon") then
			l_ammo_give_1 = l_ammo_give_1 .. " Pox"
		end;
		local v308 = l_Value_0 == "lebel" and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript") and "8mm Conscript" or ((l_Value_0 == "enfield" and v_u_12.alt_mode == true or v_u_19.blank_round_loaded and v_u_19.blank_round_loaded == true) and ".303 Blank" or l_ammo_give_1)
		local v309 = v307 <= 0.2 and "Almost empty.." or (v307 <= 0.45 and "Less than half.." or (v307 <= 0.55 and "About half.." or (v307 <= 0.75 and "More than half.." or (v307 <= 0.99 and "Almost full.." or v305))))
		if (l_Value_0 == "scho" or (l_Value_0 == "pieper" or (l_Character_0.perk.Value == "vet" or l_Character_0:FindFirstChild("elitekit") and (l_Character_0:FindFirstChild("class") and l_Character_0.elitekit.Value == l_Character_0.class.Value))) or l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot")) and (v307 <= 0.99 and v_u_304[v_u_19.ammo_mag]) then
			v309 = v_u_304[v_u_19.ammo_mag] .. " left."
		end;
		local v310 = (l_Value_0 == "henry" or l_Value_0 == "remington") and "One shot." or (v_u_19.ammo_mag <= 1 and "One shot left." or (l_Character_0.perk.Value == "vet" and l_capacity_1 < v_u_19.ammo_mag and "Full plus one." or v309))
		if l_Value_0 == "crossbow" then
			v310 = "Bolt loaded."
			v306 = 1
		end;
		local v311 = v307 == 0 and "Empty." or v310
		if l_CurrentCamera_0:FindFirstChild("ammo_check") then
			l_CurrentCamera_0.ammo_check.bg.ammo.Text = v308
			l_CurrentCamera_0.ammo_check.bg.count.Text = v311
			l_CurrentCamera_0.ammo_check.bg.count.Visible = true
			l_CurrentCamera_0.ammo_check.bg.ammo.Visible = true
			l_CurrentCamera_0.ammo_check.bg.walkertext.Visible = false
			l_CurrentCamera_0.ammo_check.bg.Size = game.ReplicatedStorage.misc.ammo_check.bg.Size
			l_CurrentCamera_0.ammo_check.bg.maxammo.Visible = true
			l_CurrentCamera_0.ammo_check.bg.maxammo.inner.bar.Size = UDim2.new(1, 0, math.clamp(l_core_checkers_0[l_ammo_give_0 .. "_reserves"] / l_core_checkers_0[l_ammo_give_0 .. "_max"], 0, 1), 0)
			if v_u_7.ammo_reserves_max >= 200 or l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") or v_u_7.hidereserves then
				l_CurrentCamera_0.ammo_check.bg.maxammo.Visible = false
			end;
		end;
		if l_Value_0 == "walker" then
			v_u_166(_G["walkercylinder" .. l_Parent_0.slot.Value])
		end;
		l_core_checkers_0.check_ammo = tick()
		local v312 = l_Value_0 == "springfield" and v_u_12.alt_mode == true and "check_alt" or (l_Value_0 == "pieper" and v_u_12.slide_locked == true and "check_primed" or (v_u_11.check_empty and v_u_19.ammo_mag <= 0 and "check_empty" or "check"))
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "reloadstart",
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_11[v312]:Play(0.1, 1, 1 / v306)
		v_u_1:s_wait(v306)
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "reloadend",
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_2.Value = false
	end;
end;
local function v_u_316() --[[ Line: 4009 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_2, (copy 3): l_core_checkers_0, (ref 4): v_u_7, (ref 5): l_Value_0, (ref 6): v_u_19, (copy 7): v_u_11, (copy 8): l_Parent_0, (copy 9): v_u_8, (ref 10): v_u_10, (copy 11): l_Character_0, (copy 12): v_u_1 ]]
	v_u_12.state = "cycling"
	v_u_2.Value = true
	l_core_checkers_0.sprint_block = true
	local l_cycle_0 = v_u_7.cycle
	local v314
	if l_Value_0 == "lebel" and (v_u_12.alt_mode == false and v_u_19.alt_extra == true) then
		l_cycle_0 = 1.75
		v314 = "alt_toggled_off"
	else
		v314 = "cycle"
	end;
	local v315 = v_u_11.cycle_left and l_core_checkers_0.flip_cam == true and "cycle_left" or v314
	if l_Parent_0:FindFirstChild("bipod") and (v_u_11.bipod_cycle and tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer) then
		v315 = "bipod_cycle"
		if l_Value_0 == "enfield" and v_u_10 == "enfieldvariant" then
			l_cycle_0 = l_cycle_0 * 0.8
		end;
	end;
	if l_Character_0:FindFirstChild("vanguardbuff") then
		l_cycle_0 = l_cycle_0 * 0.9
	end;
	if l_Character_0:FindFirstChild("buff_elite") then
		l_cycle_0 = l_cycle_0 * 0.8
	end;
	if l_Character_0 and (l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "quickdraw") then
		l_cycle_0 = l_cycle_0 * 0.955
	end;
	if workspace.serverStuff.restorationmode.Value == true then
		l_cycle_0 = l_cycle_0 * 1.2
	end;
	if l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" or workspace.serverStuff.trainingmode.Value == true then
		l_cycle_0 = l_cycle_0 * 1.2
	end;
	if l_Value_0 == "pugsley" and (l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "rook") then
		l_cycle_0 = l_cycle_0 * 0.85
	end;
	v_u_19.alt_extra = false
	v_u_11[v315]:Stop(0)
	v_u_11[v315]:Play(0.1, 1, 1 / l_cycle_0)
	v_u_1:s_wait(l_cycle_0 + v_u_7.cycle_rest)
	l_core_checkers_0.sprint_block = false
	v_u_2.Value = false
	v_u_12.state = "normal"
end;
local v_u_317 = nil
local function v_u_318() --[[ Line: 4066 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): l_Parent_0, (copy 6): v_u_2, (copy 7): v_u_11, (copy 8): v_u_1, (copy 9): v_u_3, (copy 10): l_remotes_0, (copy 11): l_CurrentCamera_0 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	elseif l_Parent_0:FindFirstChild("flares") == nil then
		return;
	elseif l_Parent_0.flares.Value <= 0 then
		_G.popupmsg("flaregunnone", "I don\'t have any more illuminating flares.", 1)
		return;
	elseif v_u_2.Value ~= true then
		v_u_2.Value = true
		local l_flares_0 = l_Parent_0.flares
		l_flares_0.Value = l_flares_0.Value - 1
		local l_flip_cam_0 = l_core_checkers_0.flip_cam
		v_u_11[l_flip_cam_0 == false and "flaregun_right" or "flaregun"]:Play(0.1, 1, 1)
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "flare_equip",
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_1:s_wait(0.1)
		v_u_3("officer_flaregun", {
			["char"] = l_Character_0,
			["arm_use"] = l_flip_cam_0
		})
		v_u_1:s_wait(0.4)
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flaregun", l_CurrentCamera_0.CFrame.LookVector, l_flip_cam_0)
		v_u_1:s_wait(0.5)
		v_u_2.Value = false
	end;
end;
local function v_u_319() --[[ Line: 4123 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): v_u_2, (copy 6): v_u_11, (copy 7): v_u_1, (copy 8): l_remotes_0, (copy 9): l_Parent_0 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif l_Character_0:FindFirstChild("lewisshield_cd") then
		_G.popupmsg("lewisshieldnone", "I don\'t have my Shield right now.", 1)
		return;
	elseif v_u_2.Value ~= true then
		v_u_2.Value = true
		v_u_11.shieldplace:Play(0.1, 1, 1.2)
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "shield_ready",
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_1:s_wait(0.2)
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "lewisshield")
		v_u_1:s_wait(0.6)
		v_u_2.Value = false
	end;
end;
local function v_u_320() --[[ Line: 4156 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): v_u_2, (copy 6): v_u_11, (copy 7): v_u_1, (copy 8): l_remotes_0, (copy 9): l_Parent_0 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif l_Character_0:FindFirstChild("telescope_cd") then
		_G.popupmsg("telescopenone", "I don\'t have my Telescope anymore.", 1)
		return;
	elseif v_u_2.Value ~= true then
		v_u_2.Value = true
		v_u_11.telescope:Play(0.1, 1, 1.2)
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "telescope_ready",
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_1:s_wait(0.1)
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "telescope")
		v_u_1:s_wait(0.7)
		v_u_2.Value = false
	end;
end;
local function v_u_323() --[[ Line: 4190 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Parent_0, (copy 5): v_u_2, (copy 6): v_u_11, (copy 7): v_u_1, (copy 8): l_Character_0, (copy 9): l_keysheld_0, (copy 10): l_RenderStepped_0, (copy 11): l_remotes_0, (copy 12): v_u_9 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if l_Parent_0:FindFirstChild("client_inactive") or l_Parent_0:FindFirstChild("inactive") then
		return;
	end;
	v_u_2.Value = true
	local v321 = tick()
	v_u_11.flag:Play(0.1, 1, 1)
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "unready" .. math.random(1, 4),
		["location"] = l_Character_0.HumanoidRootPart
	})
	l_keysheld_0.m1 = true
	local v322 = true
	while true do
		if l_keysheld_0.m1 ~= true and tick() - v321 <= 1.3 then
			v322 = false
			break;
		end;
		l_RenderStepped_0:Wait()
		if tick() - v321 >= 1.5 then
			break;
		end;
	end;
	if v322 == true then
		local l_StringValue_1 = Instance.new("StringValue")
		game:GetService("Debris"):AddItem(l_StringValue_1, 2)
		l_StringValue_1.Name = "client_inactive"
		l_StringValue_1.Parent = l_Parent_0
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flagplace")
		v_u_11.throw_over:Play(0.1, 1, 1)
		v_u_2.Value = false
		v_u_9:UnequipTools()
	else
		v_u_11.flag:Stop(0.05)
		v_u_2.Value = false
	end;
end;
local function v_u_329() --[[ Line: 4242 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): v_u_2, (copy 5): l_Character_0, (copy 6): l_keysheld_0, (copy 7): l_LocalPlayer_0, (ref 8): l_Value_0, (copy 9): v_u_1, (copy 10): l_Value_1, (copy 11): v_u_3, (copy 12): v_u_11, (copy 13): l_RenderStepped_0, (copy 14): l_CurrentCamera_0, (copy 15): v_u_26, (copy 16): l_remotes_0, (copy 17): l_Parent_0, (copy 18): v_u_9 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if l_core_checkers_0.aiming == false then
		return;
	end;
	v_u_2.Value = true
	local v324 = tick()
	local v325 = 1
	if l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "rook" or l_Character_0.class.Value == "engineer") then
		v325 = v325 / 1.5
	end;
	local v326 = v325 / 2
	l_keysheld_0.m1 = true
	local v327 = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_welding")
	if l_Value_0 == "weldingtool" then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "active",
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		if l_Value_1 and v327 then
			v_u_3("weldingfx", {
				["weldfx"] = v327,
				["state"] = "start"
			})
			v325 = 3
		else
			v325 = 3
		end;
	end;
	v_u_11.repair:Play(0.2, 1, 1 / v325)
	while l_RenderStepped_0:Wait() do
		if v326 <= tick() - v324 then
			v324 = tick() + v326
			local v328 = v_u_1:raycastline({
				["point"] = l_Character_0.Head.Position,
				["destination"] = l_CurrentCamera_0.CFrame.LookVector,
				["range"] = 3,
				["layermask"] = v_u_26
			})
			if not v328 or (not v328.Parent or (not v328.Parent.Parent or (not v328.Parent.Parent.Parent or v328.Parent.Parent.Name ~= "trains" and v328.Parent.Parent.Parent.Name ~= "trains"))) then
				break;
			end;
			if not l_core_checkers_0.internal_sound or l_core_checkers_0.internal_sound.Volume > 0.3 then
				_G.popupmsg("repairinside", "I need to repair the damage from the outside.", 1)
				break;
			end;
			if workspace.serverStuff.values.gamemode_specific.train_track_on.trainhealth.Value >= workspace.serverStuff.values.gamemode_specific.train_track_on.trainhealthmax.Value then
				break;
			end;
			local l_Parent_1 = v328.Parent
			if v328.Parent.Parent.Parent.Name == "trains" then
				l_Parent_1 = v328.Parent.Parent
			end;
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "repair" .. math.random(1, 4),
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			l_remotes_0.interaction_handler:FireServer(l_Parent_0, "repair_wrench", l_Parent_1)
			if l_Value_0 == "weldingtool" and (l_Value_1 and (v327 and (v327:FindFirstChild("welding") and v327.welding.flash.Enabled == false))) then
				v_u_3("weldingfx", {
					["weldfx"] = v327,
					["state"] = "weldfx"
				})
			end;
		end;
		if v_u_9 == nil or (v_u_9.Health <= 0 or l_keysheld_0.m1 ~= true) then
			break;
		end;
	end;
	v_u_11.repair:Stop(0.2)
	if l_Value_0 == "weldingtool" then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "deactive",
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		if l_Value_1 and v327 then
			v_u_3("weldingfx", {
				["weldfx"] = v327,
				["state"] = "end"
			})
		end;
	end;
	v_u_1:s_wait(0.15)
	v_u_2.Value = false
end;
local function v_u_338() --[[ Line: 4370 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Parent_0, (ref 5): l_Value_0, (copy 6): l_Character_0, (copy 7): v_u_2, (copy 8): v_u_11, (copy 9): v_u_1, (copy 10): l_keysheld_0, (copy 11): l_RenderStepped_0, (copy 12): l_remotes_0, (copy 13): v_u_9, (copy 14): v_u_4, (ref 15): v_u_10, (copy 16): l_Value_1, (ref 17): v_u_19 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if l_Parent_0:FindFirstChild("client_inactive") then
		return;
	end;
	if l_Value_0 == "nebel" and (l_Character_0:FindFirstChild("equipment") and l_Character_0.equipment.Value <= 0) then
		return;
	end;
	local v330 = l_Character_0:FindFirstChild("equipment")
	v_u_2.Value = true
	local l_fire_rate_0 = v_u_7.fire_rate
	local v331 = tick()
	v_u_11.prime:Play(0.2, 1, 1 / l_fire_rate_0)
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "unready" .. math.random(1, 4),
		["location"] = l_Character_0.HumanoidRootPart
	})
	l_keysheld_0.m1 = true
	local v332 = true
	while true do
		if l_keysheld_0.m1 ~= true and tick() - v331 <= 0.2 then
			v332 = false
			break;
		end;
		l_RenderStepped_0:Wait()
		if l_fire_rate_0 <= tick() - v331 then
			break;
		end;
	end;
	if v332 == true then
		if l_Value_0 == "nebel" then
			v330.Value = v330.Value - 1
			l_core_checkers_0.equipment_show_cd = tick()
		end;
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "throw",
			["location"] = l_Character_0.HumanoidRootPart
		})
		local l_StringValue_2 = Instance.new("StringValue")
		game:GetService("Debris"):AddItem(l_StringValue_2, 2)
		l_StringValue_2.Name = "client_inactive"
		l_StringValue_2.Parent = l_Parent_0
		local v333
		if l_core_checkers_0.aiming == true then
			v333 = "throw_under"
		else
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "throw_far" .. math.random(1, 2),
				["location"] = l_Character_0.HumanoidRootPart
			})
			v333 = "throw_over"
		end;
		if l_Value_0 == "nebel" then
			l_remotes_0.equipment_handler:FireServer({
				["tool"] = l_Parent_0,
				["hand_thrown"] = v333,
				["lookvector"] = l_Character_0.Head.CFrame.lookVector
			})
		else
			l_remotes_0.interaction_handler:FireServer(l_Parent_0, "throw_grenade", l_Character_0.Head.CFrame.lookVector, v333)
		end;
		v_u_11[v333]:Play(0.1, 1, 2)
		v_u_2.Value = false
		v_u_9:UnequipTools()
		if l_Value_0 == "nebel" and v330.Value > 0 then
			local v334 = v_u_4
			local v335 = "grenade_pin_return"
			local v336 = {}
			local v337 = l_Value_0
			if v_u_10 ~= "" then
				v337 = v_u_10
			end;
			v336.main = {
				["char"] = l_Character_0,
				["originweapon"] = v337,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v334(v335, v336)
			return;
		end;
	else
		v_u_11.prime:Stop(0.05)
		v_u_2.Value = false
	end;
end;
local function v_u_355(p339, p340, p341) --[[ Line: 4473 ]]
	--[[ Upvalues: (ref 1): v_u_28, (copy 2): l_Character_0, (copy 3): l_CurrentCamera_0, (ref 4): l_Value_0, (copy 5): l_Value_1, (ref 6): v_u_19, (copy 7): v_u_1, (copy 8): v_u_3, (copy 9): v_u_23, (copy 10): l_remotes_0, (copy 11): l_Parent_0 ]]
	if v_u_28 == nil then
		return;
	end;
	local v342 = v_u_28
	local v343 = l_Character_0.Head.Position - l_CurrentCamera_0.CFrame.LookVector * 0.4
	if l_Value_0 == "enfield" or (l_Value_0 == "rooklauncher" or l_Value_0 == "crossbow") then
		v343 = l_Value_1.special.muzzle.Position - l_Value_1.special.muzzle.CFrame.lookVector
	end;
	local l_LookVector_0 = CFrame.new(v343, v342).LookVector
	local v344 = nil
	local v345 = nil
	local v346 = nil
	local v347 = nil
	local v348 = nil
	local v349, v350
	if l_Value_0 == "stimbottle" then
		v349 = v_u_19.stim_colour
		v350 = v_u_1:deepCopy(v_u_19.stim_content)
		v_u_19.stim_content = {}
		v_u_19.stim_colour = Color3.fromRGB(199, 199, 199)
	else
		v350 = nil
		v349 = nil
	end;
	if l_Value_0 == "remington" then
		v348 = l_Value_1
	end;
	v_u_3("projectile_fire", {
		["wep"] = l_Value_0,
		["org"] = v343,
		["orgface"] = l_LookVector_0,
		["speed"] = p339,
		["drop"] = p340,
		["amtdrop"] = p341,
		["lm"] = v_u_23,
		["extra"] = v348
	})
	local v351 = 0
	for v352 = 1, 100 do
		v344, v345, v346, v347 = v_u_1:raycastline({
			["point"] = v343,
			["destination"] = l_LookVector_0,
			["range"] = p339,
			["layermask"] = v_u_23
		})
		if _G.debugline == true then
			v_u_1:debugline(v343, v345)
		end;
		if v344 ~= nil then
			break;
		end;
		if p340 <= v352 then
			l_LookVector_0 = l_LookVector_0 - Vector3.new(0, p341, 0)
		end;
		v351 = v351 + p339
		v_u_1:s_wait(0.03)
		v343 = v345
	end;
	if v344 then
		if v344 and (v344.Material == Enum.Material.Glass and (v344.Name == "WindowBreakable" or v344.Name == "GlassWindow")) then
			local v353 = l_Value_0 == "rooklauncher" and 5 or 3
			v_u_3("wood_impact", {
				["point"] = v345,
				["part_hit"] = v344,
				["partcol"] = v344.Color,
				["pellets"] = 1,
				["glass"] = true
			})
			if v344.Name == "WindowBreakable" then
				v_u_3("bullet_hole", {
					["pos"] = v345,
					["normal"] = v346,
					["glass"] = true,
					["forceparent"] = v344
				}, true)
				l_remotes_0.game_handler:FireServer("window_impact", v344, v353)
			end;
		end;
		if l_Value_0 == "rooklauncher" then
			local v354 = v344 and (v347 == Enum.Material.Rock or v347 == Enum.Material.Mud) and true or false
			if v345.Y <= 34 then
				v354 = false
			end;
			if v354 == true then
				v_u_3("mine_impact", {
					["point"] = v345
				})
			end;
			l_remotes_0.interaction_handler:FireServer(l_Parent_0, "rooknade", v345, v354, v344, CFrame.new(v345, v343))
			if v344.Name == "breakpiecetopmanufacturing" then
				l_remotes_0.game_handler:FireServer("hit_destructible", v344)
				return;
			end;
		else
			if l_Value_0 == "enfield" then
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "enfieldgrenade", v345, v344, v351)
				return;
			end;
			if l_Value_0 == "throwaxe" then
				l_remotes_0.equipment_handler:FireServer({
					["tool"] = l_Parent_0,
					["hit"] = v344,
					["point"] = v345,
					["origin"] = v343
				})
				if v344 and (v344.Parent and (v344.Parent:FindFirstChild("Humanoid") and (v344.Parent.Humanoid.Health > 0 and (v344.Parent.Parent ~= l_Character_0.Parent and v344.Parent:FindFirstChild("dreadnought") == nil)))) then
					v_u_3("bloodhitmarker_fx", {
						["position"] = CFrame.new(v344.Position)
					}, true)
					return;
				end;
			elseif l_Value_0 == "crossbow" then
				l_remotes_0.game_handler:FireServer("crossbow_hit", {
					["tool"] = l_Parent_0,
					["hit"] = v344,
					["hitframe"] = v344.CFrame,
					["point"] = v345,
					["origin"] = v343
				})
				if v344 and (v344.Parent and (v344.Parent:FindFirstChild("Humanoid") and (v344.Parent.Humanoid.Health > 0 and (v344.Parent.Parent ~= l_Character_0.Parent and v344.Parent:FindFirstChild("dreadnought") == nil)))) then
					v_u_3("bloodhitmarker_fx", {
						["position"] = CFrame.new(v344.Position)
					}, true)
					return;
				end;
			elseif l_Value_0 == "remington" then
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "thrown_remington_hit", v344, v345, v343, v348)
				if v344 and (v344.Parent and (v344.Parent:FindFirstChild("Humanoid") and (v344.Parent.Humanoid.Health > 0 and (v344.Parent.Parent ~= l_Character_0.Parent and v344.Parent:FindFirstChild("dreadnought") == nil)))) then
					v_u_3("bloodhitmarker_fx", {
						["position"] = CFrame.new(v344.Position)
					}, true)
					return;
				end;
			elseif l_Value_0 == "stimbottle" then
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "stimbottle", v345, {
					["stims"] = v350,
					["color"] = v349
				})
			end;
		end;
	end;
end;
local function v_u_356() --[[ Line: 4670 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): l_Value_1, (copy 6): v_u_1, (ref 7): v_u_19, (copy 8): v_u_2, (copy 9): v_u_3, (ref 10): l_Value_0, (copy 11): v_u_355, (copy 12): v_u_11 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	elseif l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
		return;
	elseif l_Value_1 == nil or (l_Value_1:FindFirstChild("special") == nil or l_Value_1.special:FindFirstChild("muzzle") == nil) then
		return;
	else
		l_Character_0:FindFirstChild("equipment")
		l_core_checkers_0.equipment_show_cd = tick()
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "click" .. math.random(1, 2),
			["location"] = l_Character_0.HumanoidRootPart
		})
		if v_u_19.ammo_mag > 0 then
			v_u_2.Value = true
			l_core_checkers_0.sprint_block = true
			if _G.firing_movement_handler then
				_G.firing_movement_handler(v_u_7.firing_movement, v_u_7.firing_movement_last)
			end;
			v_u_19.ammo_mag = v_u_19.ammo_mag - 1
			l_core_checkers_0.equipment_show_cd = tick()
			l_core_checkers_0.equipment_ticker = tick()
			local l_equipment_0 = l_Character_0.equipment
			l_equipment_0.Value = l_equipment_0.Value - 1
			v_u_3("muzzle_flash", {
				["point"] = l_Value_1.special.muzzle.CFrame,
				["weapon_name"] = "rooklauncher",
				["noflash"] = true
			})
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "fire",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_1:fast_spawn(function() --[[ Line: 4725 ]]
				--[[ Upvalues: (ref 1): v_u_355 ]]
				v_u_355(6, 5, 0.02)
			end)
			l_core_checkers_0.jump_tick = tick()
			v_u_11.fire:Stop(0)
			v_u_11.fire_left:Stop(0)
			if l_core_checkers_0.flip_cam == true then
				v_u_11.fire_left:Play(0.01, 1, 1)
			else
				v_u_11.fire:Play(0.01, 1, 1)
			end;
			v_u_1:s_wait(v_u_7.fire_rate)
			l_core_checkers_0.sprint_block = false
			v_u_2.Value = false
		end;
	end;
end;
local v_u_357 = nil
local function v_u_359(p358) --[[ Line: 4751 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_11, (copy 3): v_u_1, (copy 4): l_Character_0, (copy 5): l_Parent_0, (copy 6): v_u_2 ]]
	if v_u_12.anim_swaps == nil then
		v_u_11.shieldraised_idle.Priority = Enum.AnimationPriority.Action
		v_u_11.shieldraised_aimed.Priority = Enum.AnimationPriority.Action2
		v_u_12.anim_swaps = {
			v_u_11.shieldraised_shoot,
			v_u_11.shieldraised_empty,
			v_u_11.shieldraised_idle,
			v_u_11.shieldraised_aimed,
			v_u_11.shoot,
			v_u_11.shoot_empty,
			v_u_11.held,
			v_u_11.aim
		}
	end;
	v_u_11.aim:Stop(0.3)
	v_u_11.held:Stop(0.3)
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "ready" .. math.random(1, 4),
		["location"] = l_Character_0.HumanoidRootPart
	})
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "large" .. math.random(1, 3),
		["location"] = l_Character_0.HumanoidRootPart
	})
	if v_u_12.alt_mode == true then
		l_Parent_0.guarding.Value = false
		v_u_11.held = v_u_12.anim_swaps[7]
	else
		l_Parent_0.guarding.Value = true
		v_u_11.held = v_u_12.anim_swaps[3]
	end;
	if v_u_12.equipped == true then
		v_u_11.held:Play(0.3, 1, 0.25)
	end;
	v_u_12.alt_mode = not v_u_12.alt_mode
	if p358 == true then
		v_u_2.Value = true
		v_u_1:s_wait(0.25)
		v_u_2.Value = false
	end;
end;
local function v_u_360() --[[ Line: 4814 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): v_u_2, (copy 5): l_Parent_0, (copy 6): v_u_9, (copy 7): l_Character_0, (copy 8): v_u_1, (copy 9): v_u_11, (copy 10): v_u_355, (copy 11): l_remotes_0 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif v_u_2.Value == true then
		return;
	elseif l_Parent_0:FindFirstChild("client_inactive") then
		return;
	elseif v_u_9:FindFirstChild("burning_light") or v_u_9:FindFirstChild("burning_heavy") then
		return;
	elseif workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	elseif l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
	else
		v_u_2.Value = true
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "large" .. math.random(2, 3),
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_11.fire:Play(0.1, 1, 8)
		local l_StringValue_3 = Instance.new("StringValue")
		l_StringValue_3.Name = "client_inactive"
		l_StringValue_3.Parent = l_Parent_0
		v_u_1:s_wait(0.125)
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "throw_gun" .. math.random(1, 3),
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_1:fast_spawn(function() --[[ Line: 4862 ]]
			--[[ Upvalues: (ref 1): v_u_355 ]]
			v_u_355(8, 2, 0.02)
		end)
		v_u_11.throw_over:Play(0.1, 1, 1)
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "throw_remington")
		v_u_2.Value = false
		v_u_9:UnequipTools()
	end;
end;
local function v_u_367() --[[ Line: 4875 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): v_u_1, (ref 6): v_u_19, (copy 7): v_u_2, (copy 8): l_remotes_0, (copy 9): l_Parent_0, (copy 10): v_u_4, (ref 11): l_Value_0, (ref 12): v_u_10, (copy 13): l_Value_1, (copy 14): v_u_11, (copy 15): v_u_355 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	elseif l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
		return;
	else
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "trigger",
			["location"] = l_Character_0.HumanoidRootPart
		})
		if v_u_19.ammo_mag > 0 then
			v_u_2.Value = true
			l_remotes_0.game_handler:FireServer("crossbow_state_handler", l_Parent_0, false)
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "fire",
				["location"] = l_Character_0.HumanoidRootPart
			})
			local v361 = v_u_4
			local v362 = "crossbow_bolt_visibility"
			local v363 = {}
			local v364 = l_Value_0
			if v_u_10 ~= "" then
				v364 = v_u_10
			end;
			v363.main = {
				["char"] = l_Character_0,
				["originweapon"] = v364,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v363.transp = 1
			v361(v362, v363)
			v_u_19.ammo_mag = 0
			l_core_checkers_0.sprint_block = true
			l_core_checkers_0.jump_tick = tick()
			v_u_11.fire:Stop(0)
			v_u_11.fire_left:Stop(0)
			v_u_11.locked:Stop(0.03)
			v_u_12.slide_locked = false
			local v_u_365, v_u_366
			if l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "marksman" then
				v_u_365 = 6
				v_u_366 = 0.01
			else
				v_u_365 = 2
				v_u_366 = 0.02
			end;
			v_u_1:fast_spawn(function() --[[ Line: 4932 ]]
				--[[ Upvalues: (ref 1): v_u_355, (ref 2): v_u_365, (ref 3): v_u_366 ]]
				v_u_355(8, v_u_365, v_u_366)
			end)
			v_u_11.speen:Play(0.1, 1, 1)
			v_u_11[l_core_checkers_0.flip_cam == true and "fire_left" or "fire"]:Play(0.01, 1, 3)
			v_u_1:s_wait(v_u_7.fire_rate)
			l_core_checkers_0.sprint_block = false
			v_u_2.Value = false
		end;
	end;
end;
local function v_u_372() --[[ Line: 4953 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (copy 4): l_Character_0, (copy 5): l_Parent_0, (ref 6): v_u_19, (copy 7): v_u_2, (copy 8): v_u_4, (ref 9): l_Value_0, (ref 10): v_u_10, (copy 11): l_Value_1, (copy 12): v_u_3, (copy 13): v_u_1, (copy 14): v_u_355, (copy 15): v_u_11 ]]
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	elseif l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
		return;
	elseif l_Parent_0:FindFirstChild("gl_uses") == nil then
		return;
	elseif l_Parent_0.gl_uses.Value <= 0 then
		return;
	elseif v_u_19.ammo_mag > 0 and (v_u_19.blank_round_loaded ~= nil and v_u_19.blank_round_loaded ~= false) then
		v_u_2.Value = true
		local l_gl_uses_0 = l_Parent_0.gl_uses
		l_gl_uses_0.Value = l_gl_uses_0.Value - 1
		l_core_checkers_0.sprint_block = true
		v_u_19.ammo_mag = v_u_19.ammo_mag - 1
		v_u_19.blank_round_loaded = false
		local v368 = v_u_4
		local v369 = "riflegrenade_fired"
		local v370 = {}
		local v371 = l_Value_0
		if v_u_10 ~= "" then
			v371 = v_u_10
		end;
		v370.main = {
			["char"] = l_Character_0,
			["originweapon"] = v371,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v368(v369, v370)
		v_u_3("muzzle_flash", {
			["point"] = l_Value_1.special.muzzle.CFrame,
			["weapon_name"] = "rooklauncher",
			["noflash"] = true
		})
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "blank",
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_1:fast_spawn(function() --[[ Line: 5004 ]]
			--[[ Upvalues: (ref 1): v_u_355 ]]
			v_u_355(8, 5, 0.02)
		end)
		l_core_checkers_0.jump_tick = tick()
		v_u_11.fire:Stop(0)
		v_u_11.fire_left:Stop(0)
		v_u_11[l_core_checkers_0.flip_cam == true and "fire_left" or "fire"]:Play(0.01, 1, 1)
		v_u_1:s_wait(v_u_7.fire_rate)
		l_core_checkers_0.sprint_block = false
		v_u_2.Value = false
	end;
end;
local v_u_373 = tick()
local function v_u_504(p374) --[[ Line: 5030 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_7, (copy 3): l_core_checkers_0, (ref 4): v_u_28, (copy 5): l_Character_0, (ref 6): l_Value_0, (copy 7): l_Parent_0, (copy 8): v_u_1, (copy 9): v_u_372, (copy 10): v_u_367, (ref 11): v_u_19, (copy 12): v_u_316, (copy 13): l_Value_1, (copy 14): v_u_3, (copy 15): v_u_4, (ref 16): v_u_10, (copy 17): v_u_2, (copy 18): v_u_11, (copy 19): l_LocalPlayer_0, (ref 20): v_u_235, (copy 21): v_u_26, (copy 22): v_u_8, (copy 23): l_RenderStepped_0, (ref 24): v_u_159, (copy 25): v_u_24, (ref 26): v_u_373, (copy 27): l_CurrentCamera_0, (copy 28): l_remotes_0, (copy 29): v_u_6, (copy 30): v_u_180, (copy 31): l_keysheld_0, (ref 32): v_u_504, (ref 33): v_u_317, (ref 34): v_u_181, (copy 35): v_u_303 ]]
	if v_u_12.shorted == true then
		return;
	end;
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if v_u_12.equipped == false and p374 ~= true then
		return;
	end;
	if l_core_checkers_0.jumped_air == true then
		return;
	end;
	if v_u_28 == nil then
		return;
	end;
	if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 then
		return;
	end;
	if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	end;
	if workspace.serverStuff.medievalmode.Value == true and l_Value_0 ~= "crossbow" then
		_G.popupmsg("guninmedieval", "I can\'t fire weapons in Medieval Mode.", 1)
		return;
	end;
	if l_Character_0:FindFirstChild("oathbroken") then
		_G.popupmsg("brokenoath", "I can\'t do this.", 1)
		return;
	end;
	if l_Parent_0:FindFirstChild("client_inactive") or l_Parent_0:FindFirstChild("inactive") then
		return;
	end;
	if l_Value_0 ~= "crossbow" then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "click" .. math.random(1, 2),
			["location"] = l_Character_0.HumanoidRootPart
		})
	end;
	v_u_12.fire_buffer = 0
	if l_Value_0 == "enfield" and v_u_12.alt_mode == true then
		v_u_372()
		return;
	end;
	if l_Value_0 == "crossbow" then
		v_u_367()
		return;
	end;
	if v_u_19.force_block_fire == true then
		if l_Value_0 == "lebel" and (v_u_12.alt_mode == false and v_u_19.ammo_mag > 0) then
			v_u_316()
			v_u_19.force_block_fire = false
		end;
		return;
	end;
	local v375 = nil
	local v376 = {}
	if l_Value_0 == "walker" then
		if not (_G["walkerstate" .. l_Parent_0.slot.Value] and _G["walkercylinder" .. l_Parent_0.slot.Value]) then
			return;
		end;
		local v377 = _G["walkerstate" .. l_Parent_0.slot.Value][_G["walkercylinder" .. l_Parent_0.slot.Value]]
		if v377 then
			v376[1] = v377.cap
			v376[2] = v377.ball
			v376[3] = v377.powder
			local l_ball_0 = v377.ball
			if v377.cap == true and v377.powder ~= false then
				v_u_19.ammo_mag = 1
				v377.ball = false
			else
				v_u_19.ammo_mag = 0
			end;
			if v377.cap == true then
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "cap",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
				local v378 = l_Value_1.parts.cylinder:FindFirstChild("round" .. _G["walkercylinder" .. l_Parent_0.slot.Value])
				if v378 then
					if v377.powder == false then
						v378 = nil
					end;
					v_u_3("muzzle_flash", {
						["point"] = l_Value_1.parts.cylinder.CFrame + l_Value_1.parts.cylinder.CFrame.lookVector * 0.5,
						["after_smoke"] = v378,
						["weapon_size"] = 1,
						["weapon_name"] = "lebel",
						["noflash"] = true,
						["class_use"] = l_Character_0:FindFirstChild("class")
					})
				end;
				if v377.powder ~= false then
					v375 = v377.powder <= 0.2 and "veryweakload" or (v377.powder < 0.5 and "weakload" or v375)
					if l_ball_0 == false then
						v375 = v375 == nil and "noball" or v375 .. "noball"
					end;
					v377.powder = false
				end;
				v377.cap = "fired"
			end;
			local v379 = v_u_4
			local v380 = "walker_setstate"
			local v381 = {}
			local v382 = l_Value_0
			if v_u_10 ~= "" then
				v382 = v_u_10
			end;
			v381.main = {
				["char"] = l_Character_0,
				["originweapon"] = v382,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v381.walker_slot = _G["walkercylinder" .. l_Parent_0.slot.Value]
			v381.walker_state = v377
			v379(v380, v381)
			local v383 = _G
			local v384 = "walkercylinder" .. l_Parent_0.slot.Value
			v383[v384] = v383[v384] + 1
			if _G["walkercylinder" .. l_Parent_0.slot.Value] > 6 then
				_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
			end;
		end;
	end;
	local v385 = v_u_7.fire_rate * 0.9
	local v386 = true
	local v387
	if l_Value_0 == "lever" then
		v385 = 0.725
		if l_Character_0.perk.Value == "vet" then
			v387 = true
			v386 = false
		else
			v387 = false
		end;
	else
		v387 = true
	end;
	local v388 = false
	local v389 = l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true and true or false
	local v390 = l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) and "akimbo_locked" or "locked"
	if l_Value_0 == "pieper" and v_u_12.slide_locked == false then
		local v391 = _G.pieper_alt == true and 0.25 or 0.15
		v_u_2.Value = true
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "hammer",
			["location"] = l_Character_0.HumanoidRootPart
		})
		delay(v391 / 1.5, function() --[[ Line: 5249 ]]
			--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Value_0, (ref 3): l_Character_0 ]]
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "rotate_cylinder",
				["location"] = l_Character_0.HumanoidRootPart
			})
		end)
		local v392 = v_u_4
		local v393 = "cylinder_rotate"
		local v394 = {}
		local v395 = l_Value_0
		if v_u_10 ~= "" then
			v395 = v_u_10
		end;
		v394.main = {
			["char"] = l_Character_0,
			["originweapon"] = v395,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v394.speedval = v391
		v392(v393, v394)
		v_u_12.slide_locked = true
		v_u_11[v390]:Play(v391)
		if v389 == false then
			v_u_11.hammer_pull:Play(0.1, 0.1, 3)
		end;
		v_u_1:s_wait(v391)
		if _G.pieper_alt == true then
			v_u_2.Value = false
			return;
		end;
	end;
	if l_Value_0 == "trench" and (v_u_19.ammo_mag <= 0 and v_u_12.slide_locked == false) then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "empty",
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_12.slide_locked = true
		v_u_11[v390]:Play(0.05)
		return;
	end;
	if v_u_19.ammo_mag <= 0 then
		if v_u_11.fire_empty and v386 == true then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "empty",
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_2.Value = true
			local v396 = false
			if p374 == true then
				local v397 = l_Character_0:FindFirstChild("Bulwark\'s Shield") or l_Character_0:FindFirstChild("Cavalry Sword")
				local v398
				if l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "akimbo" then
					v398 = l_Character_0:FindFirstChildOfClass("Tool")
					if v398:FindFirstChild("akimbo") and v398.akimbo.Value == true then
						v396 = true
					else
						v398 = v397
					end;
				else
					v398 = v397
				end;
				if v398 and v398:FindFirstChild("event") then
					v398.event:Fire("dual_shoot_empty")
				end;
			elseif l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true then
				v_u_11.akimbo_right_empty:Play(0, 1, 1)
			end;
			v_u_11.fire:Stop(0)
			if v_u_11.fire_left then
				v_u_11.fire_left:Stop(0)
			end;
			if v_u_11.fire_empty_left then
				v_u_11.fire_empty_left:Stop(0)
			end;
			v_u_11.fire_empty:Stop(0)
			if v_u_11.akimbo_fire_empty then
				v_u_11.akimbo_fire_empty:Stop(0)
			end;
			if v_u_11.cycle then
				v_u_11.cycle:Stop(0)
			end;
			if v_u_11.cycle_left then
				v_u_11.cycle_left:Stop(0)
			end;
			if v_u_11.fire_empty_left ~= nil and (l_core_checkers_0.flip_cam == true and (p374 ~= true and v389 == false)) then
				v_u_11.fire_empty.Priority = Enum.AnimationPriority.Action2
				v388 = true
			end;
			v_u_11[v396 == true and "akimbo_fire_empty" or "fire_empty"]:Play(0.01, 1, 1 / v385)
			if v388 == true then
				v_u_11.fire_empty_left:Play(0.01, 1, 1 / v385)
				delay(v385 * 0.8, function() --[[ Line: 5359 ]]
					--[[ Upvalues: (ref 1): v_u_11 ]]
					v_u_11.fire_empty.Priority = Enum.AnimationPriority.Action3
					v_u_11.fire_empty:Stop(0)
				end)
			end;
			v_u_1:s_wait(v_u_7.fire_rate)
			v_u_2.Value = false
		end;
		return;
	end;
	if l_Value_0 == "dbgun" then
		v_u_12.db_othershell = false
	end;
	v_u_2.Value = true
	if l_Value_0 == "mpgun" or l_Value_0 == "lewis" then
		v385 = 0.5
		if p374 ~= "autoshot" then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "prefire" .. math.random(1, 2),
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_1:s_wait(0.08)
		end;
	end;
	l_core_checkers_0.force_jump_tick = tick()
	if not l_LocalPlayer_0.Character:FindFirstChild("cowboy") or (not l_LocalPlayer_0.Character:FindFirstChild("elitekit") or l_LocalPlayer_0.Character.elitekit.Value ~= "ocelot") then
		l_core_checkers_0.sprint_block = true
	end;
	local v399 = l_Value_0 == "lewis"
	if _G.firing_movement_handler then
		_G.firing_movement_handler(v_u_7.firing_movement, v_u_7.firing_movement_last, v399)
	end;
	v_u_19.ammo_mag = v_u_19.ammo_mag - 1
	local l_muzzle_0 = l_Value_1.special.muzzle
	if l_Parent_0:FindFirstChild("mounted_weapon") and (l_Parent_0.mounted_weapon.Value and (l_Parent_0.mounted_weapon.Value:FindFirstChild("rig") and (l_Parent_0.mounted_weapon.Value.rig:FindFirstChild("mg") and l_Parent_0.mounted_weapon.Value.rig.mg:FindFirstChild("muzzle")))) then
		l_muzzle_0 = l_Parent_0.mounted_weapon.Value.rig.mg.muzzle
		if l_Parent_0.mounted_weapon.Value.rig.mg:FindFirstChild("ejection") then
			local v400 = v_u_4
			local v401 = "eject_casing"
			local v402 = {}
			local v403 = l_Value_0
			if v_u_10 ~= "" then
				v403 = v_u_10
			end;
			v402.main = {
				["char"] = l_Character_0,
				["originweapon"] = v403,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v402.force_ejection_area = l_Parent_0.mounted_weapon.Value.rig.mg.ejection.CFrame
			v400(v401, v402)
		end;
	end;
	local v404 = "fire"
	v_u_3("muzzle_flash", {
		["point"] = l_muzzle_0.CFrame,
		["after_smoke"] = l_muzzle_0,
		["weapon_size"] = v_u_10 == "steyrvariant" and 1 or v_u_7.size,
		["weapon_name"] = l_Value_0,
		["class_use"] = l_Character_0:FindFirstChild("class")
	})
	if l_Value_1:FindFirstChild("cylinder") and l_Value_0 ~= "walker" then
		local v405 = v_u_4
		local v406 = "cylinder_fire"
		local v407 = {}
		local v408 = l_Value_0
		if v_u_10 ~= "" then
			v408 = v_u_10
		end;
		v407.main = {
			["char"] = l_Character_0,
			["originweapon"] = v408,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v405(v406, v407)
	end;
	local v409 = "fire"
	if l_Value_0 == "walker" and v376[3] ~= false then
		if v376[3] < 0.5 then
			v409 = "fire_weak"
			v404 = "fire_weak"
		end;
		if v376[3] >= 1 then
			v404 = "fire_break"
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "walker_break",
				["location"] = l_Character_0.HumanoidRootPart
			})
			local v410 = v_u_4
			local v411 = "walker_cylinderbreak"
			local v412 = {}
			local v413 = l_Value_0
			if v_u_10 ~= "" then
				v413 = v_u_10
			end;
			v412.main = {
				["char"] = l_Character_0,
				["originweapon"] = v413,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v410(v411, v412)
		end;
	end;
	local v414 = (v_u_10 == "piepervariant" or (v_u_10 == "springfieldvariant" or (v_u_10 == "autosgvariant" or (v_u_10 == "dbgunvariant" or (v_u_10 == "henryvariant" or (v_u_10 == "levervariant" or (v_u_10 == "remingtonvariant" or v_u_10 == "saavariant"))))))) and "variantfire" or (l_Value_0 == "scho" and (l_Value_1:FindFirstChild("parts") and (l_Value_1.parts:FindFirstChild("break") and (l_Value_1.parts["break"]:FindFirstChild("snubbarrel") and l_Value_1.parts["break"].snubbarrel.Transparency == 0))) and "firesnub" or v409)
	if l_Value_0 == "springfield" and v_u_12.alt_mode == true then
		v414 = "pedersen_fire"
		if v_u_12.jam_count then
			local v415 = v_u_12
			v415.jam_count = v415.jam_count - 1
		end;
		if v_u_12.jam_count <= 0 then
			v_u_12.jam_count = math.random(7, 18)
			v_u_12.jammed = true
			local v416 = v_u_4
			local v417 = "springfield_pedersen_jammed"
			local v418 = {}
			local v419 = l_Value_0
			if v_u_10 ~= "" then
				v419 = v_u_10
			end;
			v418.main = {
				["char"] = l_Character_0,
				["originweapon"] = v419,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v416(v417, v418)
		else
			local v420 = v_u_4
			local v421 = "eject_casing"
			local v422 = {}
			local v423 = l_Value_0
			if v_u_10 ~= "" then
				v423 = v_u_10
			end;
			v422.main = {
				["char"] = l_Character_0,
				["originweapon"] = v423,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v420(v421, v422)
		end;
	end;
	if l_Value_0 == "lewis" then
		local v424 = v_u_4
		local v425 = "lewis_rotate"
		local v426 = {}
		local v427 = l_Value_0
		if v_u_10 ~= "" then
			v427 = v_u_10
		end;
		v426.main = {
			["char"] = l_Character_0,
			["originweapon"] = v427,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v424(v425, v426)
	end;
	local v428, v429
	if p374 == "autoshot" then
		v428 = -0.5
		v429 = 0.05
	else
		v428 = nil
		v429 = 0.1
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = v414,
		["pitchvariation"] = v429,
		["client_volume"] = 0.3,
		["gun_volume"] = true,
		["volume_adjust"] = v428,
		["location"] = l_Character_0.HumanoidRootPart
	})
	local v430 = l_Value_0 == "walker" and v376[3] ~= false and (v376[3] <= 0.2 and "small" or (v376[3] >= 0.5 and "large" or "medium")) or (v_u_7.special.suppressed == true and "suppressor" or (v_u_10 == "henryvariant" and "medium" or ((v_u_10 == "steyrvariant" or v_u_10 == "saavariant") and "small" or ((l_Value_0 == "henry" or l_Value_0 == "pugsley") and "large" or (v_u_7.pellets > 1 and "shotgun" or ((v_u_7.size == 1 or l_Value_0 == "lever") and "small" or "medium"))))))
	v_u_235 = true
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "loud_" .. math.random(1, 3),
		["pitchvariation"] = 0.3,
		["gun_volume"] = true,
		["volume_adjust"] = v428,
		["location"] = l_Character_0.HumanoidRootPart
	})
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "distant_" .. math.random(1, 3),
		["gun_volume"] = true,
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	if l_Value_0 == "pugsley" then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "echo" .. math.random(1, 3),
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		if _G.ear_ring then
			_G.ear_ring(1000)
		end;
		if l_Character_0.class.Value ~= "rook" and _G.knockback_effect then
			_G.knockback_effect(10, (l_Character_0.HumanoidRootPart.CFrame - l_Character_0.HumanoidRootPart.CFrame.lookVector * 5).Position)
		end;
	end;
	local v431 = -1
	local v432 = -1
	local v433 = v_u_11.fire_last and (v_u_19.ammo_mag <= 0 and v387 == true) and "fire_last" or v404
	local v434 = false
	local v435 = l_Value_0 == "saa" and v_u_12.alt_mode == true and true or (l_core_checkers_0.aiming == false and v_u_11.hipfire and true or false)
	if v435 == true then
		v433 = "hipfire"
		v385 = 1
		local l_Right Arm_0 = l_Character_0["Right Arm"]
		if v_u_7.lefthand == true then
			l_Right Arm_0 = l_Character_0["Left Arm"]
		end;
		local v436, _ = v_u_1:raycastline({
			["point"] = l_Right Arm_0.Position - l_Character_0.HumanoidRootPart.CFrame.lookVector * 1,
			["destination"] = l_Character_0.Head.CFrame.lookVector,
			["range"] = v_u_7.length,
			["layermask"] = v_u_26
		})
		if v436 then
			v434 = true
		end;
	end;
	local l_pellets_0 = v_u_7.pellets
	local v437 = l_Value_0 == "springfield" and v_u_12.alt_mode == true and "pedersen" or v375
	local v438 = l_Value_0 == "springfield" and v_u_12.alt_mode == true and 0.5 or (v_u_11.cycle and l_Value_0 ~= "enfield" and 1 or v385)
	if l_Value_0 == "mares" and (v_u_12.alt_mode == true and (p374 ~= true and (l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value ~= "akimbo"))) then
		v_u_12.slide_locked = true
		local l_locked_2 = v_u_11.locked
		if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) then
			l_locked_2 = v_u_11.akimbo_locked
		end;
		if l_locked_2 then
			l_locked_2:Play(0.1)
		end;
		if v_u_19.ammo_mag > 0 then
			delay(0.25, function() --[[ Line: 5688 ]]
				--[[ Upvalues: (ref 1): v_u_11 ]]
				v_u_11.spin_right:Play(0.1, 1, 2)
			end)
		end;
	end;
	if p374 == true then
		local v439 = l_Character_0:FindFirstChild("Bulwark\'s Shield") or l_Character_0:FindFirstChild("Cavalry Sword")
		local v440 = false
		local v441
		if l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "akimbo" then
			v441 = l_Character_0:FindFirstChildOfClass("Tool")
			if v441:FindFirstChild("akimbo") and v441.akimbo.Value == true then
				v440 = true
			else
				v441 = v439
			end;
		else
			v441 = v439
		end;
		if v441 and v441:FindFirstChild("event") then
			v433 = v440 == true and "akimbo_fire" or v433
			v441.event:Fire("dual_shoot", v_u_19.ammo_mag, 0.6 / v438)
		end;
		if l_Value_0 == "mares" then
			v433 = ""
			v_u_12.slide_locked = true
			local l_locked_3 = v_u_11.locked
			if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) then
				l_locked_3 = v_u_11.akimbo_locked
			end;
			if l_locked_3 then
				l_locked_3:Play(0.1)
			end;
			if v_u_19.ammo_mag > 0 then
				local v_u_442 = v441 and v441.Name == "Bulwark\'s Shield" and "spin_right" or "spin_left"
				delay(0.25, function() --[[ Line: 5721 ]]
					--[[ Upvalues: (ref 1): v_u_11, (ref 2): v_u_442 ]]
					v_u_11[v_u_442]:Play(0.1, 1, 2)
				end)
			end;
		end;
	elseif l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true then
		v_u_11.akimbo_right:Play(0.01, 1, 0.6 / v438)
		if l_Value_0 == "mares" then
			v433 = ""
			v_u_12.slide_locked = true
			local l_locked_4 = v_u_11.locked
			if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true) then
				l_locked_4 = v_u_11.akimbo_locked
			end;
			if l_locked_4 then
				l_locked_4:Play(0.1)
			end;
			if v_u_19.ammo_mag > 0 then
				delay(0.25, function() --[[ Line: 5734 ]]
					--[[ Upvalues: (ref 1): v_u_11 ]]
					v_u_11.spin_right:Play(0.1, 1, 2)
				end)
			end;
		end;
	end;
	if v_u_11[v433 .. "_left"] ~= nil and (l_core_checkers_0.flip_cam == true and (p374 ~= true and v389 == false)) then
		v_u_11[v433 .. "_left"]:Stop(0)
		v_u_11[v433].Priority = Enum.AnimationPriority.Action2
		v388 = true
	end;
	local v_u_443 = l_Parent_0:FindFirstChild("bipod") and (v_u_11.bipod_fire and tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer) and "bipod_fire" or v433
	if v_u_11[v_u_443] then
		v_u_11[v_u_443]:Stop(0)
		v_u_11[v_u_443]:Play(0.01, 1, 1 / v438)
	end;
	if v388 == true and v_u_11[v_u_443 .. "_left"] then
		v_u_11[v_u_443 .. "_left"]:Play(0.01, 1, 1 / v438)
		delay(v438 * 0.8, function() --[[ Line: 5761 ]]
			--[[ Upvalues: (ref 1): v_u_11, (ref 2): v_u_443 ]]
			v_u_11[v_u_443].Priority = Enum.AnimationPriority.Action3
			v_u_11[v_u_443]:Stop(0)
		end)
		if v_u_11.cycle then
			l_RenderStepped_0:Wait()
		end;
	end;
	local v444 = true
	for v445 = 1, l_pellets_0 do
		if l_Character_0:FindFirstChild("execing") or v_u_28 == nil then
			break;
		end;
		if v445 > 1 then
			v444 = false
		end;
		local v446 = v_u_7.accuracy / 10
		if tick() - l_core_checkers_0.moving_accuracy >= 0 or l_core_checkers_0.in_air == true then
			v446 = v_u_7.moving_accuracy / 10
		end;
		if l_Value_0 == "walker" then
			if v376[3] <= 0.2 then
				v446 = v_u_7.moving_accuracy / 20
			end;
			if v376[2] == "half" then
				v446 = v_u_7.moving_accuracy / 10
			else
				v446 = v376[2] == false and 0 or v446
			end;
		end;
		if v435 == true then
			if l_Value_0 == "saa" then
				v446 = 7.5
				if v_u_12.alt_mode == true then
					v446 = 0
					v437 = "quickdraw"
				elseif l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot" then
					v446 = 2.5
				end;
			end;
		elseif l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
			v446 = 0
		end;
		v_u_159 = tick()
		if l_pellets_0 == 1 then
			v446 = v446 / l_core_checkers_0.accuracy_modifier
		end;
		local v447 = (l_Parent_0:FindFirstChild("bipod") and (tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer and (tick() - l_core_checkers_0.moving_accuracy < 0 and l_core_checkers_0.in_air == false)) and 0.2 or v446) * 10
		local v448 = l_Value_1.special.muzzle.CFrame - l_Value_1.special.muzzle.CFrame.lookVector * v_u_7.length
		if l_Parent_0:FindFirstChild("mounted_weapon") and (l_Parent_0.mounted_weapon.Value and (l_Parent_0.mounted_weapon.Value:FindFirstChild("rig") and (l_Parent_0.mounted_weapon.Value.rig:FindFirstChild("mg") and l_Parent_0.mounted_weapon.Value.rig.mg:FindFirstChild("muzzle")))) then
			v448 = l_Parent_0.mounted_weapon.Value.rig.mg.muzzle.CFrame
		end;
		if v434 == true then
			v448 = l_Character_0.Head.CFrame - l_Character_0.Head.CFrame.lookVector * 1
		end;
		local v449 = (v448.RightVector * math.random(-v447, v447) + v448.UpVector * math.random(-v447, v447)) / 1000
		if l_pellets_0 > 1 then
			local v450 = v447 / 1000
			if l_pellets_0 == 5 and v_u_10 == "autosgvariant" then
				if v445 == 1 then
					v431 = 0
					v432 = 0
				elseif v445 == 2 then
					v431 = -2
					v432 = 0
				elseif v445 == 3 then
					v431 = 2
					v432 = 0
				elseif v445 == 4 then
					v431 = 0
					v432 = -2
				elseif v445 == 5 then
					v431 = 0
					v432 = 2
				end;
			end;
			v449 = v448.RightVector * v450 * v431 + v448.UpVector * v450 * v432
			v431 = v431 + 1
			if v431 >= 2 then
				v432 = v432 + 1
				v431 = -1
			end;
		end;
		local v451 = l_Parent_0:FindFirstChild("scoped") and l_Parent_0.scoped.Value == true and Vector3.new(0, 0, 0) or (l_core_checkers_0.holding_breath == true and (tick() - l_core_checkers_0.hold_breathtime >= l_core_checkers_0.hold_breathaccuracy and (l_pellets_0 == 1 and v_u_12.no_steady_acc == false)) and Vector3.new(0, 0, 0) or v449)
		local v452 = CFrame.new(v448.Position, v_u_28).LookVector + v451
		if l_Parent_0:FindFirstChild("mounted_weapon") and (l_Parent_0.mounted_weapon.Value and (l_Parent_0.mounted_weapon.Value:FindFirstChild("rig") and (l_Parent_0.mounted_weapon.Value.rig:FindFirstChild("mg") and l_Parent_0.mounted_weapon.Value.rig.mg:FindFirstChild("muzzle")))) then
			v448 = l_Parent_0.mounted_weapon.Value.rig.mg.muzzle
			v452 = l_Parent_0.mounted_weapon.Value.rig.mg.muzzle.CFrame.LookVector + v451
		end;
		local v453 = 3
		local l_wallpen_studs_0 = v_u_7.wallpen_studs
		local l_wallpen_distance_0 = v_u_7.wallpen_distance
		if v437 == "pedersen" then
			l_wallpen_studs_0 = 2
			l_wallpen_distance_0 = 30
		end;
		local v454 = l_Value_0 == "pugsley" and 4 or v453
		local v455 = 500
		if l_Value_0 == "walker" then
			if v376[3] < 0.5 then
				l_wallpen_studs_0 = 2
				l_wallpen_distance_0 = 30
			end;
			if v376[2] == false then
				l_wallpen_studs_0 = 0
				v455 = 3
				l_wallpen_distance_0 = 0
			end;
		end;
		if workspace.serverStuff.trainingmode.Value == true then
			l_wallpen_studs_0 = 0
			l_wallpen_distance_0 = 0
		end;
		local v456 = nil
		local v457 = false
		for v458 = 1, v454 do
			local v459, v460, v461, v462 = v_u_1:raycastline({
				["point"] = v448.Position,
				["destination"] = v456 or v452,
				["range"] = v455,
				["bullet"] = true,
				["atmos"] = v430,
				["layermask"] = v_u_24
			})
			if v448 == nil or v460 == nil then
				break;
			end;
			if l_Character_0:FindFirstChild("bodyshield") and (l_Character_0.bodyshield.Value:FindFirstChild("Humanoid") and (l_Character_0.bodyshield.Value.Humanoid.Health > 0 and (l_Character_0.bodyshield.Value:FindFirstChild("HeadHitbox") and l_core_checkers_0.aiming == false))) then
				v459 = l_Character_0.bodyshield.Value.HeadHitbox
				v460 = l_Character_0.bodyshield.Value.HeadHitbox.Position
			end;
			local l_magnitude_0 = (v448.Position - v460).magnitude
			if l_magnitude_0 >= 20 or (v458 >= 2 or v_u_7.special and (v_u_7.special.incendiary and v_u_7.special.incendiary == true)) then
				v_u_3("bullet_tracer", {
					["startpoint"] = v448.Position,
					["endpoint"] = v460,
					["pelletsfired"] = l_pellets_0,
					["snap"] = v444,
					["atmos_using"] = v430
				})
			end;
			if v_u_7.special and (v_u_7.special.incendiary and v_u_7.special.incendiary == true) then
				if v459 then
					v_u_3("phos_impact", {
						["posat"] = CFrame.new(v460, l_Character_0.HumanoidRootPart.Position)
					})
				end;
				v_u_3("phos_trail", {
					["startpoint"] = l_Value_1.special.muzzle.Position,
					["endpoint"] = v460
				})
			end;
			local v463 = false
			local v464 = false
			local v465 = false
			if v459 and v459.Parent:FindFirstChild("invuln") == nil then
				if v459.Parent:FindFirstChild("Humanoid") and (v459.Parent.Humanoid.Health > 0 or v459.Parent.Parent == workspace.bodies) then
					v463 = true
					if v459.Parent:FindFirstChild("dreadnought") then
						v_u_3("mine_impact", {
							["weapon"] = l_Value_0,
							["normal"] = v461,
							["from"] = l_Value_1.special.muzzle.Position,
							["point"] = v459.Position,
							["headhit"] = true,
							["ricochet"] = math.random(1, 2)
						})
					else
						if v459.Parent:FindFirstChild("helmet") and (v459.Name == "HeadHitbox" and (v459:FindFirstChild("helmet_lifted") == nil and (v459.Parent.Parent ~= workspace.bodies and tick() - v_u_373 >= 0.1))) then
							v_u_373 = tick()
							v_u_1:soundHandler({
								["directory"] = {},
								["soundfile"] = "headshot",
								["pitchvariation"] = 0.1,
								["location"] = l_CurrentCamera_0
							}, true)
						end;
						if (v459.Name ~= "HeadHitbox" or v459.Parent:FindFirstChild("helmet") == nil) and v459.Parent.Parent ~= workspace.bodies then
							local v466 = v_u_3
							local v467 = {
								["point"] = CFrame.new(v459.Position, l_Character_0.HumanoidRootPart.Position)
							}
							v467.headshot = v459.Name == "HeadHitbox"
							v466("blood_impact", v467, true)
							if tick() - v_u_373 >= 0.1 then
								v_u_3("bloodhitmarker_fx", {
									["position"] = CFrame.new(v459.Position)
								}, true)
							end;
							v_u_373 = tick()
						end;
					end;
					v437 = v435 == true and (l_Value_0 == "saa" and (v_u_19.ammo_mag <= 0 and (v437 ~= "quickdraw" and l_Character_0:FindFirstChild("cowboy") == nil))) and "cowboy" or v437
					if v459.Parent.Parent == workspace.bodies then
						if tick() - v_u_373 >= 0.1 then
							if v459.Name == "Head" and v459.Parent:FindFirstChild("helmet") then
								v_u_3("mine_impact", {
									["weapon"] = l_Value_0,
									["normal"] = v461,
									["from"] = l_Value_1.special.muzzle.Position,
									["point"] = v459.Position,
									["headhit"] = true,
									["ricochet"] = math.random(1, 2)
								})
							else
								v_u_3("blood_impact", {
									["point"] = CFrame.new(v459.Position, l_Character_0.HumanoidRootPart.Position)
								})
								v_u_1:soundHandler({
									["directory"] = {},
									["soundfile"] = "flesh_" .. math.random(1, 4),
									["pitchvariation"] = 0.1,
									["location"] = v459
								})
								v_u_1:soundHandler({
									["directory"] = {},
									["soundfile"] = "blood_" .. math.random(1, 4),
									["pitchvariation"] = 0.1,
									["location"] = v459
								})
							end;
							l_remotes_0.game_handler:FireServer("hit_body", v459)
						end;
						v_u_373 = tick()
					else
						l_remotes_0.damage_handler:FireServer(v459, l_Parent_0, "gun", v_u_7, v437, v457)
					end;
					if l_Value_0 ~= "pugsley" then
						break;
					end;
				else
					if v459.Material == Enum.Material.Wood or v459.Material == Enum.Material.WoodPlanks then
						v_u_3("wood_impact", {
							["point"] = v460,
							["pellets"] = l_pellets_0
						})
						if v459.Name == "secretpartpiece" then
							l_remotes_0.game_handler:FireServer("hit_secretpart", v459)
						end;
						if v459.Name == "lightbody_shoot" and v459.Parent.Name == "body" then
							l_remotes_0.game_handler:FireServer("hit_destructible", v459)
						end;
						if v459.Name == "interactabledestroy" then
							l_remotes_0.game_handler:FireServer("hit_interactablepiece", v459)
						end;
					elseif v459.Material == Enum.Material.Sand or v459.Material == Enum.Material.Ground then
						v_u_3("wood_impact", {
							["point"] = v460,
							["partcol"] = v459.Color,
							["pellets"] = l_pellets_0,
							["sand"] = true
						})
						if v459.Name == "targetrange" then
							v_u_3("bullet_hole", {
								["pos"] = v460,
								["normal"] = v461,
								["targetrange"] = true
							}, true)
							if workspace.serverStuff.trainingmode.Value == true then
								l_remotes_0.game_handler:FireServer("hit_target_range_training")
							end;
						end;
					elseif v459.Material == Enum.Material.Glass and (v459.Name == "WindowBreakable" or v459.Name == "GlassWindow") then
						v_u_3("wood_impact", {
							["point"] = v460,
							["part_hit"] = v459,
							["partcol"] = v459.Color,
							["pellets"] = l_pellets_0,
							["glass"] = true
						})
						if v459.Name == "WindowBreakable" then
							v_u_3("bullet_hole", {
								["pos"] = v460,
								["normal"] = v461,
								["glass"] = true,
								["forceparent"] = v459
							}, true)
							l_remotes_0.game_handler:FireServer("window_impact", v459, (math.clamp(v_u_7.pen, 1, 5)))
						end;
					else
						v_u_3("mine_impact", {
							["weapon"] = l_Value_0,
							["normal"] = v461,
							["from"] = l_Value_1.special.muzzle.Position,
							["point"] = v460,
							["bullet"] = true,
							["ricochet"] = (math.random(1, 3) ~= 1 or l_pellets_0 ~= 1) and 0 or math.random(1, 3),
							["hit_targ"] = v459.Name,
							["hit_mat"] = v459.Material,
							["pellets"] = l_pellets_0
						})
						if v462 and (v462 == Enum.Material.Rock and l_Value_0 == "pugsley") then
							l_remotes_0.mine:FireServer(CFrame.new(v460 + l_CurrentCamera_0.CFrame.LookVector * 2, l_Character_0.Head.Position), l_Parent_0, false, v459)
						end;
					end;
					local v468 = false
					if v459.Name == "leftshield" or (v459.Name == "rightshield" or (v459.Name == "mainshield" or v459.Name == "topshield")) then
						l_remotes_0.interaction_handler:FireServer(l_Parent_0, "damage_vanguardshield", v459, v437)
						if l_Value_0 ~= "pugsley" then
							break;
						end;
						v465 = true
						v468 = true
					elseif v459.Name == "protect" and v459.Parent.Name == "parts" or v459.Name == "flametank" then
						if l_Value_0 ~= "pugsley" then
							break;
						end;
						v465 = true
						v468 = true
					elseif (v459.Name == "main" or (v459.Name == "shieldcover" or (v459.Name == "shieldside" or (v459.Name == "shieldbolts" or v459.Name == "click")))) and (v459.Parent.Parent.Name == "Vanguard Barrier" or v459.Parent.Name == "main") then
						if l_Value_0 ~= "pugsley" then
							break;
						end;
						v465 = true
						v468 = true
					end;
					v464 = v459:FindFirstChild("pennable") and true or v464
					v465 = not v459.Anchored and true or v465
					if v468 and not v464 then
						l_wallpen_studs_0 = 3
						v437 = "pugsleymetalpenetration"
						v464 = true
						l_wallpen_distance_0 = 35
					end;
					if v459.Parent and (v459.Parent.Parent and (v459.Parent.Parent:FindFirstChild("health") and v459.Parent.Parent.health.Value > 0)) then
						l_remotes_0.construction_handler:FireServer("damage", v459.Parent.Parent, l_Parent_0, v437)
						if not v464 then
							break;
						end;
					end;
					if v459.Parent and v459.Parent.Name == "frontcarriage" or v459.Parent.Parent and v459.Parent.Parent.Name == "frontcarriage" then
						local l_Parent_2 = v459.Parent
						if v459.Parent.Parent.Name == "frontcarriage" then
							l_Parent_2 = v459.Parent.Parent
						end;
						l_remotes_0.interaction_handler:FireServer(l_Parent_0, "damage_frontcarriage", l_Parent_2, v437)
						break;
					end;
					if v459.Name == "flametank" then
						l_remotes_0.interaction_handler:FireServer(l_Parent_0, "damage_flametank", v459, v437)
						if not v464 then
							break;
						end;
					end;
				end;
			end;
			if _G.debugline == true then
				v_u_1:debugline(v448.Position, v460, 10)
				local l_Part_0 = Instance.new("Part")
				l_Part_0.BrickColor = BrickColor.new("Really red")
				l_Part_0.Material = Enum.Material.Neon
				l_Part_0.Size = Vector3.new(0.1, 0.1, 0.1)
				l_Part_0.CanCollide = false
				l_Part_0.CanQuery = false
				l_Part_0.Anchored = true
				l_Part_0.CFrame = CFrame.new(v460)
				l_Part_0.Parent = workspace.notarget
			end;
			if l_pellets_0 ~= 1 and v445 ~= 1 then
				break;
			end;
			local v469
			if l_Value_0 == "pugsley" then
				if v460 then
					v469 = not v459 or table.find(v_u_8.pugsley_pen_materials, v459.Material) or (v459:FindFirstChild("pugsleypen") or v459.Parent:FindFirstChild("pugsleypen"))
				else
					v469 = v460
				end;
			else
				v469 = false
			end;
			if v469 and (not v464 and v459.Material ~= Enum.Material.Glass) then
				l_wallpen_studs_0 = 3
				l_wallpen_distance_0 = 35
				v437 = "pugsleymetalpenetration"
			end;
			if l_wallpen_distance_0 < l_magnitude_0 then
				break;
			end;
			local v470 = false
			if v460 and v459 and (v464 or v459:FindFirstChild("pugsleypen") and l_Value_0 ~= "pugsley" or (v459.Material == Enum.Material.Wood or (v459.Material == Enum.Material.WoodPlanks or (v469 or v463 == true)))) then
				local v471
				if v458 >= 2 then
					v471 = l_wallpen_studs_0 / 2
				else
					v471 = l_wallpen_studs_0
				end;
				local v472 = RaycastParams.new()
				v472.FilterType = Enum.RaycastFilterType.Include
				v472.FilterDescendantsInstances = { v459 }
				v472.IgnoreWater = true
				local v473 = v460 + v452 * v471
				local v474 = workspace:Raycast(v473, CFrame.new(v473, v460).LookVector * (v471 * 2), v472)
				if v474 and (v474.Instance and v474.Position) then
					v470 = true
					v457 = true
					v448 = CFrame.new(v474.Position)
					if (v_u_6.Target == v474.Instance or (v_u_6.Hit.Position - v474.Position).Magnitude <= 1) and not v456 then
						v456 = workspace.CurrentCamera.CFrame.LookVector.Unit
					end;
					if v463 == false then
						v_u_3("bullet_hole", {
							["pos"] = v460,
							["normal"] = v461,
							["hit"] = v459,
							["moving"] = v465
						}, true)
						if v459.Material == Enum.Material.Wood or v459.Material == Enum.Material.WoodPlanks then
							v_u_3("wood_impact", {
								["point"] = v448.Position
							})
						end;
					end;
				end;
			end;
			if v470 == false then
				break;
			end;
			v444 = false
		end;
	end;
	if _G.debugline == false then
		local l_recoil_count_0 = v_u_7.recoil_count
		local l_recoil_0 = v_u_7.recoil
		if l_Value_0 == "walker" then
			if v376[3] ~= false then
				if v376[3] <= 0.2 then
					l_recoil_0 = l_recoil_0 / 3
				elseif v376[3] < 0.5 then
					l_recoil_0 = l_recoil_0 / 2
				end;
			end;
		elseif l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") then
			l_recoil_0 = l_recoil_0 * 0.25
		end;
		local v475 = l_Parent_0:FindFirstChild("bipod") and tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer and 1 or l_recoil_0
		l_core_checkers_0.recoil_kick(v475, v475, l_recoil_count_0, true)
	end;
	local v476
	if v_u_19.ammo_mag <= 0 then
		if l_Parent_0:FindFirstChild("mag_empty") then
			l_Parent_0.mag_empty.Value = true
			v476 = false
		else
			v476 = false
		end;
	else
		v476 = true
	end;
	if v_u_12.alt_mode == true and l_Value_0 == "lebel" then
		v_u_19.force_block_fire = true
		v476 = false
	end;
	local v477
	if l_Value_0 == "mauser" or (l_Value_0 == "mausercarbine" or (l_Value_0 == "steyr" or (l_Value_0 == "mpistol" or (l_Value_0 == "rsc" or (l_Value_0 == "mpgun" or l_Value_0 == "lewis"))))) then
		v477 = l_Value_0 ~= "rsc" or math.random(1, 2) ~= 1
	else
		v477 = false
	end;
	local l_fire_rate_1 = v_u_7.fire_rate
	if l_Value_0 == "browningmg" and v_u_19.ammo_mag == 7 then
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "steam" .. math.random(1, 3),
			["location"] = l_Character_0.HumanoidRootPart
		})
	end;
	if v_u_19.ammo_mag <= 1 and l_Value_0 == "pugsley" then
		local v478 = v_u_4
		local v479 = "magazine_last_round"
		local v480 = {}
		local v481 = l_Value_0
		if v_u_10 ~= "" then
			v481 = v_u_10
		end;
		v480.main = {
			["char"] = l_Character_0,
			["originweapon"] = v481,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v478(v479, v480)
	end;
	if l_Value_0 == "lewis" and v_u_19.ammo_mag <= 25 then
		local v482 = v_u_4
		local v483 = "lewis_magazine"
		local v484 = {}
		local v485 = l_Value_0
		if v_u_10 ~= "" then
			v485 = v_u_10
		end;
		v484.main = {
			["char"] = l_Character_0,
			["originweapon"] = v485,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v482(v483, v484)
		if v_u_19.ammo_mag <= 0 then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "last",
				["location"] = l_Character_0.HumanoidRootPart
			})
		end;
	end;
	if l_Value_0 == "mpistol" then
		local v486 = v_u_4
		local v487 = "m_mag_update"
		local v488 = {}
		local v489 = l_Value_0
		if v_u_10 ~= "" then
			v489 = v_u_10
		end;
		v488.main = {
			["char"] = l_Character_0,
			["originweapon"] = v489,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v486(v487, v488)
	end;
	if v_u_19.ammo_mag <= 0 then
		if l_Value_0 == "rsc" then
			local v490 = v_u_4
			local v491 = "casing_visibility"
			local v492 = {}
			local v493 = l_Value_0
			if v_u_10 ~= "" then
				v493 = v_u_10
			end;
			v492.main = {
				["char"] = l_Character_0,
				["originweapon"] = v493,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v492.transp = 1
			v490(v491, v492)
		end;
		if l_Value_0 == "mpgun" then
			local v494 = v_u_4
			local v495 = "magazine_last_round"
			local v496 = {}
			local v497 = l_Value_0
			if v_u_10 ~= "" then
				v497 = v_u_10
			end;
			v496.main = {
				["char"] = l_Character_0,
				["originweapon"] = v497,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v494(v495, v496)
		end;
		if l_Value_0 == "mgturret" or l_Value_0 == "browningmg" then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "overheat" .. math.random(1, 2),
				["location"] = l_Character_0.HumanoidRootPart
			})
			l_fire_rate_1 = v_u_7.reload_start
			v_u_11[v_u_443]:Stop(0)
			v_u_11.reload_start:Play(0.1, 1, 1 / l_fire_rate_1)
			v_u_19.ammo_mag = math.random(50, 70)
		end;
		if v_u_11[v390] and v477 == true then
			v_u_12.slide_locked = true
			v_u_11[v390]:Play(0.2)
		end;
	end;
	if l_Value_0 == "springfield" and v_u_12.alt_mode == true then
		v476 = false
	end;
	if v_u_11.cycle and v476 == true then
		v_u_19.need_bolt = true
	end;
	if v_u_7.auto ~= true then
		if l_Character_0:FindFirstChild("vanguardbuff") then
			l_fire_rate_1 = l_fire_rate_1 * 0.85
		end;
		if l_Character_0:FindFirstChild("buff_elite") then
			l_fire_rate_1 = l_fire_rate_1 * 0.8
		end;
		if l_Character_0.perk.Value == "quickdraw" then
			if v_u_19.need_bolt == true then
				l_fire_rate_1 = l_fire_rate_1 * 0.955
			else
				l_fire_rate_1 = l_fire_rate_1 * 0.925
			end;
		end;
		if l_Character_0.perk.Value == "akimbo" and (l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == true or p374 == true)) then
			local l_StringValue_4 = Instance.new("StringValue")
			game:GetService("Debris"):AddItem(l_StringValue_4, 0.75)
			l_StringValue_4.Name = "ambi_penalty"
			l_StringValue_4.Parent = l_Character_0
			l_fire_rate_1 = l_fire_rate_1 * 0.7
		end;
		if workspace.serverStuff.restorationmode.Value == true then
			l_fire_rate_1 = l_fire_rate_1 * 1.2
		end;
	end;
	if l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" or workspace.serverStuff.trainingmode.Value == true then
		l_fire_rate_1 = l_fire_rate_1 * 1.2
	end;
	if l_Value_0 == "mares" then
		if p374 == true and l_Character_0:FindFirstChild("Cavalry Sword") or l_Character_0.perk.Value == "akimbo" and (l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == true or p374 == true)) then
			l_fire_rate_1 = l_fire_rate_1 * 1.1
		elseif v_u_12.alt_mode == true then
			l_fire_rate_1 = l_fire_rate_1 * 1.1
		end;
	end;
	if p374 == true and l_Character_0:FindFirstChild("Cavalry Sword") then
		l_fire_rate_1 = l_fire_rate_1 * 1.1
	end;
	local v498 = l_Value_0 == "dbgun" and (v_u_12.alt_mode == true and v_u_19.ammo_mag > 0) and 0.08 or l_fire_rate_1
	local v499
	if v435 == true then
		v499 = l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot" and 0.15 or (v_u_12.alt_mode == true and 0.4 or 0.35)) or v498
	else
		v499 = l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") and 0.45 or v498
	end;
	if l_Value_0 == "pugsley" and (l_core_checkers_0.crouching == true and l_Character_0.class.Value ~= "rook") then
		_G.knockdownproc()
	end;
	v_u_1:s_wait(v499)
	if v414 == "pedersen_fire" and (v_u_12.jammed and v_u_12.jammed == true) then
		v_u_12.jammed = false
		v_u_11.pedersen_jam:Play(0.2, 1, 1)
		v_u_1:s_wait(1)
	end;
	l_core_checkers_0.sprint_block = false
	if l_Value_0 == "walker" and v376[3] >= 1 then
		v_u_180(true)
		return;
	else
		v_u_2.Value = false
		if v_u_7.auto == true and (l_keysheld_0.m1 == true and (l_core_checkers_0.shift_locked == true and (l_core_checkers_0.aiming == true and tick() - l_core_checkers_0.fall_damage_interrupt > 0))) then
			v_u_504("autoshot")
		end;
		if l_Value_0 == "dbgun" and (v_u_12.alt_mode == true and v_u_19.ammo_mag > 0) then
			v_u_317()
		else
			if v_u_19.need_bolt == true then
				if l_core_checkers_0.queue_inv ~= nil then
					repeat
						l_RenderStepped_0:wait()
					until l_core_checkers_0.queue_inv == nil and v_u_12.equipped == true;
				end;
				if l_Value_0 == "pugsley" then
					v_u_2.Value = true
					repeat
						l_RenderStepped_0:Wait()
					until tick() - l_core_checkers_0.fall_damage_interrupt >= 0;
				end;
				if v388 == true and (v_u_11.fire_left and l_Value_0 ~= "trench") then
					v_u_11.fire_left:Stop(0.1)
				end;
				v_u_316()
				v_u_19.need_bolt = false
			end;
			if tick() - v_u_181 <= 0.4 and v_u_7.capacity <= 2 then
				v_u_181 = 0
				v_u_303()
			end;
			if v_u_19.ammo_mag <= 0 and (l_Value_0 == "mauser" and (v_u_10 == "mauservariant" and v_u_12.equipped == true)) then
				local v500 = v_u_4
				local v501 = "casing_visibility"
				local v502 = {}
				local v503 = l_Value_0
				if v_u_10 ~= "" then
					v503 = v_u_10
				end;
				v502.main = {
					["char"] = l_Character_0,
					["originweapon"] = v503,
					["weapon"] = l_Value_0,
					["model"] = l_Value_1,
					["module"] = v_u_7,
					["core"] = v_u_19
				}
				v502.transp = 1
				v500(v501, v502)
				v_u_2.Value = true
				if l_Character_0.perk.Value ~= "vet" then
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "steam_fire" .. math.random(1, 5),
						["location"] = l_Character_0.HumanoidRootPart
					})
					v_u_11.check_empty:Play(0.1, 1, 0.6666666666666666)
					v_u_1:s_wait(1.5)
				end;
				v_u_2.Value = false
				v_u_180(true)
			end;
		end;
	end;
end;
l_BindableEvent_0.Event:Connect(function(p505, p506, p507) --[[ Line: 6694 ]]
	--[[ Upvalues: (ref 1): v_u_504, (copy 2): v_u_157, (ref 3): l_Value_0, (ref 4): v_u_10, (copy 5): v_u_303, (copy 6): v_u_12, (ref 7): v_u_357, (copy 8): l_Parent_0, (ref 9): v_u_19, (copy 10): v_u_11, (copy 11): l_core_checkers_0, (copy 12): l_Character_0, (ref 13): v_u_85 ]]
	if p505 == "fire_weapon" then
		v_u_504(true)
		return;
	elseif p505 == "swing_weapon" then
		v_u_157(true)
	elseif p505 == "reload_weapon_swap" then
		if l_Value_0 ~= "mauser" or v_u_10 ~= "mauservariant" then
			v_u_303(true)
			return;
		end;
	elseif p505 == "dual_active" then
		v_u_12.dual_wield_active = p506
		if (l_Value_0 == "steyr" or l_Value_0 == "mares") and v_u_12.alt_mode == true then
			v_u_357(true)
			return;
		end;
	else
		if p505 == "dual_shoot" then
			local v508 = "shoot"
			if l_Parent_0:FindFirstChild("akimbo") and l_Parent_0:FindFirstChild("akimbo").Value == true then
				v508 = "akimbo_left"
			else
				v_u_19.ammo_mag = p506
			end;
			v_u_11[v508]:Stop(0)
			v_u_11[v508]:Play(0.01, 1, p507)
			return;
		end;
		if p505 == "dual_shoot_empty" then
			local v509, v510
			if l_Parent_0:FindFirstChild("akimbo") and l_Parent_0:FindFirstChild("akimbo").Value == true then
				v509 = "akimbo_left"
				v510 = "akimbo_left_empty"
			else
				v509 = "shoot"
				v510 = "shoot_empty"
			end;
			v_u_11[v509]:Stop(0)
			v_u_11[v510]:Stop(0)
			v_u_11[v510]:Play(0, 1, 1)
			return;
		end;
		if p505 == "reset_aimtime" then
			l_core_checkers_0.aim_time = tick()
			v_u_12.draw = tick()
			if v_u_12.slide_locked == true then
				v_u_11[v_u_11.akimbo_locked and (l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == false and v_u_12.dual_wield_active == true)) and "akimbo_locked" or "locked"]:Play(0)
				return;
			end;
		elseif p505 == "throw_axe" then
			local v511 = l_Character_0:FindFirstChild("equipment")
			if v_u_12.equipped == false and (v511 and v511.Value > 0) then
				v_u_85()
			end;
		end;
	end;
end)
local function v_u_514(p512) --[[ Line: 6770 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_11, (ref 3): v_u_7, (ref 4): l_Value_0, (ref 5): v_u_10, (copy 6): l_core_checkers_0, (copy 7): v_u_1, (copy 8): l_Character_0, (copy 9): v_u_2 ]]
	if v_u_12.anim_swaps == nil then
		v_u_12.anim_swaps = {
			v_u_11.alt_changeaim,
			v_u_11.alt_changefire,
			v_u_11.alt_changefire_empty,
			v_u_11.aim,
			v_u_11.fire,
			v_u_11.fire_empty,
			v_u_11.alt_changefire_last,
			v_u_11.fire_last
		}
		v_u_12.anim_swapstwo = {
			v_u_11.alt_changefire_left,
			v_u_11.alt_changefire_empty_left,
			v_u_11.alt_changefire_last_left,
			v_u_11.alt_changeaim_left,
			v_u_11.fire_left,
			v_u_11.fire_empty_left,
			v_u_11.fire_last_left,
			v_u_11.aim_left
		}
	end;
	v_u_11.aim:Stop(v_u_7.aim_speed)
	if v_u_11.aim_left then
		v_u_11.aim_left:Stop(v_u_7.aim_speed)
	end;
	local v513 = 0.3
	if l_Value_0 == "mauser" then
		if v_u_10 ~= "" then
			return;
		end;
		v513 = 1
		local l_alt_stockon_0 = v_u_11.alt_stockon
		if v_u_12.alt_mode == true then
			l_core_checkers_0.inv_swapping = true
			l_alt_stockon_0 = v_u_11.alt_stockoff
		else
			l_core_checkers_0.inv_swapping = false
		end;
		l_alt_stockon_0:Play(0.1, 1, 1)
	else
		v_u_12.no_steady_acc = not v_u_12.no_steady_acc
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "ready" .. math.random(1, 4),
			["location"] = l_Character_0.HumanoidRootPart
		})
	end;
	if v_u_12.alt_mode == true then
		v_u_11.aim = v_u_12.anim_swaps[4]
		v_u_11.fire = v_u_12.anim_swaps[5]
		if v_u_11.fire_empty then
			v_u_11.fire_empty = v_u_12.anim_swaps[6]
		end;
		if v_u_11.fire_last then
			v_u_11.fire_last = v_u_12.anim_swaps[8]
		end;
		if v_u_11.fire_left then
			v_u_11.fire_left = v_u_12.anim_swapstwo[5]
		end;
		if v_u_11.fire_empty_left then
			v_u_11.fire_empty_left = v_u_12.anim_swapstwo[6]
		end;
		if v_u_11.fire_last_left then
			v_u_11.fire_last_left = v_u_12.anim_swapstwo[7]
		end;
		if v_u_11.aim_left then
			v_u_11.aim_left = v_u_12.anim_swapstwo[8]
		end;
	else
		v_u_11.aim = v_u_12.anim_swaps[1]
		v_u_11.fire = v_u_12.anim_swaps[2]
		if v_u_11.fire_empty then
			v_u_11.fire_empty = v_u_12.anim_swaps[3]
		end;
		if v_u_11.fire_last then
			v_u_11.fire_last = v_u_12.anim_swaps[7]
		end;
		if v_u_11.fire_left then
			v_u_11.fire_left = v_u_12.anim_swapstwo[1]
		end;
		if v_u_11.fire_empty_left then
			v_u_11.fire_empty_left = v_u_12.anim_swapstwo[2]
		end;
		if v_u_11.fire_last_left then
			v_u_11.fire_last_left = v_u_12.anim_swapstwo[3]
		end;
		if v_u_11.aim_left then
			v_u_11.aim_left = v_u_12.anim_swapstwo[4]
		end;
	end;
	v_u_12.alt_mode = not v_u_12.alt_mode
	if p512 ~= true then
		v_u_2.Value = true
		v_u_1:s_wait(v513)
		v_u_2.Value = false
	end;
	if v_u_12.alt_mode == true then
		if l_Value_0 == "mauser" then
			l_core_checkers_0.inv_block_reason = "I need to detach the Stock first to swap weapons."
			v_u_7.movement = 2
			v_u_7.firing_movement = 2
			v_u_7.fire_rate = 0.27
			v_u_7.recoil = 4
			v_u_7.accuracy = 6
			v_u_7.moving_accuracy = 100
		elseif l_Value_0 == "lever" then
			v_u_7.movement = 0.5
			v_u_7.firing_movement = 0.5
			v_u_7.accuracy = 35
			v_u_7.moving_accuracy = 35
		elseif l_Value_0 == "steyr" then
			v_u_7.recoil = 3
			v_u_7.moving_accuracy = 8
			v_u_7.fire_rate = 0.45
			v_u_7.movement = 3
			v_u_7.firing_movement = 3
			v_u_7.accuracy = 1
		elseif l_Value_0 == "rsc" then
			v_u_7.recoil = 5
			v_u_7.accuracy = 30
			v_u_7.moving_accuracy = 50
			v_u_7.aim_speed = 0.3
			v_u_7.movement = 1
			v_u_7.firing_movement = 0.5
		elseif l_Value_0 == "remington" then
			v_u_7.accuracy = 1
			v_u_7.moving_accuracy = 1
		elseif l_Value_0 == "autosg" then
			v_u_7.firing_movement = 3
			v_u_7.movement = 4
			v_u_7.recoil_count = 6
			v_u_7.recoil = 6
			v_u_7.aim_speed = 0.5
		elseif l_Value_0 == "mares" then
			v_u_7.recoil = 12
			v_u_7.movement = 0.5
			v_u_7.firing_movement = 0.5
			v_u_7.firing_movement_last = 0.25
			v_u_7.moving_accuracy = 60
			v_u_7.aim_speed = 0.125
		end;
	else
		l_core_checkers_0.inv_block_reason = ""
		v_u_7 = v_u_1:deepCopy(require(game.ReplicatedStorage.weapon_modules:FindFirstChild(l_Value_0)))
	end;
	l_core_checkers_0.speed_mod = v_u_7.movement
end;
local function v_u_560() --[[ Line: 6919 ]]
	--[[ Upvalues: (copy 1): l_Parent_0, (ref 2): l_Value_0, (copy 3): v_u_2, (copy 4): l_Character_0, (copy 5): v_u_12, (copy 6): v_u_11, (copy 7): v_u_1, (ref 8): v_u_10, (copy 9): l_CurrentCamera_0, (ref 10): v_u_7, (copy 11): l_core_checkers_0, (copy 12): v_u_126, (copy 13): l_Value_1, (copy 14): v_u_3, (copy 15): l_remotes_0, (copy 16): v_u_9, (copy 17): l_keysheld_0, (copy 18): v_u_319, (copy 19): l_RenderStepped_0, (copy 20): l_core_game_0, (ref 21): v_u_504, (copy 22): v_u_4, (ref 23): v_u_19, (ref 24): v_u_514, (copy 25): l_ammo_give_0, (copy 26): v_u_359, (copy 27): v_u_113, (copy 28): v_u_26 ]]
	if workspace.serverStuff.trainingmode.Value == true then
		return;
	end;
	if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0:FindFirstChild("akimbo_aiming") and l_Parent_0.akimbo.Value == true) then
		if l_Value_0 == "saa" and (v_u_2.Value == false and (l_Character_0:FindFirstChild("stop_movement") == nil and (l_Character_0.HumanoidRootPart.Velocity.Magnitude <= 0.5 and (v_u_12.dual_wield_tool and (v_u_12.dual_wield_tool:FindFirstChild("weapon") and v_u_12.dual_wield_tool.weapon.Value == "saa"))))) then
			v_u_2.Value = true
			v_u_11.akimbo_saa_spins:Play(0.1, 1, 1)
			local l_StringValue_5 = Instance.new("StringValue")
			l_StringValue_5.Name = "stop_movement"
			l_StringValue_5.Parent = l_Character_0
			v_u_1:s_wait(7.4)
			v_u_2.Value = false
			if l_StringValue_5 then
				l_StringValue_5:Destroy()
			end;
		else
			l_Parent_0.akimbo_aiming.Value = not l_Parent_0.akimbo_aiming.Value
		end;
	end;
	if l_Value_0 == "mosin" then
		if v_u_10 ~= "" then
			return;
		end;
		l_Parent_0.scoped.Value = not l_Parent_0.scoped.Value
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = l_Parent_0.scoped.Value == false and "zoom_out" or "zoom_in",
			["location"] = l_CurrentCamera_0
		}, true)
	elseif l_Value_0 == "pickaxe" then
		if l_Parent_0.durability.Value <= 0 then
			_G.popupmsg("pick_dura", "My Pick has worn out, I can\'t mine at Heavy Strength.", 1)
			return;
		end;
		v_u_12.alt_mode = not v_u_12.alt_mode
		if v_u_12.alt_mode == true then
			_G.popupmsg("alt_on", "Mining at Weaker Strength.", 1)
		else
			_G.popupmsg("alt_off", "Mining at Heavy Strength", 1)
		end;
	end;
	if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	end;
	if v_u_7.tooltype == "hammer" then
		if v_u_2.Value ~= true then
			v_u_12.construction_mode = not v_u_12.construction_mode
		end;
	end;
	if l_Value_0 == "henry" or (l_Value_0 == "lance" or l_Value_0 == "trench") then
		if v_u_2.Value == true then
			return;
		elseif v_u_10 ~= "henryvariant" then
			v_u_126()
		end;
	end;
	if l_Value_0 == "bottle" then
		if v_u_2.Value == true then
			return;
		end;
		if l_Value_1:FindFirstChild("glassbottle") then
			v_u_2.Value = true
			v_u_11.empty:Play(0.1, 1, 0.5)
			v_u_1:s_wait(2)
			v_u_2.Value = false
			return;
		end;
		if l_core_checkers_0.sick == true then
			_G.popupmsg("bottlesick", "I\'m too sick to drink this right now..", 1)
			return;
		end;
		v_u_2.Value = true
		local l_StringValue_6 = Instance.new("StringValue")
		l_StringValue_6.Name = "drinking"
		l_StringValue_6.Parent = l_Character_0
		l_core_checkers_0.sprint_block = true
		local v515
		if l_Character_0:FindFirstChild("helmet") and l_Character_0.helmet:FindFirstChild("knock") or l_Character_0:FindFirstChild("extralift") then
			v_u_3("helmet_adjusting", {
				["char"] = l_Character_0,
				["val"] = "helmetoff"
			})
			v_u_11.helmet_remove:Play(0.05, 1, 1)
			l_remotes_0.game_handler:FireServer("helmet_lift", true)
			v_u_1:s_wait(0.5)
			v515 = true
		else
			v515 = false
		end;
		v_u_11.drink:Play(0.1, 1, 0.5)
		v_u_1:s_wait(2)
		v_u_11.drink:Stop(0.1)
		v_u_11.drink_motion:Play(0.1, 1, 0.5)
		while v_u_9 ~= nil and (v_u_9.Health > 0 and (l_core_checkers_0.sick ~= true or math.random(1, 2) ~= 1)) do
			l_remotes_0.interaction_handler:FireServer(l_Parent_0, "drinkbottle")
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "drink" .. math.random(1, 5),
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_1:s_wait(0.5)
			if v_u_9 == nil or (v_u_9.Health <= 0 or l_keysheld_0[_G.get_keybinds("alt")] ~= true) then
				break;
			end;
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "water" .. math.random(1, 4),
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_1:s_wait(1.5)
			if v_u_9 == nil or (v_u_9.Health <= 0 or l_keysheld_0[_G.get_keybinds("alt")] ~= true) then
				break;
			end;
		end;
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = l_Character_0.gender.Value .. "_exhale" .. math.random(1, 3),
			["volume_adjust"] = 0.5,
			["location"] = l_Character_0.HumanoidRootPart
		})
		v_u_11.drink_motion:Stop(0.1)
		v_u_11.drink_done:Play(0.1, 1, 0.5)
		v_u_1:s_wait(2)
		l_core_checkers_0.sprint_block = false
		l_StringValue_6:Destroy()
		l_remotes_0.game_handler:FireServer("helmet_lift", false)
		if v515 == true then
			v_u_3("helmet_adjusting", {
				["char"] = l_Character_0,
				["val"] = "helmet"
			})
			v_u_11.helmet_place:Play(0.05, 1, 1)
			v_u_1:s_wait(0.5)
		end;
		v_u_2.Value = false
		return;
	end;
	if l_Value_0 == "machete" then
		if v_u_2.Value == true then
			return;
		elseif l_Value_1:FindFirstChild("body") and (l_Value_1.body:FindFirstChild("blade") and l_Value_1.body.blade:FindFirstChild("blood1")) then
			local l_blade_0 = l_Value_1.body.blade
			if l_blade_0 ~= nil then
				v_u_2.Value = true
				v_u_11.clean:Play(0.1, 1, 0.5)
				v_u_1:s_wait(0.6)
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "clean_notdirty" .. math.random(1, 4),
					["location"] = l_Character_0.HumanoidRootPart
				})
				if l_blade_0:FindFirstChild("blood1") and l_blade_0.blood1.Transparency ~= 1 then
					l_remotes_0.interaction_handler:FireServer(l_Parent_0, "cleanmachete", 1)
					l_blade_0.blood1.Transparency = 1
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "clean_dirty" .. math.random(1, 2),
						["location"] = l_Character_0.HumanoidRootPart
					})
				end;
				v_u_1:s_wait(0.9)
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "clean_notdirty" .. math.random(1, 4),
					["location"] = l_Character_0.HumanoidRootPart
				})
				if l_blade_0:FindFirstChild("blood2") and l_blade_0.blood2.Transparency ~= 1 then
					l_remotes_0.interaction_handler:FireServer(l_Parent_0, "cleanmachete", 2)
					l_blade_0.blood2.Transparency = 1
					if l_blade_0:FindFirstChild("blood3") then
						l_blade_0.blood3.Transparency = 1
					end;
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "clean_dirty" .. math.random(1, 2),
						["location"] = l_Character_0.HumanoidRootPart
					})
				end;
				v_u_1:s_wait(0.5)
				v_u_2.Value = false
			end;
		else
			return;
		end;
	end;
	if l_Value_0 == "lewis" then
		if v_u_2.Value ~= true then
			v_u_319()
		end;
	end;
	if v_u_7.tooltype == "whistle" then
		if v_u_2.Value ~= true then
			v_u_2.Value = true
			l_core_checkers_0.selection_box_selected = ""
			l_core_checkers_0.display_selections({ "advance", "defend", "focus" })
			repeat
				l_RenderStepped_0:wait()
			until l_core_checkers_0.selection_box_selected ~= "" or l_core_checkers_0.queue_inv ~= nil;
			if l_core_checkers_0.queue_inv ~= nil then
				l_core_checkers_0.selection_box_selected = "none"
			end;
			if l_core_checkers_0.selection_box_selected ~= "none" then
				_G.whistle_at = l_core_checkers_0.selection_box_selected
				_G.popupmsg("orderissue" .. math.random(1, 100), "Issuing " .. (l_core_checkers_0.selection_box_selected == "focus" and "Focus" or (l_core_checkers_0.selection_box_selected == "defend" and "Defend" or "Advance")) .. " Order.", 1)
			end;
			l_core_game_0.selectionboxes.Visible = false
			l_core_checkers_0.selection_box_selected = ""
			v_u_2.Value = false
		end;
	end;
	if l_Value_0 == "lebel" then
		if v_u_2.Value ~= true then
			v_u_12.alt_mode = not v_u_12.alt_mode
			v_u_2.Value = true
			if v_u_12.alt_mode == true then
				_G.popupmsg("alt_on", "Fire mode changed to Single Fire.", 1)
				v_u_11.alt_mode_on:Play(0.2, 1, 1)
			else
				_G.popupmsg("alt_off", "Fire mode returned to Repeating.", 1)
				v_u_11.alt_mode_off:Play(0.2, 1, 1)
			end;
			v_u_1:s_wait(0.5)
			v_u_2.Value = false
		end;
	end;
	if l_Value_0 == "pieper" then
		if v_u_2.Value == true then
			return;
		elseif _G.get_settings("qprimeknell") == true then
			_G.pieper_alt = true
			if v_u_12.slide_locked == false and v_u_2.Value == false then
				v_u_504()
			end;
			_G.pieper_alt = false
			return;
		else
			if _G.pieper_alt == nil then
				_G.pieper_alt = false
			end;
			_G.pieper_alt = not _G.pieper_alt
			if _G.pieper_alt == true then
				_G.popupmsg("alt_on", "I\'ll prime the hammer manually after every shot.", 1)
			else
				_G.popupmsg("alt_off", "I\'ll fire in double action now.", 1)
			end;
		end;
	end;
	if l_Value_0 == "walker" then
		if v_u_2.Value ~= true then
			v_u_2.Value = true
			v_u_11.spin_cylinder:Play(0.1, 1, 0.7692307692307692)
			v_u_1:s_wait(0.78)
			local v516 = math.random(4, 9)
			local v517 = v_u_4
			local v518 = "walker_cylinder_rotate"
			local v519 = {}
			local v520 = l_Value_0
			if v_u_10 ~= "" then
				v520 = v_u_10
			end;
			v519.main = {
				["char"] = l_Character_0,
				["originweapon"] = v520,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v519.add_amount = v516
			v517(v518, v519)
			for _ = 1, v516 do
				local v521 = _G
				local v522 = "walkercylinder" .. l_Parent_0.slot.Value
				v521[v522] = v521[v522] + 1
				if _G["walkercylinder" .. l_Parent_0.slot.Value] > 6 then
					_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
				end;
			end;
			v_u_1:s_wait(0.39)
			local v523 = v_u_4
			local v524 = "walker_cylinder_rotate"
			local v525 = {}
			local v526 = l_Value_0
			if v_u_10 ~= "" then
				v526 = v_u_10
			end;
			v525.main = {
				["char"] = l_Character_0,
				["originweapon"] = v526,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v523(v524, v525)
			local v527 = _G
			local v528 = "walkercylinder" .. l_Parent_0.slot.Value
			v527[v528] = v527[v528] + 1
			if _G["walkercylinder" .. l_Parent_0.slot.Value] > 6 then
				_G["walkercylinder" .. l_Parent_0.slot.Value] = 1
			end;
			v_u_1:s_wait(0.26)
			v_u_2.Value = false
		end;
	end;
	if l_Value_0 == "mares" then
		if v_u_2.Value == true then
			return;
		elseif not l_Character_0:FindFirstChild("class") or l_Character_0.class.Value ~= "conscript" then
			v_u_514(false)
		end;
	end;
	if l_Value_0 == "autosg" then
		if v_u_2.Value == true then
			return;
		elseif l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" then
			return;
		elseif l_Value_0 ~= "autosg" or v_u_10 ~= "autosgvariant" then
			v_u_514(false)
		end;
	end;
	if l_Value_0 == "springfield" then
		if v_u_2.Value == true or v_u_10 == "springfieldvariant" then
			return;
		else
			if v_u_12.pedersen_mag == nil then
				v_u_12.pedersen_mag = 0
				if v_u_12.extra_mag == nil then
					v_u_12.extra_mag = false
				end;
				v_u_12.initial_mag = true
			end;
			if v_u_12.pedersen_mag <= 1 and (v_u_12.extra_mag == false and (v_u_12.initial_mag == false and v_u_12.alt_mode == false)) then
				_G.popupmsg("pedersen_nomags", "I don\'t have any magazines left.", 1)
			else
				v_u_2.Value = true
				v_u_12.state = "reload"
				if v_u_12.alt_mode == false then
					v_u_11.pedersen_bolt_remove:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					v_u_11.pedersen_device_on:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					v_u_11.pedersen_mag_in:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					if v_u_12.pedersen_mag == 0 then
						if v_u_12.initial_mag == false then
							v_u_12.extra_mag = false
						end;
						v_u_12.initial_mag = false
						v_u_12.pedersen_mag = 40
						if v_u_12.newmag_chamber and v_u_12.newmag_chamber == true then
							v_u_12.newmag_chamber = false
							local v529 = v_u_12
							v529.pedersen_mag = v529.pedersen_mag + 1
						else
							v_u_11.pedersen_charge:Play(0.2, 1, 1)
							v_u_1:s_wait(1)
						end;
					end;
					v_u_12.jam_count = math.random(7, 18)
					v_u_7.fire_rate = 0.333
					v_u_7.recoil = 1
					v_u_12.last_mag = v_u_19.ammo_mag
					v_u_19.pedersen_device = true
					v_u_19.ammo_mag = v_u_12.pedersen_mag
				else
					local v530
					if v_u_19.ammo_mag <= 1 then
						v530 = "pedersen_mag_eject"
						if v_u_19.ammo_mag == 1 then
							v_u_12.newmag_chamber = true
						end;
						v_u_19.ammo_mag = 0
					else
						v530 = "pedersen_mag_out"
					end;
					v_u_11[v530]:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					v_u_11.pedersen_device_off:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					v_u_11.pedersen_bolt_place:Play(0.2, 1, 0.5)
					v_u_1:s_wait(2)
					v_u_12.pedersen_mag = v_u_19.ammo_mag
					v_u_19.ammo_mag = v_u_12.last_mag
					v_u_19.pedersen_device = false
					if v_u_19.ammo_mag <= 0 then
						local v531 = v_u_4
						local v532 = "set_chamber_empty"
						local v533 = {}
						local v534 = l_Value_0
						if v_u_10 ~= "" then
							v534 = v_u_10
						end;
						v533.main = {
							["char"] = l_Character_0,
							["originweapon"] = v534,
							["weapon"] = l_Value_0,
							["model"] = l_Value_1,
							["module"] = v_u_7,
							["core"] = v_u_19
						}
						v531(v532, v533)
					end;
					v_u_11.cycle_pedersen:Play(0.2, 1, 1)
					v_u_1:s_wait(1)
					if v_u_19.ammo_mag <= 0 then
						local v535 = v_u_4
						local v536 = "set_chamber_full"
						local v537 = {}
						local v538 = l_Value_0
						if v_u_10 ~= "" then
							v538 = v_u_10
						end;
						v537.main = {
							["char"] = l_Character_0,
							["originweapon"] = v538,
							["weapon"] = l_Value_0,
							["model"] = l_Value_1,
							["module"] = v_u_7,
							["core"] = v_u_19
						}
						v535(v536, v537)
					end;
					v_u_7 = v_u_1:deepCopy(require(game.ReplicatedStorage.weapon_modules:FindFirstChild(l_Value_0)))
				end;
				v_u_12.interrupt_reload = false
				v_u_12.state = "normal"
				v_u_2.Value = false
				v_u_12.alt_mode = not v_u_12.alt_mode
			end;
		end;
	end;
	if l_Value_0 == "enfield" then
		if v_u_2.Value == true then
			return;
		elseif l_Parent_0:FindFirstChild("gl_uses") == nil then
			return;
		elseif v_u_10 ~= "enfieldvariant" then
			if v_u_19.blank_round_loaded == nil then
				v_u_19.blank_round_loaded = false
				v_u_12.grenade_fired = false
			end;
			v_u_12.state = "reload"
			if v_u_12.alt_mode == false then
				if l_Parent_0.gl_uses.Value <= 0 then
					_G.popupmsg("nogl_left", "I don\'t have any more rifle grenades left.", 1)
					return;
				end;
				v_u_12.alt_mode = true
				v_u_2.Value = true
				v_u_11.cutoff_on:Play(0.1, 1, 2)
				v_u_1:s_wait(0.25)
				if v_u_19.blank_round_loaded == false then
					local v539
					if l_Character_0.perk.Value == "vet" and v_u_19.ammo_mag > 0 then
						l_core_checkers_0[l_ammo_give_0 .. "_reserves"] = l_core_checkers_0[l_ammo_give_0 .. "_reserves"] + 1
						v539 = "load_blank_vet"
					else
						v539 = "load_blank"
					end;
					v_u_11[v539]:Play(0.1, 1, 0.6666666666666666)
					v_u_1:s_wait(1.5)
					v_u_11.blank_end:Play(0.1, 1, 2)
					v_u_1:s_wait(0.5)
					if v_u_19.ammo_mag > 0 then
						v_u_19.ammo_mag = v_u_19.ammo_mag - 1
					end;
				end;
				v_u_19.blank_round_loaded = true
				v_u_19.ammo_mag = v_u_19.ammo_mag + 1
				v_u_11.load_grenade:Play(0.1, 1, 0.6666666666666666)
				v_u_1:s_wait(1.5)
				v_u_2.Value = false
			else
				v_u_12.alt_mode = false
				v_u_2.Value = true
				local v540, v541
				if v_u_19.blank_round_loaded == false then
					v540 = "discard_grenade"
					v541 = 1
				else
					v540 = "unload_grenade"
					v541 = 1.5
				end;
				v_u_11[v540]:Play(0.1, 1, 1 / v541)
				v_u_1:s_wait(v541)
				v_u_11.cutoff_off:Play(0.2, 1, 2)
				v_u_1:s_wait(0.25)
				local v542
				if v_u_19.ammo_mag > 1 then
					v_u_11.blank_boltback:Play(0.2, 1, 1)
					v_u_1:s_wait(0.5)
					v_u_11.reload_end:Play(0.2, 1, 2)
					v_u_1:s_wait(0.5)
					v542 = true
				else
					v542 = false
				end;
				if v_u_19.blank_round_loaded == true then
					v_u_19.ammo_mag = v_u_19.ammo_mag - 1
				end;
				if v542 == true then
					v_u_19.blank_round_loaded = false
				end;
				v_u_2.Value = false
			end;
			v_u_12.state = "normal"
			v_u_12.interrupt_reload = false
		end;
	end;
	if l_Value_0 == "dbgun" then
		if v_u_2.Value == true then
			return;
		elseif tick() - v_u_12.alt_cd <= 0.3 then
			return;
		else
			v_u_12.alt_mode = not v_u_12.alt_mode
			v_u_12.alt_cd = tick()
			if v_u_12.alt_mode == true then
				_G.popupmsg("alt_on", "Fire mode changed to Double Fire.", 1)
			else
				_G.popupmsg("alt_off", "Fire mode changed to Single Fire.", 1)
			end;
		end;
	end;
	if l_Value_0 == "saa" then
		if v_u_2.Value == true then
			return;
		end;
		if v_u_19.ammo_mag <= 0 then
			return;
		end;
		if v_u_10 ~= "" then
			return;
		end;
		if v_u_2.Value == false then
			v_u_2.Value = true
			l_core_checkers_0.sprint_block = true
			v_u_12.alt_mode = true
			v_u_11.quickdraw_start:Play(0.2, 1, 1)
			local v543 = tick()
			repeat
				l_core_checkers_0.aim_time = tick()
				l_RenderStepped_0:wait()
			until tick() - v543 >= 0.75;
			v_u_11.quickdraw:Play(0.2, 1, 0.5)
			local v544 = false
			while true do
				l_core_checkers_0.aim_time = tick()
				if l_keysheld_0.m1 == true and l_core_checkers_0.jumped_air == false then
					v544 = true
					break;
				end;
				if l_keysheld_0[_G.get_keybinds("reload")] == true or (l_keysheld_0[_G.get_keybinds("alt")] == true or (l_keysheld_0[_G.get_keybinds("checkammo")] == true or l_core_checkers_0.queue_inv ~= nil)) then
					break;
				end;
				l_RenderStepped_0:Wait()
			end;
			v_u_11.quickdraw:Stop(0.2)
			v_u_2.Value = false
			if v544 == true then
				v_u_504()
			end;
			v_u_12.alt_mode = false
			l_core_checkers_0.sprint_block = false
			return;
		end;
	elseif l_Value_0 == "scho" then
		if v_u_2.Value == true then
			return;
		end;
		if v_u_12.scho_spin == nil then
			v_u_12.scho_spin = 0
		end;
		if v_u_2.Value == false and tick() - v_u_12.alt_cd >= 1 then
			if tick() - v_u_12.alt_cd < 1 or tick() - v_u_12.alt_cd >= 1.0833333333333335 then
				v_u_12.scho_spin = 0
				v_u_11.spin_start:Play(0.3, 1, 1.2)
				v_u_12.alt_cd = tick()
				return;
			end;
			v_u_11.spin:Play(0.3, 1, 1.2)
			v_u_12.alt_cd = tick() - 0.4166666666666667
			v_u_12.scho_spin = v_u_12.scho_spin + 1
			if v_u_12.scho_spin >= 5 and l_Value_0 == "scho" then
				local l_StringValue_7 = Instance.new("StringValue")
				game:GetService("Debris"):AddItem(l_StringValue_7, 50)
				l_StringValue_7.Name = "morale"
				l_StringValue_7.Parent = l_Character_0
				v_u_12.scho_spin = 0
				return;
			end;
		end;
	else
		if l_Value_0 == "mauser" or (l_Value_0 == "lever" or (l_Value_0 == "steyr" or l_Value_0 == "rsc")) then
			if v_u_2.Value == true then
				return;
			elseif l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" then
				return;
			elseif l_Value_0 == "lever" and v_u_10 == "levervariant" then
				return;
			elseif l_Value_0 ~= "steyr" or v_u_10 ~= "steyrvariant" then
				v_u_514(false)
			end;
		end;
		if l_Value_0 == "remington" then
			if v_u_2.Value == true or v_u_10 ~= "" then
				return;
			else
				v_u_12.alt_mode = not v_u_12.alt_mode
				if v_u_12.alt_mode == true then
					_G.popupmsg("alt_on", "I\'ll melee with the gun now.", 1)
				else
					_G.popupmsg("alt_off", "I\'ll throw the gun now.", 1)
				end;
			end;
		end;
		if l_Value_0 == "mpistol" then
			if v_u_2.Value ~= true then
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "reloadstart",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
				v_u_2.Value = true
				v_u_11.tag_look:Play(0.1, 1, 0.5)
				delay(0.1, function() --[[ Line: 7721 ]]
					--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0, (ref 3): v_u_3 ]]
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "generalpouch" .. math.random(1, 2),
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					v_u_3("faketag_hand", {
						["char"] = l_Character_0
					})
				end)
				delay(0.3, function() --[[ Line: 7737 ]]
					--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0 ]]
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "tag_rattle" .. math.random(1, 3),
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
				end)
				v_u_1:s_wait(1)
				local v545 = tick()
				v_u_11.tag_look:AdjustSpeed(0)
				v_u_11.tag_look.TimePosition = 0.5
				while l_keysheld_0[_G.get_keybinds("alt")] ~= nil or tick() - v545 < 0.5 do
					v_u_11.tag_look.TimePosition = 0.5
					l_RenderStepped_0:Wait()
				end;
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "reloadend",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
				v_u_11.tag_look.TimePosition = 0.5
				v_u_11.tag_look:AdjustSpeed(0.5)
				delay(0.5, function() --[[ Line: 7774 ]]
					--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0 ]]
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "tag_rattle" .. math.random(1, 3),
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
				end)
				delay(0.7, function() --[[ Line: 7783 ]]
					--[[ Upvalues: (ref 1): v_u_3, (ref 2): l_Character_0 ]]
					v_u_3("faketag_hand", {
						["char"] = l_Character_0
					})
				end)
				v_u_1:s_wait(1.2)
				v_u_2.Value = false
			end;
		end;
		if l_Value_0 == "vanguardshield" then
			if v_u_2.Value == true then
				return;
			elseif not l_Parent_0:FindFirstChild("client_inactive") then
				local v546 = "shield_foldout"
				local v547 = 1.75
				if v_u_12.alt_mode == false then
					if ((not l_Value_1:FindFirstChild("special") or (not l_Value_1.special:FindFirstChild("leftshield") or (not l_Value_1.special:FindFirstChild("rightshield") or (not l_Value_1.special.leftshield:FindFirstChild("damagepart") or (not l_Value_1.special.rightshield:FindFirstChild("damagepart") or (l_Value_1.special.leftshield.damagepart.Transparency ~= 1 or l_Value_1.special.rightshield.damagepart.Transparency ~= 1)))))) and true or false) == true then
						l_core_checkers_0.inv_block_reason = "I need to fold my side plates to swap weapons."
						l_core_checkers_0.inv_swapping = false
					end;
				else
					l_core_checkers_0.inv_block_reason = ""
					l_core_checkers_0.inv_swapping = true
					v546 = "shield_foldin"
					v547 = 1
				end;
				local v548 = v_u_12.dual_wield_tool == nil and 1.75 or v547
				if l_Value_1:FindFirstChild("special") and (l_Value_1.special:FindFirstChild("leftshield") and (l_Value_1.special:FindFirstChild("rightshield") and (l_Value_1.special.leftshield:FindFirstChild("damagepart") and l_Value_1.special.rightshield:FindFirstChild("damagepart")))) then
					v_u_2.Value = true
					if l_Value_1.special.leftshield.damagepart.Transparency == 0 or l_Value_1.special.rightshield.damagepart.Transparency == 0 then
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "unready" .. math.random(1, 4),
							["location"] = l_Character_0.HumanoidRootPart
						})
					end;
					if l_Value_1.special.leftshield.damagepart.Transparency == 0 then
						v_u_11[v546 .. "_left"]:Play(0.1, 1, 2 * v548)
						v_u_1:s_wait(0.3 / v548)
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "shield_shuffle" .. math.random(1, 3),
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = v546,
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
						v_u_1:s_wait(0.2 / v548)
					end;
					if l_Value_1.special.rightshield.damagepart.Transparency == 0 then
						v_u_11[v546 .. "_right"]:Play(0.1, 1, 2 * v548)
						v_u_1:s_wait(0.3 / v548)
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "shield_shuffle" .. math.random(1, 3),
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = v546,
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
						v_u_1:s_wait(0.2 / v548)
					end;
					v_u_2.Value = false
				end;
				v_u_359(false)
			end;
		end;
		if v_u_7.tooltype == "stims" then
			if v_u_2.Value == true then
				return;
			elseif l_Character_0.supplies.Value <= 0 then
				_G.popupmsg("stim_supply", "I don\'t have enough Supplies for Stimulants.", 1)
			else
				local v549 = 0
				if _G.get_settings("oldmortselection") == true then
					_G.popupmsg("stim_popup", "Use [1] [2] [3] [4] [5] or [6]", 1)
					v_u_2.Value = true
					l_core_checkers_0.inv_swapping = false
					local v550 = tick()
					v_u_11.choosing:Play(0.3, 1, 0.5)
					while true do
						v549 = l_keysheld_0[Enum.KeyCode.One] and 1 or (l_keysheld_0[Enum.KeyCode.Two] and 2 or (l_keysheld_0[Enum.KeyCode.Three] and 3 or (l_keysheld_0[Enum.KeyCode.Four] and 4 or (l_keysheld_0[Enum.KeyCode.Five] and 5 or (l_keysheld_0[Enum.KeyCode.Six] and 6 or 0)))))
						if tick() - v550 >= 0.5 and (l_keysheld_0[Enum.KeyCode.Q] == true or l_keysheld_0.m1 == true) then
							break;
						end;
						l_RenderStepped_0:wait()
						if v549 ~= 0 then
							break;
						end;
					end;
				else
					v_u_2.Value = true
					v_u_11.choosing:Play(0.3, 1, 0.5)
					l_core_checkers_0.selection_box_selected = ""
					l_core_checkers_0.display_selections({
						"1",
						"2",
						"3",
						"4",
						"5",
						"6"
					})
					repeat
						l_RenderStepped_0:wait()
					until l_core_checkers_0.selection_box_selected ~= "" or l_core_checkers_0.queue_inv ~= nil;
					if l_core_checkers_0.queue_inv ~= nil then
						l_core_checkers_0.selection_box_selected = "none"
					end;
					if l_core_checkers_0.selection_box_selected ~= "none" then
						v549 = tonumber(l_core_checkers_0.selection_box_selected)
					end;
					l_core_game_0.selectionboxes.Visible = false
					l_core_checkers_0.selection_box_selected = ""
				end;
				v_u_11.choosing:Stop(0.3)
				if v549 ~= 0 then
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "grab",
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					_G.popupmsg("stim_load" .. math.random(1, 100), v_u_12.stimulants[v549].name .. " Vial added.", 1)
					local l_supplies_0 = l_Character_0.supplies
					l_supplies_0.Value = l_supplies_0.Value - 1
					l_remotes_0.medical_handler:FireServer("apply_stims", v549)
					if v_u_19.stim_content == nil then
						v_u_19.stim_content = {}
					end;
					if v_u_19.stim_colour == nil then
						v_u_19.stim_colour = Color3.fromRGB(199, 199, 199)
					end;
					v_u_19.stim_colour = v_u_19.stim_colour:Lerp(game.ReplicatedStorage.outfits.mortician:FindFirstChild("stim" .. v549).vial.inside.Color, 0.5)
					delay(0.2, function() --[[ Line: 8003 ]]
						--[[ Upvalues: (ref 1): v_u_4, (ref 2): l_Value_0, (ref 3): v_u_10, (ref 4): l_Character_0, (ref 5): l_Value_1, (ref 6): v_u_7, (ref 7): v_u_19 ]]
						local v551 = v_u_4
						local v552 = "stimbottle_changecolour"
						local v553 = {}
						local v554 = l_Value_0
						if v_u_10 ~= "" then
							v554 = v_u_10
						end;
						v553.main = {
							["char"] = l_Character_0,
							["originweapon"] = v554,
							["weapon"] = l_Value_0,
							["model"] = l_Value_1,
							["module"] = v_u_7,
							["core"] = v_u_19
						}
						v553.colour = v_u_19.stim_colour
						v551(v552, v553)
					end)
					table.insert(v_u_19.stim_content, v549)
					v_u_12.alt_mode = true
					v_u_12.stim_uses = 3
					v_u_11.load:Play(0.1, 1, 1.5)
					v_u_1:s_wait(0.73)
					spawn(function() --[[ Line: 8016 ]]
						--[[ Upvalues: (ref 1): v_u_4, (ref 2): l_Value_0, (ref 3): v_u_10, (ref 4): l_Character_0, (ref 5): l_Value_1, (ref 6): v_u_7, (ref 7): v_u_19 ]]
						local v555 = v_u_4
						local v556 = "stim_empty_vial"
						local v557 = {}
						local v558 = l_Value_0
						if v_u_10 ~= "" then
							v558 = v_u_10
						end;
						v557.main = {
							["char"] = l_Character_0,
							["originweapon"] = v558,
							["weapon"] = l_Value_0,
							["model"] = l_Value_1,
							["module"] = v_u_7,
							["core"] = v_u_19
						}
						v555(v556, v557)
					end)
					v_u_11.load:Stop(0.3)
				end;
				l_core_checkers_0.inv_swapping = true
				v_u_2.Value = false
			end;
		end;
		if v_u_7.tooltype == "firstaid" then
			if v_u_2.Value ~= true then
				v_u_113(true)
			end;
		end;
		if v_u_7.tooltype == "binocs" then
			if l_Character_0:FindFirstChild("binoc_ping_cd") then
				return;
			end;
			if v_u_2.Value == true then
				return;
			end;
			local l_StringValue_8 = Instance.new("StringValue")
			game:GetService("Debris"):AddItem(l_StringValue_8, 2)
			l_StringValue_8.Name = "binoc_ping_cd"
			l_StringValue_8.Parent = l_Character_0
			v_u_11.point:Play(0.3, 1, 1)
			local _, v559 = v_u_1:raycastline({
				["point"] = l_CurrentCamera_0.CFrame.Position,
				["destination"] = l_CurrentCamera_0.CFrame.LookVector,
				["range"] = 500,
				["layermask"] = v_u_26
			})
			if v559 then
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "binoc_ping", v559)
			end;
		end;
	end;
end;
local function v_u_562() --[[ Line: 8069 ]]
	--[[ Upvalues: (copy 1): v_u_2, (copy 2): l_core_checkers_0, (copy 3): v_u_12, (copy 4): v_u_1, (copy 5): l_CurrentCamera_0, (copy 6): v_u_23, (copy 7): v_u_11, (copy 8): l_remotes_0, (copy 9): l_Parent_0 ]]
	if v_u_2.Value == true then
		return;
	elseif l_core_checkers_0.aiming == false then
		return;
	else
		if v_u_12.internal_binocs == nil then
			v_u_12.internal_binocs = 0
		end;
		if tick() - v_u_12.internal_binocs > 1 then
			local v561, _ = v_u_1:raycastline({
				["point"] = l_CurrentCamera_0.CFrame.Position,
				["destination"] = l_CurrentCamera_0.CFrame.LookVector,
				["range"] = 500,
				["layermask"] = v_u_23
			})
			if v561 and (v561.Name == "leftshield" or (v561.Name == "rightshield" or (v561.Name == "mainshield" or v561.Name == "topshield"))) and (v561.Parent and (v561.Parent.Parent and (v561.Parent.Parent.Parent and v561.Parent.Parent.Parent:FindFirstChild("Torso")))) then
				v561 = v561.Parent.Parent.Parent.Torso
			end;
			if v561 and (v561.Name == "protect" and (v561.Parent and (v561.Parent.Name == "parts" and (v561.Parent.Parent and (v561.Parent.Parent.Parent and v561.Parent.Parent.Parent:FindFirstChild("Torso")))))) then
				v561 = v561.Parent.Parent.Parent.Torso
			end;
			if v561 and (v561.Parent and (v561.Parent:FindFirstChild("Humanoid") and (v561.Parent.Humanoid.Health > 0 and v561.Parent:FindFirstChild("mark_cd") == nil))) then
				v_u_12.internal_binocs = tick()
				v_u_11.point:Play(0.3, 1, 1)
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "binoc_mark", v561.Parent)
			end;
		end;
	end;
end;
local function v_u_563() --[[ Line: 8110 ]]
	--[[ Upvalues: (copy 1): v_u_2, (copy 2): v_u_12, (ref 3): v_u_7, (copy 4): l_core_checkers_0, (copy 5): l_Parent_0, (copy 6): v_u_11, (copy 7): v_u_1, (copy 8): l_remotes_0, (copy 9): v_u_3, (copy 10): l_Character_0, (copy 11): v_u_9 ]]
	if v_u_2.Value == true or tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif not (l_Parent_0:FindFirstChild("inactive") or l_Parent_0:FindFirstChild("client_inactive")) then
		v_u_2.Value = true
		local l_StringValue_9 = Instance.new("StringValue")
		game:GetService("Debris"):AddItem(l_StringValue_9, 2)
		l_StringValue_9.Name = "client_inactive"
		l_StringValue_9.Parent = l_Parent_0
		v_u_11.use:Play(0.1, 1, 1)
		v_u_1:s_wait(0.4)
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "lancerstimmed")
		v_u_1:s_wait(0.55)
		v_u_3("lancer_fakestim", {
			["char"] = l_Character_0
		})
		v_u_1:s_wait(0.1)
		v_u_2.Value = false
		v_u_9:UnequipTools()
	end;
end;
local function v_u_568() --[[ Line: 8142 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_19, (copy 3): v_u_2, (ref 4): v_u_7, (copy 5): l_core_checkers_0, (copy 6): v_u_1, (copy 7): l_Character_0, (copy 8): v_u_11, (copy 9): v_u_355, (copy 10): v_u_4, (ref 11): l_Value_0, (ref 12): v_u_10, (copy 13): l_Value_1 ]]
	if v_u_12.alt_mode == false or (v_u_19.stim_content == nil or #v_u_19.stim_content <= 0) then
		return;
	elseif v_u_2.Value ~= true and tick() - v_u_12.draw >= v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		v_u_2.Value = true
		v_u_1:soundHandler({
			["directory"] = {},
			["soundfile"] = "shake" .. math.random(1, 3),
			["pitchvariation"] = 0.1,
			["location"] = l_Character_0.HumanoidRootPart
		})
		delay(0.6, function() --[[ Line: 8159 ]]
			--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Character_0 ]]
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "throw",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
		end)
		v_u_11.ready:Play(0.1, 1, 1.5)
		v_u_1:s_wait(0.7)
		v_u_1:fast_spawn(function() --[[ Line: 8184 ]]
			--[[ Upvalues: (ref 1): v_u_355 ]]
			v_u_355(4, 2, 0.02)
		end)
		v_u_12.alt_mode = false
		local v564 = v_u_4
		local v565 = "stimbottle_invis"
		local v566 = {}
		local v567 = l_Value_0
		if v_u_10 ~= "" then
			v567 = v_u_10
		end;
		v566.main = {
			["char"] = l_Character_0,
			["originweapon"] = v567,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v564(v565, v566)
		v_u_11.throw_over:Play(0.1, 1, 2)
		v_u_1:s_wait(0.5)
		v_u_11.throw_over:Stop(0.2)
		v_u_11.new:Play(0.2, 1, 1.5)
		v_u_1:s_wait(0.75)
		v_u_2.Value = false
	end;
end;
v_u_85 = function() --[[ Line: 8207 ]]
	--[[ Upvalues: (copy 1): l_Parent_0, (copy 2): l_Character_0, (copy 3): v_u_1, (ref 4): l_Value_0, (copy 5): l_core_checkers_0, (copy 6): v_u_355, (copy 7): v_u_12 ]]
	if l_Parent_0:FindFirstChild("client_inactive") then
		return;
	else
		local v569 = l_Character_0:FindFirstChild("equipment")
		if v569 ~= nil and v569.Value > 0 then
			local v_u_570, v_u_571
			if l_Character_0:FindFirstChild("class") and (l_Character_0.class.Value == "lancer" and (l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "marksman")) then
				v_u_570 = 6
				v_u_571 = 0.01
			else
				v_u_570 = 2
				v_u_571 = 0.02
			end;
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "throw1",
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "throw2",
				["location"] = l_Character_0.HumanoidRootPart
			})
			l_core_checkers_0.equipment_show_cd = tick()
			l_core_checkers_0.equipment_ticker = tick()
			v569.Value = v569.Value - 1
			v_u_1:fast_spawn(function() --[[ Line: 8248 ]]
				--[[ Upvalues: (ref 1): v_u_355, (ref 2): v_u_570, (ref 3): v_u_571 ]]
				v_u_355(8, v_u_570, v_u_571)
			end)
			v_u_12.alt_mode = false
		end;
	end;
end
local v_u_572 = 0
local function v_u_578() --[[ Line: 8416 ]]
	--[[ Upvalues: (copy 1): l_core_checkers_0, (ref 2): v_u_572, (copy 3): l_LocalPlayer_0, (copy 4): l_Value_1, (copy 5): l_Character_0, (copy 6): v_u_1, (copy 7): v_u_12, (copy 8): l_RenderStepped_0, (copy 9): v_u_9, (copy 10): l_keysheld_0, (copy 11): v_u_2, (copy 12): v_u_11, (copy 13): v_u_3, (ref 14): v_u_7, (copy 15): l_remotes_0, (copy 16): l_Parent_0, (ref 17): v_u_31 ]]
	if l_core_checkers_0.aiming == false then
		return;
	end;
	if tick() - v_u_572 <= 0.5 then
		return;
	end;
	if l_core_checkers_0.shift_locked == false then
		return;
	end;
	if workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firebeam") == nil or workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle") == nil then
		return;
	end;
	if l_Value_1:FindFirstChild("firehitbox") == nil then
		return;
	end;
	if tick() - l_core_checkers_0.fall_damage_interrupt <= 0 then
		return;
	end;
	if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
		return;
	end;
	if workspace.serverStuff.medievalmode.Value == true then
		_G.popupmsg("guninmedieval", "I can\'t fire weapons in Medieval Mode.", 1)
		return;
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "trigger_hit",
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	if v_u_12.flamer_fuel <= 0 then
		spawn(function() --[[ Line: 8453 ]]
			--[[ Upvalues: (ref 1): l_RenderStepped_0, (ref 2): v_u_9, (ref 3): l_core_checkers_0, (ref 4): v_u_12, (ref 5): l_keysheld_0, (ref 6): v_u_1, (ref 7): l_Character_0 ]]
			repeat
				l_RenderStepped_0:Wait()
			until v_u_9 == nil or (v_u_9.Health <= 0 or (tick() - l_core_checkers_0.fall_damage_interrupt <= 0 or (v_u_12.equipped == false or (l_core_checkers_0.aiming == false or (l_keysheld_0.m1 ~= true or l_core_checkers_0.shift_locked == false)))));
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "trigger_release",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
		end)
		return;
	end;
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "ready" .. math.random(1, 4),
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	v_u_2.Value = true
	local v573 = l_core_checkers_0.flip_cam == true and "firing_left" or "firing"
	v_u_11[v573]:Play(0.2, 1, 0.1)
	if workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle"):FindFirstChild("residual") and workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle").residual.Enabled == false then
		v_u_3("flamer_fx", {
			["beampart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firebeam"),
			["muzzlepart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle"),
			["firehitbox"] = l_Value_1:FindFirstChild("firehitbox"),
			["state"] = "initialsmoke"
		})
		v_u_1:s_wait(0.3)
	end;
	v_u_11[v573]:AdjustSpeed(1)
	v_u_572 = tick()
	l_core_checkers_0.int_speed = l_core_checkers_0.int_speed - v_u_7.firing_movement
	l_core_checkers_0.slow_rotate = true
	if l_Value_1 then
		v_u_3("flamer_fx", {
			["beampart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firebeam"),
			["muzzlepart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle"),
			["firehitbox"] = l_Value_1:FindFirstChild("firehitbox"),
			["state"] = "start"
		})
	end;
	local v574 = tick()
	while true do
		l_RenderStepped_0:Wait()
		if l_core_checkers_0.flip_cam == true and v_u_11.firing.IsPlaying == true then
			v_u_11.firing:Stop(0.1)
			if v_u_11.firing_left.IsPlaying == false then
				v_u_11.firing_left:Play(0.1, 1, 1)
			end;
		end;
		if l_core_checkers_0.flip_cam == false and v_u_11.firing_left.IsPlaying == true then
			v_u_11.firing_left:Stop(0.1)
			if v_u_11.firing.IsPlaying == false then
				v_u_11.firing:Play(0.1, 1, 1)
			end;
		end;
		if v_u_12.flamer_fuel <= 0 then
			break;
		end;
		if tick() - v574 >= 0.1 then
			local v575 = v_u_12
			v575.flamer_fuel = v575.flamer_fuel - 1
			if v_u_12.flamer_fuel <= 0 and l_Character_0:FindFirstChild("flametankempty") == nil then
				l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flametankempty")
			end;
			v574 = tick()
			local v576 = {}
			if not l_Value_1:FindFirstChild("firehitbox") then
				return;
			end;
			for _, v577 in ipairs((workspace:GetPartsInPart(l_Value_1.firehitbox, v_u_31))) do
				if v577.Name ~= "bullet_whizz" and (v577.Parent and (v577.Parent:FindFirstChild("Humanoid") and (v577.Parent.Humanoid:FindFirstChild("burning_heavy") == nil and (v577.Parent.Humanoid.Health > 0 and v576[v577.Parent.Name] == nil)))) then
					v576[v577.Parent.Name] = true
					l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flamethrower", v577.Parent)
				end;
			end;
		end;
		if v_u_9 == nil or (v_u_9.Health <= 0 or (tick() - l_core_checkers_0.fall_damage_interrupt <= 0 or v_u_12.equipped == false)) or (l_core_checkers_0.aiming == false or (l_keysheld_0.m1 ~= true or l_core_checkers_0.shift_locked == false)) and tick() - v_u_572 >= 0.5 or v_u_12.flamer_fuel <= 0 then
			break;
		end;
	end;
	if v_u_12.flamer_fuel <= 0 and l_Character_0:FindFirstChild("flametankempty") == nil then
		l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flametankempty")
	end;
	if l_Value_1 then
		v_u_3("flamer_fx", {
			["beampart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firebeam"),
			["muzzlepart"] = workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_firemuzzle"),
			["firehitbox"] = l_Value_1:FindFirstChild("firehitbox"),
			["state"] = "stop"
		})
	end;
	l_core_checkers_0.int_speed = l_core_checkers_0.int_speed + v_u_7.firing_movement
	l_core_checkers_0.slow_rotate = false
	v_u_2.Value = false
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "trigger_release",
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	v_u_572 = tick()
	v_u_11.firing_left:Stop(0.5)
	v_u_11.firing:Stop(0.5)
end;
v_u_317 = function(p579) --[[ Line: 8615 ]]
	--[[ Upvalues: (ref 1): v_u_5, (copy 2): l_Character_0, (copy 3): v_u_2, (ref 4): v_u_19, (copy 5): l_core_checkers_0, (ref 6): v_u_7, (copy 7): v_u_113, (copy 8): v_u_12, (copy 9): v_u_568, (copy 10): v_u_563, (copy 11): v_u_329, (copy 12): v_u_338, (copy 13): v_u_323, (copy 14): v_u_562, (copy 15): v_u_578, (ref 16): l_Value_0, (ref 17): v_u_10, (copy 18): l_Parent_0, (copy 19): v_u_360, (copy 20): l_RenderStepped_0, (ref 21): v_u_504, (copy 22): v_u_157, (copy 23): l_remotes_0, (copy 24): v_u_11, (copy 25): v_u_9, (copy 26): v_u_1, (copy 27): l_LocalPlayer_0, (copy 28): v_u_8, (copy 29): v_u_356 ]]
	if v_u_5 == true then
		return;
	elseif l_Character_0:FindFirstChild("exec") then
		return;
	elseif l_Character_0:FindFirstChild("execing") then
		return;
	elseif v_u_2.Value == true then
		return;
	elseif v_u_19.need_bolt == true then
		return;
	elseif tick() - l_core_checkers_0.fall_damage_interrupt <= 0 then
		return;
	elseif v_u_7.tooltype == "firstaid" then
		v_u_113()
		return;
	elseif tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
		return;
	elseif v_u_7.tooltype == "lantern" then
		return;
	elseif v_u_7.tooltype == "stims" then
		v_u_568()
		return;
	elseif v_u_7.tooltype == "lancerstim" then
		v_u_563()
		return;
	elseif v_u_7.tooltype == "wrench" then
		v_u_329()
		return;
	elseif v_u_7.tooltype == "throwable" then
		v_u_338()
		return;
	elseif v_u_7.tooltype == "flagpole" then
		v_u_323()
		return;
	elseif v_u_7.tooltype == "binocs" then
		v_u_562()
		return;
	elseif v_u_7.tooltype == "flamer" then
		v_u_578()
		return;
	elseif l_Value_0 == "remington" and (v_u_10 == "" and (v_u_12.alt_mode == false and (v_u_2.Value == false and (l_core_checkers_0.aiming == false and l_Parent_0:FindFirstChild("akimbo") == nil)))) then
		v_u_360()
		return;
	elseif v_u_12.dual_wield_tool == nil and l_Value_0 ~= "vanguardshield" then
		if v_u_7.tooltype == "whistle" then
			l_core_checkers_0.equipment_show_cd = tick()
			local v580 = l_Character_0:FindFirstChild("equipment")
			if v580.Value <= 0 or (l_Character_0:FindFirstChild("buff_" .. _G.whistle_at .. "_already") or l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "radio") then
				local v581 = {
					"Why is no one listening to me?",
					"Why is everyone so mean to me </3.",
					"I\'m being annoying right now.",
					"I\'m being ignored, this is un-acceptable.",
					"Who asked?",
					"I\'m just yapping right now.",
					"I don\'t think anyone cares right now."
				}
				local v582 = "My whistle is not effective right now."
				if v580.Value > 0 then
					v582 = "I already issued this Order, I should use a different one."
				elseif math.random(1, 20) == 1 then
					v582 = v581[math.random(1, #v581)]
				end;
				_G.popupmsg("whistlecd", l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "radio" and "I don\'t need this anymore." or v582, 1)
			else
				v580.Value = v580.Value - 1
				local l_whistle_at_0 = _G.whistle_at
				if _G.whistle_long then
					l_whistle_at_0 = l_whistle_at_0 .. "_long"
				end;
				l_remotes_0.equipment_handler:FireServer(l_whistle_at_0)
			end;
			v_u_2.Value = true
			v_u_11.use:Play(0.1, 1, 1)
			v_u_11[_G.whistle_at]:Play(0.1, 1, 1)
			delay(0.1, function() --[[ Line: 8874 ]]
				--[[ Upvalues: (ref 1): v_u_9, (ref 2): v_u_12, (ref 3): v_u_1, (ref 4): l_Character_0 ]]
				if v_u_9 and (v_u_9.Health > 0 and v_u_12.equipped == true) then
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "whistle_" .. _G.whistle_at,
						["location"] = l_Character_0.HumanoidRootPart
					})
				end;
			end)
			v_u_1:s_wait(2.75)
			v_u_2.Value = false
			return;
		elseif (v_u_7.tooltype == "hammer" or v_u_7.tooltype == "jaegerkit") and v_u_12.construction_mode == true then
			if v_u_12.construct_pos and (v_u_12.construct_ready == true and l_Character_0:FindFirstChild("supplies")) then
				if _G.ping_locked == true then
					return;
				end;
				if v_u_9:FindFirstChild("burning_heavy") then
					return;
				end;
				local v583 = 0
				for _, v584 in ipairs(workspace.constructions:GetChildren()) do
					if v584:FindFirstChild("owner") and (v584.owner.Value == l_LocalPlayer_0.Name and v584.Name == v_u_12.constructing) then
						v583 = v583 + 1
					end;
				end;
				local l_base_constructs_0 = v_u_8.base_constructs[v_u_12.constructing]
				local v585, v586
				if l_base_constructs_0 then
					v585 = l_base_constructs_0.limits
					v586 = l_base_constructs_0.cost
				else
					v585 = 10
					v586 = 1
				end;
				local v587 = v_u_12.constructing == "Light Lure" and 1 or ((v_u_12.constructing == "Mantrap" or (v_u_12.constructing == "Dynamite Stack" or v_u_12.constructing == "Tin Bomb")) and 2 or v586)
				if v583 < v585 then
					if (v_u_12.constructing == "Tripwire" and 0.1 or 0.5) >= tick() - v_u_12.construct_cd then
						return;
					end;
					if v587 > l_Character_0.supplies.Value then
						_G.popupmsg("construct_warn", "I don\'t have enough Supplies for this " .. v_u_12.constructing .. ".", 2)
						return;
					end;
					v_u_12.construct_cd = tick()
					if v_u_7.tooltype == "hammer" then
						l_remotes_0.construction_handler:FireServer("build", v_u_12.constructing, v_u_12.construct_pos)
						return;
					end;
					if v_u_7.tooltype == "jaegerkit" then
						if workspace.serverStuff.values.gamemode.Value == "truce" and l_Character_0:FindFirstChild("engage") == nil then
							return;
						elseif l_Character_0:FindFirstChild("oathbroken") then
							_G.popupmsg("brokenoath", "I can\'t do this.", 1)
						else
							l_remotes_0.interaction_handler:FireServer(l_Parent_0, "place_trap", {
								["trap"] = v_u_12.constructing,
								["pos"] = v_u_12.construct_pos
							})
						end;
					end;
				else
					local v588 = v_u_12.constructing .. "s."
					if v_u_12.constructing == "Sandbags" then
						v588 = v_u_12.constructing .. "."
					end;
					_G.popupmsg("construct_warn", "I can\'t build any more of these " .. v588, 2)
				end;
			end;
			return;
		elseif l_core_checkers_0.shift_locked == false then
			return;
		elseif l_core_checkers_0.aiming == false or (v_u_7.tooltype == "pick" or (v_u_7.tooltype == "melee" or (v_u_7.tooltype == "hammer" or v_u_7.tooltype == "throwaxe"))) then
			if l_Value_0 == "rooklauncher" then
				return;
			elseif (l_Character_0:FindFirstChild("bodyshield") and v_u_19.ammo_mag > 0 and true or (v_u_11.hipfire and v_u_10 == "" and true or false)) == true and v_u_19.ammo_mag > 0 then
				v_u_504()
			else
				v_u_157()
			end;
		else
			if tick() - l_core_checkers_0.aim_time > math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10) then
				if l_Value_0 == "rooklauncher" then
					v_u_356()
					return;
				end;
				v_u_504()
			end;
			return;
		end;
	else
		local v589 = l_Parent_0:FindFirstChild("guarding")
		if l_core_checkers_0.aiming == true then
			if v_u_12.dual_wield_tool == nil then
				if v589 then
					v589.Value = true
				end;
				v_u_157()
				if v_u_12.alt_mode == false and v589 then
					v589.Value = false
					return;
				end;
			elseif v_u_12.dual_wield_tool:FindFirstChild("weapon") and v_u_12.dual_wield_tool.weapon.Value == "cavsword" then
				if v_u_12.dual_wield_tool and v_u_12.dual_wield_tool:FindFirstChild("event") then
					if v589 then
						v589.Value = true
					end;
					v_u_12.dual_wield_tool.event:Fire("swing_weapon")
					repeat
						l_RenderStepped_0:Wait()
					until v_u_2.Value == false;
					if v_u_12.alt_mode == false and v589 then
						v589.Value = false
						return;
					end;
				end;
			else
				if l_Value_0 == "vanguardshield" and v_u_12.alt_mode == true then
					return;
				end;
				if tick() - l_core_checkers_0.aim_time > math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10) then
					if l_Parent_0:FindFirstChild("akimbo") and (l_Parent_0.akimbo.Value == true and l_Parent_0:FindFirstChild("akimbo_aiming")) then
						if l_Parent_0.akimbo_aiming.Value == false and v_u_12.flipflop ~= nil then
							local l_flipflop_0 = v_u_12.flipflop
							if l_flipflop_0 == true and (v_u_19.ammo_mag <= 0 and v_u_12.dual_wield_tool.mag_empty.Value == false) then
								l_flipflop_0 = nil
							end;
							p579 = l_flipflop_0 ~= true and (v_u_12.dual_wield_tool.mag_empty.Value == true and v_u_19.ammo_mag > 0) and true or l_flipflop_0
							v_u_12.flipflop = not v_u_12.flipflop
						elseif _G.using_controller == true then
							p579 = p579 ~= true and true or nil
						end;
					end;
					if p579 == true then
						if v_u_19.ammo_mag <= 1 then
							v_u_12.fire_buffer = 0
						end;
						v_u_504()
						return;
					end;
					if v_u_12.dual_wield_tool and (v_u_12.dual_wield_tool:FindFirstChild("event") and v_u_12.other_wep_module) then
						if v_u_12.dual_wield_tool:FindFirstChild("mag_empty") and v_u_12.dual_wield_tool.mag_empty.Value == true then
							v_u_12.fire_buffer = 0
						end;
						v_u_12.dual_wield_tool.event:Fire("fire_weapon")
						return;
					end;
				end;
			end;
		elseif (l_Value_0 == "vanguardshield" and l_core_checkers_0.sprinting == true) == false then
			if v_u_12.dual_wield_tool and (v_u_12.dual_wield_tool:FindFirstChild("event") and (v_u_12.alt_mode == false and l_Value_0 == "vanguardshield")) then
				if v589 then
					v589.Value = true
				end;
				v_u_12.dual_wield_tool.event:Fire("swing_weapon")
				repeat
					l_RenderStepped_0:Wait()
				until v_u_2.Value == false;
				if v_u_12.alt_mode == false and v589 then
					v589.Value = false
					return;
				end;
			else
				if v589 then
					v589.Value = true
				end;
				v_u_157()
				if v_u_12.alt_mode == false and v589 then
					v589.Value = false
				end;
			end;
		end;
		return;
	end;
end
local v_u_590 = 1
local v_u_591 = 0
local l_construct_constructions_0 = v_u_12.construct_constructions[1]
local function v622() --[[ Line: 9021 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_1, (copy 3): l_CurrentCamera_0, (copy 4): v_u_24, (ref 5): v_u_29, (copy 6): f_updateCharacterTransparency, (copy 7): l_Parent_0, (copy 8): l_Value_1, (copy 9): l_Character_0, (copy 10): v_u_26, (ref 11): v_u_14, (ref 12): v_u_15, (copy 13): l_core_checkers_0, (ref 14): v_u_7, (ref 15): l_construct_constructions_0, (copy 16): l_core_game_0, (ref 17): v_u_18, (copy 18): l_LocalPlayer_0, (copy 19): v_u_27, (ref 20): v_u_31, (copy 21): v_u_25, (copy 22): v_u_23, (ref 23): l_Value_0, (copy 24): v_u_11, (copy 25): v_u_8, (copy 26): l_keysheld_0, (copy 27): v_u_2, (ref 28): v_u_19, (ref 29): v_u_317 ]]
	if v_u_12.equipped ~= false then
		local _, v592 = v_u_1:raycastline({
			["point"] = l_CurrentCamera_0.CFrame.Position,
			["destination"] = l_CurrentCamera_0.CFrame.LookVector,
			["range"] = 500,
			["layermask"] = v_u_24
		})
		v_u_29 = v592
		f_updateCharacterTransparency()
		if l_Parent_0:FindFirstChild("bipod") and (l_Value_1 and l_Value_1:FindFirstChild("hitbox")) then
			local v593 = l_Character_0.Head.Position - Vector3.new(0, 0.5, 0)
			local v594, _ = v_u_1:raycastline({
				["point"] = v593 + l_CurrentCamera_0.CFrame.lookVector * 4,
				["destination"] = -l_Character_0.HumanoidRootPart.CFrame.upVector,
				["range"] = 2.25,
				["layermask"] = v_u_26
			})
			local v595, _ = v_u_1:raycastline({
				["point"] = v593 + l_CurrentCamera_0.CFrame.lookVector * 1.5,
				["destination"] = -l_Character_0.HumanoidRootPart.CFrame.upVector,
				["range"] = 2.25,
				["layermask"] = v_u_26
			})
			if v594 or v595 then
				l_Parent_0.bipod.Value = tick()
				if v_u_14 == false then
					v_u_14 = true
					if tick() - v_u_15 >= 0.2 and l_core_checkers_0.aiming == true then
						v_u_15 = tick()
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "bipod_deploy" .. math.random(1, 4),
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
					end;
				end;
			else
				if l_core_checkers_0.aiming == false then
					l_Parent_0.bipod.Value = 0
				end;
				if tick() - v_u_15 > 0.2 and v_u_14 == true then
					v_u_14 = false
					if tick() - v_u_15 >= 0.2 and l_core_checkers_0.aiming == true then
						v_u_15 = tick()
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "bipod_undeploy" .. math.random(1, 4),
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
					end;
				end;
			end;
		end;
		if v_u_12.construction_mode == true then
			if v_u_7.tooltype == "jaegerkit" then
				if l_core_checkers_0.aiming == true then
					if v_u_12.constructing ~= "Tripwire" then
						v_u_12.confirm_construct = 0
						if v_u_12.construct_holo then
							v_u_12.constructing = "Tripwire"
							v_u_12.construct_holo:Destroy()
							v_u_12.construct_holo = nil
						end;
					end;
				elseif v_u_12.constructing == "Tripwire" then
					v_u_12.constructing = l_construct_constructions_0
					if v_u_12.construct_holo then
						v_u_12.construct_holo:Destroy()
						v_u_12.construct_holo = nil
					end;
				end;
			end;
			if v_u_12.construct_holo == nil then
				local v596 = game.ReplicatedStorage.deployables:FindFirstChild(v_u_12.constructing)
				if v596 then
					v_u_12.construct_holo = v596:Clone()
					for _, v597 in ipairs(v_u_12.construct_holo:GetDescendants()) do
						if v597:IsA("BasePart") and v597.Material ~= Enum.Material.Neon then
							v597.CanCollide = false
							v597.CanQuery = false
							v597.Locked = true
							if v597.Parent == v_u_12.construct_holo.finished or v597.Parent.Parent == v_u_12.construct_holo.finished then
								v597.Transparency = 0.5
								v597.Parent = v_u_12.construct_holo.finished
								v597.Material = Enum.Material.SmoothPlastic
							else
								v597.Transparency = 1
							end;
						elseif v597:IsA("Decal") then
							v597:Destroy()
						end;
					end;
					v_u_12.construct_holo.Parent = l_CurrentCamera_0
				end;
			else
				v_u_12.construct_pos = l_Character_0.HumanoidRootPart.CFrame + l_Character_0.HumanoidRootPart.CFrame.lookVector * 3 - Vector3.new(0, 2.5, 0)
				if v_u_7.tooltype == "hammer" then
					v_u_12.construct_holo:PivotTo(v_u_12.construct_pos)
				end;
				local v598 = nil
				local v599 = nil
				local v600 = nil
				local v601 = nil
				if v_u_7.tooltype == "hammer" then
					local v602
					v598, v602 = v_u_1:raycastline({
						["point"] = l_Character_0.HumanoidRootPart.Position,
						["destination"] = l_Character_0.HumanoidRootPart.CFrame.LookVector,
						["range"] = 4,
						["layermask"] = v_u_26
					})
					v599, v600 = v_u_1:raycastline({
						["point"] = v602,
						["destination"] = -l_Character_0.HumanoidRootPart.CFrame.upVector,
						["range"] = 5,
						["layermask"] = v_u_26
					})
					v_u_12.construct_pos = l_Character_0.HumanoidRootPart.CFrame + l_Character_0.HumanoidRootPart.CFrame.lookVector * 3 - Vector3.new(0, (v602 - v600).Magnitude - 0.5, 0)
				elseif v_u_7.tooltype == "jaegerkit" and (l_core_game_0.Parent.loadout_menu.Visible == false and v_u_29) then
					local v603 = l_Character_0.Head.Position - l_CurrentCamera_0.CFrame.LookVector * 0.4
					v599, v600, v601 = v_u_1:raycastline({
						["point"] = v603,
						["destination"] = CFrame.new(v603, v_u_29).LookVector,
						["range"] = (v_u_12.constructing == "Tripwire" and 8 or 5) + ((l_CurrentCamera_0.CFrame.Position - l_Character_0.Head.Position).Magnitude - 1),
						["layermask"] = v_u_26
					})
					v598 = nil
				end;
				if v_u_18 then
					if v598 and v598:IsDescendantOf(v_u_18) then
						v599 = nil
						v598 = nil
					end;
					if v599 and v599:IsDescendantOf(v_u_18) then
						v599 = nil
						v598 = nil
					end;
				end;
				if v599 and (v599.Name == "nobuild" and v_u_7.tooltype == "hammer") then
					v599 = nil
					v598 = nil
				end;
				if v599 and (v599.Parent and (v599.Parent.Parent and (v599.Parent.Parent.Parent and (v599.Parent.Parent.Parent.Parent and (v599.Parent.Parent.Parent.Parent.Name == "Elevator" or (v599.Parent.Parent.Parent.Name == "Elevator" or (v599.Parent.Parent.Name == "Elevator" or v599.Parent.Name == "Elevator"))))))) then
					v599 = nil
					v598 = nil
				end;
				if v_u_7.tooltype == "jaegerkit" and v600 then
					v_u_12.construct_pos = CFrame.new(v600)
					if v599 then
						v_u_12.construct_pos = CFrame.new(v600, v600 - v601) * CFrame.Angles(1.5707963267948966, 0, 0) + v601 * 0.5
					end;
					if v599 and v599.Transparency == 1 then
						v599 = nil
					end;
					if v_u_12.constructing == "Tripwire" then
						local v604 = 20
						local v605 = nil
						for _, v606 in ipairs(workspace.constructions:GetChildren()) do
							if v606:FindFirstChild("fuse_hook") and (v606:FindFirstChild("tripwires") and (v606.Name ~= "Tripwire" and (v606:FindFirstChild("triggered") == nil and (v606:FindFirstChild("owner") and (v606.owner.Value == l_LocalPlayer_0.Name and (v606:FindFirstChild("health") and (v606.health.Value >= 0 and v606:FindFirstChild("core")))))))) then
								local l_magnitude_1 = (v_u_12.construct_pos.Position - v606.core.Position).magnitude
								if l_magnitude_1 <= v604 then
									local v607 = CFrame.new(v_u_12.construct_pos.Position, v606.core.Position)
									if not v_u_1:raycastline({
										["point"] = v607.Position,
										["destination"] = v607.LookVector * 1,
										["range"] = l_magnitude_1,
										["layermask"] = v_u_27
										}) then
										v605 = v606.fuse_hook.Position
										v604 = l_magnitude_1
									end;
								end;
							end;
						end;
						if v605 then
							local v608 = CFrame.new(v_u_12.construct_pos.Position, v605)
							v_u_12.los_tripwire.Parent = l_CurrentCamera_0
							v_u_12.los_tripwire.CFrame = v608 + v608.LookVector * (v604 / 2)
							v_u_12.los_tripwire.Size = Vector3.new(0.1, 0.1, v604)
						else
							v_u_12.los_tripwire.Parent = nil
						end;
					else
						v_u_12.los_tripwire.Parent = nil
					end;
				end;
				v_u_12.construct_holo:PivotTo(v_u_12.construct_pos)
				if v_u_12.construct_holo == nil or (v598 ~= nil or (not v599 or (#v_u_12.construct_holo.bounding:GetTouchingParts() > 0 or #workspace:GetPartsInPart(v_u_12.construct_holo.bounding, v_u_31) > 0))) then
					for _, v609 in ipairs(v_u_12.construct_holo.finished:GetChildren()) do
						if v609:IsA("BasePart") then
							v609.Color = Color3.new(0.7, 0.2, 0.2)
						end;
					end;
					if v_u_12.los_tripwire then
						v_u_12.los_tripwire.Color = Color3.new(0.7, 0.2, 0.2)
					end;
					v_u_12.construct_ready = false
				else
					for _, v610 in ipairs(v_u_12.construct_holo.finished:GetChildren()) do
						if v610:IsA("BasePart") then
							v610.Color = Color3.new(0.9, 0.9, 0.9)
						end;
					end;
					if v_u_12.los_tripwire then
						v_u_12.los_tripwire.Color = Color3.new(0.9, 0.9, 0.9)
					end;
					v_u_12.construct_ready = true
				end;
			end;
		elseif v_u_12.construct_holo then
			l_core_checkers_0.check_ammo = 0
			v_u_12.construct_holo:Destroy()
			v_u_12.construct_holo = nil
			v_u_12.construct_pos = nil
			v_u_12.construct_ready = false
		end;
		if v_u_12.extra_bb or (v_u_7.tooltype == "firstaid" or v_u_7.tooltype == "stims") then
			local v611 = v_u_25
			if v_u_7.tooltype == "hammer" then
				v611 = v_u_23
			end;
			local v612 = v_u_1:raycastline({
				["point"] = l_CurrentCamera_0.CFrame.Position,
				["destination"] = l_CurrentCamera_0.CFrame.lookVector,
				["range"] = 10 + (l_CurrentCamera_0.CFrame.Position - l_Character_0.HumanoidRootPart.Position).Magnitude,
				["layermask"] = v611
			})
			if v_u_7.tooltype == "hammer" then
				local v613
				if v612 and (v612.Parent and (v612.Parent.Parent and (v612.Parent.Parent:FindFirstChild("core") and v612.Parent.Parent:FindFirstChild("health")))) then
					v612 = v612.Parent.Parent
					v613 = true
				else
					v613 = false
				end;
				if v613 and l_core_checkers_0.shift_locked == true then
					if v612.team.Value == l_LocalPlayer_0.Team and v612:FindFirstChild("health") then
						v_u_12.extra_bb.CFrame = v612.core.CFrame
						v_u_12.extra_bb.bb.user.Text = v612.owner.Value .. "\'s " .. v612.Name
						local v614 = v612.health.Value / v612.health.maxhealth.Value
						if v612.construction.Value < 100 then
							v614 = v612.construction.Value / 100
						end;
						v_u_12.extra_bb.bb.perc.Text = math.ceil(v614 * 100) .. "%"
						v_u_12.extra_bb.bb.bar.inner.Size = UDim2.new(v614, 0, 0.2, 0)
						v_u_12.extra_bb.bb.Enabled = true
					else
						v_u_12.extra_bb.bb.Enabled = false
					end;
				else
					v_u_12.extra_bb.bb.Enabled = false
				end;
			elseif v_u_7.tooltype == "firstaid" or v_u_7.tooltype == "stims" then
				if v612 and (v612.Parent:FindFirstChild("Humanoid") and (v612.Parent:FindFirstChild("chems") and (v612.Parent:FindFirstChild("Torso") and (v612.Parent.Humanoid.Health > 0 and v612.Parent.Parent == l_Character_0.Parent)))) then
					v_u_12.heal_target = v612.Parent
				else
					v_u_12.heal_target = nil
				end;
			end;
		end;
		if l_core_checkers_0.aiming == true and (tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier and l_core_checkers_0.jumped_air == false) then
			local v615 = true
			local v616 = l_Value_0 ~= "vanguardshield" or v_u_12.alt_mode ~= true
			if v_u_11.bipod_aim and (l_Parent_0:FindFirstChild("bipod") and tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier) then
				if tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer then
					v616 = false
					v615 = false
					if v_u_11.bipod_aim.IsPlaying == false then
						v_u_11.bipod_aim:Play(math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10), 1, 0.5)
					end;
				elseif v_u_11.bipod_aim.IsPlaying == true then
					v_u_11.bipod_aim:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
				end;
			end;
			if v_u_12.dual_wield_tool ~= nil then
				v615 = false
			end;
			if v_u_11.aim_left then
				if l_core_checkers_0.flip_cam == true and v615 == true then
					if tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
						if v_u_11.hipfire and v_u_11.hipfire.IsPlaying == true then
							v_u_11.hipfire:Stop(0.3)
						end;
						v616 = false
						if v_u_11.aim_left.IsPlaying == false then
							v_u_11.aim_left:Play(math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10), 1, 0.5)
						end;
						if l_Parent_0:FindFirstChild("left_aiming") then
							l_Parent_0.left_aiming.Value = true
						end;
						if v_u_11.aim.IsPlaying == true then
							v_u_11.aim:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
						end;
					end;
				else
					if v_u_11.aim_left.IsPlaying == true then
						v_u_11.aim_left:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
					end;
					if l_Parent_0:FindFirstChild("left_aiming") then
						l_Parent_0.left_aiming.Value = false
					end;
				end;
			end;
			if v_u_11.aim.IsPlaying == false and v616 == true then
				if v_u_11.hipfire then
					v_u_11.hipfire:Stop(0.3)
				end;
				v_u_11.aim:Play(math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10), 1, 0.5)
			end;
		else
			if l_Parent_0:FindFirstChild("left_aiming") then
				l_Parent_0.left_aiming.Value = false
			end;
			if v_u_11.aim.IsPlaying == true then
				v_u_11.aim:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
			end;
			if v_u_11.aim_left and v_u_11.aim_left.IsPlaying == true then
				v_u_11.aim_left:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
			end;
			if v_u_11.bipod_aim and v_u_11.bipod_aim.IsPlaying == true then
				v_u_11.bipod_aim:Stop((math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10)))
			end;
		end;
		local v617 = "sprint"
		local v618
		if l_LocalPlayer_0.Character:FindFirstChild("perk") and (l_LocalPlayer_0.Character.perk.Value == "sprinter" or l_LocalPlayer_0.Character:FindFirstChild("elitekit") and (l_LocalPlayer_0.Character.elitekit.Value == "jaeger" or l_LocalPlayer_0.Character.elitekit.Value == "soldat" and l_LocalPlayer_0.Character.class.Value == "soldat")) then
			v618 = 0.25
			if v_u_11.sprint_greyhound ~= nil then
				v617 = "sprint_greyhound"
			end;
		else
			v618 = 0.4
		end;
		if v_u_11[v617] then
			if l_core_checkers_0.sprinting == true and l_core_checkers_0.sprinting_max_speed == true then
				if v_u_11[v617].IsPlaying == false then
					v_u_11[v617]:Play(v618, 1, 0.8)
				end;
			elseif v_u_11[v617].IsPlaying == true then
				v_u_11[v617]:Stop(v618)
			end;
		end;
		if v_u_7.tooltype == "hammer" or (v_u_7.tooltype == "jaegerkit" or (v_u_7.tooltype == "stims" or (l_Parent_0:FindFirstChild("durability") or v_u_7.tooltype == "flamer"))) then
			local v619 = true
			if v_u_7.tooltype == "hammer" or v_u_7.tooltype == "jaegerkit" then
				if v_u_12.construction_mode == false then
					v619 = false
				end;
			end;
			if v619 == true and l_CurrentCamera_0:FindFirstChild("ammo_check") then
				local v620 = "Supplies"
				l_CurrentCamera_0.ammo_check.bg.Size = game.ReplicatedStorage.misc.ammo_check.bg.Size
				l_CurrentCamera_0.ammo_check.bg.walkertext.Visible = false
				l_CurrentCamera_0.ammo_check.bg.count.Visible = true
				l_CurrentCamera_0.ammo_check.bg.ammo.Visible = true
				local v621
				if l_Parent_0:FindFirstChild("durability") then
					v621 = math.floor(l_Parent_0.durability.Value / v_u_12.durability_max * 100) .. "%"
					l_CurrentCamera_0.ammo_check.bg.maxammo.inner.bar.Size = UDim2.new(1, 0, l_Parent_0.durability.Value / v_u_12.durability_max, 0)
					v620 = "Sharpness"
				elseif v_u_7.tooltype == "flamer" then
					v621 = math.floor(v_u_12.flamer_fuel / v_u_12.flamer_fuel_max * 100) .. "%"
					l_CurrentCamera_0.ammo_check.bg.maxammo.inner.bar.Size = UDim2.new(1, 0, v_u_12.flamer_fuel / v_u_12.flamer_fuel_max, 0)
					v620 = "Fuel"
				else
					v621 = l_Character_0.supplies.Value .. "/" .. l_Character_0.supplies.max.Value
					l_CurrentCamera_0.ammo_check.bg.maxammo.inner.bar.Size = UDim2.new(1, 0, l_Character_0.supplies.Value / l_Character_0.supplies.max.Value, 0)
				end;
				l_CurrentCamera_0.ammo_check.bg.ammo.Text = v621
				l_CurrentCamera_0.ammo_check.bg.count.Text = v620
				l_core_checkers_0.check_ammo = tick()
			end;
		end;
		if l_keysheld_0.m1 == true and (v_u_12.state == "reload" and (v_u_12.interrupt_reload == false and v_u_2.Value == true)) then
			v_u_12.interrupt_reload = true
		end;
		if tick() - v_u_12.fire_buffer <= 0.2 and (v_u_2.Value == false and (v_u_19.ammo_mag >= 1 or l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true)) and (l_core_checkers_0.queue_inv == nil and (v_u_12.construction_mode == false and (v_u_19.force_block_fire == false and tick() - v_u_12.draw > 0.5))) then
			v_u_317(v_u_12.fire_buffer_type)
		end;
	end;
end;
local v_u_623 = nil
local v_u_624 = nil
local function v639() --[[ Line: 9544 ]]
	--[[ Upvalues: (copy 1): l_CurrentCamera_0, (copy 2): l_LocalPlayer_0, (copy 3): v_u_1, (copy 4): v_u_24, (ref 5): v_u_28, (ref 6): v_u_48, (copy 7): l_Character_0, (copy 8): v_u_11, (copy 9): v_u_12, (ref 10): v_u_7, (copy 11): l_core_checkers_0, (copy 12): l_Value_1, (copy 13): v_u_26, (ref 14): v_u_590, (ref 15): l_Value_0, (copy 16): l_Parent_0, (ref 17): v_u_623, (ref 18): v_u_624, (copy 19): l_core_game_0, (ref 20): v_u_159, (ref 21): v_u_158, (copy 22): v_u_8, (ref 23): v_u_591 ]]
	local l_Position_0 = l_CurrentCamera_0.CFrame.Position
	if l_LocalPlayer_0.CameraMode ~= Enum.CameraMode.LockFirstPerson then
		l_Position_0 = l_CurrentCamera_0.CFrame.Position + l_CurrentCamera_0.CFrame.LookVector * 1
	end;
	local _, v625 = v_u_1:raycastline({
		["point"] = l_Position_0,
		["destination"] = l_CurrentCamera_0.CFrame.LookVector,
		["range"] = 500,
		["layermask"] = v_u_24
	})
	v_u_28 = v625
	if v_u_48 then
		v_u_48.warningbeam.Enabled = false
		v_u_48.x.Enabled = false
	end;
	if l_Character_0:FindFirstChild("execing") then
		if v_u_11.melee1 and v_u_11.melee1.IsPlaying == true then
			v_u_11.melee1:Stop(0)
		end;
		if v_u_11.melee2 and v_u_11.melee2.IsPlaying == true then
			v_u_11.melee2:Stop(0)
		end;
		if v_u_11.altmelee1 and v_u_11.altmelee1.IsPlaying == true then
			v_u_11.altmelee1:Stop(0)
		end;
		if v_u_11.altmelee2 and v_u_11.altmelee2.IsPlaying == true then
			v_u_11.altmelee2:Stop(0)
		end;
		if v_u_11.melee_alt1 and v_u_11.melee_alt1.IsPlaying == true then
			v_u_11.melee_alt1:Stop(0)
		end;
		if v_u_11.melee_alt2 and v_u_11.melee_alt2.IsPlaying == true then
			v_u_11.melee_alt2:Stop(0)
		end;
		if v_u_11.charge and v_u_11.charge.IsPlaying == true then
			v_u_11.charge:Stop(0)
		end;
		if v_u_11.charge_stop and v_u_11.charge_stop.IsPlaying == true then
			v_u_11.charge_stop:Stop(0)
		end;
	end;
	if v_u_12.equipped ~= false or v_u_12.dual_wield_active ~= false then
		if tick() - v_u_12.draw < v_u_7.draw_speed / l_core_checkers_0.draw_modifier then
			l_core_checkers_0.aim_time = tick()
			v_u_12.aim_sound = false
		end;
		if v_u_11.short and v_u_7.length > 0 then
			if l_core_checkers_0.aiming == true and (l_Value_1:FindFirstChild("hitbox") and (tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier and (v_u_12.state ~= "reload" and v_u_12.state ~= "cycling"))) then
				local v626 = v_u_26
				local v627, v628 = v_u_1:raycastline({
					["point"] = l_Character_0.Head.Position - l_Character_0.Head.CFrame.lookVector + l_Character_0.HumanoidRootPart.CFrame.rightVector * (l_Character_0.HumanoidRootPart.CFrame:ToObjectSpace(l_Value_1.hitbox.CFrame).Position.X / 3),
					["destination"] = l_CurrentCamera_0.CFrame.LookVector,
					["range"] = v_u_7.length,
					["layermask"] = v626
				})
				local v629
				if workspace.serverStuff.trainingmode.Value == true then
					local v630 = l_Value_1.special.muzzle.CFrame - l_Value_1.special.muzzle.CFrame.lookVector * v_u_7.length
					local v631
					v629, v631 = v_u_1:raycastline({
						["point"] = v630.Position,
						["destination"] = CFrame.new(v630.Position, v_u_28).LookVector,
						["range"] = 500,
						["layermask"] = v626
					})
					if not v629 or (not v629.Parent or (not v629.Parent:FindFirstChild("Humanoid") or (not v629.Parent:FindFirstChild("rank") or v629.Parent:FindFirstChild("enemy") ~= nil))) then
						v629 = v627
					end;
				else
					v629 = v627
				end;
				if v629 or l_core_checkers_0.jumped_air == true then
					if v629 then
						v_u_590 = 1 - (l_Character_0.HumanoidRootPart.Position - v628).magnitude / v_u_7.length + 0.4
					else
						v_u_590 = 1
					end;
					v_u_12.shorted = true
				else
					v_u_12.shorted = false
				end;
			else
				v_u_12.shorted = false
			end;
			if v_u_12.shorted == true then
				local l_short_0 = v_u_11.short
				local v632
				if v_u_11.short_alt and l_Character_0["Left Arm"]:FindFirstChild(l_Value_0 .. l_Parent_0.slot.Value) then
					l_short_0 = v_u_11.short_alt
					v632 = v_u_11.short
				else
					v632 = nil
				end;
				if l_short_0.IsPlaying == false then
					l_short_0:Play(0.1, math.clamp(v_u_590, 0, 1), 0.5)
				end;
				l_short_0:AdjustWeight((math.clamp(v_u_590, 0, 1)))
				if v632 and v632.IsPlaying == true then
					v632:Stop(0.1)
				end;
			else
				if v_u_11.short.IsPlaying == true then
					v_u_11.short:Stop(0.1)
				end;
				if v_u_11.short_alt and v_u_11.short_alt.IsPlaying == true then
					v_u_11.short_alt:Stop(0.1)
				end;
			end;
		end;
		l_core_checkers_0.gun_crosshair = false
		v_u_623 = nil
		v_u_624 = nil
		if l_core_game_0.crosshair.Visible == true then
			local l_crosshair_0 = l_core_game_0.crosshair
			local v633 = v_u_12.dual_wield_tool == nil
			if l_Parent_0:FindFirstChild("akimbo") then
				v633 = true
				if v_u_12.dual_wield_active == true then
					l_crosshair_0 = l_core_game_0.akimbocrosshair
				end;
			end;
			if tick() - v_u_159 >= 0.03 then
				v_u_158 = 0
			else
				v_u_158 = 40
			end;
			if v_u_12.aim_sound == false and (tick() - l_core_checkers_0.aim_time > math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10) and (v_u_7.tooltype == "gun" or v_u_7.tooltype == "launcher")) then
				v_u_12.aim_sound = true
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "aimed",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
			end;
			if (v_u_7.tooltype == "gun" or (v_u_7.tooltype == "launcher" or v_u_12.dual_wield_tool ~= nil)) and (v_u_12.shorted == false and (v_u_12.state ~= "reload" and (v_u_12.state ~= "walker_reload" and (tick() - l_core_checkers_0.aim_time > math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10) and (tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier and l_core_checkers_0.charging == false))))) then
				l_core_checkers_0.gun_crosshair = true
			end;
			local l_accuracy_0 = v_u_7.accuracy
			if tick() - l_core_checkers_0.moving_accuracy >= 0 or l_core_checkers_0.in_air == true then
				l_accuracy_0 = v_u_7.moving_accuracy
			end;
			local l_pellets_1 = v_u_7.pellets
			local v634 = l_Parent_0:FindFirstChild("bipod") and (tick() - l_Parent_0.bipod.Value <= v_u_8.bulwark_buffer and (tick() - l_core_checkers_0.moving_accuracy < 0 and l_core_checkers_0.in_air == false)) and 2 or l_accuracy_0
			if (v_u_7.tooltype == "gun" or v_u_7.tooltype == "launcher") and l_pellets_1 == 1 then
				v634 = v634 / l_core_checkers_0.accuracy_modifier
			end;
			local v635 = math.clamp((l_Parent_0:FindFirstChild("scoped") and l_Parent_0.scoped.Value == true and 0 or (l_core_checkers_0.holding_breath == true and (tick() - l_core_checkers_0.hold_breathtime >= l_core_checkers_0.hold_breathaccuracy and (l_pellets_1 == 1 and v_u_12.no_steady_acc == false)) and 0 or v634)) * 1.1, 0, 200)
			if v_u_7.tooltype == "gun" and l_pellets_1 > 1 then
				v635 = math.clamp(v635 * 0.7, 0, 200)
			end;
			v_u_591 = v_u_1:lerp(v_u_591, (l_Value_0 == "saa" and (l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "ocelot") and 0 or (l_Value_0 == "enfield" and v_u_12.alt_mode == true and 0 or v635)) + v_u_158, 0.3)
			if v633 == true then
				l_crosshair_0.Size = UDim2.new(0, 1, 0, 1)
				l_crosshair_0.main.Size = UDim2.new(0, v_u_591, 0, v_u_591)
			end;
			if v_u_48 and (l_Parent_0:FindFirstChild("mounted_weapon") == nil and (v_u_7.tooltype == "gun" and (v_u_12.shorted == false and (v_u_12.state ~= "reload" and (tick() - l_core_checkers_0.aim_time > math.clamp(v_u_7.aim_speed / l_core_checkers_0.handling_modifier, 0.125, 10) and (tick() - v_u_12.draw > v_u_7.draw_speed / l_core_checkers_0.draw_modifier and (l_Value_1 and (l_Value_1:FindFirstChild("special") and (l_Value_1.special:FindFirstChild("muzzle") and v_u_28))))))))) then
				local v636 = l_Value_1.special.muzzle.CFrame - l_Value_1.special.muzzle.CFrame.lookVector * v_u_7.length
				local v637, v638 = v_u_1:raycastline({
					["point"] = v636.Position,
					["destination"] = CFrame.new(v636.Position, v_u_28).LookVector,
					["range"] = _G.get_settings("longrangeobstruction") == true and 200 or v_u_7.length + 7,
					["layermask"] = v_u_26
				})
				v_u_623 = v637
				v_u_624 = v638
			end;
		else
			v_u_12.aim_sound = false
			v_u_158 = 0
		end;
		if v_u_48 and (_G.get_settings("disableobstruction") ~= true and workspace.serverStuff.trainingmode.Value == false) then
			if v_u_623 then
				v_u_48.CFrame = CFrame.new(v_u_624)
				if _G.get_settings("laserobstruction") == true then
					v_u_48.warningbeam.Enabled = true
				end;
				v_u_48.x.Enabled = true
				return;
			end;
			v_u_48.x.Enabled = false
			v_u_48.warningbeam.Enabled = false
		end;
	end;
end;
local function v_u_641(p640) --[[ Line: 9828 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): v_u_2, (copy 3): l_core_checkers_0, (ref 4): v_u_317 ]]
	if v_u_12.dropped ~= true then
		if v_u_12.construction_mode == false and (tick() - v_u_12.draw > 0.5 and (v_u_2.Value == true and (l_core_checkers_0.queue_inv == nil and v_u_12.state ~= "reload"))) then
			v_u_12.fire_buffer = tick()
			if p640 == true then
				v_u_12.fire_buffer_type = true
			else
				v_u_12.fire_buffer_type = false
			end;
		end;
		v_u_317(p640)
	end;
end;
s_UserInputService_0.InputBegan:Connect(function(p642, p643) --[[ Line: 9843 ]]
	--[[ Upvalues: (copy 1): v_u_12, (copy 2): l_Character_0, (copy 3): l_core_game_0, (copy 4): s_UserInputService_0, (copy 5): l_Parent_0, (copy 6): v_u_641, (ref 7): v_u_181, (ref 8): l_Value_0, (copy 9): v_u_1, (copy 10): l_core_checkers_0, (copy 11): v_u_2, (copy 12): v_u_11, (copy 13): l_remotes_0, (copy 14): v_u_9, (ref 15): v_u_7, (copy 16): v_u_303, (copy 17): l_RenderStepped_0, (ref 18): l_construct_constructions_0, (copy 19): l_LocalPlayer_0, (copy 20): v_u_320, (copy 21): v_u_4, (ref 22): v_u_10, (copy 23): l_Value_1, (ref 24): v_u_19, (copy 25): v_u_180, (copy 26): v_u_313, (copy 27): v_u_318, (copy 28): v_u_560, (copy 29): v_u_3, (copy 30): v_u_304 ]]
	if p643 == true then
		return;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if l_Character_0:FindFirstChild("exec") then
		return;
	end;
	if l_Character_0:FindFirstChild("execing") then
		return;
	end;
	if l_core_game_0.Parent.loadout_menu.Visible == true then
		return;
	end;
	if v_u_12.equipped == false then
		return;
	end;
	if (p642.UserInputType == Enum.UserInputType.MouseButton2 or p642.KeyCode == Enum.KeyCode.ButtonL2) and (s_UserInputService_0.MouseBehavior == Enum.MouseBehavior.LockCenter and (l_Parent_0:FindFirstChild("akimbo_aiming") and l_Parent_0.akimbo_aiming.Value == true)) then
		v_u_641(true)
	end;
	if p642.KeyCode then
		if p642.KeyCode == _G.get_keybinds("reload") then
			v_u_181 = tick()
			if l_Value_0 == "vanguardshield" and v_u_12.alt_mode == true then
				if not (l_Parent_0:FindFirstChild("client_inactive") or l_Parent_0:FindFirstChild("inactive")) then
					local l_StringValue_10 = Instance.new("StringValue")
					game:GetService("Debris"):AddItem(l_StringValue_10, 30)
					l_StringValue_10.Name = "client_inactive"
					l_StringValue_10.Parent = l_Parent_0
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "shield_prep",
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "belt1",
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					delay(0.2, function() --[[ Line: 9901 ]]
						--[[ Upvalues: (ref 1): v_u_1, (ref 2): l_Value_0, (ref 3): l_Character_0 ]]
						v_u_1:soundHandler({
							["directory"] = {},
							["soundfile"] = "belt2",
							["pitchvariation"] = 0.1,
							["location"] = l_Character_0.HumanoidRootPart
						})
					end)
					l_core_checkers_0.inv_swapping = true
					l_core_checkers_0.inv_block_reason = ""
					v_u_2.Value = true
					v_u_11.shield_plant:Play(0.1, 1, 1)
					v_u_1:s_wait(1)
					l_remotes_0.interaction_handler:FireServer(l_Parent_0, "vanguard_plantshield")
					v_u_2.Value = false
					v_u_9:UnequipTools()
				end;
			end;
			if v_u_7.tooltype == "gun" or v_u_7.tooltype == "launcher" then
				v_u_303()
			elseif v_u_12.dual_wield_tool == nil then
				if v_u_7.tooltype == "hammer" or v_u_7.tooltype == "jaegerkit" then
					if v_u_2.Value == true or l_core_checkers_0.aiming == true then
						if l_core_game_0.selectionboxes.Visible == true then
							l_core_game_0.selectionboxes.Visible = false
							l_core_checkers_0.selection_box_selected = "none"
						end;
						return;
					end;
					v_u_2.Value = true
					l_core_checkers_0.selection_box_selected = ""
					l_core_checkers_0.display_selections(v_u_12.construct_constructions)
					repeat
						l_RenderStepped_0:wait()
					until l_core_checkers_0.selection_box_selected ~= "" or (l_core_checkers_0.aiming == true or l_core_checkers_0.queue_inv ~= nil);
					if l_core_checkers_0.aiming == true or l_core_checkers_0.queue_inv ~= nil then
						l_core_checkers_0.selection_box_selected = "none"
					end;
					if l_core_checkers_0.selection_box_selected ~= "none" then
						v_u_12.constructing = l_core_checkers_0.selection_box_selected
						l_construct_constructions_0 = v_u_12.constructing
						if v_u_12.construct_holo then
							v_u_12.construct_holo:Destroy()
							v_u_12.construct_holo = nil
						end;
						if v_u_7.tooltype == "jaegerkit" then
							local v644 = 0
							for _, v645 in ipairs(workspace.constructions:GetChildren()) do
								if v645:FindFirstChild("owner") and (v645:FindFirstChild("health") and (v645.health.Value > 0 and (v645.owner.Value == l_LocalPlayer_0.Name and v645.Name == v_u_12.constructing))) then
									v644 = v644 + 1
								end;
							end;
							if v644 >= 2 then
								_G.popupmsg("max" .. v_u_12.constructing, "I already have the maximum number of " .. v_u_12.constructing .. "s deployed.", 2)
							end;
						end;
					end;
					l_core_game_0.selectionboxes.Visible = false
					l_core_checkers_0.selection_box_selected = ""
					v_u_2.Value = false
				elseif l_Value_0 == "pickaxe" then
					if v_u_2.Value == true then
						return;
					end;
					if v_u_12.sharpening_stones <= 0 then
						_G.popupmsg("nosharpenstone", "I don\'t have any Sharpening Stones left.", 2)
						return;
					end;
					if l_Parent_0.durability.Value == v_u_12.durability_max then
						_G.popupmsg("maxsharp", "My Pick is already as sharp as it gets.", 2)
						return;
					end;
					local v646 = v_u_12
					v646.sharpening_stones = v646.sharpening_stones - 1
					v_u_2.Value = true
					v_u_11.sharpen:Play(0.1, 1, 0.75)
					v_u_1:s_wait(2.2)
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "finishsharpen",
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					l_Parent_0.durability.Value = v_u_12.durability_max
					v_u_1:s_wait(0.8)
					v_u_2.Value = false
				elseif v_u_7.tooltype == "binocs" then
					if l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" then
						return;
					end;
					if l_core_checkers_0.aiming == false then
						v_u_320()
					end;
				elseif v_u_7.tooltype == "stims" then
					if v_u_12.alt_mode == true then
						spawn(function() --[[ Line: 10040 ]]
							--[[ Upvalues: (ref 1): v_u_4, (ref 2): l_Value_0, (ref 3): v_u_10, (ref 4): l_Character_0, (ref 5): l_Value_1, (ref 6): v_u_7, (ref 7): v_u_19 ]]
							local v647 = v_u_4
							local v648 = "stimbottle_dispose"
							local v649 = {}
							local v650 = l_Value_0
							if v_u_10 ~= "" then
								v650 = v_u_10
							end;
							v649.main = {
								["char"] = l_Character_0,
								["originweapon"] = v650,
								["weapon"] = l_Value_0,
								["model"] = l_Value_1,
								["module"] = v_u_7,
								["core"] = v_u_19
							}
							v647(v648, v649)
						end)
						l_core_checkers_0.inv_swapping = false
						v_u_2.Value = true
						v_u_12.alt_mode = false
						v_u_11.new:Play(0.1, 1, 1.5)
						v_u_1:s_wait(0.75)
						v_u_2.Value = false
						v_u_19.stim_content = {}
						l_core_checkers_0.inv_swapping = true
					else
						_G.popupmsg("nostimloaded", "No Stimulants are loaded, press " .. _G.get_keybinds("alt").Name .. " to load.", 2)
					end;
				end;
			else
				if v_u_2.Value == true then
					return;
				end;
				if v_u_12.dual_wield_tool ~= nil then
					if l_core_checkers_0.inv_swapping ~= true then
						if l_core_checkers_0.inv_block_reason ~= "" then
							_G.popupmsg("block_warning", l_core_checkers_0.inv_block_reason, 1)
						end;
						return;
					end;
					v_u_12.dual_wield_tool.event:Fire("reload_weapon_swap")
				end;
			end;
		end;
		if p642.KeyCode == _G.get_keybinds("dropweapon") and (v_u_7.tooltype == "gun" and (v_u_2.Value == true and v_u_12.state == "reload")) then
			v_u_180()
			return;
		end;
		if p642.KeyCode == _G.get_keybinds("checkammo") then
			if v_u_7.tooltype == "gun" then
				v_u_313()
			elseif v_u_7.tooltype == "hammer" then
				if v_u_12.construction_mode == true then
					if tick() - v_u_12.construct_cd <= 0.5 then
						return;
					end;
					if v_u_12.confirm_construct == nil then
						v_u_12.confirm_construct = 0
					end;
					if tick() - v_u_12.confirm_construct > 5 then
						v_u_12.confirm_construct = tick()
						_G.popupmsg("construct_confirmdestroy", "Confirm destruction of all Constructs?", 2)
					else
						v_u_12.construct_cd = tick()
						local v651 = {}
						for _, v652 in ipairs(workspace.constructions:GetChildren()) do
							if v652:FindFirstChild("owner") and (v652:FindFirstChild("health") and (v652.health.Value > 0 and (v652.owner.Value == l_LocalPlayer_0.Name and v652.Name == v_u_12.constructing))) then
								table.insert(v651, v652)
							end;
						end;
						local l_constructing_0 = v_u_12.constructing
						if l_constructing_0 ~= "Sandbags" then
							l_constructing_0 = l_constructing_0 .. "s"
						end;
						if #v651 >= 1 then
							_G.popupmsg("construct_destroy", "I\'ve destroyed " .. #v651 .. " " .. l_constructing_0, 2)
							l_remotes_0.construction_handler:FireServer("destroy_all", v_u_12.constructing)
							for _, v653 in ipairs(v651) do
								if v653.Name == v_u_12.constructing and (v653:FindFirstChild("owner") and v653.owner.Value == l_LocalPlayer_0.Name) then
									v653:Destroy()
								end;
							end;
						else
							_G.popupmsg("construct_nodestroy", "I have no " .. l_constructing_0 .. " to Destroy.", 2)
						end;
					end;
				end;
			elseif v_u_7.tooltype == "binocs" then
				if l_Character_0:FindFirstChild("class") and l_Character_0.class.Value == "conscript" then
					return;
				end;
				if l_core_checkers_0.aiming == false then
					v_u_318()
				end;
			elseif v_u_7.tooltype == "whistle" then
				if _G.whistle_long == false then
					_G.whistle_long = true
					_G.popupmsg("orderlong" .. math.random(1, 100), "Issued order will be Long.", 1)
				else
					_G.whistle_long = false
					_G.popupmsg("orderlong" .. math.random(1, 100), "Issued order will be Short.", 1)
				end;
			elseif v_u_7.tooltype == "shield" then
				if v_u_2.Value == true then
					return;
				end;
				if l_Parent_0:FindFirstChild("shield_supplies") and l_Parent_0.shield_supplies.Value <= 0 then
					_G.popupmsg("repairlack", "I don\'t have the supplies for a Repair right now.", 2)
					return;
				end;
				if l_Value_1:FindFirstChild("special") and (l_Value_1.special:FindFirstChild("leftshield") and (l_Value_1.special:FindFirstChild("rightshield") and (l_Value_1.special:FindFirstChild("topshield") and l_Parent_0:FindFirstChild("shield_supplies")))) then
					local v654 = { l_Value_1.special.topshield, l_Value_1.special.rightshield, l_Value_1.special.leftshield }
					table.sort(v654, function(p655, p656) --[[ Line: 10237 ]]
						return p655.health.Value < p656.health.Value;
					end)
					local v657 = false
					local v658 = {}
					for v659 = 1, 3 do
						local v660 = v654[v659]
						if v660:FindFirstChild("health") and v660.health.Value < v660.health.max.Value then
							v657 = true
							break;
						end;
					end;
					if v657 == false then
						_G.popupmsg("repairstag", "My Shield does not need any repairs.", 2)
						return;
					end;
					if v_u_12.alt_mode == true then
						v_u_560()
						if v_u_2.Value == true then
							return;
						end;
					end;
					v_u_1:soundHandler({
						["directory"] = {},
						["soundfile"] = "reloadstart",
						["pitchvariation"] = 0.1,
						["location"] = l_Character_0.HumanoidRootPart
					})
					v_u_2.Value = true
					for v661 = 1, 3 do
						local v662 = v654[v661]
						if v662:FindFirstChild("health") and ((v662.Name ~= "topshield" and 0 or v662.health.max.Value) > v662.health.Value and v662:FindFirstChild("damagepart")) then
							if v662.damagepart.Transparency == 0 then
								v_u_1:soundHandler({
									["directory"] = {},
									["soundfile"] = "shield_shuffle" .. math.random(1, 3),
									["pitchvariation"] = 0.1,
									["location"] = l_Character_0.HumanoidRootPart
								})
								v_u_11["remove_" .. v662.Name]:Play(0.1, 1, 1)
								v_u_1:s_wait(0.5)
								v_u_1:soundHandler({
									["directory"] = {},
									["soundfile"] = "metal_detach",
									["pitchvariation"] = 0.1,
									["location"] = l_Character_0.HumanoidRootPart
								})
								v_u_3("fake_shield_parts", {
									["part"] = v662,
									["transp"] = 1
								})
								l_remotes_0.interaction_handler:FireServer(l_Parent_0, "remove_vanguardshield", v662)
								v_u_1:s_wait(0.5)
							end;
							table.insert(v658, v662)
							local l_shield_supplies_0 = l_Parent_0.shield_supplies
							l_shield_supplies_0.Value = l_shield_supplies_0.Value - 1
							if l_Parent_0.shield_supplies.Value <= 0 then
								break;
							end;
						end;
					end;
					for v663 = 1, #v658 do
						local v664 = v658[v663]
						if v664:FindFirstChild("health") and (v664:FindFirstChild("part") and v664.damagepart.Transparency == 1) then
							v_u_1:soundHandler({
								["directory"] = {},
								["soundfile"] = "shield_prep",
								["pitchvariation"] = 0.1,
								["location"] = l_Character_0.HumanoidRootPart
							})
							v_u_11["replace_" .. v664.Name]:Play(0.1, 1, 1)
							v_u_1:s_wait(0.1)
							v_u_3("fake_shield_parts", {
								["part"] = v664,
								["transp"] = 0
							})
							v_u_1:s_wait(0.4)
							v_u_1:soundHandler({
								["directory"] = {},
								["soundfile"] = "shield_repair",
								["pitchvariation"] = 0.1,
								["location"] = l_Character_0.HumanoidRootPart
							})
							l_remotes_0.interaction_handler:FireServer(l_Parent_0, "replace_vanguardshield", v664)
							v_u_1:s_wait(0.5)
						end;
					end;
				end;
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "reloadend",
					["pitchvariation"] = 0.1,
					["location"] = l_Character_0.HumanoidRootPart
				})
				v_u_2.Value = false
			elseif v_u_7.tooltype == "stims" and v_u_2.Value == false then
				v_u_11.checkstim:Play(0.1, 1, 1)
				v_u_2.Value = true
				if v_u_19.stim_content == nil or #v_u_19.stim_content <= 0 then
					_G.popupmsg("stimdesc", "No Stimulants filled.", 1.5)
				else
					local v665 = {}
					for _, v666 in ipairs(v_u_19.stim_content) do
						if v665[v666] then
							v665[v666] = v665[v666] + 1
						else
							v665[v666] = 1
						end;
					end;
					for v667, v668 in pairs(v665) do
						local l_stimulants_0 = v_u_12.stimulants[v667]
						_G.popupmsg("stimchecking" .. math.random(1, 100), v668 * 10 .. "u " .. l_stimulants_0.name .. ": " .. l_stimulants_0.desc, 1.5)
					end;
				end;
				v_u_1:s_wait(1)
				v_u_2.Value = false
			elseif v_u_7.tooltype == "throwaxe" and (v_u_2.Value == false and l_Parent_0:FindFirstChild("use_count")) then
				v_u_11.checkaxes:Play(0.1, 1, 1)
				v_u_2.Value = true
				if l_Parent_0.use_count.Value == 1 then
					_G.popupmsg("checkaxes", "One Axe remaining.", 1.5)
				else
					_G.popupmsg("checkaxes", v_u_304[l_Parent_0.use_count.Value] .. " Axes left.", 1.5)
				end;
				v_u_1:s_wait(1)
				v_u_2.Value = false
			elseif v_u_7.tooltype == "firstaid" and v_u_2.Value == false then
				v_u_11.checkhealth:Play(0.1, 1, 1)
				v_u_2.Value = true
				local v669 = "I\'m all good."
				local v670 = {
					"I\'m fine, just slightly in pain.",
					"I\'m hurt, but I\'ll recover.",
					"I\'m injured and need Surgery.",
					"I\'m heavily wounded, I really need Surgery."
				}
				local v671 = {
					200,
					150,
					100,
					50
				}
				if l_Character_0.perk.Value == "healing" then
					v670 = {
						"I\'m fine.",
						"I\'m hurt.",
						"I\'m injured. Need Surgery.",
						"Need Surgery immediately."
					}
					v669 = "I\'m healthy."
				elseif l_Character_0:FindFirstChild("elitekit") then
					v671 = {
						300,
						200,
						150,
						100,
						50
					}
					v670 = {
						"I\'m good enough.",
						"I\'m fine, just slightly in pain.",
						"I\'m hurt, but I\'ll recover.",
						"I\'m injured and need Surgery.",
						"I\'m heavily wounded, I really need Surgery."
					}
				end;
				for v672 = 1, #v671 do
					if v_u_9.Health < v671[v672] then
						v669 = v670[v672]
					end;
				end;
				if l_core_checkers_0.sick == true then
					if l_Character_0.chems:FindFirstChild("int") then
						v669 = l_Character_0.perk.Value == "healing" and "Poisoned. Need a Cure immediately." or "I\'m feeling horribly sick and I need a Cure right now."
					else
						v669 = l_Character_0.perk.Value == "healing" and "I\'m sick. Need a Cure." or "I\'m feeling sick right now."
					end;
				elseif l_Character_0.perk.Value == "healing" then
					v669 = v669 .. " (" .. math.ceil(v_u_9.Health) .. "ml)"
				end;
				_G.popupmsg("healthstate" .. math.random(1, 100), v669, 1.5)
				local v673 = l_Character_0.chems:GetChildren()
				local v674
				if #v673 > 0 then
					local v675 = {}
					local v676 = {}
					for _, v677 in ipairs(v673) do
						if v675[v677.Name] == nil then
							v675[v677.Name] = 1
							v676[v677.Name] = math.ceil(v677:GetAttribute("TickTimeLeft") or (v677:GetAttribute("Duration") or 0))
						else
							local l_Name_0 = v677.Name
							v675[l_Name_0] = v675[l_Name_0] + 1
							local l_Name_1 = v677.Name
							v676[l_Name_1] = v676[l_Name_1] + math.ceil(v677:GetAttribute("Duration") or 0)
						end;
					end;
					local v678 = 0
					local v679 = 0
					v674 = ""
					for _, _ in pairs(v675) do
						v678 = v678 + 1
					end;
					for v680, v681 in pairs(v675) do
						v679 = v679 + 1
						local l_stimulants_1 = v_u_12.stimulants[v680]
						if l_stimulants_1 then
							local v682 = v681 * 10 .. "u " .. l_stimulants_1.name
							if l_Character_0:FindFirstChild("perk") and l_Character_0.perk.Value == "healing" then
								v682 = v682 .. " (" .. v676[v680] .. "s)"
							end;
							local v683
							if v678 <= v679 then
								v683 = v682 .. "."
							else
								v683 = v682 .. ", "
							end;
							v674 = v674 .. v683
						end;
					end;
				else
					v674 = "Clean bloodstream."
				end;
				_G.popupmsg("chemstate" .. math.random(1, 100), v674, 1.5)
				v_u_1:s_wait(1)
				v_u_2.Value = false
			elseif l_Value_0 == "lance" and v_u_2.Value == false then
				v_u_2.Value = true
				if l_LocalPlayer_0.Character:FindFirstChild("flagwave_cd") == nil then
					l_remotes_0.interaction_handler:FireServer(l_Parent_0, "flagwave")
					local l_StringValue_11 = Instance.new("StringValue")
					game:GetService("Debris"):AddItem(l_StringValue_11, 15)
					l_StringValue_11.Name = "flagwave_cd"
					l_StringValue_11.Parent = l_Character_0
				else
					_G.popupmsg("flagcd", "My flag is not effective right now.", 1)
				end;
				v_u_1:soundHandler({
					["directory"] = {},
					["soundfile"] = "flag" .. math.random(1, 2),
					["location"] = l_Character_0.HumanoidRootPart
				})
				v_u_11.raise_flag:Play(0.2, 1, 1)
				v_u_1:s_wait(2.5)
				v_u_2.Value = false
			end;
		end;
		if p642.KeyCode == _G.get_keybinds("alt") then
			v_u_560()
			if v_u_2.Value == true and l_core_game_0.selectionboxes.Visible == true then
				l_core_game_0.selectionboxes.Visible = false
				l_core_checkers_0.selection_box_selected = "none"
			end;
		end;
	end;
end)
l_Parent_0.Activated:Connect(v_u_641)
l_Parent_0.Equipped:Connect(function() --[[ Line: 10557 ]]
	--[[ Upvalues: (ref 1): v_u_5, (copy 2): l_Character_0, (copy 3): v_u_12, (copy 4): l_LocalPlayer_0, (copy 5): v_u_3, (ref 6): v_u_28, (ref 7): v_u_29, (copy 8): l_core_checkers_0, (ref 9): l_Value_0, (copy 10): v_u_2, (copy 11): l_CurrentCamera_0, (ref 12): v_u_7, (copy 13): l_core_game_0, (copy 14): l_Parent_0, (ref 15): v_u_10, (copy 16): v_u_1, (copy 17): v_u_4, (copy 18): l_Value_1, (ref 19): v_u_19, (copy 20): l_remotes_0, (copy 21): v_u_11, (copy 22): v_u_359, (copy 23): l_RenderStepped_0 ]]
	if v_u_5 == true then
		return;
	end;
	if l_Character_0 == nil or l_Character_0:FindFirstChild("HumanoidRootPart") == nil then
		return;
	end;
	if v_u_12.dropped == true then
		return;
	end;
	if workspace.throwables:FindFirstChild(l_LocalPlayer_0.Name .. "_compass") then
		v_u_3("destroy_compasses", {
			["char"] = l_Character_0
		})
	end;
	v_u_28 = nil
	v_u_29 = nil
	l_core_checkers_0.aim_time = tick()
	v_u_12.draw = tick()
	if l_Character_0 and (l_Character_0:FindFirstChild("perk") and (l_Character_0.perk.Value == "tunnelrat" and (l_Value_0 == "pick" or l_Value_0 == "pickaxe"))) then
		v_u_12.draw = 0
	end;
	v_u_12.equipped = true
	v_u_2.Value = false
	if l_CurrentCamera_0:FindFirstChild("ammo_check") then
		l_CurrentCamera_0.ammo_check.bg.maxammo.Visible = true
	end;
	local l_Action3_0 = Enum.AnimationPriority.Action3
	local l_name_0 = v_u_7.name
	if v_u_7.alt_name and l_LocalPlayer_0.Team == game.Teams["Royal Nation"] then
		l_name_0 = v_u_7.alt_name
	end;
	l_core_game_0.inventoryitemname.item.Text = l_name_0
	local v684 = l_core_game_0.inventory:FindFirstChild(l_Value_0 .. l_Parent_0.slot.Value) or l_core_game_0.inventory:FindFirstChild(v_u_10 .. l_Parent_0.slot.Value)
	if v684 then
		l_core_checkers_0.inventory_display = tick()
		v684.line.BackgroundColor3 = Color3.new(1, 1, 1)
		v684.icon.ImageColor3 = Color3.new(1, 1, 1)
		v684.num.TextColor3 = Color3.new(1, 1, 1)
	end;
	l_core_checkers_0.speed_mod = v_u_7.movement
	v_u_1:soundHandler({
		["directory"] = {},
		["soundfile"] = "draw",
		["force_max_dist"] = l_Character_0:FindFirstChild("elitekit") and l_Character_0.elitekit.Value == "jaeger" and 5 or nil,
		["pitchvariation"] = 0.1,
		["location"] = l_Character_0.HumanoidRootPart
	})
	local v685 = v_u_4
	local v686 = "weapon_visibility"
	local v687 = {}
	local v688 = l_Value_0
	if v_u_10 ~= "" then
		v688 = v_u_10
	end;
	v687.main = {
		["char"] = l_Character_0,
		["originweapon"] = v688,
		["weapon"] = l_Value_0,
		["model"] = l_Value_1,
		["module"] = v_u_7,
		["core"] = v_u_19
	}
	v687.slot = l_Parent_0.slot.Value
	v687.state = "equip"
	v685(v686, v687, true)
	l_remotes_0.game_handler:FireServer("weapon_visibility", {
		["wep"] = l_Parent_0,
		["state"] = "equip"
	})
	if l_Value_0 == "henry" and (l_Character_0.perk.Value == "vet" and v_u_12.alt_mode == false) then
		local v689 = v_u_4
		local v690 = "henry_offhandround"
		local v691 = {}
		local v692 = l_Value_0
		if v_u_10 ~= "" then
			v692 = v_u_10
		end;
		v691.main = {
			["char"] = l_Character_0,
			["originweapon"] = v692,
			["weapon"] = l_Value_0,
			["model"] = l_Value_1,
			["module"] = v_u_7,
			["core"] = v_u_19
		}
		v691.visibility = true
		v689(v690, v691)
	end;
	if l_Parent_0:FindFirstChild("akimbo") and l_Parent_0.akimbo.Value == true then
		l_Parent_0.akimbo.Value = false
	end;
	if l_Value_0 == "vanguardshield" or l_Value_0 == "cavsword" and l_Parent_0.slot.Value == 1 or v_u_7.size == 1 and (v_u_7.tooltype == "gun" and (l_Character_0:FindFirstChild("perk") and (l_Character_0.perk.Value == "akimbo" and l_Parent_0:FindFirstChild("akimbo")))) then
		local v693 = 2
		if l_Parent_0:FindFirstChild("akimbo_aiming") then
			l_Parent_0.akimbo_aiming.Value = false
			v693 = l_Parent_0:FindFirstChild("slot") and l_Parent_0.slot.Value == 2 and 1 or v693
		end;
		v_u_12.dual_wield_tool = nil
		if v_u_12.dual_wield_tool == nil then
			local v694 = l_Value_0
			if v_u_10 ~= "" then
				v694 = v_u_10
			end;
			v_u_7 = v_u_1:deepCopy(require(game.ReplicatedStorage.weapon_modules:FindFirstChild(v694)))
			for _, v695 in ipairs(l_LocalPlayer_0.Backpack:GetChildren()) do
				if v695:FindFirstChild("slot") and (v695.slot.Value == v693 and v695.Name ~= "empty") then
					if (v695.weapon.Value == "cavsword" and (v695:FindFirstChild("inactive") == nil and (v695:FindFirstChild("client_inactive") == nil and l_Value_0 == "vanguardshield")) and true or (v695:FindFirstChild("pistol") and (v695.pistol.Value == true and (v695:FindFirstChild("inactive") == nil and v695:FindFirstChild("client_inactive") == nil)) and true or false)) == true then
						v_u_12.dual_wield_tool = v695
					end;
					break;
				end;
			end;
			if v_u_11.aim_normal then
				v_u_11.aim_normal.Priority = v_u_11.aim.Priority
			end;
			if v_u_11.aim_dual then
				v_u_11.aim_dual.Priority = v_u_11.aim.Priority
			end;
			if v_u_12.dual_wield_tool then
				v_u_11.sprint = v_u_11.sprint_dual
				local l_Value_3 = v_u_12.dual_wield_tool.weapon.Value
				if l_Value_0 == "vanguardshield" then
					if l_Value_3 == "cavsword" then
						v_u_11.sword_aim.Priority = v_u_11.aim.Priority
						v_u_11.sword_fullguard_aimed.Priority = v_u_11.shieldraised_aimed.Priority
						v_u_11.sword_fullguard_idle.Priority = v_u_11.shieldraised_idle.Priority
						v_u_11.aim = v_u_11.sword_aim
						v_u_11.shieldraised_aimed = v_u_11.sword_fullguard_aimed
						v_u_11.shieldraised_idle = v_u_11.sword_fullguard_idle
						v_u_11.sprint = v_u_11.sprint_normal
					else
						v_u_11.aim = v_u_11.aim_normal
					end;
				else
					v_u_11.aim = v_u_11.aim_dual
				end;
				local v_u_696 = require(game.ReplicatedStorage.weapon_modules:FindFirstChild(l_Value_3))
				v_u_12.other_wep_module = v_u_696
				v_u_12.dual_wield_vfx = function() --[[ Line: 10747 ]]
					--[[ Upvalues: (ref 1): l_Character_0, (ref 2): v_u_12, (copy 3): v_u_696 ]]
					return {
						["char"] = l_Character_0,
						["originweapon"] = v_u_12.dual_wield_tool.weapon.Value,
						["weapon"] = v_u_12.dual_wield_tool.weapon.Value,
						["model"] = v_u_12.dual_wield_tool.model.Value,
						["module"] = v_u_696,
						["core"] = nil
					};
				end;
				if l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and v_u_7.tooltype == "gun") then
					v_u_7.aim_speed = (v_u_7.aim_speed + v_u_696.aim_speed) / 1.5
					v_u_7.movement = v_u_7.movement + v_u_696.movement
					v_u_11.held = v_u_11.akimbo_held
					l_Action3_0 = Enum.AnimationPriority.Action
					l_Parent_0.akimbo.Value = true
				else
					v_u_7.aim_speed = v_u_696.aim_speed
				end;
			else
				if l_Value_0 == "vanguardshield" then
					if v_u_12.alt_mode == true then
						v_u_359(true)
					end;
					v_u_11.aim = v_u_11.shield_noweapon_aim
				else
					v_u_11.aim = v_u_11.aim_normal
				end;
				if l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and v_u_7.tooltype == "gun") then
					v_u_11.held = v_u_11.held_normal
					l_Parent_0.akimbo.Value = false
				end;
				v_u_11.sprint = v_u_11.sprint_normal
			end;
		end;
	end;
	if v_u_11.fire then
		v_u_11.fire.Priority = l_Action3_0
	end;
	if v_u_11.akimbo_fire then
		v_u_11.akimbo_fire.Priority = l_Action3_0
	end;
	if v_u_11.fire_left then
		v_u_11.fire_left.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire then
		v_u_11.alt_changefire.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire_empty then
		v_u_11.alt_changefire_empty.Priority = l_Action3_0
	end;
	if v_u_11.fire_empty then
		v_u_11.fire_empty.Priority = l_Action3_0
	end;
	if v_u_11.akimbo_fire_empty then
		v_u_11.akimbo_fire_empty.Priority = l_Action3_0
	end;
	if v_u_11.fire_empty_left then
		v_u_11.fire_empty_left.Priority = l_Action3_0
	end;
	if v_u_11.fire_last then
		v_u_11.fire_last.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire_last then
		v_u_11.alt_changefire_last.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire_left then
		v_u_11.alt_changefire_left.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire_last_left then
		v_u_11.alt_changefire_last_left.Priority = l_Action3_0
	end;
	if v_u_11.alt_changefire_empty_left then
		v_u_11.alt_changefire_empty_left.Priority = l_Action3_0
	end;
	v_u_11.held:Play(0, 1, 0.25)
	if v_u_12.dual_wield_tool then
		v_u_12.dual_wield_tool.event:Fire("dual_active", true)
		v_u_12.dual_wield_tool.event:Fire("reset_aimtime")
		local v697 = l_Value_0 == "cavsword" and true or nil
		local v698
		if l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and v_u_7.tooltype == "gun") then
			v697 = true
			v698 = true
		else
			v698 = nil
		end;
		v_u_4("weapon_visibility", {
			["main"] = v_u_12.dual_wield_vfx(),
			["slot"] = v_u_12.dual_wield_tool.slot.Value,
			["state"] = "equip",
			["flipped"] = v697,
			["dual"] = v698
		}, true)
		l_remotes_0.game_handler:FireServer("weapon_visibility", {
			["wep"] = v_u_12.dual_wield_tool,
			["state"] = "equip",
			["flipped"] = v697,
			["dual"] = v698
		})
	end;
	if v_u_12.slide_locked == true then
		v_u_11.locked:Play(0)
		if v_u_11.akimbo_locked then
			v_u_11.akimbo_locked:Stop(0)
		end;
	end;
	if v_u_12.alt_slide_locked == true then
		v_u_11.locked_alt:Play(0)
	end;
	v_u_11[v_u_11.draw_dual and v_u_12.dual_wield_tool ~= nil and "draw_dual" or "draw"]:Play(0, 1, (math.clamp(1 / (v_u_7.draw_speed / l_core_checkers_0.draw_modifier), 0, 1.5)))
	if l_Value_0 == "saa" and l_Character_0:FindFirstChild("cowboy") then
		delay(0.15, function() --[[ Line: 10901 ]]
			--[[ Upvalues: (ref 1): v_u_11 ]]
			v_u_11.ocelot_draw_spin:Play(0.1, 1, 1.4)
		end)
	end;
	tick()
	repeat
		l_RenderStepped_0:Wait()
		l_core_checkers_0.aim_time = tick()
		v_u_12.aim_sound = false
	until tick() - v_u_12.draw >= v_u_7.draw_speed / l_core_checkers_0.draw_modifier or v_u_12.equipped == false;
end)
l_Parent_0.Unequipped:Connect(function() --[[ Line: 10915 ]]
	--[[ Upvalues: (ref 1): v_u_5, (copy 2): l_Character_0, (copy 3): v_u_12, (copy 4): v_u_11, (copy 5): l_Parent_0, (ref 6): v_u_28, (ref 7): v_u_29, (copy 8): l_core_checkers_0, (copy 9): l_core_game_0, (ref 10): l_Value_0, (ref 11): v_u_10, (ref 12): v_u_48, (copy 13): v_u_1, (copy 14): v_u_359, (copy 15): v_u_4, (copy 16): l_Value_1, (ref 17): v_u_7, (ref 18): v_u_19, (copy 19): l_remotes_0 ]]
	if v_u_5 == true then
		return;
	elseif l_Character_0 == nil or l_Character_0:FindFirstChild("HumanoidRootPart") == nil then
		return;
	elseif v_u_12.dropped ~= true then
		if v_u_12.slide_locked == true and v_u_11.akimbo_locked then
			v_u_11.locked:Stop(0)
			v_u_11.akimbo_locked:Play(0)
		end;
		if l_Parent_0:FindFirstChild("akimbo") then
			l_Parent_0.akimbo.Value = false
		end;
		v_u_28 = nil
		v_u_29 = nil
		l_core_checkers_0.check_ammo = 0
		if v_u_12.los_tripwire then
			v_u_12.los_tripwire.Parent = nil
		end;
		if v_u_12.construct_holo then
			v_u_12.construct_holo:Destroy()
			v_u_12.construct_holo = nil
		end;
		if v_u_12.extra_bb then
			v_u_12.extra_bb.bb.Enabled = false
		end;
		v_u_12.construct_ready = false
		v_u_12.construct_pos = nil
		if v_u_11.fire then
			v_u_11.fire.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.akimbo_fire then
			v_u_11.akimbo_fire.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.fire_left then
			v_u_11.fire_left.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.alt_changefire then
			v_u_11.alt_changefire.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.alt_changefire_empty then
			v_u_11.alt_changefire_empty.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.fire_empty then
			v_u_11.fire_empty.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.akimbo_fire_empty then
			v_u_11.akimbo_fire_empty.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.fire_empty_left then
			v_u_11.fire_empty_left.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.fire_last then
			v_u_11.fire_last.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.alt_changefire_left then
			v_u_11.alt_changefire_left.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.alt_changefire_last_left then
			v_u_11.alt_changefire_last_left.Priority = Enum.AnimationPriority.Action
		end;
		if v_u_11.alt_changefire_empty_left then
			v_u_11.alt_changefire_empty_left.Priority = Enum.AnimationPriority.Action
		end;
		local v699 = l_core_game_0.inventory:FindFirstChild(l_Value_0 .. l_Parent_0.slot.Value) or l_core_game_0.inventory:FindFirstChild(v_u_10 .. l_Parent_0.slot.Value)
		if v699 then
			l_core_checkers_0.inventory_display = tick()
			v699.line.BackgroundColor3 = Color3.new(0, 0, 0)
			v699.icon.ImageColor3 = Color3.new(0, 0, 0)
			v699.num.TextColor3 = Color3.new(0, 0, 0)
		end;
		if v_u_48 then
			v_u_48.warningbeam.Enabled = false
			v_u_48.x.Enabled = false
		end;
		for v700, v701 in pairs(v_u_11) do
			if v700 ~= "throw_over" and v700 ~= "throw_under" and ((l_Value_0 ~= "crossbow" or v700 ~= "locked") and true or (l_Character_0:FindFirstChild("crossbow1") and l_Character_0:FindFirstChild("crossbow2") and true or false)) == true then
				v701:Stop(0.01)
			end;
		end;
		if v_u_11.unequip then
			v_u_11.unequip:Play(0.1, 1, 1)
		end;
		if l_Character_0 and l_Character_0:FindFirstChild("HumanoidRootPart") then
			v_u_1:soundHandler({
				["directory"] = {},
				["soundfile"] = "unequip",
				["pitchvariation"] = 0.1,
				["location"] = l_Character_0.HumanoidRootPart
			})
			v_u_12.equipped = false
			if l_Value_0 == "vanguardshield" and (v_u_12.alt_mode == true and v_u_12.dual_wield_tool) then
				v_u_359(false)
			end;
			local v702 = v_u_4
			local v703 = "weapon_visibility"
			local v704 = {}
			local v705 = l_Value_0
			if v_u_10 ~= "" then
				v705 = v_u_10
			end;
			v704.main = {
				["char"] = l_Character_0,
				["originweapon"] = v705,
				["weapon"] = l_Value_0,
				["model"] = l_Value_1,
				["module"] = v_u_7,
				["core"] = v_u_19
			}
			v704.slot = l_Parent_0.slot.Value
			v704.state = "holster"
			v702(v703, v704, true)
			if l_Value_0 == "henry" and l_Character_0.perk.Value == "vet" then
				local v706 = v_u_4
				local v707 = "henry_offhandround"
				local v708 = {}
				local v709 = l_Value_0
				if v_u_10 ~= "" then
					v709 = v_u_10
				end;
				v708.main = {
					["char"] = l_Character_0,
					["originweapon"] = v709,
					["weapon"] = l_Value_0,
					["model"] = l_Value_1,
					["module"] = v_u_7,
					["core"] = v_u_19
				}
				v708.visibility = false
				v706(v707, v708)
			end;
			l_remotes_0.game_handler:FireServer("weapon_visibility", {
				["wep"] = l_Parent_0,
				["state"] = "holster"
			})
			if v_u_12.dual_wield_tool then
				v_u_12.dual_wield_tool.event:Fire("dual_active", false)
				local v710 = l_Value_0 == "cavsword" and true or nil
				local v711
				if l_Character_0.perk.Value == "akimbo" and (v_u_7.size == 1 and v_u_7.tooltype == "gun") then
					v710 = true
					v711 = true
				else
					v711 = nil
				end;
				v_u_4("weapon_visibility", {
					["main"] = v_u_12.dual_wield_vfx(),
					["slot"] = v_u_12.dual_wield_tool.slot.Value,
					["state"] = "holster",
					["flipped"] = v710,
					["dual"] = v711
				}, true)
				l_remotes_0.game_handler:FireServer("weapon_visibility", {
					["wep"] = v_u_12.dual_wield_tool,
					["state"] = "holster",
					["flipped"] = v710,
					["dual"] = v711
				})
			end;
		end;
	end;
end)
local v_u_712 = l_RenderStepped_0:Connect(v622)
local v_u_713 = game:GetService("RunService").Stepped:Connect(v639)
v_u_167 = function() --[[ Line: 11112 ]]
	--[[ Upvalues: (copy 1): v_u_12, (ref 2): v_u_48, (copy 3): v_u_11, (copy 4): v_u_88, (ref 5): v_u_5, (copy 6): v_u_712, (copy 7): v_u_713, (copy 8): l_Parent_0 ]]
	if v_u_12.construct_holo ~= nil then
		v_u_12.construct_holo:Destroy()
	end;
	if v_u_12.los_tripwire ~= nil then
		v_u_12.los_tripwire:Destroy()
	end;
	if v_u_48 ~= nil then
		v_u_48:Destroy()
	end;
	if v_u_12.extra_bb then
		v_u_12.extra_bb:Destroy()
	end;
	for _, v714 in pairs(v_u_11) do
		v714:Stop(0)
		v714:Destroy()
	end;
	v_u_88:Disconnect()
	v_u_5 = true
	v_u_12.equipped = false
	v_u_712:Disconnect()
	v_u_713:Disconnect()
	delay(2, function() --[[ Line: 11147 ]]
		--[[ Upvalues: (ref 1): l_Parent_0 ]]
		if l_Parent_0 then
			l_Parent_0:Destroy()
		end;
	end)
end
v_u_9.Died:Connect(v_u_167)
