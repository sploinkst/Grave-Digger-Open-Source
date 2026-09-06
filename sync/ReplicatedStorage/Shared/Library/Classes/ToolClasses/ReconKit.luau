local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BaseTool = require(script.Parent.Parent.BaseTool)
local ReconKit = {}
ReconKit.__index = ReconKit
ReconKit.Weight = 0
setmetatable(ReconKit, {__index = BaseTool})

function ReconKit.new(info)
	local self = BaseTool.new(info)
	setmetatable(self, ReconKit)
	self.className = "ReconKit"
	self.Designation = "Miscellaneous"
	return self
end

function ReconKit:activate()
	if not self.tool or self.tool.Parent ~= Players.LocalPlayer.Character
		or not self.Equipped or os.clock() < (self.nextMark or 0) then return end
	self.nextMark = os.clock() + 1
	local camera = workspace.CurrentCamera
	if not camera then return end
	local point = game:GetService("UserInputService"):GetMouseLocation()
	local ray = camera:ScreenPointToRay(point.X, point.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	local model = hit and hit.Instance
	while model and not Players:GetPlayerFromCharacter(model) do model = model.Parent end
	if model then
		ReplicatedStorage.Shared.Library.Events:WaitForChild("ClassIntel"):FireServer("ReconMark", model)
	end
end

function ReconKit:on_give(tool)
	self.tool = tool
	self.connections = {
		tool.Activated:Connect(function() self:activate() end),
		tool.Unequipped:Connect(function() self.Equipped = false end),
	}
end

function ReconKit:equip()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	self.Equipped = true
	humanoid:EquipTool(self.tool)
	self:notify("Recon Kit: point at an enemy and press M1 to mark them for nearby allies.")
end

function ReconKit:unequip()
	self.Equipped = false
	if self.tool and self.tool.Parent == Players.LocalPlayer.Character then
		self.tool.Parent = Players.LocalPlayer.Backpack
	end
end

function ReconKit:destroy()
	self.Equipped = false
	for _, connection in self.connections or {} do connection:Disconnect() end
	self.connections = {}
end

return ReconKit
