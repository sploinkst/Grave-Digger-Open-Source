-- Shared by the real character and the loadout preview.
--   Assets/outfits/<team>/<class>
--   Assets/outfits/elite/<team>/<class> (Shock Troopers only)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Appearance = {}
-- Temporary runtime tracing for class helmet integration. Keep this enabled
-- until the Studio output confirms the complete mount path. Legit no clue why it's breaking btw
Appearance.DebugHelmets = true

local function helmetDebug(...)
	if Appearance.DebugHelmets then warn("[ClassAppearance/Helmet]", ...) end
end

local function childIgnoreCase(parent: Instance?, name: string): Instance?
	if not parent then return nil end
	local direct = parent:FindFirstChild(name)
	if direct then return direct end
	local wanted = string.lower(name)
	for _, child in parent:GetChildren() do
		if string.lower(child.Name) == wanted then return child end
	end
	return nil
end

local function teamFolderName(teamName: string?): string
	if teamName == "Golden Empire" then return "empire" end
	if teamName == "Royal Nation" then return "nation" end
	return teamName or "nation"
end

function Appearance.GetOutfit(teamName: string?, className: string?, isElite: boolean?): Folder?
	local assets = ReplicatedStorage.Shared:FindFirstChild("Assets")
	local outfits = childIgnoreCase(assets, "outfits")
	if not outfits then return nil end
	local root = if isElite then (childIgnoreCase(outfits, "elite") or childIgnoreCase(outfits, "elites")) else outfits
	local team = childIgnoreCase(root, teamFolderName(teamName))
	local class = childIgnoreCase(team, className or "Soldat")
	return if class and class:IsA("Folder") then class else nil
end

local function attachModel(character: Model, clone: Model, helmet: boolean)
	local primary = if helmet then (childIgnoreCase(clone, "helmet") :: BasePart?) else nil
	if primary and not primary:IsA("BasePart") then primary = nil end
	primary = primary or clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	if not primary then
		helmetDebug("FAILED: no BasePart to mount", clone:GetFullName())
		clone:Destroy()
		return false
	end
	clone.PrimaryPart = primary
	-- Outfit helmet models use internal mesh names, never character-part names.
	-- They always mount to Head; other outfit models retain their authored target.
	local anchor = if helmet then character:FindFirstChild("Head") else character:FindFirstChild(primary.Name)
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("HumanoidRootPart")
	if not anchor or not anchor:IsA("BasePart") then
		helmetDebug("FAILED: no character anchor", clone.Name, "helmet=", helmet)
		clone:Destroy()
		return false
	end
	local data = character:FindFirstChild("CharacterData")
	clone.Parent = data and data:FindFirstChild("Equipment") or character
	if helmet then helmetDebug("mounting", clone.Name, "primary=", primary.Name, "anchor=", anchor.Name, "parent=", clone.Parent and clone.Parent:GetFullName()) end
	local offset = primary.CFrame:ToObjectSpace(clone:GetPivot())
	clone:PivotTo(anchor.CFrame * offset)
	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanQuery = false
			part.Massless = true
		end
	end
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = anchor
	weld.Part1 = primary
	weld.Parent = anchor
	weld:SetAttribute("ClassAppearance", true)
	if helmet and not clone:FindFirstChild("Helmet") then
		-- Existing helmet gameplay identifies a helmet by this marker.  Keep the
		-- source model untouched and add the compatibility marker to its clone.
		local marker = Instance.new("Folder")
		marker.Name = "Helmet"
		marker:SetAttribute("ClassAppearance", true)
		marker.Parent = clone
	end
	if helmet then
		task.defer(function()
			helmetDebug("mounted", clone.Name, "stillParented=", clone.Parent ~= nil, "weldPart1=", weld.Part1 and weld.Part1:GetFullName())
		end)
	end
	return true
end

