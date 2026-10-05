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

-- Mount the entire assembly, including descendants of a Part root. Preserve
-- articulated joints and only weld components which have no connection to it.
local function mountAssembly(character: Model, clone: Instance, anchor: BasePart, root: BasePart): boolean
	local parts, offsets, adjacency = {}, {}, {}
	if clone:IsA("BasePart") then table.insert(parts, clone) end
	for _, item in clone:GetDescendants() do
		if item:IsA("BasePart") then table.insert(parts, item) end
	end
	for _, part in parts do
		offsets[part] = root.CFrame:ToObjectSpace(part.CFrame)
		adjacency[part] = {}
	end
	for _, joint in clone:GetDescendants() do
		if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
			local p0, p1 = joint.Part0, joint.Part1
			-- Exported rigs can retain a reference to their original dummy body.
			-- Rebase that endpoint without changing the assembled rest pose.
			if adjacency[p1] and not adjacency[p0] then
				if joint:IsA("JointInstance") and p0 then
					joint.C0 = root.CFrame:ToObjectSpace(p0.CFrame) * joint.C0
				end
				joint.Part0 = root
				p0 = root
			elseif adjacency[p0] and not adjacency[p1] then
				-- An external mounting weld is replaced by our character weld.
				joint:Destroy()
			end
			if adjacency[p0] and adjacency[p1] and p0 ~= p1 then
				table.insert(adjacency[p0], {Part = p1, Joint = joint, Forward = true})
				table.insert(adjacency[p1], {Part = p0, Joint = joint, Forward = false})
			elseif p0 == p1 then
				joint:Destroy()
			end
		end
	end
	local connected = {}
	local function visit(part)
		if connected[part] then return end
		connected[part] = true
		for _, edge in adjacency[part] do
			if not connected[edge.Part] then
				local joint = edge.Joint
				if joint:IsA("JointInstance") then
					local transform = if joint:IsA("Motor6D") then joint.Transform else CFrame.identity
					local relative = joint.C0 * transform * joint.C1:Inverse()
					offsets[edge.Part] = offsets[part] * (if edge.Forward then relative else relative:Inverse())
				end
				visit(edge.Part)
			end
		end
	end
	visit(root)
	for _, part in parts do
		if not connected[part] then
			local weld = Instance.new("Weld")
			weld.Name = "EquipmentInternalWeld"
			weld.Part0, weld.Part1 = root, part
			weld.C0 = offsets[part]
			weld.Parent = root
			visit(part)
		end
	end
	for _, part in parts do
		part.CFrame = anchor.CFrame * offsets[part]
		part.Anchored = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0, weld.Part1 = anchor, root
	weld:SetAttribute("ClassAppearance", true)
	weld.Parent = anchor
	clone:SetAttribute("ClassAppearance", true)
	local data = character:FindFirstChild("CharacterData")
	clone.Parent = data and data:FindFirstChild("Equipment") or character
	return true
end

local function attachModel(character: Model, clone: Model, helmet: boolean)
	local primary = clone.PrimaryPart
		or childIgnoreCase(clone, if helmet then "Head" else "Torso")
		or childIgnoreCase(clone, "helmet")
	if not primary or not primary:IsA("BasePart") then primary = clone:FindFirstChildWhichIsA("BasePart", true) end
	local anchor = if helmet then character:FindFirstChild("Head") else
		(primary and character:FindFirstChild(primary.Name)) or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not primary or not anchor or not anchor:IsA("BasePart") then clone:Destroy(); return false end
	clone.PrimaryPart = primary
	if helmet then
		clone:SetAttribute("ClassHelmet", true)
		if not clone:FindFirstChild("Helmet") then
			local marker = Instance.new("Folder")
			marker.Name = "Helmet"
			marker.Parent = clone
		end
	end
	return mountAssembly(character, clone, anchor, primary)
end

local function attachPart(character: Model, clone: BasePart, helmet: boolean): boolean
	local headAttachment = helmet or string.lower(clone.Name) == "extralift" or string.lower(clone.Name):find("headset", 1, true)
	local anchor = if headAttachment then character:FindFirstChild("Head") else character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not anchor or not anchor:IsA("BasePart") then clone:Destroy(); return false end
	if helmet then clone:SetAttribute("ClassHelmet", true) end
	return mountAssembly(character, clone, anchor, clone)
end

