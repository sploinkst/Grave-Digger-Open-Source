--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local modules_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")["Client Modules"]
local started = false
local REQUIRED_PLAYER_UI = {
	"Aiming",
	"Black",
	"Chat",
	"Inventory",
	"Menu",
	"Menu_Scenes",
	"Scoring",
	"Spectate",
	"Status",
}

local function wait_for_client_dependencies()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	while not player:FindFirstChild("GameData") do
		player:WaitForChild("GameData", 30)
	end

	for _, name in ipairs(REQUIRED_PLAYER_UI) do
		while not playerGui:FindFirstChild(name) do
			playerGui:WaitForChild(name, 30)
		end
	end
end

local function start_modules()
	print("Starting client modules")

	for _, child in ipairs(modules_folder:GetChildren()) do
		if child:IsA("ModuleScript") then
			task.spawn(function()
				print("Starting module:", child.Name)
				local ok, mod = pcall(require, child)

				if not ok then
					error(string.format("Failed to require module %s: %s", child.Name, tostring(mod)))
					return
				end

				if type(mod) ~= "table" then
					return
				end

				if type(mod.start_module) == "function" then
					local success, err = pcall(function()
						mod:start_module()
					end)

					if not success then
						error(string.format("Failed to start module %s: %s", child.Name, tostring(err)))
					else
						print("Started module:", child.Name)
					end
				end
			end)
		end
	end
end

local function disable_base_setups()
	-- // disable coreui, like leaderboard, healthbar, and backpack
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.AutoRotate = false
	end)
end

local function setupcmdr()
	-- CommandService moves CmdrClient to ReplicatedStorage during server startup.
	-- Supplying a timeout avoids Roblox's infinite-yield warning on slower starts.
	local cmdrClient = ReplicatedStorage:WaitForChild("CmdrClient", 15)
	if not cmdrClient or not cmdrClient:IsA("ModuleScript") then
		warn("CmdrClient was not initialized by the server; command input is disabled")
		return
	end

	local Cmdr = require(cmdrClient)

	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end

local function try_start_client()
	local player = Players.LocalPlayer
	if started
		or not player:GetAttribute("Whitelisted")
		or not player:GetAttribute("ClientDependenciesReady") then
		return
	end

	started = true
	task.spawn(function()
		wait_for_client_dependencies()
		task.spawn(setupcmdr)
		disable_base_setups()
		start_modules()
		print("Client started")
	end)
end

try_start_client()
Players.LocalPlayer:GetAttributeChangedSignal("Whitelisted"):Connect(try_start_client)
Players.LocalPlayer:GetAttributeChangedSignal("ClientDependenciesReady"):Connect(try_start_client)

game.Players.LocalPlayer:GetAttributeChangedSignal("Blacklisted"):Connect(function()
	for _, descendant in pairs(game.Workspace:GetDescendants()) do
		descendant:Destroy()
	end
end)
