local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

return function (context, text)
	for _, player in ipairs(Players:GetPlayers()) do
		local Clone = player.PlayerGui.Announcements.Holder.Example:Clone()
		Clone.Parent = player.PlayerGui.Announcements.Holder
		Clone.Name = "Announcement"
		Clone.Visible = true
		
		Clone.Text = text .. " - " .. context.Executor.Name
		
		task.delay(3, function()
			Clone:Destroy()
		end)
	end
	
	return "Created announcement."
end