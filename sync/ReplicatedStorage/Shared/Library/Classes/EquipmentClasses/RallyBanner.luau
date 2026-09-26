local Class = require(script.Parent.GenericEquipmentFactory).create({
	name = "RallyBanner",
	displayName = "Rally Banner",
	maxEquipment = 1,
	reloadTime = 45,
	instantActivate = true,
	unequipHeldToolsOnActivate = true,
})

local baseActivate = Class.Activate
function Class:Activate()
	if (self:GetCount() or 0) <= 0 then return end
	local event = game:GetService("ReplicatedStorage").Shared.Library.Events:WaitForChild("BuffAbility")
	event:FireServer("RallyBanner")
	baseActivate(self)
end

return Class
