	-- Playback ratios from toolScript, independent of Roblox track lengths.
-- Gameplay readiness and animation blend times are separate clocks in the master.
local Rules = {}
local durations = {
	Reload_Start = "reload_start", Reload_Empty = "reload_empty", Reload_Loop = "reload_loop",
	Reload_Loop_Alt = "reload_loop", Reload_Loop_After = "reload_loop_after",
	Reload_End = "reload_end", Reload_End_Locked = "reload_end", Reload_Alt = "reload_alt",
	Reload_Alt_Extra = "reload_alt", Reload_Full = "reload_full", Reload_Clip = "reload_full",
	Reload_Clip_Start_Empty = "reload_start", Reload_Clip_Start_Empty_Novet = "reload_start",
	Reload_Clip_Start_One = "reload_start",
}
local shared = {
	Hold = {speed = 0.25, fade = 0},
	Sprint = {speed = 0.8, fade = 0.4}, Long_Sprint = {speed = 0.8, fade = 0.4},
	Sprint_Greyhound = {speed = 0.8, fade = 0.25},
	Aim = {speed = 0.5}, Aim_Left = {speed = 0.5}, Bipod_Aim = {speed = 0.5},
	Tag_Look = {speed = 0.5, fade = 0.1},
	Spin_Left = {speed = 2, fade = 0.1}, Spin_Right = {speed = 2, fade = 0.1},
	Quickdraw_Start = {speed = 1, fade = 0.2}, Quickdraw = {speed = 0.5, fade = 0.2},
	Choosing = {speed = 0.5, fade = 0.3},
	Drink = {speed = 0.5, fade = 0.1}, DrinkMotion = {speed = 0.5, fade = 0.1},
	DrinkDone = {speed = 0.5, fade = 0.1}, Clean = {speed = 0.5, fade = 0.1},
	ThrowUnder = {speed = 2, fade = 0.1}, ThrowOver = {speed = 2, fade = 0.1},
	Point = {speed = 1, fade = 0.3}, Flare = {speed = 1, fade = 0.1}, Flare_Right = {speed = 1, fade = 0.1},
	Telescope = {speed = 1.2, fade = 0.1}, ShieldPlace = {speed = 1.2, fade = 0.1},
	ShieldPlant = {speed = 1, fade = 0.1}, Use = {speed = 1, fade = 0.1},
	Flag = {speed = 1, fade = 0.1}, RaiseFlag = {speed = 1, fade = 0.2},
	Melee1 = {speed = 1, fade = 0.1}, Melee2 = {speed = 1, fade = 0.1},
	Alt_Melee1 = {speed = 1, fade = 0.1}, Alt_Melee2 = {speed = 1, fade = 0.1},
	Sharpen = {speed = 0.75, fade = 0.1},
}
local families = {
	crossbow = {Fire = {speed = 3, fade = 0.01}, Fire_Left = {speed = 3, fade = 0.01}, Speen = {speed = 1, fade = 0.1}},
	enfield = {
		Pedersen_Mag_Eject = {speed = 0.5},
		Pedersen_Bolt_Remove = {speed = 0.5, fade = 0.2}, Pedersen_Device_On = {speed = 0.5, fade = 0.2},
		Pedersen_Device_Off = {speed = 0.5, fade = 0.2}, Pedersen_Bolt_Place = {speed = 0.5, fade = 0.2},
		Load_Grenade = {speed = 2/3}, Cutoff_On = {speed = 2}, Cutoff_Off = {speed = 2, fade = 0.2},
		Load_Blank = {speed = 2/3}, Load_Blank_Vet = {speed = 2/3}, Unload_Grenade = {speed = 2/3},
		Blank_End = {speed = 2}, Blank_Reload = {speed = 1}, Discard_Grenade = {speed = 1},
		Blank_Boltback = {speed = 1, fade = 0.2},
	},
	springfield = {
		Pedersen_Mag_Eject = {speed = 0.5}, Pedersen_Mag_Out = {speed = 0.5, fade = 0.2},
		Pedersen_Bolt_Remove = {speed = 0.5, fade = 0.2}, Pedersen_Device_On = {speed = 0.5, fade = 0.2},
		Pedersen_Device_Off = {speed = 0.5, fade = 0.2}, Pedersen_Bolt_Place = {speed = 0.5, fade = 0.2},
		Pedersen_Mag_In = {speed = 0.5, fade = 0.2}, Pedersen_Jam = {speed = 1, fade = 0.2},
		Pedersen_Charge = {speed = 1, fade = 0.2}, Cycle_Pedersen = {speed = 1, fade = 0.2},
	},
	walker = {Reload_Start = {speed = 2, fade = 0.4}, Reload_Idle = {speed = 0.5},
		Reload_Dump = {speed = 1}, Reload_Cylinder = {speed = 103/30}, Reload_End = {speed = 2}},
	pieper = {Hammer_Lower = {speed = 2}, Hammer_Pull = {speed = 3, weight = 0.1},
		Spin_Cylinder = {speed = 1/1.3}},
	saa = {Spin_Start = {speed = 1.2, fade = 0.3}, Spin = {speed = 1.2, fade = 0.3}},
	henry = {Charge = {speed = 1.5, fade = 0.5}, Charge_Stop = {speed = 1.5, fade = 0.2}},
}
local function positive(value)
	return type(value)=="number" and value>0 and value<math.huge
