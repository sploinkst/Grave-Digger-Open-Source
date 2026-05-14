local module = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

-- // State
local Sprinting   = false
local LoopRunning = false
local SprintTicker = 0 
local HoldingBreath = false
local IsJumping = true
local fall_time = tick()
local fall_threshold = 0.35

local W_Locked = true

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

-- // Core loop
local function sprintLoop()
	if LoopRunning then return end
	LoopRunning = true

	SprintTicker = tick()  -- start the ramp timer, matches sprint_ticker = tick()
	print("[SprintLoop] Started - W_Locked:", W_Locked)

	while Sprinting do
		if not Character or not Humanoid or not RootPart then break end

		-- Check if recently jumped/fell
		if (tick() - fall_time) < fall_threshold then
			print("[SprintLoop] Stopped: Recently jumped/fell")
			Sprinting = false
			resetSpeed()
			break
		end

		-- Check if dead
		if not Character or not Humanoid or not RootPart then break end

		-- Stop sprinting if crouching
		if Character:GetAttribute("Crouching") then
			print("[SprintLoop] Stopped: Crouching")
			break
		end

		-- Stop sprinting if aiming
		if Character:GetAttribute("Aiming") then
			print("[SprintLoop] Stopped: Aiming")
			setHoldBreathe(true)
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

-- // Input
function module.start_module()
	if Humanoid then
		Humanoid.WalkSpeed = BaseSpeed
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == getSprintKey() then
			if (tick() - fall_time) < fall_threshold then
				return
			end

			-- Check if player can start sprint based on W_Locked state
			if canStartSprint() then
				Sprinting = true
				task.spawn(sprintLoop)
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
			fall_time = tick() 
		end
	end)

	Humanoid.HealthChanged:Connect(function()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

		task.delay(1, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end)
	end)

	Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		if not Character:GetAttribute("Aiming") and HoldingBreath == true then
			setHoldBreathe(false)
		end
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