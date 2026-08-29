-- // @Praxitos
-- // GameManagerService — handles rounds, spawning, final stand, and capture point logic

local Module = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ToolService = require(script.Parent.ItemsService)
local AccessoryService = require(script.Parent.AccessoryService)

-- // Shared folders
local Shared = ReplicatedStorage.Shared
local Library = Shared.Library
local Config = Library.Configuration.Scoring_Variables

local TerrainService = require(script.TerrainService)

-- // Scoring values
local EmpireReinCount = Config.Empire.Empire_Rein_Count
local EmpireReinWaveTimer = Config.Empire.Empire_Rein_Wave_Timer
local EmpireInfiniteRespawns = Config.Empire:FindFirstChild("Empire_Infinite_Tickets")
local NationInfiniteRespawns = Config.Nation:FindFirstChild("Nation_Infinite_Tickets")
local NationReinCount = Config.Nation.Nation_Rein_Count
local NationReinWaveTimer = Config.Nation.Nation_Rein_Wave_Timer
local GameTimer = Config.Timer.Game_Timer
local GamemodeFolder = Config.Gamemode
local CapturePointsCount = GamemodeFolder.Capture_Points_Count

local QuickRespawnsBoolean = Config.Parent.Game_Variables:FindFirstChild("Quick_Respawns")

local EmpireReinCountDefault = EmpireReinCount.Value
local NationReinCountDefault = NationReinCount.Value
local EmpireReinWaveTimerDefault = EmpireReinWaveTimer.Value
local NationReinWaveTimerDefault = NationReinWaveTimer.Value
local GameTimerDefault = GameTimer.Value

-- // Workspace references
local MainGame = workspace.Game_Details.Main_Game
local empireSpawn
local nationSpawn
local PointsFolder = MainGame.Points

-- // Asset references
local SpawnAnims = Shared:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Character"):WaitForChild("Spawns")
local CoreMaps = Shared.Assets.Maps["Core Maps"]

local Sounds = Shared:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Game")
local Tick = Sounds:WaitForChild("Countdown")

-- // Points billboard
local UiFolder = Shared.Assets.UI
local PointsBillboard = UiFolder.Points_Billboard

local TestingBoolean = Config.Parent.Game_Variables.Testing_Boolean
local VisualizeCastsBoolean = Config.Parent.Ranged_Variables.Visualizations.Visualize_Casts
local FastCastModule = require(Shared.Library.Externals.FastCast)
local ZonePlusModule = require(Shared.Library.Externals.Zone)

local SfxConnection = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Sounds")

-- // State
local timeTick = false
local roundActive = false
local intermissionTime = 20

local EmpireTeam = game.Teams["Golden Empire"]
local NationTeam = game.Teams["Royal Nation"]

local roundGeneration = 0
local roundEnding = false
local BeginRound
local TriggerRoundEnd

local hiatusPeriod = false
local hiatusTick = 180

-- // Constants
local ServerReadyTimeout = 5
local ItemGiveDelay = 0.5
local FinalStandGraceSeconds = 15

local EmpireCharGroup = "EmpireChar"
local NationCharGroup = "NationChar"
local EmpireWallGroup = "EmpireSpawnWalls"
local NationWallGroup = "NationSpawnWalls"

local FinalStandEvent =  SfxConnection.Parent.FinalStand

local function RegisterGroupSafe(name: string)
	local success, err = pcall(function()
		PhysicsService:RegisterCollisionGroup(name)
	end)
	if not success and not string.find(tostring(err), "already exists") then
		warn("[GameManager] Failed to register collision group", name, ":", err)
	end
end

local function SetupCollisionGroups()
	RegisterGroupSafe(EmpireCharGroup)
	RegisterGroupSafe(NationCharGroup)
	RegisterGroupSafe(EmpireWallGroup)
	RegisterGroupSafe(NationWallGroup)

	-- // Teammates don't collide.
	PhysicsService:CollisionGroupSetCollidable(EmpireCharGroup, EmpireCharGroup, false)
	PhysicsService:CollisionGroupSetCollidable(NationCharGroup, NationCharGroup, false)

	-- // Friendly spawn walls start SOLID — players are locked inside their
	-- // spawn during intermission. StartIntermission() flips this to false
	-- // once the countdown ends and the round begins, and flips it back to
	-- // true the next time intermission starts (see SetWallCollision).
	PhysicsService:CollisionGroupSetCollidable(EmpireCharGroup, EmpireWallGroup, true)
	PhysicsService:CollisionGroupSetCollidable(NationCharGroup, NationWallGroup, true)

	-- // Enemy spawn walls.
	PhysicsService:CollisionGroupSetCollidable(EmpireCharGroup, NationWallGroup, true)
	PhysicsService:CollisionGroupSetCollidable(NationCharGroup, EmpireWallGroup, true)

	-- // Enemy players still collide.
	PhysicsService:CollisionGroupSetCollidable(EmpireCharGroup, NationCharGroup, true)
end

