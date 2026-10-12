-- Resolve dedicated mod models and apply their authored visibility groups.
local Ids = require(script.Parent.WeaponIds)
local Stats = require(script.Parent.WeaponModStats)
local ModelRules = require(script.Parent.WeaponModModelRules)
local Cosmetics = require(script.Parent.MasterCosmetics)
local Appearance = {}
function Appearance.Model(models, weapon, equipment)
	local canonical = Ids.Canonical(weapon)
	if not Stats[canonical] then return nil end
	-- Dedicated variants take priority. Imported shared models also contain mod parts.
	local names = {Ids.MasterSourceName(canonical), canonical}
	for _, alias in ipairs(Ids.Aliases(canonical)) do table.insert(names, alias) end
	for _, folder in ipairs({models or false, equipment or false}) do
	if folder then
	for _, name in ipairs(names) do
		local direct = folder:FindFirstChild(name)
		if direct and (direct:IsA("Model") or direct:IsA("BasePart") or direct:IsA("Tool")) then return direct end
		for _, candidate in ipairs(folder:GetDescendants()) do
			if candidate.Name:lower() == name:lower() and (candidate:IsA("Model") or candidate:IsA("BasePart") or candidate:IsA("Tool")) then
				return candidate
			end
		end
	end
	end
	end
	local baseNames = Ids.Aliases(Ids.AssetName(canonical))
	table.insert(baseNames, 1, Ids.AssetName(canonical))
	for _, folder in ipairs({models or false, equipment or false}) do
		if folder then
			for _, name in ipairs(baseNames) do
				for _, candidate in ipairs(folder:GetDescendants()) do
					if candidate.Name:lower() == name:lower() and (candidate:IsA("Model") or candidate:IsA("BasePart") or candidate:IsA("Tool")) then
						return candidate
					end
				end
			end
		end
	end
	return nil
end

function Appearance.Clone(model, weapon, skin)
 local family = weapon and Ids.AssetName(weapon)
 local replacement = family and Cosmetics.model_replacements[family] and skin and skin ~= "stock" and Cosmetics.SkinModel(weapon,skin)
 local clone = (replacement or model):Clone()
 clone.Name = model.Name
	if clone:IsA("Tool") then
		local container = Instance.new("Model")
		container.Name = clone.Name
		for _, child in ipairs(clone:GetChildren()) do child.Parent = container end
		clone:Destroy()
		clone = container
	end
	return clone
end

function Appearance.Root(model)
	if not model then return nil end
	if model:IsA("BasePart") then return model end
	local hitbox = model:FindFirstChild("hitbox", true)
	if hitbox and hitbox:IsA("BasePart") then return hitbox end
	if model:IsA("Model") and model.PrimaryPart then return model.PrimaryPart end
	local handle = model:FindFirstChild("Handle", true)
	if handle and handle:IsA("BasePart") then return handle end
	return model:FindFirstChildWhichIsA("BasePart", true)
end

local function visibility(group, enabled)
	local objects = group:GetDescendants(); table.insert(objects, group)
	for _, part in ipairs(objects) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			local original = part:GetAttribute("ModOriginalTransparency")
			if original == nil then
				original = part:GetAttribute("VisibleTransparency") or part.Transparency
				if original == 1 and part.Name ~= "hitbox" then original = 0 end
				part:SetAttribute("ModOriginalTransparency", original)
			end
			part.Transparency = enabled and original or 1
		end
	end
end
function Appearance.Apply(model, weapon, skin, character)
	local canonical = Ids.Canonical(weapon)
	local mod = Stats[canonical]
	local source = Ids.MasterSourceName(canonical)
	local function selected(required)
		if type(required) ~= "string" then return false end
		required = required:lower()
		if not mod then return required == "standard" end
		return required == source:lower() or required == canonical:lower()
			or required == mod.variant:lower() or Ids.Canonical(required) == canonical
	end
	local variants = model:FindFirstChild("Variants")
	if variants then
		for _, group in ipairs(variants:GetChildren()) do
			visibility(group, selected(group.Name))
		end
	end
	for _, group in ipairs(model:GetDescendants()) do
		if Ids.AssetName(canonical) == "enfield" and group.Name:lower():match("^bipod[1234]$") then
			visibility(group, mod ~= nil and mod.variant == "enfield")
		end
		local required = group:GetAttribute("WeaponModification")
		if type(required) == "string" then
			visibility(group, selected(required))
		end
	end
	ModelRules.Apply(model, mod and mod.variant or Ids.AssetName(canonical), mod ~= nil)
	if skin and skin ~= "stock" then Cosmetics.apply_skin(model, Ids.AssetName(canonical), skin, character) end
	model:SetAttribute("WeaponSkin", skin or "stock")
	model:SetAttribute("WeaponModification", mod and source or "")
end
return Appearance
