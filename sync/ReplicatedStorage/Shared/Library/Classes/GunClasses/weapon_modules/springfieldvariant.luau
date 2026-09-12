local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.springfield))
v1.name = "\'Whisper\' Flyboy Rifle"
v1.variant = "springfield"
v1.desc = "Modification of the \'Whisper\' Silenced Rifle."
v1.lore = "Though for most intents and purposes, five rounds is perfectly sufficient when it comes to combat, the standard issue \226\128\152Prince\226\128\153 Long Rifle came with an exceptional seven rounds, leaving many standard rifles to feel comparatively low in their ammo capacity, the \226\128\152Whisper\226\128\153 Silenced Rifle among them.\n\nBut during a Nation scavenge on the surface, a modified \226\128\152Whisper\226\128\153 rifle was discovered in an abandoned Air Base with a staggering twenty-five round magazine, initially designed for pilots who had been shot down by Anti-Aircraft implements and were likely to fight in sustained engagements behind enemy lines.\n\nHeavy and impractical, this modified design still saw a decent bit of popularity initially after its discovery. Twenty-five rounds was a jaw-dropping amount of ammunition without the need to reload, and many more naive soldiers jumped at the opportunity, though they would soon discover the pain of actually having to load the rifle with its incredibly heavy magazine spring. The suppressor was soon dropped due to making the weapon extremely cumbersome given the additional length, leaving the \226\128\152Whisper\226\128\153 name rather inane.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "97249316038367"
v1.assists = {
    "Fitted with a twenty five round magazine intended for the air service.",
    "Twenty five round magazine.",
    "Lack of silencer reduces muzzle velocity, but helps save on weight.",
    "Still heavy and sluggish because of the twenty five round magazine.",
    "You will struggle to reload when near max capacity due to the magazine spring."
}
v1.range = 60
v1.far = 90
v1.draw_speed = 1
v1.length = 4
v1.movement = 3
v1.firing_movement = 3
v1.firing_movement_last = 0.5
v1.ammo_reserves = 0
v1.ammo_reserves_max = 1
v1.capacity = 25
v1.chamber = false
v1.reload_start = 1.75
v1.reload_empty = 2
v1.reload_loop = 0.75
v1.reload_end = 1
v1.special = {}
return v1;
