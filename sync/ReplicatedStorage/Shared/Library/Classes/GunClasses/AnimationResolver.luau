-- Fallback for legacy authored animations.
-- Published AnimationIds are always preferred; nested KeyframeSequences are
-- registered only when the wrapper has no usable ID.
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local sequenceCache: { [KeyframeSequence]: Animation } = {}

local function hasUploadedId(animation: Animation): boolean
	local id = animation.AnimationId
	return id ~= "" and id ~= "rbxassetid://0" and id ~= "0"
end

local function normalize(name: string): string
	local normalized = name:lower():gsub("[^%w]", "")
	return normalized
end

local function fallbackSequence(
	wrapper: Instance,
	gunType: string?,
	bindingName: string?
): KeyframeSequence?
	local toolAnimations = ReplicatedStorage:FindFirstChild("ToolAnimations")
	local folder = toolAnimations and gunType and toolAnimations:FindFirstChild(gunType)

	if folder then
		local wanted = { normalize(wrapper.Name) }
		if bindingName then
			table.insert(wanted, normalize(bindingName))
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("KeyframeSequence") then
				local candidate = normalize(descendant.Name)
				for _, name in wanted do
					if candidate == name then
						return descendant
					end
				end
			end
		end
	end

	local exact = wrapper:FindFirstChild(wrapper.Name)
	if exact and exact:IsA("KeyframeSequence") then
		return exact
	end

	return wrapper:FindFirstChildWhichIsA("KeyframeSequence", true)
end

local function resolve(wrapper: Instance, gunType: string?, bindingName: string?): Animation?
	if wrapper:IsA("Animation") and hasUploadedId(wrapper) then
		return wrapper
	end

	local sequence = if wrapper:IsA("KeyframeSequence") then wrapper else fallbackSequence(wrapper, gunType, bindingName)
	if not sequence then
		return nil
	end

	local cached = sequenceCache[sequence]
	if cached then
		return cached
	end

	-- Roblox only exposes local sequence registration in Studio. Live games must
	-- use the uploaded AnimationId on the wrapper.
	if not RunService:IsStudio() then
		return nil
	end

	local ok, id = pcall(function()
		return KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	end)

	if not ok or type(id) ~= "string" or id == "" then
		warn(("Animation fallback failed for %s: %s"):format(wrapper:GetFullName(), tostring(id)))
		return nil
	end

	local runtime = Instance.new("Animation")
	runtime.Name = wrapper.Name
	runtime.AnimationId = id
	sequenceCache[sequence] = runtime
	return runtime
end

return {
	Resolve = resolve,
	HasUploadedId = hasUploadedId,
}
