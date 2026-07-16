local module = {}

local TorsoXRotation = 2
local TorsoZRotation = 3
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

local activeConnection: RBXScriptConnection? = nil
local characterAddedConnection: RBXScriptConnection? = nil
local characterRemovingConnection: RBXScriptConnection? = nil

local started = false

local function ExponentialDecay(current, target, decay, deltaTime)
	return current + (target - current) * (1 - math.exp(-decay * deltaTime))
end

local function disconnectRender()
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end
end

local function setupCharacter(character: Model)
	disconnectRender()

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

	-- Reset smoothing
	SmoothedValue1 = 0
	SmoothedValue2 = 0

	activeConnection = RunService.RenderStepped:Connect(function(deltaTime)
		-- Stop if character disappears
		if character.Parent == nil then
			disconnectRender()
			return
		end

		local force = humanoidRootPart.Velocity * Vector3.new(1, 0, 1)

		local targetValue1 = 0
		local targetValue2 = 0

		if force.Magnitude > 0.001 then
			local direction = force.Unit
			targetValue1 = humanoidRootPart.CFrame.RightVector:Dot(direction)
			targetValue2 = humanoidRootPart.CFrame.LookVector:Dot(direction)
		end

		SmoothedValue1 = ExponentialDecay(
			SmoothedValue1,
			targetValue1,
			SMOOTHNESS,
			deltaTime
		)

		SmoothedValue2 = ExponentialDecay(
			SmoothedValue2,
			targetValue2,
			SMOOTHNESS,
			deltaTime
		)

		rootJoint.C0 = RootJointC0 * CFrame.Angles(
			math.rad(SmoothedValue2 * TorsoZRotation),
			math.rad(-SmoothedValue1 * TorsoXRotation),
			0
		)

		leftHipJoint.C0 = LeftHipJointC0 * CFrame.Angles(
			math.rad(SmoothedValue1 * LegRotation),
			0,
			0
		)

		rightHipJoint.C0 = RightHipJointC0 * CFrame.Angles(
			math.rad(-SmoothedValue1 * LegRotation),
			0,
			0
		)
	end)
end

function module.start_module()
	if started then
		return
	end

	started = true

	if Player.Character then
		task.spawn(setupCharacter, Player.Character)
	end

	characterAddedConnection = Player.CharacterAdded:Connect(setupCharacter)

	characterRemovingConnection = Player.CharacterRemoving:Connect(function()
		disconnectRender()
		started = false
	end)
end


return module