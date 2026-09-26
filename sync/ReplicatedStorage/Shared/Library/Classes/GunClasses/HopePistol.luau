local HopePistol = require(script.Parent.LegacyGunFactory).create({
	className = "HopePistol",
	assetName = "mpistol",
	AnimationGunType = "HopePistol",
	StrictAnimations = true,
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Hope' Automatic Pistol",
		icon = "87131177597373",
		ammo_give = ".45 Auto",
		damage = 90,
		range = 30,
		range_damage = 85,
		far = 80,
		far_damage = 80,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 1,
		wallpen_distance = 30,
		wallpen_studs = 2,
		accuracy = 6,
		moving_accuracy = 40,
		fire_rate = 0.35,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.275,
		aim_speed = 0.2,
		recoil = 12,
		recoil_count = 6,
		movement = 1,
		firing_movement = 1.5,
		firing_movement_last = 0.5,
		ammo_reserves = 1,
		ammo_reserves_max = 2,
		capacity = 7,
		reload_start = 2,
		reload_end = 1.15,
		chamber = true,
		require_full_load = true,
	},
	bulletSpeed = 850,
})

-- Alternate Action inspects the dog tag. The authored animation pauses at its
-- presentation frame while the input is held, matching the original weapon.
function HopePistol:_onAltInput(pressed: boolean)
	self._tagInspectHeld = pressed
	if not pressed or not self.Equipped or self:_isBusyForActivation() then return end

	local animations = self.RegisteredAnimations
	if not animations or not animations.Tag_Look then return end

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

return HopePistol
