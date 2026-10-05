local HopePistol = require(script.Parent.LegacyGunFactory).create({
	className = "HopePistol",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.32220459, -1.17378056, -0.236167908, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
		alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
	},
	assetName = "mpistol",
	AnimationGunType = "HopePistol",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Locked = "locked", Draw = "draw", Fire = "fire", Check = "check",
		Reload_Start = "reload_start", Reload_Start_Vet = "reload_start_vet", Reload_End = "reload_end",
		Reload_End_Locked = "reload_end_locked", Reload_End_Locked_Vet = "reload_end_locked_vet",
		Akimbo_Fire = "akimbo_fire", Akimbo_Locked = "akimbo_locked", Tag_Look = "tag_look",
	},
	WeaponCategory = "Pistol",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Hope' Automatic Pistol",
		desc = "A legendary handgun that needs no introduction.",
		lore = "Named by a Solace Coalition Priest, who adorned it with gold and engravings to bring it luck against the demons which lurk these halls.",
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
		size = 1,
		wound = 1,
		length = 4,
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
