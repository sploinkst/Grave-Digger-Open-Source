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
local Rules = require(Library.VoiceCommandRules)
local lastCommands = setmetatable({}, {__mode="k"})
local started = false

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
	if started then return end
	started = true
	VoiceComms.OnServerEvent:Connect(function(player, voicecomm, data)
		if type(voicecomm) ~= "string" or not Rules.Commands[voicecomm] then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not root or not player.Team then return end
		local now = os.clock()
		if now - (lastCommands[player] or -math.huge) < 0.5 then return end
		if Rules.Officer[voicecomm] and character:GetAttribute("Class") ~= "Officer" then return end
		lastCommands[player] = now
		if voicecomm == "danger" then DangerAlert(player, data); return end
		local request = Rules.Requests[voicecomm]
		if request then character:SetAttribute(request, workspace:GetServerTimeNow() + 10) end
		for _, receiver in ipairs(Players:GetPlayers()) do
			local receiverRoot = receiver.Character and receiver.Character:FindFirstChild("HumanoidRootPart")
			if receiver.Team == player.Team and receiverRoot and (receiverRoot.Position-root.Position).Magnitude <= (Rules.Officer[voicecomm] and 200 or Audio.PingRadius) then
				VoiceComms:FireClient(receiver, player, voicecomm, {Position=root.Position, message=Rules.Labels[voicecomm]})
			end
		end
	end)
end
return VoiceManager
