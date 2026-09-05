--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
-- local Logger = require(ReplicatedStorage.Shared.Library.Logger)("ServerStarter")

local modules_folder = ReplicatedStorage.Shared.Modules["Server Modules"]

-- Publish the authored tool folders once; clients register sequences on demand.
local authoredAnimations = ServerStorage:FindFirstChild("animations")
local authoredTools = authoredAnimations and authoredAnimations:FindFirstChild("tools")
local toolAnimations = Instance.new("Folder")
toolAnimations.Name = "ToolAnimations"
if authoredTools then
	for _, folder in authoredTools:GetChildren() do
		folder:Clone().Parent = toolAnimations
	end
else
	warn("[ServerStarter] Missing ServerStorage.animations.tools; dynamic tool animations are unavailable")
end
local previousToolAnimations = ReplicatedStorage:FindFirstChild("ToolAnimations")
if previousToolAnimations then previousToolAnimations:Destroy() end
toolAnimations.Parent = ReplicatedStorage

-- Movement clips are authored alongside the shared restock animation.
local sharedSource = authoredAnimations and authoredAnimations:FindFirstChild("shared")
local movementAnimations = Instance.new("Folder")
movementAnimations.Name = "MovementAnimations"
for _, name in {"walk_forward", "walk_injured", "walk_left", "walk_right",
	"sprinting_arms", "sprinting_full", "sprinting_lean", "leg_aiming"} do
	local clip = sharedSource and sharedSource:FindFirstChild(name)
	if clip then clip:Clone().Parent = movementAnimations
	else warn("[ServerStarter] Missing shared animation: " .. name) end
end
local previousMovement = ReplicatedStorage:FindFirstChild("MovementAnimations")
if previousMovement then previousMovement:Destroy() end
movementAnimations.Parent = ReplicatedStorage

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
