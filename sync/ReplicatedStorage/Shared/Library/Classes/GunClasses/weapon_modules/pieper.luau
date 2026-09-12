local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Knell\' Silenced Revolver"
v1.desc = "Quiet double action revolver that leaves no bullet trails."
v1.lore = "Most people believe that only the Golden Empire wears religion on their shoulders but that simply is not true, Christianity and its variation has been a moral high-ground many of those in the Royal Nation swear by even to the end.\n\nA small cavalry guards known as the 3rd Peters Guard were comprised purely of the most devoted of Christians, adorned with the familiar upside-down cross, they swore their life not to just the Royal Nation but to the Holy Church as well, wielding this very pistol known as the \'Knell\', named after the ringing of a bell for a funeral, as these soldiers wished no ill will to their enemies\226\128\148even amongst the vitriol and spite that the Golden Empire gave them\226\128\148these men and women only wished for a peaceful passing for them.\n\nThe weapon itself? A technological marvel for its time, a gas sealing cylinder allowed it to be suppressed using the same Maxim system that the \'Whisper\' rifle had, a swing out seven round cylinder giving a cut above other revolvers in terms of capacity and reloading, alongside a double action trigger, while heavy, provides a good rate of fire in a roster of single actions.\n\nIt was seen as a gift from God, a blueprint discovered by the 3rd Peters Guard themselves in a rubble of a manufacturing plant based near Mexico, of whom immediately commissioned development from the Solace Coalition."
v1.size = 1
v1.icon = "109940911033447"
v1.animations = "pieper"
v1.ammo_give = "8mm Copper"
v1.melee_sound = "pistol"
v1.assists = {
    "Exceptionally quiet, can not be heard at a distance.",
    "Murders with this revolver do not reveal your position to the victim.",
    "Double Action has good fire rate, but with a trigger delay.",
    "[@ALT] to toggle Single Action, forcing a manual hammer pull after every shot."
}
v1.tooltype = "gun"
v1.damage = 105
v1.range = 50
v1.range_damage = 95
v1.far = 70
v1.far_damage = 80
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 2
v1.wallpen_distance = 50
v1.wallpen_studs = 3
v1.accuracy = 8
v1.moving_accuracy = 70
v1.fire_rate = 0.375
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.25
v1.aim_speed = 0.175
v1.wound = 1
v1.length = 4.5
v1.recoil = 10
v1.recoil_count = 6
v1.movement = 0.5
v1.firing_movement = 1
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 7
v1.chamber = false
v1.reload_start = 1.65
v1.reload_empty = 0
v1.reload_loop = 0.5
v1.reload_loop_after = 0.2
v1.reload_end = 0.5
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {
    ["suppressed"] = true
}
return v1;
