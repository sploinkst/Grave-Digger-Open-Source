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
	if not tool or not tool:IsA("Tool") or state.charging or os.clock() < state.attack then return end
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
	local root = character:FindFirstChild("HumanoidRootPart")
	for _, ally in Players:GetPlayers() do
		local target = ally.Character
		local alive, _, allyRoot = living(target)
		if alive and (ally == player or (player.Team and ally.Team == player.Team))
			and (root.Position - allyRoot.Position).Magnitude <= 80 then
			local untilTime = workspace:GetServerTimeNow() + 33
			target:SetAttribute("MoraleUntil", untilTime)
			target:SetAttribute("Clotting", nil)
			ally:SetAttribute("clotting", nil)
			ally:SetAttribute("morale", true)
			task.delay(33, function()
				if ally.Character == target and target:GetAttribute("MoraleUntil") == untilTime then
					target:SetAttribute("MoraleUntil", nil); ally:SetAttribute("morale", nil)
				end
			end)
		end
	end
end

-- Charge and axes handlers are defined below; all requests use server-owned state.
local charge
local throwAxe

function Service.start_module()
	if Service.started then return end
	Service.started = true
	remote.OnServerEvent:Connect(function(player, action, direction)
		local character = player.Character
		if not living(character) then return end
		local state = stateFor(character)
		if action == "Block" then
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