local module = {}

local function format_username(username: string, team: string)
	local hex =
		team == "Golden Empire"
		and "#FFD454"
		or "#7F16AF"

	return "<b><font color='" .. hex .. "'>ARM "
		.. username
		.. "</font></b>"
end

function module.create_chat(player: Player, chat: string)
	local ChatFrame: ScrollingFrame =
		game.Players.LocalPlayer.PlayerGui.Chat.ChatFrame

	local Example =
		ChatFrame:WaitForChild("Example")

	local clone = Example:Clone()

	clone.Name = tostring(os.clock())

	clone.Visible = true
	clone.Parent = ChatFrame

	local formattedName =
		format_username(
			player.Name,
			player.Team.Name
		)

	local playername =
		clone:FindFirstChild("playername")

	local playertext =
		clone:FindFirstChild("playertext")

	if playername then
		playername.Text = formattedName
	end

	if playertext then
		playertext.Text =
			formattedName
			.. ": "
			.. chat
	end

	task.defer(function()
		ChatFrame.CanvasPosition = Vector2.new(
			0,
			math.max(
				0,
				ChatFrame.AbsoluteCanvasSize.Y
			)
		)
	end)
end

return module