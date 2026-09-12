local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.autosg))
v1.name = "\'Hellion\' Heavy Shotgun"
v1.variant = "autosg"
v1.desc = "Modification of the \'Hellion\' Automatic Shotgun"
v1.lore = "As the war waged on, both sides standardized their armouries with more efficient and generalist weaponry, with nicher options falling into obscurity. One such implement was the Slug shell, originally coupled with the \226\128\152Hellion\226\128\153 Automatic Shotgun for a quick and simple conversion from close to long range.\n\nSlugs soon found themselves outcompeted by pistols and rifles in practicality, and given the lackluster efficiency to manufacturing effort ratio, fell out of favor. With the absence of game animals to warrant using slugs against, there was little point for their continued issuance. Still, a few Hellion users sought a greater effective range without compromising the weapon\226\128\153s close range performance.\n\nA mining operation in Nation territory soon created a new innovation to solve this quandary - relics from the American Revolution including an old style of load for muskets known as \226\128\152buck and ball\226\128\153, a combination of six buckshot pellets and a single musket ball for combined close and long range performance.\n\nSoon, the concept was drafted for shotgun shells and sent off to Solace for manufacture. Though requiring a heavier and sturdier frame of the \226\128\152Hellion\226\128\153 to fire without risk of breakage, it nonetheless proved its worth as a capable implement at a wide variety of ranges.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "81839002295742"
v1.ammo_give = "00 Buck and Ball"
v1.assists = {
    "Fires a powerful shell loaded with four pellets and one ball.",
    "Buck and Ball load has excellent damage over range and stopping power.",
    "Heavier construction to handle the stronger loads makes it cumbersome.",
    "Reduced capacity to save on weight.",
    "Poor rate of fire compared to the original model."
}
v1.damage = 50
v1.range = 25
v1.range_damage = 40
v1.far = 30
v1.far_damage = 30
v1.pen = 2
v1.accuracy = 18
v1.moving_accuracy = 18
v1.fire_rate = 0.75
v1.aim_speed = 0.6
v1.pellets = 5
v1.recoil = 12
v1.recoil_count = 9
v1.movement = 4
v1.firing_movement = 3
v1.ammo_reserves = 1
v1.ammo_reserves_max = 2
v1.capacity = 5
v1.chamber = false
return v1;
