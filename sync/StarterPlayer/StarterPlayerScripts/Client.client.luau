--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local modules_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")["Client Modules"]
local started = false

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
	local replicatedstorage_service = game:GetService("ReplicatedStorage")
	local Cmdr = require(replicatedstorage_service:WaitForChild("CmdrClient"))

	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end

if game.Players.LocalPlayer:GetAttribute("Whitelisted") and started == false then
	started = true
	setupcmdr()
	disable_base_setups()
	start_modules()
	print("Client started")
end

game.Players.LocalPlayer:GetAttributeChangedSignal("Whitelisted"):Connect(function()
	if game.Players.LocalPlayer:GetAttribute("Whitelisted") and started == false then
		started = true
		setupcmdr()
		disable_base_setups()
		start_modules()
	end
end)

game.Players.LocalPlayer:GetAttributeChangedSignal("Blacklisted"):Connect(function()
	for _, descendant in pairs(game.Workspace:GetDescendants()) do
		descendant:Destroy()
	end
end)