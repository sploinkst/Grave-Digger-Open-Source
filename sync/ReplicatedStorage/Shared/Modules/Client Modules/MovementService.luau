local module = {}

-- // Debug (set to false to silence all [Movement] prints)
local DEBUG = true

local function dbg(...)
	if DEBUG then
		print("[Movement]", ...)
	end
end

-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationResolver = require(ReplicatedStorage.Shared.Library.Classes.GunClasses.AnimationResolver)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SettingsManager = require(ReplicatedStorage.Shared.Modules["Client Modules"].SettingsManager)

-- // Player
local LocalPlayer = Players.LocalPlayer
local Locomotion = require(script.Parent.LocomotionService)

-- // Dynamic character refs
local Character = nil
local Humanoid: Humanoid? = nil
local RootPart = nil
local Animator = nil
local InjuredLeftTrack: AnimationTrack? = nil
local InjuredRightTrack: AnimationTrack? = nil

-- // Vault config
local VAULT_RAYCAST_RANGE_1 = 2 -- wall ahead
local VAULT_RAYCAST_RANGE_2 = 3.5 -- headroom
local VAULT_RAYCAST_RANGE_3 = 3 -- ledge top clear
local VAULT_RAYCAST_RANGE_4 = 3 -- space above ledge clear

local VAULT_TARGET_UP = 5
local VAULT_TARGET_FORWARD = 5
local VAULT_DURATION = 0.4
local VAULT_COOLDOWN_FALLBACK = 1.5 -- cooldown clears even if Landed never fires

local VAULT_BODY_POSITION_MAXFORCE = Vector3.new(200000, 200000, 200000)
local VAULT_BODY_POSITION_P = 2000
local VAULT_BODY_POSITION_D = 500

local JUMP_COOLDOWN = 1

-- // State
local Sprinting = false
local IsJumping = false
local IsClimbing = false
local InputsBinded = false
local jumpCooldown = false

local VaultActive = false
local VaultCooldown = false
local VaultAnimPlaying = false

local characterConnections = {}

-- Attributes that should make Locomotion recalculate speed.
local SPEED_ATTRIBUTES = {
	"DebuffMovementMultiplier",
	"BurnMovementMultiplier",
	"TabletMovementMultiplier",
	"TakingTablets",
	"BloodlustWalkMultiplier",
	"MoraleSprintMultiplier",
	"OrderSprintSpeedMultiplier",
	"ChemicalSprintMultiplier",
	"ChemicalMovementPenaltyMultiplier",
}

local MOVE_KEYS = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
}

-- // Animation helpers

-- Accepts an Animation, or a container (Folder/Model) holding one.
local function resolveAnimation(instance: Instance?): Animation?
	if not instance then
		return nil
	end
	if instance:IsA("Animation") then
		return instance
	end
	return instance:FindFirstChildWhichIsA("Animation", true) or AnimationResolver.Resolve(instance)
end

local function loadTrack(animator: Animator?, instance: Instance?, label: string): AnimationTrack?
	if not animator then
		warn("[Movement] No Animator when loading", label)
		return nil
	end

	local animation = resolveAnimation(instance)
	if not animation then
		warn("[Movement] No Animation found for", label, instance and instance:GetFullName() or "(instance missing)")
		return nil
	end

	local ok, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if not ok then
		warn("[Movement] LoadAnimation failed for", label, result)
		return nil
	end

	dbg("Loaded animation:", label, "(" .. animation.ClassName .. ")", animation.AnimationId)
	return result
end

-- Safe lookup: a missing path no longer errors the whole module.
local function findMantleAnimation(): Instance?
	local shared = ReplicatedStorage:WaitForChild("Shared", 10)
	local node = shared
	for _, name in { "Assets", "Animations", "Character", "Jumping", "Mantle" } do
		node = node and node:FindFirstChild(name)
	end
	if not node then
		warn("[Movement] Mantle animation not found at Shared.Assets.Animations.Character.Jumping.Mantle")
	else
		dbg("Mantle found:", node:GetFullName(), node.ClassName)
	end
	return node
end

local mantleAnim = findMantleAnimation()

-- // Helpers

local function isAiming()
	return Character ~= nil and Character:GetAttribute("Aiming") == true
end

local function sprintHeld()
	return Locomotion.IsSprintHeld()
end

local function refreshLocomotion()
	local result = Locomotion.Update(0)
	Sprinting = result and result.accelerating or false
end

local function setCharacterBool(name: string, state: boolean)
	if not Character then
		return
	end

	local data = Character:FindFirstChild("CharacterData")
	local stateFolder = data and data:FindFirstChild("State")
	local value = stateFolder and stateFolder:FindFirstChild(name)

	if value and value:IsA("BoolValue") then
		value.Value = state
	end

	Character:SetAttribute(name, if state then true else nil)
