-- The second Ocelot revolver needs its own runtime Tool identity so the
-- inventory, destruction, and drop-reload paths can track both guns reliably.

local OcelotTalonRevolver = require(script.Parent.OcelotTalonRevolver)

local Secondary = {}
Secondary.__index = Secondary
setmetatable(Secondary, { __index = OcelotTalonRevolver })

function Secondary.new(info)
	local self = OcelotTalonRevolver.new(info)
	setmetatable(self, Secondary)
	self.className = "OcelotTalonRevolverSecondary"
	self.name = "OcelotTalonRevolverSecondary"
	self.Display_Name = "Ocelot Talon Revolver (Secondary)"
	self.Designation = "Secondary"
	return self
end

Secondary.Display_Name = "Ocelot Talon Revolver (Secondary)"
Secondary.HiddenFromLoadout = true

return Secondary
