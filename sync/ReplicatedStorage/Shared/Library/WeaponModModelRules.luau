-- Exact geometry/color changes from Assets/Random/cosmetics.modify_variant.
-- Apply to clones only; templates and already-authored standalone mods remain safe.
local Rules = {
	pieper = {Remove={"body.suppressor"}, Muzzle=true},
	mosin = {Remove={"body.scope", "body.part"}, Color={
		["parts.casing.bullet"]=Color3.fromRGB(218,133,65),
		["parts.clip.bullets.bullet"]=Color3.fromRGB(218,133,65),
		["parts.clip.topbullet.bullet"]=Color3.fromRGB(218,133,65)}},
	springfield = {Remove={"body.suppressor", "body.suppressormetal"}, Show={"body.extendmag"}, Muzzle=true},
	mauser = {Remove={"body.body"}, Show={"body.expansion", "body.fileddownbody"}},
	autosg = {Remove={"body.handguard", "body.cap"}, Show={"body.shortcap", "body.shorthandguard"},
		Color={["parts.casing"]=Color3.fromRGB(61,26,26)}},
	enfield = {Show={"body.bipod1", "body.bipod2", "body.bipod3", "body.bipod4"}},
	steyr = {Show={"body.steyrstock1", "body.steyrstock2", "body.steyrstock3", "body.steyrstock4"}},
	saa = {Show={"body.steyrstock1", "body.steyrstock2", "body.steyrstock3"}, Color={
		["parts.casing"]=Color3.fromRGB(91,93,105),
		["parts.casing.bullet"]=Color3.fromRGB(248,248,248)}},
	dbgun = {Hide={"parts.barrel"}, Show={"parts.barrel.shortbarrel"}, Muzzle=true},
	henry = {Remove={"body.bayonet"}, Show={"body.halesight1", "body.halesight2", "body.halesight3"},
		BrickColor={["parts.casing.bullet2"]=BrickColor.new("Maroon")}},
	lever = {Remove={"body.barrel"}, Show={"body.shortbarrel", "parts.lever.shortlever"},
		Hide={"parts.lever.leverpiece"}, Color={["parts.casing.bullet"]=Color3.fromRGB(55,56,63)}, Muzzle=true},
	remington = {Remove={"body.wood", "parts.barrelpivot.barrel", "parts.barrelpivot.barrelwood"},
		Show={"body.longstock", "body.longstockplate", "parts.barrelpivot.longbarrel",
			"parts.barrelpivot.longbarrelwood", "parts.barrelpivot.longbarrelwoodscrew"}, Muzzle=true},
}
for index=1,6 do
	Rules.saa.Color["parts.cylinder.round" .. index] = Color3.fromRGB(91,93,105)
	Rules.saa.Color["parts.cylinder.round" .. index .. ".bullet"] = Color3.fromRGB(248,248,248)
end

local ModelRules = {Definitions=Rules}
function ModelRules.Find(model, path)
	local current = model
	for piece in path:gmatch("[^.]+") do
		current = current and current:FindFirstChild(piece)
	end
	return current
end
function ModelRules.Apply(model, family, modified)
	local rule = Rules[family]
	if not rule then return end
	for _, path in ipairs(rule.Show or {}) do
		local part = ModelRules.Find(model,path)
		if part and part:IsA("BasePart") then part.Transparency = modified and 0 or 1 end
	end
	if not modified then return end
	for _, path in ipairs(rule.Remove or {}) do
		local part = ModelRules.Find(model,path)
		if part then part:Destroy() end
	end
	for _, path in ipairs(rule.Hide or {}) do
		local part = ModelRules.Find(model,path)
		if part and part:IsA("BasePart") then part.Transparency = 1 end
	end
	for _, property in ipairs({"Color", "BrickColor"}) do
		for path, value in pairs(rule[property] or {}) do
			local part = ModelRules.Find(model,path)
			if part and part:IsA("BasePart") then part[property] = value end
		end
	end
	if rule.Muzzle then
		local alternate = ModelRules.Find(model,"special.altmuzzle")
		if alternate then
			local original = ModelRules.Find(model,"special.muzzle")
			if original then original:Destroy() end
			alternate.Name = "muzzle"
		end
	end
end
return ModelRules
