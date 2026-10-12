local Data = require(script.Parent.MasterReference.Equipments)
local Rules = {}
Rules.ByController = {AmmoPack = "soldat", MiningBombLauncher = "rook", MedicalSyrettes = "mortician", TrenchWhistle = "officer", SmokescreenBombs = "jaeger", ThrowingAxes = "lancer", RallyBanner = "vanguard"}
function Rules.Get(controller)
 local definition = Data[Rules.ByController[controller] or controller]
 if definition and definition.name ~= "lol" then return definition end
end
function Rules.Configure(equipment)
 local definition = Rules.Get(equipment.className)
 if definition then equipment.MaxEquipment = definition.ammo; equipment.EquipmentReloadTime = definition.cd end
 return definition
end
return Rules
