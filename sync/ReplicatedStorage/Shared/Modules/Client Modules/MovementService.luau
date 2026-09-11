local module = {}

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SettingsManager = require(
	ReplicatedStorage.Shared.Modules["Client Modules"].SettingsManager
)

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Dynamic character refs
local Character = nil
local Humanoid: Humanoid = nil
local RootPart = nil
local Animator = nil

-- // Config
local BaseSpeed = 10
local MaxSpeed = 18
local SprintRampTime = 2
local RestrictedSpeedMultiplier = 0.5

-- // VAULT CONFIG
local VAULT_RAYCAST_RANGE_1 = 2
local VAULT_RAYCAST_RANGE_2 = 3.5
local VAULT_RAYCAST_RANGE_3 = 3
local VAULT_RAYCAST_RANGE_4 = 3

local VAULT_TARGET_UP = 5
local VAULT_TARGET_FORWARD = 5
local VAULT_DURATION = 0.4

local VAULT_BODY_POSITION_MAXFORCE =
	Vector3.new(200000, 200000, 200000)

local VAULT_BODY_POSITION_P = 2000
local VAULT_BODY_POSITION_D = 500

-- // State
local SprintKeyHeld = false
local Sprinting = false
local LoopRunning = false
local Checked = false

local SprintTicker = 0

local HoldBreathe_time = 5.5
local HoldBreathe_regen = 2.5
local HoldBreathe_maxaccuracy = 0.35

local HoldingBreath = false
local HoldBreathStart = 0
local HoldBreathCooldownEnd = 0

local IsJumping = false
local IsClimbing = false

local fall_time = tick()
local fall_threshold = 0.35
local fall_duration_threshold = 0.3

local LastSprintCancelTime = 0
local AimSprintCooldown = 0.35

local InputsBinded = false

local W_Locked = true

-- // VAULT STATE
local VaultActive = false
local VaultCooldown = false
local VaultAnimPlaying = false

local mantleAnim =
	ReplicatedStorage
	:WaitForChild("Shared")
	.Assets
	.Animations
	.Character
	.Jumping
	.Mantle

-- // Velocity tracking
local VelocityHistory = {}
local MAX_VELOCITY_HISTORY = 5

local KeyStates = {
	Forward = false,
	Backwards = false,
	Left = false,
	Right = false,
}

-- // Connection tracking
local characterConnections = {}

-- // Forward declaration
local tryStartSprint

-- // Helpers

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function getOrderSpeedMultiplier()
	if not Character then
		return 1
	end

	return Character:GetAttribute("OrderSpeedMultiplier") or 1
end

local function isAiming()
	return Character
		and Character:GetAttribute("Aiming") == true
end

local function isCrouching()
	return Character
		and Character:GetAttribute("Crouching") == true
end

local function isADSMovementExempt()
	return Character
		and Character:GetAttribute("ADSMovementExempt") == true
end

local function getAimingSpeed()
	local orderSpeed = getOrderSpeedMultiplier()

	-- Normal aiming movement.
	if not isADSMovementExempt() then
		return BaseSpeed
			* RestrictedSpeedMultiplier
			* orderSpeed
	end

	-- Special tools that explicitly allow normal movement while aiming.
	return BaseSpeed * orderSpeed
end

local function getNormalSpeed()
	local orderSpeed = getOrderSpeedMultiplier()

	if isCrouching() then
		return BaseSpeed
			* RestrictedSpeedMultiplier
			* orderSpeed
	end

	return BaseSpeed * orderSpeed
end

local function setSprintAttribute(state: boolean)
	if not Character then
		return
	end

	local data = Character:FindFirstChild("CharacterData")

	local value =
		data
		and data:FindFirstChild("State")
		and data.State:FindFirstChild("Sprinting")

	if value and value:IsA("BoolValue") then
		value.Value = state
	end

	Character:SetAttribute(
		"Sprinting",
		state and true or nil
	)
end

local function setCharacterBool(name: string, state: boolean)
	if not Character then
		return
	end

	local data = Character:FindFirstChild("CharacterData")

	local value =
		data
		and data:FindFirstChild("State")
		and data.State:FindFirstChild(name)

	if value and value:IsA("BoolValue") then
		value.Value = state
	end

	Character:SetAttribute(
		name,
		state and true or nil
	)
