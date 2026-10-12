local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local PickaxeBase = require(script.Parent.Pickaxe)
local Holster_Folder = ReplicatedStorage.Shared.Assets.Guns.Holsters:FindFirstChild("Tool Holsters")
local Tool_Folder = ReplicatedStorage.Shared.Assets.Guns.ToolModels
local Animations_Folder = ReplicatedStorage.Shared.Assets.Animations
local Players = game:GetService("Players")
local Rules = require(ReplicatedStorage.Shared.Library.PickaxeRules)

local HeavyPickaxe = {}
HeavyPickaxe.__index = HeavyPickaxe
setmetatable(HeavyPickaxe, { __index = PickaxeBase })

export type HeavyPickaxe = typeof(setmetatable({} :: {
	className: "HeavyPickaxe",
	name: string,
	item_image: string,
	holster_reference: Instance?,
	actual_holster: Model?,
	tool: Tool?,
	mining_power: number
}, {} :: typeof(HeavyPickaxe)))

function HeavyPickaxe.new(PickaxeCreateInfo: Types.BaseToolCreateInfo): HeavyPickaxe
	local self = setmetatable(PickaxeBase.new(PickaxeCreateInfo), HeavyPickaxe)
	self.className = "HeavyPickaxe"
	self.AuthoredWelds = require(script.Parent.Parent.Parent.WeaponPreviewMounts).pickaxe
	self.EquipWelds = self.AuthoredWelds
	self.UseNativeEquipMount = true
	self.item_image = "rbxassetid://17496049481" 
	self.Designation = "Mining"

	self.holster_reference = nil -- Render the tool model using weapon-module holster offsets.
	self.actual_holster = nil

	self.model_reference = Tool_Folder:FindFirstChild("HeavyPickaxe")
	self.actual_model = nil

	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference.HeavyPickaxe_Middle,
		C0 = CFrame.new(-0.328, -0.86, 0.279) * CFrame.Angles(0.005, math.rad(-90), math.rad(90))
	}

	self.animations = {
		Draw = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Draw,
		Hold = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Hold,
		Melee1 = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Melee,
		Melee2 = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Melee2,
		Mine = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Mine1,
		Unequip = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Unequip1,
		Sharpen = Animations_Folder.Tools.Pickaxes.Heavy.HeavyPickaxe_Sharpen,
	}

	self.mining_power = 13
	self.mining_recovery = 0.5
	self.ANIM_LAYERS.Sharpen = 2
	self._activationConnection = nil

	return self
end

function HeavyPickaxe:_finishSharpen()
	self._sharpenRequest = false
	self._sharpenActive = false
	self.Reloading = false
	self:_cutAnim("Sharpen", 0.1)
	if self.Equipped then self:_restoreBase() end
end

function HeavyPickaxe:_on_give(tool)
	PickaxeBase._on_give(self, tool)
	if self._pickActionConnection then self._pickActionConnection:Disconnect() end
	if self._sharpnessConnection then self._sharpnessConnection:Disconnect() end
	self._pickRemote = ReplicatedStorage.Shared.Library.Events:WaitForChild("PickaxeAction")
	self._pickActionConnection = self._pickRemote.OnClientEvent:Connect(function(target, action, reason)
		if target ~= tool then return end
		if action == "Message" then
			if self._sharpenRequest and (reason == "NoStones" or reason == "AlreadySharp") then self:_finishSharpen() end
			if self.Equipped and Rules.Messages[reason] then self:notify(Rules.Messages[reason]) end
		elseif action == "Started" then
			if not self.Equipped or tool.Parent ~= Players.LocalPlayer.Character then return end
			self._sharpenRequest = false
			self._sharpenActive = true
			self.Reloading = true
			self:_stopAllExcept()
			self:_playAnim("Sharpen", false, {fade = 0.1, speed = Rules.SharpenSpeed})
		elseif action == "Finished" or action == "Cancelled" then
			self:_finishSharpen()
		end
	end)
	self._sharpnessConnection = tool:GetAttributeChangedSignal("PickDurability"):Connect(function()
		if self.Checking then self:_showSharpness() end
	end)
	tool.Destroying:Connect(function()
		if self._pickActionConnection then self._pickActionConnection:Disconnect() end
		if self._sharpnessConnection then self._sharpnessConnection:Disconnect() end
		if self._miningImpactConnection then self._miningImpactConnection:Disconnect() end
		if self._deactivationConnection then self._deactivationConnection:Disconnect() end
		if self._sharpnessDisplay then self._sharpnessDisplay:Destroy(); self._sharpnessDisplay = nil end
	end)
