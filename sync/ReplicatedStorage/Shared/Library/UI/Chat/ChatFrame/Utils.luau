local module = {}


local function format_username(username: string, team: string, server: boolean)
	local hex = if team == "Golden Empire" then "#FFD454" else "#7F16AF"

	local prefix = "ARM "

	if server then
		hex = "#FF0000"
		username = "SERVER"
		prefix = ""
	end

	return string.format(
		"<b><font color='%s'>%s%s</font></b>",
		hex,
		prefix,
		username
	)
end

function module.create_chat(player: Player, chat: string, server: boolean)
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
			player.Team.Name,
			server
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