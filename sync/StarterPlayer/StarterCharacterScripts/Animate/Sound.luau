local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sound_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild('Movement')
local sfx_replicant = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Sounds")
local SoundPlayback = require(ReplicatedStorage.Shared.Library.SoundPlayback)

local function get_floor()
	local FloorMaterial = script.Parent.Parent.Humanoid.FloorMaterial
	local Material = string.split(tostring(FloorMaterial), "Enum.Material.")[2]
	return Material
end

local function get_sound()
	local character = script.Parent.Parent
	local folder = if character:GetAttribute("charging") == true
		then sound_folder:FindFirstChild("Charge")
		else sound_folder:FindFirstChild(get_floor())
	if not folder then return nil end

	local steps = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Sound") and child.Name:match("^step%d+$") then
			table.insert(steps, child)
		end
	end
	if #steps == 0 then return nil end
	return steps[math.random(1, #steps)]
end
module.Play_WalkSFX = function()
	local sound = get_sound()
	
	if not sound then return end
	SoundPlayback.Play(sound, script.Parent.Parent.HumanoidRootPart, { Volume = 1 })
	sfx_replicant:FireServer(sound, script.Parent.Parent.HumanoidRootPart, sound.PlaybackSpeed, 1, 0, 0)
end

return module
