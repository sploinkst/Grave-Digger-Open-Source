-- Animation remaps and magazine spring resistance from the supplied tool master.
local Behavior = {}
function Behavior.Configure(config, variant)
	local map = config.AnimationMap or {}
	local function remap(entries) for key, value in pairs(entries) do map[key] = value end end
	if variant == "lever" or variant == "autosg" or variant == "steyr" then
		remap({Aim="alt_changeaim", Aim_Left="alt_changeaim_left", Fire="alt_changefire", Fire_Left="alt_changefire_left"})
		if variant ~= "steyr" then remap({Fire_Last="alt_changefire_last", Fire_Last_Left="alt_changefire_last_left"}) end
		if variant == "lever" then remap({Fire_Empty="alt_changefire_empty", Fire_Empty_Left="alt_changefire_empty_left"}) end
		if variant == "steyr" then remap({Draw="steyrdraw"}) end
	elseif variant == "saa" then
		remap({Draw="stock_draw", Aim="stock_aim", Aim_Left="stock_aim_left", Fire="stock_fire", Fire_Left="stock_fire_left", Fire_Empty="stock_fire_empty", Fire_Empty_Left="stock_fire_empty_left"})
	elseif variant == "remington" then
		remap({Draw="long_draw", Hold="long_held", Aim="long_aim", Aim_Left="long_aim_left", Fire="long_fire", Fire_Left="long_fire_left", Melee1="long_melee1", Melee2="long_melee2", Short="long_short", Check="long_check", Sprint="long_sprint"})
		map.Sprint_Greyhound = false
	elseif variant == "dbgun" then
		remap({Sprint_Greyhound="sprint_alt_greyhound"})
	elseif variant == "springfield" then
		remap({Reload_Heavyloop="reload_heavyloop"})
	end
	config.AnimationMap = map
end
function Behavior.FlyboyLoading(capacity)
	if capacity >= 23 then return "Reload_Heavyloop", 1.4 end
	if capacity >= 21 then return "Reload_Heavyloop", 1.3 end
	if capacity >= 19 then return "Reload_Heavyloop", 1.2 end
	if capacity >= 17 then return "Reload_Loop", 1.1 end
	return "Reload_Loop", 1
end
return Behavior
