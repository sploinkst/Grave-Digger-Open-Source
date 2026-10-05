local Players = game:GetService("Players")
local Audio = require(game:GetService("ReplicatedStorage").Shared.Library.GameAudio)
local module, started = {}, false

function module.start_module()
	if started then return end
	started = true
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local bound = setmetatable({}, {__mode = "k"})
	local function bind(object)
		if bound[object] or not (object:IsA("GuiButton") or object:IsA("TextBox")) then return end
		local ancestor, inMenu = object, false
		while ancestor and ancestor ~= gui do
			if ancestor.Name == "Menu" or ancestor.Name == "Menu_Scenes" or ancestor.Name == "loadout_menu" then inMenu = true end
			ancestor = ancestor.Parent
		end
		if not inMenu then return end
		bound[object] = true
		local function play(name)
			local parent = object
			while parent and parent ~= gui do
				if parent:IsA("GuiObject") and not parent.Visible then return end
				if parent:IsA("ScreenGui") and not parent.Enabled then return end
				parent = parent.Parent
			end
			if parent == gui then Audio.Play("Menu", name) end
		end
		object.MouseEnter:Connect(function() play("hover") end)
		object.SelectionGained:Connect(function() play("hover") end)
		if object:IsA("GuiButton") then
			object.Activated:Connect(function() play("button") end)
		elseif object:IsA("TextBox") then
			object.Focused:Connect(function() play("button") end)
		end
	end
	for _, object in gui:GetDescendants() do bind(object) end
	gui.DescendantAdded:Connect(bind)
end
return module
