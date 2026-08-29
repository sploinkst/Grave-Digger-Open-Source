local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local PickaxeBase = require(script.Parent.Pickaxe)
local Holster_Folder = ReplicatedStorage.Shared.Assets.Guns.Holsters:FindFirstChild("Tool Holsters")
local Tool_Folder = ReplicatedStorage.Shared.Assets.Guns.ToolModels
local Animations_Folder = ReplicatedStorage.Shared.Assets.Animations

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
	self.item_image = "rbxassetid://17496049481" 
	self.Designation = "Mining"

	self.holster_reference = Holster_Folder and Holster_Folder:FindFirstChild("HeavyPickaxeHolster")
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
	self._activationConnection = nil

	return self
end

return HeavyPickaxe