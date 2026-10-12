local Rules = {
	MaxDurability = 40,
	MaxStones = 1,
	SharpenTime = 2.2,
	SharpenRecovery = 0.8,
	SharpenSpeed = 0.75,
	HeavySize = {16, 14, 14},
	WeakSize = {12, 10, 10},
	PreciseSize = {8, 8, 8},
	Messages = {
		Dulled = "My Pick has worn out, I can't mine at Heavy Strength.",
		Weak = "Mining at Weaker Strength.",
		Heavy = "Mining at Heavy Strength",
		NoStones = "I don't have any Sharpening Stones left.",
		AlreadySharp = "My Pick is already as sharp as it gets.",
	},
}

function Rules.Strike(durability, weak, precise)
	if precise then return "Precise", durability end
	if weak or durability <= 0 then return "Weak", durability end
	return "Heavy", math.max(0, durability - 1)
end

function Rules.SharpenError(durability, stones)
	if stones <= 0 then return "NoStones" end
	if durability >= Rules.MaxDurability then return "AlreadySharp" end
	return nil
end

return Rules