end

-- // Hold Breath

local function setHoldBreathe(holding: boolean)
	if not Character then
		return
	end

	if holding then

		if HoldingBreath then
			return
		end

		if tick() < HoldBreathCooldownEnd then
			return
		end

		HoldingBreath = true
		HoldBreathStart = tick()

		setCharacterBool("HoldBreathe", true)

		task.spawn(function()

			while HoldingBreath do

				if not Character then
					break
				end

				if not Character:GetAttribute("Aiming") then
					break
				end

				if Character.Humanoid.MoveDirection.Magnitude > 0 then
					break
				end

				if not SprintKeyHeld then
					break
				end

				if tick() - HoldBreathStart >= HoldBreathe_time then
					break
				end

				if Character:GetAttribute("HoldBreathe") ~= true then
					break
				end

				task.wait(0.05)
			end

			if HoldingBreath then

				HoldingBreath = false

				HoldBreathCooldownEnd =
					tick() + HoldBreathe_regen

				if Character
					and Character:GetAttribute("HoldBreathe") then

					setCharacterBool(
						"HoldBreathe",
						false
					)
				end

				print(
					"[HoldBreath] Ended. Cooldown until:",
					HoldBreathCooldownEnd
				)
			end
		end)

	else

		if not HoldingBreath then
			return
		end

		HoldingBreath = false

		HoldBreathCooldownEnd =
			tick() + HoldBreathe_regen

		if Character:GetAttribute("HoldBreathe") then
			setCharacterBool(
				"HoldBreathe",
				false
			)
		end

		print(
			"[HoldBreath] Ended manually. Cooldown until:",
			HoldBreathCooldownEnd
		)
	end
end

-- // Speed

local function resetSpeed()
	if not Character or not Humanoid then
		return
	end

	Sprinting = false
	SprintTicker = 0

	setSprintAttribute(false)

	-- AIMING ALWAYS WINS.
	if isAiming() then

		setHoldBreathe(false)

		Humanoid.WalkSpeed =
			getAimingSpeed()

		return
	end

	-- Normal / crouch movement.
	Humanoid.WalkSpeed =
		getNormalSpeed()
end

local function applyRestrictedSpeed()
	if not Character or not Humanoid then
		return
	end

	-- AIMING ALWAYS WINS.
	if isAiming() then
		Humanoid.WalkSpeed =
			getAimingSpeed()

		return
	end

	-- Crouching.
	Humanoid.WalkSpeed =
		getNormalSpeed()
end

-- // IMPORTANT:
-- // This function is called continuously by the sprint loop.
-- // It prevents the sprint loop from ever leaving WalkSpeed
-- // at a sprint value while aiming.

local function enforceMovementSpeed()
	if not Character or not Humanoid then
		return
	end

	if isAiming() then

		local aimingSpeed = getAimingSpeed()

		if Humanoid.WalkSpeed ~= aimingSpeed then
			Humanoid.WalkSpeed = aimingSpeed
		end

		return
	end
end

-- // Sprint

local function canStartSprint()
	if not Character then
		return false
	end

	-- NEVER sprint while aiming.
	if Character:GetAttribute("Aiming") then
		return false
	end

	-- NEVER sprint while crouching.
	if Character:GetAttribute("Crouching") then
		return false
	end

	if IsClimbing then
		return false
	end

	if W_Locked == true then
		return KeyStates.Forward
	else
		return
			KeyStates.Forward
			or KeyStates.Backwards
			or KeyStates.Left
			or KeyStates.Right
	end
end

local function getSmoothedVelocity()
	if not RootPart then
		return 0
	end

	local currentVel =
		RootPart.AssemblyLinearVelocity.Magnitude

	table.insert(
		VelocityHistory,
		currentVel
	)

	if #VelocityHistory > MAX_VELOCITY_HISTORY then
		table.remove(
			VelocityHistory,
			1
		)
	end

	local sum = 0

	for _, vel in ipairs(VelocityHistory) do
		sum += vel
	end

	if #VelocityHistory == 0 then
		return 0
	end

	return sum / #VelocityHistory
end

local function getForwardVelocity()
	if not RootPart then
		return 0
	end

	local velocity =
		RootPart.CFrame:VectorToObjectSpace(
			RootPart.AssemblyLinearVelocity
		)

	return velocity.Z
