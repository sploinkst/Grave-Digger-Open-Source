local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local State = require(script.Parent.MixtureState)
local Visuals = require(RS.Shared.Library.MedicalVisuals)
local Mixtures = {}
local mixtures = setmetatable({}, {__mode = "k"})

local function capacity(character)
	local data = character:FindFirstChild("CharacterData")
	local perks = data and data:FindFirstChild("Perks")
	local perk = perks and perks:FindFirstChild("Survivalist")
	return perk and (not perk:IsA("BoolValue") or perk.Value) and 15 or 10
end

function Mixtures.Publish(character, state)
	character:SetAttribute("StimulantSupplies", state.supplies)
	character:SetAttribute("StimulantCapacity", state.capacity)
	character:SetAttribute("StimulantMixture", HttpService:JSONEncode(state.mix))
	local data = character:FindFirstChild("CharacterData")
	local equipment = data and data:FindFirstChild("Equipment")
	Visuals.TintBottle(equipment and equipment:FindFirstChild("stimbottle"), state.mix)
end

function Mixtures.Get(character)
	local maximum = capacity(character)
	local state = mixtures[character]
	if not state then
		state = State.new(maximum)
		mixtures[character] = state
	end
	State.SetCapacity(state, maximum)
	Mixtures.Publish(character, state)
	return state
end

function Mixtures.Restock(player)
	local character = player.Character
	if not character or character:GetAttribute("Class") ~= "Mortician" then return end
	local state = Mixtures.Get(character)
	State.Restock(state)
	Mixtures.Publish(character, state)
end

return Mixtures
