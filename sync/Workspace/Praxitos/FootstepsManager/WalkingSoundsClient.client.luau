-- // Walking Sounds (Client)
-- Made by VroIok, modified

-- // Services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Character setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")
local ServerSound = Root:WaitForChild("CurrentSound")

-- // Sound folder
local SoundFolder = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Assets")
	:WaitForChild("Sounds")
	:WaitForChild("Movement")

-- // Remote
local UpdateWalkspeedRemote = ReplicatedStorage:WaitForChild("UpdateWalkspeed")

-- // Sound state
local Id
local Volume
local PlaybackSpeed = 1

local FloorMaterial
local Material

-- // Local sound instance
local CurrentSound = Instance.new("Sound")
CurrentSound.Name = "CurrentSound"
CurrentSound.Parent = SoundService

-- // Remove default Roblox running sound
local DefaultRunning = Root:FindFirstChild("Running")
if DefaultRunning then
	DefaultRunning:Destroy()
end

-- // Get current floor material
local function GetFloorMaterial()
	FloorMaterial = Humanoid.FloorMaterial
	Material = string.split(tostring(FloorMaterial), "Enum.Material.")[2]
	return Material
end

-- // Pick a random sound from the material folder
local function GetSoundProperties()
	if not Material then
		return false
	end

	local MaterialFolder = SoundFolder:FindFirstChild(Material)

	if not MaterialFolder then
		return false
	end

	local Sounds = MaterialFolder:GetChildren()

	if #Sounds == 0 then
		return false
	end

	local Chosen = Sounds[math.random(1, #Sounds)]

	Id = Chosen.SoundId
	Volume = Chosen:GetAttribute("Volume") or 0.5
	PlaybackSpeed = (Humanoid.WalkSpeed / 16) * (Chosen:GetAttribute("Speed") or 1)

	return true
end

-- // Apply sound properties
local function Update()
	if not Id then
		return
	end

	CurrentSound.SoundId = Id
	CurrentSound.Volume = Volume
	CurrentSound.PlaybackSpeed = PlaybackSpeed
end

-- // Scale volume based on camera distance
local function UpdateVolume()
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	local MaxDistance = 100
	local MaxVolume = Volume or 0.5

	local Distance = (Camera.CFrame.Position - Root.Position).Magnitude

	CurrentSound.Volume = math.clamp(
		MaxVolume - (Distance / MaxDistance),
		0,
		MaxVolume
	)
end

-- // Init
GetFloorMaterial()

if GetSoundProperties() then
	Update()
end

-- // Floor material changed
Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	GetFloorMaterial()

	if GetSoundProperties() then
		Update()

		if Humanoid.MoveDirection.Magnitude > 0 then
			CurrentSound:Play()
		end
	end
end)

-- // Walkspeed changed
Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	UpdateWalkspeedRemote:FireServer(Humanoid.WalkSpeed)

	if GetSoundProperties() then
		Update()
	end
end)

-- // Handle movement state
Humanoid.Running:Connect(function(Speed)
	local Moving =
		Humanoid.MoveDirection.Magnitude > 0
		and Speed > 0
		and Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing

	if Moving then
		if GetSoundProperties() then
			Update()

			if not CurrentSound.IsPlaying then
				CurrentSound.Looped = true
				CurrentSound:Play()
			end
		end
	else
		CurrentSound:Stop()
	end
end)

-- // Keep server sound muted
ServerSound:GetPropertyChangedSignal("Volume"):Connect(function()
	if ServerSound.Volume ~= 0 then
		ServerSound.Volume = 0
	end
end)

ServerSound.Volume = 0

-- // Stop sound after respawn
Player.CharacterAdded:Connect(function()
	task.wait(1)

	if CurrentSound.IsPlaying then
		CurrentSound:Stop()
	end
end)

-- // Camera distance volume updater
task.spawn(function()
	while task.wait(0.05) do
		if CurrentSound.IsPlaying then
			UpdateVolume()
		end
	end
end)