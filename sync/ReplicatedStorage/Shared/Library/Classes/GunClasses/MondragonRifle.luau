--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)

local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local HolsterFolder = GunAssets.Holsters
local AnimationFolder = Assets.Animations.Tools.Guns:FindFirstChild("mondragon")
local PrinceAnimations = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local SoundFolder = GunAssets.Sounds:FindFirstChild("mondragon") or GunAssets.Sounds:FindFirstChild("MondragonRifle")

local BULLET_SPEED = 950
local WEAPON_STATS = {
	name = "'Der Albtraum'",
	desc = "",
	lore = "",
	size = 2,
	icon = "112193472525301",
	animations = "mondragon",
	ammo_give = "7.25mm Round",
	melee_sound = "rifle",
	blacklist = true,
	alt_name = "'Der Verfolger'",
	assists = {},
	tooltype = "gun",
	damage = 140,
	range = 70,
	range_damage = 130,
	far = 120,
	far_damage = 99,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 3,
	wallpen_distance = 30,
	wallpen_studs = 2,
	accuracy = 4,
	moving_accuracy = 50,
	fire_rate = 0.45,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 0.65,
	aim_speed = 0.3,
	wound = 1,
	length = 5,
	recoil = 8,
	recoil_count = 6,
	movement = 1,
	firing_movement = 1,
	firing_movement_last = 0.5,
	ammo_reserves = 200,
	ammo_reserves_max = 200,
	capacity = 10,
	chamber = false,
	reload_start = 1.6,
	reload_empty = 2.8,
	reload_loop = 0.8,
	reload_end = 0.7,
	reload_full = 1.7,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-0.843444824, -0.160831451, 0.563819885, -0.0857552588, 0.996316195, -2.14072588e-6, -0.996316195, -0.0857552588, 6.89330363e-6, 6.68433131e-6, 2.72397665e-6, 1),
	holsterc1 = CFrame.identity,
	alt_holsterc0 = CFrame.new(-0.0671386719, 0.0569257736, 0.563720703, -0.085755609, -0.996316195, 1.70646985e-7, -0.996320546, 0.0857559666, 8.59710667e-7, -2.90349675e-7, -2.8889346e-7, -1),
	alt_holsterc1 = CFrame.identity,
	lefthand = true,
	equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9),
	equipc1 = CFrame.identity,
	special = {
		suppressed = true,
	},
}

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Fire_Last = 1,
	Fire_Last_Left = 1,
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_Empty = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Reload_Full = 2,
	Check = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
}

local function anim(names: { string }): Animation?
	if not AnimationFolder then return nil end
	for _, name in names do
		local found = AnimationFolder:FindFirstChild(name) or AnimationFolder:FindFirstChild(name, true)
		if found and found:IsA("Animation") then return found end
	end
	return nil
end

local MondragonRifle = {}
MondragonRifle.__index = MondragonRifle
setmetatable(MondragonRifle, { __index = BaseRifle })

export type MondragonRifle = typeof(setmetatable({} :: any, MondragonRifle))

