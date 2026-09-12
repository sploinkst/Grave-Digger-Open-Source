local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "\'Union\' Military Pistol"
v1.desc = "A semi-automatic, accurate pistol with great damage retention over range."
v1.lore = "Often seen as weak-willed cowards, the Solace Coalition sees many attempted raids on its worksites from unsavoury individuals - lawless bandits looking to get rich off barely armed innocent souls being one of them.\n\nThough the venerable \'Grace\' Revolver was and continues to be a favourite amongst Solace Guardsmen for its sheer stopping power, the limited capacity of six shots had a tendency to run out in prolonged firefights against multiple attackers, a detriment that proved lethal in many cases.\n\nCoincidentally, the Royal Nation was in similar need of a new pistol - an alternative to the \'Honour\' Pistol that would sate the desires of many overzealous officers who insisted on engaging outside of the sidearm\'s effective range.\n\nWord soon spread to both factions\' officials, and development of the \'Union\' Pistol began, with the Royal Nation providing ample resources in order to secure a complementary shipment for themselves.\n\nThe weapon is now a staple of all factions\' armouries, including the Empire - a remarkably advanced handgun for its time, this pistol serves as a symbol of resistance against those who would dare oppress."
v1.size = 1
v1.icon = "94903428476030"
v1.animations = "steyr"
v1.ammo_give = "9mm Lead"
v1.melee_sound = "pistol"
v1.assists = {
    "Mind the slow, individual reload.",
    "Great accuracy, but poor performance while moving relative to other pistols.",
    "Adopt a two handed stance with [@ALT], further improving accuracy.",
    "Two handed stance reduces rate of fire but practically negates recoil and movement pentalies."
}
v1.tooltype = "gun"
v1.damage = 90
v1.range = 30
v1.range_damage = 80
v1.far = 225
v1.far_damage = 60
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 1
v1.wallpen_distance = 30
v1.wallpen_studs = 2
v1.accuracy = 8
v1.moving_accuracy = 80
v1.fire_rate = 0.375
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.275
v1.aim_speed = 0.2
v1.wound = 1
v1.length = 4
v1.recoil = 10
v1.recoil_count = 6
v1.movement = 1
v1.firing_movement = 2.5
v1.firing_movement_last = 0.5
v1.ammo_reserves = 2
v1.ammo_reserves_max = 3
v1.capacity = 8
v1.chamber = false
v1.reload_start = 1.3
v1.reload_empty = 1.2
v1.reload_loop = 0.6
v1.reload_loop_after = 0
v1.reload_end = 0.35
v1.reload_full = 2
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.32220459, -1.17378056, -0.236167908, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