end

-- Single source of truth for whether the Jumping state is allowed.
local function applyJumpEnabled()
	if not Humanoid or not Character then
		return
	end

	local blocked = jumpCooldown
		or isAiming()
		or Character:GetAttribute("charging") == true
		or Character:GetAttribute("JumpBlocked") == true
		or Character:GetAttribute("BulwarkReloading") == true

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not blocked)
end

local function startJumpCooldown()
	local humanoid = Humanoid
	jumpCooldown = true
	applyJumpEnabled()

	task.delay(JUMP_COOLDOWN, function()
		if Humanoid ~= humanoid then
			return -- character changed
		end
		jumpCooldown = false
		applyJumpEnabled()
	end)
end

-- // Injured pose

local function updateInjuredPose()
	if not Humanoid or not Character then
		return
	end

	local injured = Humanoid.Health > 0
		and Humanoid.Health < Humanoid.MaxHealth
		and Character:GetAttribute("Aiming") ~= true

	local shoulderLeft = LocalPlayer:GetAttribute("Current_Shoulder") == "Left"
	local activeTrack = if shoulderLeft then InjuredRightTrack else InjuredLeftTrack
	local otherTrack = if shoulderLeft then InjuredLeftTrack else InjuredRightTrack

	if injured and activeTrack then
		if otherTrack and otherTrack.IsPlaying then
			otherTrack:Stop(0.15)
		end
		if not activeTrack.IsPlaying then
			-- Play(fadeTime, weight, speed): speed is 0.5 here
			activeTrack:Play(0.15, 1, 0.5)
		end
	else
		if InjuredLeftTrack and InjuredLeftTrack.IsPlaying then
			InjuredLeftTrack:Stop(0.15)
		end
		if InjuredRightTrack and InjuredRightTrack.IsPlaying then
			InjuredRightTrack:Stop(0.15)
		end
	end
end

-- // Vault

-- True only if the ray hits something solid that isn't a character.
local function blockedAt(origin: Vector3, direction: Vector3, params: RaycastParams): boolean
	local result = workspace:Raycast(origin, direction, params)
	if not result or not result.Instance.CanCollide then
		return false
	end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	return not (model and model:FindFirstChildOfClass("Humanoid"))
end

local function checkVaultGeometry(): (boolean, string)
	if not RootPart then
		return false, "no root part"
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { Character }
	params.IgnoreWater = true

	local position = RootPart.Position
	local look = RootPart.CFrame.LookVector

	local wallAhead = blockedAt(position, look * VAULT_RAYCAST_RANGE_1, params)
	local headroom = not blockedAt(position, RootPart.CFrame.UpVector * VAULT_RAYCAST_RANGE_2, params)
	local ledgeClear = not blockedAt(position + Vector3.new(0, 2.5, 0), look * VAULT_RAYCAST_RANGE_3, params)
	local aboveClear = not blockedAt(position + Vector3.new(0, 6, 0), look * VAULT_RAYCAST_RANGE_4, params)

	local summary = string.format(
		"wallAhead=%s headroom=%s ledgeClear=%s aboveClear=%s",
		tostring(wallAhead),
		tostring(headroom),
		tostring(ledgeClear),
		tostring(aboveClear)
	)

	return wallAhead and headroom and ledgeClear and aboveClear, summary
end

local function playMantle()
	local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
	local track = loadTrack(animator, mantleAnim, "Mantle")
	if not track then
		return
	end

	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.05)
	VaultAnimPlaying = true
end

local function executeVault()
	if not Character or not RootPart or not Humanoid then
		return
	end

	dbg("VAULT executing")

	VaultActive = true
	VaultCooldown = true
	setCharacterBool("Vaulting", true)

	playMantle()

	local targetPosition = RootPart.Position
		+ Vector3.new(0, VAULT_TARGET_UP, 0)
		+ RootPart.CFrame.LookVector * VAULT_TARGET_FORWARD

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "VaultPosition"
	bodyPosition.MaxForce = VAULT_BODY_POSITION_MAXFORCE
	bodyPosition.P = VAULT_BODY_POSITION_P
	bodyPosition.D = VAULT_BODY_POSITION_D
	bodyPosition.Position = targetPosition
	bodyPosition.Parent = RootPart

	task.delay(VAULT_DURATION, function()
		if bodyPosition.Parent then
			bodyPosition:Destroy()
		end

		setCharacterBool("Vaulting", false)
		VaultActive = false
		VaultAnimPlaying = false
		dbg("VAULT finished")
	end)

	-- Safety net: don't stay locked out if Landed never fires.
	task.delay(VAULT_COOLDOWN_FALLBACK, function()
		VaultCooldown = false
	end)
