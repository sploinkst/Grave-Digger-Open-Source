local VoiceReceiver = {}
-- @Praxitos
-- Handles Client VoiceManager

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Constants
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = Shared:WaitForChild("Library")
local Events = Library:WaitForChild("Events")
local VoiceComms = Events:WaitForChild('VoiceComms')

-- // Variables

-- // Functions

-- temp
local function CreateBillBoard(position)
	local part = Instance.new("Part")
	part.Name = "DangerPing"
	part.Size = Vector3.new(3,3,3)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DangerBillboard"
	billboard.Size = UDim2.fromOffset(100, 25)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = part
	billboard.Parent = workspace

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "DANGER"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard



	task.delay(10, function()
		part:Destroy()
	end)
end

function VoiceReceiver.start_module()
	VoiceComms.OnClientEvent:Connect(function(sender, VoiceComm, data)
		print("VoiceReceiver: received voicecomm from server:", VoiceComm, data)
		
		if VoiceComm == "danger" then
			CreateBillBoard(data.Position)
			print("VoiceReceiver: Fired CreateBillBoard to", data.Position)
			
			local Notifications = require(game.Players.LocalPlayer.PlayerGui:WaitForChild('Notifications').Utils)
			Notifications.send_notification({}, sender.Name .. ": Danger over there")
		end
	end)
end

return VoiceReceiver
