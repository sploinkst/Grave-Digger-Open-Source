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
local Atmosphere = Sounds:WaitForChild("Atmosphere")

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
	-- Every client owns its own ambience track. Keeping the clone in
	-- SoundService makes it non-positional and prevents character respawns from
	-- stopping it.
	if currentAtmosphere and currentAtmosphere.Parent then return end
	local source = Atmosphere:WaitForChild("cave5")
	if not source:IsA("Sound") then
		warn("[MusicService] Atmosphere.cave5 is not a Sound")
		return
	end
	currentAtmosphere = source:Clone()
	currentAtmosphere.Name = "CaveAtmosphere"
	currentAtmosphere.Looped = true
	currentAtmosphere.Parent = SoundService
	currentAtmosphere:Play()
end

return MusicService
