local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.knife))
v1.name = "\'Dan-Janiel\' Bottle"
v1.desc = "Your trusted bottle for forgetting, the best you have at all times."
v1.lore = "Roast pork, bully beef, soup and plum duff for everyone!\n\nThe crowd cheered as the wooden basket slammed on the table, clinking of bottles, shaking of plates and hungry faces scarfing down perhaps the most exotic meal they will ever have in their life-time.\n\nCelebration is due for moments like these, a bottle of cheap \'Dan-Janiel\' to help wash away what they\'ll do tomorrow and what they\'re currently doing today.\n\nMany discuss about their friends, their past, some even their families. There were smiles, these contortions in facial muscles that once seemed impossible to ever stretch in place, now loose and all around.\n\nJust one more sip then, one more.\n\nYou\'ll never have a meal like this in your life ever again.\n\nDon\'t think about the cans of stew, the charred rats and the mushroom soup, they\'re not real, you\'re having the best time with your fellow brothers and sisters.\n\nIt\'s okay to forget.\n\nYou deserve so much better."
v1.size = 1
v1.icon = "137193950943929"
v1.animations = "bottle"
v1.melee_sound = "bottle"
v1.alt_team_icon = nil
v1.alt_team_model = nil
v1.assists = { "Attack from behind for an instant take-down.", "You will steal dog-tags off those you murder.", "Hold [Q] to forget the horrors if just for a moment." }
v1.holster_point = "Torso"
v1.holsterc0 = CFrame.new(-0.593933105, -1.18787014, 0.719642639, 3.87428628e-7, 0.17364803, -0.98480773, -3.50177999e-7, -0.98480773, -0.17364803, -1, 4.12134227e-7, -3.2073504e-7)
v1.holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
v1.special = {}
return v1;
