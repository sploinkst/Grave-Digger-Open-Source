local ResetManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InputManager = require(script.Parent.SettingsManager)


local Player = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Reset")

function ResetManager.start_module()
	InputManager.HookInput("Reset Character", function(_, pressed)
		
		if not pressed then return end 
		if Player.Character then
			RemoteEvent:FireServer()
		end
	end)
end
return ResetManager
