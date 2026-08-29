--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
-- local Logger = require(ReplicatedStorage.Shared.Library.Logger)("ServerStarter")

local modules_folder = ReplicatedStorage.Shared.Modules["Server Modules"]

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