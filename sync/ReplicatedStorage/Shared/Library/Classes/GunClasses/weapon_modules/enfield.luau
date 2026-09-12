local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Jesse\' Combat Rifle"
v1.desc = "A high capacity and agile rifle reloaded with Stripper Clips innately."
v1.lore = "Soon to be phased out of existence by the ubiquitous \'Prince\' Rifle, this formerly unknown rifle garnered the attention of a certain group of individuals for its sleek wood furniture, light weight, smooth action, and massive capacity, proving itself a cut above the rest compared to other \'generic\' rifles.\n\nThis certain group turned out to be the Nation\'s Jaeger Corps, and, following their seizure of a would-be production facility within Empire territory, the workers were given the job of manufacturing this no-name rifle - and though these workers had quite a showing of their conviction and loyalty to the Queen\'s Will, they were a far cry from the unbreakable zealots of the Lancer Legions.\n\nNo-one truly knows what happened inside that facility, as the workers were put to death following the completion of their work, but tortuous labor conditions, corporeal punishment, and even deliberate poisoning would not be out of the question, further fueling the Empire\'s propaganda campaign depicting the Nation as bloodthirsty dogs.\n\nDespite the attrocites wrought that day, the methods were nonetheless efficient, and the rifle was particularly adored by the local Sergeant Major - developing a technique where the middle finger would rest on the trigger, with the index and thumb on the bolt, enabling rapid fire on account of the rifle\'s particular boons.\n\nIt\'s said that even the most fearless of Empire men will turn tail and flee if he hears the rapid rapport of this newly-revived rifle, its name now synonymous with the man who realized its true potential."
v1.size = 2
v1.icon = "127196615975204"
v1.animations = "enfield"
v1.ammo_give = ".303 Spitzer"
v1.melee_sound = "rifle"
v1.assists = {
    "Utilises a unique bolting technique, improving rate of fire over other bolt rifles.",
    "Great capacity and clip reloads keep you in the fight for longer.",
    "Lighter and swifter than other bolt rifles, but suffers in precision.",
    "[@ALT] to load a Shrapnel Grenade dealing light damage, has a minimum arming distance."
}
v1.tooltype = "gun"
v1.damage = 130
v1.range = 50
v1.range_damage = 120
v1.far = 95
v1.far_damage = 95
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 3
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 12
v1.moving_accuracy = 80
v1.fire_rate = 0.2
v1.cycle = 0.55
v1.cycle_rest = 0.05
v1.draw_speed = 0.65
v1.aim_speed = 0.25
v1.wound = 1
v1.length = 5
v1.recoil = 10
v1.recoil_count = 6
v1.movement = 1
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 1
v1.ammo_reserves_max = 2
v1.capacity = 10
v1.chamber = false
v1.reload_start = 1.2
v1.reload_empty = 1.7
v1.reload_loop = 0.7
v1.reload_end = 0.65
v1.reload_full = 1.8
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.843444824, -0.160831451, 0.563819885, -0.0857552588, 0.996316195, -2.14072588e-6, -0.996316195, -0.0857552588, 6.89330363e-6, 6.68433131e-6, 2.72397665e-6, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.0671386719, 0.0569257736, 0.563720703, -0.085755609, -0.996316195, 1.70646985e-7, -0.996320546, 0.0857559666, 8.59710667e-7, -2.90349675e-7, -2.8889346e-7, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
