local now = 0
local os = {clock = function() return now end}
local task = {delay = function() end}
local function signal()
	return {Connect = function(self, callback) self.callback = callback end}
end
local WhistleEquipEvent = {OnServerEvent = signal()}
local WhistleOrderEvent = {OnServerEvent = signal(), FireClient = function(self, player, kind, value)
	player.reply = {kind, value}
end}
local RunService = {Heartbeat = signal()}
local players = {}
local player_service = {GetPlayers = function() return players end, PlayerRemoving = signal()}
local function position(x)
	return setmetatable({x = x}, {__sub = function(a, b) return {Magnitude = math.abs(a.x - b.x)} end})
end
local function character(x, capacity)
	local attributes = {Class = "Officer", Equipment = "TrenchWhistle", WhistleEquipped = true, OfficerOrderCapacity = capacity or 1}
	local children = {HumanoidRootPart = {Position = position(x)}, Humanoid = {Health = 100}, TrenchWhistleTool = {}}
	return {GetAttribute = function(_, key) return attributes[key] end,
		SetAttribute = function(_, key, value) attributes[key] = value end,
		FindFirstChild = function(_, key) return children[key] end,
		FindFirstChildOfClass = function(_, key) return children[key] end}
end
local function player(x, team, capacity)
	local p = {Character = character(x, capacity), Team = team, Parent = true}
	table.insert(players, p)
	return p
end
local function equal(actual, expected, message)
	assert(actual == expected, message .. ": got " .. tostring(actual) .. ", expected " .. tostring(expected))
end
local function tickAura()
	now += .5
	RunService.Heartbeat.callback(.5)
end
local function issue(p, order, duration)
	now += .5
	WhistleOrderEvent.OnServerEvent.callback(p, order, duration)
end
