local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Rules = require(Shared.Library.LocomotionRules)
local Voice = require(Shared.Library.CharacterVoice)
local player = Players.LocalPlayer
local Service = {}
local started = false
local character, state = nil, Rules.New()
local breathStartedAt = nil
local lastResult
local keys = {}
for _, key in Enum.KeyCode:GetEnumItems() do keys[key.Name] = key end

local function setting(name)
    local data = player:FindFirstChild("PlayerData")
    local settings = data and data:FindFirstChild("Settings Data")
    local entry = settings and settings:FindFirstChild(name, true)
    local value = entry and entry:FindFirstChild("Current")
    return value and value.Value
end

local function heldInput()
    local data = player:FindFirstChild("PlayerData")
    local settings = data and data:FindFirstChild("Settings Data")
    local inputs = settings and settings:FindFirstChild("Inputs")
    local binds = inputs and inputs:FindFirstChild("Binds")
    local sprint = binds and binds:FindFirstChild("Sprint")
    local current = sprint and sprint:FindFirstChild("Current")
    local key = keys[current and current.Value or "LeftShift"]
    local keyboard = key and key.Name:sub(1,6) ~= "Button" and key.Name:sub(1,4) ~= "DPad" and UIS:IsKeyDown(key) or false
    local gamepadHeld = false
    for _, gamepad in UIS:GetConnectedGamepads() do
        if UIS:IsGamepadButtonDown(gamepad, Enum.KeyCode.ButtonL3) then gamepadHeld = true end
        if key and (key.Name:sub(1,6) == "Button" or key.Name:sub(1,4) == "DPad") and UIS:IsGamepadButtonDown(gamepad,key) then gamepadHeld = true end
    end
    return keyboard or gamepadHeld, gamepadHeld
end

local function flag(name, value)
    if character:GetAttribute(name) ~= (value and true or nil) then character:SetAttribute(name, value and true or nil) end
    local data = character:FindFirstChild("CharacterData")
    local folder = data and data:FindFirstChild("State")
    local object = folder and folder:FindFirstChild(name)
    if object and object:IsA("BoolValue") and object.Value ~= value then object.Value = value end
end

local function multiplier(name) return character:GetAttribute(name) or 1 end

