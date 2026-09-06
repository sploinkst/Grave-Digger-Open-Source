local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local BaseEquipment = require(script.Parent.Parent.BaseEquipment)
local Combat = require(script.Parent.Parent.MeleeController)
local Settings = require(ReplicatedStorage.Shared.Modules["Client Modules"].SettingsManager)
local Axes = {}
Axes.__index = Axes
setmetatable(Axes, {__index = BaseEquipment})

function Axes.new()
	local self = BaseEquipment.new({name = "Throwing Axes"})
	setmetatable(self, Axes)
	self.className = "ThrowingAxes"
	self.MaxEquipment = 4
	self.tracks = {}
	self.connections = {}
	return self
end

function Axes:play(name, looped)
	for _, track in self.tracks do track:Stop(.08) end
	local track = self.tracks[name]
	if track then track.Looped = looped == true; track.Priority = Enum.AnimationPriority.Action3; track:Play(.08) end
	return track
end

function Axes:cancel()
	self.version = (self.version or 0) + 1
	self.prepared = false
	Combat.Remote():FireServer("CancelAxe")
	self:play("Unequip")
end

function Axes:Start(character)
	self.Character = character
	self.Stopped = false
	local function updateCount()
		local gui = self:_getEquipmentGui()
		local label = gui and gui:FindFirstChild("count")
		if gui then gui.Enabled = true end
		if label then label.Text = tostring(character:GetAttribute("ThrowingAxesCount") or 4) end
	end
	table.insert(self.connections, character:GetAttributeChangedSignal("ThrowingAxesCount"):Connect(updateCount))
	updateCount()
	local animationRoot = ReplicatedStorage:WaitForChild("ToolAnimations", 10)
	local folder = animationRoot and animationRoot:FindFirstChild("throwaxe")
	if folder then
		self.tracks = require(ReplicatedStorage.Shared.Library.Util).register_animations(Players.LocalPlayer, {
			Draw = folder:FindFirstChild("draw"), Prime = folder:FindFirstChild("prime"),
			Throw = folder:FindFirstChild("throw_over"), Unequip = folder:FindFirstChild("unequip"),
			Check = folder:FindFirstChild("checkaxes"),
		}, "throwaxe") or {}
	end
	if self.Stopped or Players.LocalPlayer.Character ~= character then return end
	self._inputHook = function(_, pressed)
		if self.Stopped or Players.LocalPlayer.Character ~= character
			or character:GetAttribute("Equipment") ~= "ThrowingAxes" then return end
		if pressed then
			if self.prepared or os.clock() < (self.readyAt or 0) or Players.LocalPlayer:GetAttribute("MenuOpen")
				or character:GetAttribute("charging") or character:GetAttribute("CombatStunned")
				or (character:GetAttribute("ThrowingAxesCount") or 4) <= 0 then return end
			require(ReplicatedStorage.Shared.Modules["Client Modules"].InventoryService).UnequipCurrent()
			self.prepared = true
			self.version = (self.version or 0) + 1
			local version = self.version
			local data = character:FindFirstChild("CharacterData")
			local perks = data and data:FindFirstChild("Perks")
			local marksman = perks and perks:FindFirstChild("Marksman")
			self.drawTime = marksman and (not marksman:IsA("BoolValue") or marksman.Value) and .1 or .25
			self.drawAt = os.clock()
			Combat.Remote():FireServer("PrepareAxe")
			local track = self:play("Draw")
			if track and track.Length > 0 then track:AdjustSpeed(track.Length / self.drawTime) end
			task.delay(self.drawTime, function()
				if self.prepared and self.version == version and not self.Stopped then self:play("Prime", true) end
			end)
		elseif self.prepared then
			local version = self.version
			task.delay(math.max(0, self.drawTime - (os.clock() - self.drawAt)), function()
				if self.Stopped or not self.prepared or version ~= self.version then return end
				self.prepared = false
				self.readyAt = os.clock() + .4
				self:play("Throw")
				Combat.Remote():FireServer("ThrowAxe", Combat.Direction())
			end)
		end
	end
	Settings.HookInput("Class Equipment", self._inputHook)
	table.insert(self.connections, Input.InputBegan:Connect(function(input, processed)
		if not processed and self.prepared and input.UserInputType == Enum.UserInputType.MouseButton1 then self:cancel() end
	end))
	table.insert(self.connections, character.ChildAdded:Connect(function(child)
		if self.prepared and child:IsA("Tool") then self:cancel() end
	end))
end

function Axes:Stop()
	self.Stopped = true
	self:cancel()
	if self._inputHook then Settings.UnhookInput("Class Equipment", self._inputHook) end
	for _, connection in self.connections do connection:Disconnect() end
	for _, track in self.tracks do track:Stop(); track:Destroy() end
	self.connections = {}; self.tracks = {}
end

return Axes