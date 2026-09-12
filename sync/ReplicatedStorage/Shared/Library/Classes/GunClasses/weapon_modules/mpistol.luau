local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Hope\' Automatic Pistol"
v1.desc = "A legendary handgun that needs no introduction."
v1.lore = "The boy once found a beautiful waterfall, hidden away from the eyes of his peers, a land not in jurisdiction of either the Golden Empire nor Royal Nation, un-marked, never discovered and never reported.\n\nHe kept to himself, often desperately trying to forget the past, knowing that every minute of doing so haunts him, so he fled to the waterfall.\n\nThen he came face to face with a girl, rifle raised, ready to take his life.. but yet hesitated.\n\nWhy? He was the enemy, there wasn\'t any reason not to\226\128\148even if this area was off limits\226\128\148nobody would know.\n\nThey spoke, they spoke of the lives they\'ve taken, they spoke of the lives that saved them, they spoke of the war and the fragility of life.\n\nIt wasn\'t long until they met with a Solace Priest in secrecy, he talked of a tunnel that could bring one to the outside, but he warned: a demon was coming for all of them and you can\'t escape it.\n\nThe story feels un-finished.. perhaps there is something still missing..\n\nTake the pistol and un-cover the end of the story."
v1.size = 1
v1.icon = "87131177597373"
v1.animations = "mpistol"
v1.ammo_give = ".45 Auto"
v1.melee_sound = "pistol"
v1.assists = {
    "High power, reliable, magazine fed pistol.",
    "Magazines provide relatively fast reloads, but low reserves.",
    "You will be unable to reload without sufficient reserves.",
    "Hold [Q] to remember."
}
v1.tooltype = "gun"
v1.damage = 90
v1.range = 30
v1.range_damage = 85
v1.far = 80
v1.far_damage = 80
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 1
v1.wallpen_distance = 30
v1.wallpen_studs = 2
v1.accuracy = 6
v1.moving_accuracy = 40
v1.fire_rate = 0.35
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.275
v1.aim_speed = 0.2
v1.wound = 1
v1.length = 4
v1.recoil = 12
v1.recoil_count = 6
v1.movement = 1
v1.firing_movement = 1.5
v1.firing_movement_last = 0.5
v1.ammo_reserves = 1
v1.ammo_reserves_max = 2
v1.require_full_load = true
v1.capacity = 7
v1.chamber = true
v1.reload_start = 2
v1.reload_end = 1.15
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.32220459, -1.17378056, -0.236167908, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