function Service.Update(dt)
    if character ~= player.Character then
        character, state = player.Character, Rules.New()
        breathStartedAt, lastResult = nil, nil
    end
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    local held, gamepadHeld = heldInput()
    local menu = player:GetAttribute("MenuOpen") == true or player:GetAttribute("RebindingInput") == true or UIS:GetFocusedTextBox() ~= nil
    local blocked = character:GetAttribute("BulwarkReloading") == true
    for _, name in {"SprintBlocked", "ActionBlocked", "CombatStunned", "TakingTablets", "StimulantSelecting", "OfficerOrderSelecting"} do
        if character:GetAttribute(name) then blocked = true; break end
    end
    local aiming = character:GetAttribute("Aiming") == true
    local crouching = character:GetAttribute("Crouching") == true
    local wounds = character:FindFirstChild("CharacterData") and character.CharacterData:FindFirstChild("Wounds")
    local injured = humanoid.Health < 100 or (wounds and #wounds:GetChildren() > 0)
    local walkMultiplier = multiplier("OrderSpeedMultiplier") * multiplier("MovementSpeedMultiplier")
        * multiplier("DebuffMovementMultiplier") * multiplier("BurnMovementMultiplier") * multiplier("TabletMovementMultiplier")
    if not injured then walkMultiplier *= multiplier("BloodlustWalkMultiplier") end
    local sprintMultiplier = multiplier("SprintSpeedMultiplier") * multiplier("ChemicalSprintMultiplier")
    if not injured then sprintMultiplier *= multiplier("OrderSprintSpeedMultiplier") * multiplier("MoraleSprintMultiplier") * multiplier("BloodlustSprintMultiplier") end
    local penalty = character:GetAttribute("FocusOrder") and 0.65 or 0.5
    penalty = 1 - (1-penalty) * multiplier("ChemicalMovementPenaltyMultiplier")
    local aimSpeed = 10 * walkMultiplier * (character:GetAttribute("ADSMovementExempt") and 1 or penalty)
    local humanoidState = humanoid:GetState()
    local result = Rules.Step(state, {
        held=held, toggle=setting("ToggleSprint") == true or UIS:GetLastInputType().Name:find("Gamepad") ~= nil,
        alive=humanoid.Health > 0, menu=menu, blocked=blocked,
        aiming=aiming, crouching=crouching, climbing=humanoidState == Enum.HumanoidStateType.Climbing,
        vaulting=player:GetAttribute("Vaulting") == true or character:GetAttribute("Vaulting") == true,
        mounted=player:GetAttribute("MountedWeapon") ~= nil and player:GetAttribute("MountedWeapon") ~= false,
        grounded=humanoid.FloorMaterial ~= Enum.Material.Air,
        moving=humanoid.MoveDirection.Magnitude > 0.05,
        forward=humanoid.MoveDirection:Dot(root.CFrame.LookVector) > 0.25,
        freeLook=player:GetAttribute("FreeLook") == true,
        speed=root.AssemblyLinearVelocity.Magnitude,
        normalSpeed=10 * walkMultiplier * (crouching and 0.5 or 1), aimSpeed=aimSpeed,
        sprintSpeed=18 * walkMultiplier * sprintMultiplier,
        rampTime=2 * multiplier("SprintRampMultiplier") * multiplier("OrderSprintRampMultiplier"),
        instant=character:GetAttribute("InstantSprintAcceleration") == true,
        accuracyTime=character:GetAttribute("HoldBreathAccuracyTime") or 0.35,
        breathDuration=character:GetAttribute("HoldBreathDuration") or 5.5,
        breathRecovery=character:GetAttribute("HoldBreathRecovery") or 2.5,
    }, dt or 0)
    -- Aiming and surgery keep their gameplay restrictions; a mounted gun or
    -- vault owns its own movement until the action ends.
    local mounted = player:GetAttribute("MountedWeapon")
    local vaulting = player:GetAttribute("Vaulting") or character:GetAttribute("Vaulting")
    if humanoid.Health > 0 and not mounted and not vaulting then
        local speed = (character:GetAttribute("ActionBlocked") or character:GetAttribute("BulwarkFiring")) and 0 or result.speed
        if humanoid.WalkSpeed ~= speed then humanoid.WalkSpeed = speed end
    end
    flag("Sprinting", result.sprinting)
    player:SetAttribute("Sprinting", result.sprinting and true or nil)
    character:SetAttribute("SprintProgress", result.sprintProgress)
    if result.inhaled then breathStartedAt = os.clock() end
    if not result.holding then breathStartedAt = nil end
    character:SetAttribute("HoldBreathStartedAt", breathStartedAt)
    character:SetAttribute("HoldBreathAccuracyTime", character:GetAttribute("HoldBreathAccuracyTime") or 0.35)
    flag("HoldBreathe", result.holding)
    character:SetAttribute("SteadyAimProgress", result.focusProgress)
    if result.inhaled then Voice.Play(character,"inhale") elseif result.exhaled and humanoid.Health > 0 then Voice.Play(character,"exhale") end
    local gui = player:FindFirstChildOfClass("PlayerGui")
    local aimingGui = gui and gui:FindFirstChild("Aiming")
    local icon = aimingGui and aimingGui:FindFirstChild("hold_breath")
    if icon and icon:IsA("ImageLabel") then icon.ImageTransparency = 1-result.focusProgress end
    local main = gui and gui:FindFirstChild("main")
    local core = main and main:FindFirstChild("core_game")
    local oldIcon = core and core:FindFirstChild("holdbreath")
    if oldIcon and oldIcon:IsA("ImageLabel") then oldIcon.ImageTransparency = 1-result.focusProgress end
    local checkers = _G.core_checkers
    if checkers then
        checkers.sprinting = result.sprinting
        checkers.holding_breath = result.holding
        checkers.hold_breathaccuracy = character:GetAttribute("HoldBreathAccuracyTime")
        checkers.hold_breathtime = result.holding and tick()-state.breathElapsed or tick()-((character:GetAttribute("HoldBreathRecovery") or 2.5)-state.recovery)
    end
    lastResult = result
    return result
end

function Service.IsSprintHeld()
    local held = heldInput()
    return held and not player:GetAttribute("MenuOpen") and UIS:GetFocusedTextBox() == nil
end

function Service.start_module()
    if started then return end
    started = true
    RunService:UnbindFromRenderStep("AimingMovementSpeed")
    RunService:UnbindFromRenderStep("SteadyAimFocus")
    RunService:BindToRenderStep("LocomotionUpdate", Enum.RenderPriority.Character.Value + 2, Service.Update)
end
return Service
