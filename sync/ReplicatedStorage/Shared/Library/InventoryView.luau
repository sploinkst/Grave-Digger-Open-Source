local Assets = require(script.Parent.AuthoredAssets)
local View = {}
local prepared = setmetatable({}, {__mode = "k"})
function View.Template(playerGui)
 local inventory=playerGui:FindFirstChild("Inventory")
 local holder=inventory and inventory:FindFirstChild("inventory")
 local template=holder and holder:FindFirstChild("ex")
 if not template then
  holder=inventory and inventory:FindFirstChild("Main")
  template=holder and holder:FindFirstChild("Example")
 end
 if inventory and inventory:IsA("ScreenGui") then inventory.Enabled=true end
 if inventory then
  for _,other in ipairs(inventory:GetChildren()) do
   if other:IsA("GuiObject") and other~=holder and (other.Name=="Main" or other.Name=="inventory") then other.Visible=false end
  end
 end
	if not holder or not template or not template:IsA("GuiObject") then return nil, nil end
	if not prepared[holder] then
		prepared[holder] = true
		for _, child in ipairs(holder:GetChildren()) do
			if child:IsA("GuiObject") and not child:GetAttribute("InventorySlot") then child.Visible = false end
		end
	end
	holder.Visible = true
	return holder, template
end
function View.Parts(ui)
	if not ui or not ui.Parent then return nil, nil, nil end
	return ui:FindFirstChild("line") or ui:FindFirstChild("Frame", true),
		ui:FindFirstChild("icon") or ui:FindFirstChild("ImageLabel", true),
		ui:FindFirstChild("num") or ui:FindFirstChild("Hotkey", true)
end
return View
