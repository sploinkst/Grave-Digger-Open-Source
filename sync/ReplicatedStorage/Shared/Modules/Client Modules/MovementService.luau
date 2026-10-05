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
local Locomotion = require(script.Parent.LocomotionService)

-- // Dynamic character refs
local Character = nil
local Humanoid: Humanoid = nil
local RootPart = nil
local Animator = nil
local InjuredLeftTrack: AnimationTrack? = nil
local InjuredRightTrack: AnimationTrack? = nil

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




local IsJumping = false
local IsClimbing = false

local fall_time = tick()
local fall_threshold = 0.35
local fall_duration_threshold = 0.3


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
local updateSprint

local function updateInjuredPose()
	if not Humanoid then return end
	local injured = Humanoid.Health > 0 and Humanoid.Health < 100
		and Character ~= nil and Character:GetAttribute("Aiming") ~= true
	local leftTrack = if LocalPlayer:GetAttribute("Current_Shoulder") == "Left"
		then InjuredRightTrack else InjuredLeftTrack
	local otherTrack = if leftTrack == InjuredLeftTrack then InjuredRightTrack else InjuredLeftTrack
	if injured and leftTrack then
		if otherTrack and otherTrack.IsPlaying then otherTrack:Stop(0.15) end
		if not leftTrack.IsPlaying then leftTrack:Play(0.15, 1, 0.5) end
	else
		if InjuredLeftTrack and InjuredLeftTrack.IsPlaying then InjuredLeftTrack:Stop(0.15) end
		if InjuredRightTrack and InjuredRightTrack.IsPlaying then InjuredRightTrack:Stop(0.15) end
	end
end

-- // Helpers

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function isAiming()
	return Character
		and Character:GetAttribute("Aiming") == true
end

local function isCrouching()
	return Character
		and Character:GetAttribute("Crouching") == true
end

local function setSprintAttribute(_state: boolean)
    local result = Locomotion.Update(0)
    Sprinting = result and result.accelerating or false
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

local function refreshSprintInput()
    SprintKeyHeld = Locomotion.IsSprintHeld()
end

local function refreshLocomotion()
    local result = Locomotion.Update(0)
    Sprinting = result and result.accelerating or false
    refreshSprintInput()
end
local resetSpeed = refreshLocomotion
local applyRestrictedSpeed = refreshLocomotion
local enforceMovementSpeed = refreshLocomotion

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

-- Vault/jump callbacks request a refresh; LocomotionService owns speed.
updateSprint = refreshLocomotion
tryStartSprint = refreshLocomotion

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

	local function updateJumpEnabled()
		local blocked = Character:GetAttribute("JumpBlocked") == true or Character:GetAttribute("BulwarkReloading") == true
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not blocked)
		if blocked then
			Sprinting = false
			resetSpeed()
		end
	end
	track(Character:GetAttributeChangedSignal("JumpBlocked"):Connect(updateJumpEnabled))
	track(Character:GetAttributeChangedSignal("BulwarkReloading"):Connect(updateJumpEnabled))
	track(Character:GetAttributeChangedSignal("DebuffMovementMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("BurnMovementMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("TabletMovementMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("TakingTablets"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("BloodlustWalkMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("MoraleSprintMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("OrderSprintSpeedMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("ChemicalSprintMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("ChemicalMovementPenaltyMultiplier"):Connect(resetSpeed))
	track(Character:GetAttributeChangedSignal("SprintBlocked"):Connect(function()
		if Character:GetAttribute("SprintBlocked") then
			Sprinting = false
			resetSpeed()
		end
	end))
	updateJumpEnabled()

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
									Character:GetAttribute("JumpBlocked") ~= true and Character:GetAttribute("BulwarkReloading") ~= true
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
				updateInjuredPose()

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

    -- ADS transitions never restart sprint or a breath timer.
    track(Character:GetAttributeChangedSignal("Aiming"):Connect(function()
        updateInjuredPose()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,
            not isAiming() and Character:GetAttribute("JumpBlocked") ~= true and Character:GetAttribute("BulwarkReloading") ~= true)
        refreshLocomotion()
    end))

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


end

-- // Character binding

local function bindCharacter(char)
	if InjuredLeftTrack then InjuredLeftTrack:Stop(0); InjuredLeftTrack:Destroy() end
	if InjuredRightTrack then InjuredRightTrack:Stop(0); InjuredRightTrack:Destroy() end
	InjuredLeftTrack = nil
	InjuredRightTrack = nil

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

	local movementAnimations = ReplicatedStorage:FindFirstChild("MovementAnimations")
	local injuredLeft = movementAnimations and movementAnimations:FindFirstChild("injured_left")
	local injuredRight = movementAnimations and movementAnimations:FindFirstChild("injured_right")
	InjuredLeftTrack = injuredLeft and Animator:LoadAnimation(injuredLeft) or nil
	InjuredRightTrack = injuredRight and Animator:LoadAnimation(injuredRight) or nil
	for _, track in { InjuredLeftTrack, InjuredRightTrack } do
		if track then
			track.Priority = Enum.AnimationPriority.Action2
			track.Looped = true
		end
	end

	-- Reset volatile state.
	IsJumping = false
	IsClimbing = false

	VaultActive = false
	VaultCooldown = false
	VaultAnimPlaying = false

	Sprinting = false
	SprintKeyHeld = false

	W_Locked = LocalPlayer:GetAttribute("FreeLook") ~= true
	for key in KeyStates do KeyStates[key] = false end


	fall_time = tick()

	refreshLocomotion()

	bindCharacterConnections()
	updateInjuredPose()
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
					Enum.UserInputType.Gamepad1,
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
	Locomotion.start_module()

	bindCharacter(
		LocalPlayer.Character
			or LocalPlayer.CharacterAdded:Wait()
	)

	LocalPlayer.CharacterAdded:Connect(
		bindCharacter
	)
	LocalPlayer:GetAttributeChangedSignal("Current_Shoulder"):Connect(updateInjuredPose)

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


end

return module
