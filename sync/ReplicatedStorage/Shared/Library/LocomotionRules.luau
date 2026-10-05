-- Pure state transitions, shared by the live controller and regression checks.
local Rules = {}
local function clamp(value, low, high) return math.max(low, math.min(high, value)) end
function Rules.New()
    return {ramp=0, holding=false, breathElapsed=0, recovery=0, latched=false, previousHeld=false, airborne=0}
end

function Rules.Step(state, input, dt)
    dt = math.max(0, dt)
    state.airborne = input.grounded and 0 or state.airborne + dt
    local unavailable = not input.alive or input.menu or input.blocked
    local rising = input.held and not state.previousHeld
    state.previousHeld = input.held
    if unavailable or input.aiming or input.crouching or input.climbing or input.vaulting or input.mounted then
        state.latched = false
    elseif input.toggle and rising then
        state.latched = not state.latched
    elseif not input.toggle then
        state.latched = false
    end
    local sprintRequested = input.toggle and state.latched or (not input.toggle and input.held)
    local sprint = sprintRequested and not unavailable and not input.aiming
        and not input.crouching and not input.climbing and not input.vaulting
        and not input.mounted and state.airborne < 0.35 and input.moving
        and (input.freeLook or input.forward)
    if sprint then
        state.ramp = state.ramp + dt
    else
        state.ramp = 0
    end
    local rampTime = input.rampTime or 2
    local alpha = 0
    if sprint then alpha = input.instant and 1 or (rampTime <= 0 and 1 or clamp(state.ramp / rampTime, 0, 1)) end
    local progress = alpha * alpha * (3 - 2 * alpha)
    state.recovery = math.max(0, state.recovery - dt)
    local focusAllowed = not unavailable and input.aiming and input.held
        and input.speed < 3 and not input.vaulting and not input.mounted
    local accuracyTime = input.accuracyTime or 0.35
    local inhaled, exhaled = false, false
    if state.holding then
        state.breathElapsed = state.breathElapsed + dt
        if (not focusAllowed or state.breathElapsed >= (input.breathDuration or 5.5))
            and state.breathElapsed >= accuracyTime then
            state.holding = false
            state.recovery = input.breathRecovery or 2.5
            exhaled = true
        end
    elseif focusAllowed and state.recovery <= 0 then
        state.holding = true
        state.breathElapsed = 0
        inhaled = true
    end
    if not input.alive then state.holding = false; state.latched = false end
    local speed = input.normalSpeed or 10
    if input.aiming then speed = input.aimSpeed or 5
    elseif sprint then speed = speed + ((input.sprintSpeed or 18) - speed) * progress end
    return {
        speed=speed, sprinting=sprint and progress >= 0.8, accelerating=sprint,
        sprintProgress=progress, holding=state.holding,
        focusProgress=state.holding and clamp(state.breathElapsed / math.max(accuracyTime, 0.001), 0, 1) or 0,
        inhaled=inhaled, exhaled=exhaled,
    }
end
return Rules
