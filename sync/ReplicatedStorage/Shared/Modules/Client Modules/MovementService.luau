local module = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Dynamic character refs
local Character = nil
local Humanoid: Humanoid = nil
local RootPart = nil
local Animator = nil

local function bindCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
	Animator = Humanoid:WaitForChild("Animator")
end


bindCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- // Data
local PlayerData = LocalPlayer:WaitForChild("PlayerData")
local SettingsData = PlayerData:WaitForChild("Settings Data")
local InputOptions = SettingsData:WaitForChild("Input Options")
local SprintKey = InputOptions:WaitForChild("Sprint")
local CrouchKey = InputOptions:WaitForChild("Crouch")

-- // Config
local BaseSpeed          = 10
local MaxSpeed           = 18
local SprintRampTime     = 2

-- // VAULT CONFIG
local VAULT_RAYCAST_RANGE_1 = 2      -- Forward surface detection
local VAULT_RAYCAST_RANGE_2 = 3.5    -- Top clearance
local VAULT_RAYCAST_RANGE_3 = 3      -- Mid clearance
local VAULT_RAYCAST_RANGE_4 = 3      -- Upper clearance
local VAULT_TARGET_UP = 5             -- Distance to move player up
local VAULT_TARGET_FORWARD = 5        -- Distance to move player forward
local VAULT_DURATION = 0.4            -- How long vault physics applies
local VAULT_BODY_POSITION_MAXFORCE = Vector3.new(200000, 200000, 200000)
local VAULT_BODY_POSITION_P = 2000
local VAULT_BODY_POSITION_D = 500

-- // State
local SprintKeyHeld = false
local Sprinting   = false
local LoopRunning = false
local SprintTicker = 0 
local HoldingBreath = false
local IsJumping = false
local fall_time = tick()
local fall_threshold = 0.35
local fall_duration_threshold = 0.3

local W_Locked = true

-- // VAULT STATE
local VaultActive = false
local VaultCooldown = false
local VaultAnimPlaying = false
local mantleAnim = game:GetService("ReplicatedStorage"):WaitForChild("Shared").Assets.Animations.Character.Jumping.Mantle

-- // Velocity tracking for alignment system
-- Track the last few velocity readings to smooth out alignment-caused jitter
local VelocityHistory = {}
local MAX_VELOCITY_HISTORY = 5

local KeyStates = {
	Forward   = false,
	Backwards = false,
	Left      = false,
	Right     = false,
}


-- // Helpers
local function getKeyName(value: string): string
	return value:gsub("Enum.KeyCode.", "")
end

local function getSprintKey()
	return Enum.KeyCode[getKeyName(SprintKey.Value)]
end

local function getCrouchKey()
	return Enum.KeyCode[getKeyName(CrouchKey.Value)]
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function setSprintAttribute(state: boolean)
	if Character then
		Character:SetAttribute("Sprinting", state and true or nil)
	end
end

local function setHoldBreathe(holding: boolean)
	if not Character then return end
	if holding then
		Character:SetAttribute("HoldBreathe", true)
		HoldingBreath = true
	else
		Character:SetAttribute("HoldBreathe", nil)
		HoldingBreath = false
	end

	print("Set HoldBreathe to:", holding)
end

local function resetSpeed()
	if not Character or not Humanoid then return end

	Sprinting = false
	SprintTicker = 0
	setSprintAttribute(false)

	if Character:GetAttribute("Aiming") then
		setHoldBreathe(false)
	else
		Humanoid.WalkSpeed = BaseSpeed
	end
end

--[[
	Check if player can start sprinting based on W_Locked state.
	If W_Locked: must be pressing W
	If not W_Locked: can press any movement key
]]
local function canStartSprint()
	if W_Locked == true then
		return KeyStates.Forward
	else
		-- Can start sprint with any movement key
		return KeyStates.Forward or KeyStates.Backwards or KeyStates.Left or KeyStates.Right
	end
end

--[[
	Get smoothed velocity by averaging recent readings.
	This prevents alignment rotation jitter from breaking sprint.
	Matches ingameScript_GD's velocity checking but with smoothing.
]]
local function getSmoothedVelocity()
	if not RootPart then return 0 end

	local currentVel = RootPart.AssemblyLinearVelocity.Magnitude

	-- Add to history
	table.insert(VelocityHistory, currentVel)

	-- Keep history size limited
	if #VelocityHistory > MAX_VELOCITY_HISTORY then
		table.remove(VelocityHistory, 1)
	end

	-- Average the history
	local sum = 0
	for _, vel in ipairs(VelocityHistory) do
		sum += vel
	end

	return sum / #VelocityHistory
