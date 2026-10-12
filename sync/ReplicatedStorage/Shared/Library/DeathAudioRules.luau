-- Anatomical sound mapping. The supplied client masters omit server gib dispatch.
local Rules = {}
function Rules.Category(part, explosion)
	if explosion then return "gib" end
	local name = string.lower(tostring(part or ""))
	if name == "head" then return "headgib" end
	if name:find("arm", 1, true) or name:find("leg", 1, true) or name:find("hand", 1, true) or name:find("foot", 1, true) then return "dismember" end
	return "gib"
end
return Rules
