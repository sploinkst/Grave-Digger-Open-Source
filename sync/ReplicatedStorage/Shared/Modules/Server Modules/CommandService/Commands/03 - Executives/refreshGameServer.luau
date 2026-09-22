local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

return function()
	for _, player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(91037495253997, player)
	end
end