end

-- // Vault

local function checkVaultGeometry()
	if not RootPart then
		return false
	end

	local rayParams = RaycastParams.new()

	rayParams.FilterType =
		Enum.RaycastFilterType.Exclude

	rayParams.FilterDescendantsInstances = {
		Character
	}

	rayParams.IgnoreWater = true

	-- Ray 1
	local rayOrigin1 = RootPart.Position

	local rayDirection1 =
		RootPart.CFrame.LookVector
		* VAULT_RAYCAST_RANGE_1

	local rayResult1 =
		workspace:Raycast(
			rayOrigin1,
			rayDirection1,
			rayParams
		)

	local check1 = false

	if rayResult1 then

		local model =
			rayResult1.Instance
			:FindFirstAncestorOfClass("Model")

		local hasHumanoid =
			model
			and model:FindFirstChildOfClass("Humanoid")

		if not hasHumanoid
			and rayResult1.Instance.CanCollide then

			check1 = true
		end
	end

	-- Ray 2
	local rayOrigin2 = RootPart.Position

	local rayDirection2 =
		RootPart.CFrame.UpVector
		* VAULT_RAYCAST_RANGE_2

	local rayResult2 =
		workspace:Raycast(
			rayOrigin2,
			rayDirection2,
			rayParams
		)

	local check2 = not rayResult2

	-- Ray 3
	local rayOrigin3 =
		RootPart.Position
		+ Vector3.new(0, 2.5, 0)

	local rayDirection3 =
		RootPart.CFrame.LookVector
		* VAULT_RAYCAST_RANGE_3

	local rayResult3 =
		workspace:Raycast(
			rayOrigin3,
			rayDirection3,
			rayParams
		)

	local check3 = not rayResult3

	-- Ray 4
	local rayOrigin4 =
		RootPart.Position
		+ Vector3.new(0, 6, 0)

	local rayDirection4 =
		RootPart.CFrame.LookVector
		* VAULT_RAYCAST_RANGE_4

	local rayResult4 =
		workspace:Raycast(
			rayOrigin4,
			rayDirection4,
			rayParams
		)

	local check4 = not rayResult4

	return
		check1
		and check2
		and check3
		and check4
end

local function executeVault()
	if not Character
		or not RootPart
		or not Humanoid then

		return
	end

	VaultActive = true
	VaultCooldown = true

	setCharacterBool(
		"Vaulting",
		true
	)

	local animator =
		Humanoid:FindFirstChildOfClass("Animator")

	if animator then

		pcall(function()

			local track =
				animator:LoadAnimation(
					mantleAnim
				)

			track.Priority =
				Enum.AnimationPriority.Action

			track:Play(0.05)

			VaultAnimPlaying = true
		end)
	end

	local targetPosition =
		RootPart.Position
		+ Vector3.new(
			0,
			VAULT_TARGET_UP,
			0
		)
		+ (
			RootPart.CFrame.LookVector
			* VAULT_TARGET_FORWARD
		)

	local bodyPosition =
		Instance.new("BodyPosition")

	bodyPosition.Name =
		"VaultPosition"

	bodyPosition.MaxForce =
		VAULT_BODY_POSITION_MAXFORCE

	bodyPosition.P =
		VAULT_BODY_POSITION_P

	bodyPosition.D =
		VAULT_BODY_POSITION_D

	bodyPosition.Position =
		targetPosition

	bodyPosition.Parent =
		RootPart

	task.delay(
		VAULT_DURATION,
		function()

			if bodyPosition
				and bodyPosition.Parent then

				bodyPosition:Destroy()
			end

			setCharacterBool(
				"Vaulting",
				false
			)

			VaultActive = false
			VaultAnimPlaying = false
		end
	)
end

local function checkVaultTrigger()
	if not Character
		or not RootPart
		or not IsJumping
		or VaultActive
		or VaultCooldown
		or Character:FindFirstChild("VaultMontage")
		or VaultAnimPlaying then

		return false
	end

	if Character:GetAttribute("Aiming")
		or Character:GetAttribute("Crouching") then

		return false
	end

	return checkVaultGeometry()
end

-- // Core sprint loop

