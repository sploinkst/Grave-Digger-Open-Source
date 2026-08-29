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
local Effects_Folder = ReplicatedStorage.Shared.Assets.Guns.Effects
local small_rocks = Effects_Folder.smallrock

local utilities_module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local delete_terrain: RemoteEvent = ReplicatedStorage.Shared.Library.Events.DeleteTerrain

local LOCAL_PLAYER = Players.LocalPlayer

local TUNNEL_SIZE = Vector3.new(16, 14, 14)
local TUNNEL_SURFACE_OVERLAP = 2

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
	self.Mining = false
	self._activationConnection = nil
	self.CompassDisabled = false

	return self
end

function Pickaxe:on_give(tool: Tool, holster: Model?, model: Model?)
	BaseTool.on_give(self, tool, holster)

	self.tool = tool

	self.RegisteredAnimations = utilities_module.register_animations(LOCAL_PLAYER, self.animations)
	if not self.RegisteredAnimations then
		warn("[Pickaxe] Failed to register animations")
	end

	if holster then
		self.actual_holster = holster
	elseif self.holster_reference then
		self.actual_holster = utilities_module.reverse_search_holster(
			LOCAL_PLAYER,
			self.holster_reference.Name
		)
	else
		warn("[Pickaxe] Missing holster_reference")
	end

	if self._activationConnection then
		self._activationConnection:Disconnect()
	end

	self._activationConnection = tool.Activated:Connect(function()
		self:activate()
	end)
end

function Pickaxe:equip()
	if not self.tool then return end

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:EquipTool(self.tool)

	if self.RegisteredAnimations then
		local draw = self.RegisteredAnimations.Draw
		local hold = self.RegisteredAnimations.Hold

		if draw then
			draw:Play()
		end

		if hold then
			hold:Play()
		end

		for _, animation in pairs(self.RegisteredAnimations) do
			if typeof(animation) == "Instance" and animation:IsA("AnimationTrack") then
				animation:AdjustWeight(5, 0)
				animation.Priority = Enum.AnimationPriority.Action4
			end
		end
	end

	if self.actual_holster then
		utilities_module.hide_holster(LOCAL_PLAYER, self.actual_holster)
	end
	
	LOCAL_PLAYER.Character:SetAttribute("CompassDenied", true)	
end

function Pickaxe:unequip()
	if not self.tool then return end

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	self.RegisteredAnimations.Unequip:Play()

	humanoid:UnequipTools()

	self.RegisteredAnimations.Unequip.Stopped:Wait()
	for _, animation in pairs(self.RegisteredAnimations) do
		animation:Stop()
	end
	
	LOCAL_PLAYER.Character:SetAttribute("CompassDenied", nil)	
end

function Pickaxe:activate()
	if self.Mining then return end
	local character = LOCAL_PLAYER.Character
	if not character then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	local origin = character:FindFirstChild("Head").Position
	local direction = camera.CFrame.LookVector * 5

	local raycast = utilities_module.send_raycast(
		origin,
		direction,
		nil,
		{ workspace.Terrain }
	)


	if self.RegisteredAnimations then
		local index = math.random(1, 2)
		local anim = self.RegisteredAnimations["Melee" .. index]
		if anim then
			self.Mining = true
			anim:Play()
			task.delay(0.5, function()
				self.Mining = false
			end)
		end
	end

	if not raycast then print("Return raycast") return end

	if raycast.Instance == workspace.Terrain and raycast.Material == Enum.Material.Rock then
		print("Hit rock")

		local tunnelDirection = direction.Unit
		local tunnelCenter = raycast.Position
			+ tunnelDirection * ((TUNNEL_SIZE.Z / 2) - TUNNEL_SURFACE_OVERLAP)
		local tunnelCFrame = CFrame.lookAt(tunnelCenter, tunnelCenter + tunnelDirection)
		delete_terrain:FireServer(tunnelCFrame, TUNNEL_SIZE)

		local small_rocks_clone = small_rocks:Clone()
		small_rocks_clone.Position = raycast.Position
		small_rocks_clone.Parent = workspace

		utilities_module.emit_part(small_rocks_clone)
		small_rocks_clone:Destroy()

		print("sent rock")
	end
end

return Pickaxe
