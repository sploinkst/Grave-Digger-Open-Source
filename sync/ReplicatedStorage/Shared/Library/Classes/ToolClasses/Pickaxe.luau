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
local IMPACT_FALLBACK_TIME = 0.3

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

	_activationConnection: RBXScriptConnection?
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
	self.ANIM_LAYERS = {Hold = 0, Draw = 2, Unequip = 2, Mine = 2, Melee1 = 2, Melee2 = 2}
	self.Mining = false
	self._activationConnection = nil
	self.CompassDisabled = false

	return self
end

-- Use the shared equip lifecycle: draw finishes before held starts, and
-- tracks are registered once with their correct priorities and loop settings.
function Pickaxe:_on_unequip()
	self._miningSwing = (self._miningSwing or 0) + 1
	self.Mining = false
end

function Pickaxe:activate()
	if not self.Equipped or self.Equipping or self:_isBusy() then return end
	local animations = self.RegisteredAnimations
	local track = animations and animations.Mine
	if not track then return end
	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	self.Mining = true
	self._miningSwing = (self._miningSwing or 0) + 1
	local swing = self._miningSwing
	local impacted = false
	local connections = {}
	local function hitRock()
		if impacted or swing ~= self._miningSwing or not self.Mining then return end
		impacted = true
		if not self.Equipped or not self.tool or self.tool.Parent ~= character or humanoid.Health <= 0 then return end
		local camera = workspace.CurrentCamera
		local head = character:FindFirstChild("Head")
		if not camera or not head then return end
		-- The server raycasts this direction and owns carving, particles and audio.
		delete_terrain:FireServer(camera.CFrame.LookVector * MINING_REACH)
	end
	local function finishSwing()
		for _, connection in connections do connection:Disconnect() end
		if swing ~= self._miningSwing then return end
		self.Mining = false
		self:_restoreBase()
	end
	for _, marker in {"Hit", "Mine", "Impact", "hit", "mine", "impact"} do
		table.insert(connections, track:GetMarkerReachedSignal(marker):Connect(hitRock))
	end
	table.insert(connections, track.KeyframeReached:Connect(function(name)
		if name:lower() == "hit" or name:lower() == "mine" or name:lower() == "impact" then hitRock() end
	end))
	table.insert(connections, track.Stopped:Once(finishSwing))
	self:_stopAllExcept(track)
	self:_playAnim("Mine")
	-- Legacy published clips may have no impact marker. Submit at mid-swing
	-- once; a marker and this fallback can never mine twice.
	task.delay(IMPACT_FALLBACK_TIME, hitRock)
end

return Pickaxe
