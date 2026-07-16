-- @Praxitos

local module = {}

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local InsertService 	= game:GetService("InsertService")
local Lighting          = game:GetService("Lighting")
local RunService 		= game:GetService("RunService")
local WorkspaceService  = game:GetService("Workspace")
local InputService      = game:GetService("UserInputService")

-- Shared references
local shared    = ReplicatedStorage:WaitForChild("Shared")
local library   = shared:WaitForChild("Library")
local utilities = require(library:WaitForChild("Util"))

local concussion_blur = Lighting.Effects.ConcussionBlur
local concussion_active = false
local concussion_connection: RBXScriptConnection? = nil
local heartbeat_sound: Sound? = nil
local lastHeartbeatTime = 0

local NationStart = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Game"):WaitForChild("NationStart")
local EmpireStart = NationStart.Parent.EmpireStart

local Name_Billboard = ReplicatedStorage:WaitForChild('Shared'):WaitForChild("Assets"):WaitForChild('UI'):WaitForChild("Name_Billboard")

local game_details = WorkspaceService:WaitForChild("Game_Details")
local bodies_folder = game_details:WaitForChild("Bodies")

-- Replication tracking
local MAX_REPLICATION_EVENTS = 300
module.ReplicationBuffer = {}

local function push_replication_event(eventType, data)
	table.insert(module.ReplicationBuffer, {
		Type = eventType,
		Time = os.clock(),
		Data = data
	})

	if #module.ReplicationBuffer > MAX_REPLICATION_EVENTS then
		table.remove(module.ReplicationBuffer, 1)
	end
end

function module.GetReplicationBuffer()
	return module.ReplicationBuffer
end

-- Export for easy access
function module.GetReplicationCount()
	return #module.ReplicationBuffer
end

-- Asset folders
local holsters_root = ReplicatedStorage.Shared.Assets.Guns.Holsters
local tool_holsters = holsters_root["Tool Holsters"]
local gun_holsters  = holsters_root["Gun Holsters"]

-- Configuration
local config          = library.Configuration.Scoring_Variables
local empire_config   = config.Empire
local nation_config   = config.Nation
local game_timer_val  = config.Timer.Game_Timer
local gamemode_config = config.Gamemode

local empire_rein_count = empire_config.Empire_Rein_Count
local empire_wave_timer = empire_config.Empire_Rein_Wave_Timer
local nation_rein_count = nation_config.Nation_Rein_Count
local nation_wave_timer = nation_config.Nation_Rein_Wave_Timer

local visualize_casts_boolean = config.Parent.Ranged_Variables.Visualizations.Visualize_Casts
local fastcast_module = require(shared.Library.Externals.FastCast)


-- Constants
local MAX_REIN = 500
local LOW_HEALTH_THRESHOLD = 100
local HEARTBEAT_INTERVAL = 1.5

local ICONS = {
	Golden_Empire_Background = "rbxassetid://17519166341",
	Royal_Nation_Background  = "rbxassetid://17519166185",
}

local FLASH_TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local FLASH_COLOR      = Color3.fromRGB(220, 50, 50)

local flinch_cooldown = 0.35
local last_flinched = 0
-- Replicants
local replicant_folder = game:GetService("ReplicatedStorage").Shared.Library.Events.Replicant_Communication
local fastcast_replicant = replicant_folder.FastCast_Connection
local vfx_replicant = replicant_folder.VFX_Connection
local sfx_replicant = replicant_folder.SFX_Connection
local texture_replicant = replicant_folder.Texture_Connection
local casing_replicant = replicant_folder.Casing_Connection

-- UI references (reassigned on respawn)
local scoring_gui:        ScreenGui
local score_frame:        Frame
local empire_frame:       Frame
local nation_frame:       Frame
local timer_frame:        Frame
local objective_uis:      Folder
local overhead_frame:     Frame
local overhead_bar:       Frame
local overhead_bgicon:    ImageLabel
local overhead_label:     TextLabel
local overhead_enemyin:   Frame
local overhead_lockicon:  ImageLabel

local local_player = Players.LocalPlayer

-- Blur effect setup
local Camera = workspace.CurrentCamera
local blur = Camera:FindFirstChild("blur")
if blur == nil then
	blur = Instance.new("BlurEffect")
	blur.Name = "blur"
	blur.Size = 0
	blur.Parent = Camera
end

local lastHeartbeatTime = 0

-- Overhead sync connections; cleared whenever the player leaves a capture zone
local overhead_connections: { RBXScriptConnection } = {}

-- Active flash tweens keyed by frame, so we can stop them individually
local active_flash_tweens: { [Frame]: Tween } = {}
local flash_connections: { [Frame]: RBXScriptConnection } = {}

-- Tracks the last team that was actively pushing each point, keyed by point name.
-- Preserved during decay so the bar keeps the correct color as it falls back.
local point_cap_team: { [string]: string } = {}


local function resolve_cap_team(empire_count: IntValue, nation_count: IntValue, point_name: string)
	local empire_n = empire_count.Value
	local nation_n = nation_count.Value

	local cap_team = nil

	if empire_n > nation_n then
		cap_team = "Golden Empire"
	elseif nation_n > empire_n then
		cap_team = "Royal Nation"
	end

	-- cache for decay logic consistency (optional but now safe)
	point_cap_team[point_name] = cap_team

	return cap_team
end

local function setup_light(parent: BasePart, player: Player)
	local light      = Instance.new("PointLight")
	light.Brightness = 0.5
	light.Range      = 18
	light.Parent     = parent

	light.Color = player.TeamColor.Color
end

local function update_bar(frame: Frame, value: number)
	local normalized = math.clamp(value / MAX_REIN, 0, 1)
	frame.bar.Size   = UDim2.fromScale(normalized, 1)
	frame.num.Text   = tostring(value)
