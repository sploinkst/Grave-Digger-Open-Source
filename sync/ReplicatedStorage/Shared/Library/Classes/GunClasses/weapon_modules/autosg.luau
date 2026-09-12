local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Hellion\' Automatic Shotgun"
v1.desc = "High capacity crowd-sweeper capable of annihilating groups in close range."
v1.lore = "\'The Hellion\' was a propaganda film made by the Royal Nation during the development of a new service shotgun designed to compete against the Golden Empire\'s \'Equine\'\226\128\148ironically\226\128\148the movie depicted the shotgun being used by said Golden Empire men who were possessed by the spirit of the reaper and depicted them as nothing more than crazed madmen who turned on their own soldiers as much as the enemy.\n\nOf course the Royal Nation prevailed in the end, for human grit will always beat unholy worship.\n\nThe film made its way across all territories, both the Golden Empire and Solace Coalition, with the Empire mocking the amateur directing and acting.\nNonetheless, a story like this for once gave name to a weapon that didn\'t involve any horrific bloodshed, violence or politics.\nPerhaps this shows there is still a glimmer of humanity left in this war."
v1.size = 2
v1.icon = "117308271652473"
v1.animations = "autosg"
v1.ammo_give = "00 Buckshot"
v1.melee_sound = "rifle"
v1.assists = {
    "Semi-automatic with slow but unwasteful reloads.",
    "Be wary of the heavy recoil and low effective range.",
    "Runs dry quickly without moderation.",
    "Mind the low ammo count.",
    "[@ALT] to shoulder aim, reducing mobility but greatly improving recoil control.",
    "Fires in a fixed spread pattern, make sure your aim is on point."
}
v1.tooltype = "gun"
v1.damage = 22
v1.range = 20
v1.range_damage = 12
v1.far = 35
v1.far_damage = 9
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 40
v1.wallpen_studs = 3
v1.accuracy = 20
v1.moving_accuracy = 20
v1.fire_rate = 0.4
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 1
v1.aim_speed = 0.35
v1.wound = 1
v1.pellets = 9
v1.length = 4.5
v1.recoil = 12
v1.recoil_count = 9
v1.movement = 2
v1.firing_movement = 2
v1.firing_movement_last = 0.75
v1.ammo_reserves = 1
v1.ammo_reserves_max = 2
v1.capacity = 7
v1.chamber = false
v1.reload_start = 0.75
v1.reload_empty = 2
v1.reload_loop = 1
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.950378418, 0.100975513, 0.597045898, 0, 1, 0, -1, 0, 0, 0, 0, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.00793457031, 0.0137820244, 0.597045898, 0, -1, 0, -1, 0, 0, 0, 0, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
