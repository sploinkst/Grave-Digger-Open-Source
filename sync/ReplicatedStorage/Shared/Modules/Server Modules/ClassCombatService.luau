local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Rules = require(ReplicatedStorage.Shared.Library.MeleeRules)
local Util = require(ReplicatedStorage.Shared.Library.Util)
local Service = {}
local events = ReplicatedStorage.Shared.Library.Events
local remote = events:FindFirstChild("ClassCombat")
if not remote then
	remote = Instance.new("RemoteEvent"); remote.Name = "ClassCombat"; remote.Parent = events
end
local states = setmetatable({}, {__mode = "k"})

local function stateFor(character)
	local state = states[character]
	if not state then state = {attack = 0, charge = 0, inspire = 0, axe = 0, axes = Rules.Axes.Count}; states[character] = state end
	return state
end

local function living(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return humanoid and root and humanoid.Health > 0 and character.Parent ~= nil, humanoid, root
end

local function enemy(player, character)
	if character == player.Character then return false end
	local target = Players:GetPlayerFromCharacter(character)
	return not target or player.Team == nil or target.Team ~= player.Team
end

local function characterFrom(part)
	while part and part ~= workspace do
		if part:IsA("Model") and part:FindFirstChildOfClass("Humanoid") then return part end
		part = part.Parent
	end
end

local function paramsFor(character)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	return params
end

local function validDirection(direction)
	return typeof(direction) == "Vector3" and direction.X == direction.X and direction.Y == direction.Y
		and direction.Z == direction.Z and direction.Magnitude > .9 and direction.Magnitude < 1.1
end

local function perk(character, name)
	local data = character:FindFirstChild("CharacterData")
	local perks = data and data:FindFirstChild("Perks")
	local entry = perks and perks:FindFirstChild(name)
	return entry ~= nil and (not entry:IsA("BoolValue") or entry.Value)
end

function Service.Blocks(character, origin)
	local alive, _, root = living(character)
	if not alive or not character:FindFirstChild("shield") or character:GetAttribute("ShieldRaised") ~= true then return false end
	local delta = origin - root.Position
	return delta.Magnitude > .01 and root.CFrame.LookVector:Dot(delta.Unit) >= Rules.Shield.BlockDot
end

local function damage(player, target, amount, instant)
	local alive, humanoid = living(target)
	if not alive or not enemy(player, target) then return end
	local targetPlayer = Players:GetPlayerFromCharacter(target)
	if targetPlayer then targetPlayer:SetAttribute("LastTagged", player.Name) end
	humanoid:TakeDamage(instant and humanoid.Health or amount * (target:GetAttribute("MeleeDamageMultiplier") or 1))
end

local function visible(character, target, origin, position)
	local hit = workspace:Raycast(origin, position - origin, paramsFor(character))
	return not hit or hit.Instance:IsDescendantOf(target)
end

local function sweep(player, character, direction, shield)
	local alive, _, root = living(character)
	if not alive then return end
	direction = root.CFrame.LookVector
	local reach = shield and Rules.Shield.Range or Rules.Lance.SweepRange
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = {character}
	local targets = {}
	for _, part in workspace:GetPartBoundsInRadius(root.Position, reach + 2, overlap) do
		local target = characterFrom(part)
		if target and not targets[target] then
			targets[target] = true
			local targetAlive, _, targetRoot = living(target)
			if targetAlive and enemy(player, target) then
				local delta = targetRoot.Position - root.Position
				local dot = delta.Magnitude > .01 and direction:Dot(delta.Unit) or 1
				if delta.Magnitude <= reach and dot >= Rules.Lance.SweepDot
					and visible(character, target, root.Position, targetRoot.Position)
					and not Service.Blocks(target, root.Position) then
					damage(player, target, shield and Rules.Shield.Damage or Rules.Lance.SweepDamage)
				end
			end
		end
	end
end

local function stab(player, character, direction)
	local head = character:FindFirstChild("Head")
	if not head then return end
	-- A single ray, with no sweep fallback: headshots must actually hit the head.
	local hit = workspace:Raycast(head.Position, direction * Rules.Lance.StabRange, paramsFor(character))
	local target = hit and characterFrom(hit.Instance)
	if not target or not enemy(player, target) or Service.Blocks(target, head.Position) then return end
	local helmet, knockable = Util.check_for_helmet(target)
	if helmet and (helmet:GetAttribute("Knocked") or helmet:GetAttribute("HelmetSpent")) then helmet = nil end
	local headshot = hit.Instance.Name == "Head" or (helmet and hit.Instance:IsDescendantOf(helmet))
	if headshot and helmet then
		require(script.Parent.ReplicantManager).pop_helmet(target, helmet, knockable, player)
	end
	damage(player, target, Rules.Lance.StabDamage, headshot and not helmet)
end

local function attack(player, character, state, mode, direction)
	local shield = mode == "ShieldSwing"
	local tool = character:FindFirstChild(shield and "shield" or "lance")
	if not tool or not tool:IsA("Tool") or state.prepared or state.charging or os.clock() < state.attack then return end
	state.attack = os.clock() + Rules.Lance.Interval
	if shield then character:SetAttribute("ShieldRaised", false) end
	task.delay(Rules.Lance.Windup, function()
		if player.Character ~= character or tool.Parent ~= character or not living(character) then return end
		if mode == "Stab" then stab(player, character, direction) else sweep(player, character, direction, shield) end
	end)
end

local function inspire(player, character, state)
	if not character:FindFirstChild("lance") or state.charging or os.clock() < state.inspire then return end
	state.inspire = os.clock() + 30
	character:SetAttribute("InspireReadyAt", workspace:GetServerTimeNow() + 30)
	remote:FireClient(player, "Inspire")
	-- Morale/Clotting gameplay is deferred until those status systems exist.

end

-- Charge and axes handlers are defined below; all requests use server-owned state.
local charge
local throwAxe

local function recover(player, character, seconds, knocked)
	local alive, humanoid, root = living(character)
	if not alive then return end
	character:SetAttribute("CombatStunned", true)
	local wasAnchored = root.Anchored
	if knocked then
		require(script.Parent.StatusService).GiveStatus(player, "RagdollStatus")
	else root.Anchored = true end
	task.delay(seconds, function()
		if root.Parent then root.Anchored = wasAnchored end
		character:SetAttribute("CombatStunned", nil)
		if knocked and player.Character == character then
			require(script.Parent.StatusService).RemoveStatus(player, "RagdollStatus")
		end
	end)
end

charge = function(player, character, state)
	local tool = character:FindFirstChild("lance")
	local _, humanoid, root = living(character)
	if not tool or state.charging or os.clock() < state.charge or os.clock() < state.attack then return end
	if root.AssemblyLinearVelocity:Dot(root.CFrame.LookVector) < 16 then return end
	local butcher, veteran = perk(character, "Butcher"), perk(character, "Veteran")
	local duration, cooldown, maximum = Rules.ChargePerks(butcher, veteran)
	-- Point-blank attempts use the ordinary sweep, including its windup/damage.
	local nearby = workspace:Spherecast(root.Position, 1.5, root.CFrame.LookVector * 4, paramsFor(character))
	local closeTarget = nearby and characterFrom(nearby.Instance)
	if closeTarget and enemy(player, closeTarget) then
		attack(player, character, state, "Sweep", root.CFrame.LookVector)
		remote:FireClient(player, "CloseSweep")
		return
	end
	state.charging = true
	character:SetAttribute("charging", true)
	character:SetAttribute("ImprovedCharge", butcher or veteran)
	remote:FireClient(player, "Charge")
	local attachment = Instance.new("Attachment"); attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment; velocity.MaxForce = math.huge
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World; velocity.Parent = root
	local endsAt = os.clock() + duration
	local previous = root.Position
	local struck = {}
	local count = 0
	local reason = "Expired"
	local connection
	local function finish(why)
		if not state.charging then return end
		state.charging = false
		state.charge = os.clock() + cooldown
		character:SetAttribute("ChargeReadyAt", workspace:GetServerTimeNow() + cooldown)
		character:SetAttribute("charging", nil)
		character:SetAttribute("ImprovedCharge", nil)
		connection:Disconnect(); velocity:Destroy(); attachment:Destroy()
		if player.Parent then remote:FireClient(player, "ChargeStop", why) end
		if why ~= "Cancelled" and player.Character == character and living(character) then
			recover(player, character, why == "Kill" and (butcher and .35 or .7) or 1, why == "Obstacle")
		end
	end
	connection = RunService.Heartbeat:Connect(function(dt)
		if player.Character ~= character or not living(character) or tool.Parent ~= character then finish("Cancelled"); return end
		if os.clock() >= endsAt then finish(reason); return end
		local direction = root.CFrame.LookVector
		velocity.VectorVelocity = Vector3.new(direction.X * 23, root.AssemblyLinearVelocity.Y, direction.Z * 23)
		local traveled = root.Position - previous
		if traveled.Magnitude > 23 * dt + 8 then finish("Cancelled"); return end
		local params = paramsFor(character)
		local excluded = {character}
		for target in struck do table.insert(excluded, target) end
		params.FilterDescendantsInstances = excluded
		local hit = workspace:Spherecast(previous, 1.4, traveled + direction * 2.5, params)
		previous = root.Position
		if not hit then return end
		local target = characterFrom(hit.Instance)
		if target and not enemy(player, target) then struck[target] = true; return end
		if target and living(target) then
			if Service.Blocks(target, root.Position) then
				if veteran then
					target:SetAttribute("ShieldRaised", false); target:SetAttribute("ShieldStamina", 0)
					stateFor(target).attack = os.clock() + 3
					task.delay(3, function() if target.Parent then target:SetAttribute("ShieldStamina", 100) end end)
				end
				finish("Obstacle"); return
			end
			struck[target] = true
			count += 1
			damage(player, target, 0, true)
			reason = "Kill"
			remote:FireClient(player, "ChargeHit")
			if count >= maximum then finish("Kill") end
		elseif hit.Instance.CanCollide then finish("Obstacle") end
	end)
end

throwAxe = function(player, character, state, direction)
	if character:GetAttribute("Class") ~= "Lancer" or character:GetAttribute("Equipment") ~= "ThrowingAxes"
		or state.charging or os.clock() < state.axe or state.axes <= 0 or not state.prepared then return end
	local source = ReplicatedStorage.Shared.Assets.Equipment:FindFirstChild("throwaxe")
	if not source then return end
	local drawTime = perk(character, "Marksman") and .1 or .25
	if os.clock() - state.prepared < drawTime then
		if state.releasing then return end
		state.releasing = true
		local prepared = state.prepared
		task.delay(drawTime - (os.clock() - prepared), function()
			state.releasing = false
			if player.Character == character and living(character) and state.prepared == prepared then
				throwAxe(player, character, state, direction)
			end
		end)
		return
	end
	state.prepared = nil
	state.axe = os.clock() + Rules.Axes.Interval
	state.axes -= 1
	state.regen = state.regen or os.clock() + 20
	local held = character:FindFirstChild("PreparedAxe")
	character:SetAttribute("ThrowingAxesCount", state.axes)
	remote:FireClient(player, "ThrowAxe", state.axes)
	task.delay(Rules.Axes.Windup, function()
		if held then held:Destroy() end
		if player.Character ~= character or not living(character) then return end
		local head = character:FindFirstChild("Head")
		if not head then return end
		local axe = source:Clone()
		for _, part in axe:GetDescendants() do
			if part:IsA("BasePart") then part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false end
		end
		axe.Parent = workspace
		local position = head.Position
		local velocity = direction * Rules.Axes.Speed
		local gravity = workspace.Gravity * (perk(character, "Marksman") and .1 or 1)
		local elapsed = 0
		local params = paramsFor(character)
		params.FilterDescendantsInstances = {character, axe}
		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			elapsed += dt
			if not axe.Parent or elapsed > Rules.Axes.Lifetime then connection:Disconnect(); axe:Destroy(); return end
			local delta = velocity * dt + Vector3.new(0, -gravity * dt * dt / 2, 0)
			local hit = workspace:Raycast(position, delta, params)
			if hit then
				local target = characterFrom(hit.Instance)
				if target and not Service.Blocks(target, position) and enemy(player, target) then
					local helmet = Util.check_for_helmet(target)
					if helmet and (helmet:GetAttribute("Knocked") or helmet:GetAttribute("HelmetSpent")) then helmet = nil end
					local headshot = hit.Instance.Name == "Head" or (helmet and hit.Instance:IsDescendantOf(helmet))
					if helmet then require(script.Parent.ReplicantManager).pop_helmet(target, helmet, true, player) end
					damage(player, target, Rules.Axes.Damage, headshot and not helmet)
				end
				axe:PivotTo(CFrame.lookAt(hit.Position, hit.Position + velocity.Unit))
				connection:Disconnect(); Debris:AddItem(axe, 8); return
			end
			position += delta
			velocity += Vector3.new(0, -gravity * dt, 0)
			axe:PivotTo(CFrame.lookAt(position, position + velocity.Unit) * CFrame.Angles(elapsed * 20, 0, 0))
		end)
	end)
