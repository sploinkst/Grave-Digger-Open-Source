local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Heavy Lance"
v1.desc = "A large, sweeping steel capable of taking many lives at once and a flag of loyalty."
v1.lore = "The Lancers are the shining beacon of this horrible war, a sign of fearless-ness and unparamount devotion to the cause.\n\nOften times considered fanatics who will charge head first into the enemy, it is nonetheless effective when seeing your fellow allies skewered by the un-waivering loyalty and wrath of their oppositions.\n\nWhether it is the bayonet of the Royal Nation or the pole-axe of the Golden Empire, when raised high and their flags billow in the air, fear will always take the hearts of the enemy as they ask themselves: Who will be the corpse hoisted into the spears of zealotry?"
v1.size = 2
v1.icon = "101804862805033"
v1.alt_team_icon = "83022012975342"
v1.alt_team_model = "empirelance"
v1.animations = "lance"
v1.melee_sound = "lance"
v1.assists = {
    "Regular attacks perform sweeps that can hit multiple opponents.",
    "[Aim] to perform swift, lethal Stabs that require precision.",
    "Press [@CHECK] to raise your flag high, inspiring Morale to all nearby.",
    "Press [@ALT] at a Full Sprint to initiate a Lance Charge.",
    "Lance Charges are not effective for a short period after starting."
}
v1.tooltype = "melee"
v1.damage = 130
v1.range = 7.75
v1.range_damage = 0
v1.pen = 3
v1.melee_damage = 130
v1.melee_stab_damage = 180
v1.melee_swing_speed = 0.7
v1.melee_range = 7.75
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.7
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 1
v1.aim_speed = 0.5
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 0
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.66595459, 0.661320448, 0.491149902, -0.766044438, -0.642787576, 0, -0.642787576, 0.766044438, 0, -0, 0, -1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.66595459, 0.661320448, 0.491149902, -0.766044438, -0.642787576, 0, -0.642787576, 0.766044438, 0, -0, 0, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.334197998, -0.969068766, 0.2840271, 0, 0, -1, 0.999998391, 0, 0, 0, -0.99999845, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
