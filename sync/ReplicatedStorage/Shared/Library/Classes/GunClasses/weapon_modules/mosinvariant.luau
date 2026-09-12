local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.mosin))
v1.name = "\'Volk\' Frontline Rifle"
v1.variant = "mosin"
v1.desc = "Modification of the \'Volk\' Scoped Rifle."
v1.lore = "Though excellent over long ranges, the Wolf\226\128\153s infamous \226\128\152Volk\226\128\153 Scoped Rifle suffered from a few shortcomings that only gave credence to his fearsome reputation. The rifle was often ill-suited to close-range engagements, the SMLE scope proving somewhat cumbersome in the confines of cave combat.\n\nAn additional point of contention was the 7.62x54mmR Lead round\226\128\153s propensity to pierce straight through an enemy at closer ranges, dealing significantly reduced damage and limiting stopping power. Though solutions were presented such as carrying a pistol or simply using a different rifle, many had a sentimental attachment to the rifle despite its flaws and as such the engineers got to work.\n\nWar is cruel. Though conventions existed to prevent brutality and excess misery, many of these laws of war fell to the wayside in favor of wanton glory-seeking and greed. The development of the 7.62x54mmR Jacketed round was no exception, a weaker round designed intentionally to fracture and expand on impact with flesh, dealing maximum damage. Such a round was excruciating upon its victims.\n\nBut it did solve the issue of the Volk\226\128\153s weakness at close range. Without its famous scope, the Volk \226\128\152Frontline\226\128\153 Rifle became a light, swift, and devastating rifle, creating as many victims of war as it saved.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "73535017242408"
v1.ammo_give = "7.62mmR Jacketed"
v1.assists = {
    "No scope provides better handling and fire-rate.",
    "No scope hampers precision and recoil control.",
    "Fires a jacketed round dealing high damage.",
    "Jacketed rounds loses inverse damage profile and penetration.",
    "Issued with Stripper Clips in place of the scope pouch."
}
v1.damage = 150
v1.range = 70
v1.range_damage = 140
v1.far = 100
v1.far_damage = 130
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 30
v1.wallpen_studs = 2
v1.accuracy = 10
v1.moving_accuracy = 120
v1.fire_rate = 0.3
v1.cycle = 0.65
v1.cycle_rest = 0.2
v1.draw_speed = 0.5
v1.aim_speed = 0.3
v1.recoil = 10
v1.recoil_count = 6
v1.movement = 2
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 4
v1.special = {}
return v1;
