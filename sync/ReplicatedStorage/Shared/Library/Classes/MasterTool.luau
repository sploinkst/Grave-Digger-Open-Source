-- Shared authored model/animation setup and cancellation for utility tools.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Assets = require(script.Parent.Parent.AuthoredAssets)
local BaseTool = require(script.Parent.BaseTool)
local ToolDefinitions = require(script.Parent.Parent.MasterToolDefinitions)

local Tool = {}
Tool.__index = Tool
setmetatable(Tool, { __index = BaseTool })

-- Binding name -> animation instance name
local ANIMATION_NAMES = {
	Draw = "draw",
	Hold = "held",
	Aim = "aim",
	Sprint = "sprint",
	Unequip = "unequip",
	Melee1 = "melee1",
	Melee2 = "melee2",
	Repair = "repair",
	Use = "use",
	Throw = "throw",
	Prime = "prime",
	ThrowUnder = "throw_under",
	ThrowOver = "throw_over",
	Check = "check",
	Flag = "flag",
	Drink = "drink",
	DrinkMotion = "drink_motion",
	DrinkDone = "drink_done",
	Clean = "clean",
	Clean2 = "clean2",
	Point = "point",
	Flare = "flaregun",
	Flare_Right = "flaregun_right",
	Telescope = "telescope",
	ShieldPlace = "shieldplace",
	ShieldPlant = "shield_plant",
	Choosing = "choosing",
	RaiseFlag = "raise_flag",
}

--// Helpers

-- Looks in Guns/ToolModels first, then falls back to Equipment.
local function findToolModel(assetName)
	local assets = RS.Shared.Assets
	local guns = assets:FindFirstChild("Guns")
	local toolModels = guns and guns:FindFirstChild("ToolModels")
	local equipment = assets:FindFirstChild("Equipment")

	return (toolModels and toolModels:FindFirstChild(assetName)) or (equipment and equipment:FindFirstChild(assetName))
end

local function findGrip(model)
	if not model then
		return nil
	end
	return model:FindFirstChild("hitbox", true) or model:FindFirstChildWhichIsA("BasePart", true)
end

--// Construction

function Tool.new(info, name, assetName)
	local self = setmetatable(BaseTool.new(info), Tool)

	self.className = name
	self.name = name
	self.Designation = "Equipment"
	self.Can_Drop = false
	self.AnimationGunType = assetName
	self.UseAuthoredGrip = true
	self.MasterAssetName = assetName
	self.model_reference = findToolModel(assetName)

	local data = ToolDefinitions[assetName]
	if data then
		self.item_image = if data.icon then "rbxassetid://" .. tostring(data.icon) else ""
		self.Melee_Damage = data.melee_damage
		self.MeleeRange = data.melee_range
		self.ActionDelay = data.draw_speed
		self.PrimeTime = data.fire_rate
		self.draw_speed = data.draw_speed
		self.aim_speed = data.aim_speed
		self.melee_swing_speed = data.melee_swing_speed
	end

	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = findGrip(self.model_reference),
		C0 = CFrame.identity,
		C1 = CFrame.identity,
	}

	return self
end

--// Animations

function Tool:_prepareAnimations()
	local root = RS:FindFirstChild("ToolAnimations")
	local folder = root and root:FindFirstChild(self.AnimationGunType)

	self.animations = {}
	if not folder then
		return
	end

	for binding, animationName in ANIMATION_NAMES do
		local clip = folder:FindFirstChild(animationName, true)
		if clip then
			self.animations[binding] = clip
		end
	end
end

--// State

function Tool:Ready()
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	return self.Equipped
		and not self.Equipping
		and self.tool
		and self.tool.Parent == character
		and humanoid
		and humanoid.Health > 0
		and not player:GetAttribute("MenuOpen")
		and not character:GetAttribute("ActionBlocked")
		and not character:GetAttribute("Surrendered")
		and not self._masterAction
		and not self:_isBusy()
end

function Tool:_isHeldByLocalPlayer()
	return self.Equipped and self.tool and self.tool.Parent == Players.LocalPlayer.Character
end

--// Aiming

function Tool:Direction()
	local camera = workspace.CurrentCamera
	return camera and camera.CFrame.LookVector
end

function Tool:Target(range)
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { Players.LocalPlayer.Character, camera }

	return workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * range, params)
end

--// Networking

function Tool:Request(remote, action, argument)
	local event = RS.Shared.Library.Events:FindFirstChild(remote)
	if event then
		event:FireServer(self.tool, action, argument)
	end
end

--// Actions

-- Plays an animation, runs `callback` after `seconds`, then (optionally after
-- `recoverySeconds`) releases the action lock. Any CancelAction() call in the
-- meantime invalidates the pending callback.
function Tool:Action(animation, seconds, callback, recoverySeconds)
	if not self:Ready() then
		return false
	end

	self._masterAction = true
	self._masterGeneration = (self._masterGeneration or 0) + 1
	local generation = self._masterGeneration

	local function isCurrent()
		return self._masterGeneration == generation
	end

	local function finish()
		if not isCurrent() then
			return
		end
		self._masterAction = false
		self:_restoreBaseDeferred()
	end

	self:_playAnim(animation)

	task.delay(seconds, function()
		if not isCurrent() then
			return
		end

		if self:_isHeldByLocalPlayer() then
			callback()
		end

		if recoverySeconds and recoverySeconds > 0 then
			task.delay(recoverySeconds, finish)
		else
			finish()
		end
	end)

	return true
end

function Tool:CancelAction()
	self._masterGeneration = (self._masterGeneration or 0) + 1
	self._masterAction = false
end

--// Tool callbacks

function Tool:_on_equip()
	self:_connectInput()
end

function Tool:_on_unequip()
	self:CancelAction()
	self:_disconnectInput()

	if self.View then
		self.View:Close()
	end
end

function Tool:destroy()
	self:CancelAction()

	if self.View then
		self.View:Destroy()
	end

	BaseTool.destroy(self)
end

return Tool