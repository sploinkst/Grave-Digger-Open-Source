	local v4 = {
	    ["add_chem"] = function(p1, p2, p3) --[[ Line: 4 ]]
	        if not (p2.Parent and p2.Parent:FindFirstChild("dreadnought")) then
	            if p1 and (p2 and p3) then
	                for _ = 1, p3 do
	                    local l_IntValue_0 = Instance.new("IntValue")
	                    l_IntValue_0.Name = p1
	                    l_IntValue_0.Parent = p2
	                    l_IntValue_0.Value = tick()
	                end;
	            end;
	        end;
	    end,
	    [1] = {
	        ["int"] = "bic",
	        ["icon"] = "74802872617600",
	        ["name"] = "Bicaridine",
	        ["desc"] = "Improves Patient healing through clotting and patches up light wounds.",
	        ["last"] = 80
	    },
	    ["bic"] = v4[1],
	    [2] = {
	        ["int"] = "syn",
	        ["icon"] = "96118896167664",
	        ["name"] = "Synaptizine",
	        ["desc"] = "Improves Patient sprinting alacrity.",
	        ["last"] = 80
	    },
	    ["syn"] = v4[2],
	    [3] = {
	        ["int"] = "mep",
	        ["icon"] = "76686378846497",
	        ["name"] = "Mephedrone",
	        ["desc"] = "Improves Patient Melee and Mining capabilities.",
	        ["last"] = 80
	    },
	    ["mep"] = v4[3],
	    [4] = {
	        ["int"] = "hyd",
	        ["icon"] = "87152867318813",
	        ["name"] = "Hydrocodone",
	        ["desc"] = "Improves Patient stability and pain tolerance.",
	        ["last"] = 80
	    },
	    ["hyd"] = v4[4],
	    [5] = {
	        ["int"] = "hal",
	        ["icon"] = "105133707458681",
	        ["name"] = "Haloperidol",
	        ["desc"] = "Improves Patient focus and handling.",
	        ["last"] = 80
	    },
	    ["hal"] = v4[5],
	    [6] = {
	        ["int"] = "ama",
	        ["icon"] = "119238951619730",
	        ["name"] = "Amatoxin",
	        ["desc"] = "Causes Pox build-up in Patients over time.",
	        ["last"] = 25
	    },
	    ["ama"] = v4[6],
	    [7] = {
	        ["int"] = "per",
	        ["name"] = "Peridaxon",
	        ["desc"] = "Rapidly purges all Chemicals from the Patient.",
	        ["last"] = 20
	    },
	    ["per"] = v4[7],
	    [8] = {
	        ["int"] = "int",
	        ["name"] = "Initropidril",
	        ["desc"] = "Immediately induces sickness in Patients and deteriorates health.",
	        ["last"] = 8.5
	    },
	    ["int"] = v4[8],
	    [9] = {
	        ["int"] = "sickness",
	        ["name"] = "Pox",
	        ["desc"] = "Causes chemical build-up in Patients, harmless on its own.",
	        ["last"] = 10
	    },
	    ["sickness"] = v4[9],
	    [10] = {
	        ["int"] = "tric",
	        ["name"] = "Tricordrazine",
	        ["desc"] = "Rapidly purges all Chemicals from the Patient and instantly heals wounds.",
	        ["last"] = 20
	    },
	    ["tric"] = v4[10],
	    [11] = {
	        ["int"] = "inap",
	        ["name"] = "Inaprovaline",
	        ["desc"] = "Patch wounds and increase adrenal levels, however suffers from tremors.",
	        ["last"] = 30
	    },
	    ["inap"] = v4[11],
	    [12] = {
	        ["int"] = "eth",
	        ["name"] = "Ethanol",
	        ["desc"] = "Soothes the pain.",
	        ["last"] = 30
	    },
	    ["eth"] = v4[12]
	}
	return v4;
