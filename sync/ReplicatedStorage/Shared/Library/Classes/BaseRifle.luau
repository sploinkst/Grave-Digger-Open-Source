--!strict
--!native
--!optimize 2

local Types = require(script.Parent.Parent.Types)
local BaseFirearm = require(script.Parent.BaseFirearm)

local BaseRifle = {}
BaseRifle.__index = BaseRifle
setmetatable(BaseRifle, { __index = BaseFirearm })

export type BaseRifle = BaseFirearm.BaseFirearm & {
	WeaponCategory: "Rifle",
	Designation: string,
	damage: number,
	Max_Capacity: number,
	Capacity: number,
	Ammo_Type: string,
	recoil: number,
	recoil_count: number,
	Penetration_Level: number,
	Armor_Penetration_Level: number,
	KnockBack_Force: number,
	Aiming_Number: number,
	Accuracy: number,
	Moving_Accuracy: number,
}

function BaseRifle.new(info: Types.BaseToolCreateInfo): BaseRifle
	local self = BaseFirearm.new(info) :: any
	setmetatable(self, BaseRifle)

	self.className = "BaseRifle"
	self.WeaponCategory = "Rifle"
	self.Designation = "Primary"

	self.damage = 100
	self.Max_Capacity = 5
	self.Capacity = self.Max_Capacity
	self.Ammo_Type = "Rifle"
	self.recoil = 55
	self.recoil_count = 7
	self.Penetration_Level = 2
	self.Armor_Penetration_Level = 2
	self.KnockBack_Force = 10
	self.Aiming_Number = 100
	self.Accuracy = 5
	self.Moving_Accuracy = 65

	return self
end

return BaseRifle
