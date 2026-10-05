local Controller = require(script.Parent.Parent.ConstructionTool)
local Class = setmetatable({}, {__index = Controller})
Class.__index = Class
Class.Weight = 0
Class.Designation = "Equipment"
Class.Medal_Cost = 0
function Class.new(info)
	local self = Controller.new(info, false)
	self.className = "ConstructHammer"; self.name = self.className
	return setmetatable(self, Class)
end
return Class
