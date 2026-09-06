local now = 0
local os = {clock = function() return now end}
local scheduled = {}
local task = {delay = function(delay, callback) table.insert(scheduled, {at = now + delay, run = callback}) end}
local function advance(seconds)
	now += seconds
	for i = #scheduled, 1, -1 do
		if scheduled[i].at <= now then local entry = table.remove(scheduled, i); entry.run() end
	end
end
local function signal()
	return {Connect = function(self, callback)
		self.callback = callback
		return {Disconnect = function() end}
	end}
end
local Vector3 = {}
local vectorMeta = {}
function Vector3.new(x, y, z) return setmetatable({X = x, Y = y, Z = z, vector = true}, vectorMeta) end
vectorMeta.__index = function(v, key)
	if key == "Magnitude" then return math.sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z) end
	if key == "Unit" then return Vector3.new(v.X/v.Magnitude, v.Y/v.Magnitude, v.Z/v.Magnitude) end
	if key == "Dot" then return function(a,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
vectorMeta.__add = function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vectorMeta.__sub = function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
vectorMeta.__mul = function(a,b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
local typeof = function(value) return type(value) == "table" and value.vector and "Vector3" or type(value) end
local facing = Vector3.new(0,0,-1)
local CFrame = {new = function() return {} end, lookAt = function() return {} end, Angles = function() return {} end}
local function node(name, class, children)
	local n = {Name = name, ClassName = class, children = children or {}, attributes = {}}
	function n:IsA(kind) return self.ClassName == kind or (kind == "BasePart" and self.ClassName == "Part") end
	function n:FindFirstChild(key) return self.children[key] end
	function n:FindFirstChildOfClass(kind)
		for _, child in self.children do if child:IsA(kind) then return child end end
	end
	n.FindFirstChildWhichIsA = n.FindFirstChildOfClass
	function n:GetAttribute(key) return self.attributes[key] end
	function n:SetAttribute(key, value) self.attributes[key] = value end
	function n:IsDescendantOf(ancestor)
		local current = self.Parent
		while current do if current == ancestor then return true end; current = current.Parent end
		return false
	end
	function n:GetDescendants() local result = {}; for _, child in self.children do table.insert(result, child) end; return result end
	function n:Destroy() self.Parent = nil end
	function n:PivotTo() end
	function n:Clone()
		local clone = node(self.Name, self.ClassName)
		for key, child in self.children do clone.children[key] = child:Clone(); clone.children[key].Parent = clone end
		return clone
	end
	for _, child in n.children do child.Parent = n end
	return n
end
local Instance = {new = function(kind) return node(kind, kind) end}
local Enum = {RaycastFilterType = {Exclude = 1}, ActuatorRelativeTo = {World = 1}}
local RaycastParams = {new = function() return {} end}
local OverlapParams = RaycastParams
local castResult
local parts = {}
local workspace = node("Workspace", "Workspace")
workspace.Gravity = 196.2
function workspace:Raycast() return castResult end
function workspace:Spherecast() return castResult end
function workspace:GetPartBoundsInRadius() return parts end
function workspace:GetServerTimeNow() return now end
local players = {}
local Players = {GetPlayers = function() return players end, GetPlayerFromCharacter = function(_, char)
	for _, player in players do if player.Character == char then return player end end
end}
local remote = {OnServerEvent = signal(), FireClient = function(_, player, kind) player.reply = kind end}
local events = {FindFirstChild = function() return remote end}
local equipment = node("Equipment", "Folder", {throwaxe = node("throwaxe", "Model", {hitbox = node("hitbox", "Part")})})
local ReplicatedStorage = {Shared = {Library = {Events = events}, Assets = {Equipment = equipment}}}
local RunService = {Heartbeat = signal()}
local Debris = {AddItem = function() end}
local game = {GetService = function(_, name)
	return ({Players = Players, ReplicatedStorage = ReplicatedStorage, RunService = RunService, Debris = Debris})[name]
end}
local Util = {check_for_helmet = function(character) return character.helmet, true end}
local script = {Parent = {ReplicantManager = "helmets", StatusService = "statuses"}}
local require = function(name)
	if name == "helmets" then return {pop_helmet = function(_, helmet) helmet:SetAttribute("Knocked", true) end} end
	return {GiveStatus = function() end, RemoveStatus = function() end}
end
local function character(position, weapon)
	local hum = node("Humanoid", "Humanoid"); hum.Health = 500; hum.MaxHealth = 500
	function hum:TakeDamage(amount) self.Health -= amount end
	local root = node("HumanoidRootPart", "Part"); root.Position = position; root.CFrame = {LookVector = facing}; root.AssemblyLinearVelocity = Vector3.new(0,0,0)
	local head = node("Head", "Part"); head.Position = position
	local char = node("Character", "Model", {Humanoid = hum, HumanoidRootPart = root, Head = head})
	if weapon then char.children[weapon] = node(weapon, "Tool"); char.children[weapon].Parent = char end
	char.Parent = workspace
	return char
end
local function player(char, team)
	local p = node("Player", "Player"); p.Character = char; p.Team = team; p.Parent = true
	table.insert(players, p)
	return p
end
local function equal(actual, expected, message)
	assert(actual == expected, message .. ": got " .. tostring(actual) .. ", expected " .. tostring(expected))
end
