local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseEquipment = require(script.Parent.Parent.BaseEquipment)
local Rules = require(ReplicatedStorage.Shared.Library.RookLauncherRules)
local Class = {}
Class.__index = Class
setmetatable(Class, {__index = BaseEquipment})

function Class.new()
	local self = setmetatable(BaseEquipment.new({name = "Mining Bomb Launcher"}), Class)
	self.className = "MiningBombLauncher"
	self.MaxEquipment = Rules.EquipmentCapacity
	self.EquipmentReloadTime = Rules.EquipmentRecharge
	self.InstantActivate = true
	return self
end
function Class:GetCount()
	return self.Character and self.Character:GetAttribute("MiningBombLauncherCharges") or Rules.EquipmentCapacity
end
function Class:SpecialStart()
	local function refresh()
		local gui = self:_getEquipmentGui()
		local count = gui and gui:FindFirstChild("count")
		if count and count:IsA("TextLabel") then count.Text = tostring(self:GetCount()) end
	end
	self.ChargeConnection = self.Character:GetAttributeChangedSignal("MiningBombLauncherCharges"):Connect(refresh)
	refresh()
end
function Class:Activate()
	if self.Stopped or not self.Character then return end
	if not self.Character:FindFirstChild("RookLauncher") then
		require(ReplicatedStorage.Shared.Modules["Client Modules"].InventoryService).UnequipCurrent()
	end
	ReplicatedStorage.Shared.Library.Events:WaitForChild("RookLauncherAction"):FireServer(nil, "ToggleEquip")
end
function Class:Stop()
	if self.ChargeConnection then self.ChargeConnection:Disconnect(); self.ChargeConnection = nil end
	BaseEquipment.Stop(self)
end
return Class
