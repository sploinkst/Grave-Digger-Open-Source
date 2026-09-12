local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Conscript Lantern"
v1.desc = ""
v1.lore = ""
v1.size = 1
v1.icon = "17778483663"
v1.animations = "lantern"
v1.assists = {
    "ENTRY NUMBER 17.",
    "DARK, DARKER, YET DARKER.",
    "THE DARKNESS KEEPS GROWING.",
    "THE SHADOWS CUTTING DEEPER.",
    "PHOTON READINGS... NEGATIVE."
}
v1.tooltype = "lantern"
v1.damage = 90
v1.range = 0
v1.range_damage = 0
v1.pen = 1
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.75
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 1
v1.aim_speed = 0.5
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 1
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.capacity = 0
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.20967102, -0.820671082, 0.010559082, 1, 0, 0, 0, 0.999999523, 0, 0, 0, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-1.20967102, -0.820671082, 0.010559082, 1, 0, 0, 0, 0.999999523, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(0.499038696, -0.70711112, -0.444458008, -1, 0, 0, 0, 0, -0.99999994, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