local function sprintLoop()

	if LoopRunning then
		return
	end

	LoopRunning = true

	SprintTicker = tick()

	print(
		"[SprintLoop] Started - W_Locked:",
		W_Locked
	)

	while Sprinting do

		if not Character
			or not Humanoid
			or not RootPart then

			break
		end

		-- =====================================================
		-- AIMING HAS ABSOLUTE PRIORITY
		-- =====================================================

		if isAiming() then

			print(
				"[SprintLoop] Stopped: Aiming"
			)

			Sprinting = false

			setSprintAttribute(false)

			-- Immediately force aiming speed.
			Humanoid.WalkSpeed =
				getAimingSpeed()

			break
		end

		-- =====================================================
		-- CLIMBING
		-- =====================================================

		if IsClimbing then

			print(
				"[SprintLoop] Stopped: Climbing"
			)

			break
		end

		-- =====================================================
		-- JUMP / FALL
		-- =====================================================

		if IsJumping then

			local fallDuration =
				tick() - fall_time

			if fallDuration >
				fall_duration_threshold then

				print(
					"[SprintLoop] Stopped: Falling for too long"
				)

				break
			end
		end

		-- =====================================================
		-- CROUCH
		-- =====================================================

		if isCrouching() then

			print(
				"[SprintLoop] Stopped: Crouching"
			)

			break
		end

		-- =====================================================
		-- INPUT
		-- =====================================================

		if W_Locked
			and not KeyStates.Forward then

			print(
				"[SprintLoop] Stopped: W_Locked but W not held"
			)

			break
		end

		local hasMovementInput =
			KeyStates.Forward
			or KeyStates.Backwards
			or KeyStates.Left
			or KeyStates.Right

		-- =====================================================
		-- SECOND AIM CHECK
		-- =====================================================
		--
		-- This check intentionally exists immediately before
		-- writing WalkSpeed. This closes the exact race where
		-- aiming can begin during the sprint ramp.

		if isAiming() then

			Sprinting = false

			setSprintAttribute(false)

			Humanoid.WalkSpeed =
				getAimingSpeed()

			break
		end

		local shouldSprint =
			(
				not isAiming()
				and W_Locked
				and KeyStates.Forward
			)
			or (
				not W_Locked
				and hasMovementInput
			)

		if shouldSprint then

			local elapsed =
				tick() - SprintTicker

			local t =
				math.clamp(
					elapsed / SprintRampTime,
					0,
					1
				)

			-- FINAL AIM CHECK BEFORE WALK SPEED WRITE
			if isAiming() then

				Sprinting = false

				setSprintAttribute(false)

				Humanoid.WalkSpeed =
					getAimingSpeed()

				break
			end

			local sprintSpeed =
				lerp(
					0,
					MaxSpeed - BaseSpeed,
					t
				)

			local sprintWalkSpeed =
				(BaseSpeed + sprintSpeed)
				* getOrderSpeedMultiplier()

			-- One last protection against an aiming state
			-- changing during this iteration.
			if isAiming() then

				Sprinting = false

				setSprintAttribute(false)

				Humanoid.WalkSpeed =
					getAimingSpeed()

				break
			end

			Humanoid.WalkSpeed =
				sprintWalkSpeed

			if t >= 0.8 then
				setSprintAttribute(true)
			end

		else

			if W_Locked then

				print(
					"[SprintLoop] Stopped: W_Locked and not pressing W"
				)

				break

			else

				if not hasMovementInput then

					print(
						"[SprintLoop] Stopped: No movement input at all"
					)

					break
				end
			end
		end

		-- =====================================================
		-- VELOCITY CHECKS
		-- =====================================================

		local forwardVel =
			getForwardVelocity()

		if forwardVel > 2 then

			print(
				"[SprintLoop] Stopped: Moving backwards too much"
			)

			break
		end

		local smoothedVel =
			getSmoothedVelocity()

		if smoothedVel <
			(Humanoid.WalkSpeed - 8) then

			print(
				"[SprintLoop] Stopped: Velocity too low (Hit a wall)"
			)

			break
		end

		task.wait(0.03)
	end

	LoopRunning = false

	-- =========================================================
	-- IMPORTANT
	-- =========================================================
	--
	-- If aiming caused the loop to terminate, resetSpeed()
	-- will explicitly select the aiming speed.

	resetSpeed()

	-- =========================================================
	-- AUTO REBUILD
	-- =========================================================

	if SprintKeyHeld and not Checked then

		task.defer(function()

			print(
				"[SprintLoop] Monitoring for Auto-Rebuild..."
			)

			while
				SprintKeyHeld
				and not Sprinting
				and not Checked
			do

				-- NEVER rebuild sprint while aiming.
				if isAiming() then
					task.wait(0.1)
					continue
				end

				if canStartSprint() then

					Checked = true

					local smoothedVel =
						getSmoothedVelocity()

					if smoothedVel >=
						(BaseSpeed - 3)
						or (
							not W_Locked
								and smoothedVel > 2
						) then

						print(
							"[SprintLoop] Auto-Rebuild conditions met. Restarting!"
						)

						tryStartSprint()

						break
					end
				end

				task.wait(0.1)
			end
		end)
	end
