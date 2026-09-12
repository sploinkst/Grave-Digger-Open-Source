local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Grace\' Service Revolver"
v1.desc = "The ever powerful service revolver of the great Golden Empire."
v1.lore = "The Empire\'s third accepted service pistol design - originally known as the Model 3 - the \'Grace\' is somewhat of an antiquated design that nonetheless proves reliable in all manner of contexts, from a self-defense implement to a backup for a more conventional primary weapon.\n\nThe Empire did not initially commission the design - created independently by the Solace Coalition, the Empire first discovered the design in the defense of a Solace milling factory from an unsanctioned Nation attack - and following the discreet seizure and inspection of one of these revolvers by an Imperial Officer, the design was quickly adopted and made a staple of Imperial arsenals."
v1.size = 1
v1.icon = "17601078078"
v1.animations = "scho"
v1.ammo_give = ".45 Lead"
v1.melee_sound = "pistol"
v1.assists = {
    "A reliable back up that\'s fast to draw and aim.",
    "Agile with lesser movement penalties compared to rifles.",
    "Spin your revolver with [@ALT].",
    "Time your spins for style."
}
v1.tooltype = "gun"
v1.damage = 120
v1.range = 30
v1.range_damage = 105
v1.far = 70
v1.far_damage = 70
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 8
v1.moving_accuracy = 50
v1.fire_rate = 0.75
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.2
v1.aim_speed = 0.125
v1.wound = 1
v1.length = 4
v1.recoil = 15
v1.recoil_count = 6
v1.movement = 0.5
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 6
v1.chamber = false
v1.reload_start = 1.1
v1.reload_empty = 0
v1.reload_loop = 0.4
v1.reload_loop_after = 0.1
v1.reload_end = 0.65
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
