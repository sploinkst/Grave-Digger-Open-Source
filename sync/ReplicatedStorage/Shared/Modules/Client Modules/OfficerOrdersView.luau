-- Uses the master's authored selector; duration is changed by the tool's T input.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Selection = require(script.Parent.MasterUI.SelectionView)
local View = {}; View.__index = View
View.Orders = {"Advance", "Defend", "Focus"}
View.Durations = {60, 30}
local icons = {"81453171147177", "110211160912800", "138309011037793"}
function View.new(onSelect, onDuration, canSelect, onClose)
 local self = setmetatable({OnSelect=onSelect, OnDuration=onDuration, CanSelect=canSelect, Selecting=false}, View)
 self.Selector = Selection.new(onSelect, canSelect, "OfficerOrderSelecting", function() self.Selecting=false; if onClose then onClose() end end)
 return self
end
function View:SetState(order, duration, charges) self.Order=order; self.Duration=duration; self.Charges=charges end
function View:SetMessage(message)
 if message and _G.popupmsg then _G.popupmsg("officer_order", message, 2) end
end
function View:Show(character) self:Hide(); self.Character=character end
function View:CloseSelector() self.Selector:Close(); self.Selecting=false end
function View:ToggleSelector()
 if self.Selecting then self:CloseSelector(); return end
 local entries={}
 for index, name in ipairs(View.Orders) do table.insert(entries,{id=name,name=name.." Order",icon=icons[index]}) end
 self.Selecting=self.Selector:Open(self.Character, entries)
end
function View:Hide() self:CloseSelector() end
function View:Destroy() self:Hide(); self.Selector:Destroy() end
return View
