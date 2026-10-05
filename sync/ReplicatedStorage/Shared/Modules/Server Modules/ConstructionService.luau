local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Assets = require(RS.Shared.Library.AuthoredAssets)
local Rules = require(RS.Shared.Library.MasterPortRules)
local V = require(script.Parent.MasterActions.Validation)
local Service = {}
local remote = V.Remote("ConstructionAction")
local folder = workspace:FindFirstChild("constructions")
if not folder then folder = Instance.new("Folder"); folder.Name = "constructions"; folder.Parent = workspace end
local TOOLS = {"ConstructHammer", "Hammer", "hammer", "HunterKit", "JaegerKit", "jaegerkit"}
local snapshots = setmetatable({}, {__mode = "k"})

local function number(parent, name, default)
	local child = parent:FindFirstChild(name)
	if not child then child = Instance.new("NumberValue"); child.Name = name; child.Value = default; child.Parent = parent end
	return child
end
local function setState(model)
	if not model:FindFirstChild("construction") or not model:FindFirstChild("health")
		or not model.health:FindFirstChild("maxhealth") then return end
	local progress = model.construction.Value
	local state = Rules.ConstructionState(progress, model.health.Value, model.health.maxhealth.Value)
	local saved = snapshots[model]
	for _, group in ipairs({"unfinished", "finished", "damaged"}) do
		local container = model:FindFirstChild(group)
		if container then
			for _, part in ipairs(container:GetDescendants()) do
				if part:IsA("BasePart") then
					local original = saved and saved[part]
					part.Transparency = group == state and (original and original.transparency or 0) or 1
					part.CanCollide = group == state and (original and original.collide or false)
					part.CanQuery = group == state and (original and original.query or false)
				end
			end
		end
	end
	model:SetAttribute("ConstructionState", state)
end
local function ownerCount(player, name)
	local count = 0
	for _, model in ipairs(folder:GetChildren()) do
		if model.Name == name and model:GetAttribute("OwnerUserId") == player.UserId then count += 1 end
	end
	return count
end
function Service.Find(instance)
	if typeof(instance) ~= "Instance" then return nil end
	while instance and instance.Parent ~= folder do instance = instance.Parent end
	return instance and instance:IsA("Model") and instance or nil
end
function Service.Damage(player, instance, amount)
	local model = Service.Find(instance)
	if not model or not model:FindFirstChild("health") or not Rules.Finite(amount) or amount <= 0 or model:FindFirstChild("invuln") then return false end
	local team = model:FindFirstChild("team")
	if team and team.Value == player.Team then return false end
	model.health.Value = math.max(0, model.health.Value - amount); setState(model)
	if model.health.Value <= 0 then
		if model:GetAttribute("HunterTrap") then require(script.Parent.HunterKitService).TriggerHit(model)
		else model:Destroy() end
	end
	return true
end
function Service.Place(player, name, transform, options)
	local character, root = V.Living(player)
	local template = Assets.Deployable(name)
	if not character or not template or not template:IsA("Model") or not V.Transform(transform)
		or (root.Position - transform.Position).Magnitude > 8 then return nil end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local surface = workspace:Raycast(transform.Position + transform.UpVector * 1.5, -transform.UpVector * 3, params)
	if not surface or surface.Instance.Name == "nobuild" then return nil end
	local ancestor = surface.Instance
	while ancestor and ancestor ~= workspace do
		if ancestor.Name == "Elevator" or ancestor.Name == "trains" or ancestor:GetAttribute("NoBuild") then return nil end
		ancestor = ancestor.Parent
	end
	-- A placement must also be visible from the player's head.
	local head = character:FindFirstChild("Head")
	local obstruction = head and workspace:Raycast(head.Position, transform.Position - head.Position, params)
	if obstruction and (obstruction.Position - transform.Position).Magnitude > 1.5 then return nil end
	local model = template:Clone(); model:PivotTo(transform)
	local bounding = model:FindFirstChild("bounding")
	local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = {character, surface.Instance}
	if bounding and #workspace:GetPartBoundsInBox(bounding.CFrame, bounding.Size * 0.95, overlap) > 0 then model:Destroy(); return nil end
	local trap = table.find(Rules.Traps, name) ~= nil or name == "Tripwire"
	if name == "Tripwire" then
		local linked = false
		for _, candidate in ipairs(folder:GetChildren()) do
			local hook = candidate:FindFirstChild("fuse_hook")
			if hook and candidate:FindFirstChild("tripwires") and candidate:GetAttribute("OwnerUserId") == player.UserId
				and (hook.Position - transform.Position).Magnitude <= Rules.TripwireRange then
				local ray = workspace:Raycast(transform.Position, hook.Position - transform.Position, params)
				if not ray or ray.Instance:IsDescendantOf(candidate) then linked = true; break end
			end
		end
		if not linked then model:Destroy(); return nil end
	end
	local cost = template:GetAttribute("Cost") or ((name == "Mantrap" or name == "Dynamite Stack" or name == "Tin Bomb") and 2 or 1)
	local limit = template:GetAttribute("Limit") or (trap and 2 or 10)
	local supplies = character:FindFirstChild("supplies")
	local balance = supplies and supplies.Value or character:GetAttribute("ConstructionSupplies") or 0
	if not (options and options.free) and not Rules.CanSpend(balance, cost, ownerCount(player, name), limit) then model:Destroy(); return nil end
	if options and options.free and ownerCount(player, name) >= limit then model:Destroy(); return nil end
	local saved = {}; snapshots[model] = saved
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			saved[part] = {transparency = part.Transparency, collide = part.CanCollide, query = part.CanQuery}; part.Anchored = true
		elseif part:IsA("Script") or part:IsA("LocalScript") then part:Destroy() end
	end
	local health = number(model, "health", template:GetAttribute("MaxHealth") or 100)
	number(health, "maxhealth", health.Value)
	number(model, "construction", 100).Value = model:FindFirstChild("unfinished") and 0 or 100
	local owner = model:FindFirstChild("owner") or Instance.new("StringValue"); owner.Name = "owner"; owner.Value = player.Name; owner.Parent = model
	local team = model:FindFirstChild("team") or Instance.new("ObjectValue"); team.Name = "team"; team.Value = player.Team; team.Parent = model
	model:SetAttribute("OwnerUserId", player.UserId); model:SetAttribute("OwnerCharacter", nil)
	model.Parent = folder; setState(model)
	if not (options and options.free) then
		if supplies then supplies.Value -= cost else character:SetAttribute("ConstructionSupplies", balance - cost) end
	end
	if trap then require(script.Parent.HunterKitService).BindTrap(player, model) end
	return model
