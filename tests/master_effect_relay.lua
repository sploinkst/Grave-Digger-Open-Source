local file = assert(io.open("sync/ReplicatedStorage/Shared/Modules/Server Modules/MasterEffectsRelay.luau", "r"))
local source = file:read("*a"); file:close()
source = source:gsub("window.count %+%= 1", "window.count = window.count + 1")
source = source:gsub('in game:GetService%("Players"%):GetPlayers%(%) do', 'in ipairs(game:GetService("Players"):GetPlayers()) do')
local sent, callback = {}, nil
local player, recipient = {}, {}
local event = {OnServerEvent = {Connect = function(_, fn) callback = fn end}}
local presentation = {FireClient = function(_, target, action, payload) sent[#sent + 1] = {target = target, action = action, payload = payload} end}
local events = {FindFirstChild = function(_, name) return name == "WeaponEffect" and event or presentation end}
local library = {Events = events, MasterEffects = {NetworkRules = "Allowed"}, WeaponIds = "Ids"}
game = {GetService = function(_, name)
 if name == "ReplicatedStorage" then return {Shared = {Library = library}} end
 if name == "Players" then return {GetPlayers = function() return {player, recipient} end} end
end}
require = function(name)
 return name == "Allowed" and {grenade_pin = true} or {MasterSourceName = function() return "grenade" end}
end
typeof = function(value) return type(value) == "table" and value.instance and "Instance" or type(value) end
math.clamp = function(v, a, b) return math.max(a, math.min(v, b)) end
local character, model = {}, {instance = true}
local humanoid = {Health = 200}
local equipment = {FindFirstChild = function() return model end}
local data = {FindFirstChild = function() return equipment end}
character.FindFirstChildOfClass = function() return humanoid end
character.FindFirstChild = function() return data end
model.IsA = function(_, kind) return kind == "Model" end
model.IsDescendantOf = function(_, parent) return parent == character end
local reference = {Value = "owned", IsA = function(_, kind) return kind == "StringValue" end}
local tool = {instance = true, Name = "Grenade", Parent = character, IsA = function(_, kind) return kind == "Tool" end, FindFirstChild = function() return reference end}
player.Character = character
local relay = assert(load(source, "master relay"))(); relay.start_module()
callback(player, "grenade_pin", tool, model, {ammo_mag = 3, loading_slugs = true, lefthand = true, damage = 999})
assert(#sent == 1 and sent[1].target == recipient and sent[1].action == "master_weapon_effect")
local payload = sent[1].payload.data
assert(payload.main.core.ammo_mag == 3 and payload.main.core.damage == nil and payload.main.module.lefthand)
callback(player, "unknown", tool, model, {})
assert(#sent == 1)
tool.Parent = {}; callback(player, "grenade_pin", tool, model, {}); assert(#sent == 1)
tool.Parent = character; callback(player, "grenade_pin", tool, {instance = true, IsA = model.IsA}, {}); assert(#sent == 1)
humanoid.Health = 0; callback(player, "grenade_pin", tool, model, {}); assert(#sent == 1)
humanoid.Health = 200; callback(player, "grenade_pin", tool, model, {ammo_mag = 0/0}); assert(#sent == 2 and sent[2].payload.data.main.core.ammo_mag == 0)
print("Weapon effect relay ownership, allowlist, health and payload validation passed")
