--!strict
--!optimize 2

local UserInputService = game:GetService("UserInputService")

local game_points = game:GetService("Workspace").Game_Details.Main_Game.Points

local BaseTool = require(script.Parent.Parent.BaseTool)

local Compass = {}
Compass.__index = Compass
Compass.className = "Compass"

setmetatable(Compass, { __index = BaseTool })

-- // Types
export type Compass = BaseTool.BaseTool & {
	className: "Compass",
	name: string,
}

-- // Constructor
function Compass.new(info: { name: string }): Compass
	-- Proper inheritance: build from BaseTool first
	local self = BaseTool.new(info) :: any
	setmetatable(self, Compass)

	-- Override / extend
	self.className = "Compass"
	self.name = info.name
	self.Equipped = false
	
	self.Designation = "Nil"
	
	-- Compass-specific state (example)
	-- self.someProperty = ...

	return self
end

function Compass:show_ui()
	local gamemode_config =
		game:GetService("ReplicatedStorage")
		.Shared
		.Library
		.Configuration
		.Scoring_Variables
		.Gamemode

	local designationIndex = 0

	for _, point in ipairs(game_points:GetChildren()) do
		local billboard = point:FindFirstChild("Points_Billboard")

		if not billboard then
			continue
		end

		billboard.Enabled = true
	end
end

function Compass:hide_ui()
	for _, child in pairs(game_points:GetChildren()) do
		if child:FindFirstChild("Points_Billboard") then
			child.Points_Billboard.Enabled = false
		end
	end
end

-- // Required override
function Compass:activate()
	print("[Compass] Activated:", self.name)
	
	if self.Equipped then
		print("Too show objectives...")
		Compass:show_ui()
	else
		print("Too hide objectives...")
		Compass:hide_ui()
	end
end

-- // Optional lifecycle hooks
function Compass:_on_give(tool: Tool, holster: Model?, model: Model?)
	
	UserInputService.InputBegan:Connect(function(input, gps)
		if gps then return end 
		
		if input.KeyCode == Enum.KeyCode.X then
			self.Equipped = true
			self:activate()
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input, gps)
		if gps then return end 
		
		if input.KeyCode == Enum.KeyCode.X then
			self.Equipped = false
			self:activate()
		end
	end)
end

return Compass