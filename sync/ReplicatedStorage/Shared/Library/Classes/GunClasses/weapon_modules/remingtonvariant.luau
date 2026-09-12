local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.remington))
v1.name = "\'Negotiator\' Long Shotgun"
v1.variant = "remington"
v1.desc = "Modification of the \'Negotiator\' Pocket Shotgun"
v1.lore = "Though the Solace Coalition consists of those who fled the Nation and Empire specifically to avoid war, it is far from a safe haven. Work is dangerous, with the damage caused by bandits and cave-ins from constant labour being a common story in its newspapers.\n\nTo alleviate part of the stress of working long hours with the risk of these threats, Solace has allowed its workers to bring with them weapons for self defense, with the permission of their foremen. Though the typical candidates for these implements are the venerable Grace and Union pistols, there lies among them a rather unusual sight - a single-shot, long-barrelled shotgun.\n\nThough largely obsolete for military use with the existence of the double-barrelled shotgun, it is this obsolescence that gives this weapon a remarkably cheap price, in addition to having an almost endless supply. It is accurate, powerful, and reliable, capable of taking down a threat in a single shot without question, should your aim be true.\n\nNevertheless, it is a rare sight. Most would prefer to avoid the stress of having only one shot to take down a threat, and though it is light for a shotgun, it is far from the weight of a pistol such as the Grace or Union. Indeed, the weapon is far more likely to be found modified into a makeshift break-action pistol than in its original form.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "96879521732906"
v1.assists = {
    "Long barrel provides vastly better effective range.",
    "Long barrel means it no longer fits in your pocket.",
    "Simple and light to use keeps handling penalties minimal.",
    "You\'re not throwing this."
}
v1.size = 2
v1.accuracy = 12
v1.moving_accuracy = 12
v1.draw_speed = 0.75
v1.length = 5
v1.recoil = 20
v1.recoil_count = 9
v1.ammo_reserves = 6
v1.ammo_reserves_max = 8
v1.holsterc0 = CFrame.new(-1.16953278, -0.134528637, 0.577529907, -1.45285696e-7, 1, -3.87428628e-7, -1, -1.45285554e-7, 3.50177999e-7, 3.50177942e-7, 3.87428713e-7, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.0379943848, -0.134528875, 0.581314087, -1.45285696e-7, -1, 3.87428628e-7, -1, 1.45285554e-7, -3.50177999e-7, 3.50177942e-7, -3.87428713e-7, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.reload_start = 3
v1.pen = 2
return v1;
