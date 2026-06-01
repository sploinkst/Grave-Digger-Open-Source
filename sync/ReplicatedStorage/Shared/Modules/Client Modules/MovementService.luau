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
local Checked = false

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
local VelocityHistory = {}
local MAX_VELOCITY_HISTORY = 5

local KeyStates = {
	Forward   = false,
	Backwards = false,
	Left      = false,
	Right     = false,
}

-- Forward declaration of loop trigger to allow cross-calling
local tryStartSprint

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
]]
local function canStartSprint()
	-- Don't start sprinting if aiming or crouching
	if not Character or Character:GetAttribute("Aiming") or Character:GetAttribute("Crouching") then
		return false
	end

	if W_Locked == true then
		return KeyStates.Forward
	else
		return KeyStates.Forward or KeyStates.Backwards or KeyStates.Left or KeyStates.Right
	end
end

local function getSmoothedVelocity()
	if not RootPart then return 0 end

	local currentVel = RootPart.AssemblyLinearVelocity.Magnitude

	table.insert(VelocityHistory, currentVel)

	if #VelocityHistory > MAX_VELOCITY_HISTORY then
		table.remove(VelocityHistory, 1)
	end

	local sum = 0
	for _, vel in ipairs(VelocityHistory) do
		sum += vel
	end

	return sum / #VelocityHistory
end

local function getForwardVelocity()
	if not RootPart then return 0 end

	local velocity = RootPart.CFrame:vectorToObjectSpace(RootPart.AssemblyLinearVelocity)
	return velocity.Z
end

local function checkVaultGeometry()
	if not RootPart then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {Character}
	rayParams.IgnoreWater = true

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

	local rayOrigin2 = RootPart.Position
	local rayDirection2 = RootPart.CFrame.UpVector * VAULT_RAYCAST_RANGE_2
	local rayResult2 = workspace:Raycast(rayOrigin2, rayDirection2, rayParams)
	local check2 = not rayResult2

	local rayOrigin3 = RootPart.Position + Vector3.new(0, 2.5, 0)
	local rayDirection3 = RootPart.CFrame.LookVector * VAULT_RAYCAST_RANGE_3
	local rayResult3 = workspace:Raycast(rayOrigin3, rayDirection3, rayParams)
	local check3 = not rayResult3

	local rayOrigin4 = RootPart.Position + Vector3.new(0, 6, 0)
	local rayDirection4 = RootPart.CFrame.LookVector * VAULT_RAYCAST_RANGE_4
	local rayResult4 = workspace:Raycast(rayOrigin4, rayDirection4, rayParams)
	local check4 = not rayResult4

	return check1 and check2 and check3 and check4
end

local function executeVault()
	if not Character or not RootPart or not Humanoid then return end

	VaultActive = true
	VaultCooldown = true
	Character:SetAttribute("Vaulting", true)

	local animator = Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		pcall(function()
			local track = animator:LoadAnimation(mantleAnim)
			track:Play(0.05)
			VaultAnimPlaying = true
		end)
	end

	local targetPosition = RootPart.Position + Vector3.new(0, VAULT_TARGET_UP, 0) + (RootPart.CFrame.LookVector * VAULT_TARGET_FORWARD)

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "VaultPosition"
	bodyPosition.MaxForce = VAULT_BODY_POSITION_MAXFORCE
	bodyPosition.P = VAULT_BODY_POSITION_P
	bodyPosition.D = VAULT_BODY_POSITION_D
	bodyPosition.Position = targetPosition
	bodyPosition.Parent = RootPart

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
	if not Character or not RootPart or not IsJumping or VaultActive or VaultCooldown or Character:FindFirstChild("VaultMontage") or VaultAnimPlaying then
		return false
	end

	if Character:GetAttribute("Aiming") or Character:GetAttribute("Crouching") then
		return false
	end

	return checkVaultGeometry()
end

