--!strict
--!native
--!optimize 2

local Types = require(script.Parent.Parent.Types)
local BaseFirearm = require(script.Parent.BaseFirearm)

local BasePistol = {}
BasePistol.__index = BasePistol
setmetatable(BasePistol, { __index = BaseFirearm })

export type BasePistol = BaseFirearm.BaseFirearm & {
	WeaponCategory: "Pistol",
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

function BasePistol.new(info: Types.BaseToolCreateInfo): BasePistol
	local self = BaseFirearm.new(info) :: any
	setmetatable(self, BasePistol)

	self.className = "BasePistol"
	self.WeaponCategory = "Pistol"
	self.Designation = "Secondary"

	self.damage = 60
	self.Max_Capacity = 6
	self.Capacity = self.Max_Capacity
	self.Ammo_Type = "Pistol"
	self.recoil = 35
	self.recoil_count = 6
	self.Penetration_Level = 1
	self.Armor_Penetration_Level = 1
	self.KnockBack_Force = 6
	self.Aiming_Number = 80
	self.Accuracy = 6
	self.Moving_Accuracy = 50

	return self
end

return BasePistol