end

local function update_wave_text(frame: Frame, value: number)
	frame.rein.Text = value > 0
		and "Reinforcements in: " .. tostring(value)
		or  "Reinforcements available"
end

local function update_timer(frame: TextLabel, value: number)
	frame.Text = tostring(value)
end

local function set_objectives_hidden()
	for _, ui in pairs(objective_uis:GetChildren()) do
		ui.Visible = false
	end
end

local function update_objective(value: string)
	set_objectives_hidden()
	local target = objective_uis:FindFirstChild(string.lower(value))
	if target then
		target.Visible = true
	else
		warn("[ScoringClient] Unknown objective type:", value, "— falling back to 'control'")
		local control = objective_uis:FindFirstChild("control")
		if control then control.Visible = true end
	end
end

local function refresh_ui()
	update_bar(nation_frame, nation_rein_count.Value)
	update_wave_text(nation_frame, nation_wave_timer.Value)
	update_bar(empire_frame, empire_rein_count.Value)
	update_wave_text(empire_frame, empire_wave_timer.Value)
	update_timer(timer_frame, game_timer_val.Value)
	update_objective(gamemode_config.Gamemode_Type.Value)
end

local function rebind_ui()
	local player_gui  = local_player:WaitForChild("PlayerGui")
	scoring_gui       = player_gui:WaitForChild("Scoring")
	score_frame       = scoring_gui:WaitForChild("scoreframe")
	empire_frame      = score_frame:WaitForChild("empireside")
	nation_frame      = score_frame:WaitForChild("nationside")
	timer_frame       = score_frame.center
	objective_uis     = score_frame.objective_uis
	overhead_frame    = scoring_gui.objpopup
	overhead_bar      = overhead_frame:FindFirstChild("bar")
	overhead_bgicon   = overhead_frame:FindFirstChild("bgicon")
	overhead_label    = overhead_frame:FindFirstChild("label")
	overhead_enemyin  = overhead_frame:FindFirstChild("enemyin")
	overhead_lockicon = overhead_frame:FindFirstChild("lockicon")
	refresh_ui()
end



local function get_billboard_ui(point_name: string)
	local point_folder = workspace.Game_Details.Main_Game.Points:FindFirstChild(point_name)
	if not point_folder then
		return nil
	end

	return point_folder:FindFirstChild("Points_Billboard")
end

local function start_flash(frame: Frame)
	if active_flash_tweens[frame] then return end

	frame.BackgroundColor3                  = FLASH_COLOR
	frame.BackgroundTransparency            = 1
	overhead_enemyin.BackgroundTransparency = 1

	frame.Visible            = true
	overhead_enemyin.Visible = true

	local tween = TweenService:Create(frame, FLASH_TWEEN_INFO, {
		BackgroundTransparency = 0
	})
	active_flash_tweens[frame] = tween
	tween:Play()

	if flash_connections[frame] then
		flash_connections[frame]:Disconnect()
	end
	flash_connections[frame] = frame:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
		overhead_enemyin.BackgroundTransparency = frame.BackgroundTransparency
	end)
end

local function stop_flash(frame: Frame, is_overhead: boolean?)
	local tween = active_flash_tweens[frame]
	if tween then
		tween:Cancel()
		active_flash_tweens[frame] = nil
	end

	if frame then
		frame.BackgroundTransparency = 1
		frame.Visible = false
	end

	if is_overhead then
		overhead_enemyin.BackgroundTransparency = 1
		overhead_enemyin.Visible = false
	end
	
	if flash_connections[frame] then
		flash_connections[frame]:Disconnect()
		flash_connections[frame] = nil
	end

	frame.BackgroundTransparency            = 1
	frame.Visible                           = false
	overhead_enemyin.BackgroundTransparency = 1
	overhead_enemyin.Visible                = false
end

local function update_enemy_flash(
	empire_count: IntValue,
	nation_count: IntValue,
	owner: StringValue,
	scoreboard_enemyin: Frame,
	point_name: string?
)
	local team = local_player.Team
	if not team then
		stop_flash(scoreboard_enemyin, true)
		return
	end

	local billboard_enemyin

	if point_name then
		local billboard = get_billboard_ui(point_name)

		if billboard then
			billboard_enemyin = billboard:FindFirstChild("enemyin")
		end
	end

	local enemy_present = false
	local enemy_owns = false

	if team.Name == "Golden Empire" then
		enemy_present = nation_count.Value > 0
		enemy_owns = owner.Value == "Royal Nation"
	else
		enemy_present = empire_count.Value > 0
		enemy_owns = owner.Value == "Golden Empire"
	end

	if enemy_present and not enemy_owns then
		start_flash(scoreboard_enemyin)

		if billboard_enemyin then
			start_flash(billboard_enemyin)
		end
	else
		stop_flash(scoreboard_enemyin)

		if billboard_enemyin then
			stop_flash(billboard_enemyin, false)
		end
	end
end




local function setup_holster(player: Player, child: BoolValue)
	local reference =
		tool_holsters:FindFirstChild(child.Name) or
		gun_holsters:FindFirstChild(child.Name)

	if not reference then
		warn("[ScoringClient] No holster reference found for:", child.Name)
		return
	end

	local primary = reference.PrimaryPart
	if not primary then
		warn("[ScoringClient] No PrimaryPart on holster:", child.Name)
		return
	end

	local body_part_name = string.split(primary.Name, "_")[2]
	local char = player.Character
	if not char or not char:FindFirstChild(body_part_name) then
		warn("[ScoringClient] Missing body part:", body_part_name)
		return
	end

	local clone = reference:Clone()
	utilities.quick_weld(clone.PrimaryPart, char[body_part_name], clone, child.Name .. "_Weld")
	clone.Parent = char:WaitForChild("CharacterData"):WaitForChild("Rendered_Holsters")

	child:GetPropertyChangedSignal("Value"):Connect(function()
		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("Hide_On_Equip") then
				part.Transparency = child.Value and 0 or 1
			end
		end
	end)
