local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Talon\' Army Revolver"
v1.desc = "A swift revolver with a bite and capable of firing from the hip."
v1.lore = "A venerable and well-worn design originating in the Royal Nation\'s territory, this iconic pistol stands the test of time and serves as a symbol of patriotism and pride within the Royal Nation\'s ideology - ideals that are similarly represented by the symbol of soaring Eagles, hence the moniker.\n\nUnlike most other weapons, the \'Talon\' is mostly produced domestically by the Nation rather than the Solace Coalition, a symbol of defiance against the fanatics - though, the irony of using such a symbol against the Nation\'s own soldiers is not lost on the Empire.\n\nPerhaps most famously wielded by King Helfort in an Empire Shock Trooper assassination attempt, six shots of .45 Flat proved adequate to put down each and every assailant with zero casualties on the Nation\'s part, further cementing the pistol\'s reputation of reliability under mud, muck and grime."
v1.size = 1
v1.icon = "18771441971"
v1.animations = "saa"
v1.ammo_give = ".45 Flat"
v1.melee_sound = "pistol"
v1.assists = {
    "Fan fire by firing from the hip, in-accurate, but deadly.",
    "Exceptional performance while firing on the move.",
    "Lacks precision compared to other weapons.",
    "[@ALT] to ready yourself for a Quick-draw.",
    "Quick-draw shots are perfectly accurate no matter what."
}
v1.tooltype = "gun"
v1.damage = 105
v1.range = 35
v1.range_damage = 90
v1.far = 60
v1.far_damage = 70
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 18
v1.moving_accuracy = 38
v1.fire_rate = 0.7
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.05
v1.aim_speed = 0.125
v1.wound = 1
v1.length = 3.5
v1.recoil = 15
v1.recoil_count = 6
v1.movement = 0.5
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 6
v1.chamber = false
v1.reload_start = 0.8
v1.reload_empty = 0
v1.reload_loop = 1.1
v1.reload_loop_after = 0.1
v1.reload_end = 0.6
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
