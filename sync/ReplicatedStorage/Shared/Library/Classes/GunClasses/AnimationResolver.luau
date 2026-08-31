-- Adapts Studio's saved KeyframeSequences into Animations that BaseTool can load.
-- The server mirrors the selected rigs from ServerStorage.RBX_ANIMSAVES.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local replicatedSaves = ReplicatedStorage:FindFirstChild("RBX_ANIMSAVES")
	or ReplicatedStorage:WaitForChild("RBX_ANIMSAVES", 15)
local registeredSequences: { [KeyframeSequence]: Animation } = {}

local function normalize(name: string): string
	local normalized = string.lower(name):gsub("[^%w]", "")
	return normalized
end

local function findAnimationSource(source: Instance, candidate: string): Instance?
	local exact = source:FindFirstChild(candidate, true)
	if exact then return exact end

	local wanted = normalize(candidate)
	for _, descendant in source:GetDescendants() do
		if normalize(descendant.Name) == wanted
			and (descendant:IsA("Animation") or descendant:IsA("KeyframeSequence")) then
			return descendant
		end
	end
	return nil
end

-- Exact animation vocabulary exposed by lebel_rig. Do not add aliases here:
-- weapon-specific names belong in that weapon's class.
local PRIMARY_CANDIDATES: { [string]: { string } } = {
	Aim = { "aim" },
	Aim_Left = { "aim_left" },
	Aim_Normal = { "aim_normal" },
	Alt_Mode_Off = { "alt_mode_off" },
	Alt_Mode_On = { "alt_mode_on" },
	Alt_Toggled_Off = { "alt_toggled_off" },
	Alt_Melee1 = { "altmelee1" },
	Alt_Melee2 = { "altmelee2" },
	Check = { "check" },
	Check_Empty = { "check_empty" },
	Cycle = { "cycle" },
	Draw = { "draw" },
	Fire = { "fire" },
	Fire_Empty = { "fire_empty" },
	Fire_Empty_Left = { "fire_empty_left" },
	Fire_Last = { "fire_last" },
	Fire_Last_Left = { "fire_last_left" },
	Fire_Left = { "fire_left" },
	Hipfire = { "hipfire" },
	Hold = { "held" },
	Locked = { "locked" },
	Melee1 = { "melee1" },
	Melee2 = { "melee2" },
	Quickdraw = { "quickdraw" },
	Quickdraw_Start = { "quickdraw_start" },
	Reload_Clip = { "reload_clip" },
	Reload_Clip_Empty = { "reload_clip_empty" },
	Reload_Clip_Start_Empty = { "reload_clip_start_empty" },
	Reload_Clip_Start_Empty_Novet = { "reload_clip_start_empty_novet" },
	Reload_Clip_Start_One = { "reload_clip_start_one" },
	Reload_Alt = { "reload_alt" },
	Reload_Alt_Extra = { "reload_alt_extra" },
	Reload_Empty = { "reload_empty" },
	Reload_Empty_Vet = { "reload_empty_vet" },
	Reload_End = { "reload_end" },
	Reload_End_Locked = { "reload_end_locked" },
	Reload_End_Vet = { "reload_end_vet" },
	Reload_Full = { "reload_full" },
	Reload_Full_Vet = { "reload_full_vet" },
	Reload_Heavyloop = { "reload_heavyloop" },
	Reload_Loop = { "reload_loop" },
	Reload_Loop_After = { "reload_loop_after" },
	Reload_Loop_After_Twice = { "reload_loop_after_twice" },
	Reload_One = { "reload_one" },
	Reload_One_Vet = { "reload_one_vet" },
	Reload_Partial = { "reload_partial" },
	Reload_Start = { "reload_start" },
	Reload_Start_Vet = { "reload_start_vet" },
	Shoot = { "shoot" },
	Shoot_Empty = { "shoot_empty" },
	Short = { "short" },
	Sprint = { "sprint" },
	Sprint_Normal = { "sprint_normal" },
	Unequip = { "unequip" },
}

local function registerSequence(sequence: KeyframeSequence): Animation?
	local cached = registeredSequences[sequence]
	if cached then return cached end

	local success, contentId = pcall(function()
		return KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	end)
	if not success then
		warn(("Could not register gun animation %q: %s"):format(sequence.Name, tostring(contentId)))
		return nil
	end

	local animation = Instance.new("Animation")
	animation.Name = sequence.Name
	animation.AnimationId = contentId
	registeredSequences[sequence] = animation
	return animation
end

return function(rigName: string, legacySource: Instance?, fallbackSource: Instance?)
	local savedRig = replicatedSaves and replicatedSaves:FindFirstChild(rigName)

	return function(names: string | { string }, fallbackName: string): Animation?
		local candidates: { string } = {}
		if type(names) == "string" then
			candidates = PRIMARY_CANDIDATES[names] or {}
		else
			-- Explicit arrays are weapon-owned exact names. They intentionally do
			-- not expand PRIMARY_CANDIDATES or borrow another weapon's aliases.
			candidates = names
		end
		local sources: { Instance } = {}
		if savedRig then table.insert(sources, savedRig) end
		if legacySource and legacySource ~= savedRig then table.insert(sources, legacySource) end

		for _, source in ipairs(sources) do
			for _, name in ipairs(candidates) do
				local found = findAnimationSource(source, name)
				if found and found:IsA("Animation") then return found end
				if found and found:IsA("KeyframeSequence") then
					local animation = registerSequence(found)
					if animation then return animation end
				end
			end
		end

		if fallbackSource then
			local fallback = fallbackSource:FindFirstChild(fallbackName, true)
			if fallback and fallback:IsA("Animation") then return fallback end
		end

		warn(("Missing optional animation %q for RBX_ANIMSAVES.%s"):format(fallbackName, rigName))
		return nil
	end
end
