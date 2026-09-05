-- Shared authored-animation lookup for all weapon controllers.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local toolAnimations = ReplicatedStorage:FindFirstChild("ToolAnimations")
if not toolAnimations and RunService:IsClient() then
	toolAnimations = ReplicatedStorage:WaitForChild("ToolAnimations", 15)
end
local registeredSequences: { [KeyframeSequence]: Animation } = {}
local sourceIndexes: { [Instance]: { [string]: Instance } } = {}

local function normalize(name: string): string
	local normalized = string.lower(name):gsub("[^%w]", "")
	return normalized
end

local function indexSource(source: Instance): { [string]: Instance }
	if sourceIndexes[source] then return sourceIndexes[source] end
	local index = {}
	for _, descendant in source:GetDescendants() do
		if descendant:IsA("Animation") or descendant:IsA("KeyframeSequence") then
			index[normalize(descendant.Name)] = descendant
		end
	end
	sourceIndexes[source] = index
	return index
end

local function findAnimationSource(source: Instance, candidate: string): Instance?
	return indexSource(source)[normalize(candidate)]
end

-- Shared controller vocabulary; unusual gameplay aliases stay in the weapon.
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

return function(gunType: string)
	local authored = toolAnimations and toolAnimations:FindFirstChild(gunType)
	if authored and next(indexSource(authored)) == nil then authored = nil end

	local function resolve(names: string | { string }, fallbackName: string): Animation?
		local candidates: { string } = {}
		if type(names) == "string" then
			candidates = PRIMARY_CANDIDATES[names] or {string.lower(names)}
		else
			-- Explicit arrays are weapon-owned exact names. They intentionally do
			-- not expand PRIMARY_CANDIDATES or borrow another weapon's aliases.
			candidates = names
		end
		local sources: { Instance } = {}
		if authored then table.insert(sources, authored) end

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

		warn(("Missing optional animation %q in ServerStorage.animations.tools.%s"):format(table.concat(candidates, "/"), gunType))
		return nil
	end

	-- Build the common bindings from the folder itself. New standard clips do
	-- not require another per-gun list, and absent optional clips stay absent.
	local function loadAnimations(overrides: { [string]: Animation }?): { [string]: Animation }
		local result = {}
		local source = authored
		if source then
			local controllerNames = {}
			for key, candidates in PRIMARY_CANDIDATES do
				for _, candidate in candidates do controllerNames[normalize(candidate)] = key end
			end
			for normalizedName, clip in indexSource(source) do
				local key = controllerNames[normalizedName] or clip.Name:gsub("[^_]+", function(word)
					return word:sub(1, 1):upper() .. word:sub(2):lower()
				end)
				local animation = if clip:IsA("Animation") then clip else registerSequence(clip)
				if animation then result[key] = animation end
			end
		end
		for key, animation in overrides or {} do result[key] = animation end
		return result
	end
	return resolve, loadAnimations
end
