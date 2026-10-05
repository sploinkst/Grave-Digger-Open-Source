-- Server-simulated flight and impact; chemical application lives in ChemicalService.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Shared = RS.Shared
local Rules = require(Shared.Library.ChemicalRules)
local Chemicals = require(script.Parent.Parent.ChemicalService)
local Bottle = {}

local function impact(provider, character, position, mix)
	local cloud = Instance.new("Part")
	cloud.Name = "StimulantCloud"; cloud.Shape = Enum.PartType.Ball
	cloud.Size = Vector3.one * Rules.ImpactRadius * 2
	cloud.Color = Color3.fromRGB(table.unpack(Rules.MixtureColor(mix)))
	cloud.Transparency = 0.85; cloud.Anchored = true
	cloud.CanCollide = false; cloud.CanTouch = false; cloud.CanQuery = false
	cloud.Position = position; cloud.Parent = workspace
	Debris:AddItem(cloud, 1.5)
	for _, player in Players:GetPlayers() do
		local target = player.Character
		local root = target and target:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - position).Magnitude > Rules.ImpactRadius then continue end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {cloud, character}
		local hit = workspace:Raycast(position + Vector3.new(0, 0.1, 0), root.Position - position, params)
		if not hit or hit.Instance:IsDescendantOf(target) then Chemicals.ApplyMixture(provider, character, player, mix) end
	end
end

function Bottle.Throw(player, character, direction, mix)
	local head = character:FindFirstChild("Head")
	if not head then return false end
	local source = Shared.Assets.Guns.ToolModels:FindFirstChild("stimbottle")
	local bottle = source and source:Clone() or Instance.new("Part")
	if bottle:IsA("BasePart") then bottle.Size = Vector3.new(0.6, 1.2, 0.6); bottle.Color = Color3.fromRGB(100, 160, 120) end
	bottle.Name = "ThrownStimulants"
	local parts = bottle:IsA("BasePart") and {bottle} or bottle:GetDescendants()
	for _, part in parts do
		if part:IsA("BasePart") then part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false end
	end
	bottle.Parent = workspace
	local position = head.Position
	local velocity = direction * Rules.ThrowSpeed
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, bottle}
	local elapsed = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if not bottle.Parent or elapsed > 8 then connection:Disconnect(); bottle:Destroy(); return end
		local delta = velocity * dt - Vector3.yAxis * workspace.Gravity * dt * dt / 2
		local hit = workspace:Raycast(position, delta, params)
		if hit then
			connection:Disconnect(); bottle:Destroy()
			if player.Parent == Players then impact(player, character, hit.Position + hit.Normal * 0.15, mix) end
			return
		end
		position += delta
		velocity -= Vector3.yAxis * workspace.Gravity * dt
		bottle:PivotTo(CFrame.new(position) * CFrame.Angles(elapsed * 6, 0, 0))
	end)
	return true
end

return Bottle
