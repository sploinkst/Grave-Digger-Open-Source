-- Shared by the real character and the loadout preview.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(script.Parent.ClassDefinitions)
local Appearance = {}

-- Paths start at game, uses exact Explorer names, and can contain spaces.
-- Helmet models use the existing convention: PrimaryPart named Head, 
-- with all visible pieces welded to it. Roblox Accessories are also supported.
Appearance.Assets = {
	["Golden Empire"] = {
		Soldat = {Helmet = {"ReplicatedStorage", "Shared", "Assets", "Accessories", "Empire_Soldat_Helmet"}},
		Rook = {}, Mortician = {}, Officer = {}, Jaeger = {}, Lancer = {}, Vanguard = {},
	},
	["Royal Nation"] = {
		Soldat = {Helmet = {"ReplicatedStorage", "Shared", "Assets", "Accessories", "Nation_Soldat_Helmet"}},
		Rook = {}, Mortician = {}, Officer = {}, Jaeger = {}, Lancer = {}, Vanguard = {},
	},
}

function Appearance.Resolve(path)
	if type(path) ~= "table" then return nil end
	local node = game
	for _, name in path do
		node = node:FindFirstChild(name)
		if not node then return nil end
	end
	return node
end

function Appearance.Config(teamName, className)
	local team = Appearance.Assets[teamName]
	return team and team[className] or {}
end

function Appearance.Apply(character, teamName, className)
	local config = Appearance.Config(teamName, className)
	local definition = Definitions.Get(className)
	for _, child in character:GetDescendants() do
		if child:GetAttribute("ClassAppearance") then child:Destroy() end
	end
	for _, kind in {"Shirt", "Pants"} do
		local source = Appearance.Resolve(config[kind])
		if source and source:IsA(kind) then
			for _, child in character:GetChildren() do
				if child:IsA(kind) then child:Destroy() end
			end
			source:Clone().Parent = character
		end
	end
	local paths = table.clone(config.Accessories or {})
	if not definition.NoHelmet and config.Helmet then table.insert(paths, config.Helmet) end
	for _, path in paths do
		local source = Appearance.Resolve(path)
		-- Existing accessory folders have faction subfolders; support their unique names.
		if not source and path == config.Helmet then
			source = ReplicatedStorage.Shared.Assets.Accessories:FindFirstChild(path[#path], true)
		end
		if source then
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if clone:IsA("Accessory") and humanoid then
				humanoid:AddAccessory(clone)
			elseif clone:IsA("Model") and clone.PrimaryPart then
				local anchor = character:FindFirstChild(clone.PrimaryPart.Name)
				if anchor and anchor:IsA("BasePart") then
					local offset = clone.PrimaryPart.CFrame:ToObjectSpace(clone:GetPivot())
					clone:PivotTo(anchor.CFrame * offset)
					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") then part.Anchored = false; part.CanCollide = false; part.Massless = true end
					end
					local weld = Instance.new("Weld")
					weld.Name = "AccessoryWeld"
					weld.Part0 = anchor; weld.Part1 = clone.PrimaryPart; weld.Parent = anchor
					weld:SetAttribute("ClassAppearance", true)
					local data = character:FindFirstChild("CharacterData")
					clone.Parent = data and data:FindFirstChild("Equipment") or character
				else clone:Destroy() end
			else clone:Destroy() end
		end
	end
end
return Appearance
