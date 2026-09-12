local v1 = require(game.ReplicatedStorage.shared.bFunctions):deepCopy(require(game.ReplicatedStorage.weapon_modules.enfield))
v1.name = "\'Jesse\' Precision Rifle"
v1.variant = "enfield"
v1.desc = "Modification of the \'Jesse\' Combat Rifle"
v1.lore = "The \226\128\152Jesse\226\128\153 Combat Rifle has proved itself a staple amongst the Nation\226\128\153s soldiers for its high capacity and smooth bolt action - though somewhat lacking in damage over range compared to its competitors such as the \226\128\152Prince\226\128\153 Long Rifle, it is nevertheless a favorite of many due to its ergonomic advantages.\n\nSimilarly, the weapon has received a great deal of modifications to suit various users\226\128\153 needs, a common being the installation of a bipod, allowing for even greater comfort while prone and incredible stability and thus accuracy when settled on a surface. Though somewhat awkward to handle when on the move, this modification has seen extensive use by guards due to their generally sedentary occupation.\n\nIn addition, when mounted, Sergeant Major Jesse\226\128\153s famed rapid-fire technique became ever-more effective, considerably increasing the weapon\226\128\153s maximum rate of fire by less skilled users. The bipod solidified its elite status in the defense of a Nation supply outpost, the guards\226\128\153 flurry of fire mowing down waves of fanatic imperials until their retreat. The echoes of .303 Spitzer were mistaken for machine gun fire by reinforcements.\n\nWritten by Deceased_Rabbit and Lazarubius."
v1.icon = "91074694421110"
v1.assists = { "Added bipod provides stability and rate of fire when deployed.", "Added weight however impairs accuracy and handling." }
v1.accuracy = 14
v1.moving_accuracy = 100
v1.aim_speed = 0.35
v1.movement = 2
v1.firing_movement = 2
return v1;
