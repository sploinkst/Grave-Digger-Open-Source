--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)

local Holster_Folder = ReplicatedStorage.Shared.Assets.Guns.Holsters
local Tool_Folder = ReplicatedStorage.Shared.Assets.Guns.ToolModels
local Animations_Folder = ReplicatedStorage.Shared.Assets.Animations

local utilities_module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local delete_terrain: RemoteEvent = ReplicatedStorage.Shared.Library.Events.DeleteTerrain

local LOCAL_PLAYER = Players.LocalPlayer

local MINING_REACH = 5
local IMPACT_TIME = 0.2

local Pickaxe = {}
Pickaxe.__index = Pickaxe
setmetatable(Pickaxe, { __index = BaseTool })

export type Pickaxe = typeof(setmetatable({} :: {
	className: "Pickaxe",
	name: string,
	item_image: string,
	Designation: string,
	holster_reference: Instance?,
	actual_holster: Model?,
	tool: Tool?,
	mining_power: number,
	model_reference: Model?,
	actual_model: Model?,
	motor_6d_data: {
		Parent: string,
		Part0: string,
		Part1: string,
		C0: CFrame
	},
	animations: {[string]: Animation},
	RegisteredAnimations: {[string]: AnimationTrack}?,

	_activationConnection: RBXScriptConnection?,
	_deactivationConnection: RBXScriptConnection?
}, {} :: typeof(Pickaxe)))

function Pickaxe.new(PickaxeCreateInfo: Types.BaseToolCreateInfo): Pickaxe
	local self = setmetatable(BaseTool.new(PickaxeCreateInfo), Pickaxe)

	self.className = "Pickaxe"
	self.item_image = "rbxassetid://17496049481"
	self.Designation = "Mining"

	self.holster_reference = Holster_Folder and Holster_Folder:FindFirstChild("PickaxeHolster")
	self.actual_holster = nil

	self.model_reference = Tool_Folder:FindFirstChild("Pickaxe")
	self.actual_model = nil

	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = self.model_reference.Pickaxe_Middle,
		C0 = CFrame.new(-0.184, -0.939, 0.183) * CFrame.Angles(0.005, math.rad(-90), math.rad(90))
	}

	self.animations = {
		Draw = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Draw,
		Hold = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Hold,
		Melee1 = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Melee1,
		Melee2 = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Melee2,
		Mine = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Mine,
		Unequip = Animations_Folder.Tools.Pickaxes.Regular.Pickaxe_Unequip
	}

	self.mining_power = 12
	self.mining_recovery = 0.55
	self.AnimationPriorities = {Hold = Enum.AnimationPriority.Core, Draw = Enum.AnimationPriority.Core}
	self.ANIM_LAYERS = {Hold = 0, Draw = 2, Unequip = 2, Mine = 2, Melee1 = 2, Melee2 = 2}
	self.Mining = false
	self._miningHeld = false
	self._miningLoopRunning = false
	self._nextMiningMelee = 1
	self._activationConnection = nil
	self._deactivationConnection = nil
	self.CompassDisabled = false

	return self
end

-- Use the shared equip lifecycle: draw finishes before held starts, and
-- tracks are registered once with their correct priorities and loop settings.
function Pickaxe:_restoreBase()
	BaseTool._restoreBase(self)
	local character = LOCAL_PLAYER.Character
	local sprinting = not self.Aiming and character and character:GetAttribute("Sprinting") == true
	local draw = self.RegisteredAnimations and self.RegisteredAnimations.Draw
	if draw and draw.IsPlaying then draw:AdjustWeight(sprinting and 0 or 1, 0.1) end
	if sprinting then
		local hold = self.RegisteredAnimations and self.RegisteredAnimations.Hold
		if hold and hold.IsPlaying then hold:Stop(0.1) end
	end
end

