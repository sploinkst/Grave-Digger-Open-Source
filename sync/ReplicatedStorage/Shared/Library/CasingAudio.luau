local RS = game:GetService("ReplicatedStorage")
local WeaponIds = require(script.Parent.WeaponIds)
local Playback = require(script.Parent.SoundPlayback)
local Audio = {}

function Audio.Family(partName, weaponName, override)
	if type(override) == "string" and override ~= "" then return override end
	local name = string.lower(partName or "")
	local weapon = WeaponIds.Canonical(weaponName)
	if name:find("glass", 1, true) or name:find("bottle", 1, true) then return "glass" end
	if name:find("cap", 1, true) then return "walkercap" end
	if name:find("clip", 1, true) then return weapon == "AdjudicatorRifle" and "rscclip" or "clip" end
	if name:find("mag", 1, true) then
		return (weapon == "LewisGun" or weapon == "StormRifle" or weapon == "WhisperFlyboyRifle"
			or weapon == "BrowningMachineGun" or name:find("large", 1, true)) and "largemag" or "mag"
	end
	if weapon == "KingslayerRevolver" then return "walkercap" end
	if weapon == "AntiMaterialRifle" or weapon == "RookLauncher" then return "large" end
	if weapon:find("Shotgun", 1, true) then return "shotgun" end
	if weapon:find("Revolver", 1, true) or weapon:find("Pistol", 1, true) then return "revolver" end
	return "rifle"
end

function Audio.Surface(material)
	local name = typeof(material) == "EnumItem" and material.Name or tostring(material)
	if name == "Wood" or name == "WoodPlanks" then return "wood" end
	if name == "Metal" or name == "CorrodedMetal" or name == "DiamondPlate" or name == "Foil" then return "metal" end
	return nil
end

local function choose(folder, prefix)
	local variants = {}
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Sound") and child.Name:sub(1, #prefix) == prefix
			and child.Name:sub(#prefix + 1):match("^%d+$") then
			table.insert(variants, child)
		end
	end
	return #variants > 0 and variants[math.random(1, #variants)] or nil
end

function Audio.Find(family, material)
	local root = RS.Shared.Assets:FindFirstChild("Sounds")
	local sounds = root and root:FindFirstChild("Guns")
	local folder = sounds and sounds:FindFirstChild("Casings")
	if not folder then return nil end
	local surface = Audio.Surface(material)
	return (surface and choose(folder, family .. "_" .. surface)) or choose(folder, family)
end

function Audio.Bind(part, family, owner)
	local played = false
	local connection
	connection = part.Touched:Connect(function(hit)
		if played or not hit or not hit.Parent or hit:IsDescendantOf(part) then return end
		if owner and owner.Character and hit:IsDescendantOf(owner.Character) then return end
		local model = hit:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then return end
		if hit:IsA("BasePart") and not hit.CanCollide then return end
		-- Terrain.Material is not the material at the point of contact.
		local material = hit.Material
		if hit == workspace.Terrain then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Include
			params.FilterDescendantsInstances = {workspace.Terrain}
			local result = workspace:Raycast(part.Position + Vector3.new(0, 0.5, 0), Vector3.new(0, -2, 0), params)
			if result then material = result.Material end
		end
		played = true
		connection:Disconnect()
		local sound = Audio.Find(family, material)
		if sound then Playback.Play(sound, part, {PitchVariation = 0.1}) end
	end)
	part.Destroying:Once(function() if connection.Connected then connection:Disconnect() end end)
end

return Audio
