-- @praxitos
-- Handles VoiceWheel

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
-- // Constants
local Player = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Library = Shared:WaitForChild("Library")
local Events = Library:WaitForChild("Events")
local VoiceComms = Events:WaitForChild("VoiceComms")

local Modules = Shared:WaitForChild("Modules"):WaitForChild("Client Modules")
local SettingsHandler = require(Modules:WaitForChild("SettingsManager"))

local ScreenGui = script.Parent
local HolderFrame = ScreenGui.Holder

-- // Variables
local BaseButtonSize = UDim2.new(0.5, 0, 0.5, 0)
local EnlargedButtonSize = UDim2.new(0.6, 0, 0.6, 0)

local Selected = nil

-- // Functions
local function DangerPing()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { Player.Character }

	local result = Workspace:Raycast(
		camera.CFrame.Position,
		camera.CFrame.LookVector * 1000,
		raycastParams
	)

	if not result then
		return
	end

	VoiceComms:FireServer("danger", {
		Position = result.Position
	})
end

local function Init()
	for _, voice in pairs(HolderFrame:GetChildren()) do
		if not string.find(voice.Name, "officer") then
			continue
		end

		if Player:GetAttribute("SelectedClass") ~= "Officer" then
			voice.Visible = false
		else
			voice.Visible = true
		end
	end

	SettingsHandler.HookInput("Voice Lines", function(input, IsPressed)
		if not Player.Character or Player.Character.Humanoid.Health <= 0 then return end
		
		if IsPressed then
			HolderFrame.Visible = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		else
			HolderFrame.Visible = false

			if Selected == "danger" then
				DangerPing()
			end

			if Player:GetAttribute("FreeLook") then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			else
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
			end
		end
	end)
end

local function HandleButtonsEnlargement()
	for _, voice in pairs(HolderFrame:GetChildren()) do
		voice.bar.button.MouseEnter:Connect(function()
			voice.bar.button.int_text.Size = EnlargedButtonSize
			Selected = voice.Name
		end)

		voice.bar.button.MouseLeave:Connect(function()
			voice.bar.button.int_text.Size = BaseButtonSize
			Selected = nil
		end)
	end
end

-- // Connections
Init()
HandleButtonsEnlargement()