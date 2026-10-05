-- Shared authored model/animation setup and cancellation for utility tools.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Assets = require(script.Parent.Parent.AuthoredAssets)
local BaseTool = require(script.Parent.BaseTool)
local Tool = {}; Tool.__index = Tool; setmetatable(Tool, {__index = BaseTool})
local bindings = {Draw = "draw", Hold = "held", Aim = "aim", Sprint = "sprint", Unequip = "unequip",
	Melee1 = "melee1", Melee2 = "melee2", Repair = "repair", Use = "use", Throw = "throw",
	Prime = "prime", ThrowUnder = "throw_under", ThrowOver = "throw_over", Check = "check", Flag = "flag",
	Drink = "drink", DrinkMotion = "drink_motion", DrinkDone = "drink_done", Clean = "clean", Clean2 = "clean2", Point = "point",
	Flare = "flaregun", Flare_Right = "flaregun_right", Telescope = "telescope", ShieldPlace = "shieldplace",
	ShieldPlant = "shield_plant", Choosing = "choosing", RaiseFlag = "raise_flag"}
function Tool.new(info, name, assetName)
	local self = setmetatable(BaseTool.new(info), Tool)
	self.className = name; self.name = name; self.Designation = "Equipment"; self.Can_Drop = false
	self.AnimationGunType = assetName; self.UseAuthoredGrip = true
	self.MasterAssetName = assetName
	local equipment = RS.Shared.Assets:FindFirstChild("Equipment")
	local guns = RS.Shared.Assets:FindFirstChild("Guns")
	local models = guns and guns:FindFirstChild("ToolModels")
	self.model_reference = models and models:FindFirstChild(assetName) or equipment and equipment:FindFirstChild(assetName)
	local data = require(script.Parent.Parent.MasterToolDefinitions)[assetName]
	if data then
		self.item_image = data.icon and "rbxassetid://" .. tostring(data.icon) or ""
		self.Melee_Damage = data.melee_damage; self.MeleeRange = data.melee_range
		self.ActionDelay = data.draw_speed
		self.PrimeTime = data.fire_rate
		self.draw_speed = data.draw_speed; self.aim_speed = data.aim_speed
		self.melee_swing_speed = data.melee_swing_speed
	end
	local grip = self.model_reference and (self.model_reference:FindFirstChild("hitbox", true)
		or self.model_reference:FindFirstChildWhichIsA("BasePart", true))
	self.motor_6d_data = {Parent = "Right Arm", Part0 = "Right Arm", Part1 = grip, C0 = CFrame.identity, C1 = CFrame.identity}
	return self
end
function Tool:_prepareAnimations()
	local folder = RS:FindFirstChild("ToolAnimations")
	folder = folder and folder:FindFirstChild(self.AnimationGunType)
	self.animations = {}
	for binding, name in pairs(bindings) do
		local clip = folder and folder:FindFirstChild(name, true)
		if clip then self.animations[binding] = clip end
	end
end
function Tool:Ready()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return self.Equipped and not self.Equipping and self.tool and self.tool.Parent == character
		and humanoid and humanoid.Health > 0 and not Players.LocalPlayer:GetAttribute("MenuOpen")
		and not character:GetAttribute("ActionBlocked") and not character:GetAttribute("Surrendered")
		and not self._masterAction and not self:_isBusy()
end
function Tool:Direction()
	local camera = workspace.CurrentCamera
	return camera and camera.CFrame.LookVector
end
function Tool:Target(range)
	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Players.LocalPlayer.Character, camera}
	return workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * range, params)
end
function Tool:Request(remote, action, argument)
	local event = RS.Shared.Library.Events:FindFirstChild(remote)
	if event then event:FireServer(self.tool, action, argument) end
end
function Tool:Action(animation, seconds, callback, recoverySeconds)
	if not self:Ready() then return false end
	self._masterAction = true
	self._masterGeneration = (self._masterGeneration or 0) + 1
	local generation = self._masterGeneration
	self:_playAnim(animation)
	task.delay(seconds, function()
		if self._masterGeneration ~= generation then return end
		if self.Equipped and self.tool and self.tool.Parent == Players.LocalPlayer.Character then callback() end
		local function finish()
			if self._masterGeneration ~= generation then return end
			self._masterAction = false; self:_restoreBaseDeferred()
		end
		if recoverySeconds and recoverySeconds > 0 then task.delay(recoverySeconds, finish) else finish() end
	end)
	return true
end
function Tool:CancelAction()
	self._masterGeneration = (self._masterGeneration or 0) + 1; self._masterAction = false
end
function Tool:_on_equip() self:_connectInput() end
function Tool:_on_unequip()
	self:CancelAction(); self:_disconnectInput()
	if self.View then self.View:Close() end
end
function Tool:destroy()
	self:CancelAction()
	if self.View then self.View:Destroy() end
	BaseTool.destroy(self)
end
return Tool
