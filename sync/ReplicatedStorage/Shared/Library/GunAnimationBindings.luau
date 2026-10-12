-- Fill authored actions for all firearms, including native sequence-only folders.
local RS = game:GetService("ReplicatedStorage")
local Ids = require(script.Parent.WeaponIds)
local Bindings = {}
local aliases = {
	Hold = {"held", "hold"}, Draw = {"draw", "steyrdraw"},
	Fire = {"fire", "firing"}, Fire_Left = {"fire_left", "firing_left"},
	Cycle = {"cycle", "reload_bolt"}, Reload_Loop = {"reload_loop", "reload_one", "reload_dual_vet"},
	Reload_Full = {"reload_full", "reload_clip"},
	Hip_Aim = {"alt_changeaim"}, Hip_Aim_Left = {"alt_changeaim_left"},
	Hip_Fire = {"alt_changefire"}, Hip_Fire_Left = {"alt_changefire_left"},
	Alt_Melee1 = {"altmelee1", "meleealt1"}, Alt_Melee2 = {"altmelee2", "meleealt2"},
	ShieldPlace = {"shieldplace"},
}
local function normalize(name) return name:lower():gsub("[^%w]", "") end
local function actionName(name)
	return (name:gsub("^%l", string.upper):gsub("_(%l)", function(c) return "_" .. c:upper() end))
end
function Bindings.Prepare(controller)
	if not controller.IsFirearm then return end
	local assets = RS.Shared.Assets
	local animations = assets:FindFirstChild("Animations")
	local tools = animations and animations:FindFirstChild("Tools")
	local guns = tools and tools:FindFirstChild("Guns")
	local legacy = RS:FindFirstChild("ToolAnimations")
	local names = {controller.className, controller.AnimationGunType, Ids.MasterSourceName(controller.className), Ids.AssetName(controller.className), Ids.Canonical(Ids.AssetName(controller.className))}
	for _, alias in ipairs(Ids.Aliases(controller.className)) do table.insert(names, alias) end
	local folder
	for _, root in ipairs({guns or false, legacy or false}) do
		if root then
			for _, name in ipairs(names) do
				local candidate = root:FindFirstChild(name)
				if candidate and (candidate:FindFirstChildWhichIsA("KeyframeSequence", true) or candidate:FindFirstChildWhichIsA("Animation", true)) then folder = candidate; break end
			end
		end
		if folder then break end
	end
	if not folder then return end
	if type(controller.animations)~="table" then controller.animations={} end
	local clips = {}
	for _, child in ipairs(folder:GetChildren()) do
		local clip = (child:IsA("Animation") or child:IsA("KeyframeSequence")) and child
			or child:FindFirstChildWhichIsA("Animation", true) or child:FindFirstChildWhichIsA("KeyframeSequence", true)
		if clip then
			clips[normalize(child.Name)] = clip
			local action = actionName(child.Name)
			if not controller.AnimationOmissions or not controller.AnimationOmissions[action] then
				controller.animations[action] = controller.animations[action] or clip
			end
		end
	end
	for action, clip in pairs(controller.animations) do
		local native = clips[normalize(clip.Name)]
		if native then controller.animations[action] = native end
	end

	for action, sources in pairs(aliases) do
		if not controller.AnimationOmissions or not controller.AnimationOmissions[action] then
			if not controller.animations[action] then
				for _, name in ipairs(sources) do
					local clip = clips[normalize(name)]
					if clip then controller.animations[action] = clip; break end
				end
			end
		end
	end
end
return Bindings
