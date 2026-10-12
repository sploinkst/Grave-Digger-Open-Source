local Shared = game:GetService("ReplicatedStorage").Shared
local Classes = require(Shared.Library.ClassDefinitions)
local Ids = require(Shared.Library.WeaponIds)
local Mounts = require(Shared.Library.WeaponPreviewMounts)
local WeaponAppearance = require(script.Parent.PreviewWeaponAppearance)
local ModAppearance = require(Shared.Library.WeaponModAppearance)
local Equipment = {}

local assetAliases = {HeavyPickaxe="pickaxe", ConstructHammer="hammer", ReconKit="binocs", HunterKit="jaegerkit", StimulantCompounds="stims", PainkillerInjector="lancerstim", Medkit="firstaid"}

local function findAsset(folder, name)
	if not folder then return end
	for _, alias in {Ids.AssetName(name), Ids.Canonical(name), name, assetAliases[name] or name} do
		local found = folder:FindFirstChild(alias, true)
		if found and (found:IsA("Model") or found:IsA("BasePart") or found:IsA("Tool")) then return found end
	end
end

function Equipment.Items(player, className)
	className = className or Classes.Selected(player)
	local definition = Classes.Get(className)
	local loadout = Classes.GetLoadout(player, className)
	local items, slots, seen = {}, {}, {}
	local function add(name, slotNumber, repeated)
		if not name or name == "" then return end
		local id = Ids.Canonical(name)
		if id == "HeavyPickaxe" and className ~= "Rook" then return end
		if seen[id] and not repeated then return end
		seen[id] = true
		table.insert(items, id)
		table.insert(slots, slotNumber or 0)
	end
	local function slot(name)
		local value = loadout and loadout:FindFirstChild(name)
		return value and value.Value or ""
	end
	add(definition.FixedPrimary or (not definition.NoFirearms and slot("Primary")), 1)
	if not definition.NoFirearms then add(slot("Secondary"), 2, true) end
	add(slot("Melee") ~= "" and slot("Melee") or "Knife", 3)
	for _, name in definition.Tools or {} do add(name) end
	if definition.Equipment == "MiningBombLauncher" then add("RookLauncher") end
	-- Preserve carried utility tools, but do not bring the previous class's guns.
	local containers = {}
	if player.Character then table.insert(containers, player.Character) end
	local backpack = player:FindFirstChild("Backpack")
	if backpack then table.insert(containers, backpack) end
	for _, container in containers do
		if container then
			for _, tool in container:GetChildren() do
				if tool:IsA("Tool") then
					local weapon = tool:FindFirstChild("weapon")
					local name = Ids.Canonical(weapon and weapon.Value or tool.Name)
					local slotValue = tool:FindFirstChild("slot")
					if not slotValue or (slotValue.Value ~= "Primary" and slotValue.Value ~= "Secondary" and slotValue.Value ~= "Mining" and slotValue.Value ~= "Melee") then
						if Shared.Library.Classes.ToolClasses:FindFirstChild(name) then add(name) end
					end
				end
			end
		end
	end
	return items, slots
end

function Equipment.Apply(rig, player, className)
	if rig == player.Character then return end
	-- The master removes belt lanterns from the Loadout rig.
	for _, object in rig:GetDescendants() do
		local name = object.Name:lower()
		if name == "lantern" or name == "nationlantern" or name == "conscriptlantern" then object:Destroy() end
	end
	local old = rig:FindFirstChild("MenuWeapons")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "MenuWeapons"; folder.Parent = rig
	local guns = Shared.Assets:FindFirstChild("Guns")
	local models = guns and guns:FindFirstChild("ToolModels")
	local held = false
	local items, slots = Equipment.Items(player, className)
	for index, name in items do
		local slot = slots[index]
		local welds = Mounts[Ids.MasterSourceName(name)] or Mounts[assetAliases[name]] or {}
		local source, skin = WeaponAppearance.Model(models, name, welds, player.Team and player.Team.Name, player, math.clamp(slot, 1, 2))
		source = source or findAsset(models, name) or findAsset(Shared.Assets:FindFirstChild("Equipment"), name)
		if not source then warn("[Menu] Missing preview tool model: " .. name); continue end
		local clone = ModAppearance.Clone(source)
		clone.Name = name
		WeaponAppearance.Apply(clone, welds, skin, rig, name)
		local root = clone:IsA("BasePart") and clone or clone:FindFirstChild("hitbox", true)
			or clone:FindFirstChild(name .. "_Middle", true) or clone:FindFirstChild(name .. "_Hitbox", true) or clone:FindFirstChild("Handle", true)
			or clone:FindFirstChildWhichIsA("BasePart", true)
		if not root or not root:IsA("BasePart") then clone:Destroy(); continue end
		local holding = not held and (slot == 1 or slot == 2)
		local body = rig:FindFirstChild(holding and (welds.lefthand and "Left Arm" or "Right Arm") or (welds.holster_point or "Torso"))
		if not body then clone:Destroy(); continue end
		local c0, c1
		if holding then c0, c1 = welds.equipc0, welds.equipc1
		elseif slot == 2 then c0, c1 = welds.alt_holsterc0 or welds.holsterc0, welds.alt_holsterc1 or welds.holsterc1
		else c0, c1 = welds.holsterc0, welds.holsterc1 end
		if not c0 then
   warn("[Menu] Missing authored preview mount: " .. name)
   clone:Destroy(); continue
  end
		c1 = c1 or CFrame.identity
		if holding and welds.variant == "remington" then c1 = c1 * CFrame.new(-1, 0.5, 0) end
		local delta = body.CFrame * c0 * c1:Inverse() * root.CFrame:Inverse()
		local parts = clone:IsA("BasePart") and {clone} or {}
		for _, object in clone:GetDescendants() do
			if object:IsA("BasePart") then table.insert(parts, object)
			elseif object:IsA("LuaSourceContainer") or object:IsA("Sound") then object:Destroy()
			elseif object:IsA("Light") or object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then object.Enabled = false
			elseif object:IsA("JointInstance") or object:IsA("WeldConstraint") then
				object:Destroy() -- The menu displays a rigid model; rebuild its internal welds below.
			end
		end
		for _, part in parts do
			part.CFrame = delta * part.CFrame
			part.Anchored = false; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
			part.LocalTransparencyModifier = 0; part.Massless = true
			if part ~= root then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = root; weld.Part1 = part; weld.Parent = root
			end
		end
		local mount = Instance.new("Motor6D")
		mount.Name = holding and "weppreview" or slot == 3 and "knifesetup" or "holsterpreview"
		mount.Part0 = body; mount.Part1 = root; mount.C0 = c0; mount.C1 = c1; mount.Parent = root
		clone.Parent = folder
		WeaponAppearance.Sheath(rig, folder, name, welds, slot == 2,skin,player.Team)
		if holding then held = true end
	end
end

return Equipment
