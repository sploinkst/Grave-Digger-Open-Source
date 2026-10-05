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
local Audio = require(Library.GameAudio)

-- // Variables

-- // Functions
local function DangerAlert(player,data)
	if type(data) ~= "table" or typeof(data.Position) ~= "Vector3" then return end
	local senderRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not senderRoot or not player.Team then return end
	local Position = data.Position
	if (Position - senderRoot.Position).Magnitude > 1100 then return end
	local hit = typeof(data.Hit) == "Instance" and data.Hit or nil
	local target
	while hit and hit ~= workspace do
		if hit:IsA("Model") then target = Players:GetPlayerFromCharacter(hit); if target then break end end
		hit = hit.Parent
	end
	local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if target and targetRoot and target.Team ~= player.Team and (targetRoot.Position - Position).Magnitude <= 12 then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {player.Character}
		local result = workspace:Raycast(senderRoot.Position, targetRoot.Position - senderRoot.Position, params)
		if not result or result.Instance:IsDescendantOf(target.Character) then
			require(script.Parent.StatusService).GiveStatus(target, "SpottedStatus", 10, false, player)
		end
	end
	
	for _, receivingPlayer in pairs(Players:GetPlayers()) do
		if player.Team ~= receivingPlayer.Team then continue end
		
		-- // if within not 30 studs of the sending player return
		local receivingRoot = receivingPlayer.Character and receivingPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not receivingRoot or (receivingRoot.Position - senderRoot.Position).Magnitude > Audio.PingRadius then continue end
		
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