end

--[[
	Check Z-axis velocity (forward/backward).
	Returns the object-space Z velocity relative to character facing direction.
]]
local function getForwardVelocity()
	if not RootPart then return 0 end

	local velocity = RootPart.CFrame:vectorToObjectSpace(RootPart.AssemblyLinearVelocity)
	return velocity.Z
end

local function checkVaultGeometry()
	if not RootPart then
		return false
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {Character}
	rayParams.IgnoreWater = true

	-- Raycast 1: Forward surface check
	local rayOrigin1 = RootPart.Position
	local rayDirection1 = RootPart.CFrame.LookVector * VAULT_RAYCAST_RANGE_1

	local rayResult1 = workspace:Raycast(rayOrigin1, rayDirection1, rayParams)

	local check1 = false

	if rayResult1 then
		local model = rayResult1.Instance:FindFirstAncestorOfClass("Model")
		local hasHumanoid = model and model:FindFirstChildOfClass("Humanoid")

		if not hasHumanoid and rayResult1.Instance.CanCollide then
			check1 = true
		end
	end

	-- Raycast 2: Top clearance
	local rayOrigin2 = RootPart.Position
	local rayDirection2 = RootPart.CFrame.UpVector * VAULT_RAYCAST_RANGE_2

	local rayResult2 = workspace:Raycast(rayOrigin2, rayDirection2, rayParams)

	local check2 = not rayResult2

	-- Raycast 3: Mid clearance
	local rayOrigin3 = RootPart.Position + Vector3.new(0, 2.5, 0)
	local rayDirection3 = RootPart.CFrame.LookVector * VAULT_RAYCAST_RANGE_3

	local rayResult3 = workspace:Raycast(rayOrigin3, rayDirection3, rayParams)

	local check3 = not rayResult3

	-- Raycast 4: Upper clearance
	local rayOrigin4 = RootPart.Position + Vector3.new(0, 6, 0)
	local rayDirection4 = RootPart.CFrame.LookVector * VAULT_RAYCAST_RANGE_4

	local rayResult4 = workspace:Raycast(rayOrigin4, rayDirection4, rayParams)

	local check4 = not rayResult4

	return check1 and check2 and check3 and check4
end

local function executeVault()
	if not Character or not RootPart or not Humanoid then
		return
	end

	VaultActive = true
	VaultCooldown = true

	Character:SetAttribute("Vaulting", true)

	-- Animation
	local animator = Humanoid:FindFirstChildOfClass("Animator")

	if animator then
		pcall(function()
			local track = animator:LoadAnimation(mantleAnim)
			track:Play(0.05)

			VaultAnimPlaying = true
		end)
	end

	-- Calculate target position
	local targetPosition =
		RootPart.Position
		+ Vector3.new(0, VAULT_TARGET_UP, 0)
		+ (RootPart.CFrame.LookVector * VAULT_TARGET_FORWARD)

	-- Create BodyPosition
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "VaultPosition"
	bodyPosition.MaxForce = VAULT_BODY_POSITION_MAXFORCE
	bodyPosition.P = VAULT_BODY_POSITION_P
	bodyPosition.D = VAULT_BODY_POSITION_D
	bodyPosition.Position = targetPosition
	bodyPosition.Parent = RootPart

	-- Cleanup
	task.delay(VAULT_DURATION, function()
		if bodyPosition and bodyPosition.Parent then
			bodyPosition:Destroy()
		end

		Character:SetAttribute("Vaulting", nil)

		VaultActive = false
		VaultAnimPlaying = false
	end)
end

local function checkVaultTrigger()
	if not Character then
		return false
	end

	if not RootPart then
		return false
	end

	if not IsJumping then
		return false
	end

	-- Already vaulting
	if VaultActive then
		return false
	end

	if VaultCooldown then
		return false
	end

	-- Montage checks
	if Character:FindFirstChild("VaultMontage") then
		return false
	end

	if VaultAnimPlaying then
		return false
	end

	-- State checks
	if Character:GetAttribute("Aiming") then
		return false
	end

	if Character:GetAttribute("Crouching") then
		return false
	end

	-- Geometry validation
	local geometryPassed = checkVaultGeometry()

	if not geometryPassed then
		return false
	end

	return true