end

function tryStartSprint()

	-- Absolute protection against sprinting while aiming.
	if isAiming() then

		Sprinting = false

		if Humanoid then
			Humanoid.WalkSpeed =
				getAimingSpeed()
		end

		return
	end

	if not Sprinting
		and canStartSprint() then

		Sprinting = true

		task.spawn(
			sprintLoop
		)

		task.delay(
			0.5,
			function()

				Checked = false
			end
		)
	end
end

-- // Bind character connections

local function bindCharacterConnections()

	-- Disconnect previous connections.
	for _, conn in ipairs(characterConnections) do
		conn:Disconnect()
	end

	characterConnections = {}

	local function track(conn)
		table.insert(
			characterConnections,
			conn
		)
	end

	-- // Vault cooldown
	track(
		Humanoid.StateChanged:Connect(
			function(old, new)

				if new ==
					Enum.HumanoidStateType.Landed then

					VaultCooldown = false
				end
			end
		)
	)

	-- // Main state machine
	track(
		Humanoid.StateChanged:Connect(
			function(old, new)

				if new ==
					Enum.HumanoidStateType.Climbing then

					IsClimbing = true
					IsJumping = false

					LocalPlayer:SetAttribute(
						"Climbing",
						true
					)

					if Sprinting then

						print(
							"[StateChanged] Climbing started — stopping sprint"
						)

						Sprinting = false

						resetSpeed()
					end

				elseif new ==
					Enum.HumanoidStateType.Jumping then

					IsClimbing = false

					LocalPlayer:SetAttribute(
						"Climbing",
						nil
					)

					if Character:GetAttribute(
						"Crouching"
						) then

						setCharacterBool(
							"Crouching",
							false
						)
					end

					if Character:GetAttribute(
						"Aiming"
						) then

						return
					end

					LocalPlayer:SetAttribute(
						"Jumping",
						true
					)

					Humanoid:SetStateEnabled(
						Enum.HumanoidStateType.Jumping,
						false
					)

					IsJumping = true
					fall_time = tick()

					task.delay(
						1,
						function()

							if Humanoid then

								Humanoid:SetStateEnabled(
									Enum.HumanoidStateType.Jumping,
									true
								)
							end
						end
					)

				elseif new ==
					Enum.HumanoidStateType.Freefall then

					IsClimbing = false

					LocalPlayer:SetAttribute(
						"Climbing",
						false
					)

					IsJumping = true
					fall_time = tick()

				elseif new ==
					Enum.HumanoidStateType.Landed then

					IsClimbing = false

					LocalPlayer:SetAttribute(
						"Climbing",
						false
					)

					LocalPlayer:SetAttribute(
						"Jumping",
						nil
					)

					IsJumping = false
					fall_time = tick()

					print(
						"[StateChanged] Landed - fall_time reset to:",
						fall_time
					)

					if SprintKeyHeld
						and not isAiming() then

						tryStartSprint()
					end

				elseif new ==
					Enum.HumanoidStateType.Running
					or new ==
					Enum.HumanoidStateType.RunningNoPhysics then

					if IsClimbing then

						IsClimbing = false

						LocalPlayer:SetAttribute(
							"Climbing",
							false
						)

						print(
							"[StateChanged] Left climbing via Running state"
						)

						if SprintKeyHeld
							and not isAiming() then

							tryStartSprint()
						end
					end
				end
			end
		)
	)

	-- // Health jump disable
	track(
		Humanoid.HealthChanged:Connect(
			function()

				Humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Jumping,
					false
				)

				task.delay(
					1,
					function()

						if Humanoid then

							Humanoid:SetStateEnabled(
								Enum.HumanoidStateType.Jumping,
								true
							)
						end
					end
				)
			end
		)
	)

	-- // Aiming
	track(
		Character:GetAttributeChangedSignal(
			"Aiming"
		):Connect(
			function()

				local aiming =
					Character:GetAttribute(
						"Aiming"
					) == true

				if aiming then

					-- =================================================
					-- AIMING IMMEDIATELY KILLS SPRINT
					-- =================================================

					Sprinting = false
					LastSprintCancelTime = tick()

					setSprintAttribute(false)

					print(
						"[Aiming] Sprint cancelled"
					)

					-- Force the correct speed immediately.
					Humanoid.WalkSpeed =
						getAimingSpeed()

					-- Disable jumping.
					Humanoid:SetStateEnabled(
						Enum.HumanoidStateType.Jumping,
						false
					)

					-- Hold breath.
					if SprintKeyHeld
						and Humanoid.MoveDirection.Magnitude <= 0
						and (
							tick() - LastSprintCancelTime
						) >= AimSprintCooldown then

						setHoldBreathe(true)

					else

						setHoldBreathe(false)
					end

				else

					-- Restore jumping.
					Humanoid:SetStateEnabled(
						Enum.HumanoidStateType.Jumping,
						true
					)

					setHoldBreathe(false)

					-- Restore normal movement.
					applyRestrictedSpeed()

					-- Resume sprint only if appropriate.
					if SprintKeyHeld
						and (
							tick()
							- LastSprintCancelTime
						) >= AimSprintCooldown then

						tryStartSprint()
					end
				end
			end
		)
	)

	-- // Crouching
	track(
		Character:GetAttributeChangedSignal(
			"Crouching"
		):Connect(
			function()

				if Character:GetAttribute(
					"Crouching"
					) then

					Sprinting = false

					setSprintAttribute(false)
				end

				applyRestrictedSpeed()
			end
		)
	)

	-- // ADS movement exemption
	track(
		Character:GetAttributeChangedSignal(
			"ADSMovementExempt"
		):Connect(
			function()

				if Character:GetAttribute(
					"Aiming"
					) then

					applyRestrictedSpeed()
				end
			end
		)
	)

	-- // Order speed multiplier
	track(
		Character:GetAttributeChangedSignal(
			"OrderSpeedMultiplier"
		):Connect(
			function()

				if not Sprinting
					or isAiming() then

					applyRestrictedSpeed()
				end
			end
		)
	)

	-- // Hold breath force cancel
	track(
		Character:GetAttributeChangedSignal(
			"HoldBreathe"
		):Connect(
			function()

				local attributeState =
					Character:GetAttribute(
						"HoldBreathe"
					)

				if HoldingBreath
					and attributeState ~= true then

					HoldingBreath = false

					HoldBreathCooldownEnd =
						tick() + HoldBreathe_regen

					print(
						"[HoldBreath] Forcefully cancelled. Cooldown until:",
						HoldBreathCooldownEnd
					)
				end
			end
		)
	)
