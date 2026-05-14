local module = {}

-- // Variables
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local Accessories_Folder = ReplicatedStorage.Shared.Assets.Accessories
local Utils_Module 		 = require(ReplicatedStorage.Shared.Library.Util)


-- // Functions
local function fetch_accessory(accessory_name)
	local Accessory = Accessories_Folder:FindFirstChild(accessory_name, true)
	
	if not Accessory then
		warn("Accessory not found:", accessory_name)
		return
	end
	
	return Accessory
end


function module.give_accessory(player: Player, accessory_name: string, server_handled: boolean?)
	server_handled = server_handled or false
	print("Received with:", player.Name, accessory_name, server_handled)
	
	
	local Accessory:Instance = fetch_accessory(accessory_name)
	
	if not Accessory then return end	
	
	
	if server_handled then
		local accessory_clone = Accessory:Clone()
		
		Utils_Module.quick_give_accessory(player, accessory_clone, true)
	else	
		Utils_Module.quick_give_accessory(player, nil, false)
	end
	
end




function module.start_module()
	-- // skip, does nothing
end
return module