-- // Core loop
local function sprintLoop()
	if LoopRunning then return end
	LoopRunning = true

	SprintTicker = tick() 
	print("[SprintLoop] Started - W_Locked:", W_Locked)

	while Sprinting do
		if not Character or not Humanoid or not RootPart then break end

		-- // if aiming and not moving
		if Character:GetAttribute("Aiming") and Character.Humanoid.MoveDirection.Magnitude <= 0 then
			print("[SprintLoop] Stopped: Aiming")
			setHoldBreathe(true)
			break
		end

		if IsJumping then
			local fallDuration = tick() - fall_time
			if fallDuration > fall_duration_threshold then
				print("[SprintLoop] Stopped: Falling for too long")
				break
			end
		end

		if Character:GetAttribute("Crouching") then
			print("[SprintLoop] Stopped: Crouching")
			break
		end

		if W_Locked and not KeyStates.Forward then
			print("[SprintLoop] Stopped: W_Locked but W not held")
			break
		end

		local hasMovementInput = KeyStates.Forward or KeyStates.Backwards or KeyStates.Left or KeyStates.Right

		if W_Locked and KeyStates.Forward or not W_Locked and hasMovementInput then
			local elapsed = tick() - SprintTicker
			local t = math.clamp(elapsed / SprintRampTime, 0, 1)

			local sprintSpeed = lerp(0, MaxSpeed - BaseSpeed, t)
			Humanoid.WalkSpeed = BaseSpeed + sprintSpeed

			if t >= 0.8 then
				setSprintAttribute(true)
			end
		else
			if W_Locked then
				print("[SprintLoop] Stopped: W_Locked and not pressing W")
				break
			else
				if not hasMovementInput then
					print("[SprintLoop] Stopped: No movement input at all")
					break
				end
			end
		end

		-- Velocity checks (e.g. wall bumps)
		local forwardVel = getForwardVelocity()
		if forwardVel > 2 then 
			print("[SprintLoop] Stopped: Moving backwards too much")
			break
		end

		local smoothedVel = getSmoothedVelocity()
		if smoothedVel < (Humanoid.WalkSpeed - 8) then
			print("[SprintLoop] Stopped: Velocity too low (Hit a wall)")
			break
		end

		task.wait(0.03) 
	end

	-- Clean up current sprint state safely
	LoopRunning = false
	resetSpeed()
	
	if SprintKeyHeld and not Checked then
		task.defer(function()
			print("[SprintLoop] Monitoring for Auto-Rebuild...")
			while SprintKeyHeld and not Sprinting and not Checked do
				if canStartSprint() then
					Checked = true
					local smoothedVel = getSmoothedVelocity()
					-- Give a tiny bit of leniency to start accelerating again away from the wall
					if smoothedVel >= (BaseSpeed - 3) or (not W_Locked and smoothedVel > 2) then
						print("[SprintLoop] Auto-Rebuild conditions met. Restarting!")
						tryStartSprint()
						break
					end
				end
				task.wait(0.1)
			end
		end)
	end
end

-- Dedicated initialization function to avoid double-loop fires
function tryStartSprint()
	if not Sprinting and canStartSprint() then
		Sprinting = true
		task.spawn(sprintLoop)
		
		task.delay(0.5, function()
			Checked = false
		end)
	end
end

local function setupVaultInput()
	RunService.RenderStepped:Connect(function()
		local holdingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)
		local holdingGamepad = UserInputService:IsGamepadButtonDown(0, Enum.KeyCode.ButtonA)

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
	
	Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		if Character:GetAttribute("Aiming") then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			print("[Module] Jumping disabled for aiming")
		else
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			print("[Module] Jumping enabled for aiming")
		end
	end)

	fall_time = tick()

	setupVaultInput()
	setupVaultCooldownReset()

	Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		local aiming = Character:GetAttribute("Aiming")
		if aiming and SprintKeyHeld and Character.Humanoid.MoveDirection.Magnitude <= 0 then
			setHoldBreathe(true)
		else
			setHoldBreathe(false)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.W then
			KeyStates.Forward = true
			if SprintKeyHeld then tryStartSprint() end
		elseif input.KeyCode == Enum.KeyCode.S then
			KeyStates.Backwards = true
			if SprintKeyHeld then tryStartSprint() end
		elseif input.KeyCode == Enum.KeyCode.A then
			KeyStates.Left = true
			if SprintKeyHeld then tryStartSprint() end
		elseif input.KeyCode == Enum.KeyCode.D then
			KeyStates.Right = true
			if SprintKeyHeld then tryStartSprint() end
		end

		if input.KeyCode == getSprintKey() then
			SprintKeyHeld = true
			tryStartSprint()

			if Character:GetAttribute("Aiming") and Character.Humanoid.MoveDirection.Magnitude <= 0 then
				setHoldBreathe(true)
			else
				setHoldBreathe(false)
			end
		end

		if input.KeyCode == getCrouchKey() then
			if Character:GetAttribute("Crouching") then
				Character:SetAttribute("Crouching", nil)
				if SprintKeyHeld then tryStartSprint() end
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

			if Character:GetAttribute("Aiming") then
				return
			end
			
			LocalPlayer:SetAttribute("Jumping", true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			IsJumping = true
			fall_time = tick()
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
			print("[StateChanged] Landed - fall_time reset to:", fall_time)

			-- Rebuild sprint upon landing if key is still pinned down
			if SprintKeyHeld then tryStartSprint() end
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
		if SprintKeyHeld then tryStartSprint() end
	end)

end

return module