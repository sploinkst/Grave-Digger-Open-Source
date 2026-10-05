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
local directAssets = ReplicatedStorage:FindFirstChild("Assets")
local directGuns = directAssets and directAssets:FindFirstChild("Guns")
local directSoundRoot = directAssets and directAssets:FindFirstChild("Sounds")
local directSounds = directSoundRoot and directSoundRoot:FindFirstChild("Guns")
local directAnimations = directAssets and directAssets:FindFirstChild("Animations")
local directTools = directAnimations and directAnimations:FindFirstChild("Tools")
local directGunAnimations = directTools and directTools:FindFirstChild("Guns")
local AnimationFolder = (directGunAnimations and directGunAnimations:FindFirstChild("GeistRifle"))
	or Assets.Animations.Tools.Guns:FindFirstChild("GeistRifle")
	or Assets.Animations.Tools.Guns:FindFirstChild("mondragon")
local PrinceAnimations = Assets.Animations.Tools.Guns:FindFirstChild("PrinceRifle")
local SoundFolder = (directSounds and directSounds:FindFirstChild("GeistRifle"))
	or Assets.Sounds.Guns:FindFirstChild("GeistRifle") or Assets.Sounds.Guns:FindFirstChild("mondragon") or Assets.Sounds.Guns:FindFirstChild("MondragonRifle")

