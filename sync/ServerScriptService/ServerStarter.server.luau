--!strict
local Players = game:GetService("Players")
Players.CharacterAutoLoads = false

local function WatchPlayerLoading(player: Player)
	task.delay(120, function()
		if player.Parent == Players and
			(not player:GetAttribute("PlayerDataReady") or not player:GetAttribute("PlayerSetupReady")) then
			player:Kick(" Data failed to load. ")
		end
	end)
end
Players.PlayerAdded:Connect(WatchPlayerLoading)
for _, player in Players:GetPlayers() do
	WatchPlayerLoading(player)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
-- local Logger = require(ReplicatedStorage.Shared.Library.Logger)("ServerStarter")

local modules_folder = ReplicatedStorage.Shared.Modules["Server Modules"]

-- Client modules may be required before DataService depending on Explorer
-- child order. Publish core remotes before any service starts so requiring a
-- client module can never hang waiting for a service-owned RemoteEvent.
local eventsFolder = ReplicatedStorage.Shared.Library:WaitForChild("Events")
if not eventsFolder:FindFirstChild("Datapush") then
	local datapush = Instance.new("RemoteEvent")
	datapush.Name = "Datapush"
	datapush.Parent = eventsFolder
end
if not eventsFolder:FindFirstChild("Presentation") then
	local presentation = Instance.new("RemoteEvent")
	presentation.Name = "Presentation"
	presentation.Parent = eventsFolder
end
for _, name in {"BuffAbility", "HunterKitAbility", "MedicalSyrettes", "StimulantCompounds", "MedicalAction", "ConstructionAction", "UtilityAction", "OrdnanceAction", "ReconAction", "ShieldAction", "MatchControl"} do
	if not eventsFolder:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = eventsFolder
	end
end
if not eventsFolder:FindFirstChild("MountedWeapon") then
	local mountedWeapon = Instance.new("RemoteEvent")
	mountedWeapon.Name = "MountedWeapon"
	mountedWeapon.Parent = eventsFolder
end
if not eventsFolder:FindFirstChild("Compass") then
	local compass = Instance.new("RemoteEvent")
	compass.Name = "Compass"
	compass.Parent = eventsFolder
end

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
local movementNames={
 walk_forward={"walk_forward","walk_forward_FootstepsNew"},
 walk_injured={"walk_injured","walk_injured_new"},
 walk_left={"walk_left","walk_left_FootstepsNew"},
 walk_right={"walk_right","walk_right_FootstepsNew"},
 sprinting_arms={"sprinting_arms"},
 sprinting_full={"sprinting_full","sprinting_full_FootstepsNews"},
 sprinting_lean={"sprinting_lean"},leg_aiming={"leg_aiming"},
 injured_left={"injured_left"},injured_right={"injured_right"},
}
local nativeAnimations=ReplicatedStorage.Shared.Assets:FindFirstChild("Animations")
for name,aliases in pairs(movementNames) do
 local clip
 for _,root in ipairs({sharedSource or false,authoredAnimations or false,nativeAnimations or false}) do
  if root then
   for _,alias in ipairs(aliases) do
    for _,candidate in ipairs(root:GetDescendants()) do
     if candidate.Name==alias and (candidate:IsA("Animation") or candidate:IsA("KeyframeSequence")) then clip=candidate;break end
    end
    if clip then break end
   end
  end
  if clip then break end
 end
 if clip then
  local clone=clip:Clone();clone.Name=name;clone.Parent=movementAnimations
 else warn("[ServerStarter] Missing movement animation: "..name.." ("..table.concat(aliases,", ")..")") end
end

local previousMovement = ReplicatedStorage:FindFirstChild("MovementAnimations")
if previousMovement then previousMovement:Destroy() end
movementAnimations.Parent = ReplicatedStorage

for _, child in ipairs(modules_folder:GetChildren()) do
	task.spawn(function()
		if not child:IsA("ModuleScript") then
			return
		end

		print(("Loading module: %s"):format(child.Name))

		local success, module = pcall(require, child)

		if not success then
			warn(("Failed to require '%s':\n%s"):format(child.Name, tostring(module)))
			return
		end

		if type(module) ~= "table" or type(module.start_module) ~= "function" then
            -- Helper modules are initialized by the service that owns them.
			return
		end

		local started, err = pcall(function()
			module:start_module()
		end)

		if started then
			print(("Loaded module: %s"):format(child.Name))
		else
			warn(("Error while starting '%s':\n%s"):format(child.Name, tostring(err)))
		end
	end)
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
