game = {GetService=function() return {IsStudio=function() return false end} end}
-- Startup and source-data regression checks run without Roblox services.
local root = "sync/ReplicatedStorage/Shared/Library/"
local references = root .. "MasterReference/"
local base = dofile(references .. "Base.luau")
local equipment = dofile(references .. "Equipments.luau")
local chemicals = dofile(references .. "Stimulants.luau")
assert(base.base_health == 200 and base.chem_tolerance == 3)
assert(equipment.rook.ammo == 3 and equipment.rook.cd == 40)
assert(equipment.soldat.cd == 20 and equipment.jaeger.ammo == 1 and equipment.jaeger.cd == 60)
assert(#chemicals == 12 and chemicals.bic == chemicals[1] and chemicals.eth == chemicals[12])
assert(chemicals.ama.last == 25 and chemicals.int.last == 8.5 and chemicals.inap.last == 30)
assert(next(dofile(references .. "Localization.luau")) == nil)
for _, lines in pairs(dofile(references .. "Wardialogue.luau")) do assert(#lines == 0) end
-- Loading the effect registries must not access the old workspace remotes or live assets.
local service = {RenderStepped = {}, Heartbeat = {}}
game = {GetService = function() return service end}
workspace = {CurrentCamera = {}}
PhysicalProperties = {new = function() return {} end}
Vector3 = {new = function() return {} end}
Color3 = {fromRGB = function() return {} end}
CFrame = {new = function() return {} end}
tick = function() return 0 end
script = {Parent = {Runtime = "Runtime", Helpers = "Helpers"}}
local runtime = {World = function() return {} end, Assets = function() return {FindFirstChild = function() return nil end} end, Setting = function() return false end}
require = function(name) return name == "Runtime" and runtime or {} end
local weapon = dofile(root .. "MasterEffects/Weapon.luau")
local visual = dofile(root .. "MasterEffects/Visual.luau")
assert(type(weapon.Functions.cylinder_rotate) == "function")
assert(type(weapon.Functions.stim_pushpart) == "function")
assert(type(visual.Functions.flamer_fx) == "function")
assert(type(visual.Functions.apply_character_overlay) == "function")
local wc, vc = 0, 0
for _, callback in pairs(weapon.Functions) do assert(type(callback) == "function"); wc = wc + 1 end
for _, callback in pairs(visual.Functions) do assert(type(callback) == "function"); vc = vc + 1 end
assert(wc == 103 and vc == 53)
local network = dofile(root .. "MasterEffects/NetworkRules.luau")
for name in pairs(weapon.Functions) do assert(network[name], "Missing network allowlist: " .. name) end
for name in pairs(network) do assert(weapon.Functions[name], "Unknown network effect: " .. name) end
-- Definition-dependent safe no-ops should also execute without an instance tree.
weapon.Functions.lewis_rotate({})
weapon.Functions.grenade_pin_return({main = {}})
visual.Functions.reset_limbpos({})
visual.Functions.lowgraphics_flare({})
print("Master reference data and startup passed: " .. wc .. " weapon effects, " .. vc .. " visual effects")
