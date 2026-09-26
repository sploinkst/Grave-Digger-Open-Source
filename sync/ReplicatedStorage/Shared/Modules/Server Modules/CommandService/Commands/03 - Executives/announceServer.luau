local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function (context, text)
	local ok, filtered = pcall(function()
		return TextService:FilterStringAsync(text, context.Executor.UserId):GetNonChatStringForBroadcastAsync()
	end)
	if not ok then return "Announcement could not be filtered." end
	local manager = require(ReplicatedStorage.Shared.Modules["Server Modules"].ReplicantManager)
	manager.BroadcastPresentation("global_alert", {
		message = filtered .. " - " .. context.Executor.Name,
		privateServer = game.PrivateServerId ~= "",
		duration = 15,
	})
	return "Created announcement."
end
