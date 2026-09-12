local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.core_modules.WEAPON))
v1.name = "Bulwark\'s Shield"
v1.desc = "A sturdy shield that can resist even the toughest of firearms."
v1.lore = "During the Sleepless War, the mobile personnel shields were an experimental form of protection used during trench warfare, providing protection to soldiers akin to that of armoured vehicles, allowing a slow, but steady advance to those behind it.\n\nHowever, it proved just simply too cumbersome and heavy to even consider using and rarely saw much use during said war, soon scrapped to the pile of experimental ideas that never saw light again.\n\nAs battles raged under the soil, the need for armoured vehicles\226\128\148of which there were little in functioning order\226\128\148grew more, and so the Royal Nation took back to looking at the original mobile shield design.\nScrapping a majority of the weight by cutting it down with a segmented locking design inspired by trench body plate, they developed their vision perfectly of a mobile advancing cover.\n\nIt had its flaws, it was still relatively heavy and unwieldy, but it served its duty far better than most designs at the time.\n\nThe Royal Nation designated the first crew to see deployment with the shields: The Vanguards."
v1.size = 1
v1.icon = "100140862319507"
v1.animations = "shield"
v1.melee_sound = "shield"
v1.alt_team_icon = "73326284553168"
v1.alt_team_model = "empirevanguard"
v1.assists = {
    "Shield segments can and will be damaged, needing to be repaired.",
    "Will passively protect you, even if not held.",
    "[@ALT] to enter a Full Guard.",
    "[@CHECK] to Repair the Shield.",
    "[@RELOAD] while Full Guarding to Plant the shield.",
    "Click on a Planted shield to retrieve it.",
    "You cannot fire your Pistols while in Full Guard.",
    "Will pair any Pistols or Cavalry Sword in your Secondary Holster.",
    "Be mindful of close encounters, the shield struggles against melee."
}
v1.tooltype = "shield"
v1.damage = 90
v1.range = 0
v1.range_damage = 0
v1.pen = 1
v1.melee_damage = 105
v1.melee_swing_speed = 0.65
v1.melee_range = 5
v1.accuracy = 0
v1.moving_accuracy = 0
v1.fire_rate = 0.2
v1.cycle = 0
v1.cycle_rest = 0
v1.draw_speed = 1.25
v1.aim_speed = 0.3
v1.wound = 1
v1.length = 0
v1.recoil = 0
v1.movement = 2.5
v1.firing_movement = 0
v1.firing_movement_last = 0
v1.capacity = 1
v1.chamber = false
v1.reload_start = 0
v1.reload_empty = 0
v1.reload_loop = 0
v1.reload_end = 0
v1.holster_point = "Torso"
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.holsterc0 = CFrame.new(-0.140808105, 0.0443191528, 0.651268005, 3.05416705e-8, 0.715402305, -0.698710978, 3.12712771e-8, -0.698710978, -0.715402305, -1, 3.55271326e-15, -4.37113137e-8)
v1.lefthand = true
v1.equipc0 = CFrame.new(-0.576034546, 0.0706379414, -0.0196380615, 1, 0, -4.37113883e-8, 0, -0.999999881, 0, -4.37113883e-8, 0, -1)
v1.equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
