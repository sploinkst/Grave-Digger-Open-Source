-- Adapts Studio's saved KeyframeSequences into Animations that BaseTool can load.
-- The server mirrors the selected rigs from ServerStorage.RBX_ANIMSAVES.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local replicatedSaves = ReplicatedStorage:FindFirstChild("RBX_ANIMSAVES")
	or ReplicatedStorage:WaitForChild("RBX_ANIMSAVES", 15)
local registeredSequences: { [KeyframeSequence]: Animation } = {}

-- Common action contract used by every rifle rig. New guns only need to call
-- the canonical action name; uncommon alt actions can still pass a custom
-- candidate list directly.
local PRIMARY_CANDIDATES: { [string]: { string } } = {
	Draw = { "draw", "raise", "aim" },
	Hold = { "held", "hold" },
	Unequip = { "unequip", "lower", "held" },
	Aim = { "aim" },
	Aim_Left = { "aim_left", "aim" },
	Fire = { "fire" },
	Fire_Left = { "fire_left", "fire" },
	Cycle = { "cycle", "charge_stop", "charge", "locked" },
	Charge = { "charge" },
	Charge_Stop = { "charge_stop", "held" },
	Reload_Empty = { "reload_empty", "reload_clip_start_empty", "reload_start" },
	Reload_Start = { "reload_start", "reload_clip_start_one", "reload_clip_start_empty" },
	Reload_Loop = { "reload_loop", "reload_clip", "reload_start" },
	Reload_End = { "reload_end", "held" },
	Check = { "check", "check_empty" },
	Melee1 = { "melee1", "meleealt1", "check" },
	Melee2 = { "melee2", "meleealt2", "check" },
	Short = { "short", "locked" },
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

return function(rigName: string, legacySource: Instance?, fallbackSource: Instance)
	local savedRig = replicatedSaves and replicatedSaves:FindFirstChild(rigName)

	return function(names: string | { string }, fallbackName: string): Animation
		local candidates = if type(names) == "string"
			then (PRIMARY_CANDIDATES[names] or { names })
			else names
		local sources: { Instance } = {}
		if savedRig then table.insert(sources, savedRig) end
		if legacySource and legacySource ~= savedRig then table.insert(sources, legacySource) end

		for _, source in ipairs(sources) do
			for _, name in ipairs(candidates) do
				local found = source:FindFirstChild(name)
				if found and found:IsA("Animation") then return found end
				if found and found:IsA("KeyframeSequence") then
					local animation = registerSequence(found)
					if animation then return animation end
				end
			end
		end

		return fallbackSource:FindFirstChild(fallbackName) :: Animation
	end
end
