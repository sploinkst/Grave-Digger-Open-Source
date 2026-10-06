local Assets = game:GetService("ReplicatedStorage").Shared.Assets
local GunloadingSounds = {}

-- Animation cues name a family (rifleinsert, spin_main, etc.) or an
-- explicit clip. Only numeric variants belong to a family.
local function choose(folder, name)
	if not folder then return nil end
	local exact = folder:FindFirstChild(name, true)
	if exact and exact:IsA("Sound") then return exact end
	local variants = {}
	for _, child in ipairs(folder:GetDescendants()) do
		if child:IsA("Sound") and child.Name:sub(1, #name) == name then
			local suffix = child.Name:sub(#name + 1)
			if suffix:match("^%d+$") then table.insert(variants, child) end
		end
	end
	if #variants > 0 then return variants[math.random(1, #variants)] end
	return nil
end

function GunloadingSounds.Find(name)
	local sounds = Assets:FindFirstChild("Sounds")
	local gunSounds = sounds and sounds:FindFirstChild("Guns")
	local shared = gunSounds and (gunSounds:FindFirstChild("Shared") or gunSounds:FindFirstChild("shared"))
	local gsfx = shared and (shared:FindFirstChild("gsfx") or shared:FindFirstChild("Gsfx"))
	local sound = choose(gsfx, name)
	if sound then return sound end
	local gameSounds = sounds and sounds:FindFirstChild("Game")
	local loading = gameSounds and gameSounds:FindFirstChild("Gunloading")
	local loadingSound = choose(loading, name) or choose(shared, name)
	if loadingSound then return loadingSound end
	-- These lever cues are shared by Crestfall and Auclair's authored clips.
	if name:match("^lever_") then
		return choose(gunSounds and gunSounds:FindFirstChild("CrestfallRifle"), name)
	end
	return nil
end

return GunloadingSounds
