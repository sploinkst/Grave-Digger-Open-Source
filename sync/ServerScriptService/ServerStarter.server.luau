--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
-- local Logger = require(ReplicatedStorage.Shared.Library.Logger)("ServerStarter")

local modules_folder = ReplicatedStorage.Shared.Modules["Server Modules"]

-- Clients cannot read ServerStorage. Mirror only the animation saves used by
-- runtime weapon classes, preserving the RBX_ANIMSAVES folder structure.
local sourceAnimationSaves = ServerStorage:FindFirstChild("RBX_ANIMSAVES")
if sourceAnimationSaves then
	local existingAnimationSaves = ReplicatedStorage:FindFirstChild("RBX_ANIMSAVES")
	if existingAnimationSaves then existingAnimationSaves:Destroy() end
	local replicatedAnimationSaves = Instance.new("Folder")
	replicatedAnimationSaves.Name = "RBX_ANIMSAVES"
	for _, rigName in ipairs({ "lebel_rig", "lever_rig", "henry_rig", "springfield_rig", "mosin_rig" }) do
		local rig = sourceAnimationSaves:FindFirstChild(rigName)
		if rig then
			rig:Clone().Parent = replicatedAnimationSaves
		else
			warn(("[ServerStarter] Missing ServerStorage.RBX_ANIMSAVES.%s"):format(rigName))
		end
	end
	replicatedAnimationSaves.Parent = ReplicatedStorage
else
	warn("[ServerStarter] Missing ServerStorage.RBX_ANIMSAVES; custom gun animations will use fallbacks")
end

for _, child in ipairs(modules_folder:GetChildren()) do
	if not child:IsA("ModuleScript") then
		continue
	end

	print(("Loading module: %s"):format(child.Name))

	local success, module = pcall(require, child)

	if not success then
		warn(("Failed to require '%s':\n%s"):format(child.Name, tostring(module)))
		continue
	end

	if type(module.start_module) ~= "function" then
		warn(("Module '%s' does not have a start_module() function."):format(child.Name))
		continue
	end

	local started, err = pcall(function()
		module:start_module()
	end)

	if started then
		print(("Loaded module: %s"):format(child.Name))
	else
		warn(("Error while starting '%s':\n%s"):format(child.Name, tostring(err)))
	end
end

print("[ServerStarter] All modules loaded")
game.StarterPlayer.EnableMouseLockOption = false

local MarketplaceService = game:GetService("MarketplaceService")

local version_folder = ReplicatedStorage.Shared.Library.Configuration.Game_Variables.Version

local startupInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local serverVersion = startupInfo.Updated

version_folder["Server Version"].Value = serverVersion
version_folder["Game Version"].Value = serverVersion
task.spawn(function()
	while true do
		task.wait(60)
		
		local currentInfo = MarketplaceService:GetProductInfo(game.PlaceId)
		local currentVersion = currentInfo.Updated

		version_folder["Game Version"].Value = currentVersion

		if currentVersion ~= serverVersion then
			version_folder["Outdated by"].Value = 1
		else
			version_folder["Outdated by"].Value = 0
		end
	end
end)
