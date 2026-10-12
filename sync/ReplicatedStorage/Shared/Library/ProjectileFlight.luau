-- FastCast owns all flight and collision. Callers own impact effects and damage.
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local FastCast = require(RS.Shared.Library.Externals.FastCast)
local Flight = {}
local caster = FastCast.new()
local flights = {}

local function facing(position, velocity)
	return velocity.Magnitude > 0.001 and CFrame.lookAt(position, position + velocity) or CFrame.new(position)
end

caster.LengthChanged:Connect(function(cast, origin, direction, distance, velocity)
	local state = flights[cast]
	if not state or state.hit or not state.visual.Parent then return end
	state.visual:PivotTo(facing(origin + direction * distance, velocity)
		* CFrame.Angles(cast.StateInfo.TotalRuntime * state.spin, 0, 0))
end)

caster.RayHit:Connect(function(cast, hit, velocity)
	local state = flights[cast]
	if not state or state.hit or not state.visual.Parent then return end
	state.hit = true
	state.visual:PivotTo(facing(hit.Position, velocity))
	local ok, err = pcall(state.onImpact, hit, state.visual, velocity, cast)
	if not ok then warn("[ProjectileFlight] Impact failed: " .. tostring(err)) end
	if not state.retain or not ok then state.visual:Destroy() end
end)

caster.CastTerminating:Connect(function(cast)
	local state = flights[cast]
	if not state then return end
	flights[cast] = nil
	state.destroying:Disconnect()
	if not state.hit then state.visual:Destroy() end
end)

function Flight.Launch(character, source, direction, speed, onImpact, options)
	options = options or {}
	local head = character and character:FindFirstChild("Head")
	if not head or not source or not (source:IsA("Model") or source:IsA("BasePart")) then return false end
	local visual = source:Clone()
	local parts = visual:GetDescendants()
	if visual:IsA("BasePart") then table.insert(parts, visual) end
	for _, part in parts do
		if part:IsA("BasePart") then
			part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		elseif part:IsA("BaseScript") or part:IsA("JointInstance") or part:IsA("WeldConstraint")
			or part:IsA("BodyMover") or part:IsA("Constraint") then part:Destroy() end
	end
	local origin = options.origin or head.Position
	local velocity = options.velocity or direction * speed
	visual:PivotTo(facing(origin, velocity))
	visual.Parent = workspace
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, visual}
	local behavior = FastCast.newBehavior()
	behavior.RaycastParams = params
	behavior.Acceleration = options.acceleration or -Vector3.yAxis * workspace.Gravity
	behavior.MaxDistance = options.maxDistance or 10000
	behavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Always
	behavior.HighFidelitySegmentSize = 0.5
	behavior.CanPierceFunction = options.canPierce
	local cast = caster:Fire(origin, direction, velocity, behavior)
	local state = {visual = visual, onImpact = onImpact or function() end, retain = options.retain, spin = options.spin or 4}
	flights[cast] = state
	state.destroying = visual.Destroying:Connect(function()
		-- Impact callbacks may consume the visual before FastCast terminates.
		-- Defer external cancellation to avoid re-entering ActiveCast.Terminate.
		if not state.hit then task.defer(function() if flights[cast] then cast:Terminate() end end) end
	end)
	task.delay(options.lifetime or 8, function() if flights[cast] then cast:Terminate() end end)
	Debris:AddItem(visual, options.visualLifetime or 30)
	return true, visual, cast
end

return Flight