-- // Tags every "basecolour" wall part under spawnRoom.Walls with wallGroup.
-- // Run once at server start since these are static map parts, not something
-- // that gets recreated each round.
local function TagSpawnWalls(spawnRoom: Model, wallGroup: string)
	local wallsFolder = spawnRoom:FindFirstChild("Walls")
	if not wallsFolder then
		warn("[GameManager] TagSpawnWalls: no Walls folder found under", spawnRoom.Name)
		return
	end

	local tagged = 0
	for _, child in ipairs(wallsFolder:GetChildren()) do
		if child.Name == "basecolour" and child:IsA("BasePart") then
			child.CollisionGroup = wallGroup
			-- // CanCollide must stay true for the physics engine to even
			-- // consider this part; the actual team-vs-team filtering now
			-- // happens entirely through the collision group pairing above,
			-- // not through this flag.
			child.CanCollide = true
			tagged += 1
		end
	end

	print("[GameManager] Tagged", tagged, "basecolour wall part(s) under", spawnRoom.Name, "as", wallGroup)
end

local function GetCharGroupForTeam(team: Team): string?
	if team == EmpireTeam then
		return EmpireCharGroup
	elseif team == NationTeam then
		return NationCharGroup
	end
	return nil
end

local function ApplyTeamCollisionGroup(character: Model, team: Team)
	local group = GetCharGroupForTeam(team)
	if not group then
		warn("[GameManager] ApplyTeamCollisionGroup: unrecognised team for", character.Name)
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
			descendant.CollisionGroup = group
		end
	end

	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
			descendant.CollisionGroup = group
		end
	end)
end

SetupCollisionGroups()

-- // Toggles whether players can walk through their OWN team's spawn walls.
-- // true  = walls are solid (used during intermission, players locked in spawn)
-- // false = walls are passable (used once the round begins)
local function SetWallCollision(collidable: boolean)
	PhysicsService:CollisionGroupSetCollidable(EmpireCharGroup, EmpireWallGroup, collidable)
	PhysicsService:CollisionGroupSetCollidable(NationCharGroup, NationWallGroup, collidable)
	print("[GameManager] Friendly spawn wall collision set to", collidable)
end

-- // Time

local function FormatTime(totalSeconds: number): string
	return string.format("%02d:%02d", math.floor(totalSeconds / 60), totalSeconds % 60)
end

local function BeginTime()
	local totalSeconds = 0

	if typeof(GameTimer.Value) == "string" then
		local min, sec = string.match(GameTimer.Value, "^(%d%d):(%d%d)$")
		if min and sec then
			totalSeconds = tonumber(min) * 60 + tonumber(sec)
		end
	end

	while timeTick do
		task.wait(1)
		totalSeconds += 1
		GameTimer.Value = FormatTime(totalSeconds)
	end
end

-- // Spawning

