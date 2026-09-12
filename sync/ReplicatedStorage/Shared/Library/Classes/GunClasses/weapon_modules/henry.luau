local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Judgement\' Breech Rifle"
v1.desc = "A devastating, breech loading, single shot rifle fitted with a Bayonet."
v1.lore = "Though bayonets have fallen out of favor in the caves\' confines - manuverability and handling is often paramount to survival in these circumstances - in the case of the \'Judgement\', the bayonet not only serves as a stalwart backup to the single-shot nature of the rifle, but also a superstitious role.\n\nCorrosive shells hammered into the Empire\'s zealots as \'Able Four\' marched through the hellish scene, gas masks adorned and automatic weapons at the ready. One of, if not the most battle-proven teams of the Royal Nation, this simple artillery ambush would prove to be their undoing - as knightly men blitzed through noxious fumes, flesh peeling and eyes bulging as they skewered the venerated Shock Troopers in cold blood. The horrific sight caused even these grizzled men to hesitate - and in those crucial moments, .577/450 rounds tore through their Vanguards\' Shields, their flesh, and soon, their spirit.\n\n...Or so the legend goes."
v1.size = 2
v1.icon = "18724437158"
v1.animations = "henry"
v1.ammo_give = ".577 Alloy"
v1.melee_sound = "bayonet"
v1.assists = {
    "Deals significant damage at all ranges.",
    "Affixed bayonet provides superior melee capabilities.",
    "Capable of obliterating through helmets at close range.",
    "Un-wieldy and cumbersome, Steady Aim is your best friend.",
    "[@ALT] while in a Full Sprint to initiate the Bayonet Charge.",
    "Bayonet Charges are not effective for a short period after starting."
}
v1.tooltype = "gun"
v1.damage = 199
v1.range = 60
v1.range_damage = 180
v1.far = 100
v1.far_damage = 120
v1.melee_damage = 105
v1.melee_swing_speed = 0.65
v1.melee_range = 7.5
v1.pen = 4
v1.wallpen_distance = 70
v1.wallpen_studs = 4
v1.accuracy = 12
v1.moving_accuracy = 150
v1.fire_rate = 0.75
v1.display_fire_rate = 21
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 1.2
v1.aim_speed = 0.4
v1.wound = 1
v1.length = 6
v1.recoil = 25
v1.recoil_count = 9
v1.movement = 3
v1.firing_movement = 2.5
v1.firing_movement_last = 0.75
v1.ammo_reserves = 8
v1.ammo_reserves_max = 14
v1.capacity = 1
v1.chamber = false
v1.reload_start = 2
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.reload_alt = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.932582855, 2.12966585, 0.536758423, 0, 0.999995708, 0, -1, 0, 0, 0, 0, 0.999995708)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(-0.43554306, 2.12966585, 0.570640564, -0.0355006903, 0.999369681, 0, -0.99936974, -0.0355006866, 0, -0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = true
v1.equipc0 = CFrame.new(0.367686272, -3.14173198, -0.561454773, 0, 0, -0.999995708, 0.99999994, 0, 0, 0, -0.999995708, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
