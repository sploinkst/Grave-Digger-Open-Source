--!strict

local HelmetRules = {}

HelmetRules.Action = {
	Block = "Block",
	KnockOff = "KnockOff",
	Obliterate = "Obliterate",
}

export type RangeBand = "Close" | "FirstFalloff" | "SecondFalloff"
export type Action = "Block" | "KnockOff" | "Obliterate"

local function readClassName(character: Model?): string?
	if not character then return nil end
	local attr = character:GetAttribute("Class")
	if type(attr) == "string" then return string.lower(attr) end
	local classValue = character:FindFirstChild("class")
	if classValue and classValue:IsA("StringValue") then return string.lower(classValue.Value) end
	return nil
end

function HelmetRules.RangeBand(distance: number, closeRange: number?, farRange: number?): RangeBand
	if closeRange and distance <= closeRange then
		return "Close"
	end
	if farRange and distance <= farRange then
		return "FirstFalloff"
	end
	return "SecondFalloff"
end

function HelmetRules.EffectivePenetration(basePenetration: number, character: Model?, helmet: Instance?): number
	local className = readClassName(character)
	local penetration = basePenetration

	if className == "conscript" then
		penetration += 1
	elseif className == "vanguard" and penetration < 4 then
		penetration -= 1
	end

	if helmet and helmet:GetAttribute("ConscriptHelmet") == true then
		penetration += 1
	end
	if helmet and helmet:GetAttribute("VanguardHelmet") == true and penetration < 4 then
		penetration -= 1
	end

	return math.clamp(penetration, 0, 5)
end

function HelmetRules.ResolveBullet(
	basePenetration: number,
	rangeBand: RangeBand,
	character: Model?,
	helmet: Instance?
): Action
	local className = readClassName(character)
	local effectivePenetration = HelmetRules.EffectivePenetration(basePenetration, character, helmet)
	local lancerHelmet = className == "lancer"
		or (helmet ~= nil and helmet:GetAttribute("LancerHelmet") == true)
		or (helmet ~= nil and helmet:GetAttribute("Unknockable") == true)

	if effectivePenetration >= 5 then
		return HelmetRules.Action.Obliterate
	end

	if lancerHelmet then
		return HelmetRules.Action.Block
	end

	if effectivePenetration >= 4 then
		return if rangeBand == "Close" then HelmetRules.Action.Obliterate else HelmetRules.Action.KnockOff
	end
	if effectivePenetration >= 3 then
		return HelmetRules.Action.KnockOff
	end
	if effectivePenetration == 2 then
		return if rangeBand == "SecondFalloff" then HelmetRules.Action.KnockOff else HelmetRules.Action.Block
	end
	if effectivePenetration == 1 then
		return if rangeBand == "FirstFalloff" then HelmetRules.Action.KnockOff else HelmetRules.Action.Block
	end

	return HelmetRules.Action.Block
end

return HelmetRules
