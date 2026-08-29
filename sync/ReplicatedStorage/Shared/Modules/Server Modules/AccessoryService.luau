local Module = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Constants
local AccessoriesFolder = ReplicatedStorage.Shared.Assets.Accessories
local UtilsModule = require(ReplicatedStorage.Shared.Library.Util)

-- // Functions

function Module.GiveAccessory(player: Player, accessoryName: string, serverHandled: boolean?, createString: boolean, giveAccessory: boolean)
	serverHandled = serverHandled or false
	print("Received with:", player.Name, accessoryName, serverHandled)

	local accessory: Instance = UtilsModule.fetch_accessory(accessoryName)

	if not accessory then
		return
	end

	if serverHandled then
		local accessoryClone = accessory:Clone()

		return UtilsModule.quick_give_accessory(player, accessoryClone, giveAccessory, serverHandled, createString)
	else
		return UtilsModule.quick_give_accessory(player, accessory, false, false, true)
	end
end

function Module.start_module()
	-- // skip, does nothing
end

return Module