end

local function remove_holster(player: Player, child: Instance)
	local char = player.Character
	if not char then return end
	local rendered = char:FindFirstChild("CharacterData")
		and char.CharacterData:FindFirstChild("Rendered_Holsters")
	if not rendered then return end
	local existing = rendered:FindFirstChild(child.Name)
	if existing then existing:Destroy() end
end

local function handle_accessory(player, child)
	if child:IsA("Model") then
		print("[REPLICANTSERVICE] Accessory is a model:", child.Name)
		return
	end
	if child:GetAttribute("Given") then 
		print("[REPLICANTSERVICE] Accessory is already given:", child.Name)
		return
	end

	local accessory = utilities.fetch_accessory(child.Name) 
	if not accessory then 
		print("[REPLICANTSERVICE] No accessory found for:", child.Name)
		return
	end

	local clone = utilities.quick_give_accessory(player, accessory, true, false, false)
	print("Gave accessory:", child.Name)
	child:SetAttribute("Given", true)


	-- // special child handling
	if child.Name == "LightEffect" then
		local spotlight_1:PointLight = clone.Torso.a0:FindFirstChildWhichIsA("SpotLight")
		local spotlight_2:PointLight = clone.Torso.a1:FindFirstChildWhichIsA("SpotLight")

		
		if player.Team.Name == "Golden Empire" then
			spotlight_1.Color = Color3.fromRGB(255, 210, 119)
			spotlight_2.Color = Color3.fromRGB(255, 210, 119)
		else
			spotlight_1.Color = Color3.fromRGB(196, 202, 255)
			spotlight_2.Color = Color3.fromRGB(196, 202, 255)
		end
	elseif child.Name == "Empire_Dogtag" or child.Name == "Nation_Dogtag" then
		local name_label = clone.chain_tag.tag.Surface.Username
		
		name_label.Text = player.Name
		print("Set dogtag name to:", player.Name)
	end
end

local function set_character_no_collision(char)
	for _, descendant in ipairs(char:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end

	char.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end)
end

local function on_character_added(char: Model, player: Player)
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Remove any existing billboard (handles respawns cleanly)
	local existing = hrp:FindFirstChild("Name_Billboard")
	if existing then existing:Destroy() end

	-- Handle accessories for the respawned player
	for _, child in pairs(player.GameData.Accessorys:GetChildren()) do
		if child:GetAttribute("ServerHandled") then
			print("[REPLICANTSERVICE] Skipping", child.Name, "handled by the server")
			continue
		end
		child:SetAttribute("Given", nil)
		handle_accessory(player, child)
	end

	-- Don't add a billboard for the local player themselves
	if player == local_player then return end

	-- Only add billboard if this player is a teammate/disable collision
	if player.Team == local_player.Team then
		set_character_no_collision(char)
		
		local clone = Name_Billboard:Clone()
		clone.Parent = hrp
		clone.playername.Text = "ARM " .. player.Name
	end
end

local function refresh_all_billboards()
	for _, p in ipairs(Players:GetPlayers()) do
		if p == local_player then continue end
		local char = p.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local existing = hrp:FindFirstChild("Name_Billboard")
		if existing then existing:Destroy() end

		if p.Team == local_player.Team then
			local clone = Name_Billboard:Clone()
			clone.Parent = hrp
			clone.playername.Text = "ARM " .. p.Name
		end
	end
end

local function handle_playerlist(player: Player)
	local PlayerList = Players.LocalPlayer.PlayerGui.Playerlist
	local EmpireList = PlayerList.playerlist.empirelist
	local NationList = PlayerList.playerlist.royallist
	local EmpireExample = EmpireList.Example
	local NationExample = NationList.Example

	local clone

	local function createEntry()
		local isEmpire = player.Team and player.Team.Name == "Golden Empire"

		print("[PlayerList] Creating entry for", player.Name, "Empire:", isEmpire)

		local template = isEmpire and EmpireExample or NationExample
		local parent = isEmpire and EmpireList or NationList

		clone = template:Clone()
		clone.Name = player.Name
		clone.Visible = true
		clone.playername.Text = player.Name
		clone.Parent = parent

		if player == local_player then
			if isEmpire then
				clone.bg.ImageColor3 = Color3.fromRGB(255, 255, 127)
				clone.classbg.ImageColor3 = Color3.fromRGB(255, 255, 127)
				clone.rankbg.ImageColor3 = Color3.fromRGB(255, 255, 127)
			else
				clone.bg.ImageColor3 = Color3.fromRGB(94, 6, 202)
				clone.classbg.ImageColor3 = Color3.fromRGB(94, 6, 202)
				clone.rankbg.ImageColor3 = Color3.fromRGB(94, 6, 202)
			end
		else
			clone.bg.ImageColor3 = Color3.fromRGB(0, 0, 0)
			clone.classbg.ImageColor3 = Color3.fromRGB(0, 0, 0)
			clone.rankbg.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end

		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				print("[PlayerList]", player.Name, "Current Health:", humanoid.Health)

				if humanoid.Health <= 0 then
					print("[PlayerList]", player.Name, "Already dead, enabling crossout.")
					clone.crossout.Visible = true
				else
					clone.crossout.Visible = false
				end
			else
				warn("[PlayerList]", player.Name, "No humanoid found.")
				clone.crossout.Visible = false
			end
		else
			print("[PlayerList]", player.Name, "No character yet.")
			clone.crossout.Visible = false
		end

		print("[PlayerList] Crossout initial:", clone.crossout.Visible)

		return clone
	end

	local function handleCharacter(character: Model)
		print("[PlayerList] handleCharacter:", player.Name)

		local humanoid = character:WaitForChild("Humanoid")

		print("[PlayerList]", player.Name, "Connected to humanoid:", humanoid)

		if clone then
			clone.crossout.Visible = humanoid.Health <= 0
			print("[PlayerList]", player.Name, "Initial health:", humanoid.Health, "Crossout:", clone.crossout.Visible)
		else
			warn("[PlayerList]", player.Name, "Clone missing during handleCharacter.")
		end

		humanoid.Died:Connect(function()
			print("[PlayerList] Died fired for", player.Name)

			if clone then
				print("[PlayerList] Clone exists:", clone, clone.Parent)

				if clone.Parent then
					clone.crossout.Visible = true
					print("[PlayerList] Crossout set TRUE for", player.Name, clone.crossout.Visible)
				else
					warn("[PlayerList] Clone has no parent for", player.Name)
				end
			else
				warn("[PlayerList] Clone nil when", player.Name, "died.")
			end
		end)
	end

	createEntry()

	local removingConnection
	removingConnection = Players.PlayerRemoving:Connect(function(leavingPlayer)
		if leavingPlayer == player then
			print("[PlayerList] Removing", player.Name)

			if clone then
				clone:Destroy()
			end

			removingConnection:Disconnect()
		end
	end)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		print("[PlayerList] Team changed for", player.Name)

		if clone then
			clone:Destroy()
		end

		createEntry()

		if player.Character then
			handleCharacter(player.Character)
		end
	end)

	if player.Character then
		handleCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		print("[PlayerList] CharacterAdded:", player.Name)
		handleCharacter(character)
	end)
