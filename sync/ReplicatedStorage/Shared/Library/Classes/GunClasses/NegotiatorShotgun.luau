local Class = require(script.Parent.LegacyGunFactory).create({
	className = "NegotiatorShotgun",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.32220459, -1.17378032, -0.400718689, 0, 0, -1, 0.999999821, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
		alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1) * CFrame.new(0.25, 0, 0),
	},
	assetName = "remington",
	AnimationGunType = "NegotiatorShotgun",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "locked", Aim = "alt_changeaim", Fire = "fire", Check = "check", Throw = "throw",
		Reload_Start = "reload_start", Reload_Start_Vet = "reload_start_vet",
		Akimbo_Fire = "akimbo_fire", Akimbo_Locked = "akimbo_locked", Alt_Changeaim = "alt_changeaim", Alt_Changefire = "alt_changefire",
		Long_Hold = "long_held", Long_Draw = "long_draw", Long_Aim = "long_aim", Long_Aim_Left = "long_aim_left",
		Long_Fire = "long_fire", Long_Fire_Left = "long_fire_left", Long_Check = "long_check", Long_Sprint = "long_sprint",
	},
	WeaponCategory = "Shotgun",
	Designation = "Secondary",
	Weight = 1,
	LegacyStats = {
		name = "'Negotiator' Pocket Shotgun",
		desc = "A concealable single-shot shotgun used as a brutal tool of negotiation by the Bandits of the Underground.",
		lore = "Named ironically for its use as a concealable tool of negotiation by the soulless Bandits of the Underground.",
		icon = "114846330601183",
		ammo_give = "00 Buckshot",
		damage = 25,
		range = 25,
		range_damage = 15,
		far = 30,
		far_damage = 15,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 1,
		wallpen_distance = 50,
		wallpen_studs = 3,
		accuracy = 55,
		moving_accuracy = 55,
		fire_rate = 0.4,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.35,
		aim_speed = 0.3,
		pellets = 9,
		recoil = 30,
		recoil_count = 9,
		movement = 1,
		firing_movement = 2,
		firing_movement_last = 0.75,
		ammo_reserves = 3,
		ammo_reserves_max = 4,
		capacity = 1,
		chamber = false,
		reload_start = 3.5,
		size = 1,
		wound = 1,
		length = 4,
		reload_empty = 0,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
		reload_full = 0,
	},
	bulletSpeed = 850,
})

local normalActivate=Class.activate
function Class:activate()
 if self.Aiming or self.Alt_Mode then return normalActivate(self) end
 if not self.Equipped or self:_isBusyForActivation() or not self:_canFireNow() then return end
 local camera=workspace.CurrentCamera
 if not camera then return end
 local generation=self._equipGeneration
 self.Firing=true
 self:_playAnim("Fire",false,{fade=0.1,speed=8})
 task.delay(0.125,function()
  if not self.Equipped or self._equipGeneration~=generation then return end
  self:_playAnim("Throw",false,{fade=0.1,speed=1})
  game:GetService("ReplicatedStorage").Shared.Library.Events:WaitForChild("OrdnanceAction"):FireServer(self.tool,"ThrownNegotiator",camera.CFrame.LookVector)
  self.Firing=false
 end)
end
return Class
