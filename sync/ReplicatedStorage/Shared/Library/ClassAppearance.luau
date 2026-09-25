-- Shared by the real character and the loadout preview.
--   Assets/outfits/<team>/<class>
--   Assets/outfits/elite/<team>/<class> (Shock Troopers only)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Appearance = {}
Appearance.DebugHelmets = false

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
	if not isElite then
		local team = childIgnoreCase(outfits, teamFolderName(teamName))
		local class = childIgnoreCase(team, className or "Soldat")
		return if class and class:IsA("Folder") then class else nil
	end

	for _, rootName in {"elites", "elite"} do
		local root = childIgnoreCase(outfits, rootName)
		local team = childIgnoreCase(root, teamFolderName(teamName))
		local class = childIgnoreCase(team, className or "Soldat")
		if class and class:IsA("Folder") then return class end
	end
	return nil
end

local function getEliteTorso(className: string?): Instance?
	local assets = ReplicatedStorage.Shared:FindFirstChild("Assets")
	local outfits = childIgnoreCase(assets, "outfits")
	local elites = outfits and (childIgnoreCase(outfits, "elites") or childIgnoreCase(outfits, "elite"))
	if not elites then return nil end
	local key = string.lower(className or "Soldat") .. "_elitetorso"
	return childIgnoreCase(elites, key)
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

local function attachRigGroup(character: Model, source: Instance): boolean
	local anchor = character:FindFirstChild(source.Name)
	if not anchor or not anchor:IsA("BasePart") then return false end

	local clone = source:Clone()
	clone:SetAttribute("ClassAppearance", true)
	clone.Parent = character:FindFirstChild("CharacterData")
		and character.CharacterData:FindFirstChild("Equipment")
		or character

	local parts = {}
	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true
			table.insert(parts, descendant)
		elseif descendant:IsA("JointInstance") then
			descendant:SetAttribute("ClassAppearance", true)
		end
	end

	if #parts == 0 then
		clone:Destroy()
		return false
	end

	for _, part in parts do
		if part.Name == anchor.Name then
			part.Transparency = 1
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
		else
			local weld = Instance.new("Weld")
			weld.Name = "DreadArmourWeld"
			weld.Part0 = anchor
			weld.Part1 = part
			weld.C0 = anchor.CFrame:ToObjectSpace(part.CFrame)
			weld.Parent = anchor
			weld:SetAttribute("ClassAppearance", true)
		end
	end

	return true
end

local function attachRigOutfit(character: Model, container: Instance): boolean
	local equipped = false
	for _, group in container:GetChildren() do
		if attachRigGroup(character, group) then
			equipped = true
		end
	end
	return equipped
end

local function attachEliteTorso(character: Model, className: string?): boolean
	local source = getEliteTorso(className)
	if not source then return false end

	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso or not torso:IsA("BasePart") then return false end

	local clone = source:Clone()
	clone:SetAttribute("ClassAppearance", true)
	clone.Name = "EliteTorso"
	clone.Parent = character:FindFirstChild("CharacterData")
		and character.CharacterData:FindFirstChild("Equipment")
		or character

	local parts = {}
	local rootPart: BasePart?
	if clone:IsA("BasePart") then
		rootPart = clone
		table.insert(parts, clone)
	else
		rootPart = (clone :: Instance):FindFirstChild("Torso", true) :: BasePart?
			or (clone :: Instance):FindFirstChildWhichIsA("BasePart", true)
		if not rootPart and clone:IsA("Model") then
			rootPart = clone.PrimaryPart
		end
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				table.insert(parts, descendant)
			elseif descendant:IsA("JointInstance") or descendant:IsA("Constraint") then
				descendant:SetAttribute("ClassAppearance", true)
			end
		end
	end

	if not rootPart or #parts == 0 then
		clone:Destroy()
		return false
	end

	local rootCFrame = rootPart.CFrame
	local offsets = {}
	for _, part in parts do
		offsets[part] = rootCFrame:ToObjectSpace(part.CFrame)
	end

	if clone:IsA("Model") then
		clone.PrimaryPart = rootPart
		clone:PivotTo(torso.CFrame * rootCFrame:ToObjectSpace(clone:GetPivot()))
	else
		rootPart.CFrame = torso.CFrame
	end

	for _, part in parts do
		part.Anchored = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part:SetAttribute("ClassAppearance", true)
		if part ~= rootPart then
			part.CFrame = rootPart.CFrame * offsets[part]
			local weld = Instance.new("Weld")
			weld.Name = "EliteTorsoInternalWeld"
			weld.Part0 = rootPart
			weld.Part1 = part
			weld.C0 = offsets[part]
			weld.Parent = rootPart
			weld:SetAttribute("ClassAppearance", true)
		end
	end

	local weld = Instance.new("Weld")
	weld.Name = "EliteTorsoWeld"
	weld.Part0 = torso
	weld.Part1 = rootPart
	weld.Parent = torso
	weld:SetAttribute("ClassAppearance", true)

	return true