function Pickaxe:_playAnim(name, bypassEquipped, playbackOptions)
	local track = BaseTool._playAnim(self, name, bypassEquipped, playbackOptions)
	-- Drawing still completes, but its passive pose cannot blend into sprinting.
	local character = LOCAL_PLAYER.Character
	if name == "Draw" and track and character and character:GetAttribute("Sprinting") == true then
		track:AdjustWeight(0, 0)
	end
	return track
end

function Pickaxe:_on_unequip()
	self._miningSwing = (self._miningSwing or 0) + 1
	self.Mining = false
	self._miningHeld = false
end

function Pickaxe:_playMiningSound(name: string, pitchVariation: number?)
	local character = LOCAL_PLAYER.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local meleeSounds = ReplicatedStorage.Shared.Assets.Sounds:FindFirstChild("meleesounds")
	local folder = meleeSounds and meleeSounds:FindFirstChild("pickaxe")
	local sound = folder and folder:FindFirstChild(name)
	if not root or not sound or not sound:IsA("Sound") then return end
	local tunnelRat = character:GetAttribute("TunnelRat")
	self:_play_sfx(sound, root, nil, math.max(sound.Volume - (tunnelRat and 0.5 or 0), 0),
		nil, pitchVariation or 0, tunnelRat and 10 or nil)
end

function Pickaxe:_on_give(tool: Tool)
	if self._deactivationConnection then self._deactivationConnection:Disconnect() end
	if self._miningImpactConnection then self._miningImpactConnection:Disconnect() end
	self._deactivationConnection = tool.Deactivated:Connect(function()
		self._miningHeld = false
	end)
	self._miningImpactConnection = delete_terrain.OnClientEvent:Connect(function()
		local character = LOCAL_PLAYER.Character
		local animations = self.RegisteredAnimations
		local mine = animations and animations.Mine
		if self.Equipped and self.Mining and tool.Parent == character then
			self:_playMiningSound("strike" .. math.random(1, 3), 0.1)
			-- The master starts the contact/recoil clip only after hitting rock.
			if mine then mine:Play(0.2, 1, 1) end
		end
	end)
end

function Pickaxe:_mineSwing(): boolean
	if not self.Equipped or self.Equipping then return false end
	local animations = self.RegisteredAnimations
	local animationName = self._nextMiningMelee == 1 and "Melee1" or "Melee2"
	self._nextMiningMelee = self._nextMiningMelee == 1 and 2 or 1
	local track = animations and animations[animationName]
	if not track then return false end
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end

	self.Mining = true
	self._miningSwing = (self._miningSwing or 0) + 1
	local swing = self._miningSwing
	local function active()
		return swing == self._miningSwing and self.Equipped and self.tool
			and self.tool.Parent == character and humanoid.Health > 0
	end
	-- Match the master: authored speed 1, 0.1 blend, impact at 0.2s,
	-- followed by the weapon's recovery. Clip length does not gate repeat mining.
	self:_stopAllExcept(track)
	track:Play(0.1, 1, 1)
	self:_playMiningSound("ready")
	task.wait(IMPACT_TIME)
	if not active() then return false end
	self:_playMiningSound("swing" .. math.random(1, 2), 0.1)
	local camera = workspace.CurrentCamera
	if camera then delete_terrain:FireServer(camera.CFrame.LookVector * MINING_REACH) end

	local recovery = self.mining_recovery
	if character:GetAttribute("TunnelRat") then recovery *= 0.75 end
	recovery /= math.max(character:GetAttribute("ChemicalSwingMultiplier") or 1, 0.05)
	local readyAt = os.clock() + recovery
	repeat
		task.wait()
		if not active() then return false end
	until os.clock() >= readyAt
	return true
end

function Pickaxe:activate()
	if not self.Equipped or self.Equipping then return end
	self._miningHeld = true
	if self._miningLoopRunning then return end

	self._miningLoopRunning = true
	task.spawn(function()
		while self._miningHeld and self.Equipped do
			self.Mining = true
			if not self:_mineSwing() then break end
		end
		self.Mining = false
		self._miningLoopRunning = false
		if self.Equipped then self:_restoreBase() end
	end)
end

return Pickaxe
