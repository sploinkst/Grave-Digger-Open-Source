-- Read-only audit of the actual place assets. Run from Studio's command bar.
local Shared = game:GetService("ReplicatedStorage").Shared
local Ids = require(script.Parent.WeaponIds)
local Stats = require(script.Parent.WeaponModStats)
local Behavior = require(script.Parent.WeaponModBehavior)
local Appearance = require(script.Parent.WeaponModAppearance)
local ModelRules = require(script.Parent.WeaponModModelRules)
local Audit = {}

local function named(folder, names)
	if not folder then return nil end
	for _, name in ipairs(names) do
		for _, child in ipairs(folder:GetChildren()) do
			if child.Name:lower() == name:lower() then return child end
		end
	end
	return nil
end

function Audit.Run()
	local assets = Shared.Assets
	local guns = assets:FindFirstChild("Guns")
	local models = guns and guns:FindFirstChild("ToolModels")
	local equipment = assets:FindFirstChild("Equipment")
	local animations = assets:FindFirstChild("Animations")
	local tools = animations and animations:FindFirstChild("Tools")
	local clips = tools and tools:FindFirstChild("Guns")
	local sounds = assets:FindFirstChild("Sounds")
	local report = {}
	for weapon, mod in pairs(Stats) do
		local model = Appearance.Model(models, weapon, equipment)
		local config = {}; Behavior.Configure(config, mod.variant)
		local folder = named(clips, Ids.Aliases(Ids.AssetName(weapon)))
		local missing = {}
		if not model then table.insert(missing, "weapon model")
		elseif not Appearance.Root(model) then table.insert(missing, "weapon attachment root") end
		if not folder then table.insert(missing, "animation folder") end
		local required = {}
		for _, clip in pairs(config.AnimationMap) do
			if type(clip) == "string" then required[clip] = true end
		end
		if mod.variant == "enfield" then
			for _, clip in ipairs({"bipod_aim", "bipod_fire", "bipod_cycle"}) do required[clip] = true end
			for _, prefix in ipairs({"bipod_deploy", "bipod_undeploy"}) do
				for index = 1, 4 do
					local sound = sounds and sounds:FindFirstChild(prefix .. index, true)
					if not sound or not sound:IsA("Sound") then table.insert(missing, prefix .. index) end
				end
			end
		end
		for clip in pairs(required) do
			local asset = named(folder, {clip})
			if not asset or not (asset:IsA("Animation") or asset:IsA("KeyframeSequence")) then
				table.insert(missing, "animation: " .. clip)
			end
		end
		local dedicated = model and Ids.Canonical(model.Name) == weapon or false
		local tagged = model and model:FindFirstChild("Variants") ~= nil or false
		if model then
			for _, object in ipairs(model:GetDescendants()) do
				if type(object:GetAttribute("WeaponModification")) == "string" then tagged = true end
			end
		end
		local rule = ModelRules.Definitions[mod.variant]
		if model and rule and not dedicated then
			local paths = {}
			for _, property in ipairs({"Show", "Hide", "Remove"}) do
				for _, path in ipairs(rule[property] or {}) do paths[path] = true end
			end
			for _, property in ipairs({"Color", "BrickColor"}) do
				for path in pairs(rule[property] or {}) do paths[path] = true end
			end
			for path in pairs(paths) do
				if not ModelRules.Find(model,path) then table.insert(missing, "mod geometry: " .. path) end
			end
			if rule.Muzzle and not ModelRules.Find(model,"special.altmuzzle") then
				table.insert(missing,"mod geometry: special.altmuzzle")
			end
		end
		local geometry = dedicated and "dedicated model" or tagged and "shared model with visibility groups"
			or "shared model with master geometry rules"
		table.sort(missing)
		table.insert(report, {Weapon=weapon, Model=model and model:GetFullName() or "MISSING", Geometry=geometry, Missing=missing})
	end
	table.sort(report, function(a, b) return a.Weapon < b.Weapon end)
	for _, row in ipairs(report) do
		print("[WeaponModAudit] " .. row.Weapon .. " | " .. row.Model .. " | " .. row.Geometry)
		for _, missing in ipairs(row.Missing) do warn("[WeaponModAudit] " .. row.Weapon .. " missing " .. missing) end
	end
	return report
end

return Audit
