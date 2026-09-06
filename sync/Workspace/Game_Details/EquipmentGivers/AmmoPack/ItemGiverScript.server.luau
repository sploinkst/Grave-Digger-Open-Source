local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InteractionPrompt = script.Parent.GiveItem
local item_service = require(game.ReplicatedStorage.Shared.Modules["Server Modules"].ItemsService)

local GivenItem = "Medkit"

script.Parent.Marker.label.Text = "Give " .. GivenItem

InteractionPrompt.Triggered:Connect(function(player)
	local character = player.Character
	if not character then return end
	local state = character:FindFirstChild("CharacterData") and character.CharacterData:FindFirstChild("State")
	local equipment = state and state:FindFirstChild("Equipment")
	if equipment and equipment:IsA("StringValue") then equipment.Value = "AmmoPack" end
	-- Temporary compatibility for systems not yet migrated to CharacterData.State.
	character:SetAttribute("Equipment", "AmmoPack")
	print("Gave" .. GivenItem .. "to" .. player.Name)
end)
