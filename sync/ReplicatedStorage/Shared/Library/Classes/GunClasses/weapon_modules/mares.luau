local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Auclair\' Lever Pistol"
v1.desc = "Deadly lever rifle cut down to a pistol size."
v1.lore = "The Solace Coalition provides many supplies to both the two factions in war, Empire and Nation alike, discriminating between neither and keeping their heads down so the war can come to an end sooner.\n\nVery rarely will either side lay a hand on Solace workers as a result, the trust between the two is instrumental to the war, if one side fails to uphold their trust, Solace would be under protection of the other side, and the war would come to a swift end.\n\nBut it begs the question, \'Why dont we just favour a side?\', asked Jean Auclair, in-experienced in the war, twirling the cut down Lever Rifle.\n\n\'Because we would be seen as nothing more than rats, and many civilians will be killed.\', said August Woodrow, a veteran and historian.\n\nThe Solace Coalition was not only just a faction, but also a refuge for those who did not want to take the life of others, of course\226\128\148that\'d mean giving up a lot of luxuries to live a life of nothing more than mining, assembling and aiding, but that was better than being cut apart by a machine gun.\n\nLives are not just a resource you can use to \'win\' the war faster, maybe some day you will learn to appreciate that; but until then, this pistol will serve as a reminder for the people that build your gear, load your guns, feed your hunger and bury your body."
v1.size = 1
v1.icon = "87759641915052"
v1.animations = "mares"
v1.ammo_give = ".44 Army"
v1.melee_sound = "pistol"
v1.assists = {
    "Packs a punch with decent range and control for a pistol.",
    "Fast and non-wasteful reloads; ammo efficient.",
    "Poor handling compared to other pistols.",
    "[@ALT] to fire one handed, reducing stability and improving handling.",
    "Rate of fire is hampered when wielded in one hand."
}
v1.tooltype = "gun"
v1.damage = 110
v1.range = 50
v1.range_damage = 85
v1.far = 70
v1.far_damage = 70
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 10
v1.moving_accuracy = 80
v1.fire_rate = 0.7
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.4
v1.aim_speed = 0.2
v1.wound = 1
v1.length = 4
v1.recoil = 6
v1.recoil_count = 6
v1.movement = 1
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 7
v1.chamber = false
v1.reload_start = 0.7
v1.reload_empty = 2
v1.reload_loop = 0.95
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
