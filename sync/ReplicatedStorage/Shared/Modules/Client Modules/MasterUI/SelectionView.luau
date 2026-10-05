-- Port of ingameScript.create_selectionbox/display_selections. Only clones ex.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Assets = require(game:GetService("ReplicatedStorage").Shared.Library.AuthoredAssets)
local View = {}; View.__index = View
local active
local KEYS = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four,
	Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine}

function View.new(onSelect, canSelect, attribute, onClose)
	return setmetatable({OnSelect = onSelect, CanSelect = canSelect, Attribute = attribute,
		OnClose = onClose, Connections = {}, Buttons = {}, Selecting = false}, View)
end
function View:Close()
	if not self.Selecting then return end
	self.Selecting = false
	if self.Character then
		local character = self.Character
		task.defer(function() if character.Parent and not self.Selecting then character:SetAttribute(self.Attribute, nil) end end)
	end
	if active == self then
		active = nil
		if self.Panel then self.Panel.Visible = false; self.Panel.selectedoption.Text = "" end
		UIS.MouseBehavior = self.MouseBehavior; UIS.MouseIconEnabled = self.MouseIcon
		GuiService.SelectedObject = self.SelectedObject
	end
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	table.clear(self.Connections)
	for _, button in ipairs(self.Buttons) do button:Destroy() end
	table.clear(self.Buttons)
	if self.OnClose then self.OnClose() end
end
function View:Open(character, entries)
	if active then active:Close() end
	local core = Assets.CoreGame()
	local panel = core and core:FindFirstChild("selectionboxes")
	local selections = panel and panel:FindFirstChild("selections")
	local template = selections and selections:FindFirstChild("ex")
	if not template or not panel:FindFirstChild("selectedoption") then
		warn("[MasterUI] Missing authored main.core_game.selectionboxes.selections.ex")
		return false
	end
	self.Character = character; self.Panel = panel; self.Selecting = true; active = self
	character:SetAttribute(self.Attribute, true)
	self.MouseBehavior = UIS.MouseBehavior; self.MouseIcon = UIS.MouseIconEnabled
	self.SelectedObject = GuiService.SelectedObject
	UIS.MouseBehavior = Enum.MouseBehavior.Default; UIS.MouseIconEnabled = true
	for _, child in ipairs(selections:GetChildren()) do
		if child:IsA("GuiObject") then child.Visible = false end
	end
	local function selectEntry(entry)
		if not self.Selecting or not self.CanSelect() then return end
		self:Close(); self.OnSelect(entry.id)
	end
	for index, entry in ipairs(entries) do
		local button = template:Clone()
		button.Name = tostring(entry.id); button.internal.Value = tostring(entry.id)
		button.display.Value = entry.name; button.LayoutOrder = index; button.num.Text = tostring(index)
		if entry.icon then button.icon.Image = "rbxassetid://" .. tostring(entry.icon):gsub("rbxassetid://", "") end
		button.highlighted.Visible = false; button.Visible = true; button.Parent = selections
		table.insert(self.Buttons, button)
		table.insert(self.Connections, button.MouseEnter:Connect(function()
			panel.selectedoption.Text = entry.name; button.highlighted.Visible = true
		end))
		table.insert(self.Connections, button.MouseLeave:Connect(function()
			panel.selectedoption.Text = ""; button.highlighted.Visible = false
		end))
		table.insert(self.Connections, button.Activated:Connect(function() selectEntry(entry) end))
	end
	panel.selectedoption.Text = ""; panel.Visible = true
	if UIS.GamepadEnabled then GuiService.SelectedObject = self.Buttons[1] end
	table.insert(self.Connections, UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then self:Close(); return end
		local index = table.find(KEYS, input.KeyCode)
		if index and entries[index] then selectEntry(entries[index]) end
	end))
	table.insert(self.Connections, character.AncestryChanged:Connect(function(_, parent) if not parent then self:Close() end end))
	return true
end
function View:Destroy() self:Close() end
return View
