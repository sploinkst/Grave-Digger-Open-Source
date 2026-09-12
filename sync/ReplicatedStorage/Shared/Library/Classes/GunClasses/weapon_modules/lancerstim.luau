local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Painkiller Injector"
v1.desc = "One time use injector to quickly patch your wounds."
v1.lore = "We couldn\'t keep throwing lives at the wall like a dartboard, hoping for one to stick, we needed a way to really push through the enemy in entrenched positions fast and with no fear\226\128\148grenades worked of course\226\128\148until your resupply eventually ran out, and you\'re left slinging rounds back and forth until one side inevitably gives up, charging you with a knife, club, or worse.\n\nThen they came, yelling through the smoke, cavalry on horseback bearing the flag of their country, a heavy shining helmet that glistened in the sun and soon, impaled Soldiers hoisted on their spears for everyone to see.\n\nIrregular units trained in valour and ambush tactics, mortars and machine gun fire provided suppression for cavalry to swoop in and disrupt enemy formation and infrastructure, the Lancer Legion became a well respected name despite their martyrdom-like life style, of course charging at enemies with machine guns and rifles with nothing but a spear would be dangerous, but soldiers needed something to hold onto, they needed strength and courage, while Officers sat in the back yelling at men to charge to their deaths, Lancers would give soldiers this glimmer of hope and confidence to make that charge needed to break through the defenses.\n\nWhen the war went underground though, while the resolve of most men and women fell, Lancers only grew, their loyalty to service stronger, although considered rather reckless at times.\n\nWhile most doctrines have changed, with many horses falling ill due to the cave plague, the Lancer Legion still served, charging head first into the fray and with improvements to their helmets, can withstand even rifle rounds although with quite the concussion, making them the perfect formation breaker.\n\nOnce the war ends, Lancers wish to be remembered, and as they stand upon the corpses of the fallen, photos and illustrations of them will be remembered through-out history."
v1.size = 1
v1.icon = "71082473166138"
v1.animations = "lancerstim"
v1.assists = {
    "Soothes a broken body, even if just for a little.",
    "Causes tremors and poor hand eye coordination.",
    "Un-suitable for Gunners, perfect for Lancers.",
    "Limited use, you will need to resupply to get more."
}
v1.tooltype = "lancerstim"
v1.damage = 90
v1.range = 0
v1.range_damage = 0
v1.pen = 1
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.75
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.5
v1.aim_speed = 0.35
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 2
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.capacity = 0
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(0.520019531, -0.50837326, 0.584709167, -1.06830682e-13, 0.939692616, -0.342019677, -3.88831762e-14, 0.342020035, 0.939691186, 1, -1.13686838e-13, 9.47505472e-29)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.520019531, -0.50837326, 0.584709167, -1.06830682e-13, 0.939692616, -0.342019677, -3.88831762e-14, 0.342020035, 0.939691186, 1, -1.13686838e-13, 9.47505472e-29)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.524185181, -0.953423262, 0.0105342865, 1, -2.84217094e-14, 0, 0, -5.55623067e-16, 0.99999994, 2.84217094e-14, -1, 5.5562312e-16)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
