local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage.Shared.Library.MeleeRules)
local Controller = {}

function Controller.Remote()
	return ReplicatedStorage.Shared.Library.Events:WaitForChild("ClassCombat")
end

function Controller.Direction()
	local camera = workspace.CurrentCamera
	local point = game:GetService("UserInputService"):GetMouseLocation()
	local ray = camera:ScreenPointToRay(point.X, point.Y)
	local character = Players.LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	if not head then return ray.Direction end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	local pointAt = hit and hit.Position or ray.Origin + ray.Direction * 1000
	local delta = pointAt - head.Position
	return delta.Magnitude > .01 and delta.Unit or ray.Direction
end

function Controller.Swing(self, mode)
	local character = Players.LocalPlayer.Character
	if not self.Equipped or self.Equipping or not self.tool or self.tool.Parent ~= character
		or self.Charging or self.Meleeing or self.Inspiring or Players.LocalPlayer:GetAttribute("FreeLook")
		or os.clock() < (self.nextSwing or 0) then return end
	self.nextSwing = os.clock() + Rules.Lance.Interval
	self.Meleeing = true
	self._meleeStep = (self._meleeStep or 0) % 2 + 1
	self:_stopAllExcept()
	local animation = (mode == "Stab" and "Stab" or "Melee") .. self._meleeStep
	local track = self:_playAnim(animation)
	if track then track.Looped = false; track.Priority = Enum.AnimationPriority.Action3 end
	Controller.Remote():FireServer(mode, Controller.Direction())
	local tool = self.tool
	task.delay(Rules.Lance.Interval, function()
		self.Meleeing = false
		if track then track:Stop(.08) end
		if self.Equipped and self.tool == tool and tool.Parent == character then
			self:_restoreBase()
			if mode == "ShieldSwing" and self.holding_aim_button then Controller.Remote():FireServer("Block", true) end
		end
	end)
end

return Controller
