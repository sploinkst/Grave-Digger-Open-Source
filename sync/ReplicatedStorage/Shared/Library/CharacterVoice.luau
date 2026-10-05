local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Playback = require(script.Parent.SoundPlayback)
local Voice = {}

function Voice.Prefix(character)
	local gender = character and character:FindFirstChild("gender")
	local selected = gender and gender:IsA("StringValue") and gender.Value
	if not selected then
		local player = character and Players:GetPlayerFromCharacter(character)
		local data = player and require(Shared.Library.CosmeticAppearance).Data(player)
		local value = data and data:FindFirstChild("Gender")
		selected = value and value.Value
	end
	return typeof(selected) == "string" and selected:lower():sub(1, 1) == "f" and "f" or "m"
end

function Voice.Choose(character, kind)
	local sounds = Shared.Assets:FindFirstChild("Sounds")
	local folder = sounds and sounds:FindFirstChild("PlayerSounds")
	if not folder then return nil end
	local prefix = Voice.Prefix(character) .. "_" .. kind
	local choices = {}
	for _, sound in folder:GetChildren() do
		if sound:IsA("Sound") and (sound.Name == prefix or sound.Name:match("^" .. prefix .. "%d+$")) then table.insert(choices, sound) end
	end
	return #choices > 0 and choices[math.random(1, #choices)] or nil
end

function Voice.Play(character, kind)
	local sound = Voice.Choose(character, kind)
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head"))
	if sound and root then return Playback.Play(sound, root) end
end
return Voice