local function attachPart(character: Model, clone: BasePart, helmet: boolean): boolean
	local headAttachment = helmet or string.lower(clone.Name) == "extralift"
	local anchor = if headAttachment then character:FindFirstChild("Head") else character:FindFirstChild("Torso")
	if not anchor or not anchor:IsA("BasePart") then
		helmetDebug("FAILED: no anchor for part", clone.Name)
		clone:Destroy()
		return false
	end
	local data = character:FindFirstChild("CharacterData")
	clone.Parent = data and data:FindFirstChild("Equipment") or character
	local childOffsets = {}
	for _, child in clone:GetDescendants() do
		if child:IsA("BasePart") then
			childOffsets[child] = clone.CFrame:ToObjectSpace(child.CFrame)
		end
	end
	clone.Anchored = false
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Massless = true
	clone:SetAttribute("ClassAppearance", true)
	if helmet then clone:SetAttribute("ClassHelmet", true) end
	-- Direct-part helmet kits are authored around their own part origin, so
	-- welding that origin to Head is the intended attachment.
	clone.CFrame = anchor.CFrame
	local adjacency = {[clone] = {}}
	for child, offset in childOffsets do
		child.Anchored = false
		child.CanCollide = false
		child.CanQuery = false
		child.CanTouch = false
		child.Massless = true
		child.CFrame = anchor.CFrame * offset
		adjacency[child] = {}
	end
	-- Keep helmetfly/extrajoint and internal mesh welds. Welding every mesh
	-- directly to the root overconstrains those articulated assemblies.
	for _, joint in clone:GetDescendants() do
		if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
			local part0, part1 = joint.Part0, joint.Part1
			if adjacency[part1] and not adjacency[part0] then
				joint.Part0 = clone
				part0 = clone
			end
			if adjacency[part0] and adjacency[part1] then
				table.insert(adjacency[part0], part1)
				table.insert(adjacency[part1], part0)
			end
		end
	end
	local connected = {}
	local function visit(part)
		if connected[part] then return end
		connected[part] = true
		for _, neighbor in adjacency[part] do visit(neighbor) end
	end
	visit(clone)
	for child, offset in childOffsets do
		if not connected[child] then
			local childWeld = Instance.new("Weld")
			childWeld.Name = "HelmetAccessoryWeld"
			childWeld.Part0 = clone
			childWeld.Part1 = child
			childWeld.C0 = offset
			childWeld.Parent = clone
			childWeld:SetAttribute("ClassAppearance", true)
			visit(child)
		end
	end
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = anchor
	weld.Part1 = clone
	weld.Parent = anchor
	weld:SetAttribute("ClassAppearance", true)
	if helmet then
		helmetDebug("mounted part helmet", clone.Name, "anchor=", anchor.Name, "parent=", clone.Parent:GetFullName())
	end
	return true
end

-- Some exported kits (Nation Soldat) keep their head rig as sibling parts.
-- Clone the folder together before regrouping so cross-part weld references
-- point at cloned parts, never at the source outfit or separate loose clones.
local function attachFlatHelmet(character: Model, outfit: Folder): boolean
	local sourceHead = outfit:FindFirstChild("Head")
	local sourceShell = outfit:FindFirstChild("knock")
	if not sourceHead or not sourceHead:IsA("BasePart") or not sourceShell or not sourceShell:IsA("BasePart") then return false end
	local copied = outfit:Clone()
	local assembly = Instance.new("Model")
	assembly.Name = "ClassHelmet"
	assembly:SetAttribute("ClassAppearance", true)
	for _, child in copied:GetChildren() do
		if child:IsA("BasePart") or child:IsA("JointInstance") or child:IsA("Constraint") then
			child.Parent = assembly
		end
	end
	assembly.PrimaryPart = assembly:FindFirstChild("Head")
	copied:Destroy()
	attachModel(character, assembly, true)
	return true
end

local function isHelmet(instance: Instance): boolean
	if string.find(string.lower(instance.Name), "helmet", 1, true) then return true end
	for _, child in instance:GetDescendants() do
		if string.find(string.lower(child.Name), "helmet", 1, true) then return true end
	end
	return false
