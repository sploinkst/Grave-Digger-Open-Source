local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local Combat = ReplicatedStorage.Shared.Library.Events:WaitForChild("ClassCombat")

local WexFlamethrower = require(script.Parent.LegacyGunFactory).create({
	className = "WexFlamethrower",
	AuthoredWelds = {
		equipc0 = CFrame.new(0.294586182, -0.978889227, -1.03866196, 2.84217094e-14, 0, -1, 5.55623067e-16, 0.99999994, 0, 1, 5.5562312e-16, -2.84217094e-14),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = true,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.833877563, 0.738547564, 0.554540634, 1.70530257e-13, 5.68434053e-14, -1, -1, -2.22249248e-15, 1.70530257e-13, 2.22249206e-15, 0.999999762, -5.68434189e-14),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.833877563, 0.738547564, 0.554540634, 1.70530257e-13, 5.68434053e-14, -1, -1, -2.22249248e-15, 1.70530257e-13, 2.22249206e-15, 0.999999762, -5.68434189e-14),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "wex",
	AnimationGunType = "Flamethrower",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Aim = "aim", Aim_Left = "aim_left", Draw = "draw",
		Fire = "firing", Fire_Left = "firing_left",
	},
	WeaponCategory = "Flamer",
	Designation = "Primary",
	Weight = 3,
	requireAiming = true,
	fireEmissions = {},
	LegacyStats = {
		name = "'Lamentations'",
		icon = "128241979427297",
		ammo_give = "8mm Smokeless",
		tooltype = "flamer",
		damage = 150,
		range = 100,
		range_damage = 120,
		far = 150,
		far_damage = 105,
		pen = 3,
		accuracy = 6,
		moving_accuracy = 100,
		fire_rate = 0.3,
		cycle = 0.55,
		cycle_rest = 0.15,
		draw_speed = 1,
		aim_speed = 0.1,
		recoil = 10,
		recoil_count = 6,
		ammo_reserves = 1,
		ammo_reserves_max = 3,
		capacity = 7,
		chamber = true,
		auto = true,
		blacklist = true,
		size = 2,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 50,
		wallpen_studs = 3,
		wound = 1,
		length = 4,
		movement = 1,
		firing_movement = 3,
		firing_movement_last = 0.5,
		reload_start = 1.6,
		reload_empty = 1.45,
		reload_loop = 0.65,
		reload_end = 1.45,
		reload_alt = 1.4,
	},
	bulletSpeed = 350,
})

-- Flamer fuel is independent of the inherited cartridge data in the master.
-- The existing combat service owns consumption and overlapping burn targets.
function WexFlamethrower:fire()
	if not self.Equipped or self.Firing or self:_isBusyForActivation() or not self.Aiming then return false end
	if not self:_canFireNow() or self.ForceBlockFire or self:_if_sprinting() then return false end
	if (self.tool:GetAttribute("FlamerFuel") or 900) <= 0 then
		self:notify("The fuel tank is empty.")
		return false
	end
	local generation = self._equipGeneration
	self.Firing = true
	self:_stopAllExcept()
	local animation = self.current_shoulder == "Right" and "Fire" or "Fire_Left"
	local track = self:_playAnim(animation)
	if track then track.Looped = true end
	task.spawn(function()
		task.wait(0.3)
		if not self.Equipped or self._equipGeneration ~= generation then return end
		Combat:FireServer("StartFlame", workspace.CurrentCamera.CFrame.LookVector)
		local started = os.clock()
		repeat task.wait(0.05) until not self.Equipped or self._equipGeneration ~= generation
			or not self.Aiming or (self.tool:GetAttribute("FlamerFuel") or 900) <= 0
			or (not Input:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and os.clock() - started >= 0.5)
		if self._equipGeneration ~= generation then return end
		Combat:FireServer("StopFlame")
		if track then track:Stop(0.1) end
		self.Firing = false
		self:_restoreBaseDeferred()
	end)
	return true
end

function WexFlamethrower:activate()
	if self.Aiming then self:fire() elseif not self:_isBusyForActivation() then self:melee() end
end

function WexFlamethrower:reload() return false end

function WexFlamethrower:ammo_check()
	if not self.Equipped or self:_isBusyForActivation() then return end
	self:notify(tostring(math.floor((self.tool:GetAttribute("FlamerFuel") or 900) / 9)) .. "% fuel remaining.")
end

function WexFlamethrower:_on_unequip()
	Combat:FireServer("StopFlame")
	self.Firing = false
	self.Equipped = false
	if self._autoInputEndedConnection then
		self._autoInputEndedConnection:Disconnect()
		self._autoInputEndedConnection = nil
	end
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
end

return WexFlamethrower
