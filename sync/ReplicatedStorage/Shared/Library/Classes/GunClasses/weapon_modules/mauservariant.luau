local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.mauser))
v1.name = "\'Honour\' Insurgent Pistol"
v1.variant = "mauser"
v1.desc = "Modification of the \'Honour\' Duty Pistol"
v1.lore = "Though the Solace Coalition is the most widespread and reputable supplier of the war effort, in these bloodied and battered caves, under-handed deals are not uncommon, with Bandit factions occasionally seizing production facilities from Solace in order to bolster their own forces. The weapons produced by these illicit activities are a far cry from the quality that the Solace Coalition provides - malfunctions are frequent, ergonomics are crude, and precision is lacking. But these weapons are cheap and better than nothing, and as such can be found in the hands of both the oppressors and the oppressed alike.\n\nFollowing the execution of the King of Avvalia, his daughter soon fled the state, her name tarnished and disgraced. Never again would she gaze upon her homeland, the bloodstained caves serving as her staging grounds. In the coming years, she would amass followers to her path of vengeance, preparing for the day that she might one day reclaim her rightful place when the Nation and Empire both crumbled under their own divisions. A Heroine or a Warlord, she would not have made it far without this crude pistol at her hip - a dozen nocks carved into its frame.\n\nModelled with assistance from Novatality."
v1.icon = "115458043355747"
v1.ammo_give = ".30 Automatic"
v1.assists = {
    "Illicit modification, possesses an improved rate of fire.",
    "Crude construction compromises standing accuracy.",
    "Twenty round capacity, lethality achieved through volume of fire.",
    "Barrel becomes warped and unusable after expending the full magazine.",
    "Not worth reloading, [@RELOAD] will drop the weapon instead.",
    "Recover at a cache."
}
v1.accuracy = 20
v1.moving_accuracy = 30
v1.fire_rate = 0.25
v1.recoil = 9
v1.recoil_count = 6
v1.capacity = 20
v1.hidereserves = true
return v1;
