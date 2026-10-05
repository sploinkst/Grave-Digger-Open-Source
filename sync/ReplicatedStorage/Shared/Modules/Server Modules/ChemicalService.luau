-- Owns bloodstream doses, overdose, poison, and replicated chemical effects.
local Service = {}
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Rules = require(RS.Shared.Library.ChemicalRules)
local Status = require(script.Parent.StatusService)
local Aid = require(script.Parent.AidService)
local bloodstreams = setmetatable({}, {__mode = "k"})

local function bloodstreamFor(character)
	local state = bloodstreams[character]
	if not state then state = {doses = {}, toxinAt = os.clock() + Rules.ToxinInterval, clockOffset = workspace:GetServerTimeNow() - os.clock()}; bloodstreams[character] = state end
	return state
end

local function updateEffects(player, character, state)
	Rules.Expire(state.doses, os.clock())
	local active = Rules.Active(state.doses)
	local units = Rules.Units(state.doses)
	local snapshot = {}
	for _, dose in state.doses do
		table.insert(snapshot, {name = dose.name, units = Rules.DoseUnits, expiresAt = state.clockOffset + dose.expires})
	end
	character:SetAttribute("ChemicalSnapshot", HttpService:JSONEncode(snapshot))
	character:SetAttribute("ChemicalUnits", units)
	if units > Rules.SafeUnits and not Status.HasStatus(player, "SicknessStatus") then
		Status.GiveStatus(player, "SicknessStatus")
		state.sickness = true
	elseif units <= Rules.SafeUnits and state.sickness then
		if Status.HasStatus(player, "SicknessStatus") then Status.RemoveStatus(player, "SicknessStatus") end
		state.sickness = nil
	end
	local enabled = not player:GetAttribute("Sickness") and not character:GetAttribute("PositiveStimulantsPaused")
	local function effect(name, attribute, value)
		character:SetAttribute(attribute, enabled and active[name] and value or nil)
	end
	effect("Bicardine", "ChemicalRegenerationMultiplier", 3)
	effect("Bicardine", "ChemicalClottingImmune", true)
	effect("Synaptizine", "ChemicalSprintMultiplier", 1.1)
	effect("Mephedrone", "ChemicalSwingMultiplier", 1.2)
	effect("Hydrocodone", "ChemicalRecoilMultiplier", 0.5)
	effect("Haloperidol", "ChemicalHandlingMultiplier", 1.5)
	effect("Haloperidol", "ChemicalMovementPenaltyMultiplier", 0.5)
	for _, name in Rules.Order do
		local remaining = 0
		for _, dose in state.doses do
			if dose.name == name then remaining = math.max(remaining, dose.expires - os.clock()) end
		end
		character:SetAttribute(name .. "ExpiresAt", remaining > 0 and state.clockOffset + os.clock() + remaining or nil)
	end
	if enabled and active.Bicardine and Status.HasStatus(player, "ClottingStatus") then Status.RemoveStatus(player, "ClottingStatus") end
end

function Service.ApplyMixture(provider, providerCharacter, recipient, mix)
	local character = recipient.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or character:GetAttribute("StatusImmune") then return end
	if recipient ~= provider and character:GetAttribute("Class") == "Mortician" then return end
	local protected = recipient ~= provider and provider.Team ~= nil and recipient.Team == provider.Team
	local state = bloodstreamFor(character)
	local applied = false
	for _, name in mix do
		if Rules.Add(state.doses, name, os.clock(), protected) then
			applied = true
			updateEffects(recipient, character, state)
			if name == "Bicardine" and not recipient:GetAttribute("Sickness")
				and not character:GetAttribute("PositiveStimulantsPaused") and humanoid.Health >= 100 then
				humanoid.Health = humanoid.MaxHealth
			end
		end
	end
	if applied and protected then Aid.Record(recipient, provider, providerCharacter) end
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				local character = player.Character
				if not character then continue end
				local state = bloodstreams[character]
				local health = character:FindFirstChildOfClass("Humanoid")
				if not state or not health or health.Health <= 0 then continue end
				Rules.Expire(state.doses, os.clock())
				if os.clock() >= state.toxinAt then
					state.toxinAt = os.clock() + Rules.ToxinInterval
					local active = Rules.Active(state.doses)
					if active.Amatoxin and not player:GetAttribute("Sickness") then
						local protected = true
						for _, dose in state.doses do
							if dose.name == "Amatoxin" and not dose.protectAlly then protected = false end
						end
						Rules.Add(state.doses, "Pox", os.clock(), protected)
					end
				end
				updateEffects(player, character, state)
			end
			task.wait(0.25)
		end
	end)
end

return Service