local function GetSpawnAnimation(spawnName: string): Animation?
	local folder = SpawnAnims:FindFirstChild(spawnName)
	if not folder then
		warn("[GameManager] No spawn animation folder for:", spawnName)
		return nil
	end

	local anims = folder:GetChildren()
	if #anims == 0 then
		warn("[GameManager] No animations in spawn folder:", spawnName)
		return nil
	end

	return anims[math.random(1, #anims)]
end

local function FindEmptySpawn(spawnRoom: Model): Instance
	for _, slot in pairs(spawnRoom.Spawns:GetChildren()) do
		if not slot:GetAttribute("Occupied") then
			return slot
		end
	end

	-- // All slots occupied — pick a random one as fallback
	local slots = spawnRoom.Spawns:GetChildren()
	return slots[math.random(1, #slots)]
end

local function HasEligiblePlayers(team: Team): boolean
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == team and not player:GetAttribute("Active") then
			return true
		end
	end
	return false
end

local function IsTeamWiped(team: Team): boolean
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team ~= team then
			continue
		end

		local character = player.Character
		if not character then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			return false
		end
	end

	return true
end

-- // Final stand

local finalStandState: { [Player]: { in_spawn: boolean, timer_thread: thread?, highlight: Highlight? } } = {}
local finalStandGeneration: { [Team]: number? } = {}
local teamSpawnParts: { [Team]: BasePart } = {} -- populated in Module.StartModule

-- // True if the character's HumanoidRootPart is within part's oriented bounding box.
local function IsCharacterWithinPart(character: Model?, part: BasePart?): boolean
	if not character or not part then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false
	end

	local relative = part.CFrame:PointToObjectSpace(root.Position)
	local half = part.Size / 2

	return math.abs(relative.X) <= half.X
		and math.abs(relative.Y) <= half.Y
		and math.abs(relative.Z) <= half.Z
end

local function GetFinalStandState(player: Player)
	local state = finalStandState[player]
	if not state then
		state = { in_spawn = true, timer_thread = nil, highlight = nil }
		finalStandState[player] = state
		print("[FinalStand]", player.Name, "- created fresh state (in_spawn=true by default)")
	end
	return state
end

local function ClearFinalStandHighlight(player: Player)
	local state = finalStandState[player]
	if not state then
		print("[FinalStand]", player.Name, "- ClearFinalStandHighlight called but no state exists yet, nothing to do")
		return
	end

	if state.timer_thread then
		print("[FinalStand]", player.Name, "- cancelling pending grace timer")
		task.cancel(state.timer_thread)
		state.timer_thread = nil
	end

	if state.highlight then
		print("[FinalStand]", player.Name, "- removing active highlight")
		state.highlight:Destroy()
		state.highlight = nil
	end
end

local function ApplyFinalStandHighlight(player: Player, team: Team)
	print("[FinalStand]", player.Name, "- attempting to apply highlight for team", team.Name)

	local state = GetFinalStandState(player)
	if state.highlight then
		print("[FinalStand]", player.Name, "- already has a highlight, skipping")
		return
	end

	local character = player.Character
	if not character then
		print("[FinalStand]", player.Name, "- no character present, cannot highlight")
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "FinalStandHighlight"
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.FillColor = team == EmpireTeam and Color3.fromRGB(240, 240, 140) or Color3.fromRGB(146, 25, 167)
	highlight.Parent = character
	state.highlight = highlight

	print("[GameManager] Final stand highlight applied to", player.Name)
	print("[FinalStand]", player.Name, "- highlight instance created and parented to", character:GetFullName())

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Once(function()
			print("[FinalStand]", player.Name, "- died, clearing highlight via Died connection")
			ClearFinalStandHighlight(player)
		end)
	else
		print("[FinalStand]", player.Name, "- WARNING: no Humanoid found, Died cleanup not wired")
	end
end

local function StartFinalStandTimer(player: Player, team: Team, generation: number)
	local state = GetFinalStandState(player)

	-- // Only one grace timer can exist.
	if state.timer_thread then
		return
	end

	state.timer_thread = task.spawn(function()
		task.wait(FinalStandGraceSeconds)

		state.timer_thread = nil

		-- // Final stand ended or restarted.
		if finalStandGeneration[team] ~= generation then
			return
		end

		-- // Player left the game.
		if not player.Parent then
			return
		end

		-- // Grace has now been consumed.
		state.grace_used = true

		-- // If they made it back inside before grace expired,
		-- // don't highlight them.
		if state.in_spawn then
			return
		end

		-- // Still outside after grace -> highlight them.
		ApplyFinalStandHighlight(player, team)
	end)
end

-- // Continuously tracks every player's in/out-of-spawn state via direct
-- // geometry, independent of whether final stand is active. This is the only
-- // place that decides in/out — final stand just reads finalStandGeneration
-- // to decide whether an "exited" transition should start a grace timer.
local function TrackSpawnMembership()
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local team = player.Team
				if team ~= EmpireTeam and team ~= NationTeam then
					continue
				end

				local character = player.Character
				if not character then
					continue
				end

				local spawnPart = teamSpawnParts[team]
				local currentlyInSpawn = IsCharacterWithinPart(character, spawnPart)

				local state = GetFinalStandState(player)

				if state.in_spawn == currentlyInSpawn then
					continue
				end

				state.in_spawn = currentlyInSpawn

				if currentlyInSpawn then
					-- // Returning inside always removes the highlight.
					if state.highlight then
						ClearFinalStandHighlight(player)
					end
				else
					local generation = finalStandGeneration[team]
					if not generation then
						continue
					end

					-- // Haven't used the team's initial grace yet.
					if not state.grace_used then
						state.grace_used = true
						StartFinalStandTimer(player, team, generation)
					else
						-- // Grace already happened. Leaving spawn immediately
						-- // gives the highlight.
						ApplyFinalStandHighlight(player, team)
					end
				end
			end

			task.wait(0.25)
		end
	end)
end

local function StartFinalStand(losingTeam: Team, generation: number)
	finalStandGeneration[losingTeam] = generation
	print("[GameManager] Final stand begun for", losingTeam.Name, "- generation", generation)

	FinalStandEvent:FireAllClients(losingTeam.Name)
	print("[FinalStandEvent] Fired!")

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team ~= losingTeam then
			continue
		end

		local state = GetFinalStandState(player)

		state.grace_used = false

		StartFinalStandTimer(player, losingTeam, generation)
	end
end

local function EndFinalStand(losingTeam: Team)
	print("[FinalStand] === EndFinalStand:", losingTeam.Name, "(was generation", finalStandGeneration[losingTeam], ") ===")
	finalStandGeneration[losingTeam] = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == losingTeam then
			ClearFinalStandHighlight(player)
		end
	end

	print("[GameManager] Final stand ended for", losingTeam.Name)
end

Players.PlayerRemoving:Connect(function(player)
	print("[FinalStand]", player.Name, "- PlayerRemoving, clearing final stand state")
	ClearFinalStandHighlight(player)
	finalStandState[player] = nil
end)

local function GiveStartingEquipment(player: Player, character: Model)
	if not player or not player.Parent then
		return
	end
	if not character or character.Parent == nil then
		return
	end

	local playerData = player:WaitForChild("PlayerData")
	if not playerData then
		warn("[GameManager] No PlayerData found for", player.Name, "- cannot give items.")
		return
	end

	local playerDataFolder = playerData:WaitForChild("PlayerData")
	if not playerDataFolder then
		warn("[GameManager] PlayerData.PlayerData never appeared for", player.Name, "- cannot give items.")
		return
	end

	local equipment = playerDataFolder:WaitForChild("Equipment")
	if not equipment then
		warn("[GameManager] No Equipment folder for", player.Name, "- cannot give items.")
		return
	end

	local primaryTool = equipment:WaitForChild("Primary")
	local secondaryTool = equipment:WaitForChild("Secondary")

	-- // Bail out early and loudly instead of silently handing out nothing.
	if not primaryTool or primaryTool.Value == "" then
		warn("[GameManager]", player.Name, "has no Primary tool set — skipping.")
	else
		ToolService.give_item(player, primaryTool.Value)
	end

	if not secondaryTool or secondaryTool.Value == "" then
		warn("[GameManager]", player.Name, "has no Secondary tool set — skipping.")
	else
		ToolService.give_item(player, secondaryTool.Value)
	end

	ToolService.give_item(player, "Compass")
	ToolService.give_item(player, "Medkit")
	ToolService.give_item(player, "Pickaxe")

	if character and character.Parent then
		character:SetAttribute("Equipment", "AmmoPack")
	end

	print("[GameManager] Gave starting equipment to", player.Name)
end

local function EquipWhenReady(player: Player, character: Model)
	if character:GetAttribute("StartingEquipmentScheduled") then return end
	character:SetAttribute("StartingEquipmentScheduled", true)

	task.spawn(function()
		local deadline = tick() + ServerReadyTimeout

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

		task.wait(ItemGiveDelay)

		if not player.Character or player.Character ~= character then
			return
		end

		GiveStartingEquipment(player, character)
	end)
end

local function SpawnAndEquipPlayer(player: Player, spawnRoom: Model)
	if not spawnRoom then
		warn("[GameManager] SpawnAndEquipPlayer called with no spawnRoom for", player.Name)
		return
	end

	player:SetAttribute("Active", true)
	player:LoadCharacterAsync()

	local character = player.Character or player.CharacterAdded:Wait()
	local slot = FindEmptySpawn(spawnRoom)

	slot:SetAttribute("Occupied", true)
	character:PivotTo(slot.CFrame)
	ApplyTeamCollisionGroup(character, player.Team)

	-- // Freshly spawned characters start inside their spawn room.
	local state = GetFinalStandState(player)
	state.in_spawn = true
	ClearFinalStandHighlight(player)
	print("[FinalStand]", player.Name, "- spawned/respawned, forcing in_spawn=true and clearing any stale highlight")

	local animTrack: AnimationTrack?
	local animation = GetSpawnAnimation(slot.Name)

	if animation then
		local animator = character:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")
		if animator then
			animTrack = animator:LoadAnimation(animation)
			animTrack:Play()
		end
	end

	character:SetAttribute("DontRotate", true)

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	task.spawn(function()
		while character.Parent and humanoid.Health > 0 do
			if humanoid.MoveDirection.Magnitude > 0 then
				slot:SetAttribute("Occupied", nil)

				if animTrack then
					animTrack.Looped = false
					animTrack:Stop()
				end

				character:SetAttribute("DontRotate", nil)
				break
			end

			task.wait()
		end
	end)

	humanoid.Died:Connect(function()
		slot:SetAttribute("Occupied", nil)

		if animTrack then
			animTrack:Stop()
		end
	end)

	EquipWhenReady(player, character)

	return character
end

local function SpawnWave(team: Team)
	print("[GameManager] Spawning reinforcements for:", team.Name)

	local teamName = team.Name
	local spawnRoom = teamName == "Golden Empire" and empireSpawn or nationSpawn

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team ~= team or player:GetAttribute("Active") then
			continue
		end

		SpawnAndEquipPlayer(player, spawnRoom)
	end
end

local function HandleReinforcementWave(
	reinCount: IntValue,
	waveTimer: IntValue,
	team: Team,
	infiniteRespawns: BoolValue?,
	myGeneration: number
)
	print("[GameManager] Reinforcement wave loop started for", team.Name, "- round generation", myGeneration)

	while true do
		if myGeneration ~= roundGeneration then
			print("[GameManager] Reinforcement wave loop for", team.Name, "stopping — stale generation", myGeneration, "(current is", roundGeneration, ")")
			return
		end

		if not roundActive then
			task.wait(1)
			continue
		end

		if reinCount.Value <= 0 then
			print("[GameManager]", team.Name, "reinforcement count has reached 0 — no more waves will spawn for this team.")
			TriggerRoundEnd(team, myGeneration)
			return
		end

		if waveTimer.Value > 0 then
			task.wait(1)
			waveTimer.Value -= 1
			continue
		end

		if not HasEligiblePlayers(team) then
			task.wait(1)
			continue
		end

		task.wait(3)
		SpawnWave(team)

		if not (infiniteRespawns and infiniteRespawns.Value == true) then
			reinCount.Value -= 1
			print("[GameManager]", team.Name, "reinforcements remaining:", reinCount.Value)
		end

		if QuickRespawnsBoolean and QuickRespawnsBoolean.Value == true then
			waveTimer.Value = 1
		else
			waveTimer.Value = 30
		end
	end
end

TriggerRoundEnd = function(losingTeam: Team, myGeneration: number)
	if myGeneration ~= roundGeneration then
		print("[GameManager] Ignoring reinforcement-depletion trigger from", losingTeam.Name, "— round already moved on to generation", roundGeneration)
		return
	end

	if roundEnding then
		print("[GameManager] Round end already in progress — ignoring duplicate trigger from", losingTeam.Name)
		return
	end

	roundEnding = true

	local winningTeam = (losingTeam == EmpireTeam) and NationTeam or EmpireTeam

	print("[GameManager] ==================================================")
	print(string.format("[GameManager] %s is out of reinforcements. %s has won the round! Entering final stand.", losingTeam.Name, winningTeam.Name))
	print("[GameManager] Waiting for all remaining", losingTeam.Name, "players to die before ending the round...")
	print("[GameManager] ==================================================")

	-- // Round stays active during final stand — losing team can still fight,
	-- // just with no more reinforcements coming and a highlight risk if they
	-- // linger outside their spawn.
	StartFinalStand(losingTeam, myGeneration)

	local waitTicks = 0
	while myGeneration == roundGeneration and not IsTeamWiped(losingTeam) do
		waitTicks += 1
		if waitTicks % 10 == 0 then -- roughly every 5s
			print("[FinalStand] Still waiting for", losingTeam.Name, "to be wiped (generation", myGeneration, ", elapsed ~", waitTicks * 0.5, "s)")
		end
		task.wait(0.5)
	end

	if myGeneration ~= roundGeneration then
		print("[GameManager] Round was restarted externally while waiting for", losingTeam.Name, "to be wiped — aborting stale round-end sequence.")
		EndFinalStand(losingTeam)
		return
	end

	roundActive = false
	timeTick = false
	EndFinalStand(losingTeam)

	print("[GameManager]", losingTeam.Name, "has been fully wiped out. Ending round", myGeneration, "and starting a new one.")
	print("[GameManager] Returning to Hiatus Period")
	hiatusPeriod = true

	for _, player in ipairs(Players:GetPlayers()) do
		player.PlayerGui.Hiatus.Enabled = true
	end

	-- // yes i know this looks horrible. i know. blame me. -- Praxitos
	while hiatusTick > 0 do
		task.wait(1)
		hiatusTick -= 1

		for _, player in ipairs(Players:GetPlayers()) do
			local kills = player:GetAttribute("RoundKills") or 0

			player.PlayerGui.Hiatus.Main.TextLabel.Text = [[This is your time to put all your bugs within <font color="rgb(212, 105, 20)">'Found Bugs'</font> thread for this specific test session.

Testing will resume in ]] .. hiatusTick .. [[ seconds.

You have killed <font color="rgb(255, 80, 80)">]] .. kills .. [[</font> people.]]
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		player.PlayerGui.Hiatus.Enabled = false
	end

	BeginRound()
end

-- // Capture points

local function SetBillboardUI(pointParent: Part)
	local billboardUiClone = PointsBillboard:Clone()
	billboardUiClone.Parent = pointParent
end

local function SelectRandomMap(): Model
	local maps = CoreMaps:GetChildren()
	return maps[math.random(1, #maps)]
end

local function PlaceMap(map: Model, point: Instance)
	map:PivotTo(point.CFrame)
	map.Parent = point
end

local function CarveAirBlock(map: Model)
	local air = map:FindFirstChild("air")
	if not air then
		return
	end
	workspace.Terrain:FillBlock(air.CFrame, air.Size, Enum.Material.Air)
end

local function SetupCapturePoint(point: Instance, model: Model, myGeneration: number)
	if not point or not model then
		return
	end

	local capturePart: Part = model:FindFirstChild("capture")
	local pointData = GamemodeFolder:FindFirstChild(point.Name .. "_Point")

	if not pointData then
		warn("[GameManager] Missing point data folder for:", point.Name)
		return
	end

	if not capturePart then
		warn("[GameManager] Missing 'capture' part in map for point:", point.Name)
		return
	end

	SetBillboardUI(point)

	local empireCount = pointData:FindFirstChild(point.Name .. "_Empire_Count")
	local nationCount = pointData:FindFirstChild(point.Name .. "_Nation_Count")
	local progress = pointData:FindFirstChild(point.Name .. "_Progress")
	local owner = pointData:FindFirstChild(point.Name .. "_Owner")
	local progressOwner = pointData:FindFirstChild(point.Name .. "_Progress_Owner")

	if not (empireCount and nationCount and progress and owner and progressOwner) then
		warn("[GameManager] Missing value objects in point data:", pointData.Name)
		return
	end

	-- // These value objects live in ReplicatedStorage and persist across
	-- // rounds, so reset them back to a clean slate for the new round.
	empireCount.Value = 0
	nationCount.Value = 0
	progress.Value = 0
	owner.Value = ""
	progressOwner.Value = ""

	print("[GameManager] Initialising point:", point.Name, "for round generation", myGeneration)

	local playersOnPoint: { [Player]: true } = {}

	local function RemovePlayer(player: Player)
		if not playersOnPoint[player] then
			return
		end
		playersOnPoint[player] = nil

		if player.Team == EmpireTeam then
			empireCount.Value = math.max(0, empireCount.Value - 1)
		elseif player.Team == NationTeam then
			nationCount.Value = math.max(0, nationCount.Value - 1)
		end

		print("[GameManager]", point.Name, "left by", player.Name)
	end

	local function AddPlayer(player: Player)
		if playersOnPoint[player] then
			return
		end
		if player.Team ~= EmpireTeam and player.Team ~= NationTeam then
			return
		end

		playersOnPoint[player] = true

		if player.Team == EmpireTeam then
			empireCount.Value += 1
		elseif player.Team == NationTeam then
			nationCount.Value += 1
		end

		-- // Clean up if the player dies while on the point
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Died:Once(function()
					RemovePlayer(player)
				end)
			end
		end

		print("[GameManager]", point.Name, "entered by", player.Name)
	end

	-- // ZonePlus handles character resolution for us (and won't fire on
	-- // ragdolls/limbs the way raw Touched events could), so we just react
	-- // to playerEntered/playerExited directly.
	local captureZone = ZonePlusModule.new(capturePart)

	local zoneEnteredConnection = captureZone.playerEntered:Connect(function(player)
		AddPlayer(player)
	end)

	local zoneExitedConnection = captureZone.playerExited:Connect(function(player)
		RemovePlayer(player)
	end)

	-- // Clean up if a player leaves the game entirely
	local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		RemovePlayer(player)
	end)

	-- // Capture loop
	task.spawn(function()
		while true do
			task.wait(1)

			if myGeneration ~= roundGeneration then
				print("[GameManager] Capture loop for", point.Name, "stopping — stale generation", myGeneration, "(current is", roundGeneration, ")")
				zoneEnteredConnection:Disconnect()
				zoneExitedConnection:Disconnect()
				playerRemovingConnection:Disconnect()
				captureZone:destroy()
				return
			end

			local empireN = empireCount.Value
			local nationN = nationCount.Value
			local total = empireN + nationN

			-- // Award ownership at full progress
			if progress.Value == 20 then
				if empireN > nationN then
					owner.Value = "Golden Empire"
					print("[GameManager] Point captured by Empire:", point.Name)
				elseif nationN > empireN then
					owner.Value = "Royal Nation"
					print("[GameManager] Point captured by Nation:", point.Name)
				else
					owner.Value = ""
				end
				progress.Value = 0
				progressOwner.Value = ""
			end

			-- // Decay when nobody is on the point
			if total == 0 then
				if progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then
						progressOwner.Value = ""
					end
				end
				continue
			end

			-- // Stall when teams are even
			if empireN == nationN then
				print("[GameManager]", point.Name, "contested — stalling.")
				continue
			end

			if empireN > nationN then
				if owner.Value == "Golden Empire" then
					continue
				end

				-- // Drain enemy progress first before advancing
				if progressOwner.Value == "Royal Nation" and progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then
						progressOwner.Value = ""
					end
					print("[GameManager]", point.Name, "Empire draining Nation progress.")
				else
					progressOwner.Value = "Golden Empire"
					progress.Value += 1
					print("[GameManager]", point.Name, "being capped by Empire.")
				end
			else
				if owner.Value == "Royal Nation" then
					continue
				end

				-- // Drain enemy progress first before advancing
				if progressOwner.Value == "Golden Empire" and progress.Value > 0 then
					progress.Value -= 1
					if progress.Value == 0 then
						progressOwner.Value = ""
					end
					print("[GameManager]", point.Name, "Nation draining Empire progress.")
				else
					progressOwner.Value = "Royal Nation"
					progress.Value += 1
					print("[GameManager]", point.Name, "being capped by Nation.")
				end
			end
		end
	end)
end

local function SetBaseColours(spawnRoom: Model, value: boolean)
	for _, child in pairs(spawnRoom.Walls:GetChildren()) do
		if child.Name ~= "basecolour" then
			continue
		end
		
		if not child:IsA("BasePart") then
			continue
		end

		child.Transparency = value == true and 0 or 1
	end
end

local function GetSpawnRoomFor(player: Player): Model?
	if player.Team == EmpireTeam then
		return empireSpawn
	elseif player.Team == NationTeam then
		return nationSpawn
	end
	return nil
end

local function StartIntermission()
	print("[GameManager] Starting intermission.")

	SetBaseColours(empireSpawn, true)
	SetBaseColours(nationSpawn, true)
	SetWallCollision(true) -- lock players inside their spawn for the new intermission

	for _, player in ipairs(Players:GetPlayers()) do
		local spawnRoom = GetSpawnRoomFor(player)
		if spawnRoom then
			SpawnAndEquipPlayer(player, spawnRoom)
		end
	end

	local playerAddedConnection
	playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		local spawnRoom = GetSpawnRoomFor(player)
		if spawnRoom then
			SpawnAndEquipPlayer(player, spawnRoom)
		end
	end)

	-- // Countdown
	for i = intermissionTime, 1, -1 do
		print("[GameManager] Round starts in:", i)
		if i <= 5 and i ~= 1 then
			local tickClone = Tick:Clone()
			tickClone.Parent = game:GetService("SoundService")
			tickClone:Play()
			tickClone.Stopped:Connect(function()
				tickClone:Destroy()
			end)
		elseif i == 1 then
			SfxConnection:FireAllClients("BeginRound")
			print("[GameManager] Intermission over, round begins.")
		end
		task.wait(1)
	end

	playerAddedConnection:Disconnect()

	print("[GameManager] Intermission complete.")

	roundActive = true

	SetBaseColours(empireSpawn, false)
	SetBaseColours(nationSpawn, false)
	SetWallCollision(false) -- release players from spawn now that the round has begun
end

-- // Round start / restart
BeginRound = function()
	roundGeneration += 1
	local generation = roundGeneration
	roundEnding = false

	print("[GameManager] ==================================================")
	print("[GameManager] Beginning round — generation", generation)
	print("[GameManager] ==================================================")

	-- // Reset scoring values back to their configured defaults
	EmpireReinCount.Value = EmpireReinCountDefault
	NationReinCount.Value = NationReinCountDefault
	EmpireReinWaveTimer.Value = EmpireReinWaveTimerDefault
	NationReinWaveTimer.Value = NationReinWaveTimerDefault
	GameTimer.Value = GameTimerDefault

	print("[GameManager] Reset Empire reinforcements to", EmpireReinCount.Value)
	print("[GameManager] Reset Nation reinforcements to", NationReinCount.Value)
	print("[GameManager] Reset Empire wave timer to", EmpireReinWaveTimer.Value)
	print("[GameManager] Reset Nation wave timer to", NationReinWaveTimer.Value)
	print("[GameManager] Reset game timer to", GameTimer.Value)

	-- // set terrain
	TerrainService.FillTerrain()
	TerrainService.RandomizeSpawnRooms()
	print("[GameManager] Applying Terrain")

	-- // Helper: apply infinite tickets for a team immediately
	local function ApplyInfiniteTickets(reinCount: IntValue, teamName: string)
		reinCount.Value = 999
		print("[GameManager]", teamName, "infinite tickets enabled — set to 999.")
	end

	-- // Helper: apply quick respawns to a wave timer immediately
	local function ApplyQuickRespawns(waveTimer: IntValue, teamName: string)
		waveTimer.Value = 1
		print("[GameManager] Quick respawns enabled for", teamName, "— wave timer set to 1.")
	end

	if EmpireInfiniteRespawns and EmpireInfiniteRespawns.Value == true then
		ApplyInfiniteTickets(EmpireReinCount, "Empire")
	end

	if NationInfiniteRespawns and NationInfiniteRespawns.Value == true then
		ApplyInfiniteTickets(NationReinCount, "Nation")
	end

	if QuickRespawnsBoolean and QuickRespawnsBoolean.Value == true then
		ApplyQuickRespawns(EmpireReinWaveTimer, "Empire")
		ApplyQuickRespawns(NationReinWaveTimer, "Nation")
	end

	-- // Clear out any leftover capture point maps from the previous round so
	-- // the point-assignment pass below sees them as empty again.
	for _, point in ipairs(PointsFolder:GetChildren()) do
		local leftover = point:GetChildren()
		if #leftover > 0 then
			print("[GameManager] Clearing", #leftover, "leftover object(s) from point:", point.Name)
			for _, child in ipairs(leftover) do
				child:Destroy()
			end
		end
	end

	task.spawn(StartIntermission)

	timeTick = true
	task.spawn(BeginTime)

	task.spawn(HandleReinforcementWave,
		EmpireReinCount,
		EmpireReinWaveTimer,
		EmpireTeam,
		EmpireInfiniteRespawns,
		generation
	)

	task.spawn(HandleReinforcementWave,
		NationReinCount,
		NationReinWaveTimer,
		NationTeam,
		NationInfiniteRespawns,
		generation
	)

	-- // Assign a random map to each active capture point.
	-- // Build a pool of empty, unassigned points up front and pop from it,
	-- // so we can never loop forever looking for a valid point.
	local allPoints = PointsFolder:GetChildren()
	local emptyPoints: { Instance } = {}

	for _, point in ipairs(allPoints) do
		if #point:GetChildren() == 0 then
			table.insert(emptyPoints, point)
		end
	end

	local activePoints: { Instance } = {}

	local pointsToAssign = math.min(CapturePointsCount.Value, #emptyPoints)
	if pointsToAssign < CapturePointsCount.Value then
		warn(string.format(
			"[GameManager] Only %d empty capture point(s) available, but Capture_Points_Count wants %d.",
			#emptyPoints, CapturePointsCount.Value
			))
	end

	for i = 1, pointsToAssign do
		local map = SelectRandomMap()

		local index = math.random(1, #emptyPoints)
		local point = table.remove(emptyPoints, index)

		PlaceMap(map, point)
		CarveAirBlock(map)
		SetupCapturePoint(point, map, generation)
		table.insert(activePoints, point)

		print("[GameManager] Assigned map", map.Name, "to point", point.Name)
	end

	print("[GameManager] Round", generation, "set up with", #activePoints, "active capture point(s).")

	-- // Ticket drain loop
	-- // Every 3 seconds, each point owned by a team drains (3 * P / n) tickets from
	-- // the enemy, where P = points owned by that team and n = total active points.
	-- // Infinite-ticket sides are immune to draining.
	task.spawn(function()
		local n = #activePoints
		if n == 0 then
			return
		end

		print("[GameManager] Ticket drain loop started for round generation", generation)

		while true do
			task.wait(3)

			if generation ~= roundGeneration then
				print("[GameManager] Ticket drain loop stopping — stale generation", generation, "(current is", roundGeneration, ")")
				return
			end

			local empireOwned = 0
			local nationOwned = 0

			for _, point in ipairs(activePoints) do
				local pointData = GamemodeFolder:FindFirstChild(point.Name .. "_Point")
				if not pointData then
					continue
				end

				local owner = pointData:FindFirstChild(point.Name .. "_Owner")
				if not owner then
					continue
				end

				if owner.Value == "Golden Empire" then
					empireOwned += 1
				elseif owner.Value == "Royal Nation" then
					nationOwned += 1
				end
			end

			-- // Empire-owned points drain Nation tickets (skip if Nation has infinite tickets)
			if empireOwned > 0 then
				if NationInfiniteRespawns and NationInfiniteRespawns.Value == true then
					print("[GameManager] Nation infinite tickets — drain skipped.")
				else
					local totalDrain = 3 * empireOwned / n
					NationReinCount.Value = math.max(0, math.floor(NationReinCount.Value - totalDrain))
					print(string.format(
						"[GameManager] Empire owns %d/%d points — draining %.2f tickets from Nation.",
						empireOwned, n, totalDrain
						))
				end
			end

			-- // Nation-owned points drain Empire tickets (skip if Empire has infinite tickets)
			if nationOwned > 0 then
				if EmpireInfiniteRespawns and EmpireInfiniteRespawns.Value == true then
					print("[GameManager] Empire infinite tickets — drain skipped.")
				else
					local totalDrain = 3 * nationOwned / n
					EmpireReinCount.Value = math.max(0, math.floor(EmpireReinCount.Value - totalDrain))
					print(string.format(
						"[GameManager] Nation owns %d/%d points — draining %.2f tickets from Empire.",
						nationOwned, n, totalDrain
						))
				end
			end
		end
	end)

	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			player:SetAttribute("RoundKills", 0)
		end
	end)
end

-- // Module entry

function Module.start_module()
	TerrainService.start_module()

	local function track_player(player: Player)
		player.CharacterAdded:Connect(function(character)
			EquipWhenReady(player, character)
		end)
		if player.Character then
			EquipWhenReady(player, player.Character)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		track_player(player)
	end
	Players.PlayerAdded:Connect(track_player)

	empireSpawn = MainGame:WaitForChild("Empire")
	nationSpawn = MainGame:WaitForChild("Nation")
	TagSpawnWalls(empireSpawn, EmpireWallGroup)
	TagSpawnWalls(nationSpawn, NationWallGroup)

	-- // Spawn bounds used to drive the final stand highlight logic (see the
	-- // Final stand section above for why this is plain geometry, not ZonePlus).
	print("[FinalStand] Locating Empire spawn Terrain/Air part under", empireSpawn:GetFullName())
	local empireAir = empireSpawn:WaitForChild("Terrain"):WaitForChild("Air")
	print("[FinalStand] Found Empire Air part:", empireAir:GetFullName())
	teamSpawnParts[EmpireTeam] = empireAir

	print("[FinalStand] Locating Nation spawn Terrain/Air part under", nationSpawn:GetFullName())
	local nationAir = nationSpawn:WaitForChild("Terrain"):WaitForChild("Air")
	print("[FinalStand] Found Nation Air part:", nationAir:GetFullName())
	teamSpawnParts[NationTeam] = nationAir

	TrackSpawnMembership()
	print("[FinalStand] Spawn membership tracking started for both teams.")

	FastCastModule.VisualizeCasts = VisualizeCastsBoolean.Value

	VisualizeCastsBoolean:GetPropertyChangedSignal("Value"):Connect(function()
		FastCastModule.VisualizeCasts = VisualizeCastsBoolean.Value
	end)

	if TestingBoolean.Value == true then
		return
	end

	if EmpireInfiniteRespawns then
		EmpireInfiniteRespawns:GetPropertyChangedSignal("Value"):Connect(function()
			if EmpireInfiniteRespawns.Value == true then
				EmpireReinCount.Value = 999
				print("[GameManager] Empire infinite tickets toggled on mid-round — set to 999.")
			end
		end)
	end

	if NationInfiniteRespawns then
		NationInfiniteRespawns:GetPropertyChangedSignal("Value"):Connect(function()
			if NationInfiniteRespawns.Value == true then
				NationReinCount.Value = 999
				print("[GameManager] Nation infinite tickets toggled on mid-round — set to 999.")
			end
		end)
	end

	if QuickRespawnsBoolean then
		QuickRespawnsBoolean:GetPropertyChangedSignal("Value"):Connect(function()
			if QuickRespawnsBoolean.Value == true then
				EmpireReinWaveTimer.Value = 1
				NationReinWaveTimer.Value = 1
				print("[GameManager] Quick respawns toggled on mid-round — wave timers set to 1.")
			end
		end)
	end

	BeginRound()

	Players.PlayerAdded:Connect(function(player)
		if hiatusPeriod then
			player.PlayerGui.Hiatus.Enabled = true

			while hiatusTick ~= 0 do
				task.wait(1)
				game.StarterGui.Hiatus.Main.TextLabel.Text = [[
				This is your time to put all your bugs within <font color="rgb(212, 105, 20)">'Found Bugs'</font> thread for this specific test session.

				Testing will resume in"]] .. tostring(hiatusTick) .. [[ "seconds.

				You have killed <font color="rgb(255, 80, 80)">X</font> people.
				]]
			end

			player.PlayerGui.Hiatus.Enabled = false
		end
	end)
end

return Module
