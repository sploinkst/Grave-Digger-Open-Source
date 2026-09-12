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
	self.Accuracy = self.ShotgunSpread
	self.Moving_Accuracy = self.ShotgunSpread
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

function BaseShotgun:_fireShotgunBlast(options): boolean
	if self.Firing or self.Reloading or self.Cycling then return false end
	if options and options.requireAiming ~= false and not self.Aiming then return false end
	if self.ForceBlockFire or self:_if_sprinting() or self:_if_jumping() then return false end
	if self.Capacity <= 0 then
		self:_dryFire()
		return false
	end

	local muzzle = if self._getMuzzlePart then self:_getMuzzlePart() else self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle or not muzzle:IsA("BasePart") then return false end
	if not self.Caster or not self.CasterBehavior then return false end

	local direction = self:_getAimedShot(muzzle, options and options.distance)
	if not direction then return false end

	self.Firing = true
	self:_firePellets(
		muzzle,
		direction,
		options and options.bulletSpeed or self.BulletSpeed or 850,
		options and options.damage or self.damage,
		options and options.knockbackForce or self.KnockBack_Force
	)
	self.Capacity -= options and options.capacityCost or 1

	self:_stopAllExcept()
	local animation = options and options.fireAnimation
	if not animation then animation = self.current_shoulder == "Right" and "Fire" or "Fire_Left" end
	self:_playFireAnimation(animation)
	self:_playShotFeedback(muzzle, options and options.sound or self.FireSound, options and options.soundPitchVariation)

	local fireDelay = options and options.fireDelay
	if fireDelay and fireDelay > 0 then
		task.wait(self.getFireDelay and self:getFireDelay(fireDelay) or fireDelay)
	end

	self.Firing = false
	self:_restoreBaseDeferred()
	return true
end

function BaseShotgun:fire(): boolean
	return self:_fireShotgunBlast(self:_fireOptions())
end

return BaseShotgun
