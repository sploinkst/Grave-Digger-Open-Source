local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Construct Hammer"
v1.desc = "Build and provide for those in need with various defensive Constructs."
v1.lore = "Efficient in construction and demolition, the venerable Rooks take pride in their work and their body.\n\nFew can stand up to treacherous works of the Rooks, while most may believe the Lancers or Vanguards as the most fearless, it is truly the Rooks who can weather the greatest storms and show true bravery amongst their un-appreciated efforts.\n\nMining in the caverns have always been dangerous, but for more reasons than just exhaustion, tunnel cave-ins and wayward traps of mother nature; it is also time.\nEvery second spent that is not digging towards the next forward camp or preparing defenses is a second for the enemy to take advantage of.\n\nThey train day and night, shaping their bodies and donning heavy gear that can take shrapnel and collapses, the Rooks will be the ones to pave victory to a squad, the pillar of true hope, not twisted fanaticism."
v1.size = 1
v1.icon = "17625268073"
v1.animations = "pick"
v1.melee_sound = "hammer"
v1.assists = {
    "Press [@ALT] to enter and exit Build Mode.",
    "Press [@RELOAD] while in Build Mode to cycle through Constructs.",
    "Press [@CHECK] while in Build Mode will destroy all of the selected Constructs you\'ve placed.",
    "Hit with your Hammer to build and repair friendly Constructs."
}
v1.tooltype = "hammer"
v1.damage = 50
v1.range = 6
v1.range_damage = 0
v1.pen = 1
v1.melee_damage = 65
v1.melee_swing_speed = 0.4
v1.melee_range = 6
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.4
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.5
v1.aim_speed = 0.2
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 0
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.capacity = 1
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(1.065979, -1.0604744, 0.0610122681, 0, 0, -1, 0.5, 0.866025388, 0, 0.866025388, -0.5, 0)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.183654785, -0.939495087, 0.183135986, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
