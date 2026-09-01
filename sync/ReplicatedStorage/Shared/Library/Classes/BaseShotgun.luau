--!strict
--!native
--!optimize 2

local HttpService = game:GetService("HttpService")

local Types = require(script.Parent.Parent.Types)
local BaseFirearm = require(script.Parent.BaseFirearm)

local BaseShotgun = {}
BaseShotgun.__index = BaseShotgun
setmetatable(BaseShotgun, { __index = BaseFirearm })

export type BaseShotgun = BaseFirearm.BaseFirearm & {
	WeaponCategory: "Shotgun",
	PelletCount: number,
	ShotgunSpread: number,
}

function BaseShotgun.new(info: Types.BaseToolCreateInfo): BaseShotgun
	local self = BaseFirearm.new(info) :: any
	setmetatable(self, BaseShotgun)
	self.className = "BaseShotgun"
	self.WeaponCategory = "Shotgun"
	self.Designation = "Primary"
	self.PelletCount = 9
	self.ShotgunSpread = 5
	return self
end

function BaseShotgun:get_pellet_directions(shootDirection: Vector3, spreadDegrees: number?): { Vector3 }
	local directions = table.create(self.PelletCount)
	local spread = math.tan(math.rad(spreadDegrees or self.ShotgunSpread))
	local right = shootDirection:Cross(Vector3.yAxis)
	if right.Magnitude < 0.001 then right = shootDirection:Cross(Vector3.xAxis) end
	right = right.Unit
	local up = right:Cross(shootDirection).Unit
	local random = Random.new()

	for index = 1, self.PelletCount do
		-- sqrt produces an even pellet density over the circular shot pattern.
		local radius = math.sqrt(random:NextNumber()) * spread
		local angle = random:NextNumber(0, math.pi * 2)
		directions[index] = (shootDirection
			+ right * (math.cos(angle) * radius)
			+ up * (math.sin(angle) * radius)).Unit
	end
	return directions
end

function BaseShotgun:_firePellets(
	muzzle: BasePart,
	shootDirection: Vector3,
	bulletSpeed: number,
	damage: number,
	knockbackForce: number
)
	local shotId = HttpService:GenerateGUID(false)
	for pelletIndex, direction in ipairs(self:get_pellet_directions(shootDirection, self.ShotgunSpread)) do
		local cast = self.Caster:Fire(muzzle.Position, direction, bulletSpeed, self.CasterBehavior)
		cast.UserData = {
			Direction = direction,
			Penetrated = false,
			Origin = muzzle.Position,
			Shooter = game.Players.LocalPlayer,
			ShotId = shotId,
			PelletIndex = pelletIndex,
			PelletCount = self.PelletCount,
		}

		self:_connect_FastCast(muzzle.Position, direction, bulletSpeed, {
			bulletTemplate = game.ReplicatedStorage.Shared.Assets.Guns.Effects.Bullet,
			bulletContainer = workspace.Game_Details.Effects.Bullets,
			isPenetration = false,
			penetrationLevel = self.Penetration_Level,
			damage = damage,
			knockbackForce = knockbackForce,
		})
	end
end

return BaseShotgun
