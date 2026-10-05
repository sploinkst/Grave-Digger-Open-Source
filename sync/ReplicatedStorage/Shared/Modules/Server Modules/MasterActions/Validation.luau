local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Rules = require(RS.Shared.Library.MasterPortRules)
local Validation = {}
local cooldowns = setmetatable({}, {__mode = "k"})
function Validation.Remote(name)
	local events = RS.Shared.Library.Events
	local remote = events:FindFirstChild(name)
	if not remote then remote = Instance.new("RemoteEvent"); remote.Name = name; remote.Parent = events end
	return remote
end
function Validation.Living(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if player.Parent ~= Players or not humanoid or humanoid.Health <= 0 or not root then return nil end
	if player:GetAttribute("MenuOpen") or character:GetAttribute("ActionBlocked")
		or character:GetAttribute("CombatStunned") or character:GetAttribute("Surrendered") then return nil end
	return character, root, humanoid
end
function Validation.State(character, name)
	local data = character:FindFirstChild("CharacterData")
	local state = data and data:FindFirstChild("State")
	local value = state and state:FindFirstChild(name)
	return value and value.Value or character:GetAttribute(name)
end
function Validation.Tool(player, tool, names)
	local character, root, humanoid = Validation.Living(player)
	if not character or typeof(tool) ~= "Instance" or not tool:IsA("Tool") or tool.Parent ~= character then return nil end
	local weapon = tool:FindFirstChild("weapon")
	local name = weapon and weapon.Value or tool.Name
	if not table.find(names, tool.Name) and not table.find(names, name) then return nil end
	if tool:GetAttribute("Inactive") then return nil end
	return character, root, humanoid
end
function Validation.Cooldown(player, key, seconds)
	local state = cooldowns[player]
	if not state or state.character ~= player.Character then state = {character = player.Character}; cooldowns[player] = state end
	local now = os.clock()
	if now < (state[key] or 0) then return false end
	state[key] = now + seconds; return true
end
function Validation.Vector(value)
	return typeof(value) == "Vector3" and Rules.Finite(value.X) and Rules.Finite(value.Y) and Rules.Finite(value.Z)
end
function Validation.Direction(value)
	return Validation.Vector(value) and value.Magnitude > 0.9 and value.Magnitude < 1.1
end
function Validation.Transform(value)
	if typeof(value) ~= "CFrame" then return false end
	for _, component in ipairs({value:GetComponents()}) do if not Rules.Finite(component) then return false end end
	return true
end
function Validation.Ray(character, direction, range)
	if not Validation.Direction(direction) then return nil end
	local head = character:FindFirstChild("Head")
	if not head then return nil end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	return workspace:Raycast(head.Position, direction * range, params)
end
return Validation
