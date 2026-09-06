local Shared = game:GetService("ReplicatedStorage").Shared
local Classes = require(Shared.Library.ClassDefinitions)
local ClassService = require(Shared.Modules["Server Modules"].ClassService)

return function(_, player, kit)
	if not kit then
		local className = Classes.Selected(player)
		kit = "Storm Trooper"
		for name, definition in Classes.EliteDefinitions do
			if definition.RequiredClass == className then kit = name; break end
		end
	end
	local success, result = ClassService.SetShockTrooper(player, kit)
	if not success then return result end
	return ("Assigned %s to %s."):format(result, player.Name)
end