end

-- // Character binding

local function bindCharacter(char)

	Character = char

	Humanoid =
		char:WaitForChild(
			"Humanoid"
		)

	RootPart =
		char:WaitForChild(
			"HumanoidRootPart"
		)

	Animator =
		Humanoid:WaitForChild(
			"Animator"
		)

	-- Reset volatile state.
	IsJumping = false
	IsClimbing = false

	VaultActive = false
	VaultCooldown = false
	VaultAnimPlaying = false

	Sprinting = false
	SprintKeyHeld = false

	LoopRunning = false
	Checked = false

	HoldingBreath = false

	VelocityHistory = {}

	fall_time = tick()

	Humanoid.WalkSpeed =
		BaseSpeed
		* getOrderSpeedMultiplier()

	bindCharacterConnections()
end

-- // Vault input loop

local function setupVaultInput()

	RunService.RenderStepped:Connect(
		function()

			local holdingSpace =
				UserInputService:IsKeyDown(
					Enum.KeyCode.Space
				)

			local holdingGamepad =
				UserInputService:IsGamepadButtonDown(
					0,
					Enum.KeyCode.ButtonA
				)

			if holdingSpace
				or holdingGamepad then

				if checkVaultTrigger() then
					executeVault()
				end
			end
		end
	)
end

