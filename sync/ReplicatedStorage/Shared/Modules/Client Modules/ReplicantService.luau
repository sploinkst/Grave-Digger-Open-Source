-- // @Praxitos

local Module = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local WorkspaceService = game:GetService("Workspace")
local InputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local MusicService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")["Client Modules"].MusicService)

-- // Shared references
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = Shared:WaitForChild("Library")
local Utilities = require(Library:WaitForChild("Util"))

local concussionBlur = Lighting.Effects.ConcussionBlur
local concussionActive = false
local concussionConnection: RBXScriptConnection? = nil
local heartbeatSound: Sound? = nil
local lastHeartbeatTime = 0

-- Prevent remote listeners from being connected more than once.
local moduleStarted = false

local NationStart = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Game"):WaitForChild("NationStart")
local EmpireStart = NationStart.Parent.EmpireStart

-- // Adjust this path to wherever your actual capture-point loop sound lives
local CapturePointLoopSound = Shared:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Game"):WaitForChild("ObjectiveTick")

local NameBillboard = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Name_Billboard")

local GameDetails = WorkspaceService:WaitForChild("Game_Details")
local BodiesFolder = GameDetails:WaitForChild("Bodies")

-- // Replication tracking
local MaxReplicationEvents = 300
Module.ReplicationBuffer = {}

local function PushReplicationEvent(eventType, data)
	table.insert(Module.ReplicationBuffer, {
		Type = eventType,
		Time = os.clock(),
		Data = data,
	})

	if #Module.ReplicationBuffer > MaxReplicationEvents then
		table.remove(Module.ReplicationBuffer, 1)
	end
end

function Module.GetReplicationBuffer()
	return Module.ReplicationBuffer
end

function Module.GetReplicationCount()
	return #Module.ReplicationBuffer
end

-- // Asset folders
local HolstersRoot = ReplicatedStorage.Shared.Assets.Guns.Holsters

-- // Configuration
local Config = Library.Configuration.Scoring_Variables
local EmpireConfig = Config.Empire
local NationConfig = Config.Nation
local GameTimerValue = Config.Timer.Game_Timer
local GamemodeConfig = Config.Gamemode

local EmpireReinCount = EmpireConfig.Empire_Rein_Count
local EmpireWaveTimer = EmpireConfig.Empire_Rein_Wave_Timer
local NationReinCount = NationConfig.Nation_Rein_Count
local NationWaveTimer = NationConfig.Nation_Rein_Wave_Timer

local VisualizeCastsBoolean = Config.Parent.Ranged_Variables.Visualizations.Visualize_Casts
local FastCastModule = require(Shared.Library.Externals.FastCast)

-- // Constants
local MaxRein = 500
local LowHealthThreshold = 100
local HeartbeatInterval = 1.5

local Icons = {
	Golden_Empire_Background = "rbxassetid://17519166341",
	Royal_Nation_Background = "rbxassetid://17519166185",
}

local FlashTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local FlashColor = Color3.fromRGB(220, 50, 50)

local flinchCooldown = 0.35
local lastFlinched = 0
-- // Replicants
local ReplicantFolder = ReplicatedStorage.Shared.Library.Events
local FastCastReplicant = ReplicantFolder.FastCast
local VfxReplicant = ReplicantFolder.VFX
local SfxReplicant = ReplicantFolder.Sounds
local TextureReplicant = ReplicantFolder.Texture
local CasingReplicant = ReplicantFolder.Casing

local FinalStandEvent = ReplicantFolder.FinalStand

-- // UI references (reassigned on respawn)
local scoringGui: ScreenGui
local scoreFrame: Frame
local empireFrame: Frame
local nationFrame: Frame
local timerFrame: Frame
local objectiveUis: Folder
local overheadFrame: Frame
local overheadBar: Frame
local overheadBgIcon: ImageLabel
local overheadLabel: TextLabel
local overheadEnemyIn: Frame
local overheadLockIcon: ImageLabel

local LocalPlayer = Players.LocalPlayer

-- // Blur effect setup
local Camera = workspace.CurrentCamera
local Blur = Camera:FindFirstChild("blur")
if Blur == nil then
	Blur = Instance.new("BlurEffect")
	Blur.Name = "blur"
	Blur.Size = 0
	Blur.Parent = Camera
end

-- // Overhead sync connections; cleared whenever the player leaves a capture zone
local overheadConnections: { RBXScriptConnection } = {}

-- // Active flash tweens keyed by frame, so we can stop them individually
local activeFlashTweens: { [Frame]: Tween } = {}
local flashConnections: { [Frame]: RBXScriptConnection } = {}

-- // Tracks the last team that was actively pushing each point, keyed by point name.
-- // Preserved during decay so the bar keeps the correct color as it falls back.
local pointCapTeam: { [string]: string } = {}

-- // The currently-playing capture point loop sound, if the local player is
-- // standing on a point. Flat/non-positional, parented to SoundService.
local activeCaptureSound: Sound? = nil
local captureSound = false

local function ResolveCapTeam(empireCount: IntValue, nationCount: IntValue, pointName: string)
	local empireN = empireCount.Value
	local nationN = nationCount.Value

	local capTeam = nil

	if empireN > nationN then
		capTeam = "Golden Empire"
	elseif nationN > empireN then
		capTeam = "Royal Nation"
	end

	-- // cache for decay logic consistency (optional but now safe)
	pointCapTeam[pointName] = capTeam

	return capTeam
end

local function SetupLight(parent: BasePart, player: Player)
	local light = Instance.new("PointLight")
	light.Brightness = 0.5
	light.Range = 18
	light.Parent = parent

	light.Color = player.TeamColor.Color
end

