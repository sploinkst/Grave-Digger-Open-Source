--!strict

local BaseTool = require(script.Parent.Parent.BaseTool)

local Factory = {}

function Factory.create(config)
	local Class = {}
	Class.__index = Class
	setmetatable(Class, { __index = BaseTool })

	function Class.new(info)
		local self = setmetatable(BaseTool.new(info), Class)
		self.className = config.name
		self.name = config.name
		self.item_image = config.Tool_Image or ""
		self.Designation = config.Designation or "Equipment"
		self.Can_Drop = config.canDrop == true
		return self
	end

	function Class:activate() end

	Class.Tool_Image = config.Tool_Image or ""
	Class.Medal_Cost = config.Medal_Cost or 0
	Class.Weight = config.Weight or 0
	Class.Designation = config.Designation or "Equipment"

	return Class
end

return Factory
