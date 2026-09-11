local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InteractionPrompt = script.Parent.GiveItem
local item_service = require(game.ReplicatedStorage.Shared.Modules["Server Modules"].StatusService)

local GivenItem = "WoundStatus"

script.Parent.Marker.label.Text = "Receive " .. GivenItem

InteractionPrompt.Triggered:Connect(function(player)
	item_service.give_status(player, GivenItem, "Bullet", "Torso", "Round")
	print("Gave" .. GivenItem .. "to" .. player.Name)
end)