end

local function prepareAxe(character, state)
	if character:GetAttribute("Class") ~= "Lancer" or character:GetAttribute("Equipment") ~= "ThrowingAxes"
		or state.prepared or state.charging or state.axes <= 0 or os.clock() < state.axe then return end
	local source = ReplicatedStorage.Shared.Assets.Equipment:FindFirstChild("throwaxe")
	local arm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
	if not source or not arm then return end
	local clone = source:Clone()
	clone.Name = "PreparedAxe"
	local grip = clone:FindFirstChild("hitbox", true) or clone:FindFirstChildWhichIsA("BasePart", true)
	if not grip then clone:Destroy(); return end
	clone:PivotTo(arm.CFrame)
	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.Massless = true
			if part ~= grip then
				local weld = Instance.new("WeldConstraint"); weld.Part0 = grip; weld.Part1 = part; weld.Parent = grip
			end
		end
	end
	local motor = Instance.new("Motor6D"); motor.Name = "AxeGrip"
	motor.Part0 = arm; motor.Part1 = grip; motor.C0 = CFrame.new(0, -1, 0); motor.Parent = clone
	clone.Parent = character
	state.prepared = os.clock()
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	RunService.Heartbeat:Connect(function()
		local now = os.clock()
		for _, player in Players:GetPlayers() do
			local character = player.Character
			if character and character:GetAttribute("Class") == "Lancer" then
				local state = stateFor(character)
				local maximum = perk(character, "Survivalist") and 6 or 4
				if not state.initialized then state.axes = maximum; state.initialized = true end
				if state.regen and now >= state.regen then
					state.axes = math.min(maximum, state.axes + 1)
					state.regen = state.axes < maximum and now + 20 or nil
				end
				character:SetAttribute("ThrowingAxesCount", state.axes)
				if state.prepared and (not living(character) or character:FindFirstChildOfClass("Tool")) then
					state.prepared = nil
					local held = character:FindFirstChild("PreparedAxe"); if held then held:Destroy() end
				end
			end
		end
	end)
	remote.OnServerEvent:Connect(function(player, action, direction)
		local character = player.Character
		if not living(character) or character:GetAttribute("CombatStunned") then return end
		local state = stateFor(character)
		if action == "PrepareAxe" then prepareAxe(character, state)
		elseif action == "CancelAxe" then
			state.prepared = nil
			local held = character:FindFirstChild("PreparedAxe"); if held then held:Destroy() end
		elseif action == "Block" then
			if type(direction) ~= "boolean" or not character:FindFirstChild("shield") then return end
			if direction and os.clock() < state.attack then return end
			character:SetAttribute("ShieldRaised", direction)
		elseif action == "Inspire" then inspire(player, character, state)
		elseif validDirection(direction) then
			if action == "Sweep" or action == "Stab" or action == "ShieldSwing" then attack(player, character, state, action, direction)
			elseif action == "Charge" then charge(player, character, state)
			elseif action == "ThrowAxe" then throwAxe(player, character, state, direction) end
		end
	end)
end

return Service
