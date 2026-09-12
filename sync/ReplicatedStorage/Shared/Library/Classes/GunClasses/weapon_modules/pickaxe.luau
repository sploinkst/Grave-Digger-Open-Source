local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Heavy Pick"
v1.desc = "The war and duty built pick for forging tunnels or embedding into skulls."
v1.lore = "By the greatest of dangers each day I\'m surrounded\nI hang in the air by a rope or a chain\nThe mine may give in, I may be killed or wounded\nOr perish by damp or the fire of a flame\nBut what would you do if it weren\'t for our labours\nIn greatest starvation your days you would pass\nFor we would provide you with life\'s greatest blessing\nSo do not despise a poor collier lass\n\nAll the day long you may say we are buried\nDeprived of the light and the warmth of the sun\nAnd often at night from our beds we are hurried\nThe water is in and barefoot we run\nAnd though we go ragged and black are our faces\nAs kind and as free as the best we\'ll be found\nAnd our hearts are more white than your lords\' in high places\nAlthough we\'re poor colliers that work underground"
v1.size = 1
v1.icon = "17770310254"
v1.animations = "pickaxe"
v1.melee_sound = "pickaxe"
v1.assists = {
    "Mines faster and stronger than the regular Pick.",
    "Can be swung as a lethal melee weapon in a pinch.",
    "Swings can take off helmets and headshot.",
    "[@ALT] to change Mining Strength.",
    "[@RELOAD] to re-sharpen a dulled Pick.",
    "An unsharpened Pick is still useful, but has weaker strength."
}
v1.tooltype = "pick"
v1.damage = 90
v1.range = 7
v1.range_damage = 0
v1.pen = 3
v1.melee_damage = 90
v1.melee_swing_speed = 0.5
v1.melee_range = 7
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.5
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
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(0.771057129, 0.83040905, 0.625976562, -0.98480773, 0.173648179, 0, 0.173648179, 0.98480773, 0, 0, 0, -1) * CFrame.new(0, -0.5, 0)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.327880859, -0.859725237, 0.279418945, 2.83122063e-7, 0, -0.99999851, 0.999996603, 0, 3.12924357e-7, 0, -0.999996185, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