local function UpdateBar(frame: Frame, value: number)
	local normalized = math.clamp(value / MaxRein, 0, 1)
	frame:WaitForChild("bar").Size = UDim2.fromScale(normalized, 1)
	frame:WaitForChild("num").Text = tostring(value)
end

local function UpdateWaveText(frame: Frame, value: number)
	frame:WaitForChild("rein").Text = value > 0
		and "Reinforcements in: " .. tostring(value)
		or "Reinforcements available"
end

local function UpdateTimer(frame: TextLabel, value: number)
	frame.Text = tostring(value)
end

local function SetObjectivesHidden()
	for _, ui in pairs(objectiveUis:GetChildren()) do
		ui.Visible = false
	end
end

local function UpdateObjective(value: string)
	SetObjectivesHidden()
	local target = objectiveUis:FindFirstChild(string.lower(value))
	if target then
		target.Visible = true
	else
		warn("[ScoringClient] Unknown objective type:", value, "— falling back to 'control'")
		local control = objectiveUis:FindFirstChild("control")
		if control then
			control.Visible = true
		end
	end
end

local function RefreshUI()
	UpdateBar(nationFrame, NationReinCount.Value)
	UpdateWaveText(nationFrame, NationWaveTimer.Value)
	UpdateBar(empireFrame, EmpireReinCount.Value)
	UpdateWaveText(empireFrame, EmpireWaveTimer.Value)
	UpdateTimer(timerFrame, GameTimerValue.Value)
	UpdateObjective(GamemodeConfig.Gamemode_Type.Value)
end

local function RebindUI()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	scoringGui = playerGui:WaitForChild("Scoring")
	scoreFrame = scoringGui:WaitForChild("scoreframe")
	empireFrame = scoreFrame:WaitForChild("empireside")
	nationFrame = scoreFrame:WaitForChild("nationside")
	timerFrame = scoreFrame:WaitForChild("center")
	objectiveUis = scoreFrame:WaitForChild("objective_uis")
	overheadFrame = scoringGui:WaitForChild("objpopup")
	overheadBar = overheadFrame:FindFirstChild("bar")
	overheadBgIcon = overheadFrame:FindFirstChild("bgicon")
	overheadLabel = overheadFrame:FindFirstChild("label")
	overheadEnemyIn = overheadFrame:FindFirstChild("enemyin")
	overheadLockIcon = overheadFrame:FindFirstChild("lockicon")
	RefreshUI()
end

local function GetBillboardUI(pointName: string)
	local pointFolder = workspace.Game_Details.Main_Game.Points:FindFirstChild(pointName)
	if not pointFolder then
		return nil
	end

	return pointFolder:FindFirstChild("Points_Billboard")
end

local function StartFlash(frame: Frame)
	if activeFlashTweens[frame] then
		return
	end

	frame.BackgroundColor3 = FlashColor
	frame.BackgroundTransparency = 1
	overheadEnemyIn.BackgroundTransparency = 1

	frame.Visible = true
	overheadEnemyIn.Visible = true

	local tween = TweenService:Create(frame, FlashTweenInfo, {
		BackgroundTransparency = 0,
	})
	activeFlashTweens[frame] = tween
	tween:Play()

	if flashConnections[frame] then
		flashConnections[frame]:Disconnect()
	end
	flashConnections[frame] = frame:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
		overheadEnemyIn.BackgroundTransparency = frame.BackgroundTransparency
	end)
end

local function StopFlash(frame: Frame, isOverhead: boolean?)
	local tween = activeFlashTweens[frame]
	if tween then
		tween:Cancel()
		activeFlashTweens[frame] = nil
	end

	if frame then
		frame.BackgroundTransparency = 1
		frame.Visible = false
	end

	if isOverhead then
		overheadEnemyIn.BackgroundTransparency = 1
		overheadEnemyIn.Visible = false
	end

	if flashConnections[frame] then
		flashConnections[frame]:Disconnect()
		flashConnections[frame] = nil
	end

	frame.BackgroundTransparency = 1
	frame.Visible = false
	overheadEnemyIn.BackgroundTransparency = 1
	overheadEnemyIn.Visible = false
end

local function UpdateEnemyFlash(
	empireCount: IntValue,
	nationCount: IntValue,
	owner: StringValue,
	scoreboardEnemyIn: Frame,
	pointName: string?
)
	local team = LocalPlayer.Team
	if not team then
		StopFlash(scoreboardEnemyIn, true)
		return
	end

	local billboardEnemyIn

	if pointName then
		local billboard = GetBillboardUI(pointName)

		if billboard then
			billboardEnemyIn = billboard:FindFirstChild("enemyin")
		end
	end

	local enemyPresent = false
	local enemyOwns = false

	if team.Name == "Golden Empire" then
		enemyPresent = nationCount.Value > 0
		enemyOwns = owner.Value == "Royal Nation"
	else
		enemyPresent = empireCount.Value > 0
		enemyOwns = owner.Value == "Golden Empire"
	end

	if enemyPresent and not enemyOwns then
		StartFlash(scoreboardEnemyIn)

		if billboardEnemyIn then
			StartFlash(billboardEnemyIn)
		end
	else
		StopFlash(scoreboardEnemyIn)

		if billboardEnemyIn then
			StopFlash(billboardEnemyIn, false)
		end
	end
end

