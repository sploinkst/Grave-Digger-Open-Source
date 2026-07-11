------------
-- @Praxitos
-- GameManagerService — handles rounds, spawning, and capture point logic
------------

local module = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local ToolService		= require(script.Parent.ItemsService)
local AccessoryService	= require(script.Parent.AccessoryService)
-- Shared folders
local shared        = ReplicatedStorage.Shared
local library       = shared.Library
local config        = library.Configuration.Scoring_Variables


-- Scoring values
local empire_rein_count        = config.Empire.Empire_Rein_Count
local empire_rein_wave_timer   = config.Empire.Empire_Rein_Wave_Timer
local empire_infinite_respawns = config.Empire:FindFirstChild("Empire_Infinite_Tickets")
local nation_infinite_respawns = config.Nation:FindFirstChild("Nation_Infinite_Tickets")
local nation_rein_count        = config.Nation.Nation_Rein_Count
local nation_rein_wave_timer   = config.Nation.Nation_Rein_Wave_Timer
local game_timer               = config.Timer.Game_Timer
local gamemode_folder          = config.Gamemode
local capture_points_count     = gamemode_folder.Capture_Points_Count

local quick_respawns_boolean = config.Parent.Game_Variables:FindFirstChild("Quick_Respawns")

-- Workspace references
local main_game    = workspace.Game_Details.Main_Game
local empire_spawn = main_game:WaitForChild("Empire")
local nation_spawn = main_game:WaitForChild("Nation")
local points_folder = main_game.Points

-- Asset references
local spawn_anims = shared:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Character"):WaitForChild("Spawns")
local core_maps   = shared.Assets.Maps["Core Maps"]

local Sounds = shared:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Game")
local Tick = Sounds:WaitForChild("ObjectiveTick")
-- Points billboard
local ui_folder        = shared.Assets.UI
local points_billboard = ui_folder.Points_Billboard

local testing_boolean         = config.Parent.Game_Variables.Testing_Boolean
local visualize_casts_boolean = config.Parent.Ranged_Variables.Visualizations.Visualize_Casts
local fastcast_module         = require(shared.Library.Externals.FastCast)

-- State
local time_tick = false
local round_active = false
local intermission_time = 20

local empire_team = game.Teams["Golden Empire"]
local nation_team = game.Teams["Royal Nation"]

-- Constants
local SERVER_READY_TIMEOUT   = 15  -- seconds to wait for the client before giving up / forcing items
local ITEM_GIVE_DELAY        = 1.5 -- seconds after ServerReady before items are handed out

-- Time

local function format_time(total_seconds: number): string
	return string.format("%02d:%02d", math.floor(total_seconds / 60), total_seconds % 60)
end

local function begin_time()
	local total_seconds = 0

	if typeof(game_timer.Value) == "string" then
		local min, sec = string.match(game_timer.Value, "^(%d%d):(%d%d)$")
		if min and sec then
			total_seconds = tonumber(min) * 60 + tonumber(sec)
		end
	end

	while time_tick do
		task.wait(1)
		total_seconds += 1
		game_timer.Value = format_time(total_seconds)
	end
end


-- Spawning


