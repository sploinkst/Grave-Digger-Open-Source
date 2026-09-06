local module = {}

local cmdr_module = require(script.Cmdr)

function module.start_module()
	cmdr_module:RegisterTypesIn(script.Types)
	cmdr_module:RegisterHooksIn(script.Hooks)
	cmdr_module:RegisterCommandsIn(script.Commands)
end

return module