local function SetupHolster(player: Player, child: BoolValue)
	local reference =
		HolstersRoot:FindFirstChild(child.Name)

	if not reference then
		warn("[ScoringClient] No holster reference found for:", child.Name)
		return
	end

	local primary = reference.PrimaryPart
	if not primary then
		warn("[ScoringClient] No PrimaryPart on holster:", child.Name)
		return
	end

	local bodyPartName = string.split(primary.Name, "_")[2]
	local char = player.Character
	if not char or not char:FindFirstChild(bodyPartName) then
		warn("[ScoringClient] Missing body part:", bodyPartName)
		return
	end

	local clone = reference:Clone()
	local weld = Utilities.quick_weld(clone.PrimaryPart, char[bodyPartName], clone, child.Name .. "_Weld")
	local holsterC0 = reference:GetAttribute("HolsterC0")
	if typeof(holsterC0) == "CFrame" then
		weld.C0 = holsterC0
	end
	clone.Parent = char.CharacterData.Rendered_Holsters

	child:GetPropertyChangedSignal("Value"):Connect(function()
		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("Hide_On_Equip") then
				part.Transparency = child.Value and 0 or 1
			end
		end
	end)
end

local function RemoveHolster(player: Player, child: Instance)
	local char = player.Character
	if not char then
		return
	end
	local rendered = char:FindFirstChild("CharacterData")
		and char.CharacterData:FindFirstChild("Rendered_Holsters")
	if not rendered then
		return
	end
	local existing = rendered:FindFirstChild(child.Name)
	if existing then
		existing:Destroy()
	end
end

local function HandleAccessory(player, child)
	if child:IsA("Model") then
		print("[REPLICANTSERVICE] Accessory is a model:", child.Name)
		return
	end
	if child:GetAttribute("Given") then
		print("[REPLICANTSERVICE] Accessory is already given:", child.Name)
		return
	end

	local accessory = Utilities.fetch_accessory(child.Name)
	if not accessory then
		print("[REPLICANTSERVICE] No accessory found for:", child.Name)
		return
	end

	local clone = Utilities.quick_give_accessory(player, accessory, true, false, false)
	print("Gave accessory:", child.Name)
	child:SetAttribute("Given", true)

	-- // special child handling
	if child.Name == "LightEffect" then
		local spotlight1: PointLight = clone.Torso.a0:FindFirstChildWhichIsA("SpotLight")
		local spotlight2: PointLight = clone.Torso.a1:FindFirstChildWhichIsA("SpotLight")

		if player.Team.Name == "Golden Empire" then
			spotlight1.Color = Color3.fromRGB(255, 210, 119)
			spotlight2.Color = Color3.fromRGB(255, 210, 119)
		else
			spotlight1.Color = Color3.fromRGB(196, 202, 255)
			spotlight2.Color = Color3.fromRGB(196, 202, 255)
		end
	elseif child.Name == "Empire_Dogtag" or child.Name == "Nation_Dogtag" then
		local nameLabel = clone.chain_tag.tag.Surface.Username

		nameLabel.Text = player.Name
		print("Set dogtag name to:", player.Name)
	end
end

local function SetCharacterNoCollision(char)
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

local function OnCharacterAdded(char: Model, player: Player)
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- // Remove any existing billboard (handles respawns cleanly)
	local existing = hrp:FindFirstChild("Name_Billboard")
	if existing then
		existing:Destroy()
	end

	-- // Handle accessories for the respawned player
	for _, child in pairs(player.GameData.Accessorys:GetChildren()) do
		if child:GetAttribute("ServerHandled") then
			print("[REPLICANTSERVICE] Skipping", child.Name, "handled by the server")
			continue
		end
		child:SetAttribute("Given", nil)
		HandleAccessory(player, child)
	end

	-- // Don't add a billboard for the local player themselves
	if player == LocalPlayer then
		return
	end

	-- // Only add billboard if this player is a teammate/disable collision
	if player.Team == LocalPlayer.Team then
		SetCharacterNoCollision(char)

		local clone = NameBillboard:Clone()
		clone.Parent = hrp
		clone.playername.Text = "ARM " .. player.Name
	end
end

local function RefreshAllBillboards()
	for _, p in ipairs(Players:GetPlayers()) do
		if p == LocalPlayer then
			continue
		end
		local char = p.Character
		if not char then
			continue
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local existing = hrp:FindFirstChild("Name_Billboard")
		if existing then
			existing:Destroy()
		end

		if p.Team == LocalPlayer.Team then
			local clone = NameBillboard:Clone()
			clone.Parent = hrp
			clone.playername.Text = "ARM " .. p.Name
		end
	end
end

local function HandlePlayerList(player: Player)
	local playerList = Players.LocalPlayer.PlayerGui.Playerlist
	local empireList = playerList.playerlist.empirelist
	local nationList = playerList.playerlist.royallist
	local empireExample = empireList.Example
	local nationExample = nationList.Example

	local clone

	local function CreateEntry()
		local isEmpire = player.Team and player.Team.Name == "Golden Empire"

		print("[PlayerList] Creating entry for", player.Name, "Empire:", isEmpire)

		local template = isEmpire and empireExample or nationExample
		local parent = isEmpire and empireList or nationList

		clone = template:Clone()
		clone.Name = player.Name
		clone.Visible = true
		clone.playername.Text = player.Name
		clone.Parent = parent

		if player == LocalPlayer then
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

	local function HandleCharacter(character: Model)
		print("[PlayerList] HandleCharacter:", player.Name)

		local humanoid = character:WaitForChild("Humanoid")

		print("[PlayerList]", player.Name, "Connected to humanoid:", humanoid)

		if clone then
			clone.crossout.Visible = humanoid.Health <= 0
			print("[PlayerList]", player.Name, "Initial health:", humanoid.Health, "Crossout:", clone.crossout.Visible)
		else
			warn("[PlayerList]", player.Name, "Clone missing during HandleCharacter.")
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

	CreateEntry()

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

		CreateEntry()

		if player.Character then
			HandleCharacter(player.Character)
		end
	end)

	if player.Character then
		HandleCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		print("[PlayerList] CharacterAdded:", player.Name)
		HandleCharacter(character)
	end)
