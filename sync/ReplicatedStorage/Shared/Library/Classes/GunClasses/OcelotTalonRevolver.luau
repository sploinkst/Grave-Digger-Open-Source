-- Ocelot/Talon-only controller. It intentionally reuses the Talon assets and
-- behavior while existing as a separate tool so it can stay out of loadout menus.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TalonRevolver = require(script.Parent.TalonRevolver)

local GunAnimations = ReplicatedStorage.Shared.Assets.Animations.Tools.Guns
local TalonAnimations = GunAnimations:FindFirstChild("TalonRevolver") or GunAnimations:WaitForChild("saa")
local OCELOT_FIRE_INTERVAL = 0.15

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
	self.StrictAnimations = true
	if self.animations then
		-- Ocelot always spins the revolver on draw and uses the actual
		-- `hipfire` asset for unaimed shots.
		self.animations.Draw = TalonAnimations:WaitForChild("ocelot_draw_spin")
		self.animations.hipfire = TalonAnimations:WaitForChild("hipfire")
	end
	self.animation_speeds.Draw = 1 / self.draw_speed
	self.animation_speeds.hipfire = 1 / OCELOT_FIRE_INTERVAL
	self.FireInterval = 0.45
	self.fire_rate = self.FireInterval
	self.fan_fire_rate = OCELOT_FIRE_INTERVAL
	self.Accuracy = 0
	self.Moving_Accuracy = 25
	self.OcelotHipSpread = 25
	self.Starting_Reserve_Ammo = 20000
	self.Max_Reserve_Ammo = 20000

	return self
end

OcelotTalonRevolver.Display_Name = "Ocelot Talon Revolver"
OcelotTalonRevolver.HiddenFromLoadout = true

-- Authored mount data from weapon_modules.saa (including inherited values).
OcelotTalonRevolver.AuthoredWelds = {
	equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	lefthand = false,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
	holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
	alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

return OcelotTalonRevolver
