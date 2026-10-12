local Master = require(script.Parent.MasterReference.Stimulants)
local Base = require(script.Parent.MasterReference.Base)
local Rules = {}
Rules.DoseUnits = 10
Rules.DoseDuration = 80
Rules.SafeUnits = Base.chem_tolerance * Rules.DoseUnits
Rules.ImpactRadius = 12
Rules.ThrowSpeed = 65
Rules.ToxinInterval = 5
Rules.Order = {"Bicardine", "Synaptizine", "Mephedrone", "Hydrocodone", "Haloperidol", "Amatoxin"}
Rules.Definitions = {
	Bicardine = {description = "3x regeneration, prevents Clotting; heals to full if surgery is not required.", color = {100, 220, 130}},
	Synaptizine = {description = "10% faster sprinting.", color = {235, 215, 90}},
	Mephedrone = {description = "20% faster melee and mining swings.", color = {230, 230, 225}},
	Hydrocodone = {description = "50% less recoil, including flinch.", color = {100, 220, 225}},
	Haloperidol = {description = "50% faster draw and aim; reduced movement and accuracy penalties.", color = {190, 125, 230}},
	Amatoxin = {description = "Builds Pox over time, causing Sickness above 30u.", color = {65, 110, 55}},
}

local nativeNames = {bic = "Bicardine", syn = "Synaptizine", mep = "Mephedrone", hyd = "Hydrocodone", hal = "Haloperidol", ama = "Amatoxin", per = "Peridaxon", int = "Initropidril", sickness = "Pox", tric = "Tricordrazine", inap = "Inaprovaline", eth = "Ethanol"}
Rules.AllOrder = {}
Rules.Aliases = {Bicaridine = "Bicardine"}
for _, entry in ipairs(Master) do
 local name = nativeNames[entry.int]
 Rules.Aliases[entry.int] = name
 local definition = Rules.Definitions[name] or {description = entry.desc, color = {199, 199, 199}}
 definition.duration = entry.last
 definition.icon = entry.icon
 definition.displayName = entry.name
 definition.id = entry.int
 Rules.Definitions[name] = definition
 table.insert(Rules.AllOrder, name)
end
function Rules.Normalize(name) return Rules.Aliases[name] or name end
function Rules.Duration(name)
 local definition = Rules.Definitions[Rules.Normalize(name)]
 return definition and definition.duration or Rules.DoseDuration
end
function Rules.Expire(doses, now)
	for index = #doses, 1, -1 do
		if doses[index].expires <= now then table.remove(doses, index) end
	end
end

function Rules.Units(doses)
	return #doses * Rules.DoseUnits
end

function Rules.Add(doses, name, now, protectAlly)
	name = Rules.Normalize(name)
	if not Rules.Definitions[name] then return false end
	Rules.Expire(doses, now)
	if protectAlly and Rules.Units(doses) + Rules.DoseUnits > Rules.SafeUnits then return false end
	local expiry = now
	for _, dose in doses do
		if dose.name == name then expiry = math.max(expiry, dose.expires) end
	end
	table.insert(doses, {name = name, expires = expiry + Rules.Duration(name), protectAlly = protectAlly == true})
	return true
end

function Rules.Active(doses)
	local active = {}
	for _, dose in doses do active[dose.name] = true end
	return active
end

function Rules.MixtureColor(mix)
	local color = {199, 199, 199}
	for _, name in mix do
		local chemical = Rules.Definitions[name]
		if chemical then
			for channel = 1, 3 do color[channel] = (color[channel] + chemical.color[channel]) / 2 end
		end
	end
	return color
end

function Rules.Summarize(mix)
	local result, byName = {}, {}
	for _, name in mix do
		if not Rules.Definitions[name] then continue end
		local entry = byName[name]
		if not entry then entry = {name = name, units = 0, duration = 0}; byName[name] = entry; table.insert(result, entry) end
		entry.units += Rules.DoseUnits
		entry.duration += Rules.Duration(name)
	end
	return result
end

function Rules.DescribeBloodstream(snapshot, now)
	local entries, order = {}, {}
	for _, dose in snapshot do
		if type(dose.name) ~= "string" or type(dose.expiresAt) ~= "number" or dose.expiresAt <= now then continue end
		local entry = entries[dose.name]
		if not entry then entry = {units = 0, remaining = 0}; entries[dose.name] = entry; table.insert(order, dose.name) end
		entry.units += dose.units or Rules.DoseUnits
		entry.remaining = math.max(entry.remaining, math.ceil(dose.expiresAt - now))
	end
	local lines = {}
	for _, name in order do
		local entry = entries[name]
		table.insert(lines, string.format("%du %s (%ds)", entry.units, name, entry.remaining))
	end
	return #lines > 0 and table.concat(lines, ", ") or "Clean bloodstream."
end

return Rules
