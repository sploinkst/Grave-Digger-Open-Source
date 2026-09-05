local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InteractionPrompt = script.Parent.GiveItem
local item_service = require(game.ReplicatedStorage.Shared.Modules["Server Modules"].ItemsService)

local GivenItem = "GraceRevolver"

script.Parent.Marker.label.Text = "Give " .. GivenItem

InteractionPrompt.Triggered:Connect(function(player)
	item_service.give_item(player, GivenItem)
	print("Gave" .. GivenItem .. "to" .. player.Name)
end)