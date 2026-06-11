local module = {}

local TorsoXRotation = 8 
local TorsoZRotation = 6 
local LegRotation = 3.5

-- Smoothing settings (higher = smoother but slower response)
local SMOOTHNESS = 8 -- Exponential decay rate

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

-- Current smoothed values
local SmoothedValue1 = 0
local SmoothedValue2 = 0

-- Store original C0 positions
local RootJointC0 = nil
local LeftHipJointC0 = nil
local RightHipJointC0 = nil

local activeConnection = nil  -- track the current RenderStepped connection

local function ExponentialDecay(current, target, decay, deltaTime)
	return current + (target - current) * (1 - math.exp(-decay * deltaTime))
end

function module.start_module()
	local function setupCharacter(character)
		if activeConnection then
			activeConnection:Disconnect() -- disconnect previous connection
			activeConnection = nil
		end
		
		local humanoid = character:WaitForChild("Humanoid")
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local torso = character:WaitForChild("Torso")
		
		local rootJoint = humanoidRootPart:WaitForChild("RootJoint")
		local leftHipJoint = torso:WaitForChild("Left Hip")
		local rightHipJoint = torso:WaitForChild("Right Hip")
		
		-- Store original C0 positions
		RootJointC0 = rootJoint.C0
		LeftHipJointC0 = leftHipJoint.C0
		RightHipJointC0 = rightHipJoint.C0
		
		-- Reset smoothed values on new character
		SmoothedValue1 = 0
		SmoothedValue2 = 0
		
		activeConnection = RunService.RenderStepped:Connect(function(deltaTime)
			local force = humanoidRootPart.Velocity * Vector3.new(1, 0, 1)
			local targetValue1 = 0
			local targetValue2 = 0
			
			if force.Magnitude > 0.001 then
				local direction = force.Unit
				targetValue1 = humanoidRootPart.CFrame.RightVector:Dot(direction)
				targetValue2 = humanoidRootPart.CFrame.LookVector:Dot(direction)
			end
			
			-- Smooth the values using exponential decay with delta time
			SmoothedValue1 = ExponentialDecay(SmoothedValue1, targetValue1, SMOOTHNESS, deltaTime)
			SmoothedValue2 = ExponentialDecay(SmoothedValue2, targetValue2, SMOOTHNESS, deltaTime)
			
			-- Apply smoothed rotations
			rootJoint.C0 = RootJointC0 * CFrame.Angles(
				math.rad(SmoothedValue2 * TorsoZRotation),
				math.rad(-SmoothedValue1 * TorsoXRotation),
				0
			)
			leftHipJoint.C0 = LeftHipJointC0 * CFrame.Angles(math.rad(SmoothedValue1 * LegRotation), 0, 0)
			rightHipJoint.C0 = RightHipJointC0 * CFrame.Angles(math.rad(-SmoothedValue1 * LegRotation), 0, 0)
		end)
	end
	
	-- Handle current character if it exists
	if Player.Character then
		setupCharacter(Player.Character)
	end
	
	-- Handle future character respawns
	Player.CharacterAdded:Connect(setupCharacter)
end

return module