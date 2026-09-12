local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Hunter Kit"
v1.desc = "Set Contraptions for the unsuspecting and punish their confidence."
v1.lore = "Jaegers are dirty people.\n\nOften known for their cheap tricks and pushing the boundary of what is considered morally acceptable in these times of war.\n\nWar is horrific, it always is, it always will be, it is not and never will be a subject that the men and women who fought will take lightly, but there is a simple fact\226\128\148whether people wish to agree or not\226\128\148that there are men and women who have no boundaries, who can say they relish or enjoy the bloodshed of war.\n\nThe Jaeger Corp welcomes these people, shaping them to who they are, and the instruments in this kit are their voice, whether it would be for laying contraptions, sabotaging the opposition, or plain interrogation and torture."
v1.size = 1
v1.icon = "78664710036907"
v1.animations = "jaegerkit"
v1.assists = {
    "[@RELOAD] to Cycle between Contraptions.",
    "[Aim] to place Tripwires.",
    "Contraptions require Tripwires to function.",
    "Link Tripwires after placing a Trap, not before.",
    "Exceptions for Tripwires include the \'Mantrap\', \'Lantern Lure\' and \'Dynamite Stack\'."
}
v1.tooltype = "jaegerkit"
v1.damage = 90
v1.range = 0
v1.range_damage = 0
v1.pen = 1
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.75
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.75
v1.aim_speed = 0.5
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
v1.holsterc0 = CFrame.new(1.02121735, -0.806931257, 0.705734253, -0.999999881, 0, 0, 0, 1, 0, 0, 0, -1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.equipc0 = CFrame.new(-0.488250732, -1.09303796, -0.0570831299, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