end

-- Returns (canVault, reason)
local function checkVaultTrigger(): (boolean, string)
	if not Character or not RootPart then
		return false, "no character"
	end
	if not IsJumping then
		return false, "not jumping/falling (IsJumping=false)"
	end
	if VaultActive then
		return false, "vault active"
	end
	if VaultCooldown then
		return false, "vault cooldown"
	end
	if VaultAnimPlaying then
		return false, "vault anim playing"
	end
	if Character:FindFirstChild("VaultMontage") then
		return false, "VaultMontage present"
	end
	if Character:GetAttribute("charging") then
		return false, "charging"
	end
	if Character:GetAttribute("Aiming") then
		return false, "aiming"
	end
	if Character:GetAttribute("Crouching") then
		return false, "crouching"
	end

	return checkVaultGeometry()
end

-- // Character connections

local function bindCharacterConnections()
	for _, connection in characterConnections do
		connection:Disconnect()
	end
	characterConnections = {}

	local function track(connection)
		table.insert(characterConnections, connection)
	end

	local function stopSprint()
		Sprinting = false
		refreshLocomotion()
	end

	-- Jump blocking
	local function onJumpBlockChanged()
		applyJumpEnabled()
		if Character:GetAttribute("JumpBlocked") == true or Character:GetAttribute("BulwarkReloading") == true then
			stopSprint()
		end
	end
	track(Character:GetAttributeChangedSignal("JumpBlocked"):Connect(onJumpBlockChanged))
	track(Character:GetAttributeChangedSignal("charging"):Connect(onJumpBlockChanged))
	track(Character:GetAttributeChangedSignal("BulwarkReloading"):Connect(onJumpBlockChanged))
	applyJumpEnabled()

	-- Anything that changes movement speed
	for _, attribute in SPEED_ATTRIBUTES do
		track(Character:GetAttributeChangedSignal(attribute):Connect(refreshLocomotion))
	end

	track(Character:GetAttributeChangedSignal("SprintBlocked"):Connect(function()
		if Character:GetAttribute("SprintBlocked") then
			stopSprint()
		end
	end))

	-- Landing clears the vault cooldown
	track(Humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			VaultCooldown = false
		end
	end))

	-- Main state machine
	track(Humanoid.StateChanged:Connect(function(_, new)
		dbg("State ->", new.Name)

		if new == Enum.HumanoidStateType.Climbing then
			IsClimbing = true
			IsJumping = false
			LocalPlayer:SetAttribute("Climbing", true)

			if Sprinting then
				dbg("Climbing started, stopping sprint")
				stopSprint()
			end
		elseif new == Enum.HumanoidStateType.Jumping then
			IsClimbing = false
			LocalPlayer:SetAttribute("Climbing", nil)

			if Character:GetAttribute("Crouching") then
				setCharacterBool("Crouching", false)
			end

			if Character:GetAttribute("Aiming") then
				return
			end

			LocalPlayer:SetAttribute("Jumping", true)
			IsJumping = true
			startJumpCooldown()
		elseif new == Enum.HumanoidStateType.Freefall then
			IsClimbing = false
			LocalPlayer:SetAttribute("Climbing", false)
			IsJumping = true
		elseif new == Enum.HumanoidStateType.Landed then
			IsClimbing = false
			IsJumping = false
			LocalPlayer:SetAttribute("Climbing", false)
			LocalPlayer:SetAttribute("Jumping", nil)

			if sprintHeld() and not isAiming() then
				refreshLocomotion()
			end
		elseif new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.RunningNoPhysics then
			if IsClimbing then
				IsClimbing = false
				LocalPlayer:SetAttribute("Climbing", false)
				dbg("Left climbing via Running state")

				if sprintHeld() and not isAiming() then
					refreshLocomotion()
				end
			end
		end
	end))

	-- Health only updates the injured pose (it no longer toggles jumping)
	track(Humanoid.HealthChanged:Connect(updateInjuredPose))

	-- ADS transitions never restart sprint or a breath timer.
	track(Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		updateInjuredPose()
		applyJumpEnabled()
		refreshLocomotion()
	end))

	-- Crouching
	track(Character:GetAttributeChangedSignal("Crouching"):Connect(function()
		local crouching = Character:GetAttribute("Crouching") == true
		dbg("Crouching attribute changed ->", crouching)

		if crouching then
			Sprinting = false
		end
		refreshLocomotion()
	end))

	-- ADS movement exemption
	track(Character:GetAttributeChangedSignal("ADSMovementExempt"):Connect(function()
		if isAiming() then
			refreshLocomotion()
		end
	end))

	-- Order speed multiplier
	track(Character:GetAttributeChangedSignal("OrderSpeedMultiplier"):Connect(function()
		if not Sprinting or isAiming() then
			refreshLocomotion()
		end
	end))
