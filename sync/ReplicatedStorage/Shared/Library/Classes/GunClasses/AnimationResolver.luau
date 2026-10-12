-- Fallback for legacy authored animations.
-- Studio uses authored sequences; live games use explicitly published IDs.
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local WeaponIds = require(script.Parent.Parent.Parent.WeaponIds)

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
	-- A borrowed wrapper must retain its own authored sequence and rig.
	local nested = wrapper:FindFirstChildWhichIsA("KeyframeSequence", true)
	if nested then return nested end
	local toolAnimations = ReplicatedStorage:FindFirstChild("ToolAnimations")
	local folder = toolAnimations and gunType and toolAnimations:FindFirstChild(gunType)
	if not folder and toolAnimations and gunType then
		for _, alias in ipairs(WeaponIds.Aliases(gunType)) do
			folder = toolAnimations:FindFirstChild(alias)
			if folder then break end
		end
	end

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
	local sequence = if wrapper:IsA("KeyframeSequence") then wrapper else fallbackSequence(wrapper, gunType, bindingName)
	local published = wrapper:GetAttribute("PublishedAnimationId") or (sequence and sequence:GetAttribute("PublishedAnimationId"))
	if not RunService:IsStudio() or not sequence then
		if published and tostring(published):match("%d+") then
			local animation = Instance.new("Animation")
			animation.Name = wrapper.Name
			animation.AnimationId = "rbxassetid://" .. tostring(published):match("%d+")
			return animation
		end
		if wrapper:IsA("Animation") and hasUploadedId(wrapper) then return wrapper end
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