end

local function restoreHair(character: Model)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			local original = part:GetAttribute("ClassHairTransparency")
			if type(original) == "number" then
				part.Transparency = original
				part:SetAttribute("ClassHairTransparency", nil)
			end
		end
	end
end

local function hideHair(character: Model)
	for _, accessory in character:GetChildren() do
		if accessory:IsA("Accessory") and not isHelmet(accessory) then
			for _, part in accessory:GetDescendants() do
				if part:IsA("BasePart") then
					part:SetAttribute("ClassHairTransparency", part.Transparency)
					part.Transparency = 1
				end
			end
		end
	end
	local hair = character:FindFirstChild("Hair")
	if hair then
		for _, part in hair:GetDescendants() do
			if part:IsA("BasePart") then
				part:SetAttribute("ClassHairTransparency", part.Transparency)
				part.Transparency = 1
			end
		end
	end
end

function Appearance.Apply(character: Model, teamName: string?, className: string?)
	local elite = character:GetAttribute("IsShockTrooper") == true
	if elite then
		local definitions = require(ReplicatedStorage.Shared.Library.ClassDefinitions)
		local kit = definitions.GetElite(character:GetAttribute("EliteClass"))
		className = kit and (kit.OutfitClass or kit.RequiredClass) or character:GetAttribute("ClassOutfit") or className
	end
	local outfit = Appearance.GetOutfit(teamName, className, elite)
	if not outfit then
		warn(("[ClassAppearance] Missing %soutfit: outfits/%s/%s")
			:format(if elite then "elite " else "", teamFolderName(teamName), className or "Soldat"))
		return
	end
	helmetDebug("apply", "team=", tostring(teamName), "class=", tostring(className), "outfit=", outfit:GetFullName())

	for _, child in character:GetDescendants() do
		if child:GetAttribute("ClassAppearance") then child:Destroy() end
	end
	restoreHair(character)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local flatHelmet = attachFlatHelmet(character, outfit)
	local helmetEquipped = flatHelmet
	-- Class kits are deliberately flat: pants, shirt, helmet and any class
	-- accessories live directly under outfits/<team>/<class>.  Walking every
	-- descendant made model kits unreliable because their internal mesh/weld
	-- hierarchy could be mistaken for a second outfit item.
	for _, source in outfit:GetChildren() do
		if flatHelmet and (source:IsA("BasePart") or source:IsA("JointInstance") or source:IsA("Constraint")) then continue end
		if Appearance.DebugHelmets then helmetDebug("outfit child", source.Name, source.ClassName, "isHelmet=", isHelmet(source)) end
		if source:IsA("Shirt") or source:IsA("Pants") or source:IsA("ShirtGraphic") then
			for _, existing in character:GetChildren() do
				if existing.ClassName == source.ClassName then existing:Destroy() end
			end
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			clone.Parent = character
		elseif source:IsA("Accessory") and humanoid then
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			if isHelmet(clone) then
				helmetEquipped = true
				if className == "Lancer" then clone:SetAttribute("Unknockable", true) end
			end
			humanoid:AddAccessory(clone)
		elseif source:IsA("Model") then
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			local helmet = isHelmet(clone)
			if helmet then helmetDebug("found model helmet", source:GetFullName()) end
			if helmet and className == "Lancer" then clone:SetAttribute("Unknockable", true) end
			if attachModel(character, clone, helmet) and helmet then helmetEquipped = true end
		elseif source:IsA("BasePart") then
			local clone = source:Clone()
			local helmet = isHelmet(clone)
			if helmet then helmetDebug("found part helmet", source:GetFullName()) end
			if helmet and className == "Lancer" then clone:SetAttribute("Unknockable", true) end
			if attachPart(character, clone, helmet) and helmet then helmetEquipped = true end
		end
	end
	if helmetEquipped and className ~= "Officer" then hideHair(character) end
end

return Appearance
