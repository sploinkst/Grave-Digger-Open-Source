local Service = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Shared = ReplicatedStorage.Shared
local Status = require(script.Parent.StatusService)
local Remote = Shared.Library.Events:WaitForChild("MedicalSyrettes")
local Charges = setmetatable({}, {__mode = "k"})
local Aid = require(script.Parent.AidService)
local Medical = require(Shared.Library.MedicalRules)

local function capacity(character)
	local data = character:FindFirstChild("CharacterData")
	local perks = data and data:FindFirstChild("Perks")
	local survivalist = perks and perks:FindFirstChild("Survivalist")
	return survivalist and (not survivalist:IsA("BoolValue") or survivalist.Value) and 3 or 2
end

local function stateFor(character)
	local maximum = capacity(character)
	local state = Charges[character]
	if not state then
		state = {count = maximum, maximum = maximum, time = os.clock()}
		Charges[character] = state
	end
	if maximum > state.maximum then state.count += maximum - state.maximum end
	state.maximum = maximum
	local now = os.clock()
	local restored = math.floor((now - state.time) / 20)
	if restored > 0 then
		state.count = math.min(maximum, state.count + restored)
		state.time += restored * 20
	end
	state.count = math.min(maximum, state.count)
	character:SetAttribute("SyretteCapacity", maximum)
	character:SetAttribute("SyretteCharges", state.count)
	return state, maximum
end

local function needsAid(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
		and Medical.CanReceiveSyrette(humanoid.Health, Status.HasStatus(player, "ClottingStatus"),
			character:GetAttribute("SurgeryBlocked") or character:GetAttribute("IsDreadnought")), humanoid
end

local function heal(recipient, provider, providerCharacter, health)
	local needed, humanoid = needsAid(recipient)
	if not needed then return false end
	if humanoid.Health < 100 then
		humanoid.Health = math.min(health, humanoid.MaxHealth)
		while Status.HasStatus(recipient, "WoundStatus") do Status.RemoveStatus(recipient, "WoundStatus") end
	end
	if Status.HasStatus(recipient, "ClottingStatus") then Status.RemoveStatus(recipient, "ClottingStatus") end
	Aid.Record(recipient, provider, providerCharacter)
	return true
end

local function pickup(root)
	local assets = Shared.Assets:FindFirstChild("Equipment")
	local source = assets and (assets:FindFirstChild("MedicalSyrettes") or assets:FindFirstChild("MedicalSyrette") or assets:FindFirstChild("Syrette"))
	local object = source and source:Clone()
	if object and not object:IsA("BasePart") and not object:IsA("Model") then object:Destroy(); object = nil end
	if not object then
		-- A visible fallback until an authored syrette model is supplied.
		object = Instance.new("Part")
		object.Size = Vector3.new(0.25, 0.25, 1.2)
		object.Color = Color3.fromRGB(225, 235, 230)
		object.Material = Enum.Material.Metal
	end
	object.Name = "MedicalSyrette"
	local part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
	if not part then object:Destroy(); return nil end
	if object:IsA("Model") then object:PivotTo(root.CFrame * CFrame.new(0, 0, -4))
	else part.CFrame = root.CFrame * CFrame.new(0, 0, -4) end
	local parts = object:IsA("Model") and object:GetDescendants() or {part}
	for _, child in parts do
		if child:IsA("BasePart") then
			child.Anchored = false; child.CanCollide = true; child.CanTouch = true
			if child ~= part then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = part; weld.Part1 = child; weld.Parent = part
			end
		end
	end
	object.Parent = workspace
	part:SetNetworkOwner(nil)
	part.AssemblyLinearVelocity = root.CFrame.LookVector * 20 + Vector3.new(0, 8, 0)
	return object, parts
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	Remote.OnServerEvent:Connect(function(player, target)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid or humanoid.Health <= 0 or not player.Team
			or character:GetAttribute("Class") ~= "Mortician"
			or character:GetAttribute("Equipment") ~= "MedicalSyrettes" then return end
		local recipient
		if target ~= nil then
			if typeof(target) ~= "Instance" or not target:IsA("Model") then return end
			recipient = Players:GetPlayerFromCharacter(target)
			local targetRoot = target:FindFirstChild("HumanoidRootPart")
			if not recipient or recipient == player or recipient.Team ~= player.Team or not targetRoot
				or (targetRoot.Position - root.Position).Magnitude > Medical.SyretteRange or not needsAid(recipient) then return end
		end
		local state, maximum = stateFor(character)
		if state.count <= 0 then return end
		local health = character:GetAttribute("EliteClass") == "Flame Trooper" and 200 or 150
		if recipient then
			if not heal(recipient, player, character, health) then return end
		else
			local object, parts = pickup(root)
			if not object then return end
			local consumed = false
			for _, part in parts do
				if not part:IsA("BasePart") then continue end
				part.Touched:Connect(function(hit)
					if consumed then return end
					local model = hit:FindFirstAncestorOfClass("Model")
					local collector = model and Players:GetPlayerFromCharacter(model)
					if not collector or collector == player then return end
					if heal(collector, player, character, health) then consumed = true; object:Destroy() end
				end)
			end
			Debris:AddItem(object, 30)
		end
		if state.count == maximum then state.time = os.clock() end
		state.count -= 1
		character:SetAttribute("SyretteCharges", state.count)
	end)
	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				local character = player.Character
				if character and character:GetAttribute("Equipment") == "MedicalSyrettes" then stateFor(character) end
			end
			task.wait(0.25)
		end
	end)
end

return Service
