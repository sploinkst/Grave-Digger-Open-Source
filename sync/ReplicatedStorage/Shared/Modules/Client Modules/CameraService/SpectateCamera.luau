--!strict

local Workspace = game:GetService("Workspace")
local InputService = game:GetService("UserInputService")

local Camera = Workspace.CurrentCamera

local CameraClass = require(
	script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass
)

local SpectateCamera = setmetatable({}, { __index = CameraClass })
SpectateCamera.__index = SpectateCamera

local Players = {}
local CurrentIndex = 1

local InputConn

function SpectateCamera:UpdateCamera()
	if #Players == 0 then
		return
	end

	local player = Players[CurrentIndex]
	if not player then
		return
	end

	if not player.Character then
		return
	end

	local hrp = player.Character:FindFirstChild("Head")
	if not hrp then
		return
	end

	Camera.CameraSubject = hrp
end

function SpectateCamera:Start()
	Camera.CameraType = Enum.CameraType.Custom

	table.clear(Players)
	CurrentIndex = 1

	for _, player in pairs(game.Players:GetPlayers()) do
		if player == game.Players.LocalPlayer then
			continue
		end

		if player.Team ~= game.Players.LocalPlayer.Team then
			continue
		end

		table.insert(Players, player)
	end

	self:UpdateCamera()

	game.Players.LocalPlayer.PlayerGui:WaitForChild("Spectate").Enabled = true

	if InputConn then
		InputConn:Disconnect()
	end

	InputConn = InputService.InputBegan:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode == Enum.KeyCode.Q then
			if CurrentIndex - 1 == 0 then
				CurrentIndex = #Players
			else
				CurrentIndex -= 1
			end
		elseif input.KeyCode == Enum.KeyCode.E then
			if CurrentIndex + 1 > #Players then
				CurrentIndex = 1
			else
				CurrentIndex += 1
			end
		else
			return
		end

		self:UpdateCamera()
	end)
	
	game.Players.LocalPlayer.CharacterAdded:Connect(function()
		print("Spectate ended")
		self:End()
	end)
end

function SpectateCamera:Resume()
	self:Start()
end

function SpectateCamera:End()
	if InputConn then
		InputConn:Disconnect()
		InputConn = nil
	end
	
	if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Spectate") then
		game.Players.LocalPlayer.PlayerGui.Spectate.Enabled = false
	end
end

function SpectateCamera:Cut()
	self:End()
end

function SpectateCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, SpectateCamera)

	self.className = "SpectateCamera"
	self.name = "SpectateCamera"
	self.CameraPosition = Camera.CFrame.Position
	self.priority = 2

	return self
end

SpectateCamera.priority = 2

return SpectateCamera