end

local function setup_player(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	on_character_added(char, player)

	player.CharacterAdded:Connect(function(character)
		on_character_added(character, player)
	end)

	-- Refresh all billboards whenever any player switches teams
	player:GetPropertyChangedSignal("Team"):Connect(refresh_all_billboards)

	local game_data   = player:WaitForChild("GameData")
	local accessories = game_data:WaitForChild("Accessorys")
	local holsters    = accessories:WaitForChild("Holsters")

	for _, child in ipairs(holsters:GetChildren()) do
		task.spawn(setup_holster, player, child)
	end

	holsters.ChildAdded:Connect(function(child) setup_holster(player, child) end)
	holsters.ChildRemoved:Connect(function(child) remove_holster(player, child) end)

	for _, child in ipairs(accessories:GetChildren()) do
		task.spawn(handle_accessory, player, child)
	end

	accessories.ChildAdded:Connect(function(child)
		handle_accessory(player, child)
	end)
	
	handle_playerlist(player)
end





local function clear_overhead_connections()
	for _, conn in ipairs(overhead_connections) do
		conn:Disconnect()
	end
	table.clear(overhead_connections)
end

-- Returns the bar color for whichever team last pushed this point
local function get_cap_color(team_name: string?): Color3
	if team_name == "Golden Empire" then
		return Color3.new(1, 1, 0)
	elseif team_name == "Royal Nation" then
		return Color3.fromRGB(167, 83, 170)
	end
	-- Neutral fallback — progress should be 0 at this point anyway
	return Color3.fromRGB(167, 83, 170)
end

-- Applies progress to a bar.
-- Updates the remembered capping team when someone is actively pushing,
-- and leaves it unchanged during decay so the color persists.
local function apply_progress(
	point_name: string,
	progress_value: number,
	empire_count: IntValue,
	nation_count: IntValue,
	bar: Frame,
	sync_overhead: boolean
)
	local empire_n = empire_count.Value
	local nation_n = nation_count.Value

	-- deterministically resolve team
	local cap_team = nil
	if empire_n > nation_n then
		cap_team = "Golden Empire"
	elseif nation_n > empire_n then
		cap_team = "Royal Nation"
	end

	point_cap_team[point_name] = cap_team

	local color = get_cap_color(cap_team)
	local size  = UDim2.fromScale(1, progress_value / 20)

	-- scoreboard UI
	bar.BackgroundColor3 = color
	bar.Size = size

	-- billboard UI
	local billboard = get_billboard_ui(point_name)
	if billboard then
		local billboard_bar = billboard:FindFirstChild("bar")
		if billboard_bar and billboard_bar:IsA("Frame") then
			billboard_bar.BackgroundColor3 = color
			billboard_bar.Size = size
		end
	end

	-- overhead popup
	if sync_overhead then
		overhead_bar.BackgroundColor3 = color
		overhead_bar.Size = size
	end
end

local function apply_owner(
	owner_value: string,
	bar: Frame,
	bg_icon: ImageLabel,
	point_label: TextLabel,
	sync_overhead: boolean,
	point_name: string
)
	local billboard = get_billboard_ui(point_name)

	local billboard_bgicon
	local billboard_label
	local billboard_bar

	if billboard then
		billboard_bgicon = billboard:FindFirstChild("bgicon")
		billboard_label  = billboard:FindFirstChild("label")
		billboard_bar    = billboard:FindFirstChild("bar")
	end

	if owner_value == "Golden Empire" then
		local color = Color3.fromRGB(255, 255, 0)

		bg_icon.Image = ICONS.Golden_Empire_Background
		bg_icon.Visible = true
		bg_icon.ImageColor3 = color
		point_label.TextColor3 = color

		if billboard_bgicon then
			billboard_bgicon.Image = ICONS.Golden_Empire_Background
			billboard_bgicon.Visible = true
			billboard_bgicon.ImageColor3 = color
		end

		if billboard_label then
			billboard_label.TextColor3 = color
		end

		if billboard_bar then
			billboard_bar.BackgroundColor3 = color
		end

		if sync_overhead then
			overhead_bgicon.Image = ICONS.Golden_Empire_Background
			overhead_bgicon.Visible = true
			overhead_bgicon.ImageColor3 = color
			overhead_label.TextColor3 = color
		end

	elseif owner_value == "Royal Nation" then
		local color = Color3.fromRGB(146, 25, 167)

		bg_icon.Image = ICONS.Royal_Nation_Background
		bg_icon.Visible = true
		bg_icon.ImageColor3 = color
		point_label.TextColor3 = color

		if billboard_bgicon then
			billboard_bgicon.Image = ICONS.Royal_Nation_Background
			billboard_bgicon.Visible = true
			billboard_bgicon.ImageColor3 = color
		end

		if billboard_label then
			billboard_label.TextColor3 = color
		end

		if billboard_bar then
			billboard_bar.BackgroundColor3 = color
		end

		if sync_overhead then
			overhead_bgicon.Image = ICONS.Royal_Nation_Background
			overhead_bgicon.Visible = true
			overhead_bgicon.ImageColor3 = color
			overhead_label.TextColor3 = color
		end

	else
		bg_icon.Visible = false

		if billboard_bgicon then
			billboard_bgicon.Visible = false
		end

		if billboard_bar then
			billboard_bar.BackgroundColor3 = Color3.fromRGB(167, 83, 170)
		end

		if sync_overhead then
			overhead_bgicon.Visible = false
		end
	end
end

local function sync_overhead_to_point(point_name: string)
	clear_overhead_connections()

	local folder = gamemode_config:FindFirstChild(point_name .. "_Point")
	if not folder then
		warn("[ScoringClient] sync_overhead: missing folder for:", point_name)
		return
	end

	local empire_count = folder:FindFirstChild(point_name .. "_Empire_Count")
	local nation_count = folder:FindFirstChild(point_name .. "_Nation_Count")
	local progress     = folder:FindFirstChild(point_name .. "_Progress")
	local owner        = folder:FindFirstChild(point_name .. "_Owner")

	if not (empire_count and nation_count and progress and owner) then
		return
	end

	local control_ui         = objective_uis.control:FindFirstChild("objective" .. point_name)
	local bar                = control_ui and control_ui:FindFirstChild("bar")     :: Frame
	local bg_icon            = control_ui and control_ui:FindFirstChild("bgicon")  :: ImageLabel
	local point_label        = control_ui and control_ui:FindFirstChild("label")   :: TextLabel
	local scoreboard_enemyin = control_ui and control_ui:FindFirstChild("enemyin") :: Frame

	overhead_label.Text = point_name

	-- Initial sync immediately
	apply_owner(
		owner.Value,
		bar,
		bg_icon,
		point_label,
		true,
		point_name
	)

	apply_progress(
		point_name,
		progress.Value,
		empire_count,
		nation_count,
		bar,
		true
	)

	update_enemy_flash(
		empire_count,
		nation_count,
		owner,
		scoreboard_enemyin,
		point_name
	)

	table.insert(overhead_connections, progress.Changed:Connect(function()
		apply_progress(
			point_name,
			progress.Value,
			empire_count,
			nation_count,
			bar,
			true
		)
	end))

	table.insert(overhead_connections, owner.Changed:Connect(function()
		apply_owner(
			owner.Value,
			bar,
			bg_icon,
			point_label,
			true,
			point_name
		)

		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end))

	table.insert(overhead_connections, empire_count.Changed:Connect(function()
		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end))

	table.insert(overhead_connections, nation_count.Changed:Connect(function()
		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end))
end

local function bind_point_ui(point_name: string, control_ui: Frame)
	local folder = gamemode_config:FindFirstChild(point_name .. "_Point")
	if not folder then
		warn("[ScoringClient] Missing gamemode folder for:", point_name)
		return
	end

	local empire_count       = folder:FindFirstChild(point_name .. "_Empire_Count")
	local nation_count       = folder:FindFirstChild(point_name .. "_Nation_Count")
	local progress           = folder:FindFirstChild(point_name .. "_Progress")
	local owner              = folder:FindFirstChild(point_name .. "_Owner")
	local scoreboard_enemyin = control_ui:FindFirstChild("enemyin") :: Frame

	if not (empire_count and nation_count and progress and owner) then
		warn("[ScoringClient] Missing point values for:", point_name)
		return
	end

	local bar: Frame             = control_ui:FindFirstChild("bar")
	local bg_icon: ImageLabel    = control_ui:FindFirstChild("bgicon")
	local point_label: TextLabel = control_ui:FindFirstChild("label")

	-- Initial sync immediately
	apply_owner(
	owner.Value,
	bar,
	bg_icon,
	point_label,
	false,
	point_name
)

	apply_progress(
		point_name,
		progress.Value,
		empire_count,
		nation_count,
		bar,
		false
	)

	update_enemy_flash(
		empire_count,
		nation_count,
		owner,
		scoreboard_enemyin,
		point_name
	)

	-- Future updates
	progress.Changed:Connect(function()
		apply_progress(
			point_name,
			progress.Value,
			empire_count,
			nation_count,
			bar,
			false
		)
	end)

	owner.Changed:Connect(function()
		apply_owner(
			owner.Value,
			bar,
			bg_icon,
			point_label,
			false,
			point_name
		)

		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end)

	empire_count.Changed:Connect(function()
		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end)

	nation_count.Changed:Connect(function()
		update_enemy_flash(
			empire_count,
			nation_count,
			owner,
			scoreboard_enemyin,
			point_name
		)
	end)
end

local function bind_capture_point_proximity(model: Model, point_name: string)
	local capture = model:FindFirstChild("capture")
	if not capture then return end

	capture.Touched:Connect(function(hit)
		if hit.Parent ~= local_player.Character then return end
		if overhead_frame.Visible then return end
		overhead_frame.Visible = true
		sync_overhead_to_point(point_name)
	end)

	capture.TouchEnded:Connect(function(hit)
		if hit.Parent ~= local_player.Character then return end
		if not overhead_frame.Visible then return end
		overhead_frame.Visible = false
		stop_flash(overhead_enemyin)
		clear_overhead_connections()
	end)
end

local function handle_point_child(point_child: Instance)
	local control = objective_uis.control:FindFirstChild("objective" .. point_child.Name)
	if not control then
		warn("[ScoringClient] No objective UI found for:", point_child.Name)
		return
	end

	control.Visible = true
	local billboard = get_billboard_ui(point_child.Name)

	if billboard then
		local label = billboard:FindFirstChild("label")

		if label and label:IsA("TextLabel") then
			label.Text = point_child.Name
		end
	end
	bind_point_ui(point_child.Name, control)

	local model = point_child:FindFirstChildWhichIsA("Model")
	if model then
		bind_capture_point_proximity(model, point_child.Name)
	end
end

local function watch_all_points()
	local points_folder = workspace.Game_Details.Main_Game.Points
	for _, point in pairs(points_folder:GetChildren()) do
		point.ChildAdded:Connect(function() handle_point_child(point) end)
		if #point:GetChildren() > 0 then
			handle_point_child(point)
		end
	end
end

-- // concussion effects
local function stop_concussion_effect()
	if not concussion_active then return end
	concussion_active = false

	local concussion_ui = local_player.PlayerGui:WaitForChild("Status"):WaitForChild("Concussion")
	local lowhealth_imagelabel = concussion_ui.Low_Overlay
	local painoverlay_imagelabel = concussion_ui.Pain_Overlay

	-- fade-out control
	local start_time = tick()
	local FADE_OUT_DURATION = 0.5

	-- keep existing connection running, but switch it into "fade-out mode"
	if concussion_connection and concussion_connection.Connected then
		concussion_connection:Disconnect()
	end

	concussion_connection = RunService.RenderStepped:Connect(function()
		local t = tick()
		local elapsed = t - start_time

		-- 1 → 0
		local fade_alpha = 1 - math.clamp(elapsed / FADE_OUT_DURATION, 0, 1)

		-- smoothstep easing
		fade_alpha = fade_alpha * fade_alpha * (3 - 2 * fade_alpha)

		local pulse = math.sin(t * 1.5) / 10

		-- drive everything toward zero
		local target_intensity = (5 + math.abs(pulse * 50)) * fade_alpha
		blur.Size = blur.Size + (target_intensity - blur.Size) * 0.15

		if concussion_blur then
			local target_concussion_blur = (10 + math.abs(pulse * 60)) * fade_alpha
			concussion_blur.Size = concussion_blur.Size + (target_concussion_blur - concussion_blur.Size) * 0.15
		end

		-- UI scale collapses back to normal
		local scale = 1 + ((1.1 - pulse) - 1) * fade_alpha
		painoverlay_imagelabel.Size = painoverlay_imagelabel.Size:Lerp(
			UDim2.fromScale(scale, scale),
			0.15
		)

		-- fade to invisible
		lowhealth_imagelabel.ImageTransparency = 1 - fade_alpha
		painoverlay_imagelabel.ImageTransparency = 1 - fade_alpha

		-- fully done → cleanup
		if elapsed >= FADE_OUT_DURATION then
			lowhealth_imagelabel.ImageTransparency = 1
			painoverlay_imagelabel.ImageTransparency = 1

			blur.Size = 0

			if concussion_blur then
				concussion_blur.Size = 0
				concussion_blur.Enabled = false
			end

			if heartbeat_sound then
				heartbeat_sound:Stop()
				heartbeat_sound:Destroy()
				heartbeat_sound = nil
			end

	
			if concussion_connection then
				concussion_connection:Disconnect()
				concussion_connection = nil
			end
		end
	end)
end

local function start_concussion_effect()
	if concussion_active then return end
	concussion_active = true

	if concussion_blur then
		concussion_blur.Enabled = true
	end

	local concussion_ui = local_player.PlayerGui.Status.Concussion
	local lowhealth_imagelabel = concussion_ui.Low_Overlay
	local painoverlay_imagelabel = concussion_ui.Pain_Overlay

	lowhealth_imagelabel.ImageTransparency = 1
	painoverlay_imagelabel.ImageTransparency = 1

	-- fade-in control
	local start_time = tick()
	local FADE_IN_DURATION = 0.6 -- seconds

	concussion_connection = RunService.RenderStepped:Connect(function()
		local t = tick()
		local elapsed = t - start_time

		-- smooth ramp from 0 → 1
		local fade_alpha = math.clamp(elapsed / FADE_IN_DURATION, 0, 1)

		-- easing (optional but recommended)
		fade_alpha = fade_alpha * fade_alpha * (3 - 2 * fade_alpha) -- smoothstep

		local pulse = math.sin(t * 1.5) / 10

		-- blend pulse intensity with fade-in
		local target_intensity = (5 + math.abs(pulse * 50)) * fade_alpha
		blur.Size = blur.Size + (target_intensity - blur.Size) * 0.1

		if concussion_blur then
			local target_concussion_blur = (10 + math.abs(pulse * 60)) * fade_alpha
			concussion_blur.Size = concussion_blur.Size + (target_concussion_blur - concussion_blur.Size) * 0.1
		end

		-- UI fade-in + pulse scaling
		local scale = 1 + ((1.1 - pulse) - 1) * fade_alpha
		painoverlay_imagelabel.Size = painoverlay_imagelabel.Size:Lerp(
			UDim2.fromScale(scale, scale),
			0.1
		)

		-- transparency fades OUT (since 1 = invisible)
		lowhealth_imagelabel.ImageTransparency = 1 - fade_alpha
		painoverlay_imagelabel.ImageTransparency = 1 - fade_alpha

		-- Heartbeat timing
		if t - lastHeartbeatTime >= HEARTBEAT_INTERVAL then
			lastHeartbeatTime = t
			if heartbeat_sound then
				heartbeat_sound:Play()
			end
		end
	end)
end

local function update_concussion_state()
	local state = local_player:GetAttribute("Concussion") == true

	if state then
		start_concussion_effect()
	else
		stop_concussion_effect()
	end
end



module.flinch_local_player = function(direction)
	if local_player:GetAttribute("CantFlinch") then return end
	if tick() - last_flinched < flinch_cooldown then return end
	
	last_flinched = tick()
	local flinching_image_label_clone = local_player.PlayerGui.Flinching.flinch:Clone()
	flinching_image_label_clone.Visible = true
	flinching_image_label_clone.Parent = local_player.PlayerGui.Flinching
	
	local tween1 = TweenService:Create(flinching_image_label_clone, TweenInfo.new(0.6), {ImageTransparency = 1})
	tween1:Play()
	game.Debris:AddItem(flinching_image_label_clone, 1.6)
	
	local_player:SetAttribute("Flinch", direction)
	print("[ReplicantService] Local player is Flinching!", direction)
end


local function handle_fastcast_replication(...)
	local args = {...}

	local player = args[1]
	if player.Name == local_player.Name then return end

	local origin = args[2]
	local direction = args[3]
	local speed = args[4]
	local cast_data = args[5]

	-- Track event
	push_replication_event("FastCast", {
		Player = player.Name,
		Origin = origin,
		Direction = direction,
		Speed = speed
	})

	local caster, caster_data = utilities.setupFastCast(cast_data)
	caster:Fire(origin, direction, speed, caster_data)
	
	caster.LengthChanged:Connect(function(cast, position, segmentVelocity, segmentTravelDistance, segmentIndex)
		local bullet_pos = position + segmentVelocity.Unit * segmentTravelDistance

		if (bullet_pos - local_player.Character.HumanoidRootPart.Position).Magnitude < 18 then
			module.flinch_local_player(direction)
		end
	end)
end

local function handle_vfx_replication(...)
	local args = {...}

	local player = args[1]
	if player.Name == local_player.Name then
		return
	end

	local effect = args[2]
	local CFrame_Value = args[3]
	local emissions = args[4]
	local parent = args[5]
	local attach_to_parent = args[6]


	-- Track event
	push_replication_event("VFX", {
		Player = player.Name,
		Effect = effect.Name,
		Emissions = emissions,
		Attached = attach_to_parent
	})


	for _, child in ipairs(effect:GetDescendants()) do
		local emit_count = emissions[child.Name]

		if not emit_count then
			continue
		end


		local clone = child:Clone()
		local container


		if attach_to_parent then
			clone.Parent = parent
			container = clone

		else
			local part = Instance.new("Part")
			part.Size = Vector3.new(0.05, 0.05, 0.05)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = CFrame_Value
			part.Parent = workspace

			clone.Parent = part
			container = part
		end


		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emit_count)

			local lifetime = clone.Lifetime.Max

			task.delay(lifetime + 0.1, function()
				if container then
					container:Destroy()
				end
			end)
		end
	end
