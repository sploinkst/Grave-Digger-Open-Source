-- Normalized master chemicals; short IDs and numeric slots share a definition.
local Data = {}
Data[1] = {int = "bic", icon = "74802872617600", name = "Bicaridine", desc = "Improves Patient healing through clotting and patches up light wounds.", last = 80}
Data[Data[1].int] = Data[1]
Data[2] = {int = "syn", icon = "96118896167664", name = "Synaptizine", desc = "Improves Patient sprinting alacrity.", last = 80}
Data[Data[2].int] = Data[2]
Data[3] = {int = "mep", icon = "76686378846497", name = "Mephedrone", desc = "Improves Patient Melee and Mining capabilities.", last = 80}
Data[Data[3].int] = Data[3]
Data[4] = {int = "hyd", icon = "87152867318813", name = "Hydrocodone", desc = "Improves Patient stability and pain tolerance.", last = 80}
Data[Data[4].int] = Data[4]
Data[5] = {int = "hal", icon = "105133707458681", name = "Haloperidol", desc = "Improves Patient focus and handling.", last = 80}
Data[Data[5].int] = Data[5]
Data[6] = {int = "ama", icon = "119238951619730", name = "Amatoxin", desc = "Causes Pox build-up in Patients over time.", last = 25}
Data[Data[6].int] = Data[6]
Data[7] = {int = "per", name = "Peridaxon", desc = "Rapidly purges all Chemicals from the Patient.", last = 20}
Data[Data[7].int] = Data[7]
Data[8] = {int = "int", name = "Initropidril", desc = "Immediately induces sickness in Patients and deteriorates health.", last = 8.5}
Data[Data[8].int] = Data[8]
Data[9] = {int = "sickness", name = "Pox", desc = "Causes chemical build-up in Patients, harmless on its own.", last = 10}
Data[Data[9].int] = Data[9]
Data[10] = {int = "tric", name = "Tricordrazine", desc = "Rapidly purges all Chemicals from the Patient and instantly heals wounds.", last = 20}
Data[Data[10].int] = Data[10]
Data[11] = {int = "inap", name = "Inaprovaline", desc = "Patch wounds and increase adrenal levels, however suffers from tremors.", last = 30}
Data[Data[11].int] = Data[11]
Data[12] = {int = "eth", name = "Ethanol", desc = "Soothes the pain.", last = 30}
Data[Data[12].int] = Data[12]
return Data
