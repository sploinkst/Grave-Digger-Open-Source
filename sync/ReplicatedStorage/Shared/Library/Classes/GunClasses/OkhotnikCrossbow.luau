local OkhotnikCrossbow = require(script.Parent.LegacyGunFactory).create({
	className = "OkhotnikCrossbow",
	AuthoredWelds = {
		equipc0 = CFrame.new(0.308517456, -0.725009203, -0.434566498, 2.32707805e-7, 3.87429793e-7, -1, 0.99999994, -3.5017797e-7, 2.32707649e-7, -3.50177913e-7, -1, -3.87427576e-7),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = true,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-0.763778687, -0.128093004, 0.546070099, 8.74221513e-8, 2.30215846e-12, -1, -0.999999762, -8.41540921e-14, -8.74220518e-8, 8.96023165e-14, 1, -2.30215846e-12),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(-0.447631836, -0.487032413, 0.708259583, 8.60940688e-8, 0.173648119, -0.984807611, -0.999999523, -1.74320248e-13, -8.7421995e-8, -1.51805271e-8, 0.984807611, 0.173648119),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "crossbow",
	AnimationGunType = "OkhotnikCrossbow",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Locked = "locked", Aim = "aim", Aim_Left = "aim_left", Draw = "draw",
		Fire = "fire", Fire_Left = "fire_left", Check = "check", Reload_Start = "reload_start",
		Melee1 = "melee1", Melee2 = "melee2", Alt_Melee1 = "altmelee1", Alt_Melee2 = "altmelee2",
		Short = "short", Speen = "speen", Sprint = "sprint",
	},
	WeaponCategory = "Rifle",
	Designation = "Primary",
	Weight = 2,
	ammo_check_duration = 1,
	AnimationPlayback = {
		Fire = { fade = 0.01, speed = 3 },
		Fire_Left = { fade = 0.01, speed = 3 },
		Speen = { fade = 0.1, speed = 1 },
	},
	LegacyStats = {
		name = "'Okhotnik' Hunting Crossbow",
		icon = "85866554467590",
		ammo_give = "Bodkin Bolt",
		-- The legacy controller sent crossbow hits through a dedicated server
		-- handler, so its module-level damage was only a sentinel. The migrated
		-- firearm uses the shared hit pipeline and needs its real damage here.
		damage = 150,
		range = 60,
		range_damage = 125,
		far = 100,
		far_damage = 100,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 3,
		wallpen_distance = 1,
		wallpen_studs = 1,
		accuracy = 1,
		moving_accuracy = 1,
		fire_rate = 0.25,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.55,
		aim_speed = 0.125,
		recoil = 1,
		recoil_count = 1,
		movement = 1,
		firing_movement = 1,
		firing_movement_last = 0.5,
		ammo_reserves = 8,
		ammo_reserves_max = 14,
		capacity = 1,
		chamber = false,
		reload_start = 2.5,
		size = 2,
		wound = 1,
		length = 4,
		reload_empty = 0,
		reload_loop = 0,
		reload_end = 0,
		reload_alt = 0,
	},
	bulletSpeed = 650,
})

function OkhotnikCrossbow:reload()
	local reloaded = self:_reloadMagazine()
	if reloaded then self.CrossbowCocked = true end
	return reloaded
end

function OkhotnikCrossbow:fire()
	if self.Capacity <= 0 or self.CrossbowCocked == false then return false end
	self:_playAnim("Speen")
	local fired = self:_fireConfiguredShot(self.FireInterval)
	if fired then self.CrossbowCocked = false end
	return fired
end

function OkhotnikCrossbow:_getMeleeAnimationName(index: number): string
	return (self.Capacity > 0 and "Alt_Melee" or "Melee") .. index
end

function OkhotnikCrossbow:_updateQuiver()
 local character=game:GetService("Players").LocalPlayer.Character
 local reserve=self:_getReserveAmmo()
 if not character or not reserve then return end
 local quiver=character:FindFirstChild("quiver",true)
 if not quiver then return end
 for index=1,6 do
  local bolt=quiver:FindFirstChild("bolt"..index)
  if bolt and bolt:IsA("BasePart") then bolt.Transparency=reserve.Value>=index and 0 or 1 end
 end
end
function OkhotnikCrossbow:_on_give()
 local reserve=self:_getReserveAmmo()
 if reserve then self.QuiverConnection=reserve.Changed:Connect(function() self:_updateQuiver() end) end
 self:_updateQuiver()
end
function OkhotnikCrossbow:destroy()
 if self.QuiverConnection then self.QuiverConnection:Disconnect() end
 getmetatable(OkhotnikCrossbow).__index.destroy(self)
end
return OkhotnikCrossbow
