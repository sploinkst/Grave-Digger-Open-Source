local module = {}

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local chat_utils = require(
	Players.LocalPlayer.PlayerGui
		:WaitForChild("Chat")
		:WaitForChild("ChatFrame")
		:WaitForChild("Utils")
)

local chat_communication =
	ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Events")
	:WaitForChild("Chat_Communication")

local sfx_communication =
	chat_communication.Parent
	.Replicant_Communication
	.SFX_Connection

local dialogue_folder =
	ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Assets")
	:WaitForChild("Sounds")
	:WaitForChild("Dialogue")

local chat_remote =
	chat_communication:WaitForChild("Chat_Event")

local local_player = Players.LocalPlayer

local input_connections: {RBXScriptConnection} = {}

local function scroll_to_bottom()
	local chatFrame =
		local_player.PlayerGui.Chat.ChatFrame

	task.defer(function()
		chatFrame.CanvasPosition = Vector2.new(
			0,
			math.max(
				0,
				chatFrame.AbsoluteCanvasSize.Y
			)
		)
	end)
end

local function set_focus_state(active: boolean)
	local container =
		local_player.PlayerGui.Chat:FindFirstChild("Container")

	if not container then
		return
	end

	TweenService:Create(
		container,
		TweenInfo.new(0.15),
		{
			BackgroundTransparency =
				active and 0 or 0.15
		}
	):Play()
end

local function setup_input()
	for _, connection in ipairs(input_connections) do
		connection:Disconnect()
	end

	table.clear(input_connections)

	local container =
		local_player.PlayerGui
		:WaitForChild("Chat")
		:WaitForChild("Container")

	local text_box =
		container:WaitForChild("TextBox")

	table.insert(
		input_connections,
		text_box.Focused:Connect(function()
			set_focus_state(true)
		end)
	)

	table.insert(
		input_connections,
		text_box.FocusLost:Connect(function(enter_pressed)
			set_focus_state(false)

			if enter_pressed and text_box.Text ~= "" then
				chat_remote:FireServer(text_box.Text)
				text_box.Text = ""
			end
		end)
	)

	table.insert(
		input_connections,
		UserInputService.InputBegan:Connect(function(input, gp)
			if gp then
				return
			end

			if input.KeyCode == Enum.KeyCode.Slash then
				task.defer(function()
					text_box:CaptureFocus()
					text_box.Text = ""
				end)
			end
		end)
	)

	table.insert(
		input_connections,
		text_box:GetPropertyChangedSignal("Text"):Connect(function()
			if text_box.Text:sub(1, 1) == "/" then
				text_box.Text = text_box.Text:sub(2)
			end
		end)
	)
end

local function restore_chat_history()
	local chatFrame =
		local_player.PlayerGui.Chat.ChatFrame

	scroll_to_bottom()
end

function module.start_module()
	StarterGui:SetCoreGuiEnabled(
		Enum.CoreGuiType.Chat,
		false
	)

	local_player.CharacterAdded:Connect(function()
		task.wait()

		setup_input()
		restore_chat_history()
	end)

	chat_remote.OnClientEvent:Connect(function(
		player: Player,
		chat: string
	)

		chat_utils.create_chat(player, chat)

		scroll_to_bottom()

		if player.Character then
			if local_player.Team
				and player.Team
				and player.Team == local_player.Team
			then
				local root =
					player.Character:FindFirstChild(
						"HumanoidRootPart"
					)

				if root then
					local billboard =
						root:FindFirstChild(
							"Name_Billboard"
						)

					if billboard then
						local message =
							billboard:FindFirstChild(
								"playermessage"
							)

						if message then
							message.Text = chat
							message.Visible = true

							task.delay(10, function()
								if message.Parent then
									message.Visible = false
								end
							end)
						end
					end
				end
			end

			local head =
				player.Character:FindFirstChild("Head")

			if head then
				local dialogue =
					dialogue_folder:FindFirstChild(
						"dialogue" .. math.random(1, 2)
					)

				if dialogue then
					sfx_communication:FireServer(
						dialogue,
						head
					)
				end
			end
		end
	end)

	setup_input()
end

return module