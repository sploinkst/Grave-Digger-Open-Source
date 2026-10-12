local Shared = game:GetService("ReplicatedStorage").Shared
local Ids = require(Shared.Library.WeaponIds)
local ModAppearance = require(Shared.Library.WeaponModAppearance)
local ModStats = require(Shared.Library.WeaponModStats)
local MasterCosmetics = require(Shared.Library.MasterCosmetics)
local Appearance = {}

local function named(parent, name)
	if not parent then return end
	local direct = parent:FindFirstChild(name)
	if direct then return direct end
	for _, child in parent:GetChildren() do
		if child.Name:lower() == name:lower() then return child end
	end
end

function Appearance.Skin(player, weapon, slot)
	return MasterCosmetics.SelectedSkin(player,weapon,slot)
end

function Appearance.Model(models, weapon, rules, teamName, player, slot)
	local sourceName = Ids.MasterSourceName(weapon)
	local isMod = ModStats[Ids.Canonical(weapon)] ~= nil
	local source
	if isMod then
		source = ModAppearance.Model(models, weapon, Shared.Assets:FindFirstChild("Equipment"))
	else
		source = named(models, sourceName) or named(models, Ids.Canonical(weapon)) or named(models, Ids.AssetName(weapon))
	end
	if not isMod and rules.alt_team_model and teamName == "Golden Empire" then
		source = named(models, rules.alt_team_model) or source
	end
	local skin = Appearance.Skin(player, weapon, slot)
	local skinModel = skin ~= "stock" and MasterCosmetics.SkinModel(weapon,skin)
	if MasterCosmetics.model_replacements[Ids.AssetName(weapon)] and skinModel then source=skinModel end
	return source, skin
end

function Appearance.Apply(model, rules, skin, character, weapon)
	ModAppearance.Apply(model, rules.variant and rules.variant ~= "" and (rules.variant .. "variant") or weapon or model.Name,skin,character)
	model:SetAttribute("MenuVariant", rules.variant or "")
	model:SetAttribute("MenuSkin", skin)
end

function Appearance.Sheath(rig, parent, weapon, rules, secondary, skin, team)
	local authored=MasterCosmetics:add_sheath(rig,Ids.AssetName(weapon),skin or "stock",secondary and 2 or 1,team)
	if authored then authored.Parent=parent; return end
	local asset = Ids.AssetName(weapon)
	if asset ~= "knife" and asset ~= "cavsword" then return end
	local guns = Shared.Assets:FindFirstChild("Guns")
	local holsters = guns and guns:FindFirstChild("Holsters")
	local models = guns and guns:FindFirstChild("ToolModels")
	local source = named(holsters, "sheath_" .. asset) or named(models, "sheath_" .. asset)
	if not source then return end
	local clone = source:Clone()
	local root = clone:IsA("BasePart") and clone or clone:FindFirstChild("hitbox", true) or clone.PrimaryPart
	local body = rig:FindFirstChild(rules.holster_point or "Torso")
	local c0 = secondary and rules.alt_holsterc0 or rules.holsterc0
	local c1 = secondary and rules.alt_holsterc1 or rules.holsterc1
	if not root or not body or not c0 then clone:Destroy(); return end
	c0 = clone:GetAttribute("HolsterC0") or c0
	c1 = clone:GetAttribute("HolsterC1") or c1 or CFrame.identity
	local delta = body.CFrame * c0 * c1:Inverse() * root.CFrame:Inverse()
	local parts = clone:IsA("BasePart") and {clone} or {}
	for _, object in clone:GetDescendants() do
		if object:IsA("BasePart") then table.insert(parts, object)
		elseif object:IsA("JointInstance") or object:IsA("WeldConstraint") or object:IsA("LuaSourceContainer") or object:IsA("Sound") then object:Destroy()
		elseif object:IsA("Light") or object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then object.Enabled = false end
	end
	for _, part in parts do
		part.CFrame = delta * part.CFrame
		part.Anchored = false; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
		part.Massless = true; part.LocalTransparencyModifier = 0
		if part ~= root then
			local joint = Instance.new("WeldConstraint")
			joint.Part0 = root; joint.Part1 = part; joint.Parent = root
		end
	end
	local mount = Instance.new("Weld")
	mount.Part0 = body; mount.Part1 = root; mount.C0 = c0; mount.C1 = c1; mount.Parent = root
	clone.Name = "sheath_" .. asset; clone.Parent = parent
end

return Appearance
