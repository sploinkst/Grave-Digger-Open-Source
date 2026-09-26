--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseTool = require(script.Parent.Parent.BaseTool)
local TRAPS = { "Mantrap", "Tin Bomb", "Gas Shell", "Dynamite Stack", "Shotshell Trap", "Light Lure" }
local HunterKit = {}; HunterKit.__index = HunterKit; setmetatable(HunterKit, { __index = BaseTool })

function HunterKit.new(info)
	local self = setmetatable(BaseTool.new(info), HunterKit)
	self.className = "HunterKit"; self.name = "HunterKit"; self.Designation = "Equipment"
	self.SelectedTrap = 1
	return self
end
function HunterKit:_event(): RemoteEvent
	return ReplicatedStorage.Shared.Library.Events:WaitForChild("HunterKitAbility") :: RemoteEvent
end
function HunterKit:_tellSelection()
	self:notify(string.format("%d: %s", self.SelectedTrap, TRAPS[self.SelectedTrap]))
end
function HunterKit:activate()
	if self.Equipped then self:_event():FireServer("PlaceTrap", TRAPS[self.SelectedTrap]) end
end
function HunterKit:reload()
	self.SelectedTrap = self.SelectedTrap % #TRAPS + 1; self:_tellSelection()
end
function HunterKit:aim()
	if self.Equipped then self:_event():FireServer("PlaceTripwire") end
end
function HunterKit:endAiming() end
function HunterKit:setAltMode()
	self.SelectedTrap = (self.SelectedTrap - 2) % #TRAPS + 1; self:_tellSelection()
end
HunterKit.Tool_Image = "rbxassetid://78664710036907"; HunterKit.Medal_Cost = 0
HunterKit.Weight = 1; HunterKit.Designation = "Equipment"
return HunterKit