end

-- Some exported kits (Nation Soldat) keep their head rig as sibling parts.
-- Clone the folder together before regrouping so cross-part weld references
-- point at cloned parts, never at the source outfit or separate loose clones.
local function attachFlatHelmet(character: Model, outfit: Folder, className: string): boolean
	local sourceHead = outfit:FindFirstChild("Head")
	local sourceShell = outfit:FindFirstChild("knock")
	if not sourceHead or not sourceHead:IsA("BasePart") or not sourceShell or not sourceShell:IsA("BasePart") then return false end
	local copied = outfit:Clone()
	local assembly = Instance.new("Model")
	assembly.Name = "ClassHelmet"
	assembly:SetAttribute("ClassAppearance", true)
	assembly:SetAttribute(className .. "Helmet", true)
	if className == "Lancer" then assembly:SetAttribute("Unknockable", true) end
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

function Appearance.Apply(character: Model, teamName: string?, className: string?, equipmentOnly: boolean?)
	local elite = character:GetAttribute("IsShockTrooper") == true
	if elite then
		local definitions = require(ReplicatedStorage.Shared.Library.ClassDefinitions)
		local kit = definitions.GetElite(character:GetAttribute("EliteClass"))
		className = kit and kit.OutfitClass or character:GetAttribute("ClassOutfit") or className
	end
	local outfit = Appearance.GetOutfit(teamName, className, elite)
	if not outfit then
		warn(("[ClassAppearance] Missing outfit: outfits/%s%s/%s")
			:format(if elite then "elites/" else "", teamFolderName(teamName), className or "Soldat"))
		return
	end
	helmetDebug("apply", "team=", tostring(teamName), "class=", tostring(className), "outfit=", outfit:GetFullName())
	local helmetClassName = className or "Soldat"

	for _, child in character:GetDescendants() do
		local clothing = child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic")
		if child:GetAttribute("ClassAppearance") and not (equipmentOnly and clothing) then
			child:Destroy()
		end
	end
	restoreHair(character)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local flatHelmet = attachFlatHelmet(character, outfit, helmetClassName)
	local helmetEquipped = flatHelmet
	local nestedOutfit = childIgnoreCase(outfit, "outfit")
	if nestedOutfit and not equipmentOnly then
		attachRigOutfit(character, nestedOutfit)
	end
	for _, source in outfit:GetChildren() do
		if source == nestedOutfit then continue end
		if flatHelmet and (source:IsA("BasePart") or source:IsA("JointInstance") or source:IsA("Constraint")) then continue end
		if Appearance.DebugHelmets then helmetDebug("outfit child", source.Name, source.ClassName, "isHelmet=", isHelmet(source)) end
		if source:IsA("Shirt") or source:IsA("Pants") or source:IsA("ShirtGraphic") then
			if equipmentOnly then continue end
			for _, existing in character:GetChildren() do
				if existing.ClassName == source.ClassName then existing:Destroy() end
			end
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			clone.Parent = character
		elseif source:IsA("Accessory") and humanoid then
			local clone = source:Clone()
			if equipmentOnly and not isHelmet(clone) then
				clone:Destroy()
				continue
			end
			clone:SetAttribute("ClassAppearance", true)
			if isHelmet(clone) then
				helmetEquipped = true
				if helmetClassName == "Lancer" then clone:SetAttribute("Unknockable", true) end
				clone:SetAttribute(helmetClassName .. "Helmet", true)
			end
			humanoid:AddAccessory(clone)
		elseif source:IsA("Model") then
			local clone = source:Clone()
			clone:SetAttribute("ClassAppearance", true)
			local helmet = isHelmet(clone)
			if equipmentOnly and not helmet then
				clone:Destroy()
				continue
			end
			if helmet then helmetDebug("found model helmet", source:GetFullName()) end
			if helmet then
				if helmetClassName == "Lancer" then clone:SetAttribute("Unknockable", true) end
				clone:SetAttribute(helmetClassName .. "Helmet", true)
			end
			if attachModel(character, clone, helmet) and helmet then helmetEquipped = true end
		elseif source:IsA("BasePart") then
			local clone = source:Clone()
			local helmet = isHelmet(clone)
			if equipmentOnly and not helmet then
				clone:Destroy()
				continue
			end
			if helmet then helmetDebug("found part helmet", source:GetFullName()) end
			if helmet then
				if helmetClassName == "Lancer" then clone:SetAttribute("Unknockable", true) end
				clone:SetAttribute(helmetClassName .. "Helmet", true)
			end
			if attachPart(character, clone, helmet) and helmet then helmetEquipped = true end
		end
	end
	if elite and character:GetAttribute("EliteClass") ~= "OcelotTrooper" then
		attachEliteTorso(character, helmetClassName)
	end
	-- Base Officers intentionally have no helmet, but their Shock variants use
	-- the helmet authored in elites/<team>/officer like every other class.
	if helmetEquipped and (elite or className ~= "Officer") then hideHair(character) end
end

return Appearance