end

local function SetupPlayer(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	OnCharacterAdded(char, player)

	player.CharacterAdded:Connect(function(character)
		OnCharacterAdded(character, player)
	end)

	-- // Refresh all billboards whenever any player switches teams
	player:GetPropertyChangedSignal("Team"):Connect(RefreshAllBillboards)

	local gameData = player:WaitForChild("GameData")
	local accessories = gameData:WaitForChild("Accessorys")
	local holsters = accessories:WaitForChild("Holsters")

	for _, child in ipairs(holsters:GetChildren()) do
		task.spawn(SetupHolster, player, child)
	end

	holsters.ChildAdded:Connect(function(child)
		SetupHolster(player, child)
	end)
	holsters.ChildRemoved:Connect(function(child)
		RemoveHolster(player, child)
	end)

	for _, child in ipairs(accessories:GetChildren()) do
		task.spawn(HandleAccessory, player, child)
	end

	accessories.ChildAdded:Connect(function(child)
		HandleAccessory(player, child)
	end)

	HandlePlayerList(player)
end

local function ClearOverheadConnections()
	for _, conn in ipairs(overheadConnections) do
		conn:Disconnect()
	end
	table.clear(overheadConnections)
end

-- // Returns the bar color for whichever team last pushed this point
local function GetCapColor(teamName: string?): Color3
	if teamName == "Golden Empire" then
		return Color3.new(1, 1, 0)
	elseif teamName == "Royal Nation" then
		return Color3.fromRGB(167, 83, 170)
	end
	-- // Neutral fallback — progress should be 0 at this point anyway
	return Color3.fromRGB(167, 83, 170)
end

-- // Applies progress to a bar.
-- // Updates the remembered capping team when someone is actively pushing,
-- // and leaves it unchanged during decay so the color persists.
local function ApplyProgress(
	pointName: string,
	progressValue: number,
	empireCount: IntValue,
	nationCount: IntValue,
	bar: Frame,
	syncOverhead: boolean,
	playSound: boolean
)
	local empireN = empireCount.Value
	local nationN = nationCount.Value

	local capTeam = pointCapTeam[pointName]
	if empireN > 0 or nationN > 0 then
		if empireN > nationN then
			capTeam = "Golden Empire"
		elseif nationN > empireN then
			capTeam = "Royal Nation"
		end
	end

	pointCapTeam[pointName] = capTeam

	local color = GetCapColor(capTeam)
	local size = UDim2.fromScale(1, progressValue / 20)

	-- // scoreboard UI
	bar.BackgroundColor3 = color
	bar.Size = size

	-- // billboard UI
	local billboard = GetBillboardUI(pointName)
	if billboard then
		local billboardBar = billboard:FindFirstChild("bar")
		if billboardBar and billboardBar:IsA("Frame") then
			billboardBar.BackgroundColor3 = color
			billboardBar.Size = size
		end
	end

	-- // overhead popup
	if syncOverhead then
		overheadBar.BackgroundColor3 = color
		overheadBar.Size = size
	end

	if playSound then
		local clone = CapturePointLoopSound:Clone()
		clone.Parent = game.SoundService
		clone:Play()

		clone.Ended:Connect(function()
			clone:Destroy()
		end)
	end
end

local function ApplyOwner(
	ownerValue: string,
	bar: Frame,
	bgIcon: ImageLabel,
	pointLabel: TextLabel,
	syncOverhead: boolean,
	pointName: string
)
	local billboard = GetBillboardUI(pointName)

	local billboardBgIcon
	local billboardLabel
	local billboardBar

	if billboard then
		billboardBgIcon = billboard:FindFirstChild("bgicon")
		billboardLabel = billboard:FindFirstChild("label")
		billboardBar = billboard:FindFirstChild("bar")
	end

	if ownerValue == "Golden Empire" then
		local color = Color3.fromRGB(255, 255, 0)

		bgIcon.Image = Icons.Golden_Empire_Background
		bgIcon.Visible = true
		bgIcon.ImageColor3 = color
		pointLabel.TextColor3 = color

		if billboardBgIcon then
			billboardBgIcon.Image = Icons.Golden_Empire_Background
			billboardBgIcon.Visible = true
			billboardBgIcon.ImageColor3 = color
		end

		if billboardLabel then
			billboardLabel.TextColor3 = color
		end

		if billboardBar then
			billboardBar.BackgroundColor3 = color
		end

		if syncOverhead then
			overheadBgIcon.Image = Icons.Golden_Empire_Background
			overheadBgIcon.Visible = true
			overheadBgIcon.ImageColor3 = color
			overheadLabel.TextColor3 = color
		end
		
	elseif ownerValue == "Royal Nation" then
		local color = Color3.fromRGB(146, 25, 167)

		bgIcon.Image = Icons.Royal_Nation_Background
		bgIcon.Visible = true
		bgIcon.ImageColor3 = color
		pointLabel.TextColor3 = color

		if billboardBgIcon then
			billboardBgIcon.Image = Icons.Royal_Nation_Background
			billboardBgIcon.Visible = true
			billboardBgIcon.ImageColor3 = color
		end

		if billboardLabel then
			billboardLabel.TextColor3 = color
		end

		if billboardBar then
			billboardBar.BackgroundColor3 = color
		end

		if syncOverhead then
			overheadBgIcon.Image = Icons.Royal_Nation_Background
			overheadBgIcon.Visible = true
			overheadBgIcon.ImageColor3 = color
			overheadLabel.TextColor3 = color
		end
	else
		bgIcon.Visible = false

		if billboardBgIcon then
			billboardBgIcon.Visible = false
		end

		if billboardBar then
			billboardBar.BackgroundColor3 = Color3.fromRGB(167, 83, 170)
		end

		if syncOverhead then
			overheadBgIcon.Visible = false
		end
	end
	
	
	if ownerValue == "Neutral" or ownerValue == "" then return end
	
	print("ownerValue: ", ownerValue)
	if ownerValue == LocalPlayer.Team.Name then
		local Utils = require(
			LocalPlayer.PlayerGui.Alerts.AlertUtils
		).Alert("Select", pointName .. "PointCaptured")
	else
		local Utils = require(
			LocalPlayer.PlayerGui.Alerts.AlertUtils
		).Alert("Select", pointName .. "PointLost")
	end
end

local function SyncOverheadToPoint(pointName: string)
	ClearOverheadConnections()

	local folder = GamemodeConfig:FindFirstChild(pointName .. "_Point")
	if not folder then
		warn("[ScoringClient] SyncOverheadToPoint: missing folder for:", pointName)
		return
	end

	local empireCount = folder:FindFirstChild(pointName .. "_Empire_Count")
	local nationCount = folder:FindFirstChild(pointName .. "_Nation_Count")
	local progress = folder:FindFirstChild(pointName .. "_Progress")
	local owner = folder:FindFirstChild(pointName .. "_Owner")

	if not (empireCount and nationCount and progress and owner) then
		return
	end

	local controlUi = objectiveUis.control:FindFirstChild("objective" .. pointName)
	local bar = controlUi and controlUi:FindFirstChild("bar") :: Frame
	local bgIcon = controlUi and controlUi:FindFirstChild("bgicon") :: ImageLabel
	local pointLabel = controlUi and controlUi:FindFirstChild("label") :: TextLabel
	local scoreboardEnemyIn = controlUi and controlUi:FindFirstChild("enemyin") :: Frame

	overheadLabel.Text = pointName

	-- // Initial sync immediately
	ApplyOwner(owner.Value, bar, bgIcon, pointLabel, true, pointName)

	ApplyProgress(pointName, progress.Value, empireCount, nationCount, bar, true)

	UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)

	table.insert(overheadConnections, progress.Changed:Connect(function()
		ApplyProgress(pointName, progress.Value, empireCount, nationCount, bar, true, true)
	end))

	table.insert(overheadConnections, owner.Changed:Connect(function()
		ApplyOwner(owner.Value, bar, bgIcon, pointLabel, true, pointName)
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end))

	table.insert(overheadConnections, empireCount.Changed:Connect(function()
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end))

	table.insert(overheadConnections, nationCount.Changed:Connect(function()
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end))
end

