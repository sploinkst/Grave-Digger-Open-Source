local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Stimulant Compounds"
v1.desc = "Stimulants to alleviate the encroaching death, the cure-all to your troubles."
v1.lore = "Surgical precision, humanitarian aid, or simply peacekeepers, the Mortician knows no bounds.\n\nField medics proved valuable on the battlefield, but with more and more advances in the technology of murder, the bodies are piling up faster than the wounds could be mended.\n\nMorticians often employed experimental treatment, procedures and chemical compounds to fight back against the rising corpses, perhaps their constant meddling of the dead is what gave them the name they bear now; that, or their ruthless tenacity in combat from over-indulgence of their own stimulants.\n\nThey tread the fine line between life and death, understanding that saving the lives of others are as important as taking them, whether by their own hands or their wicked experiments.\n\nThis war could not end fast enough."
v1.size = 1
v1.icon = "17778483374"
v1.animations = "stimbottle"
v1.assists = {
    "Press [@ALT] to select a Stimulant to fill the bottle.",
    "Press [@CHECK] to view the effects of the loaded Stimulant.",
    "Press [@RELOAD] to dispose of your current mix.",
    "All Soldiers can only handle 30u of chemicals in their Bloodstream.",
    "Stimulants will be applied in a radius at the thrown impact point."
}
v1.tooltype = "stims"
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
v1.holsterc0 = CFrame.new(0.544822693, -0.572972059, -0.714744568, 0.500003755, -0.866023242, 0, 0.866023123, 0.500003636, 0, 0, 0, 1)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.lefthand = false
v1.equipc0 = CFrame.new(-0.402816772, -1.04018092, -0.268280029, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