local function attachRigGroup(character: Model, source: Instance): boolean
	local anchor = character:FindFirstChild(source.Name)
	if not anchor or not anchor:IsA("BasePart") then return false end

	local clone = source:Clone()
	clone:SetAttribute("ClassAppearance", true)
	clone:SetAttribute("ClassClothingRig", true)
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
	local clone = source:Clone()
	clone.Name = "EliteTorso"
	-- Radio equipment is authored separately, with a wire connecting both rigs.
	local headsetSource = childIgnoreCase(source.Parent, string.lower(className or "") .. "_headset")
	if headsetSource then
		local headset = headsetSource:Clone()
		local copies = {[source] = clone, [headsetSource] = headset}
		local function mapTree(original, copy)
			for index, child in original:GetChildren() do
				local copiedChild = copy:GetChildren()[index]
				if copiedChild then
					copies[child] = copiedChild
					mapTree(child, copiedChild)
				end
			end
		end
		mapTree(source, clone)
		mapTree(headsetSource, headset)
	local mounted = if clone:IsA("BasePart") then attachPart(character, clone, false)
		elseif clone:IsA("Model") then attachModel(character, clone, false) else false
	if not mounted then clone:Destroy(); return false end
		if headset:IsA("BasePart") then attachPart(character, headset, false)
		elseif headset:IsA("Model") then
			local head = character:FindFirstChild("Head")
			local root = headset.PrimaryPart or headset:FindFirstChildWhichIsA("BasePart", true)
			if head and root then mountAssembly(character, headset, head, root) else headset:Destroy() end
		else headset:Destroy() end
		for original, copy in copies do
			if original:IsA("Beam") then
				copy.Attachment0 = copies[original.Attachment0]
				copy.Attachment1 = copies[original.Attachment1]
			end
		end
	else
	local mounted = if clone:IsA("BasePart") then attachPart(character, clone, false)
		elseif clone:IsA("Model") then attachModel(character, clone, false) else false
	if not mounted then clone:Destroy(); return false end
	end
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
		local preservedRig = child.Parent
		while preservedRig and preservedRig ~= character and not preservedRig:GetAttribute("ClassClothingRig") do
			preservedRig = preservedRig.Parent
		end
		local clothing = child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic")
		if child:GetAttribute("ClassAppearance") and not (equipmentOnly and (clothing or child:GetAttribute("ClassClothingRig") or (preservedRig and preservedRig:GetAttribute("ClassClothingRig")))) then
			child:Destroy()
		end
	end
	restoreHair(character)

	if elite and not equipmentOnly then
		local baseOutfit = Appearance.GetOutfit(teamName, helmetClassName, false)
		if baseOutfit then
			for _, source in baseOutfit:GetDescendants() do
				if source:IsA("Shirt") or source:IsA("Pants") or source:IsA("ShirtGraphic") then
					for _, existing in character:GetChildren() do
						if existing.ClassName == source.ClassName then existing:Destroy() end
					end
					local clothing = source:Clone()
					clothing:SetAttribute("ClassAppearance", true)
					clothing.Parent = character
				end
			end
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local flatHelmet = attachFlatHelmet(character, outfit, helmetClassName)
	local helmetEquipped = flatHelmet
	local nestedOutfit = childIgnoreCase(outfit, "outfit")
	if nestedOutfit and not equipmentOnly then
		attachRigOutfit(character, nestedOutfit)
	end
	local outfitCopy = outfit:Clone()
	for _, source in outfitCopy:GetChildren() do
		if string.lower(source.Name) == "outfit" then continue end
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
			local clone = source
			clone:SetAttribute("ClassAppearance", true)
			local helmet = isHelmet(clone)
			if equipmentOnly and not helmet and string.lower(clone.Name) ~= "extralift" then
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
			local clone = source
			local helmet = isHelmet(clone)
			if equipmentOnly and not helmet and string.lower(clone.Name) ~= "extralift" then
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
	outfitCopy:Destroy()
	if elite and character:GetAttribute("EliteClass") ~= "OcelotTrooper" then
		attachEliteTorso(character, helmetClassName)
	end
	-- Base Officers intentionally have no helmet, but their Shock variants use
	-- the helmet authored in elites/<team>/officer like every other class.
	if helmetEquipped and (elite or className ~= "Officer") then hideHair(character) end
	local cosmetics = require(ReplicatedStorage.Shared.Library.CosmeticAppearance)
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	if player then cosmetics.Apply(character, cosmetics.Data(player)) end
end

return Appearance
