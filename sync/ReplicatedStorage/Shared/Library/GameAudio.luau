local Shared = game:GetService("ReplicatedStorage").Shared
local Playback = require(script.Parent.SoundPlayback)
local Audio = {PingRadius = 30}

function Audio.Find(group, name)
	local root = Shared.Assets:FindFirstChild("Sounds")
	local gameSounds = root and root:FindFirstChild("Game")
	local folder = gameSounds and ((group == "Game" or group == "Objectives") and gameSounds or gameSounds:FindFirstChild(group))
	local sound = folder and folder:FindFirstChild(name)
	return sound and sound:IsA("Sound") and sound or nil
end

function Audio.Play(group, name)
	local sound = Audio.Find(group, name)
	if sound then return Playback.Play(sound) end
end

function Audio.Whisper()
	return Audio.Play("Geist", "whisper" .. math.random(1, 4))
end
return Audio
