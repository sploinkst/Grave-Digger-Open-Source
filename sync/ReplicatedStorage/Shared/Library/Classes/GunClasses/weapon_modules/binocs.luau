local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Officer Binoculars"
v1.desc = "Scouting Binoculars with zooming and recon capabilities."
v1.lore = "Strategic, intelligent and leader would be what the Officers refer to themselves, others prefer: Upstuck, pretentious and arrogant.\n\nIt is a known fact that many Officers paid their way to their positions and frequently demanding respect out of veterans of the caves merely due to their\226\128\148often limited\226\128\148experience during the surface, to sub-par results.\nHowever, despite the prestigious title being filled by men and women who take pride in ordering poor innocent soldiers to their deaths\226\128\148there are those a true class above\226\128\148Officers who have seen what the war is really like, and it is these heroes who often turn the tides of a losing battle as most veterans often retire to the Officer role, using their expertise on the muddy grounds to carve a path forward to ending the war once and for all.\nAlthough ask most Officers, they\'ll certainly tell you they are of higher caliber than others describe them as."
v1.size = 1
v1.icon = "18693337243"
v1.animations = "binocs"
v1.assists = {
    "Mark enemies which will highlight them for you and Allies through cover.",
    "Use [@ALT] to initiate a ping, directing attention of all nearby Allies.",
    "Use [@RELOAD] to deploy a Scouting Telescope, Marking enemies in its view.",
    "Use [@CHECK] to fire a Illuminating Flare, Marking enemies nearby the flare."
}
v1.tooltype = "binocs"
v1.damage = 90
v1.range = 0
v1.range_damage = 0
v1.pen = 1
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.75
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 0.25
v1.aim_speed = 0.4
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 0
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.capacity = 0
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(0.519470215, -0.78753376, -0.622497559, -1, 0, 0, 0, 1, 0, 0, 0, -1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.alt_holsterc0 = CFrame.new(0.519470215, -0.78753376, -0.622497559, -1, 0, 0, 0, 1, 0, 0, 0, -1)
v1.alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.equipc0 = CFrame.new(-0.670684814, -0.889606476, -0.1824646, 1, 0, 0, 0, 0, 0.99999994, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