-- // Input

function module.start_module()

	bindCharacter(
		LocalPlayer.Character
			or LocalPlayer.CharacterAdded:Wait()
	)

	LocalPlayer.CharacterAdded:Connect(
		bindCharacter
	)

	setupVaultInput()

	if InputsBinded then
		return
	end

	InputsBinded = true

	-- // Movement input
	UserInputService.InputBegan:Connect(
		function(input, gameProcessed)

			if gameProcessed then
				return
			end

			if input.KeyCode ==
				Enum.KeyCode.W then

				KeyStates.Forward = true

				if SprintKeyHeld then
					tryStartSprint()
				end

			elseif input.KeyCode ==
				Enum.KeyCode.S then

				KeyStates.Backwards = true

				if SprintKeyHeld then
					tryStartSprint()
				end

			elseif input.KeyCode ==
				Enum.KeyCode.A then

				KeyStates.Left = true

				if SprintKeyHeld then
					tryStartSprint()
				end

			elseif input.KeyCode ==
				Enum.KeyCode.D then

				KeyStates.Right = true

				if SprintKeyHeld then
					tryStartSprint()
				end
			end
		end
	)

	UserInputService.InputEnded:Connect(
		function(input)

			if input.KeyCode ==
				Enum.KeyCode.W then

				KeyStates.Forward = false

			elseif input.KeyCode ==
				Enum.KeyCode.S then

				KeyStates.Backwards = false

			elseif input.KeyCode ==
				Enum.KeyCode.A then

				KeyStates.Left = false

			elseif input.KeyCode ==
				Enum.KeyCode.D then

				KeyStates.Right = false
			end
		end
	)

	-- // FreeLook
	LocalPlayer:GetAttributeChangedSignal(
		"FreeLook"
	):Connect(
		function()

			if not LocalPlayer:GetAttribute(
				"FreeLook"
				) then

				W_Locked = true

				print(
					"[Module] W_Locked set to true"
				)

			else

				W_Locked = false

				print(
					"[Module] W_Locked set to false"
				)
			end

			if SprintKeyHeld
				and not isAiming() then

				tryStartSprint()
			end
		end
	)

	-- // Sprint
	SettingsManager.HookInput(
		"Sprint",
		function(Key, IsPressed)

			print(
				"Sprint input triggered:",
				Key,
				IsPressed
			)

			if IsPressed then

				SprintKeyHeld = true

				-- This will refuse to start if aiming.
				tryStartSprint()

				if Character
					and Character:GetAttribute(
						"Aiming"
					)
						and Character.Humanoid.MoveDirection.Magnitude <= 0 then

					setHoldBreathe(true)

				else

					setHoldBreathe(false)
				end

			else

				SprintKeyHeld = false

				Sprinting = false

				resetSpeed()

				setHoldBreathe(false)
			end
		end
	)

	-- // Crouch
	SettingsManager.HookInput(
		"Crouch",
		function(Key, IsPressed)

			if not IsPressed then
				return
			end

			if Character:GetAttribute(
				"Crouching"
				) then

				setCharacterBool(
					"Crouching",
					false
				)

				if SprintKeyHeld
					and not isAiming() then

					tryStartSprint()
				end

			else

				setCharacterBool(
					"Crouching",
					true
				)

				resetSpeed()
			end
		end
	)

	-- =========================================================
	-- FINAL SPEED ENFORCER
	-- =========================================================
	--
	-- This is intentionally separate from sprintLoop.
	--
	-- If another part of the sprint system somehow writes a
	-- sprint WalkSpeed after the Aiming signal fires, this
	-- corrects it on the next render frame.
	--
	-- It ONLY runs while aiming, so it doesn't interfere with
	-- normal sprint acceleration.

	RunService:BindToRenderStep(
		"AimingMovementSpeed",
		Enum.RenderPriority.Character.Value + 1,
		function()

			if not Character
				or not Humanoid
				or Humanoid.Health <= 0 then

				return
			end

			if isAiming() then

				local targetSpeed =
					getAimingSpeed()

				if Humanoid.WalkSpeed ~= targetSpeed then

					Humanoid.WalkSpeed =
						targetSpeed
				end
			end
		end
	)
end

return module