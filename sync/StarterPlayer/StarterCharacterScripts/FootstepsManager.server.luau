-- // Walking Sounds (Server)
-- Made by VroIok, modified

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Character setup
local Player = Players:GetPlayerFromCharacter(script.Parent)
if not Player then
	return
end

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- // Sound folder
local SoundFolder = ReplicatedStorage:WaitForChild("Shared")
	:WaitForChild("Assets")
	:WaitForChild("Sounds")
	:WaitForChild("Movement")

-- // Sound state
local Id
local Volume
local PlaybackSpeed = 1

local FloorMaterial
local Material

-- // Remote setup
local UpdateWalkspeedRemote = ReplicatedStorage:FindFirstChild("UpdateWalkspeed")

if not UpdateWalkspeedRemote then
	UpdateWalkspeedRemote = Instance.new("RemoteEvent")
	UpdateWalkspeedRemote.Name = "UpdateWalkspeed"
	UpdateWalkspeedRemote.Parent = ReplicatedStorage
end

-- // Sound instance
local CurrentSound = Instance.new("Sound")
CurrentSound.Name = "CurrentSound"
CurrentSound.RollOffMode = Enum.RollOffMode.Linear
CurrentSound.RollOffMinDistance = 10
CurrentSound.RollOffMaxDistance = 75
CurrentSound.Parent = Root

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

	Id = "rbxassetid://" .. Chosen.Name
	Volume = Chosen:GetAttribute("Volume") or 0.5
	PlaybackSpeed = Chosen:GetAttribute("PlaybackSpeed") or 1

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

-- Initialize material
GetFloorMaterial()
GetSoundProperties()
Update()

-- // Sync walkspeed changes from client
UpdateWalkspeedRemote.OnServerEvent:Connect(function(Plr, Walkspeed)
	if Plr ~= Player then
		return
	end

	local Character = Plr.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		Humanoid.WalkSpeed = Walkspeed
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

			if not CurrentSound.Playing then
				CurrentSound.Looped = true
				CurrentSound:Play()
			end
		end
	else
		CurrentSound:Stop()
	end
end)

-- // Poll for floor material changes
task.spawn(function()
	while Character.Parent do
		task.wait(0.1)

		if Humanoid.FloorMaterial ~= FloorMaterial then
			GetFloorMaterial()

			if GetSoundProperties() then
				Update()
			end
		end
	end
end)