end

-- // Character binding

local function bindCharacter(char)
	dbg("bindCharacter start:", char.Name)

	if InjuredLeftTrack then
		InjuredLeftTrack:Stop(0)
		InjuredLeftTrack:Destroy()
	end
	if InjuredRightTrack then
		InjuredRightTrack:Stop(0)
		InjuredRightTrack:Destroy()
	end
	InjuredLeftTrack = nil
	InjuredRightTrack = nil

	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
	Animator = Humanoid:FindFirstChildOfClass("Animator") or Humanoid:WaitForChild("Animator", 5)

	if not Animator then
		warn("[Movement] Animator not found; creating one")
		Animator = Instance.new("Animator")
		Animator.Parent = Humanoid
	end

	local animations = ReplicatedStorage.Shared.Assets:FindFirstChild("Animations")
	local sharedAnimations = animations and animations:FindFirstChild("Shared")
	local legacyMovement = ReplicatedStorage:FindFirstChild("MovementAnimations")
	local function injuryAnimation(name)
		return (sharedAnimations and sharedAnimations:FindFirstChild(name))
			or (legacyMovement and legacyMovement:FindFirstChild(name))
	end
	InjuredLeftTrack = loadTrack(Animator, injuryAnimation("injured_left"), "injured_left")
	InjuredRightTrack = loadTrack(Animator, injuryAnimation("injured_right"), "injured_right")

	for _, injuredTrack in { InjuredLeftTrack, InjuredRightTrack } do
		if injuredTrack then
			injuredTrack.Priority = Enum.AnimationPriority.Action2
			injuredTrack.Looped = true
		end
	end

	-- Reset volatile state
	IsJumping = false
	IsClimbing = false
	jumpCooldown = false
	VaultActive = false
	VaultCooldown = false
	VaultAnimPlaying = false
	Sprinting = false

	refreshLocomotion()
	bindCharacterConnections()
	updateInjuredPose()

	dbg("bindCharacter done")
end

-- // Vault input loop

local function setupVaultInput()
	local lastDebugTime = 0

	RunService.RenderStepped:Connect(function()
		local holdingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)
		local holdingGamepad = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)

		if not (holdingSpace or holdingGamepad) then
			return
		end

		local canVault, reason = checkVaultTrigger()

		-- Throttled so holding jump doesn't flood the output
		if DEBUG and os.clock() - lastDebugTime > 0.5 then
			lastDebugTime = os.clock()
			dbg("Vault check:", canVault, "|", reason)
		end

		if canVault then
			executeVault()
		end
	end)
end

-- // Input hooks

local function hookMovementInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if MOVE_KEYS[input.KeyCode] and sprintHeld() then
			refreshLocomotion()
		end
	end)

	LocalPlayer:GetAttributeChangedSignal("FreeLook"):Connect(function()
		dbg("FreeLook ->", LocalPlayer:GetAttribute("FreeLook"))

		if sprintHeld() and not isAiming() then
			refreshLocomotion()
		end
	end)
end

local function hookCrouchInput()
	local ok, err = pcall(function()
		SettingsManager.HookInput("Crouch", function(_, isPressed)
			if not isPressed then
				return
			end

			dbg("Crouch key pressed")

			if not Character then
				dbg("Crouch ignored: no character yet")
				return
			end

			if Character:GetAttribute("Crouching") then
				setCharacterBool("Crouching", false)
				dbg("Crouch OFF")

				if sprintHeld() and not isAiming() then
					refreshLocomotion()
				end
			else
				setCharacterBool("Crouching", true)
				dbg("Crouch ON")
				refreshLocomotion()
			end
		end)
	end)

	if ok then
		dbg("Crouch input hooked")
	else
		warn("[Movement] SettingsManager.HookInput('Crouch') failed:", err)
	end
end

-- // Entry point

function module.start_module()
	if InputsBinded then
		return
	end
	InputsBinded = true

	dbg("start_module")

	Locomotion.start_module()

	-- Hook inputs first so a character-binding problem can't prevent them.
	hookCrouchInput()
	hookMovementInput()
	setupVaultInput()

	LocalPlayer:GetAttributeChangedSignal("Current_Shoulder"):Connect(updateInjuredPose)
	LocalPlayer.CharacterAdded:Connect(bindCharacter)

	if LocalPlayer.Character then
		bindCharacter(LocalPlayer.Character)
	end

	dbg("inputs hooked")
end

return module