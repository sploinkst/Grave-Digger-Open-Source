-- // wound giver
local replicatedstorage_service 		= game:GetService("ReplicatedStorage")
local modules							= replicatedstorage_service.Shared.Modules
local status_service 					= require(modules["Server Modules"].StatusService)

local proximity_prompt = script.Parent.GiveItem


local parts = {
	--"Torso",
	--"Left Arm",
	--"Right Arm",
	"Left Leg",
	"Right Leg",
}

proximity_prompt.Triggered:Connect(function(player)
	local player_character = player.Character
	if not player_character then return end

	local humanoid = player_character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- damage
	humanoid:TakeDamage(105)

	-- safe random limb selection
	local part = parts[math.random(1, #parts)]

	-- give statuses
	status_service.give_status(player, "WoundStatus", "Bullet", part, "Pellet")
	status_service.give_status(player, "ConcussionStatus")

	print("'Shot' " .. player.Name)
end)