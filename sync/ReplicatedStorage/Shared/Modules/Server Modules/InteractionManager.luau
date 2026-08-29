local module = {}
local replicatedstorage_service = game:GetService("ReplicatedStorage")
local accessory_service			= require(script.Parent.AccessoryService)
local ToolService		= require(script.Parent.ItemsService)

local Interaction_Connection = replicatedstorage_service:WaitForChild("Shared"):WaitForChild('Library'):WaitForChild("Events"):WaitForChild("Interact")
local Util = require(replicatedstorage_service:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

function module.start_module()
	print("[INTERACTIONMANAGER] Started!")
	
	Interaction_Connection.OnServerEvent:Connect(function(player, object)
		print("[INTERACTIONMANAGER] Interacted with " .. object.Name)
		
		
		if object.Name == "ammocache" or object.Name == "obj_cache" then
			print("[INTERACTIONMANAGER] Interacted with an ammocache")
			
			Util.setammo(player)

			-- // find first child that has a helmet within its name
			for _, child in pairs(player.Character.CharacterData.Equipment:GetChildren()) do
				if string.find(child.Name, "Helmet") then
					child:Destroy()
					player.Character.Head:FindFirstChild("AccessoryWeld"):Destroy()
					accessory_service.GiveAccessory(player, child.Name, true, false, true)
					
					print("[INTERACTIONMANAGER] Added helmet to " .. player.Name)
					break
				end
			end
			
			local equipment    = player.PlayerData.PlayerData:WaitForChild("Equipment")
			local primary_tool = equipment.Primary
			local secondary_tool = equipment.Secondary
			
			if not player.Backpack:FindFirstChild(primary_tool.Value) then
				ToolService.give_item(player, primary_tool.Value)
			end
			
			if not player.Backpack:FindFirstChild(secondary_tool.Value) then
				ToolService.give_item(player, secondary_tool.Value)
			end
			
		end
	end)
end
return module
