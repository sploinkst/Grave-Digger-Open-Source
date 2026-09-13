local MusicService = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Constants
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local Assets = SharedFolder:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Atmosphere = Sounds:WaitForChild("Atmosphere")

-- // Variables
local currentAtmosphere
local activeDreadMusic
local startingAtmosphere = false

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

local function isCaveAtmosphere(sound: Instance): boolean
	if sound == currentAtmosphere then return true end
	if sound.Name == "CaveAtmosphere" then return true end
	if sound:IsA("Sound") and sound:GetAttribute("AlwaysPlay") == true then return true end
	return false
end

function MusicService.StopMusicExceptCave()
	for _, child in ipairs(SoundService:GetChildren()) do
		if child:IsA("Sound") and not isCaveAtmosphere(child) then
			child:Stop()
			child:Destroy()
		end
	end
end

function MusicService.PlayDreadnought(teamName: string?)
	local trackName = teamName == "Golden Empire" and "dread_empire" or "dread_nation"
	MusicService.StopMusicExceptCave()
	activeDreadMusic = MusicService.PlayAudio(trackName)
	if activeDreadMusic then
		activeDreadMusic.Name = "DreadnoughtMusic"
		activeDreadMusic.Looped = true
		activeDreadMusic.Volume = math.min(activeDreadMusic.Volume * 1.5, 10)
	end
	return activeDreadMusic
end

function MusicService.start_module()
	-- Every client owns its own ambience track. Keeping the clone in
	-- SoundService makes it non-positional and prevents character respawns from
	-- stopping it.
	if startingAtmosphere or (currentAtmosphere and currentAtmosphere.Parent) then return end
	startingAtmosphere = true
	local source = Atmosphere:WaitForChild("cave5")
	if not source:IsA("Sound") then
		startingAtmosphere = false
		warn("[MusicService] Atmosphere.cave5 is not a Sound")
		return
	end
	currentAtmosphere = source:Clone()
	currentAtmosphere.Name = "CaveAtmosphere"
	currentAtmosphere:SetAttribute("AlwaysPlay", true)
	currentAtmosphere.Looped = true
	currentAtmosphere.Parent = SoundService
	currentAtmosphere:Play()
	startingAtmosphere = false
end

return MusicService
