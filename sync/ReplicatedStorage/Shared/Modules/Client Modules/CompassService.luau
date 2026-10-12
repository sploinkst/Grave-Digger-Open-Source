--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Library"):WaitForChild("Events")
local CompassEvent = Events:WaitForChild("Compass") :: RemoteEvent
local SettingsManager = require(Shared.Modules["Client Modules"].SettingsManager)
local SoundPlayback = require(Shared.Library.SoundPlayback)

local Service = {}
local started = false
local controller: any = nil
local active = false
local activeTrack: AnimationTrack? = nil
local activeArm: string? = nil
local activationToken = 0
local Debounce = false
local DebounceCooldown = 1
local baseMarkers: {[string]: BillboardGui} = {}

local function updateBaseMarkers(visible: boolean)
	local details = Workspace:FindFirstChild("Game_Details")
	local mainGame = details and details:FindFirstChild("Main_Game")
	local config = Shared.Library.Configuration:FindFirstChild("Scoring_Variables")
	for _, faction in {"Empire", "Nation"} do
		local teamName = if faction == "Empire" then "Golden Empire" else "Royal Nation"
		local allied = LocalPlayer.Team ~= nil and LocalPlayer.Team.Name == teamName
		local values = config and config:FindFirstChild(faction)
		local tickets = values and values:FindFirstChild(faction .. "_Rein_Count")
		local infinite = values and values:FindFirstChild(faction .. "_Infinite_Tickets")
		local depleted = tickets and tickets.Value <= 0 and not (infinite and infinite.Value)
		local spawn = mainGame and mainGame:FindFirstChild(faction)
		local terrain = spawn and spawn:FindFirstChild("Terrain")
		local anchor = terrain and terrain:FindFirstChild("Air")
		local marker = baseMarkers[faction]
		if anchor and anchor:IsA("BasePart") and not marker then
			marker = Instance.new("BillboardGui")
			marker.Name = faction .. "CompassBase"
			marker.Size = UDim2.fromOffset(180, 36)
			marker.AlwaysOnTop = true
			marker.ResetOnSpawn = false
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.TextStrokeTransparency = 0
			label.Parent = marker
			marker.Parent = LocalPlayer:WaitForChild("PlayerGui")
			baseMarkers[faction] = marker
		end
		if marker then
			marker.Adornee = if anchor and anchor:IsA("BasePart") then anchor else nil
			marker.Enabled = visible and LocalPlayer.Team ~= nil and (allied or depleted == true)
			local label = marker:FindFirstChildOfClass("TextLabel")
			if label then
				label.Text = if allied then "YOUR BASE" else "ENEMY BASE"
				label.TextColor3 = if allied then Color3.fromRGB(140, 210, 255) else Color3.fromRGB(255, 120, 100)
			end
		end
	end
end

local function objectivePoints(): Instance?
	local details = Workspace:FindFirstChild("Game_Details")
	local mainGame = details and details:FindFirstChild("Main_Game")
	return mainGame and mainGame:FindFirstChild("Points")
end

local function setObjectivesVisible(visible: boolean)
	updateBaseMarkers(visible)
	local points = objectivePoints()
	if not points then return end
	for _, point in points:GetChildren() do
		local billboard = point:FindFirstChild("Points_Billboard")
		if billboard and billboard:IsA("BillboardGui") then billboard.Enabled = visible end
	end
end

local function playSound(name: string)
	local sounds = Shared:FindFirstChild("Assets")
	local source = sounds and sounds:FindFirstChild(name, true)
	if not source or not source:IsA("Sound") then return end
	SoundPlayback.Play(source, SoundService)
end

local function closeCompass()
	if not active and not activeTrack then return end
	active = false
	activationToken += 1
	setObjectivesVisible(false)
	playSound("compass_close")
	if activeTrack then
		activeTrack:AdjustSpeed(1)
		activeTrack:Stop(0.15)
		activeTrack = nil
	end
	CompassEvent:FireServer("Hide")
	activeArm = nil
end

local function openCompass()
	if active or not controller then return end
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid or humanoid.Health <= 0
		or character:GetAttribute("Aiming") == true
		or character:GetAttribute("CompassDenied") == true then return end

	if Debounce then return end
	Debounce = true
	
	active = true
	activationToken += 1
	local token = activationToken
	local rightHanded = character:GetAttribute("CompassRight") == true
	activeArm = if rightHanded then "Right Arm" else "Left Arm"
	local animationName = if rightHanded then "Right" else "Left"
	activeTrack = controller:_playAnim(animationName, true)
	setObjectivesVisible(true)
	playSound("compass_open")
	CompassEvent:FireServer("Show", activeArm)

	task.delay(0.5, function()
		if active and token == activationToken and activeTrack then
			activeTrack:AdjustSpeed(0)
		end
	end)
	
	task.delay(DebounceCooldown, function()
		Debounce = false
	end)
end

local function handleInput(_: string, pressed: boolean)
	if pressed then openCompass() else closeCompass() end
end

function Service.Register(compassController)
	if controller and controller ~= compassController then closeCompass() end
	controller = compassController
end

function Service.Unregister(compassController)
	if controller ~= compassController then return end
	closeCompass()
	controller = nil
end

function Service.Close()
	closeCompass()
end

function Service.start_module()
	if started then return end
	started = true
	SettingsManager.HookInput("View Objectives", handleInput)
	SettingsManager.HookInput("Objectives Tool", handleInput)
	local elapsed = 0
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed += dt
		if active and elapsed >= 0.25 then
			elapsed = 0
			updateBaseMarkers(true)
		end
	end)

	local function bindCharacter(character: Model)
		character:GetAttributeChangedSignal("Aiming"):Connect(function()
			if character:GetAttribute("Aiming") == true then closeCompass() end
		end)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and humanoid:IsA("Humanoid") then humanoid.Died:Connect(closeCompass) end
	end
	LocalPlayer.CharacterAdded:Connect(bindCharacter)
	LocalPlayer.CharacterRemoving:Connect(closeCompass)
	if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
end

return Service
