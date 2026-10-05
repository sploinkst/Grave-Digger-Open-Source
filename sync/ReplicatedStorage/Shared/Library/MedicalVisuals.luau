local Rules = require(script.Parent.ChemicalRules)
local Visuals = {}
function Visuals.TintBottle(model, mix)
	if not model then return end
	local color = Color3.fromRGB(table.unpack(Rules.MixtureColor(mix)))
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and (part.Name == "insidewater" or part.Name == "InsideFluid") then part.Color = color end
	end
end
return Visuals
