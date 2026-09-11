--!strict

local Workspace = game:GetService("Workspace")
local InputService = game:GetService("UserInputService")
local Players_Service = game:GetService("Players")

local Camera = Workspace.CurrentCamera

local CameraClass = require(
	script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass
)

local SpectateCamera = setmetatable({}, { __index = CameraClass })
SpectateCamera.__index = SpectateCamera

local LocalPlayer = Players_Service.LocalPlayer

local Players = {}
local CurrentIndex = 1

local InputConn
local HeartbeatConn
local CharacterAddedConn

local function GetHead(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("Head")
end

function SpectateCamera:UpdateCamera()
	if #Players == 0 then
		Camera.CameraSubject = nil
		return
	end

	local player = Players[CurrentIndex]
	if not player then
		return
	end

	local head = GetHead(player)
	if not head then
		Camera.CameraSubject = nil
		return
	end

	Camera.CameraSubject = head
end

function SpectateCamera:Cycle(direction)
	if #Players == 0 then
		return
	end

	CurrentIndex += direction

	if CurrentIndex < 1 then
		CurrentIndex = #Players
	elseif CurrentIndex > #Players then
		CurrentIndex = 1
	end

	self:UpdateCamera()
end

function SpectateCamera:Start()
	-- // If we already have a character (i.e. we're alive), don't spectate.
	if LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("Humanoid")
		and LocalPlayer.Character.Humanoid.Health > 0 then
		self:End()
		return
	end

	Camera.CameraType = Enum.CameraType.Custom

	table.clear(Players)
	CurrentIndex = 1

	for _, player in pairs(Players_Service:GetPlayers()) do
		if player == LocalPlayer then
			continue
		end

		if LocalPlayer.Team and player.Team ~= LocalPlayer.Team then
			continue
		end

		table.insert(Players, player)
	end

	self:UpdateCamera()

	local gui = LocalPlayer.PlayerGui:WaitForChild("Spectate", 5)
	if gui then
		gui.Enabled = true
	end

	if InputConn then
		InputConn:Disconnect()
	end

	InputConn = InputService.InputBegan:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode == Enum.KeyCode.Q then
			self:Cycle(-1)
		elseif input.KeyCode == Enum.KeyCode.E then
			self:Cycle(1)
		end
	end)

	-- // Keep the camera locked onto the head every frame, in case the
	if HeartbeatConn then
		HeartbeatConn:Disconnect()
	end

	HeartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
		if #Players == 0 then
			return
		end

		local player = Players[CurrentIndex]
		if not player then
			return
		end

		local head = GetHead(player)
		if head and Camera.CameraSubject ~= head then
			Camera.CameraSubject = head
		end
	end)

	if CharacterAddedConn then
		CharacterAddedConn:Disconnect()
	end

	CharacterAddedConn = LocalPlayer.CharacterAdded:Connect(function()
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

	if HeartbeatConn then
		HeartbeatConn:Disconnect()
		HeartbeatConn = nil
	end

	if CharacterAddedConn then
		CharacterAddedConn:Disconnect()
		CharacterAddedConn = nil
	end

	local gui = LocalPlayer.PlayerGui:FindFirstChild("Spectate")
	if gui then
		gui.Enabled = false
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