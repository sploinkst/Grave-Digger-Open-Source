-- Compatibility entry point. Native calls never use the obsolete remotes.
local Dispatch = require(script.Parent.Parent.Parent.Library.MasterEffects.Dispatch)
return function(name, payload)
 return Dispatch.Visual(name, payload)
end
