local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.henry))
v1.name = "\'Judgement\' Incendiary Rifle"
v1.variant = "henry"
v1.desc = "Modification of the \'Judgement\' Breech Rifle"
v1.lore = "The \226\128\152Judgement\226\128\153 Breech Rifle carries with it a legacy of great renown, the massacre of Able Four being just one of its many accolades. The massive .577/450 Alloy cartridge tears through flesh and bone just as well as it does wood and steel, leaving a devastating injury if not outright killing its target. But what if it wasn\226\128\153t?\n\nMany anecdotal stories of the rifle failing to drop a soldier even on a direct hit left a few fanatics reeling. A single shot was all they had given they weren\226\128\153t issued a pistol, and a bayonet was a risky endeavor best saved for emergency use only. Should the victim somehow endure the shot, or worse, the user miss, it would be nearly impossible to recover.\n\nThough generally dismissed as a tall tale, an Imperial engineer soon took to the challenge of addressing this issue. Whilst the rifle was modified with more modern aperture sights to improve accuracy, the .577/450 Alloy round received special attention - the addition of phosphorus, a devastating incendiary agent. Though the direct lethality of the bullet was limited, the round, no matter where it struck, would incapacitate its target without fail with agony, setting them ablaze.\n\nNeedless to say, the weapon was controversial. Melting flesh, broken bones, agonizing screams were something that the original \226\128\152Judgement\226\128\153 Breech Rifle often spared its users from. But the final straw for the weapon was the seizure of a Solace factory manufacturing this weapon, and its subsequent use by bandits. Solace stopped manufacturing the weapon soon after, the sight of faces frozen in agony haunted cleanup crews for years to come.\n\nStill, the weapon lives on, with makeshift incendiary rounds continuing to be handmade by certain soldiers. Though a few soldiers have faced prosecution for their extensive use of the weapon, it is too little too late for many who have seen the effects of the weapon on their comrades.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "82218443186139"
v1.ammo_give = ".577 Phosphorus"
v1.assists = {
    "Uses Phosphorus filled rounds intended for rigid airships.",
    "Ignites target on a successful hit, dealing damage over time.",
    "No Bayonet and Aperture Sights provide better handling and accuracy.",
    "Considerably reduced penetration, range and base stopping power.",
    "Considerably increased chances of being tried for a war crime."
}
v1.damage = 90
v1.range = 40
v1.range_damage = 75
v1.far = 80
v1.far_damage = 50
v1.melee_sound = "rifle"
v1.melee_damage = 80
v1.melee_swing_speed = 0.7
v1.melee_range = 5
v1.pen = 3
v1.wallpen_distance = 30
v1.wallpen_studs = 2
v1.accuracy = 8
v1.moving_accuracy = 90
v1.length = 5
v1.draw_speed = 1
v1.aim_speed = 0.275
v1.special = {
    ["incendiary"] = true
}
return v1;
