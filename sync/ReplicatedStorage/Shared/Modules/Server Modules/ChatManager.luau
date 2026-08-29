local module = {}

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local chat_remote = ReplicatedStorage.Shared.Library.Events.Chat

local function filterText(player: Player, message: string)
	local success, result = pcall(function()
		return TextService:FilterStringAsync(
			message,
			player.UserId
		)
	end)

	if not success then
		return nil
	end

	local success2, filtered = pcall(function()
		return result:GetNonChatStringForBroadcastAsync()
	end)

	if not success2 then
		return nil
	end

	return filtered
end

function module.start_module()
	TextChatService.ChatWindowConfiguration.Enabled = false

	chat_remote.OnServerEvent:Connect(function(player, message)
		if typeof(message) ~= "string" then
			return
		end

		local filtered = filterText(player, message)

		if not filtered then
			return
		end

		chat_remote:FireAllClients(
			player,
			filtered
		)
	end)
end

return module