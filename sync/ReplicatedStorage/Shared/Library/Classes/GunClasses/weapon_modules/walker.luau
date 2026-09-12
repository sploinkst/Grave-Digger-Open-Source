local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Kingslayer\' Percussion Revolver"
v1.desc = "A devastating Black Powder revolver that must be manually loaded."
v1.lore = "\'So you want to kill a King too? Well do I have the right gun for you!\'\n\n\'Often used in execution of Kings for treason or corruption, these Black Powder revolvers are also a great show of force and power! Nothing will leave those Bandits quaking in their boots than this thing!\'\n\n\'First, place the Hammer into the half position to allow the cylinder to rotate!\'\n\'Second, you have a percussion cap on every chamber, replace fired ones by prying them off with your finger as necessary!\'\n\'Third, fill each chamber with the right amount of powder, too little? You\'ll barely scratch someone\226\128\148too much? You\'ll rupture the cylinder, so make sure you don\'t over do it!\'\n\'Fourth, ensure a .44 Lead Ball is added to the chamber, then rotate the cylinder once and use the ram rod to push the Lead Ball firmly into the chamber, an un-seated round will be wildly in-accurate!\'\n\'Lastly, make sure you rotate the cylinder to the right position, then pull the Hammer back firmly! You are now primed and ready!\'\n\'Those Bandits will never know what hit them!\'\n- An excerpt from an old instruction manual on the usage of a Percussion Revolver.\n\nAn infamous revolver formerly used to execute Kings, but also often seen in the hands of Kings themselves, usually reloaded by a second since most Kings lacked military knowledge.\n\nMostly used as a show of force, it certainly gathered eyes when fired in the sky and leaving a massive plume of smoke in the vicinity\226\128\148Kings of course\226\128\148favoured the rather extravagant attention from it.\n\nDespite this, in actual war? It was impractical, slow to reload, heavy, and requiring too many specialised tools and pouches to be carried with\226\128\148but sure, it was rather powerful, easily the most powerful handgun round of the time, but still not the best\226\128\148many rifle rounds were still stronger such as the ever popular .577 Alloy.\n\nBut despite that, it still had an allure to it, it had a long history in both Royal Nation and Golden Empire past, a revolver like this shaped the past like no other have done before, it was a historical marvel that reminded people of an era that many considered better.. well, better than the one we are in right now.\n\nOr it was just favoured by foolish Soldiers who think they are better than they actually are.\n\nModel created by Novatality."
v1.size = 2
v1.icon = "118851184935301"
v1.animations = "walker"
v1.ammo_give = ".44 Lead Ball"
v1.melee_sound = "pistol"
v1.assists = {
    "Impractical and difficult to use, for experts only.",
    "Cylinder state will start empty and is retained between lives.",
    "Refer to history document on reloading procedure.",
    "Tap [@RELOAD] to enter and exit the Reloading Stage.",
    "Tap [FIRE] to rotate the Cylinder.",
    "Tap [@ALT] to add a Lead Ball to the chamber.",
    "Tap [@WALKER1] to remove or add a Percussion Cap to the chamber.",
    "Hold [@WALKER2] to pour Black Powder in the chamber.",
    "Tap [@WALKER3] to use the Ram Rod on the next chamber.",
    "Tap [@WALKER4] to discard your current revolver, make sure to get a new one.",
    "Tap [@CHECK] to dump all Black Powder from the chamber if you pour too much.",
    "Failure to follow proper procedure will lead to under-performance or malfunction.",
    "Tap [@ALT] outside of Reloading Stage to spin the Cylinder."
}
v1.tooltype = "gun"
v1.damage = 180
v1.range = 40
v1.range_damage = 170
v1.far = 90
v1.far_damage = 99
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 4
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 16
v1.moving_accuracy = 120
v1.fire_rate = 1.4
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.5
v1.aim_speed = 0.3
v1.wound = 1
v1.length = 3.5
v1.recoil = 25
v1.recoil_count = 9
v1.movement = 3
v1.firing_movement = 2.5
v1.firing_movement_last = 0.75
v1.ammo_reserves = 1
v1.ammo_reserves_max = 2
v1.capacity = 6
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_loop_after = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
