local module = {}
local starter_gui = game:GetService("StarterGui")
local player_service = game:GetService("Players")
local tween_service = game:GetService("TweenService")
local userinput_service = game:GetService("UserInputService")
local replicated_storage = game:GetService("ReplicatedStorage")
local chat_utils = require(player_service.LocalPlayer.PlayerGui:WaitForChild("Chat"):WaitForChild("ChatFrame"):WaitForChild("Utils"))
local chat_communication = replicated_storage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Chat_Communication")
local sfx_communication = chat_communication.Parent.Replicant_Communication.SFX_Connection
local dialogue_folder = replicated_storage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Dialogue")
local chat_remote = chat_communication:WaitForChild("Chat_Event")
local local_player = player_service.LocalPlayer

local input_connections: {RBXScriptConnection} = {}

-- Persistent message history, survives respawns
local message_history: {{ player: Player, chat: string }} = {}
local MAX_HISTORY = 50

local function set_focus_state(active)
	if not local_player.PlayerGui.Chat.Container then return end
	tween_service:Create(local_player.PlayerGui.Chat.Container, TweenInfo.new(0.15), {
		BackgroundTransparency = active and 0 or 0.15
	}):Play()
end

local function setup_input()
	for _, conn in ipairs(input_connections) do
		conn:Disconnect()
	end
	table.clear(input_connections)

	local container = local_player.PlayerGui:WaitForChild("Chat"):WaitForChild("Container")
	local text_box = container:WaitForChild("TextBox")

	table.insert(input_connections, text_box.Focused:Connect(function()
		set_focus_state(true)
	end))

	table.insert(input_connections, text_box.FocusLost:Connect(function(enter_pressed)
		set_focus_state(false)
		if enter_pressed and text_box.Text ~= "" then
			chat_remote:FireServer(text_box.Text)
			text_box.Text = ""
		end
	end))

	table.insert(input_connections, userinput_service.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Slash then
			task.defer(function()
				text_box:CaptureFocus()
				text_box.Text = ""
			end)
		end
	end))

	table.insert(input_connections, text_box.Changed:Connect(function()
		if text_box.Text:sub(1, 1) == "/" then
			text_box.Text = text_box.Text:sub(2)
		end
	end))
end

local function restore_chat_history()
	for _, entry in ipairs(message_history) do
		chat_utils.create_chat(entry.player, entry.chat)
	end
end

function module.start_module()
	starter_gui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

	local_player.CharacterAdded:Connect(function()
		task.wait()
		setup_input()
		restore_chat_history()
	end)

	chat_remote.OnClientEvent:Connect(function(player: Player, chat: string)
		-- Store in history before creating the UI entry
		table.insert(message_history, { player = player, chat = chat })
		if #message_history > MAX_HISTORY then
			table.remove(message_history, 1)
		end

		chat_utils.create_chat(player, chat)

		if player.Character then
			if player.Team.Name == local_player.Team.Name then
				local billboard_ui = player.Character.HumanoidRootPart:FindFirstChild("Name_Billboard")
				if billboard_ui then
					billboard_ui.playermessage.Text = chat
					billboard_ui.playermessage.Visible = true
					task.delay(10, function()
						if billboard_ui and billboard_ui.Parent then
							billboard_ui.playermessage.Visible = false
						end
					end)
					print("setup message_ui")
				else
					print("no billboard")
				end
			end

			local dialogue_instance = dialogue_folder:FindFirstChild("dialogue" .. math.random(1, 2))
			sfx_communication:FireServer(dialogue_instance, player.Character:FindFirstChild("Head"))
			print("played")
		end
	end)

	setup_input()
end

return module