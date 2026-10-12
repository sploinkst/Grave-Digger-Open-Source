local attempts, warnings = 0, 0
local runtime = {Try = function(_, callback, ...) return pcall(callback, ...) end}
local visual = {Name = "Visual", IsA = function() return true end}
local weapon = {Name = "Weapon", IsA = function() return true end}
script = {Parent = {Runtime = "Runtime", FindFirstChild = function(_, kind) return kind == "Visual" and visual or weapon end}}
game = {GetService = function() return {IsClient = function() return true end} end}
workspace = {CurrentCamera = {}}
warn = function() warnings = warnings + 1 end
require = function(module)
 if module == "Runtime" then return runtime end
 attempts = attempts + 1
 if module == visual then error("registry compilation failed") end
 return {Functions = {example = function() return "played" end}, Profiles = {}}
end
local dispatch = dofile("sync/ReplicatedStorage/Shared/Library/MasterEffects/Dispatch.luau")
assert(dispatch.Visual("blood_impact", {}) == false)
assert(dispatch.Visual("blood_impact", {}) == false)
assert(attempts == 1 and warnings == 1)
local ok, result = dispatch.LegacyWeapon("example", {main = {weapon = "test"}})
assert(ok == false and attempts == 1)
assert(dispatch.Weapon({IsFirearm=true},"vfx_eject_casing")==false and attempts==1)
print("Failed registry loads are contained; native firearm and remote weapon effects bypass the duplicate registry")
