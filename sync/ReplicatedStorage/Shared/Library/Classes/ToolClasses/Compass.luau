--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseTool = require(script.Parent.Parent.BaseTool)
local CompassService = require(ReplicatedStorage.Shared.Modules["Client Modules"].CompassService)

local AnimFolder = ReplicatedStorage.Shared.Assets.Animations.Tools.Compass

local Compass = {}
Compass.__index = Compass
Compass.className = "Compass"
setmetatable(Compass, { __index = BaseTool })

export type Compass = BaseTool.BaseTool & {
	className: "Compass",
	name: string,
}

function Compass.new(info: { name: string }): Compass
	local self = BaseTool.new(info) :: any
	setmetatable(self, Compass)
	self.className = "Compass"
	self.name = info.name
	self.Designation = "Nil"
	self.animations = {
		Left = AnimFolder:FindFirstChild("CompassLeft"),
		Right = AnimFolder:FindFirstChild("CompassRight"),
	}
	return self
end

-- Input, model replication, UI, audio, and cleanup live in CompassService.
-- This class only supplies the item-specific animation controller.
function Compass:activate()
	CompassService.Register(self)
end

function Compass:_on_give(_tool: Tool, _holster: Model?, _model: Model?)
	CompassService.Register(self)
end

function Compass:_on_unequip()
	CompassService.Unregister(self)
end

return Compass