local BULLET_SPEED = 950
local WEAPON_STATS = {
	name = "'Der Albtraum'",
	desc = "Suppressed Mondrag?n semi-automatic rifle, loaded with five-round stripper clips.",
	lore = "",
	size = 2,
	icon = "112193472525301",
	animations = "GeistRifle",
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
	pen = 1,
	armor_pen = 3,
	wallpen_distance = 30,
	wallpen_studs = 2,
	accuracy = 4,
	moving_accuracy = 50,
	fire_rate = 60 / 133,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 0.7,
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
	reload_loop = 1.45,
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
	Cycle = 1,
	Cycle_Left = 1,
	Locked = 0,
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

local function anim(names: { string }): Instance?
	if not AnimationFolder then return nil end
	for _, name in names do
		local found = AnimationFolder:FindFirstChild(name) or AnimationFolder:FindFirstChild(name, true)
		if found and (found:IsA("Animation") or found:IsA("KeyframeSequence")) then return found end
	end
	return nil
end

local GeistRifle = {}
GeistRifle.__index = GeistRifle
setmetatable(GeistRifle, { __index = BaseRifle })

export type GeistRifle = typeof(setmetatable({} :: any, GeistRifle))

function GeistRifle.new(info: Types.BaseToolCreateInfo): GeistRifle
	local self = setmetatable(BaseRifle.new(info), GeistRifle)

	self.className = "MondragonRifle"
	self.name = "MondragonRifle"
	self.item_image = GeistRifle.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.AnimationGunType = "GeistRifle"
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
		Hold = anim({ "held", "Hold" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("held")),
		Draw = anim({ "draw", "Draw" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("draw")),
		Unequip = anim({ "unequip", "Unequip" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("unequip")),
		Aim = anim({ "aim", "Aim" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("aim")),
		Aim_Left = anim({ "aim_left", "Aim_Left" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("aim_left")),
		Fire = anim({ "fire", "Fire" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("fire")),
		Fire_Left = anim({ "fire_left", "Fire_Left" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("fire_left")),
		Cycle = anim({ "cycle", "Cycle" }),
		Cycle_Left = anim({ "cycle_left", "Cycle_Left" }),
		Locked = anim({ "locked", "Locked" }),
		Fire_Last = anim({ "fire_last", "Fire_Last" }),
		Fire_Last_Left = anim({ "fire_last_left", "Fire_Last_Left" }),
		Reload_Start = anim({ "reload_start", "Reload_Start" }),
		Reload_Empty = anim({ "reload_empty", "Reload_Empty" }),
		Reload_Loop = anim({ "reload_loop", "Reload_Loop" }),
		Reload_End = anim({ "reload_end", "Reload_End", "cycle", "Cycle" }),
		Reload_Full = anim({ "reload_full", "Reload_Full" }),
		Check = anim({ "check", "Check" }),
		Melee1 = anim({ "melee1", "Melee1" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("melee1")),
		Melee2 = anim({ "melee2", "Melee2" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("melee2")),
		Short = anim({ "short", "Short" }) or (PrinceAnimations and PrinceAnimations:FindFirstChild("short")),
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
	self.ShowBulletTrail = false
	self.FireEmissions = nil
	self.auto = false
	self.FireSound = SoundFolder and SoundFolder:FindFirstChild("fire")
	self:_initShoulderTracking()
	return self
end

-- Reload/check mechanics are driven by the authored sound keyframes.
-- Numbered load and clip families also live in this weapon's own sound folder.
function GeistRifle:_findAnimationSound(name)
	if not self.SoundFolder then return nil end
	local exact = self.SoundFolder:FindFirstChild(name, true)
	if exact and exact:IsA("Sound") then return exact end
	local variants = {}
	for _, sound in self.SoundFolder:GetDescendants() do
		if sound:IsA("Sound") and sound.Name:sub(1, #name) == name
			and sound.Name:sub(#name + 1):match("^%d+$") then
			table.insert(variants, sound)
		end
	end
	return #variants > 0 and variants[math.random(1, #variants)] or nil
end

function GeistRifle:_playConfiguredSound(name)
	local sound = self:_findAnimationSound(name)
	local origin = self:_findModelPart(self.MuzzlePartName)
	if sound and origin then self:_play_sfx(sound, origin, nil, 0.1) end
end

function GeistRifle:_shouldPlayAnimationSound(name)
	return name ~= "draw" and name ~= "aimed" and name ~= "fire"
end

function GeistRifle:_on_equip()
	BaseRifle._on_equip(self)
	self:_playConfiguredSound("draw")
end

function GeistRifle:aim()
	local wasAiming = self.Aiming
	BaseRifle.aim(self)
	if wasAiming or not self.Aiming then return end
	local generation, version = self._equipGeneration, self._aimVersion
	task.delay(self:_aimDuration(), function()
		if self.Equipped and self.Aiming and self._equipGeneration == generation and self._aimVersion == version then
			self:_playConfiguredSound("aimed")
		end
	end)
end

function GeistRifle:ammo_check()
	local character = game.Players.LocalPlayer.Character
	self.ExactAmmoCount = character and character:GetAttribute("Class") == "Jaeger"
	return BaseRifle.ammo_check(self)
end

function GeistRifle:reload(): boolean
	if not self.Equipped or self:_isBusy() or self.Equipping then return false end
	if self.Capacity >= self.Max_Capacity then return false end
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	if not reserve or not reserve:IsA("NumberValue") or reserve.Value <= 0 then return false end

	local player = game.Players.LocalPlayer
	local character = player.Character
	local remainingReserve = reserve.Value
	local generation = self._equipGeneration
	local classBonus = character and character:GetAttribute("Class") == "Jaeger"
	local multiplier = self:_reloadSpeedMultiplier() * (classBonus and 1.15 or 1)
	local function active()
		return self.Equipped and self._equipGeneration == generation and not self._reloadCancelled
	end
	local function phase(name, duration)
		if not active() then return false end
		local track = self.RegisteredAnimations and self.RegisteredAnimations[name]
		local speed = 1 / duration
		-- _playAnim applies aura speed modifiers; the wall clock
		-- below uses the same multipliers plus the Jaeger class bonus.
		self:_playAnim(name, false, {speed = speed * (classBonus and 1.15 or 1)})
		local deadline = os.clock() + duration / multiplier
		repeat task.wait(math.min(0.03, math.max(0, deadline - os.clock()))) until not active() or os.clock() >= deadline
		if track then track:Stop(0) end
		return active()
	end

	self:_stopAllExcept()
	self.Reloading = true
	self._reloadCancelled = false
	player:SetAttribute("CantUnequip", true)
	local opening = self.Capacity == 0 and self.RegisteredAnimations and self.RegisteredAnimations.Reload_Empty
		and "Reload_Empty" or "Reload_Start"
	if phase(opening, 1.6) then
		while active() and self.Capacity < self.Max_Capacity and remainingReserve > 0 do
			if not phase("Reload_Loop", 1.45) then break end
			local rounds = math.min(5, self.Max_Capacity - self.Capacity, remainingReserve)
			remainingReserve -= rounds
			self.Capacity += rounds
			self:_fire_ammo(rounds)
		end
		if active() then phase("Reload_End", 0.7) end
	end
	-- An old reload coroutine must never reset a newly equipped weapon.
	if self._equipGeneration == generation then
		self.Reloading = false
		self._reloadCancelled = false
		player:SetAttribute("CantUnequip", nil)
		self:_restoreBaseDeferred()
	end
	return true
end

function GeistRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

GeistRifle.Tool_Image = "rbxassetid://112193472525301"
GeistRifle.Medal_Cost = 0
GeistRifle.Weight = 3
GeistRifle.Designation = "Primary"
GeistRifle.Display_Name = WEAPON_STATS.name
GeistRifle.desc = WEAPON_STATS.desc
GeistRifle.lore = WEAPON_STATS.lore
GeistRifle.assists = WEAPON_STATS.assists
GeistRifle.icon = WEAPON_STATS.icon
GeistRifle.alt_name = WEAPON_STATS.alt_name
GeistRifle.blacklist = WEAPON_STATS.blacklist
GeistRifle.damage = WEAPON_STATS.damage
GeistRifle.range = WEAPON_STATS.range
GeistRifle.range_damage = WEAPON_STATS.range_damage
GeistRifle.far = WEAPON_STATS.far
GeistRifle.far_damage = WEAPON_STATS.far_damage
GeistRifle.accuracy = WEAPON_STATS.accuracy
GeistRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
GeistRifle.fire_rate = WEAPON_STATS.fire_rate
GeistRifle.recoil = WEAPON_STATS.recoil
GeistRifle.recoil_count = WEAPON_STATS.recoil_count
GeistRifle.capacity = WEAPON_STATS.capacity
GeistRifle.ammo_give = WEAPON_STATS.ammo_give
GeistRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
GeistRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
GeistRifle.pen = WEAPON_STATS.pen
GeistRifle.armor_pen = WEAPON_STATS.armor_pen

-- Authored mount data from weapon_modules.mondragon (including inherited values).
GeistRifle.AuthoredWelds = {
	equipc0 = CFrame.new(0.253814697, -1.70311737, -0.565979004, -0.0170763358, -0.000915539567, -0.99985379, 0.99842006, 0.0535294637, -0.0171008594, 0.0535372309, -0.998565853, -4.00225453e-9),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	lefthand = true,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-0.843444824, -0.160831451, 0.563819885, -0.0857552588, 0.996316195, -2.14072588e-6, -0.996316195, -0.0857552588, 6.89330363e-6, 6.68433131e-6, 2.72397665e-6, 1),
	holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	alt_holsterc0 = CFrame.new(-0.0671386719, 0.0569257736, 0.563720703, -0.085755609, -0.996316195, 1.70646985e-7, -0.996320546, 0.0857559666, 8.59710667e-7, -2.90349675e-7, -2.8889346e-7, -1),
	alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

return GeistRifle
