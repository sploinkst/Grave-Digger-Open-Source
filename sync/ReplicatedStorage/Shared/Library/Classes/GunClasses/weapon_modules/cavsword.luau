local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Cavalry Sword"
v1.desc = "Honed steel blade with a long range ready to take lives."
v1.lore = "In the era of firearms, the art of the blade has fallen out of favor - not only do they require a fair bit of training in order to avoid breakage from an inexperienced user, but they are time-consuming and expensive to produce relative to a rifle and bayonet, which boast longer reach and the utility of a firearm. Nevertheless, the sword persists as both a status symbol for the elite and in ever-dwindling circumstances where the reliability of a firearm may be questionable.\n\nIn a rather strange twist, it was the Royal Nation that perfected steel amongst cavalrymen - though the Empire\'s riding shotgun proved a deadly implement for hit-and-run tactics, closer quarters and damp conditions could hinder the shotgun\'s reliability - and that horses were suprisingly durable to buckshot, yet not to a long, sharp steel.\n\nThough cavalry has fallen out of favor given not only the perilous confines of the caves but the presence of the Cave Plague, these blades serve faithfully both as a badge of prestige but as a deadly implement in the tight confines of these hallowed halls."
v1.size = 1
v1.icon = "18335892865"
v1.alt_team_icon = "18335892652"
v1.alt_team_model = "armsword"
v1.animations = "sword"
v1.melee_sound = "cavsword"
v1.assists = {
    "Boasts superior range and damage to standard melee weapons.",
    "Attack from behind for an instant take-down.",
    "You will steal dog-tags off those you murder.",
    "Will pair any Pistols in your Secondary Holster."
}
v1.tooltype = "melee"
v1.range_damage = 0
v1.pen = 1
v1.melee_damage = 120
v1.melee_swing_speed = 0.55
v1.melee_range = 7.5
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.4
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.4
v1.aim_speed = 0.1
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
v1.holsterc0 = CFrame.new(0.46395874, 0.310976982, 0.502388954, 0.948681772, -0.0703201666, 0.308313996, -0.0668770224, -0.997524202, -0.0217345003, 0.309079111, -0, -0.951036334)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.601303101, 0.283640862, 0.496439219, 0.98480773, -0.173648179, 0, -0.173648179, -0.98480773, 0, 0, -0, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.166017056, -0.874788523, -1.78574085, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
