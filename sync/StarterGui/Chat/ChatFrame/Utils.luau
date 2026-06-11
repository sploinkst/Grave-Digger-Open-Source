local module = {}

local function format_username(username: string, team: string)
	local hex = team == "Golden Empire" and "#FFD454" or "#7F16AF"
	return "<b><font color='" .. hex .. "'>ARM " .. username .. "</font></b>"
end

function module.create_chat(player: Player, chat: string)
	local ChatFrame:ScrollingFrame = game.Players.LocalPlayer.PlayerGui.Chat.ChatFrame
	local Example_Frame = ChatFrame:WaitForChild("Example")
	
	local example_clone = Example_Frame:Clone()
	example_clone.Name = tostring(#ChatFrame:GetChildren() - 1)
	example_clone.Parent = ChatFrame
	example_clone.Visible = true

	local playername = example_clone:FindFirstChild("playername")
	local playertext = example_clone:FindFirstChild("playertext")

	if playername then
		playername.Text = format_username(player.Name, player.Team.Name)
	end

	if playertext then
		playertext.Text = format_username(player.Name, player.Team.Name) .. ": " .. chat
	end
end

return module