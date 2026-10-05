local Factory = require(script.Parent.LegacyGunFactory)

local MachinePistol = Factory.create({
	className = "MachinePistol",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.266601562, -1.29742551, -0.465759277, -5.68434189e-14, -2.95329523e-14, -1, 0.99999994, -5.55623014e-16, 5.68434155e-14, 5.5562312e-16, -0.999999881, -2.95329557e-14),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.428756714, -0.00153756142, 0.563869476, 0.487990797, -0.662724197, 0.568031669, 0.872847557, 0.370578408, -0.317500949, -0.0000846743642, 0.650742352, 0.759297907),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.428756714, -0.00153756142, 0.563869476, 0.487990797, -0.662724197, 0.568031669, 0.872847557, 0.370578408, -0.317500949, -0.0000846743642, 0.650742352, 0.759297907),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "mpgun",
	AnimationGunType = "mpgun",
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Breath of God'",
		icon = "79235124191407",
		ammo_give = "9mm Auto",
		damage = 85,
		range = 35,
		range_damage = 70,
		far = 55,
		far_damage = 60,
		pen = 1,
		accuracy = 8,
		moving_accuracy = 15,
		fire_rate = 0.12,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 1,
		aim_speed = 0.25,
		recoil = 2,
		recoil_count = 2,
		ammo_reserves = 200,
		ammo_reserves_max = 200,
		capacity = 32,
		auto = true,
		blacklist = true,
		size = 1,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		wallpen_distance = 30,
		wallpen_studs = 2,
		wound = 1,
		length = 4,
		movement = 1,
		firing_movement = 1,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 3,
		reload_empty = 0.75,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
	},
	bulletSpeed = 850,
})

-- Weapon master's tag inspection intentionally pauses on the authored 0.5s
-- frame while Alternate Action is held, with a minimum half-second display.
function MachinePistol:_onAltInput(pressed: boolean)
	self._tagInspectHeld = pressed
	if not pressed or not self.Equipped or self:_isBusyForActivation() then return end

	local animations = self.RegisteredAnimations
	if not animations or not animations.Tag_Look then
		self:setAltMode()
		return
	end

	self.Alting = true
	local generation = (self._tagInspectGeneration or 0) + 1
	self._tagInspectGeneration = generation

	task.spawn(function()
		local track = self:_playAnim("Tag_Look", false, {
			fade = 0.1,
			speed = 0.5,
			restart = true,
			cutFade = 0,
		})
		if not track then
			self.Alting = false
			return
		end

		task.wait(1)
		if generation ~= self._tagInspectGeneration or not self.Equipped then return end
		self:_setAnimationFrame("Tag_Look", 0.5, 0)

		local pausedAt = os.clock()
		repeat
			self:_setAnimationFrame("Tag_Look", 0.5, 0)
			task.wait()
		until generation ~= self._tagInspectGeneration
			or not self.Equipped
			or (not self._tagInspectHeld and os.clock() - pausedAt >= 0.5)

		if generation ~= self._tagInspectGeneration or not self.Equipped then return end
		self:_setAnimationFrame("Tag_Look", 0.5, 0.5)
		task.wait(1.2)
		if generation ~= self._tagInspectGeneration then return end
		self.Alting = false
		self:_restoreBaseDeferred()
	end)
end

return MachinePistol