local function get_spawn_animation(spawn_name: string): Animation?
	local folder = spawn_anims:FindFirstChild(spawn_name)
	if not folder then
		warn("[GameManager] No spawn animation folder for:", spawn_name)
		return nil
	end

	local anims = folder:GetChildren()
	if #anims == 0 then
		warn("[GameManager] No animations in spawn folder:", spawn_name)
		return nil
	end

	return anims[math.random(1, #anims)]
end

local function find_empty_spawn(spawn_room: Model): Instance
	for _, slot in pairs(spawn_room.Spawns:GetChildren()) do
		if not slot:GetAttribute("Occupied") then
			return slot
		end
	end

	-- All slots occupied — pick a random one as fallback
	local slots = spawn_room.Spawns:GetChildren()
	return slots[math.random(1, #slots)]
end

local function has_eligible_players(team: Team): boolean
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team and not player:GetAttribute("Active") then
			return true
		end
	end
	return false
end

-- Hands the player their loadout. Pulled into its own function so every
-- spawn path (wave spawns, intermission spawns, late joiners) gives items
-- the exact same way instead of three slightly different copies drifting
-- out of sync with each other.
local function give_starting_equipment(player: Player, character: Model)
	if not player or not player.Parent then return end
	if not character or character.Parent == nil then return end

	local player_data = player:FindFirstChild("PlayerData")
	if not player_data then
		warn("[GameManager] No PlayerData found for", player.Name, "- cannot give items.")
		return
	end

	local player_data_folder = player_data:WaitForChild("PlayerData", 5)
	if not player_data_folder then
		warn("[GameManager] PlayerData.PlayerData never appeared for", player.Name, "- cannot give items.")
		return
	end

	local equipment = player_data_folder:WaitForChild("Equipment", 5)
	if not equipment then
		warn("[GameManager] No Equipment folder for", player.Name, "- cannot give items.")
		return
	end

	local primary_tool   = equipment:FindFirstChild("Primary")
	local secondary_tool = equipment:FindFirstChild("Secondary")

	-- Bail out early and loudly instead of silently handing out nothing.
	if not primary_tool or primary_tool.Value == "" then
		warn("[GameManager]", player.Name, "has no Primary tool set — skipping.")
	else
		ToolService.give_item(player, primary_tool.Value)
	end

	if not secondary_tool or secondary_tool.Value == "" then
		warn("[GameManager]", player.Name, "has no Secondary tool set — skipping.")
	else
		ToolService.give_item(player, secondary_tool.Value)
	end

	ToolService.give_item(player, "Compass")
	ToolService.give_item(player, "Medkit")
	ToolService.give_item(player, "Pickaxe")

	if character and character.Parent then
		character:SetAttribute("Equipment", "AmmoPack")
	end

	print("[GameManager] Gave starting equipment to", player.Name)
end

-- Waits for the client to signal it's ready, then hands out items after a
-- short delay. If the client never signals ready within the timeout, items
-- are still given (with a warning) rather than silently skipped — a timeout
-- used to mean the player got nothing and no one noticed.
local function equip_when_ready(player: Player, character: Model)
	task.spawn(function()
		local deadline = tick() + SERVER_READY_TIMEOUT

		while not character:GetAttribute("ServerReady") do
			if not player.Character or player.Character ~= character then
				return -- player respawned/left before ever becoming ready
			end
			if tick() > deadline then
				warn("[GameManager] Timed out waiting for ServerReady on", player.Name, "- giving items anyway.")
				break
			end
			task.wait(0.1)
		end

		if not player.Character or player.Character ~= character then
			return
		end

		task.wait(ITEM_GIVE_DELAY)

		if not player.Character or player.Character ~= character then
			return
		end

		give_starting_equipment(player, character)
	end)
end

-- Single shared entry point for spawning a player into a spawn room:
-- loads the character, places it in an empty slot, plays the spawn
-- animation, wires up slot-release/animation-stop on movement or death,
-- and queues up item giving. Used by wave spawns, intermission spawns,
-- and players who join mid-intermission.
local function spawn_and_equip_player(player: Player, spawn_room: Model)
	if not spawn_room then
		warn("[GameManager] spawn_and_equip_player called with no spawn_room for", player.Name)
		return
	end

	player:SetAttribute("Active", true)
	player:LoadCharacterAsync()

	local character = player.Character or player.CharacterAdded:Wait()
	local slot       = find_empty_spawn(spawn_room)

	slot:SetAttribute("Occupied", true)
	character:PivotTo(slot.CFrame)

	local anim_track: AnimationTrack?
	local animation = get_spawn_animation(slot.Name)

	if animation then
		local animator = character:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")
		if animator then
			anim_track = animator:LoadAnimation(animation)
			anim_track:Play()
		end
	end

	character:SetAttribute("DontRotate", true)

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	task.spawn(function()
		while character.Parent and humanoid.Health > 0 do
			if humanoid.MoveDirection.Magnitude > 0 then
				slot:SetAttribute("Occupied", nil)

				if anim_track then
					anim_track.Looped = false
					anim_track:Stop()
				end

				character:SetAttribute("DontRotate", nil)
				break
			end

			task.wait()
		end
	end)

	humanoid.Died:Connect(function()
		slot:SetAttribute("Occupied", nil)

		if anim_track then
			anim_track:Stop()
		end
	end)

	equip_when_ready(player, character)

	return character
end

local function spawn_wave(team: Team)
	print("[GameManager] Spawning reinforcements for:", team.Name)

	local team_Name  = team.Name
	local spawn_room = team_Name == "Golden Empire" and empire_spawn or nation_spawn

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team ~= team or player:GetAttribute("Active") then continue end

		spawn_and_equip_player(player, spawn_room)
	end
end

local function handle_reinforcement_wave(
	rein_count: IntValue,
	wave_timer: IntValue,
	team: Team,
	infinite_respawns: BoolValue?
)
	while true do
		if not round_active then
			task.wait(1)
			continue
		end

		if rein_count.Value <= 0 then
			break
		end

		if wave_timer.Value > 0 then
			task.wait(1)
			wave_timer.Value -= 1
			continue
		end

		if not has_eligible_players(team) then
			task.wait(1)
			continue
		end

		task.wait(3)
		spawn_wave(team)

		if not (infinite_respawns and infinite_respawns.Value == true) then
			rein_count.Value -= 1
		end

		if quick_respawns_boolean and quick_respawns_boolean.Value == true then
			wave_timer.Value = 1
		else
			wave_timer.Value = 30
		end
	end
end


-- Capture points

local function set_billboard_ui(point_parent: Part)
	local billboard_ui_clone = points_billboard:Clone()
	billboard_ui_clone.Parent = point_parent
end

local function select_random_map(): Model
	local maps = core_maps:GetChildren()
	return maps[math.random(1, #maps)]
end

local function place_map(map: Model, point: Instance)
	map:PivotTo(point.CFrame)
	map.Parent = point
end

local function carve_air_block(map: Model)
	local air = map:FindFirstChild("air")
	if not air then return end
	workspace.Terrain:FillBlock(air.CFrame, air.Size, Enum.Material.Air)
end

local function setup_capture_point(point: Instance, model: Model)
	if not point or not model then return end

	local capture_part: Part = model:FindFirstChild("capture")
	local point_data         = gamemode_folder:FindFirstChild(point.Name .. "_Point")

	if not point_data then
		warn("[GameManager] Missing point data folder for:", point.Name)
		return
	end

	set_billboard_ui(point)

	local empire_count   = point_data:FindFirstChild(point.Name .. "_Empire_Count")
	local nation_count   = point_data:FindFirstChild(point.Name .. "_Nation_Count")
	local progress       = point_data:FindFirstChild(point.Name .. "_Progress")
	local owner          = point_data:FindFirstChild(point.Name .. "_Owner")
	local progress_owner = point_data:FindFirstChild(point.Name .. "_Progress_Owner")

	if not (empire_count and nation_count and progress and owner and progress_owner) then
		warn("[GameManager] Missing value objects in point data:", point_data.Name)
		return
	end

	print("[GameManager] Initialising point:", point.Name)

	local players_on_point: { [Player]: true } = {}

	local function remove_player(player: Player)
		if not players_on_point[player] then return end
		players_on_point[player] = nil

		if player.Team == game.Teams["Golden Empire"] then
			empire_count.Value = math.max(0, empire_count.Value - 1)
		elseif player.Team == game.Teams["Royal Nation"] then
			nation_count.Value = math.max(0, nation_count.Value - 1)
		end

		print("[GameManager]", point.Name, "left by", player.Name)
	end

	local function add_player(player: Player)
		if players_on_point[player] then return end
		players_on_point[player] = true

		if player.Team == game.Teams["Golden Empire"] then
			empire_count.Value += 1
		elseif player.Team == game.Teams["Royal Nation"] then
			nation_count.Value += 1
		end

		-- Clean up if the player dies or leaves while on the point
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Died:Connect(function()
					remove_player(player)
				end)
			end
		end

		print("[GameManager]", point.Name, "entered by", player.Name)
	end

	local function get_player_from_hit(hit: BasePart): Player?
		local character = hit.Parent
		if not character or not character:FindFirstChild("Humanoid") then return nil end

		-- Ignore ragdoll corpses parented under Bodies
		if character.Parent and character.Parent.Name == "Bodies" then return nil end

		return Players:GetPlayerFromCharacter(character)
	end

	-- Clean up if a player leaves the game entirely
	Players.PlayerRemoving:Connect(function(player)
		remove_player(player)
	end)

	capture_part.Touched:Connect(function(hit)
		local player = get_player_from_hit(hit)
		if player then add_player(player) end
	end)

	capture_part.TouchEnded:Connect(function(hit)
		local player = get_player_from_hit(hit)
		if player then remove_player(player) end
	end)

	-- Capture loop
	task.spawn(function()
		while true do
			task.wait(1)

			local empire_n = empire_count.Value
			local nation_n = nation_count.Value
			local total    = empire_n + nation_n

			-- Award ownership at full progress
			if progress.Value == 20 then
				if empire_n > nation_n then
					owner.Value = "Golden Empire"
					print("[GameManager] Point captured by Empire:", point.Name)
				elseif nation_n > empire_n then
					owner.Value = "Royal Nation"
					print("[GameManager] Point captured by Nation:", point.Name)
				else
					owner.Value = ""
				end
				progress.Value = 0
				progress_owner.Value = ""
			end

			-- Decay when nobody is on the point
			if total == 0 then
				if progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then
						progress_owner.Value = ""
					end
				end
				continue
			end

			-- Stall when teams are even
			if empire_n == nation_n then
				print("[GameManager]", point.Name, "contested — stalling.")
				continue
			end

			if empire_n > nation_n then
				if owner.Value == "Golden Empire" then continue end

				-- Drain enemy progress first before advancing
				if progress_owner.Value == "Royal Nation" and progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then progress_owner.Value = "" end
					print("[GameManager]", point.Name, "Empire draining Nation progress.")
				else
					progress_owner.Value = "Golden Empire"
					progress.Value += 1
					print("[GameManager]", point.Name, "being capped by Empire.")
				end
			else
				if owner.Value == "Royal Nation" then continue end

				-- Drain enemy progress first before advancing
				if progress_owner.Value == "Golden Empire" and progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then progress_owner.Value = "" end
					print("[GameManager]", point.Name, "Nation draining Empire progress.")
				else
					progress_owner.Value = "Royal Nation"
					progress.Value += 1
					print("[GameManager]", point.Name, "being capped by Nation.")
				end
			end
		end
	end)
end

local function set_basecolours(spawnroom, value)
	for _, child:Part in pairs(spawnroom.Walls:GetChildren()) do
		if child.Name ~= "basecolour" then continue end

		child.Transparency = value == true and 0 or 1
		child.CanCollide = value
	end
end

local function get_spawn_room_for(player: Player): Model?
	if player.Team == game.Teams["Golden Empire"] then
		return empire_spawn
	elseif player.Team == game.Teams["Royal Nation"] then
		return nation_spawn
	end
	return nil
end

local function start_intermission()
	print("[GameManager] Starting intermission.")

	set_basecolours(empire_spawn, true)
	set_basecolours(nation_spawn, true)

	for _, player in ipairs(Players:GetPlayers()) do
		local spawn_room = get_spawn_room_for(player)
		if spawn_room then
			spawn_and_equip_player(player, spawn_room)
		end
	end

	-- Players joining mid-intermission now go through the exact same
	-- spawn_and_equip_player path — previously this branch spawned and
	-- animated the player but never gave them any items at all.
	local player_added_connection
	player_added_connection = Players.PlayerAdded:Connect(function(player)
		local spawn_room = get_spawn_room_for(player)
		if spawn_room then
			spawn_and_equip_player(player, spawn_room)
		end
	end)

	-- Countdown
	for i = intermission_time,1,-1 do
		print("[GameManager] Round starts in:",i)
		if i <= 3 and i ~= 0 then
			local TickClone = Tick:Clone()
			TickClone.Parent = game:GetService("SoundService")
			TickClone:Play()
			TickClone.Stopped:Connect(function()
				TickClone:Destroy()
			end)
		elseif i == 0 then
			-- // fire event
		end
		task.wait(1)
	end

	player_added_connection:Disconnect()

	print("[GameManager] Intermission complete.")

	round_active = true

	set_basecolours(empire_spawn, false)
	set_basecolours(nation_spawn, false)
end

-- Module entry

function module.start_module()

	fastcast_module.VisualizeCasts = visualize_casts_boolean.Value

	visualize_casts_boolean:GetPropertyChangedSignal("Value"):Connect(function()
		fastcast_module.VisualizeCasts = visualize_casts_boolean.Value
	end)

	if testing_boolean.Value == true then return end

	-- Helper: apply infinite tickets for a team immediately
	local function apply_infinite_tickets(rein_count: IntValue, team_name: string)
		rein_count.Value = 999
		print("[GameManager]", team_name, "infinite tickets enabled — set to 999.")
	end

	-- Helper: apply quick respawns to a wave timer immediately
	local function apply_quick_respawns(wave_timer: IntValue, team_name: string)
		wave_timer.Value = 1
		print("[GameManager] Quick respawns enabled for", team_name, "— wave timer set to 1.")
	end

	-- Apply infinite tickets on start, and re-apply whenever the value changes
	if empire_infinite_respawns then
		if empire_infinite_respawns.Value == true then
			apply_infinite_tickets(empire_rein_count, "Empire")
		end
		empire_infinite_respawns:GetPropertyChangedSignal("Value"):Connect(function()
			if empire_infinite_respawns.Value == true then
				apply_infinite_tickets(empire_rein_count, "Empire")
			end
		end)
	end

	if nation_infinite_respawns then
		if nation_infinite_respawns.Value == true then
			apply_infinite_tickets(nation_rein_count, "Nation")
		end
		nation_infinite_respawns:GetPropertyChangedSignal("Value"):Connect(function()
			if nation_infinite_respawns.Value == true then
				apply_infinite_tickets(nation_rein_count, "Nation")
			end
		end)
	end

	-- Apply quick respawns on start, and re-apply whenever the value changes
	if quick_respawns_boolean then
		if quick_respawns_boolean.Value == true then
			apply_quick_respawns(empire_rein_wave_timer, "Empire")
			apply_quick_respawns(nation_rein_wave_timer, "Nation")
		end
		quick_respawns_boolean:GetPropertyChangedSignal("Value"):Connect(function()
			if quick_respawns_boolean.Value == true then
				apply_quick_respawns(empire_rein_wave_timer, "Empire")
				apply_quick_respawns(nation_rein_wave_timer, "Nation")
			end
		end)
	end

	task.spawn(start_intermission)

	time_tick = true
	task.spawn(begin_time)

	task.spawn(handle_reinforcement_wave, 
		empire_rein_count,
		empire_rein_wave_timer,
		empire_team,
		empire_infinite_respawns
	)

	task.spawn(handle_reinforcement_wave,
		nation_rein_count,
		nation_rein_wave_timer,
		nation_team,
		nation_infinite_respawns
	)

	-- Assign a random map to each active capture point.
	-- Build a pool of empty, unassigned points up front and pop from it,
	-- so we can never loop forever looking for a valid point.
	local all_points  = points_folder:GetChildren()
	local empty_points: { Instance } = {}

	for _, point in ipairs(all_points) do
		if #point:GetChildren() == 0 then
			table.insert(empty_points, point)
		end
	end

	local active_points: { Instance } = {}

	local points_to_assign = math.min(capture_points_count.Value, #empty_points)
	if points_to_assign < capture_points_count.Value then
		warn(string.format(
			"[GameManager] Only %d empty capture point(s) available, but Capture_Points_Count wants %d.",
			#empty_points, capture_points_count.Value
			))
	end

	for i = 1, points_to_assign do
		local map = select_random_map()

		local index = math.random(1, #empty_points)
		local point = table.remove(empty_points, index)

		place_map(map, point)
		carve_air_block(map)
		setup_capture_point(point, map)
		table.insert(active_points, point)
	end

	-- Ticket drain loop
	-- Every 3 seconds, each point owned by a team drains (3 * P / n) tickets from
	-- the enemy, where P = points owned by that team and n = total active points.
	-- Infinite-ticket sides are immune to draining.
	task.spawn(function()
		local n = #active_points
		if n == 0 then return end

		while true do
			task.wait(3)

			local empire_owned = 0
			local nation_owned = 0

			for _, point in ipairs(active_points) do
				local point_data = gamemode_folder:FindFirstChild(point.Name .. "_Point")
				if not point_data then continue end

				local owner = point_data:FindFirstChild(point.Name .. "_Owner")
				if not owner then continue end

				if owner.Value == "Golden Empire" then
					empire_owned += 1
				elseif owner.Value == "Royal Nation" then
					nation_owned += 1
				end
			end

			-- Empire-owned points drain Nation tickets (skip if Nation has infinite tickets)
			if empire_owned > 0 then
				if nation_infinite_respawns and nation_infinite_respawns.Value == true then
					print("[GameManager] Nation infinite tickets — drain skipped.")
				else
					local total_drain = 3 * empire_owned / n
					nation_rein_count.Value = math.max(0, math.floor(nation_rein_count.Value - total_drain))
					print(string.format(
						"[GameManager] Empire owns %d/%d points — draining %.2f tickets from Nation.",
						empire_owned, n, total_drain
						))
				end
			end

			-- Nation-owned points drain Empire tickets (skip if Empire has infinite tickets)
			if nation_owned > 0 then
				if empire_infinite_respawns and empire_infinite_respawns.Value == true then
					print("[GameManager] Empire infinite tickets — drain skipped.")
				else
					local total_drain = 3 * nation_owned / n
					empire_rein_count.Value = math.max(0, math.floor(empire_rein_count.Value - total_drain))
					print(string.format(
						"[GameManager] Nation owns %d/%d points — draining %.2f tickets from Empire.",
						nation_owned, n, total_drain
						))
				end
			end
		end
	end)
end

return module