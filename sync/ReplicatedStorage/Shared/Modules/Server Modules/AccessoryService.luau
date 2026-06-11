local module = {}

-- // Variables
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local Accessories_Folder = ReplicatedStorage.Shared.Assets.Accessories
local Utils_Module 		 = require(ReplicatedStorage.Shared.Library.Util)


-- // Functions

function module.give_accessory(player: Player, accessory_name: string, server_handled: boolean?, create_string: boolean, give_accessory: boolean)
	server_handled = server_handled or false
	print("Received with:", player.Name, accessory_name, server_handled)
	
	
	local Accessory:Instance = Utils_Module.fetch_accessory(accessory_name)
	
	if not Accessory then return end	
	
	
	if server_handled then
		local accessory_clone = Accessory:Clone()
		
		return Utils_Module.quick_give_accessory(player, accessory_clone, give_accessory, server_handled, create_string)
	else	
		return Utils_Module.quick_give_accessory(player, Accessory, false, false, true)
	end
	
end




function module.start_module()
	-- // skip, does nothing
end
return module
