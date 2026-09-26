local KingslayerRevolver = require(script.Parent.LegacyGunFactory).create({
	className = "KingslayerRevolver",
	assetName = "walker",
	AnimationGunType = "KingslayerRevolver",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Fire = "fire", Fire_Left = "fire_left", Fire_Empty = "fire_empty",
		Fire_Break = "fire_break", Fire_Weak = "fire_weak", Reload_Start = "reload_start", Reload_End = "reload_end",
		Reload_Add_Ball = "reload_add_ball", Reload_Cap_Add = "reload_cap_add", Reload_Cap_Remove = "reload_cap_remove",
		Reload_Cylinder = "reload_cylinder", Reload_Dump = "reload_dump", Reload_Idle = "reload_idle",
		Reload_Lever = "reload_lever", Reload_Powder = "reload_powder", Spin_Cylinder = "spin_cylinder",
		Spin_Start = "spin_start", Spin_Loop = "spin_loop", Spin_End = "spin_end", Spin_End_Flashy = "spin_end_flashy",
	},
	reloadStartIsFullReload = true,
	WeaponCategory = "Pistol",
	Designation = "Primary",
	Weight = 2,
	LegacyStats = {
		name = "'Kingslayer' Percussion Revolver",
		icon = "118851184935301",
		ammo_give = ".44 Lead Ball",
		damage = 180,
		range = 40,
		range_damage = 170,
		far = 90,
		far_damage = 99,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 4,
		wallpen_distance = 50,
		wallpen_studs = 3,
		accuracy = 16,
		moving_accuracy = 120,
		fire_rate = 1.4,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.5,
		aim_speed = 0.3,
		recoil = 25,
		recoil_count = 9,
		movement = 3,
		firing_movement = 2.5,
		firing_movement_last = 0.75,
		ammo_reserves = 1,
		ammo_reserves_max = 2,
		capacity = 6,
		chamber = false,
	},
	bulletSpeed = 800,
})

function KingslayerRevolver:reload()
	if not self.Equipped or self.Reloading or self.Capacity >= self.Max_Capacity then return false end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then return false end

	self.Reloading = true
	self._reloadCancelled = false
	game.Players.LocalPlayer:SetAttribute("CantUnequip", true)
	task.spawn(function()
		local startTrack = self:_playAnim("Reload_Start")
		if startTrack then startTrack.Stopped:Wait() end
		while self.Equipped and not self._reloadCancelled and self.Capacity < self.Max_Capacity and reserve.Value > 0 do
			for _, animationName in { "Reload_Powder", "Reload_Add_Ball", "Reload_Cap_Add", "Reload_Cylinder" } do
				local track = self:_playAnim(animationName, false, { restart = true, fade = 0.05, cutFade = 0 })
				if track then track.Stopped:Wait() end
				if self._reloadCancelled or not self.Equipped then break end
			end
			if self._reloadCancelled or not self.Equipped then break end
			self.Capacity += 1
			self:_fire_ammo(1)
		end
		if not self._reloadCancelled then
			local endTrack = self:_playAnim("Reload_End")
			if endTrack then endTrack.Stopped:Wait() end
		end
		self.Reloading = false
		self._reloadCancelled = false
		game.Players.LocalPlayer:SetAttribute("CantUnequip", nil)
		self:_restoreBaseDeferred()
	end)
	return true
end

function KingslayerRevolver:_onAltInput(pressed: boolean)
	if not pressed or not self.Equipped or self:_isBusyForActivation() then return end
	self.Alting = true
	task.spawn(function()
		local track = self:_playAnim("Spin_Cylinder")
		if track then track.Stopped:Wait() end
		self.Alting = false
		self:_restoreBaseDeferred()
	end)
end

return KingslayerRevolver
