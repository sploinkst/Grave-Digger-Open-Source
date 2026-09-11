local VoiceManager = {}

-- @Praxitos
-- Handles ServerSided VoiceManager

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
local function DangerAlert(player,data)
	
	local Position = data.Position
	
	for _, receivingPlayer in pairs(Players:GetPlayers()) do
		if player.Team ~= receivingPlayer.Team then continue end
		
		-- // if within not 30 studs of the sending player return
		if (receivingPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude > 30 then continue end
		
		VoiceComms:FireClient(receivingPlayer, player, "danger", {Position = Position})
		print("VoiceManager: Fired DangerPing to", receivingPlayer.Name)
		print("VoiceManager: Position is", Position)
	end
end

-- // Connections
function VoiceManager.start_module()
	VoiceComms.OnServerEvent:Connect(function(player, voicecomm, data)
		print("VoiceManager: received voicecomm from", player.Name, ":", voicecomm)
		
		if voicecomm == "danger" then
			DangerAlert(player, data)
			print("VoiceManager: Fired DangerAlert to", player.Name)
		end
	end)
end

return VoiceManager
