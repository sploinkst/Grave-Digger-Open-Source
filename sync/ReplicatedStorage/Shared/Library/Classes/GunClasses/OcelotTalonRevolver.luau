-- Ocelot/Talon-only controller. It intentionally reuses the Talon assets and
-- behavior while existing as a separate tool so it can stay out of loadout menus.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TalonRevolver = require(script.Parent.TalonRevolver)

local TalonAnimations = ReplicatedStorage.Shared.Assets.Animations.Tools.Guns:WaitForChild("TalonRevolver")
local OCELOT_FIRE_INTERVAL = 60 / 800

local OcelotTalonRevolver = {}
OcelotTalonRevolver.__index = OcelotTalonRevolver
setmetatable(OcelotTalonRevolver, { __index = TalonRevolver })

function OcelotTalonRevolver.new(info)
	local self = TalonRevolver.new(info)
	setmetatable(self, OcelotTalonRevolver)

	self.className = "OcelotTalonRevolver"
	self.name = "OcelotTalonRevolver"
	self.Display_Name = "Ocelot Talon Revolver"
	self.IsOcelotTrooper = true
	if self.animations then
		-- Ocelot always spins the revolver on draw and uses the actual
		-- `hipfire` asset for unaimed shots.
		self.animations.Draw = TalonAnimations:WaitForChild("ocelot_draw_spin")
		self.animations.hipfire = TalonAnimations:WaitForChild("hipfire")
		self.animations.Hold = self.animations.Quickdraw or self.animations.Hold
	end
	self.animation_speeds.Draw = 1 / self.draw_speed
	self.animation_speeds.hipfire = 1 / OCELOT_FIRE_INTERVAL
	self.FireInterval = OCELOT_FIRE_INTERVAL
	self.fire_rate = self.FireInterval
	self.fan_fire_rate = self.FireInterval
	self.Accuracy = 0
	self.Moving_Accuracy = 25
	self.OcelotHipSpread = 25
	self.Starting_Reserve_Ammo = 20000
	self.Max_Reserve_Ammo = 20000

	return self
end

OcelotTalonRevolver.Display_Name = "Ocelot Talon Revolver"
OcelotTalonRevolver.HiddenFromLoadout = true

return OcelotTalonRevolver
