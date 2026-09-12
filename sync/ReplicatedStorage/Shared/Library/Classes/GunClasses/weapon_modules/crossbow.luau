local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Okhotnik\' Hunting Crossbow"
v1.desc = "A crossbow firing powerful but slow bolts with a heavy drop."
v1.lore = "More tool than weapon\226\128\148although you shouldn\'t say that when one is aimed at you\226\128\148the humble crossbow has been a weapon for millennia, a bow string joined and pulled back by a Goat\'s foot lever to sling deadly bolts across large distances, making those unfortunate enough to get hit regret walking on the battlefield.\n\nCrossbows were not un-common during the war despite what you might think, the L\226\128\153Arbalete la Sauterelle Type A D\226\128\153Imphy was a large crossbow used to sling grenades over great distances, so the production of bow string was plentiful for the Golden Empire, however was a little too plentiful, given trying to set one up with the right angle in the deep confines of the cave was difficult, so a new purpose had to be found.\n\nSimpler models were made by hunters who wanted to add more fun to hunting pests for rations\226\128\148given the rather depressing living environment\226\128\148any amount of dopamine, laughter and smile would help, we\'re all human after all.\n\nIt saw very limited use in combat otherwise, but had a niche, it was quiet, more than any suppressed gun could be, so Pox tipped arrows wielded by Jaegers who were already proficient in its usage saw use.\n\nDespite everything, it is one of the most rudimentary of the Golden Empire arsenal and certainly one to be feared, with nightmare stories of bolts tearing through flesh, making surgery difficult and painful; a powerful symbol of the Golden Empire."
v1.size = 2
v1.icon = "85866554467590"
v1.animations = "crossbow"
v1.ammo_give = "Bodkin Bolt"
v1.melee_sound = "rifle"
v1.assists = {
    "Capable of damaging but not piercing through helmets.",
    "Murders with this crossbow do not reveal your position to the victim.",
    "Flies straight for a moment, then travels in an arc.",
    "Practice makes perfect, requires commitment to perform well.",
    "Bolts cannot be retrieved after firing, but can be replenished."
}
v1.tooltype = "gun"
v1.damage = 1
v1.range = 60
v1.range_damage = 1
v1.far = 100
v1.far_damage = 1
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 3
v1.wallpen_distance = 1
v1.wallpen_studs = 1
v1.accuracy = 1
v1.moving_accuracy = 1
v1.fire_rate = 0.25
v1.display_fire_rate = 20
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.55
v1.aim_speed = 0.125
v1.wound = 1
v1.length = 4
v1.recoil = 1
v1.recoil_count = 1
v1.movement = 1
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 8
v1.ammo_reserves_max = 14
v1.capacity = 1
v1.chamber = false
v1.reload_start = 2.5
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.reload_alt = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.763778687, -0.128093004, 0.546070099, 8.74221513e-8, 2.30215846e-12, -1, -0.999999762, -8.41540921e-14, -8.74220518e-8, 8.96023165e-14, 1, -2.30215846e-12)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.447631836, -0.487032413, 0.708259583, 8.60940688e-8, 0.173648119, -0.984807611, -0.999999523, -1.74320248e-13, -8.7421995e-8, -1.51805271e-8, 0.984807611, 0.173648119)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.308517456, -0.725009203, -0.434566498, 2.32707805e-7, 3.87429793e-7, -1, 0.99999994, -3.5017797e-7, 2.32707649e-7, -3.50177913e-7, -1, -3.87427576e-7)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