local function BindPointUI(pointName: string, controlUi: Frame)
	local folder = GamemodeConfig:FindFirstChild(pointName .. "_Point")
	if not folder then
		warn("[ScoringClient] Missing gamemode folder for:", pointName)
		return
	end

	local empireCount = folder:FindFirstChild(pointName .. "_Empire_Count")
	local nationCount = folder:FindFirstChild(pointName .. "_Nation_Count")
	local progress = folder:FindFirstChild(pointName .. "_Progress")
	local owner = folder:FindFirstChild(pointName .. "_Owner")
	local scoreboardEnemyIn = controlUi:FindFirstChild("enemyin") :: Frame

	if not (empireCount and nationCount and progress and owner) then
		warn("[ScoringClient] Missing point values for:", pointName)
		return
	end

	local bar: Frame = controlUi:FindFirstChild("bar")
	local bgIcon: ImageLabel = controlUi:FindFirstChild("bgicon")
	local pointLabel: TextLabel = controlUi:FindFirstChild("label")

	-- // Initial sync immediately
	ApplyOwner(owner.Value, bar, bgIcon, pointLabel, false, pointName)

	ApplyProgress(pointName, progress.Value, empireCount, nationCount, bar, false)

	UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)

	-- // Future updates
	progress.Changed:Connect(function()
		ApplyProgress(pointName, progress.Value, empireCount, nationCount, bar, false)
	end)

	owner.Changed:Connect(function()
		ApplyOwner(owner.Value, bar, bgIcon, pointLabel, false, pointName)
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end)

	empireCount.Changed:Connect(function()
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end)

	nationCount.Changed:Connect(function()
		UpdateEnemyFlash(empireCount, nationCount, owner, scoreboardEnemyIn, pointName)
	end)
end

local function BindCapturePointProximity(model: Model, pointName: string)
	local capture = model:FindFirstChild("capture")
	if not capture then
		return
	end

	capture.Touched:Connect(function(hit)
		if hit.Parent ~= LocalPlayer.Character then
			return
		end
		if overheadFrame.Visible then
			return
		end
		overheadFrame.Visible = true
		SyncOverheadToPoint(pointName)
	end)

	capture.TouchEnded:Connect(function(hit)
		if hit.Parent ~= LocalPlayer.Character then
			return
		end
		if not overheadFrame.Visible then
			return
		end
		overheadFrame.Visible = false
		StopFlash(overheadEnemyIn)
		ClearOverheadConnections()
	end)
end

local function HandlePointChild(pointChild: Instance)
	local control = objectiveUis.control:FindFirstChild("objective" .. pointChild.Name)
	if not control then
		warn("[ScoringClient] No objective UI found for:", pointChild.Name)
		return
	end

	control.Visible = true
	local billboard = GetBillboardUI(pointChild.Name)

	if billboard then
		local label = billboard:FindFirstChild("label")

		if label and label:IsA("TextLabel") then
			label.Text = pointChild.Name
		end
	end
	BindPointUI(pointChild.Name, control)

	local model = pointChild:FindFirstChildWhichIsA("Model")
	if model then
		BindCapturePointProximity(model, pointChild.Name)
	end
