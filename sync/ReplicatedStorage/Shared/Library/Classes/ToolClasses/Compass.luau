--!strict
--!optimize 2

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local game_points = game:GetService("Workspace").Game_Details.Main_Game.Points
local GiveCompassEvent:RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Equipment_Communication"):WaitForChild("GiveCompass")
local RemoveCompassEvent:RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Equipment_Communication"):WaitForChild("RemoveCompass")

local BaseTool = require(script.Parent.Parent.BaseTool)

local Assets        = ReplicatedStorage.Shared.Assets
local SoundFolder   = Assets.Guns:WaitForChild("Sounds"):WaitForChild("PrinceRifle")
local HolsterFolder = Assets.Guns.Holsters:FindFirstChild("Gun Holsters")
local ToolFolder    = Assets.Guns.ToolModels
local AnimFolder    = Assets.Animations.Tools.Compass

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
	
	self.animations = {
		Left = AnimFolder:FindFirstChild("CompassLeft"),
		Right = AnimFolder:FindFirstChild("CompassRight")
	}

	self.Debounce = 1.3
	self.DebounceTick = tick()
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

function Compass:HandleEvent()
end
-- // Required override
function Compass:activate()
	print("[Compass] Activated:", self.name)



	local character = game.Players.LocalPlayer.Character
	if not character then
		return
	end
	
	if character:GetAttribute("Aiming") then
		return
	end
	
	local compassArm = character:GetAttribute("CompassRight") and "Right Arm" or "Left Arm"
	local compassSide = character:GetAttribute("CompassRight") and "Right" or "Left"

	if self.Equipped then
		if self.DebounceTick > tick() - self.Debounce then
			return
		end

		self.DebounceTick = tick()
		
		GiveCompassEvent:FireServer(compassArm)
		print("To show objectives...")

		self:show_ui()

		self._track = self:_playAnim(compassSide)
		
		task.delay(0.5, function()
			if self._track then
				if self.Equipped then
				self._track:AdjustSpeed(0)
				end
			end
		end)
	else
		print("To hide objectives...")

		self:hide_ui()

		if self._track then
			self._track:AdjustSpeed(1)
			
			self._track.Stopped:Wait()
			RemoveCompassEvent:FireServer(compassArm)
			self._track = nil
		end
	end
end

-- // Optional lifecycle hooks
function Compass:_on_give(tool: Tool, holster: Model?, model: Model?)
	
	self.InputBeganConn = UserInputService.InputBegan:Connect(function(input, gps)
		if gps then return end 
		
		if input.KeyCode == Enum.KeyCode.X then
			self.Equipped = true
			self:activate()
		end
	end)
	
	self.InputEndedConn = UserInputService.InputEnded:Connect(function(input, gps)
		if gps then return end 
		
		if input.KeyCode == Enum.KeyCode.X then
			self.Equipped = false
			self:activate()
		end
	end)
	
	self.connection = game.Players.LocalPlayer.Character:GetAttributeChangedSignal("Aiming"):Connect(function()
		if game.Players.LocalPlayer.Character:GetAttribute("Aiming") and self.Equipped then
			self:activate()
		end
	end)
end

function Compass:_on_unequip()
	
	if self.InputBeganConn then
		self.InputBeganConn:Disconnect()
		self.InputBeganConn = nil
	end
	
	if self.InputEndedConn then
		self.InputEndedConn:Disconnect()
		self.InputEndedConn = nil
	end
	
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

return Compass