local v1 = {
    ["base_walkspeed"] = 10,
    ["sprint_walkspeed"] = 2,
    ["sprint_fullspeed"] = 6,
    ["sprint_fullspeed_time"] = 2,
    ["base_health"] = 200,
    ["health_regen"] = 1,
    ["health_regen_tick"] = 0.1,
    ["base_holdbreath_time"] = 5.5,
    ["base_holdbreath_regen"] = 2.5,
    ["base_holdbreath_maxaccuracy"] = 0.35,
    ["default_ambience"] = 0.75,
    ["default_soundgroup"] = 1,
    ["default_radiogroup"] = 0.3,
    ["dynamite_hiss_volume_default"] = 0.1,
    ["dynamite_hiss_volume_jaeger"] = 0.2,
    ["dynamite_hiss_range_default"] = 45,
    ["dynamite_hiss_range_jaeger"] = 60,
    ["vanguard_shield_sides"] = 1500,
    ["vanguard_shield_top"] = 400,
    ["bulwark_buffer"] = 0.2,
    ["pugsley_pen_materials"] = {},
    ["base_supplies"] = 10,
    ["base_constructs"] = {},
    ["base_ticket_tickwait"] = 3,
    ["base_rein_time"] = 45,
    ["base_wait_rein"] = 3,
    ["base_capture_require"] = 20,
    ["base_capture_decay"] = 1.5,
    ["base_capture_speeds"] = {},
    ["base_min_zoom"] = 3,
    ["base_max_zoom"] = 6,
    ["chem_tolerance"] = 3,
    ["level_req"] = 200,
    ["xp_on_kill"] = 2,
    ["xp_on_flag"] = 4,
    ["xp_on_capture"] = 4,
    ["xp_on_construction"] = 1,
    ["xp_on_healing"] = 3,
    ["hair_colours"] = {},
    ["skin_colours"] = {},
    ["classes"] = {},
    ["perks"] = {},
    ["conscript_kits"] = {},
    ["ranks_nation"] = {},
    ["ranks_nation_full"] = {},
    ["ranks_empire"] = {},
    ["ranks_empire_full"] = {},
    ["rank_time"] = {}
}
v1.base_constructs.Barricade = {
    ["cost"] = 2,
    ["limits"] = 4
}
v1.base_constructs.Palisade = {
    ["cost"] = 1,
    ["limits"] = 5
}
v1.base_constructs.Cache = {
    ["cost"] = 5,
    ["limits"] = 2
}
v1.base_constructs["Barbed Wire"] = {
    ["cost"] = 1,
    ["limits"] = 5
}
v1.base_constructs.Sandbags = {
    ["cost"] = 2,
    ["limits"] = 3
}
Color3.fromRGB(255, 241, 155)
v1.classes.soldat = {
    ["name"] = "Soldat",
    ["desc"] = "Frontline Infantry Class with an innate extra Inventory Weight, carrying more fire-power and ammunition. Experienced in weapon usage and handling.",
    ["order"] = 1
}
v1.classes.rook = {
    ["name"] = "Rook",
    ["desc"] = "Dedicated Engineering Class with a powerful Heavy Pick and a Construct Hammer for fortifications. Manipulating terrain is their specialty.",
    ["order"] = 2
}
v1.classes.mortician = {
    ["name"] = "Mortician",
    ["desc"] = "Mainline Corpsman Class with Surgery expertise and a large array of helpful Stimulants. Proficient at providing aid to Allies.",
    ["order"] = 3
}
v1.classes.officer = {
    ["name"] = "Officer",
    ["desc"] = "Committed Support Class with Scouting capabilities and a stronger Capture rate. Paired with a foolish insistence to assert leadership with orders.",
    ["order"] = 4
}
v1.classes.jaeger = {
    ["name"] = "Jaeger",
    ["desc"] = "Cunning Trapper Class with malicious Contraptions, the ability to track sounds of their prey, and toxication rounds. The perfect disruptor.",
    ["order"] = 5
}
v1.classes.lancer = {
    ["name"] = "Lancer",
    ["desc"] = "Stalwart Flagbearer Class with a powerful Heavy Lance and an impervious helmet. A guardian to rally for, or the martyr to die for.",
    ["order"] = 6
}
v1.classes.vanguard = {
    ["name"] = "Vanguard",
    ["desc"] = "Self-less Guardian Class armed with the sturdy Bulwark\'s Shield, capable of laying down fire from behind. First to enter the fray, and the last to leave.",
    ["order"] = 7
}
v1.classes.conscript = {
    ["name"] = "Conscript",
    ["desc"] = "Consigned to death, we all must do our part in this war.",
    ["order"] = 8
}
v1.classes.engineer = {
    ["name"] = "Engineer",
    ["desc"] = "Train go choo choo",
    ["order"] = 9
}
v1.classes.dread = {
    ["name"] = "Dreadnought",
    ["desc"] = "big gun pew pew",
    ["order"] = 10
}
v1.perks.none = {
    ["name"] = "None",
    ["desc"] = "Too green to experience the trauma of war.",
    ["icon"] = "17768266447",
    ["perk"] = true,
    ["lore"] = "The boy meekly looked at the lavish painting adorned with purple and silver trimmings.\n\n\'Everyone starts somewhere right? But where am I going to end up?\'\n\n\'What if I\'m roped into a.. role that I don\'t like or- or, worse, die knowing I couldn\'t have changed anything?\'\n\n\'I don\'t believe in fate, I don\'t like the idea that something or.. someone is dictating my life.\'\n\n\'The surface was already taken from me and I... I don\'t know what\'s going to happen next anymore.\'"
}
v1.perks.vet = {
    ["name"] = "\'Veteran\'",
    ["desc"] = "Superior reloading skills and technique.\nStart with full ammunition reserves.\nCannot be motivated by morale.",
    ["lancerdesc"] = "Lance Charges will now skewer through multiple enemies at once, only stopping at a maximum of three.\nLance Charges gain extended duration, improved turning control and can stagger Vanguard Shields.",
    ["icon"] = "17855293408",
    ["perk"] = true,
    ["lore"] = "\'Guy doesn\'t speak much huh? When you look at someone, I really do sometimes wonder what goes on in their heads.\'\n\n\'Some people don\'t even have an inner voice, could you just imagine that? The void, nothingness, in your head, for hours at a time?\'\n\n\'He\'s leaving now. Let\'s tag him, maybe we\'ll finally learn something new about this war.\'\n\n\'Or maybe he\'ll leave us to die like he did his last battalion. Don\'t matter much now anyway, the bell has rung.\'"
}
v1.perks.butcher = {
    ["name"] = "\'Butcher\'",
    ["desc"] = "Restore all life, ammunition, supplies and motivation on a Combat Knife or Trench Mace Kill.\nIncreased lethality with Combat Knife and Trench Mace.",
    ["icon"] = "17848127421",
    ["perk"] = true,
    ["lancerdesc"] = "Lance Charges gain extended duration, improved turning control, reduced rest period, and faster executions.\nRestore all life, ammunition and motivation on a successful Lance Charge.",
    ["lore"] = "\'I need to wash my hands.\', the thought ran across his mind over and over.\n\nThe obsession, it doesn\'t end, sometimes he asks himself if it was just compulsion or something else, maybe something was wrong with him.\n\n\'I need to wash my hands.\', he said to himself, looking at the broken mirror in the infirmary.\n\nA Mortician came over to him, giving him a shot of the green liquid.\n\n\'I need to wash my hands.\', the man said to the doctor.\n\nThe doctor nodded, signalling over a wash basin next to his bed.\n\n\'I need to wash my hands.\', said the pouches over my waist.\n\nHe removed his rig\226\128\148gently placing them beside the table\226\128\148before opening them one by one, removing the disembodied hands of the dissenters."
}
v1.perks.extrainv = {
    ["name"] = "\'Survivalist\'",
    ["desc"] = "Carry an extra inventory weight, extra Equipment and extra class supplies.",
    ["icon"] = "17855410807",
    ["perk"] = true,
    ["lore"] = "3x Rations\n2x Lighter\n2x Lamp Oil\n1x Flint\n2x Bandages\n2x Spare Ammunition\n1x Combat Knife\n1x Survival Knife\n3x Boric Lint\n2x Plasters\n2x Fullbrew Blend\n2x Magnesium Tablets\n3x Matchboxes\n1x Compass\n2x Soaps\n2x Razors\n1x Comb\n2x Forks\n2x Spoons\n2x Wire-cutters\n1x Book\n2x Pens\n3x Biscuits\n1x Boot Polish\n1x Sewing Kit\n2x Laces\n2x Gun Oil\n2x Rags\n1x Entrenching Tool\n1x Photo of \'Ava\'"
}
v1.perks.tunnelrat = {
    ["name"] = "\'Tunnel-rat\'",
    ["desc"] = "Mine faster, quietly and subtly with your Pick.\nQuieter footsteps and improved handling after mining.",
    ["icon"] = "17855466133",
    ["perk"] = true,
    ["lore"] = "LETTER TO INQUISITOR SABLE\nVIA VENICE\nFROM ENS OTN OCT 4TH 1919\n\nSABLE FRANCESCA\nJACK MONTENEGRO\n\n2521 I HAVE COME TO THE ATTENTION THAT THERE ARE NATION SPIES AMONGST THE SOUTHERN AREA OF EMPIRE TERRITORY NEAR ENSIGNIA\n\nTHERE ARE REPORTS OF COLLAPSED TUNNELS REVEALING HUMAN SIZED DIGWAYS OUTSIDE OF EMPIRE JURISDICTION\n\nA MEETING WILL BE ARRANGED IN JULIAS HOPE BY NEXT WEEK AND WE WILL DISCUSS THIS FURTHER THERE\n\nPLEASE BRING A LIKELY CANDIDATE\n\n430PM /5TH"
}
v1.perks.sprinter = {
    ["name"] = "\'Greyhound\'",
    ["desc"] = "Break into a sprint immediately and handle weapons better after sprinting.\nManoeuvre over Barbed Wires easier.",
    ["icon"] = "18109565944",
    ["perk"] = true,
    ["lore"] = "The girl had learned many things from others.\n\nShe had learned to cry when she was sad, she had learned to get angry at injustice, she had learned to smile at the soldiers that passed her by on their way to the frontlines.\n\nHowever, there were things that came naturally to her, things that no mentoring would\'ve taught anyone else in decades.\n\nOn her first hunt back on the surface, her rifle came as natural as breathing to her. As if it was an appendage, she knew to breathe in when she aimed, knew when to shoot when a rabbit came into her sights all the sudden, and to notch her rifle for every one.\n\nIn the end, people aren\226\128\153t much different than rabbits.\n\nAnd she knew the moment the letter had arrived in her mail, the hunt had begun.\n\nWritten by Lazarubius and Robinson M."
}
v1.perks.knockdown = {
    ["name"] = "\'Snake Eyes\'",
    ["desc"] = "Survive a lethal non-headshot every half a minute.\nPerform a roll when falling from heights, holding Jump lets you roll from shorter heights.",
    ["icon"] = "18109504628",
    ["perk"] = true,
    ["lore"] = "The man clutched his cross tightly. Chains bound his legs as he held his head down. Once, he was a proud knight for the cause, adorned in flamboyant gold. Now, all that remains are tatters and the symbol of his faith.\n\n\'You know - the boys back at outpost antumbra didn\'t talk much. Not a clue why they chose to bring you back when they wiped out your company.\'\nHis grip on the cross tightened, the chains rattled. He stayed silent.\n\nHe was startled by the banging on the bars that confined him, before he heard the guardsman laugh.\n\'Hey, blondie, you awake in there? I\'m speakin\' to you.\'\n\nThe man looked up to the guardsman, stepping forward to face him.\n\'Sergeant said he wanted to meet you - figure out what makes you so different from the rest - see what he can get out of ya. Come with me.\'\n\nThe door swung open, the chains were undone, the man held his grip on the cross-\nHe flipped it in his hand, pointing the sharp side down, and plunged it into the man\'s flesh. It wasn\'t clean, it wasn\'t a functional weapon. But its the only thing he had.\n\nYes, the man had nothing save for his cross, and now the blood on his hands. The plan- no, gamble was formulated in an instant, after verifying the guardsman\'s death, he stripped him down. Took his helmet, his clothes - rinsed them with the barely functional sink in his stall.\n\nHe lugged the body inside, closed the door - and clutched his cross as he attempted his escape. The man earned his former status through gambles time and time again, this time would be no different.\nAll in, like always.\n\nWritten by Kadence2727."
}
v1.perks.leather = {
    ["name"] = "\'Leatherneck\'",
    ["desc"] = "Immune to flinches, concussions, and knockback from being shot.\nGain resilience to melee.",
    ["icon"] = "18456666880",
    ["perk"] = true,
    ["lore"] = "POST-COMBAT FIELD REPORT - MEDICAL\nMORTICIAN JAN MATTIAS\n\n\226\128\152SOLDAT\226\128\153 HARLOW\nKIA. 8mm Spitzer struck Femoral Artery, causing massive blood loss.\n\n\226\128\152OFFICER\226\128\153 VASCA\nTwo .30 Auto fragments removed from left arm. Prescribed Bicaridine for recovery. Expected to be able to return to frontline in a week.\n\n\226\128\152SOLDAT\226\128\153 AUDOIN\nPredicted KIA. Pox rounds have caused an inevitable infection that is untreatable.\n\n\226\128\152ROOK\226\128\153 WELLER\nSustained five (5) 8mm Spitzer rounds to the chest, two (2) .45 Lead rounds to the right arm, one (1) .30 Auto round reportedly struck the head but did not lodge into skull. Expected to make a full recovery in three weeks.\n\n\226\128\152SOLDAT\226\128\153 ALASSANE\nKIA. 7.62x54 round directly to the heart caused an instant death.\n\nWritten by Lazarubius."
}
v1.perks.marksman = {
    ["name"] = "\'Marksman\'",
    ["desc"] = "Vastly improved steady aim, accuracy and recoil control.",
    ["lancerdesc"] = "Throwing Axes fly straighter and faster Throwing Axe draw time.",
    ["icon"] = "71071479396010",
    ["perk"] = true,
    ["lore"] = "750m - Rook - One, confirm\n800m - Mortician - Three, confirm, rushed first shot, two to finish\n700m - Soldat - One, confirm\n650m - Lancer - Two, unsure, should\226\128\153ve aimed at a less armoured part\n750m - Soldat - One, failed, Vanguard\nobstruction\n550m - Officer - One, confirm, easy headshot\n950m - Soldat - One, confirm, stars aligned for this one\n850m - Vanguard - Two, failed, should\226\128\153ve been more patient\n700m - Jaeger - One, confirm\n650m - Lancer - One, unsure, can never tell with these guys\n700m - Mortician - One, confirm\n\nWritten by Lazarubius"
}
v1.perks.quickdraw = {
    ["name"] = "\'Black Hand\'",
    ["desc"] = "Improved weapon handling and reduced movement penalties.\nSlightly improved trigger finger.",
    ["icon"] = "18456667058",
    ["perk"] = true,
    ["lore"] = "THE \226\128\152TALON\226\128\153 SINGLE-ACTION REVOLVER: $37.00\n\nSix shots was enough for Helfort, and it\226\128\153ll be enough for you.\nIt might be old but there\226\128\153s no denying the reliability of this rugged, dependable companion.\nWhether for personal protection, target shooting, or military use, this pistol has found its way into the holsters of thousands of Royalist civilians and soldiers - and for good reason.\nEven one shot is enough to stop an attacker dead in their tracks; perfectly balanced and coupled with exceptional ergonomics, there\226\128\153s no chance for any trouble for any quick-draw enthusiasts.\nIt\226\128\153s the only pistol you\226\128\153ll ever need.\n\nThe rest of the page was torn off, the only thing remaining: two empty .45 Flat casings.\n\nWritten by Lazarubius"
}
v1.perks.ghost = {
    ["name"] = "\'Apparition\'",
    ["desc"] = "Dims your light temporarily on a murder with your own hands.\nImmune to lesser spotting effects and have better vision in the dark.",
    ["icon"] = "95654030934373",
    ["perk"] = true,
    ["lore"] = "I saw her while we were rummaging through the aftermath.\n\nIt was hard to recognize her from the grisly scene, but... something told me it was her, even before I checked her dogtags. My best friend in the world, ever since we were kids. When we were conscripted at the same time, into the same unit, it felt like destiny.\n\nAnd now here she was, lying in a pool of half-dried blood on the ground, nothing more than a corpse.\n\n...I always saw her as the sister I never had. We looked so alike at times, people called us twins or even switched up our names in school. But despite our superficial similarities, she was always better than me at anything we did - and she did anything I did. People liked her more than me - she had some sort of natural charisma and talent that I didn\226\128\153t seem to have.\n\nA lot of people would cry at her death.\n\nNobody would cry at mine.\n\n...I reached for her dogtags.\n\nSometimes... I still hear her voice in the dark when the lamps are out.\n\nWritten by Lazarubius"
}
v1.perks.tracker = {
    ["name"] = "\'Devil Dog\'",
    ["desc"] = "Track the footsteps of your enemies and removed crouching penalties.\nSense, track and hunt nearby injured prey.",
    ["icon"] = "131119424203557",
    ["perk"] = true,
    ["lore"] = "\'Coward.\'\nThat\226\128\153s what the whispers call me whenever I\226\128\153m not in the heat of the action, where the bullets fly and the bodies fall.\n\n\'Monster.\'\nThat\226\128\153s what the whispers call me whenever my knife finds its sheath in the gut of an enemy.\n\n\'Now everybody knows what you are.\'\nIf they do, then I know which of the two I would rather be remembered as.\n\nWritten by Lazarubius"
}
v1.perks.healing = {
    ["name"] = "\'Chemist\'",
    ["desc"] = "Perform surgery on yourself faster.\nReplaces your vial of Peridaxon with Tricordrazine, an enhanced instant healing solution.\nView precise health state of self and allies.",
    ["icon"] = "139580185887345",
    ["perk"] = true,
    ["lore"] = "Dr. Haus of the Mortician Wing was regarded as among the best chemists in Empire. With his methods - often considered unorthodox, but nonetheless effective - he has saved hundreds of imperial lives, including those of well-known high ranking officials, with rumours of him even curing a member of the Queen\'s court.\n\nThe Queen\'s propaganda is powerful, but could not turn a mind as brilliant as Haus\' - an atheist in hiding. Despite being content with serving, he hated violence. With the Empire\'s ideology growing more ferocious with each battle, he turned and ran, eventually surrendering to the Nation and defecting, giving away his medical expertise in exchange for keeping his life.\n\nWhile gaining recognition in the Nation for his superb surgery skills, he became obsessed with a chemistry project. Becoming tired of physically treating soldiers, he synthesized a new combat drug. After the patent was accepted, and the drug turned to limited scale production, Haus began acting strange among colleagues, and shortly disappeared in a few days without a trace.\n\nA medical marvel, Tricordrazine exhibits unique medical properties, including quickened coagulation, increased pain tolerance, reduced scarring, and faster wound healing. Though as is with everything, it came with a price: The drug is extraordinarily addictive, and no future iteration managed to reduce its effects. In the Nation, it is referred to as the Lost Man\'s drug, and in the Empire - the Devil\'s Bargain.\n\nPeople still speculate on what may have happened to the talented Dr. Haus. But regardless of the cause, it truly is a tragedy that such a brilliant mind had been lost that day. Had it not been for the war, what advancements in medicine could have been made?\n\nWritten by MisterMax228_New"
}
v1.perks.akimbo = {
    ["name"] = "\'Ambidextrous\'",
    ["desc"] = "Wield two Pistols at the same time.\nRequires a Pistol in your Primary Sling and Secondary Holster each, they do not have to be identical.\n\nUse Alternate Action to aim and fire each pistol independently with left press or right press.",
    ["icon"] = "96077944644981",
    ["perk"] = true,
    ["lore"] = "TRAGIC SHOOTING OVER POKER IN NEW RUNSWICK SALOON\n\nToday, in the labour town of New Runswick\'s Saloon, a tragic shooting occurred with 6 dead, 3 wounded, and 16 injured.\nAccording to eye-witness reports, the shooting had occurred over a game of poker where the gunman, who was an outsider of New Runswick had lost a large sum of money during a break in-between Solace Coalition workshifts.\nThe gunman was enraged over the loss and proceeded to pull out a pair of pistols, opening fire on Solace Coalition labourers who were present in the saloon at the time, including New Runswick\'s beloved barkeep who had tragically died in the shooting.\nThe gunman quickly fled the scene shortly after committing the atrocity.\nForeman Vere Clarke and his several deputies had uncovered reportedly, 24 casings of .45 Lead strewn about the saloon.\nTo the people\'s dismay, The Foreman commented, \'We oughta just put a town-wide ban on gambling, this the fourth time it has happened, although this the bloodiest one yet.\'\nThe gunman is still at large, Solace Coalition is willing to award a tidy bonus to any man or woman who would undertake this task of ridding them from the earth by any means.\n\n$4,000 REWARD\nREWARD FOR THE CAPTURE, DEAD OR ALIVE OF\nSALVADOR \'TIGRECILLO\' GONZALES\n\n28 years of age, dark hair, trimmed mustache, 5 foot 8 inches tall. 190 pounds. Large scar across left cheek. Likely wounded following gunfight with Solace Guardsmen.\n\nFor murder, desertion, armed robbery.\nIMMEDIATELY CONTACT\nBUREAU OF ROYAL CITIZENS\226\128\153 AFFAIRS\n\nWritten by Lazarubius and BoiledBone"
}
v1.perks.hippocratic = {
    ["name"] = "\'Hippocratic\'",
    ["desc"] = "Forgo your guns, provide better surgery to your Allies using your First Aid Kit.\nPerforming surgery on your Allies inspire them with morale.\nTaking a life in self defense will damage your will to fight.",
    ["icon"] = "96285132800375",
    ["perk"] = true,
    ["lore"] = "\"Do you remember what color the sky was before the bombs fell?\"\n\n\"Do you remember the scent of flowers before they were all snuffed out by smoke?\"\n\nI will keep you in my memories, so that you will never fear being forgotten.\n\n\"We\226\128\153ll die under the orders of commanders we\226\128\153ll never meet.\"\n\n\"We\226\128\153ll ensure that families are never reunited with every bullet we spend.\"\n\nI will never take a life, so that a family won\226\128\153t mourn for those I\226\128\153ve buried.\n\n\"I can\226\128\153t do this anymore.\"\n\n\"I just want to lie down and die already.\"\n\nI will never falter.\n\nI will never fail."
}
v1.perks.cursed = {
    ["name"] = "\'Cursed\'",
    ["desc"] = "You\'ve desecrated hallowed grounds. You know too much.",
    ["icon"] = "114894113099243",
    ["perk"] = true,
    ["lore"] = "It stalks, it watches, it understands.\n\nIt sees a boy, a boy who escaped a fate laid out for him, and dared challenge it.\n\nOh this poor boy.\n\nPeople say War is Hell, but that couldn\'t be further from the truth.\n\nIn Hell, they punish the wicked, but there are only innocents in this War.\n\n\'Its safe here, just stay with me.\'\n\nThey coddled, knowing that it was the only place where it couldn\'t find them.\n\nBut the boy was selfish, he wanted escape.\n\nHe wanted to be free.\n\nOne body, three souls, he was getting close.\n\nIt stalks, it watches, it understands.\n\nYou are not safe.\n\nYou are not safe.\n\nYou are not safe.\n\nYou are not safe.\n\nYou are not safe.\n\nYou are not safe.\n\nYou are not safe."
}
v1.conscript_kits.infantry = {
    ["name"] = "Infantry",
    ["desc"] = "Standard issue frontliner.\nShoot to kill.",
    ["icon"] = "17496049645",
    ["perk"] = true,
    ["lore"] = "- Equipped with the \'Prince\' Long Rifle."
}
v1.conscript_kits.assault = {
    ["name"] = "Assault",
    ["desc"] = "Close range shotgunner.\nBreak their defenses.",
    ["icon"] = "17858644652",
    ["perk"] = true,
    ["lore"] = "- Equipped with a \'Equine\' Riding Shotgun."
}
v1.conscript_kits.medic = {
    ["name"] = "Medic",
    ["desc"] = "Qualified field surgeon.\nAssist the team.",
    ["icon"] = "17778483663",
    ["perk"] = true,
    ["lore"] = "- Equipped with a \'Honour\' Duty Pistol.\n- Equipped with a First Aid Kit"
}
v1.conscript_kits.sniper = {
    ["name"] = "Marksman",
    ["desc"] = "Long range sniper.\nPick out the weak.",
    ["icon"] = "18352089477",
    ["perk"] = true,
    ["lore"] = "- Equipped with a \'Volk\' Scoped Rifle."
}
v1.conscript_kits.scout = {
    ["name"] = "Scout",
    ["desc"] = "Spotting and recon.\nProvide eyes in the dark.",
    ["icon"] = "18693337243",
    ["perk"] = true,
    ["lore"] = "- Equipped with a \'Grace\' Service Revolver.\n- Equipped with Binoculars"
}
if game:GetService("RunService"):IsStudio() == true then
    v1.base_rein_time = 2
end;
return v1;