end

local function WatchAllPoints()
	local pointsFolder = workspace.Game_Details.Main_Game.Points
	for _, point in pairs(pointsFolder:GetChildren()) do
		point.ChildAdded:Connect(function()
			HandlePointChild(point)
		end)
		if #point:GetChildren() > 0 then
			HandlePointChild(point)
		end
	end
end

-- // concussion effects
local function StopConcussionEffect()
	if not concussionActive then
		return
	end
	concussionActive = false

	local concussionUi = LocalPlayer.PlayerGui:WaitForChild("Status"):WaitForChild("Concussion")
	local lowHealthImageLabel = concussionUi.Low_Overlay
	local painOverlayImageLabel = concussionUi.Pain_Overlay

	-- // fade-out control
	local startTime = tick()
	local fadeOutDuration = 0.5

	-- // keep existing connection running, but switch it into "fade-out mode"
	if concussionConnection and concussionConnection.Connected then
		concussionConnection:Disconnect()
	end

	concussionConnection = RunService.RenderStepped:Connect(function()
		local t = tick()
		local elapsed = t - startTime

		-- // 1 → 0
		local fadeAlpha = 1 - math.clamp(elapsed / fadeOutDuration, 0, 1)

		-- // smoothstep easing
		fadeAlpha = fadeAlpha * fadeAlpha * (3 - 2 * fadeAlpha)

		local pulse = math.sin(t * 1.5) / 10

		-- // drive everything toward zero
		local targetIntensity = (5 + math.abs(pulse * 50)) * fadeAlpha
		Blur.Size = Blur.Size + (targetIntensity - Blur.Size) * 0.15

		if concussionBlur then
			local targetConcussionBlur = (10 + math.abs(pulse * 60)) * fadeAlpha
			concussionBlur.Size = concussionBlur.Size + (targetConcussionBlur - concussionBlur.Size) * 0.15
		end

		-- // UI scale collapses back to normal
		local scale = 1 + ((1.1 - pulse) - 1) * fadeAlpha
		painOverlayImageLabel.Size = painOverlayImageLabel.Size:Lerp(
			UDim2.fromScale(scale, scale),
			0.15
		)

		-- // fade to invisible
		lowHealthImageLabel.ImageTransparency = 1 - fadeAlpha
		painOverlayImageLabel.ImageTransparency = 1 - fadeAlpha

		-- // fully done → cleanup
		if elapsed >= fadeOutDuration then
			lowHealthImageLabel.ImageTransparency = 1
			painOverlayImageLabel.ImageTransparency = 1

			Blur.Size = 0

			if concussionBlur then
				concussionBlur.Size = 0
				concussionBlur.Enabled = false
			end

			if heartbeatSound then
				heartbeatSound:Stop()
				heartbeatSound:Destroy()
				heartbeatSound = nil
			end

			if concussionConnection then
				concussionConnection:Disconnect()
				concussionConnection = nil
			end
		end
	end)
end

local function StartConcussionEffect()
	if concussionActive then
		return
	end
	concussionActive = true

	if concussionBlur then
		concussionBlur.Enabled = true
	end

	local concussionUi = LocalPlayer.PlayerGui.Status.Concussion
	local lowHealthImageLabel = concussionUi.Low_Overlay
	local painOverlayImageLabel = concussionUi.Pain_Overlay

	lowHealthImageLabel.ImageTransparency = 1
	painOverlayImageLabel.ImageTransparency = 1

	-- // fade-in control
	local startTime = tick()
	local fadeInDuration = 0.6 -- seconds

	concussionConnection = RunService.RenderStepped:Connect(function()
		local t = tick()
		local elapsed = t - startTime

		-- // smooth ramp from 0 → 1
		local fadeAlpha = math.clamp(elapsed / fadeInDuration, 0, 1)

		-- // easing (optional but recommended)
		fadeAlpha = fadeAlpha * fadeAlpha * (3 - 2 * fadeAlpha) -- smoothstep

		local pulse = math.sin(t * 1.5) / 10

		-- // blend pulse intensity with fade-in
		local targetIntensity = (5 + math.abs(pulse * 50)) * fadeAlpha
		Blur.Size = Blur.Size + (targetIntensity - Blur.Size) * 0.1

		if concussionBlur then
			local targetConcussionBlur = (10 + math.abs(pulse * 60)) * fadeAlpha
			concussionBlur.Size = concussionBlur.Size + (targetConcussionBlur - concussionBlur.Size) * 0.1
		end

		-- // UI fade-in + pulse scaling
		local scale = 1 + ((1.1 - pulse) - 1) * fadeAlpha
		painOverlayImageLabel.Size = painOverlayImageLabel.Size:Lerp(
			UDim2.fromScale(scale, scale),
			0.1
		)

		-- // transparency fades OUT (since 1 = invisible)
		lowHealthImageLabel.ImageTransparency = 1 - fadeAlpha
		painOverlayImageLabel.ImageTransparency = 1 - fadeAlpha

		-- // Heartbeat timing
		if t - lastHeartbeatTime >= HeartbeatInterval then
			lastHeartbeatTime = t
			if heartbeatSound then
				heartbeatSound:Play()
			end
		end
	end)
end

local function UpdateConcussionState()
	local state = LocalPlayer:GetAttribute("Concussion") == true

	if state then
		StartConcussionEffect()
	else
		StopConcussionEffect()
	end
end

