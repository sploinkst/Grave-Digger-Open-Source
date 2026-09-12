local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Trench Whistle"
v1.desc = "Issue Command Orders to yourself and all nearby Soldiers, improving their efficiency as long as they remain near."
v1.lore = "The Trench Whistle is a humble form of communication and giving orders over how chaotic the sounds of war could be by giving different whistle blasts.\n\nDespite the name \'Officer\', the role was likened a lot more to that of a Scout, carrying less gear, a telescope, binoculars and generally being well versed enough to write cleanly, Officers mapped out the terrain, defined where to go, points of interest, potential ambushes, attack routes and the lot\226\128\148of course this was only the experienced Officers who knew what they were doing and weren\'t the ones hiding in the back shouting \'Enemy over there!\' as if the fellow soldiers around them are blind.\n\nTheir transition to becoming the role of an Officer was more of a self-appointed decision, with so many soldiers especially from different nationalities, they needed a lot of communication amongst them\226\128\148so Scouts took up the mantle to organising where to go with their maps, which were far easier to understand than simple speech.\n\nAnd so we come back to the Trench Whistle, it was far easier to teach the soldiers: One long blast means fall back, series of short blasts meant to cease fire, and a long blast followed by a short blast was an alarm signal.\n\nThese signals have changed when the war went under the earth, as different nations had different signals, so they all rallied under new signals\226\128\148that\'s where we are now, with the faithful Trench Whistle, and the Officers that wield them."
v1.size = 1
v1.icon = "17709107730"
v1.animations = "whistle"
v1.assists = {
    "Use [@ALT] to cycle between three Orders.",
    "Use [@CHECK] to switch between Short and Long Orders.",
    "Advance Order improves Sprinting Speed.",
    "Defend Order improves Resilience and Healing Speed.",
    "Focus Order improves Weapon Handling and Accuracy."
}
v1.tooltype = "whistle"
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
v1.holsterc0 = CFrame.new(1.046875, -0.825845003, -0.521759033, 0.499998003, 0, 0.866021931, 0, -1, 0, 0.866021931, 0, -0.499998003)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.267837524, -0.9360888, -0.427062988, 0, 0, -1, -0.99999994, 0, 0, 0, 1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
