--!strict
-- Officer equipment: G draws the server-created physical whistle. Its local
-- ToolClasses controller owns draw/hold/use animations once it is equipped.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseEquipment = require(script.Parent.Parent.BaseEquipment)
local WhistleEquip = ReplicatedStorage.Shared.Library.Events:WaitForChild("WhistleEquip") :: RemoteEvent

local TrenchWhistle = {}
TrenchWhistle.__index = TrenchWhistle
setmetatable(TrenchWhistle, { __index = BaseEquipment })

function TrenchWhistle.new()
	local self = BaseEquipment.new({ name = "Trench Whistle" })
	setmetatable(self, TrenchWhistle)
	self.className = "TrenchWhistle"
	self.MaxEquipment = 1
	self.InstantActivate = true
	self.UnequipHeldToolsOnActivate = false
	return self
end

function TrenchWhistle:Activate()
	if self.Stopped or not self.Character then return end
	-- G is a true draw/holster toggle.  Previously a drawn whistle could never
	-- be put away through the equipment binding.
	local draw = self.Character:GetAttribute("WhistleEquipped") ~= true
	if draw then
		require(ReplicatedStorage.Shared.Modules["Client Modules"].InventoryService).UnequipCurrent()
	end
	WhistleEquip:FireServer(draw)
end

function TrenchWhistle:Stop()
	if self.Character and self.Character:GetAttribute("WhistleEquipped") then
		WhistleEquip:FireServer(false)
	end
	BaseEquipment.Stop(self)
end

return TrenchWhistle
