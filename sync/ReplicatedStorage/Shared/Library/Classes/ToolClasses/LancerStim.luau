local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Tool = require(script.Parent.Parent.MasterTool)
local Authored = require(RS.Shared.Library.AuthoredAssets)
local Stim = {}
Stim.__index = Stim
setmetatable(Stim, {__index = Tool})
Stim.Weight = 0
Stim.Designation = "Equipment"
Stim.Medal_Cost = 0

function Stim.new(info)
    local self = setmetatable(Tool.new(info, "LancerStim", "lancerstim"), Stim)
    self.Display_Name = "Painkiller Injector"
    self.Kind = "Lancer"
    self.model_reference = self.model_reference or Authored.Find("lancerstim", Authored.Roots(), "Model")
    local model = self.model_reference
    self.motor_6d_data.Part1 = model and (model:FindFirstChild("hitbox", true) or model:FindFirstChildWhichIsA("BasePart", true))
    self.EquipWelds = {
        lefthand = false,
        equipc0 = CFrame.new(-0.524185181, -0.953423262, 0.0105342865, 1, -2.84217094e-14, 0, 0, -5.55623067e-16, 0.99999994, 2.84217094e-14, -1, 5.5562312e-16),
        equipc1 = CFrame.identity,
    }
    self.motor_6d_data.C0 = self.EquipWelds.equipc0
    self.motor_6d_data.C1 = self.EquipWelds.equipc1
    return self
end

function Stim:_prepareAnimations()
    Tool._prepareAnimations(self)
    local animations = RS.Shared.Assets:FindFirstChild("Animations")
    local roots = {}
    if animations then table.insert(roots, animations) end
    local folder = Authored.Find("lancerstim", roots) or Authored.Find("LancerStim", roots)
    if folder then
        for binding, name in pairs({Use="use", Draw="draw", Hold="held", Sprint="sprint", Unequip="unequip"}) do
            self.animations[binding] = self.animations[binding] or folder:FindFirstChild(name, true)
        end
    end
end

function Stim:_on_give()
    local remote = RS.Shared.Library.Events:WaitForChild("UtilityAction")
    self._stimConnection = remote.OnClientEvent:Connect(function(tool, action)
        if tool == self.tool and action == "LancerStimUsed" then self._injectionCommitted = true end
    end)
end

function Stim:activate()
    if not self:Ready() or self.tool:GetAttribute("Injecting") then return end
    local charges = self.tool:GetAttribute("Charges")
    if charges ~= nil and charges <= 0 then return end
    self._injectionCommitted = false
    if self:Action("Use", 1.05, function()
        if self._injectionCommitted or self.tool:GetAttribute("Charges") == 0 then
            local character = Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:UnequipTools() end
        end
    end) then
        self:Request("UtilityAction", "LancerStim")
    end
end

function Stim:aim() end
function Stim:_on_unequip()
    self:Request("UtilityAction", "CancelLancerStim")
    self._injectionCommitted = false
    Tool._on_unequip(self)
end

function Stim:destroy()
    if self.tool then self:Request("UtilityAction", "CancelLancerStim") end
    if self._stimConnection then self._stimConnection:Disconnect() end
    Tool.destroy(self)
end
return Stim
