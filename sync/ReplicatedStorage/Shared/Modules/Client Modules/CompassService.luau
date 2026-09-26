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

local function objectivePoints(): Instance?
	local details = Workspace:FindFirstChild("Game_Details")
	local mainGame = details and details:FindFirstChild("Main_Game")
	return mainGame and mainGame:FindFirstChild("Points")
end

local function setObjectivesVisible(visible: boolean)
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