end

local function handle_texture_replication(...)
	local args = {...}

	local player = args[1]
	if player.Name == local_player.Name then return end

	local part = args[2]
	local position = args[3]
	local normal = args[4]
	local parent = args[5]

	-- Track event
	push_replication_event("Texture", {
		Player = player.Name,
		Texture = part.Name,
		Position = position
	})

	local texture_clone = part:Clone()
	texture_clone.CFrame = CFrame.new(position, position + normal)
	texture_clone.Parent = parent
end

local function handle_holster_replication(...)
	local args = {...}

	local player = args[1]
	local holster_name = args[2]
	local is_equipped = args[3]

	-- Track event
	push_replication_event("Holster", {
		Player = player.Name,
		Holster = holster_name,
		Equipped = is_equipped
	})
end




function module.handle_sfx_replication(...)
	local args = {...}
	local player = args[1]
	local sound_instance = args[2]
	if player == "BeginRound" then
		local clone
		if game.Players.LocalPlayer.Team.Name == "Golden Empire" then
			clone = EmpireStart:Clone()
		else
			clone = NationStart:Clone()
		end
		
		clone.Parent = game:GetService("SoundService")
		clone:Play()
		clone.Stopped:Connect(function()
			clone:Destroy()
		end)
		return
	else
		if not player or not sound_instance then return end
		
		local parent = args[3]
		local playback_speed = args[4] or sound_instance.PlaybackSpeed
		local volume = args[5] or sound_instance.Volume
		local pitch_shift = args[6] or 0
		local pitch_variation = args[7] or 0 --  pitch variation parameter

		local sound_clone = sound_instance:Clone()
		sound_clone.Parent = parent

		-- Set base pitch
		sound_clone.Pitch = sound_instance.Pitch or 1

		-- Apply pitch variation (same logic as the script)
		if pitch_variation and typeof(pitch_variation) == "number" then
			sound_clone.Pitch = sound_clone.Pitch + math.random(-pitch_variation * 100, pitch_variation * 100) / 100
		end

		-- Apply pitch shift (from PitchShiftSoundEffect)
		if pitch_shift ~= 0 then
			local pitch_sound = Instance.new("PitchShiftSoundEffect")
			
			pitch_sound.Octave = pitch_shift
			pitch_sound.Parent = sound_clone
		end

		sound_clone:Play()
		sound_clone.PlaybackSpeed = playback_speed
		sound_clone.Volume = volume

		sound_clone.Ended:Connect(function()
			sound_clone:Destroy()
		end)
	end
