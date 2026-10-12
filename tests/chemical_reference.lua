game = {GetService=function() return {IsStudio=function() return false end} end}
local root = "sync/ReplicatedStorage/Shared/Library/"
local data = dofile(root .. "MasterReference/Stimulants.luau")
local base = dofile(root .. "MasterReference/Base.luau")
script = {Parent = {MasterReference = {Stimulants = "Stimulants", Base = "Base"}}}
require = function(name) return name == "Stimulants" and data or base end
local file = assert(io.open(root .. "ChemicalRules.luau", "r"))
local source = file:read("*a"); file:close()
source = source:sub(1, assert(source:find("function Rules.Summarize", 1, true)) - 1)
source = source:gsub(" in doses do", " in ipairs(doses) do"):gsub(" in mix do", " in ipairs(mix) do")
local rules = assert(load(source .. "\nreturn Rules", "chemical rules"))()
local doses = {}
assert(rules.Add(doses, "ama", 100, false) and doses[1].name == "Amatoxin" and doses[1].expires == 125)
assert(rules.Add(doses, "Bicaridine", 100, true) and doses[2].name == "Bicardine" and doses[2].expires == 180)
assert(rules.Add(doses, "inap", 100, true) and doses[3].expires == 130)
assert(not rules.Add(doses, "eth", 100, true)) -- Ally overdose prevention.
assert(rules.Add(doses, "eth", 100, false) and doses[4].expires == 130)
assert(not rules.Add(doses, "unknown", 100, false))
rules.Expire(doses, 125)
assert(#doses == 3 and not rules.Active(doses).Amatoxin)
rules.Expire(doses, 130)
assert(#doses == 1 and rules.Units(doses) == 10)
assert(rules.Add(doses, "bic", 130, true) and doses[2].expires == 260) -- Stacked native doses extend the lifetime.
assert(rules.Duration("int") == 8.5 and rules.Duration("per") == 20)
print("Chemical aliases, lifetimes, stacking, expiry and ally overdose protection passed")
