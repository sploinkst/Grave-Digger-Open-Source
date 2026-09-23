local UI = require(script.Parent.UI)
local module, started = {}, false
function module.start_module(menu)
	if started then return end
	started = true
	UI.Mount("Credits", function(scene, scope)
		UI.Bind(scope, scene, "Main_Frame/Back", menu.Close)
	end)
end
return module