end

-- // Core loop
local function sprintLoop()
	if LoopRunning then return end
	LoopRunning = true

	SprintTicker = tick()  -- start the ramp timer, matches sprint_ticker = tick()
	print("[SprintLoop] Started - W_Locked:", W_Locked)

	while Sprinting do
		if not Character or not Humanoid or not RootPart then break end

		-- Stop sprinting if aiming
		if Character:GetAttribute("Aiming") then
			print("[SprintLoop] Stopped: Aiming")
			setHoldBreathe(true)
			Sprinting = false  -- ADD THIS LINE
			resetSpeed()       -- ADD THIS LINE
			break
		end

		-- Check if recently jumped/fell but DON'T automatically stop sprint
		-- Instead, check if falling for more than fall_duration_threshold seconds
		if IsJumping then
			local fallDuration = tick() - fall_time
			if fallDuration > fall_duration_threshold then
				print("[SprintLoop] Stopped: Falling for too long -", fallDuration, "seconds")
				Sprinting = false
				resetSpeed()
				break
			end
		end

		-- Check if dead
		if not Character or not Humanoid or not RootPart then break end

		-- Stop sprinting if crouching
		if Character:GetAttribute("Crouching") then
			print("[SprintLoop] Stopped: Crouching")
			break
		end

		-- Only accelerate forward
		-- Enforce W lock behavior
		if W_Locked then
			-- If W is required and not held, cancel sprint entirely
			if not KeyStates.Forward then
				print("[SprintLoop] Stopped: W_Locked but W not held")
				Sprinting = false
				resetSpeed()
				break
			end
		end

		-- Determine if we have ANY movement input (for unlocked freelook sprinting)
		local hasMovementInput =
			KeyStates.Forward or
			KeyStates.Backwards or
			KeyStates.Left or
			KeyStates.Right


		-- Only accelerate forward, but allow sprint persistence differently based on lock
		if W_Locked and KeyStates.Forward or not W_Locked and hasMovementInput then
			local elapsed = tick() - SprintTicker
			local t = math.clamp(elapsed / SprintRampTime, 0, 1)

			-- lerp from base to max over SprintRampTime
			local sprintSpeed = lerp(0, MaxSpeed - BaseSpeed, t)
			Humanoid.WalkSpeed = BaseSpeed + sprintSpeed

			-- apply sprint attribute once ramp is complete
			if t >= 1 then
				setSprintAttribute(true)
			end
		else
			print("[SprintLoop] Not accelerating forward - W:", KeyStates.Forward, "S:", KeyStates.Backwards)
			if W_Locked then
				-- Locked: losing forward input kills sprint
				print("[SprintLoop] Stopped: W_Locked and not pressing W")
				Sprinting = false
				resetSpeed()
				break
			else
				-- Unlocked: allow sprint to persist if ANY movement key is held
				print("[SprintLoop] Unlocked mode - hasMovementInput:", hasMovementInput)
				if hasMovementInput then
					-- Maintain current speed, don't reset ramp
					print("[SprintLoop] Maintaining sprint with non-W movement")
					-- (no-op: preserves momentum feel)
				else
					-- No input at all → stop sprint
					print("[SprintLoop] Stopped: No movement input at all")
					Sprinting = false
					resetSpeed()
					break
				end
			end
		end

		--[[
			Velocity checks - UPDATED to handle alignment rotation jitter.
			
			Instead of checking raw velocity magnitude which is affected by
			the AlignOrientation constraint rotation, we now:
			1. Check forward (Z-axis) velocity specifically
			2. Use smoothed velocity to ignore alignment jitter
			3. Only break if velocity is CONSISTENTLY wrong, not from one frame
		]]

		-- Get forward velocity (accounts for character facing direction)
		local forwardVel = getForwardVelocity()

		-- Stop if moving backwards significantly
		-- This accounts for strafing and alignment rotation
		if forwardVel > 2 then  -- Moving backwards too much
			print("[SprintLoop] Stopped: Moving backwards too much - forwardVel:", forwardVel)
			Sprinting = false
			resetSpeed()
			break
		end

		-- Get smoothed overall velocity (average of last few frames)
		local smoothedVel = getSmoothedVelocity()

		--[[
			Only break if velocity is consistently below walk speed.
			The smoothing prevents alignment rotation from causing false breaks.
			
			Original logic (too strict):
			if math.abs(velocity - Humanoid.WalkSpeed) > 5 and velocity < Humanoid.WalkSpeed then
			
			New logic (accounts for alignment):
			- Smoothed velocity gives us a trend, not a single frame
			- Increased tolerance from 5 to 8 to handle alignment jitter
			- More lenient because rotation shouldn't break sprint
		]]
		if smoothedVel < (Humanoid.WalkSpeed - 8) then
			print("[SprintLoop] Stopped: Velocity too low - smoothedVel:", smoothedVel, "walkSpeed:", Humanoid.WalkSpeed)
			Sprinting = false
			resetSpeed()
			break
		end

		task.wait(0.03) 
	end

	LoopRunning = false
