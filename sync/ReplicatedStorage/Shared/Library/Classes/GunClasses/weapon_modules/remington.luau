local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Negotiator\' Pocket Shotgun"
v1.desc = "A lethal single shot shotgun greatly cut down to save on weight."
v1.lore = "Come push to shove, many \'normal\' people such as you and I don\'t wish to participate in a war, a mindless bloodshed, a fruitless endeavour\226\128\148so we opt to run, and by god do we run far.\n\n\'Bandits\' are a pejorative term given to those who refuse to be conscripted to the war, with either the Royal Nation, Golden Empire or Solace Coalition, these people run, hiding away in fear and often are considered \'shoot on sight\' to make an example of to the rest.\n\nUsing scavenged\226\128\148or stolen\226\128\148supplies from previous skirmishes, Bandits had to make-shift and make do with whatever they could get their hands on, for not every Bandit is a nice person just trying to escape the war, there are plenty who will gladly stab you in the back for an extra days worth of supplies.\n\nThe \'Negotiator\' came out of this, a cut down single barrel shotgun that was often whipped out in tense moments during deals or conflicts, the No 3 Shotgun was cheap, easy to find, often left behind in caches and usually not given a second thought of\226\128\148naturally of course, what use does a single barrel shotgun serve you when you can have two barrels instead?\nIt doesn\'t help that such a weapon remain so unused in caches that they often, due to rust, were falling apart at the seams\226\128\148or hinge in most cases.\n\nBut one barrel, in a slim package that can fit right in the waist band or concealed behind a coat?\nNow that might be worth something to someone\226\128\148especially if they\'re on the receiving end of the barrel."
v1.size = 1
v1.icon = "114846330601183"
v1.animations = "remington"
v1.ammo_give = "00 Buckshot"
v1.melee_sound = "pistol"
v1.assists = {
    "In-effective outside of its intended range, but highly lethal within.",
    "Wide spread - pellets will fail to knock off helmets past close range.",
    "Mind the low ammo count.",
    "Fast handling compared to shotguns, slower compared to pistols.",
    "Fire from the hip to throw your gun as a last ditch resort.",
    "[@ALT] to toggle between throwing and melee.",
    "Fires in a fixed spread pattern, make sure your aim is on point."
}
v1.tooltype = "gun"
v1.damage = 25
v1.range = 25
v1.range_damage = 15
v1.far = 30
v1.far_damage = 15
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pellets = 9
v1.pen = 1
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 55
v1.moving_accuracy = 55
v1.fire_rate = 0.4
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.35
v1.aim_speed = 0.3
v1.wound = 1
v1.length = 4
v1.recoil = 30
v1.recoil_count = 9
v1.movement = 1
v1.firing_movement = 2
v1.firing_movement_last = 0.75
v1.ammo_reserves = 3
v1.ammo_reserves_max = 4
v1.capacity = 1
v1.chamber = false
v1.reload_start = 3.5
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_loop_after = 0
v1.reload_end = 0
v1.reload_full = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.32220459, -1.17378032, -0.400718689, 0, 0, -1, 0.999999821, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
