local MusicService = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Constants
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local Assets = SharedFolder:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Music = Sounds:WaitForChild("Music")
local Game = Sounds:WaitForChild("Game")

-- // Variables
local currentAtmosphere

function MusicService.PlayAudio(sound)
	if typeof(sound) ~= "string" then
		sound = sound.Name
	end

	local reference = Sounds:FindFirstChild(sound, true)

	if not reference then
		warn("Audio not found: " .. sound)
		return
	end

	reference = reference:Clone()
	reference.Parent = SoundService
	reference:Play()

	reference.Ended:Connect(function()
		reference:Destroy()
	end)

	return reference
end

function MusicService.PlayAdvance()
	local number = math.random(1, 5)

	MusicService.PlayAudio("advance" .. number)
end

function MusicService.start_module()
end

return MusicService