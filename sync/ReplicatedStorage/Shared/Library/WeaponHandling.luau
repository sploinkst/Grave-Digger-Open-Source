-- Durations in seconds, audited against GunClasses/weapon_modules.
-- Explicit membership keeps variants, elite kits and unverified controllers out.
local WeaponIds = require(script.Parent.WeaponIds)
local Classes = require(script.Parent.ClassDefinitions)
local Handling = {}
Handling.Baseline = {
	AdjudicatorRifle = {draw = 0.8, aim = 0.4},
	HellionShotgun = {draw = 1, aim = 0.35},
	OkhotnikCrossbow = {draw = 0.55, aim = 0.125},
	EquineShotgun = {draw = 0.95, aim = 0.35},
	JesseRifle = {draw = 0.65, aim = 0.25},
	JudgementRifle = {draw = 1.2, aim = 0.4},
	PrinceRifle = {draw = 0.75, aim = 0.35},
	CrestfallRifle = {draw = 0.75, aim = 0.275},
	AuclairPistol = {draw = 0.4, aim = 0.2},
	HonourPistol = {draw = 0.275, aim = 0.2},
	VolkRifle = {draw = 1, aim = 0.35},
	HopePistol = {draw = 0.275, aim = 0.2},
	KnellRevolver = {draw = 0.25, aim = 0.175},
	NegotiatorShotgun = {draw = 0.35, aim = 0.3},
	TalonRevolver = {draw = 0.05, aim = 0.125},
	GraceRevolver = {draw = 0.2, aim = 0.125},
	WhisperRifle = {draw = 0.75, aim = 0.35},
	UnionPistol = {draw = 0.275, aim = 0.2},
	KingslayerRevolver = {draw = 0.5, aim = 0.3},
}

function Handling.IsBaseline(name: string): boolean
	return Handling.Baseline[WeaponIds.Canonical(name)] ~= nil
end

function Handling.Duration(player: Player, duration: number, kind: string): number
	local character = player.Character
	local modifier = character and character:GetAttribute(kind == "draw" and "DrawSpeed" or "AimSpeed") or 1
	if character then
		modifier *= character:GetAttribute(kind == "draw" and "OrderDrawMultiplier" or "OrderAimMultiplier") or 1
		modifier *= character:GetAttribute("RallyHandlingMultiplier") or 1
	end
	if kind ~= "draw" and character then
		modifier *= character:GetAttribute("DebuffAimSpeedMultiplier") or 1
	end
	if Classes.HasPerk(player, "Black Hand") or Classes.HasPerk(player, "BlackHand") or Classes.HasPerk(player, "blackhand") then
		modifier *= if kind == "draw" then 1.4 else 1.14
	end
	local seconds = duration / math.max(modifier, 0.01)
	return if kind == "draw" then math.max(seconds, 0.001) else math.clamp(seconds, 0.125, 10)
end

-- Reach 99% of a stationary target over the authored aim duration, independent of FPS.
function Handling.Alpha(dt: number, duration: number): number
	return 1 - math.exp(-math.log(100) * math.max(dt, 0) / math.max(duration, 0.001))
end

return Handling
