local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sound_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild('Movement')
local sfx_replicant = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Replicant_Communication"):WaitForChild("SFX_Connection")

local function get_floor()
	local FloorMaterial = script.Parent.Parent.Humanoid.FloorMaterial
	local Material = string.split(tostring(FloorMaterial), "Enum.Material.")[2]
	return Material
end

local function get_sound()
	local sound = sound_folder:FindFirstChild(get_floor())
	
	if sound then
		-- // select random sound
		
		local sound = sound:FindFirstChild("step" .. math.random(1,3))
		local sound_clone = sound:Clone()
		sound_clone.Parent = script.Parent.Parent.HumanoidRootPart
		
		return sound_clone
	end
	
end
module.Play_WalkSFX = function()
	local sound = get_sound()
	
	if not sound then return end
	
	sound:Play()
	sfx_replicant:FireServer(sound, script.Parent.Parent.HumanoidRootPart)
	
	print(sound.Name, "Is playing")
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return module
