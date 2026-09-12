local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Honour\' Duty Pistol"
v1.desc = "High capacity pistol capable of outputting a wall of lead at close range quickly."
v1.lore = "A pre-war automatic pistol originally known as the M96, this weapon was originally a veteran memorial piece, as the .30 Automatic cartridge was believed to be ineffective in all roles save for close-range self defense.\n\nHowever, following a war\'s re-ignition, many veterans vouched for the production of more ammunition, and in turn, more pistols - of which proved its doubters wrong in the hands of capable soldiers.\n\nTen rounds, surprisingly light recoil, and a complementary dettachable stock meant that the pistol was surprisingly flexible for pestering enemies at longer ranges or for dumping lead into them up-close - and though the .30 Automatic cartridge is far from dehabilitiating at extreme ranges, it is still capable of taking a life with ease should the enemy\'s head be exposed."
v1.size = 1
v1.icon = "18193612933"
v1.animations = "mauser"
v1.ammo_give = ".30 Automatic"
v1.melee_sound = "pistol"
v1.assists = {
    "Mind the wasteful reload and weak stopping power at range.",
    "Reloading from dry is your most efficient option.",
    "You will be unable to reload without sufficient reserves.",
    "Attach or Detach Stock with [@ALT].",
    "Stock improves Accuracy and Fire rate, but cannot be holstered until removed."
}
v1.tooltype = "gun"
v1.damage = 75
v1.range = 40
v1.range_damage = 60
v1.far = 65
v1.far_damage = 50
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 0
v1.wallpen_distance = 30
v1.wallpen_studs = 2
v1.accuracy = 15
v1.moving_accuracy = 30
v1.fire_rate = 0.29
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.275
v1.aim_speed = 0.2
v1.wound = 1
v1.length = 4
v1.recoil = 6
v1.recoil_count = 6
v1.movement = 0.5
v1.firing_movement = 0.5
v1.firing_movement_last = 0.25
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 10
v1.chamber = false
v1.reload_start = 1.5
v1.reload_empty = 0.6
v1.reload_loop = 0
v1.reload_loop_after = 0
v1.reload_end = 0
v1.reload_full = 2.2
v1.require_full_load = true
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
