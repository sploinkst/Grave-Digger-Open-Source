-- All medical assistance shares one thank-you record, owned by the server.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Status = require(script.Parent.StatusService)
local Rules = require(RS.Shared.Library.MedicalRules)
local Service = {}
local recent = setmetatable({}, {__mode = "k"})

function Service.Record(recipient, provider, providerCharacter)
	if recipient == provider or not provider.Team or recipient.Team ~= provider.Team then return end
	recent[recipient] = {provider = provider, recipientCharacter = recipient.Character,
		providerCharacter = providerCharacter, expires = os.clock() + Rules.ThankWindow}
end

local function living(player)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

function Service.Thank(recipient)
	local aid = recent[recipient]
	if not aid then return false end
	recent[recipient] = nil
	local provider = aid.provider
	if provider.Parent ~= Players then return false end
	if not Rules.CanThank(os.clock(), aid.expires,
		recipient.Character == aid.recipientCharacter and provider.Character == aid.providerCharacter,
		provider.Team ~= nil and provider.Team == recipient.Team, living(provider), living(recipient)) then return false end
	Status.GiveStatus(provider, "MoraleStatus", Rules.MoraleDuration)
	return true
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	RS.Shared.Library.Events.VoiceComms.OnServerEvent:Connect(function(player, command)
		if command == "thanks" then Service.Thank(player) end
	end)
	Players.PlayerRemoving:Connect(function(player)
		recent[player] = nil
		for recipient, aid in recent do if aid.provider == player then recent[recipient] = nil end end
	end)
end

return Service
