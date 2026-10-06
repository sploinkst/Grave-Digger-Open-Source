local Shared = game:GetService("ReplicatedStorage").Shared
local Playback = require(script.Parent.SoundPlayback)
local Audio = {}

function Audio.Find(name)
	local sounds = Shared.Assets:FindFirstChild("Sounds")
	local folder = sounds and sounds:FindFirstChild("Constructs")
	if not folder then return nil end
	local exact = folder:FindFirstChild(name)
	if exact and exact:IsA("Sound") then return exact end
	local choices = {}
	for _, sound in folder:GetChildren() do
		if sound:IsA("Sound") and sound.Name:sub(1, #name) == name
			and sound.Name:sub(#name + 1):match("^%d+$") then table.insert(choices, sound) end
	end
	return #choices > 0 and choices[math.random(#choices)] or nil
end

function Audio.Play(name, origin)
	local sound = Audio.Find(name)
	if sound then return Playback.Play(sound, origin, {PitchVariation = 0.1, RollOffMaxDistance = 75}) end
end

function Audio.Material(model, hit)
	local name = model and model.Name:lower() or ""
	if name:find("sand", 1, true) then return "sand" end
	local material = hit and hit:IsA("BasePart") and hit.Material
	if material == Enum.Material.Metal or material == Enum.Material.DiamondPlate
		or material == Enum.Material.CorrodedMetal or name:find("shield", 1, true)
		or name:find("wire", 1, true) or name:find("turret", 1, true) then return "metal" end
	return "wood"
end

function Audio.Impact(model, hit, destroyed)
	local material = Audio.Material(model, hit)
	local name = destroyed and (material == "sand" and "sand_destroy" or material == "metal" and "destroy_metal" or "destroy")
		or (material == "sand" and "hit_sand" or material == "metal" and "hit_metal" or "hit")
	return Audio.Play(name, hit or model)
end
return Audio
