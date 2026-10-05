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

-- Authored mount data from weapon_modules.saa (including inherited values).
Secondary.AuthoredWelds = {
	equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	lefthand = false,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
	holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
	alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

return Secondary