end
function Service.Repair(player, instance, amount)
	local model = Service.Find(instance)
	if not model or not model:FindFirstChild("team") or model.team.Value ~= player.Team then return false end
	if not model:FindFirstChild("construction") or not model:FindFirstChild("health")
		or not model.health:FindFirstChild("maxhealth") or not Rules.Finite(amount) or amount <= 0 then return false end
	if model.construction.Value < 100 then
		local hits = model.construction:FindFirstChild("require_hits")
		model.construction.Value = math.min(100, model.construction.Value + 100 / math.max(hits and hits.Value or 5, 1))
	elseif not model:FindFirstChild("unrepairable") then model.health.Value = math.min(model.health.maxhealth.Value, model.health.Value + amount)
	else return false end
	setState(model); return true
end
function Service.Restock(player)
	local character = player.Character
	if not character then return end
	local supplies = character:FindFirstChild("supplies")
	local capacity = character:GetAttribute("ConstructionCapacity") or 10
	if supplies then supplies.Value = capacity else character:SetAttribute("ConstructionSupplies", capacity) end
end
function Service.start_module()
	if Service.started then return end; Service.started = true
	workspace:GetAttributeChangedSignal("MatchGeneration"):Connect(function()
		for _, model in ipairs(folder:GetChildren()) do
			if model:GetAttribute("OwnerUserId") then model:Destroy() end
		end
	end)
	remote.OnServerEvent:Connect(function(player, tool, action, argument)
		local character = V.Tool(player, tool, TOOLS)
		if not character or not V.Cooldown(player, "Construction", argument and type(argument) == "table" and argument.name == "Tripwire" and 0.1 or 0.5) then return end
		local traps = tool.Name == "HunterKit" or tool.Name == "JaegerKit" or tool.Name == "jaegerkit"
		local choices = traps and Rules.Traps or Rules.Constructs
		if action == "Place" and type(argument) == "table" and (table.find(choices, argument.name) or traps and argument.name == "Tripwire") then
			Service.Place(player, argument.name, argument.cframe)
		elseif action == "DestroyAll" and type(argument) == "string" and table.find(choices, argument) then
			for _, model in ipairs(folder:GetChildren()) do if model.Name == argument and model:GetAttribute("OwnerUserId") == player.UserId then model:Destroy() end end
		elseif action == "Hammer" and not traps then
			local hit = V.Ray(character, argument, 5)
			if hit and not Service.Repair(player, hit.Instance, tool:GetAttribute("RepairAmount") or 10) then
				Service.Damage(player, hit.Instance, tool:GetAttribute("MeleeDamage") or 80)
			end
		end
	end)
	local function bind(player)
		player.CharacterAdded:Connect(function() Service.Restock(player) end)
		if player.Character then Service.Restock(player) end
	end
	for _, player in ipairs(Players:GetPlayers()) do bind(player) end
	Players.PlayerAdded:Connect(bind)
	Players.PlayerRemoving:Connect(function(player)
		for _, model in ipairs(folder:GetChildren()) do if model:GetAttribute("OwnerUserId") == player.UserId then model:Destroy() end end
	end)
end
return Service
