-- No voice lines are present in the supplied table. Selection safely returns nil.
local Data = require(script.Parent.MasterReference.Wardialogue)
local Dialogue = {}
function Dialogue.Select(mode, faction, role)
 local key = string.lower(mode .. "_" .. faction .. (role and "_" .. role or ""))
 local lines = Data[key] or Data[string.lower(mode)]
 if not lines or #lines == 0 then return nil end
 return lines[math.random(1, #lines)]
end
return Dialogue
