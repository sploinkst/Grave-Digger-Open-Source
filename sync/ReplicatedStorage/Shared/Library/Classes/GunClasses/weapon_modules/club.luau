local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.knife))
v1.name = "Trench Mace"
v1.desc = "Your trusted club for murder, the best you have at all times."
v1.lore = "Often make-shifted on the field of battle, soldiers quickly realised that knives can chip, break, or rust in some humid conditions, so the logical option was the thickest piece of metal or wood you could find.\n\nConsidered crude by some, it didn\'t exactly matter, a solid blow to the head would take out any human like cattle; at least that way they go out like a switch, instead of suffering in a pool of their own crimson\226\128\148for at the end of the day, the victor is the one who still has their tags."
v1.size = 1
v1.icon = "18910163361"
v1.alt_team_icon = "18910163027"
v1.alt_team_model = "spring"
v1.animations = "club"
v1.melee_sound = "club"
v1.assists = { "Attack from behind for an instant take-down.", "You will steal dog-tags off those you murder." }
v1.special = {}
return v1;
