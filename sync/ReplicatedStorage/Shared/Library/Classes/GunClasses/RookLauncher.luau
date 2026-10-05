local Class = require(script.Parent.LegacyGunFactory).create({
	className = "RookLauncher",
	AuthoredWelds = {
		equipc0 = CFrame.new(0.405620575, -0.918596983, -0.570411682, 0, 0, -1, 0.99999994, 0, 0, 0, -0.999998629, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = true,
		holster_point = "Torso",
		holsterc0 = CFrame.new(0.09724617, -0.126744747, 0.538330078, 0.342024028, 0.939687192, 0, 0.939691246, -0.342022538, 0, 0, 0, -0.999995708),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.09724617, -0.126744747, 0.538330078, 0.342024028, 0.939687192, 0, 0.939691246, -0.342022538, 0, 0, 0, -0.999995708),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "rooklauncher",
	AnimationGunType = "rooklauncher",
	WeaponCategory = "Rifle",
	Designation = "Primary",
	Weight = 3,
	LegacyStats = {
		name = "Mining Bomb Launcher",
		icon = "18655468297",
		ammo_give = "Mining Bomb",
		tooltype = "launcher",
		damage = 50,
		range = 80,
		range_damage = 0,
		far = 0,
		far_damage = 0,
		pen = 3,
		accuracy = 2,
		moving_accuracy = 2,
		fire_rate = 0.5,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 1,
		aim_speed = 0.4,
		recoil = 10,
		recoil_count = 6,
		ammo_reserves = 100,
		ammo_reserves_max = 100,
		capacity = 1,
		size = 2,
		melee_damage = 200,
		melee_swing_speed = 0.6,
		melee_range = 5,
		wound = 1,
		length = 2,
		movement = 2,
		firing_movement = 1,
		firing_movement_last = 0.5,
		chamber = false,
		reload_start = 2.5,
		reload_empty = 0,
		reload_loop = 0,
		reload_end = 0,
		reload_alt = 0,
		lefthand = true,
	},
	bulletSpeed = 450,
})

function Class:fire()
 if not self.Aiming or not self:_canFireNow() or self.Capacity<=0 then return false end
 local camera=workspace.CurrentCamera
 if not camera then return false end
 self.Capacity-=1
 self:_blockFireFor(self.FireInterval)
 self:_playAnim("Fire")
 game:GetService("ReplicatedStorage").Shared.Library.Events:WaitForChild("OrdnanceAction"):FireServer(self.tool,"RookLauncher",camera.CFrame.LookVector)
 return true
end
return Class