end

function HeavyPickaxe:_on_unequip()
	PickaxeBase._on_unequip(self)
	self:_finishSharpen()
	self:end_ammo_check()
end

function HeavyPickaxe:setAltMode()
	if not self.Equipped or self:_isBusy() or not self._pickRemote then return end
	self._pickRemote:FireServer(self.tool, "ToggleStrength")
end

function HeavyPickaxe:reload()
	if not self.Equipped or self:_isBusy() or not self.tool or not self._pickRemote then return end
	local reason = Rules.SharpenError(self.tool:GetAttribute("PickDurability") or Rules.MaxDurability,
		self.tool:GetAttribute("SharpeningStones") or 0)
	if reason then self:notify(Rules.Messages[reason]); return end
	if not self.RegisteredAnimations or not self.RegisteredAnimations.Sharpen then
		warn("[HeavyPickaxe] Missing Sharpen animation")
		return
	end
	self._miningHeld = false
	self.Reloading = true
	self._sharpenRequest = true
	self._pickRemote:FireServer(self.tool, "Sharpen")
	local generation = self._equipGeneration
	task.delay(5, function()
		if generation == self._equipGeneration and self._sharpenRequest then self:_finishSharpen() end
	end)
end

function HeavyPickaxe:_onAnimationKeyframe(_, keyframe)
	if keyframe == "gsfx_sharpen" and self._sharpenActive and self._pickRemote then
		self._pickRemote:FireServer(self.tool, "Spark")
	end
end

function HeavyPickaxe:_showSharpness()
	if not self.tool or not self._sharpnessUtils then return end
	local ratio = math.clamp((self.tool:GetAttribute("PickDurability") or 0) / Rules.MaxDurability, 0, 1)
	self._sharpnessUtils.utils(math.floor(ratio * 100) .. "%", ratio, false, ratio, "Sharpness")
end

function HeavyPickaxe:ammo_check()
	if not self.Equipped or self:_isBusy() or not self.actual_model then return end
	local part = self.actual_model:FindFirstChild("HeavyPickaxe_Middle", true)
		or self.actual_model:FindFirstChildWhichIsA("BasePart", true)
	local camera = workspace.CurrentCamera
	local template = ReplicatedStorage.Shared.Assets.Guns.Effects:FindFirstChild("Ammo_Check")
	if not part or not camera or not template then return end
	if not self._sharpnessDisplay or not self._sharpnessDisplay.Parent then
		self._sharpnessDisplay = template:Clone()
		self._sharpnessDisplay.Name = "PickSharpness"
		self._sharpnessDisplay.Parent = camera
		self._sharpnessUtils = require(self._sharpnessDisplay.Utils)
	end
	local display = self._sharpnessDisplay
	local weld = display:FindFirstChildOfClass("WeldConstraint")
	if weld then weld:Destroy() end
	display.CFrame = part.CFrame + part.CFrame.RightVector * -0.5 + part.CFrame.UpVector
	weld = Instance.new("WeldConstraint")
	weld.Part0 = display
	weld.Part1 = part
	weld.Parent = display
	self.Checking = true
	self:_showSharpness()
end

function HeavyPickaxe:end_ammo_check()
	self.Checking = false
	if self._sharpnessUtils then task.spawn(self._sharpnessUtils.hide) end
	if self.Equipped then self:_restoreBase() end
end

return HeavyPickaxe
