--!strict

local BaseEquipment = require(script.Parent.Parent.BaseEquipment)

local Factory = {}

function Factory.create(config)
	local Class = {}
	Class.__index = Class
	setmetatable(Class, { __index = BaseEquipment })

	function Class.new()
		local self = BaseEquipment.new({ name = config.displayName or config.name })
		setmetatable(self, Class)
		self.className = config.name
		self.MaxEquipment = config.maxEquipment or 1
		self.EquipmentReloadTime = config.reloadTime or 30
		self.InstantActivate = config.instantActivate == true
		self.UnequipHeldToolsOnActivate = config.unequipHeldToolsOnActivate == true
		return self
	end

	function Class:Activate()
		if (self:GetCount() or 0) <= 0 then return end
		self:CountDown(-1)
	end

	return Class
end

return Factory
