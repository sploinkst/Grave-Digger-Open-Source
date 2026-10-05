local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Targeting = require(ReplicatedStorage.Shared.Modules["Client Modules"].MedicalUI.Targeting)
local Medical = require(ReplicatedStorage.Shared.Library.MedicalRules)
local BaseEquipment = require(script.Parent.Parent.BaseEquipment)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remote = Shared.Library.Events:WaitForChild("MedicalSyrettes")
local Syrettes = setmetatable({}, { __index = BaseEquipment })
Syrettes.__index = Syrettes

function Syrettes.new()
	local self = setmetatable(BaseEquipment.new({name = "Medical Syrettes"}), Syrettes)
	self.className = "MedicalSyrettes"
	self.MaxEquipment = 2
	self.EquipmentReloadTime = 20
	self.TapTargetHoldDrop = true
	self.AssistClone = Shared.Assets.UI.Assist_BB:Clone()
	return self
end

function Syrettes:GetCount()
	return self.Character and self.Character:GetAttribute("SyretteCharges") or 0
end

-- Charges come from the server; the shared reload wheel is cosmetic.
function Syrettes:CountDown()
	task.defer(function()
		if not self.Stopped then self:StartCount() end
	end)
end

function Syrettes:SpecialStart()
	local function refresh()
		self.MaxEquipment = self.Character:GetAttribute("SyretteCapacity") or 2
		local gui = self:_getEquipmentGui()
		local count = gui and gui:FindFirstChild("count")
		if count then count.Text = tostring(self:GetCount()) end
		self:StartCount()
	end
	self.ChargeConnection = self.Character:GetAttributeChangedSignal("SyretteCharges"):Connect(refresh)
	refresh()
	self.Connection = RunService.RenderStepped:Connect(function()
		self.PlayerTarget = nil
		self.AssistClone.Parent = nil
		local patient = Targeting.Find(Medical.SyretteRange)
		if patient and Medical.CanReceiveSyrette(patient.humanoid.Health, patient.player:GetAttribute("Clotting"),
			patient.character:GetAttribute("SurgeryBlocked") or patient.character:GetAttribute("IsDreadnought")) then
			self.PlayerTarget = patient.character
			self.AssistClone.Parent = patient.root
		end
	end)
end

function Syrettes:Activate(_, drop)
	if self:GetCount() <= 0 then return end
	if drop then Remote:FireServer() elseif self.PlayerTarget then Remote:FireServer(self.PlayerTarget) end
end

function Syrettes:SpecialStop()
	if self.Connection then self.Connection:Disconnect() end
	if self.ChargeConnection then self.ChargeConnection:Disconnect() end
	self._holding = false
	self.PlayerTarget = nil
end

return Syrettes
