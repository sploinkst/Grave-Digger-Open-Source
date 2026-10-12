local UI = require(script.Parent.UI)
local module, started = {}, false
function module.start_module(menu)
	if started then return end
	started = true
	UI.Mount("Credits", function(scene, scope)
		local scroll = UI.Find(scene, "creditsframe/menu/scroll") or UI.Find(scene, "Main_Frame/Menu/scroll")
		if scroll and scroll:IsA("ScrollingFrame") then scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end
		UI.Bind(scope, scene, "Main_Frame/Back", menu.Close)
	end)
end
return module
