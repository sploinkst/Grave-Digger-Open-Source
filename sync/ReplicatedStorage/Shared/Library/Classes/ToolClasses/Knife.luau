local Players = game:GetService("Players")
local Knife = require(script.Parent.Parent.UtilityTool).create("Knife", "knife", "Melee")

-- Hand mount from weapon_modules.knife, against the authored hitbox root.
Knife.EquipWelds = {
	lefthand = false,
	equipc0 = CFrame.new(-0.193084717, -0.886356354, -0.925292969, 0, 0, -1, 0.99999994, 0, 0, 0, -0.999999046, 0),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

function Knife:activate()
	if not self:Ready() or self.Meleeing then return end
	self:_stopAllExcept()
	self._meleeStep = (self._meleeStep or 0) % 2 + 1
	local name = "Melee" .. self._meleeStep
	local animations = self.RegisteredAnimations or {}
	if not animations[name] then name = "Melee1" end
	if not animations[name] then return end
	self.Meleeing = true
	self._masterAction = true
	self._masterGeneration = (self._masterGeneration or 0) + 1
	local generation = self._masterGeneration
	local track = self:_playAnim(name)
	if not track then self.Meleeing = false; self._masterAction = false; return end
	track.Looped = false
	local character = Players.LocalPlayer.Character
	local function active()
		return self.Equipped and self._masterGeneration == generation and self.tool and self.tool.Parent == character
	end
	-- The strike lands during the motion; recovery remains locked until the
	-- complete authored animation finishes, regardless of repeated inputs.
	task.delay(0.15, function()
		if active() and track.IsPlaying then self:Request("UtilityAction", "Melee", self:Direction()) end
	end)
	task.spawn(function()
		while active() and track.IsPlaying do task.wait() end
		if self._masterGeneration ~= generation then return end
		self.Meleeing = false
		self._masterAction = false
		if self.Equipped then self:_restoreBaseDeferred() end
	end)
end

function Knife:melee() self:activate() end

local onUnequip = Knife._on_unequip
function Knife:_on_unequip()
	self.Meleeing = false
	onUnequip(self)
end

return Knife
