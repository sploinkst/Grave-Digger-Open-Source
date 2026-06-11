local module = {}

local player_service = game:GetService("Players")
local chat_service = game:GetService("TextChatService")
local replicated_storage = game:GetService("ReplicatedStorage")

local chat_communication = replicated_storage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Chat_Communication")
local chat_remote = chat_communication:WaitForChild("Chat_Event")

function module.start_module()
	chat_service.ChatWindowConfiguration.Enabled = false
	
	chat_remote.OnServerEvent:Connect(function(player, chat)
		chat_remote:FireAllClients(player, chat)
	end)	
end

return module
