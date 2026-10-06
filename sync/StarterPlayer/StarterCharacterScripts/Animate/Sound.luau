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
	local character = script.Parent.Parent
	local adjustment, maxDistance = 0, nil
	if character:GetAttribute("charging") ~= true then
		local quiet = character:GetAttribute("TunnelRat") == true or character:GetAttribute("Crouching") == true
		if quiet then maxDistance = 10; adjustment = -0.25 end
		if character:GetAttribute("Sprinting") == true then
			adjustment = math.clamp(character:GetAttribute("SprintProgress") or 0, 0, 1) - (quiet and 0.25 or 0)
		end
		if character:FindFirstChild("dreadnought") or character:GetAttribute("Dreadnought") == true then adjustment = 0.4 end
		if character.Humanoid:GetState() == Enum.HumanoidStateType.Climbing then adjustment = -0.2 end
	end
	local volume = math.max(sound.Volume + adjustment, 0)
	SoundPlayback.Play(sound, character.HumanoidRootPart, { Volume = volume, RollOffMaxDistance = maxDistance })
	sfx_replicant:FireServer(sound, character.HumanoidRootPart, sound.PlaybackSpeed, volume, 0, 0, maxDistance)
end

return module