Module.FlinchLocalPlayer = function(direction)
	if LocalPlayer:GetAttribute("CantFlinch") then
		return
	end
	if tick() - lastFlinched < flinchCooldown then
		return
	end

	lastFlinched = tick()
	local flinchingImageLabelClone = LocalPlayer.PlayerGui.Flinching.flinch:Clone()
	flinchingImageLabelClone.Visible = true
	flinchingImageLabelClone.Parent = LocalPlayer.PlayerGui.Flinching

	local tween1 = TweenService:Create(flinchingImageLabelClone, TweenInfo.new(0.6), { ImageTransparency = 1 })
	tween1:Play()
	game.Debris:AddItem(flinchingImageLabelClone, 1.6)

	LocalPlayer:SetAttribute("Flinch", direction)
	print("[ReplicantService] Local player is Flinching!", direction)
end

local function HandleFastCastReplication(...)
	local args = { ... }

	local player = args[1]
	if player.Name == LocalPlayer.Name then
		return
	end

	local origin = args[2]
	local direction = args[3]
	local speed = args[4]
	local castData = args[5]

	-- // Track event
	PushReplicationEvent("FastCast", {
		Player = player.Name,
		Origin = origin,
		Direction = direction,
		Speed = speed,
	})

	local caster, casterData = Utilities.setupFastCast(castData)
	caster:Fire(origin, direction, speed, casterData)

	caster.LengthChanged:Connect(function(cast, position, segmentVelocity, segmentTravelDistance, segmentIndex)
		local bulletPos = position + segmentVelocity.Unit * segmentTravelDistance

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			if (bulletPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 18 then
				Module.FlinchLocalPlayer(direction)
			end
		end
	end)
end

local function HandleVfxReplication(...)
	local args = { ... }

	local player = args[1]
	if player.Name == LocalPlayer.Name then
		return
	end

	local effect = args[2]
	local cframeValue = args[3]
	local emissions = args[4]
	local parent = args[5]
	local attachToParent = args[6]

	-- // Track event
	PushReplicationEvent("VFX", {
		Player = player.Name,
		Effect = effect.Name,
		Emissions = emissions,
		Attached = attachToParent,
	})

	for _, child in ipairs(effect:GetDescendants()) do
		local emitCount = emissions[child.Name]

		if not emitCount then
			continue
		end

		local clone = child:Clone()
		local container

		if attachToParent then
			clone.Parent = parent
			container = clone
		else
			local part = Instance.new("Part")
			part.Size = Vector3.new(0.05, 0.05, 0.05)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = cframeValue
			part.Parent = workspace

			clone.Parent = part
			container = part
		end

		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emitCount)

			local lifetime = clone.Lifetime.Max

			task.delay(lifetime + 0.1, function()
				if container then
					container:Destroy()
				end
			end)
		end
	end
end

local function HandleTextureReplication(...)
	local args = { ... }

	local player = args[1]
	if player.Name == LocalPlayer.Name then
		return
	end

	local part = args[2]
	local position = args[3]
	local normal = args[4]
	local parent = args[5]

	-- // Track event
	PushReplicationEvent("Texture", {
		Player = player.Name,
		Texture = part.Name,
		Position = position,
	})

	local textureClone = part:Clone()
	textureClone.CFrame = CFrame.new(position, position + normal)
	textureClone.Parent = parent
end

local function HandleHolsterReplication(...)
	local args = { ... }

	local player = args[1]
	local holsterName = args[2]
	local isEquipped = args[3]

	-- // Track event
	PushReplicationEvent("Holster", {
		Player = player.Name,
		Holster = holsterName,
		Equipped = isEquipped,
	})
end

function Module.HandleSfxReplication(...)
	local args = { ... }
	local player = args[1]
	local soundInstance = args[2]
	if player == "BeginRound" then
		local clone
		if game.Players.LocalPlayer.Team.Name == "Golden Empire" then
			clone = EmpireStart:Clone()
		else
			clone = NationStart:Clone()
		end

		local sound: Sound = MusicService.PlayAudio(clone)
		local Utils = require(
			LocalPlayer.PlayerGui.Alerts.AlertUtils
		).Alert("Select", "RoundStart")
		task.delay(3, function()
			MusicService.PlayAdvance()
		end)
		return
	else
		if not player or not soundInstance then
			return
		end

		local parent = args[3]
		local playbackSpeed = args[4] or soundInstance.PlaybackSpeed
		local volume = args[5] or soundInstance.Volume
		local pitchShift = args[6] or 0
		local pitchVariation = args[7] or 0 -- pitch variation parameter

		local soundClone = soundInstance:Clone()
		soundClone.Parent = parent

		-- // Set base pitch
		soundClone.Pitch = soundInstance.Pitch or 1

		-- // Apply pitch variation (same logic as the script)
		if pitchVariation and typeof(pitchVariation) == "number" then
			soundClone.Pitch = soundClone.Pitch + math.random(-pitchVariation * 100, pitchVariation * 100) / 100
		end

		-- // Apply pitch shift (from PitchShiftSoundEffect)
		if pitchShift ~= 0 then
			local pitchSound = Instance.new("PitchShiftSoundEffect")

			pitchSound.Octave = pitchShift
			pitchSound.Parent = soundClone
		end

		soundClone:Play()
		soundClone.PlaybackSpeed = playbackSpeed
		soundClone.Volume = volume

		soundClone.Ended:Connect(function()
			soundClone:Destroy()
		end)
	end
end

function Module.HandleCasingReplication(...)
	local args = { ... }

	local player = args[1]
	local casing = args[2]
	local origin = args[3]
	local direction = args[4]

	local clone = casing:Clone()
	clone.Parent = workspace
	clone.CFrame = origin
	clone.Anchored = false
	clone.CanCollide = true
	clone.Transparency = 0

	local vel = direction or origin.LookVector * math.random(10, 15) + Vector3.new(0, math.random(10, 15), 0)

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = vel
	bv.Parent = clone

	clone.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

	task.delay(0.1, function()
		bv:Destroy()
	end)

	task.delay(3, function()
		clone:Destroy()
	end)

	print("Casing replicated for player:", player.Name)
