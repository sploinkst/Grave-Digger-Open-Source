local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Adjudicator\' Repeating Rifle"
v1.desc = "Semi automatic clip fed rifle firing a rifle sized cartridge."
v1.lore = "After the failure on the 17th, almost all supplies of M1886 \'Prince\' were destroyed on the Golden Empire territory, starving their soldiers from armaments that they desperately needed.\n\nHowever, after an under the table deal with the Solace Coalition, they retrieved designs and plans\226\128\148singed and scrunched from the harsh remains of the surface\226\128\148of a new rifle that could be developed off the frame of the \'Prince\'.\n\nThis new rifle was not very well favoured, it had its problems, it was heavy, needed less pressurised rounds which occasionally failed to actuate a bolt catch and hard to maintain with its constant fouling\226\128\148but it was an undeniable life-saver for the Empire.\n\nThe Royal Nation had set up a deal, they\'d return a large supply of \'Prince\' rifles in exchange for schematics of their new rifle, an insult of a trade, but one the Golden Empire shook hands for.\nWhen the wagon of supplies arrived to the meet however, they\'d soon be met at gun point, surrounded on all sides by the said rifle.\n\nCivil discussion and legal proceedings are things we as humanity strive for; despite this, in the face of faith, only the word of God matters in the eyes of the Golden Empire."
v1.size = 2
v1.icon = "131875342064540"
v1.animations = "lebel"
v1.ammo_give = "8mm Gras"
v1.melee_sound = "rifle"
v1.assists = {
    "Uses under-powered cartridges for better feeding, worse range than other Rifles.",
    "Reloads with a full clip all at once.",
    "Mind the wasteful reload, low capacity and un-reliable bolt catch.",
    "You will be unable to reload without sufficient reserves.",
    "Heavy rifle with a complex mechanism makes it clunky to use.",
    "[@ALT] to utilise a Walking Fire stance, improving handling at the cost of precision."
}
v1.tooltype = "gun"
v1.damage = 140
v1.range = 50
v1.range_damage = 105
v1.far = 70
v1.far_damage = 80
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 3
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 8
v1.moving_accuracy = 150
v1.fire_rate = 0.475
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.8
v1.aim_speed = 0.4
v1.wound = 1
v1.length = 4.5
v1.recoil = 8
v1.recoil_count = 6
v1.movement = 3
v1.firing_movement = 2
v1.firing_movement_last = 0.75
v1.ammo_reserves = 3
v1.ammo_reserves_max = 4
v1.capacity = 5
v1.chamber = true
v1.reload_start = 3
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 1.25
v1.require_full_load = true
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.950378418, 0.100975513, 0.597045898, 0, 1, 0, -1, 0, 0, 0, 0, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.00793457031, 0.0137820244, 0.597045898, 0, -1, 0, -1, 0, 0, 0, 0, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