end
function Rules.CheckDuration(weapon)
	if positive(weapon.ammo_check_duration) then return weapon.ammo_check_duration end
	local asset=weapon.MasterAssetName
	return asset=="crossbow" and 1 or (asset=="mpgun" or asset=="pugsley") and 2.5 or 1.5
end
function Rules.CycleDuration(duration,context)
	context=context or {}
	if context.rally then duration*=0.9 end
	if context.eliteBuff then duration*=0.8 end
	if context.quickdraw then duration*=0.955 end
	if context.restoration then duration*=1.2 end
	if context.conscript or context.training then duration*=1.2 end
	if context.rookHeavy then duration*=0.85 end
	return duration
end
function Rules.FireDuration(weapon, name)
	local asset=weapon.MasterAssetName
	local rate=weapon.FireInterval or weapon.fire_rate or 1
	if asset=="lever" or asset=="levervariant" then rate=0.725/0.9 end
	if (asset=="springfield" or asset=="springfieldvariant") and (weapon.Alt_Mode or weapon.PedersenMode) then return 0.5 end
	if not name:find("Empty") and weapon.RegisteredAnimations and weapon.RegisteredAnimations.Cycle and asset~="enfield" and asset~="enfieldvariant" then return 1 end
	return math.max(rate*0.9,0.001)
end
function Rules.SelectName(weapon,name,animations)
	if not weapon.IsFirearm or not weapon.IsVeteran or not name:find("Reload") then return name end
	local asset=weapon.MasterAssetName
	if asset=="rooklauncher" or asset=="springfieldvariant" then
		local regular=name:gsub("_Vet$",""); return animations[regular] and regular or name
	end
	if asset=="lebel" and name=="Reload_Empty" then return name end
	if asset=="scho" and weapon.Capacity<=0 and name=="Reload_Start" then return name end
	if not name:match("_Vet$") and animations[name.."_Vet"] then return name.."_Vet" end
	return name
end
function Rules.Playback(weapon, name)
	local base=name:gsub("_Vet$", "")
	local profile=table.clone(shared[base] or {})
	local asset=weapon.MasterAssetName or ""
	local family=families[asset] or families[asset:gsub("variant$", "")]
	for key,value in pairs(family and family[base] or {}) do profile[key]=value end
	if base=="Prime" and positive(weapon.PrimeTime) then profile.speed=1/weapon.PrimeTime; profile.fade=0.2 end
	if weapon.IsFirearm then
		if base:match("^Fire") or base:find("_Fire",1,true) or base:find("Changefire",1,true) or base=="Akimbo_Right" then
			if not (family and family[base]) then profile.speed=(base=="Akimbo_Right" and 0.6 or 1)/Rules.FireDuration(weapon,base) end
			profile.fade=profile.fade or 0.01
		elseif base:match("_Aim$") or base:match("_Aim_Left$") or base:find("Changeaim",1,true) then
			profile.speed=0.5
		elseif base=="Cycle" or base=="Cycle_Left" or base=="Bipod_Cycle" then
			if positive(weapon.cycle) then profile.speed=1/weapon.cycle end; profile.fade=0.1
		elseif base:match("^Check") then profile.speed=1/Rules.CheckDuration(weapon); profile.fade=0.1
		elseif durations[base] and positive(weapon[durations[base]]) and not (family and family[base]) then
			local duration=weapon[durations[base]]
			-- Veteran opening clips for Lebel/Scho are longer; Veteran is not a blanket speed buff.
			if name:match("_Vet$") and (weapon.MasterAssetName=="lebel" or weapon.MasterAssetName=="scho")
				and (base=="Reload_Start" or base=="Reload_Empty") then duration*=1.2 end
			profile.speed=1/duration; profile.fade=0.1
		end
	end
	return profile
end
return Rules