function MondragonRifle.new(info: Types.BaseToolCreateInfo): MondragonRifle
	local self = setmetatable(BaseRifle.new(info), MondragonRifle)

	self.className = "MondragonRifle"
	self.name = "MondragonRifle"
	self.item_image = MondragonRifle.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.AnimationGunType = "mondragon"
	self.model_reference = ToolFolder:FindFirstChild("mondragon") or ToolFolder:FindFirstChild("MondragonRifle")
	self.holster_reference = HolsterFolder:FindFirstChild("mondragonHolster") or HolsterFolder:FindFirstChild("MondragonRifleHolster")
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = WEAPON_STATS.equipc0,
		C1 = WEAPON_STATS.equipc1,
	}

	self.animations = {
		Hold = anim({ "held", "Hold" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Held")),
		Draw = anim({ "draw", "Draw" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Draw")),
		Unequip = anim({ "unequip", "Unequip" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Unequip")),
		Aim = anim({ "aim", "Aim" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Aim")),
		Aim_Left = anim({ "aim_left", "Aim_Left" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Aim_Left")),
		Fire = anim({ "fire", "Fire" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Fire")),
		Fire_Left = anim({ "fire_left", "Fire_Left" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Fire_Left")),
		Fire_Last = anim({ "fire_last", "Fire_Last" }),
		Fire_Last_Left = anim({ "fire_last_left", "Fire_Last_Left" }),
		Reload_Start = anim({ "reload_start", "Reload_Start" }),
		Reload_Empty = anim({ "reload_empty", "Reload_Empty" }),
		Reload_Loop = anim({ "reload_loop", "Reload_Loop" }),
		Reload_End = anim({ "reload_end", "Reload_End" }),
		Reload_Full = anim({ "reload_full", "Reload_Full" }),
		Check = anim({ "check", "Check" }),
		Melee1 = anim({ "melee1", "Melee1" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Melee1")),
		Melee2 = anim({ "melee2", "Melee2" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Melee2")),
		Short = anim({ "short", "Short" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("PrinceRifle_Short")),
		Drop = Assets.Animations.Tools.Misc.Drop_Rifle,
	}

	self.animation_speeds = {
		Draw = 1 / WEAPON_STATS.draw_speed,
		Aim = 1 / WEAPON_STATS.aim_speed,
		Aim_Left = 1 / WEAPON_STATS.aim_speed,
		Reload_Start = 1 / WEAPON_STATS.reload_start,
		Reload_Empty = 1 / WEAPON_STATS.reload_empty,
		Reload_Loop = 1 / WEAPON_STATS.reload_loop,
		Reload_End = 1 / WEAPON_STATS.reload_end,
		Reload_Full = 1 / WEAPON_STATS.reload_full,
	}

	self.BulletSpeed = BULLET_SPEED
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.SoundFolder = SoundFolder
	self.FireSound = SoundFolder and SoundFolder:FindFirstChild("fire")
	self.Can_Drop = true
	self:applyFirearmConfig(WEAPON_STATS)
	self.FireSound = SoundFolder and SoundFolder:FindFirstChild("fire")
	self:_initShoulderTracking()
	return self
end

function MondragonRifle:reload(): boolean
	if not self.Equipped or self.Reloading or self.Equipping then return false end
	if self.Capacity >= self.Max_Capacity then return false end

	local reserveAmmo = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserveAmmo or not reserveAmmo:IsA("NumberValue") then
		warn(self.className .. ": Cannot reload because Reserve_Ammo is missing")
		return false
	end
	if reserveAmmo.Value <= 0 then
		self:notify("I don't have any more ammo...")
		self:_restoreBase()
		return false
	end

	local needed = self.Max_Capacity - self.Capacity
	local ammoToLoad = if self.Capacity <= 0 then math.min(self.Max_Capacity, reserveAmmo.Value)
		elseif self.Capacity + 5 <= self.Max_Capacity then math.min(5, needed, reserveAmmo.Value)
		else math.min(needed, reserveAmmo.Value)
	local animName = if self.Capacity <= 0 then "Reload_Empty"
		elseif self.Capacity + 5 <= self.Max_Capacity then "Reload_Loop"
		else "Reload_Full"
	local startName = if animName == "Reload_Loop" then "Reload_Start" else nil
	local endName = if animName == "Reload_Loop" then "Reload_End" else nil

	self:_stopAllExcept()
	self.Reloading = true
	self._reloadCancelled = false
	game.Players.LocalPlayer:SetAttribute("CantUnequip", true)

	if startName then
		local startTrack = self:_playAnim(startName)
		if startTrack then startTrack.Stopped:Wait() end
	end

	if self.Equipped and not self._reloadCancelled then
		local reloadTrack = self:_playAnim(animName)
		if reloadTrack then reloadTrack.Stopped:Wait() end
	end

	if self.Equipped and not self._reloadCancelled then
		self.Capacity += ammoToLoad
		self:_fire_ammo(ammoToLoad)
		if endName then
			local endTrack = self:_playAnim(endName)
			if endTrack then endTrack.Stopped:Wait() end
		end
	end

	self.Reloading = false
	self._reloadCancelled = false
	game.Players.LocalPlayer:SetAttribute("CantUnequip", nil)
	self:_restoreBaseDeferred()
	return true
end

function MondragonRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

MondragonRifle.Tool_Image = "rbxassetid://112193472525301"
MondragonRifle.Medal_Cost = 0
MondragonRifle.Weight = 3
MondragonRifle.Designation = "Primary"
MondragonRifle.Display_Name = WEAPON_STATS.name
MondragonRifle.desc = WEAPON_STATS.desc
MondragonRifle.lore = WEAPON_STATS.lore
MondragonRifle.assists = WEAPON_STATS.assists
MondragonRifle.icon = WEAPON_STATS.icon
MondragonRifle.alt_name = WEAPON_STATS.alt_name
MondragonRifle.blacklist = WEAPON_STATS.blacklist
MondragonRifle.damage = WEAPON_STATS.damage
MondragonRifle.range = WEAPON_STATS.range
MondragonRifle.range_damage = WEAPON_STATS.range_damage
MondragonRifle.far = WEAPON_STATS.far
MondragonRifle.far_damage = WEAPON_STATS.far_damage
MondragonRifle.accuracy = WEAPON_STATS.accuracy
MondragonRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
MondragonRifle.fire_rate = WEAPON_STATS.fire_rate
MondragonRifle.recoil = WEAPON_STATS.recoil
MondragonRifle.recoil_count = WEAPON_STATS.recoil_count
MondragonRifle.capacity = WEAPON_STATS.capacity
MondragonRifle.ammo_give = WEAPON_STATS.ammo_give
MondragonRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
MondragonRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
MondragonRifle.pen = WEAPON_STATS.pen

return MondragonRifle
