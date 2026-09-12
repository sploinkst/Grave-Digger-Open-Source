local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Whisper\' Silenced Rifle"
v1.desc = "A silent and powerful bolt rifle that leaves no bullet trails."
v1.lore = "Venerable, iconic, and knock-off are words that would often be used to describe this rifle, yet despite the reputation, it still held up to this very day as a favoured rifle for many Royal Nation soldiers.\n\n\'Inspired\', although that would be a strong word off a German and Golden Empire design, the \'Whisper\' gained its name for its iconic Silencer designed by Maxim, earning its name from the gasps of Golden Empire soldiers supposedly whispering their last prayers whilst red poured from a severed carotid artery.\n\nOther than that? It\'s just another rifle, it wasn\'t anything fancy, not all rifles had to be, but it did have one last trick up its sleeve: hunting.\n\nWhen the war went under the dirt, food was an immediate concern, living off ration cans and stews would only last so long, thus the hunting of flying mammals or rodents were common, however a full powered rifle round would prove rather overkill for such an application, as well as the fact that said rounds could be instead used in the chest of another soldier.\n\nA prototype would be un-earthed, a device able to be slotted where the bolt would rest, feeding a tiny .30-18 Automatic cartridge in a 40 round magazine fired semi-automatically. There were problems however; jams were frequent, the stopping power of .30 Light was debatable, and the magazines are large and cumbersome, making them ill-suited for war.. but just about perfect for a hunter to pick off creatures that live amongst these walls, letting us prolong our starvation just a little longer."
v1.size = 2
v1.icon = "130781995861130"
v1.animations = "springfield"
v1.ammo_give = ".30-06 Ball"
v1.melee_sound = "rifle"
v1.assists = {
    "Exceptionally quiet, can not be heard at a distance.",
    "Murders with this rifle do not reveal your position to the victim.",
    "[@ALT] to swap out your bolt with an experimental Auto-loader Device.",
    "Auto-loader turns your bolt rifle into a semi automatic carbine.",
    "Mind the very weak .30 Light cartridge and frequent malfunctions."
}
v1.tooltype = "gun"
v1.damage = 130
v1.range = 70
v1.range_damage = 120
v1.far = 100
v1.far_damage = 115
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 3
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 6
v1.moving_accuracy = 100
v1.fire_rate = 0.3
v1.cycle = 0.55
v1.cycle_rest = 0.15
v1.draw_speed = 0.75
v1.aim_speed = 0.35
v1.wound = 1
v1.length = 5.5
v1.recoil = 8
v1.recoil_count = 6
v1.movement = 1
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 3
v1.ammo_reserves_max = 4
v1.capacity = 5
v1.chamber = false
v1.reload_start = 1.5
v1.reload_empty = 1.75
v1.reload_loop = 0.65
v1.reload_end = 0.75
v1.reload_full = 1.5
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.843444824, -0.160831451, 0.563819885, -0.0857552588, 0.996316195, -2.14072588e-6, -0.996316195, -0.0857552588, 6.89330363e-6, 6.68433131e-6, 2.72397665e-6, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.0671386719, 0.0569257736, 0.563720703, -0.085755609, -0.996316195, 1.70646985e-7, -0.996320546, 0.0857559666, 8.59710667e-7, -2.90349675e-7, -2.8889346e-7, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {
    ["suppressed"] = true
}
return v1;