end

function Module.ConnectSfx(...)
	local args = { ... }
	Module.HandleSfxReplication(...)

	-- // remove player from the args
	local player = args[1]
	table.remove(args, 1)

	SfxReplicant:FireServer(args)
end

function Module.start_module()
	if moduleStarted then
		warn("ReplicantService.start_module called more than once; ignoring duplicate startup")
		return
	end
	moduleStarted = true

	RebindUI()

	FastCastModule.VisualizeCasts = VisualizeCastsBoolean.Value

	VisualizeCastsBoolean:GetPropertyChangedSignal("Value"):Connect(function()
		FastCastModule.VisualizeCasts = VisualizeCastsBoolean.Value
		print("[GameManager] Cast visualization set to", VisualizeCastsBoolean.Value)
	end)

	-- // Setup existing players
	for _, player in pairs(Players:GetPlayers()) do
		SetupPlayer(player)
	end
	Players.PlayerAdded:Connect(SetupPlayer)

	-- // Bind reinforcement count updates
	NationReinCount:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateBar(nationFrame, NationReinCount.Value)
	end)
	NationWaveTimer:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateWaveText(nationFrame, NationWaveTimer.Value)
	end)
	EmpireReinCount:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateBar(empireFrame, EmpireReinCount.Value)
	end)
	EmpireWaveTimer:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateWaveText(empireFrame, EmpireWaveTimer.Value)
	end)
	GameTimerValue:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateTimer(timerFrame, GameTimerValue.Value)
	end)
	GamemodeConfig.Gamemode_Type:GetPropertyChangedSignal("Value"):Connect(function()
		UpdateObjective(GamemodeConfig.Gamemode_Type.Value)
	end)

	-- // Rebind UI on character respawn
	LocalPlayer.CharacterAdded:Connect(RebindUI)

	-- // Watch capture points
	WatchAllPoints()

	-- // Bind replication event handlers
	FastCastReplicant.OnClientEvent:Connect(HandleFastCastReplication)
	VfxReplicant.OnClientEvent:Connect(HandleVfxReplication)
	TextureReplicant.OnClientEvent:Connect(HandleTextureReplication)
	SfxReplicant.OnClientEvent:Connect(function(...)
		local args = { ... }
		local player = args[1]

		if player == LocalPlayer then
			return
		end

		Module.HandleSfxReplication(...)
	end)

	CasingReplicant.OnClientEvent:Connect(function(...)
		local args = { ... }
		local player = args[1]
		print("Casing replicated for player:", player.Name, "with:", args)

		if player == LocalPlayer then
			return
		end

		Module.HandleCasingReplication(...)
	end)

	-- // Listen for changes
	LocalPlayer:GetAttributeChangedSignal("Concussion"):Connect(UpdateConcussionState)

	LocalPlayer:GetAttributeChangedSignal("Force_Flinch"):Connect(function()
		print("FLINCHING")
		if not LocalPlayer:GetAttribute("Force_Flinch") then
			print("FLINCHING CUT")
			return
		end
		LocalPlayer:SetAttribute("Force_Flinch", nil)
		Module.FlinchLocalPlayer(3)
		print("FLINCHING DONE")
	end)

	print("[ReplicantService] Module started successfully")
	BodiesFolder.ChildAdded:Connect(function(ragdoll)
		print(ragdoll.Name, "is added to the BodiesFolder.")

		local playerReference = Players:FindFirstChild(ragdoll.Name)
		if playerReference then
			print(playerReference.Name, "is found in the player list.")
			local playerAccessories = playerReference.GameData.Accessorys

			for _, child in pairs(playerAccessories:GetChildren()) do
				local accessory = Utilities.fetch_accessory(child.Name)
				if not accessory then
					print("[REPLICANTSERVICE] No accessory found for:", child.Name)
					continue
				end

				Utilities.create_object(ragdoll, accessory)
				print("Accessory created for:", child.Name)
			end
		end
	end)

	InputService.InputBegan:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode == Enum.KeyCode.Tab then
			game.Players.LocalPlayer.PlayerGui.Playerlist.Enabled = true
		end
	end)

	InputService.InputEnded:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode == Enum.KeyCode.Tab then
			game.Players.LocalPlayer.PlayerGui.Playerlist.Enabled = false
		end
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		LocalPlayer.PlayerGui:WaitForChild("Black"):WaitForChild("fadetoblack").BackgroundTransparency = 0
		
		local tween = TweenService:Create(LocalPlayer.PlayerGui:WaitForChild("Black"):WaitForChild("fadetoblack"), TweenInfo.new(1), { BackgroundTransparency = 1 })
		tween:Play()
	end)

	if LocalPlayer.Character then
		local tween = TweenService:Create(LocalPlayer.PlayerGui:WaitForChild("Black"):WaitForChild("fadetoblack"), TweenInfo.new(1), { BackgroundTransparency = 1 })
		tween:Play()
	end
	
	FinalStandEvent.OnClientEvent:Connect(function(losingTeam)
		print("[FinalStandEvent] Received for team:", losingTeam)

		if LocalPlayer.Team and LocalPlayer.Team.Name == losingTeam then
			require(LocalPlayer.PlayerGui.Alerts.AlertUtils).Alert(
				"Select",
				"MissionFailure"
			)
		else
			require(LocalPlayer.PlayerGui.Alerts.AlertUtils).Alert(
				"Select",
				"MissionVictory"
			)
		end
	end)
end

return Module