end

local function setupVaultInput()
	RunService.RenderStepped:Connect(function()
		local holdingSpace =
			UserInputService:IsKeyDown(Enum.KeyCode.Space)

		local holdingGamepad =
			UserInputService:IsGamepadButtonDown(0, Enum.KeyCode.ButtonA)

		if holdingSpace or holdingGamepad then
			if checkVaultTrigger() then
				executeVault()
			end
		end
	end)
end

local function setupVaultCooldownReset()
	Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			VaultCooldown = false
		end
	end)
end

-- // Input
function module.start_module()
	if Humanoid then
		Humanoid.WalkSpeed = BaseSpeed
	end
	
	fall_time = tick()
	
	-- Setup vault mechanics
	setupVaultInput()
	setupVaultCooldownReset()

	Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		local aiming = Character:GetAttribute("Aiming")

		if aiming and SprintKeyHeld then
			setHoldBreathe(true)
		else
			setHoldBreathe(false)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == getSprintKey() then
			SprintKeyHeld = true

			-- CHANGED: Allow sprint restart even if recently fell
			-- Remove the fall_threshold check that prevented sprint restart

			if canStartSprint() then
				Sprinting = true
				task.spawn(sprintLoop)
			end

			if Character:GetAttribute("Aiming") then
				setHoldBreathe(true)
			else
				setHoldBreathe(false)
			end
		end

		if input.KeyCode == Enum.KeyCode.W then
			KeyStates.Forward = true
		elseif input.KeyCode == Enum.KeyCode.S then
			KeyStates.Backwards = true
		elseif input.KeyCode == Enum.KeyCode.A then
			KeyStates.Left = true
		elseif input.KeyCode == Enum.KeyCode.D then
			KeyStates.Right = true
		end

		if input.KeyCode == getCrouchKey() then
			if Character:GetAttribute("Crouching") then
				Character:SetAttribute("Crouching", nil)
			else
				Character:SetAttribute("Crouching", true)
				resetSpeed()
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == getSprintKey() then
			SprintKeyHeld = false

			Sprinting = false
			resetSpeed()
			setHoldBreathe(false)
		end

		if input.KeyCode == Enum.KeyCode.W then
			KeyStates.Forward = false
		elseif input.KeyCode == Enum.KeyCode.S then
			KeyStates.Backwards = false
		elseif input.KeyCode == Enum.KeyCode.A then
			KeyStates.Left = false
		elseif input.KeyCode == Enum.KeyCode.D then
			KeyStates.Right = false
		end
	end)

	Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Jumping then
			if Character:GetAttribute("Crouching") then 
				Character:SetAttribute("Crouching", nil)
			end

			LocalPlayer:SetAttribute("Jumping", true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			IsJumping = true
			fall_time = tick() -- start air timer immediately on jump
			task.delay(1, function()
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			end)

		elseif new == Enum.HumanoidStateType.Freefall then
			IsJumping = true
			fall_time = tick()

		elseif new == Enum.HumanoidStateType.Landed then
			LocalPlayer:SetAttribute("Jumping", nil)
			IsJumping = false
			fall_time = tick()  -- Reset fall_time when landing
			print("[StateChanged] Landed - fall_time reset to:", fall_time)
		end
	end)

	Humanoid.HealthChanged:Connect(function()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

		task.delay(1, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end)
	end)


	LocalPlayer:GetAttributeChangedSignal("FreeLook"):Connect(function()
		if not LocalPlayer:GetAttribute("FreeLook") then
			W_Locked = true
			print("[Module] W_Locked set to true")
		else
			W_Locked = false
			print("[Module] W_Locked set to false")
		end
	end)
end

return module