end

function module.handle_casing_replication(...)
	local args = {...}
	
	local player = args[1]
	local casing = args[2]
	local origin = args[3]
	local direction = args[4]
	
	local clone = casing:Clone()
	clone.Parent = workspace
	clone.CFrame = origin
	clone.Anchored = false; clone.CanCollide = true; clone.Transparency = 0

	local vel = direction or origin.LookVector * math.random(10, 15) + Vector3.new(0, math.random(10, 15), 0)

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = vel
	bv.Parent   = clone

	clone.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

	task.delay(0.1, function() bv:Destroy() end)

	task.delay(3, function() clone:Destroy() end)
	
	print("Casing replicated for player:", player.Name)
end

function module.connect_sfx(...)
	local args = {...}
	print("SFX replication received with:", args)
	module.handle_sfx_replication(...)
	
	-- // remove player from the args
	local player = args[1]
	table.remove(args, 1)
	
	
	sfx_replicant:FireServer(args)
end


local function placeUI()
	for _, child in pairs(game:GetService("ReplicatedStorage").Shared:WaitForChild("Library"):WaitForChild("UI"):GetChildren()) do
		child:Clone().Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	end
end
function module.start_module()
	placeUI()
	
	
	rebind_ui()

	fastcast_module.VisualizeCasts = visualize_casts_boolean.Value

	visualize_casts_boolean:GetPropertyChangedSignal("Value"):Connect(function()
		fastcast_module.VisualizeCasts = visualize_casts_boolean.Value
		print("[GameManager] Cast visualization set to", visualize_casts_boolean.Value)
	end)

	-- Setup existing players
	for _, player in pairs(Players:GetPlayers()) do
		setup_player(player)
	end
	Players.PlayerAdded:Connect(setup_player)

	-- Bind reinforcement count updates
	nation_rein_count:GetPropertyChangedSignal("Value"):Connect(function()
		update_bar(nation_frame, nation_rein_count.Value)
	end)
	nation_wave_timer:GetPropertyChangedSignal("Value"):Connect(function()
		update_wave_text(nation_frame, nation_wave_timer.Value)
	end)
	empire_rein_count:GetPropertyChangedSignal("Value"):Connect(function()
		update_bar(empire_frame, empire_rein_count.Value)
	end)
	empire_wave_timer:GetPropertyChangedSignal("Value"):Connect(function()
		update_wave_text(empire_frame, empire_wave_timer.Value)
	end)
	game_timer_val:GetPropertyChangedSignal("Value"):Connect(function()
		update_timer(timer_frame, game_timer_val.Value)
	end)
	gamemode_config.Gamemode_Type:GetPropertyChangedSignal("Value"):Connect(function()
		update_objective(gamemode_config.Gamemode_Type.Value)
	end)

	-- Rebind UI on character respawn
	local_player.CharacterAdded:Connect(rebind_ui)

	-- Watch capture points
	watch_all_points()

	-- Bind replication event handlers
	fastcast_replicant.OnClientEvent:Connect(handle_fastcast_replication)
	vfx_replicant.OnClientEvent:Connect(handle_vfx_replication)
	texture_replicant.OnClientEvent:Connect(handle_texture_replication)
	sfx_replicant.OnClientEvent:Connect(function(...)
		local args = {...}
		local player = args[1]
		
		if player == local_player then
			return
		end
		
		module.handle_sfx_replication(...)
	end)
	
	casing_replicant.OnClientEvent:Connect(function(...)
		local args = {...}
		local player = args[1]
		print("Casing replicated for player:", player.Name, "with:", args)
		
		if player == local_player then
			return
		end
		
		module.handle_casing_replication(...)
	end)

	-- Listen for changes
	local_player:GetAttributeChangedSignal("Concussion"):Connect(update_concussion_state)
	
	local_player:GetAttributeChangedSignal("Force_Flinch"):Connect(function()
		print("FLINCHING")
		if not local_player:GetAttribute("Force_Flinch") then
		print("FLINCHING CUT")	
		return end
		local_player:SetAttribute("Force_Flinch", nil)
		module.flinch_local_player(3)
		print("FLINCHING DONE")
	end)
	
	print("[ReplicantService] Module started successfully")
	bodies_folder.ChildAdded:Connect(function(ragdoll)
		print(ragdoll.Name, "is added to the bodies_folder.")
		
		local player_reference = Players:FindFirstChild(ragdoll.Name)
		if player_reference then
			print(player_reference.Name, "is found in the player list.")
			local player_accessories = player_reference.GameData.Accessorys
			
			for _, child in pairs(player_accessories:GetChildren()) do
				
				local accessory = utilities.fetch_accessory(child.Name) 
				if not accessory then 
					print("[REPLICANTSERVICE] No accessory found for:", child.Name)
					continue
				end
				
				utilities.create_object(ragdoll, accessory)
				print("Accessory created for:", child.Name)
			end
		end
	end)
	
	InputService.InputBegan:Connect(function(input, gps)
		if gps then return end
		
		if input.KeyCode == Enum.KeyCode.Tab then
			game.Players.LocalPlayer.PlayerGui.Playerlist.Enabled = true
		end
	end)
	
	InputService.InputEnded:Connect(function(input, gps)
		if gps then return end

		if input.KeyCode == Enum.KeyCode.Tab then
			game.Players.LocalPlayer.PlayerGui.Playerlist.Enabled = false
		end
	end)
	
	local_player.CharacterAdded:Connect(function()
		placeUI()
	end)
end

return module