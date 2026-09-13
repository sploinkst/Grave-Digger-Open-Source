--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local BasePistol = require(script.Parent.Parent.BasePistol)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects
local AnimFolder = Assets.Animations.Tools.Guns:WaitForChild("HonourPistol")
local SoundFolder = GunAssets.Sounds:FindFirstChild("HonourPistol") or GunAssets.Sounds:FindFirstChild("mauser")

local FIRE_RATE = 60 / 207
local BLACK_HAND_FIRE_RATE = 60 / 222
local STOCK_FIRE_RATE = 60 / 214
local BLACK_HAND_STOCK_FIRE_RATE = 60 / 231
local BULLET_SPEED = 850
local CLIP_SIZE = 10

local WEAPON_STATS = {
	name = "'Honour' Duty Pistol",
	desc = "High capacity pistol capable of outputting a wall of lead at close range quickly.",
	lore = "A pre-war automatic pistol originally known as the M96, this weapon was originally a veteran memorial piece, as the .30 Automatic cartridge was believed to be ineffective in all roles save for close-range self defense.\n\nHowever, following a war's re-ignition, many veterans vouched for the production of more ammunition, and in turn, more pistols - of which proved its doubters wrong in the hands of capable soldiers.\n\nTen rounds, surprisingly light recoil, and a complementary dettachable stock meant that the pistol was surprisingly flexible for pestering enemies at longer ranges or for dumping lead into them up-close - and though the .30 Automatic cartridge is far from dehabilitiating at extreme ranges, it is still capable of taking a life with ease should the enemy's head be exposed.",
	size = 1,
	icon = "18193612933",
	animations = "mauser",
	ammo_give = ".30 Automatic",
	melee_sound = "pistol",
	assists = {
		"Mind the wasteful reload and weak stopping power at range.",
		"Reloading from dry is your most efficient option.",
		"You will be unable to reload without sufficient reserves.",
		"Attach or Detach Stock with [@ALT].",
		"Stock improves Accuracy and Fire rate, but cannot be holstered until removed.",
	},
	tooltype = "gun",
	damage = 75,
	range = 40,
	range_damage = 60,
	far = 65,
	far_damage = 50,
	melee_damage = 80,
	melee_swing_speed = 0.7,
	melee_range = 5,
	pen = 0,
	armor_pen = 0,
	wallpen_distance = 30,
	wallpen_studs = 2,
	accuracy = 15,
	moving_accuracy = 30,
	stock_accuracy = 8,
	stock_moving_accuracy = 45,
	fire_rate = FIRE_RATE,
	black_hand_fire_rate = BLACK_HAND_FIRE_RATE,
	stock_fire_rate = STOCK_FIRE_RATE,
	black_hand_stock_fire_rate = BLACK_HAND_STOCK_FIRE_RATE,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 0.275,
	black_hand_draw_speed = 0.18,
	aim_speed = 0.2,
	black_hand_aim_speed = 0.172,
	wound = 1,
	length = 4,
	recoil = 6,
	stock_recoil = 3,
	recoil_count = 6,
	movement = 0.5,
	firing_movement = 0.5,
	firing_movement_last = 0.25,
	ammo_reserves = 2,
	ammo_reserves_max = 3,
	capacity = 10,
	chamber = false,
	reload_start = 1.5,
	reload_empty = 0.6,
	reload_loop = 0,
	reload_loop_after = 0,
	reload_end = 0,
	reload_full = 2.8,
	veteran_reload_full = 1.85,
	require_full_load = true,
	post_reload_delay = 0.15,
	bullet_speed = BULLET_SPEED,
}

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Stock_Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Stock_Aim = 0,
	Stock_Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Stock_Fire = 1,
	Stock_Fire_Left = 1,
	Draw = 2,
	Stock_On = 2,
	Stock_Off = 2,
	Reload_Start = 2,
	Reload_Start_Vet = 2,
	Reload_Full = 2,
	Reload_Full_Vet = 2,
	Reload_One = 2,
	Reload_One_Vet = 2,
	Check = 2,
	Check_Empty = 2,
}

local HonourPistol = {}
HonourPistol.__index = HonourPistol
setmetatable(HonourPistol, { __index = BasePistol })

export type HonourPistol = typeof(setmetatable({} :: any, HonourPistol))

local function animation(name: string): Animation?
	local found = AnimFolder:FindFirstChild(name)
	if found and found:IsA("Animation") then return found end
	return nil
end

local function hasPerk(name: string): boolean
	if not RunService:IsClient() or not LOCAL_PLAYER then return false end
	local character = LOCAL_PLAYER.Character
	local perk = character and character:FindFirstChild("perk")
	return perk ~= nil and perk:IsA("StringValue") and string.lower(perk.Value) == name
end

local function firstModelPart(model: Model?, names: { string }): BasePart?
	if not model then return nil end
	for _, name in ipairs(names) do
		local found = model:FindFirstChild(name, true)
		if found and found:IsA("BasePart") then return found end
	end
	return model:FindFirstChildWhichIsA("BasePart", true)
end

function HonourPistol.new(info: Types.BaseToolCreateInfo): HonourPistol
	local self = setmetatable(BasePistol.new(info), HonourPistol)

	local blackHand = hasPerk("blackhand")
	self.className = "HonourPistol"
	self.item_image = "rbxassetid://18193612933"
	self.Designation = "Secondary"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.AnimationGunType = "mauser"

	self.model_reference = ToolFolder:FindFirstChild("mauser") or ToolFolder:FindFirstChild("HonourPistol")
	self.holster_reference = GunAssets.Holsters:FindFirstChild("mauserHolster")
		or GunAssets.Holsters:FindFirstChild("HonourPistolHolster")
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = firstModelPart(self.model_reference, { "grip", "hitbox" }),
		C0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		C1 = CFrame.identity,
	}

	self.animations = {
		Hold = animation("locked"),
		Stock_Hold = animation("akimbo_locked"),
		Draw = animation("locked"),
		Aim = animation("locked"),
		Aim_Left = animation("akimbo_locked"),
		Stock_Aim = animation("alt_changeaim"),
		Stock_Aim_Left = animation("alt_changeaim_left"),
		Fire = animation("fire"),
		Fire_Left = animation("fire"),
		Stock_Fire = animation("alt_changefire"),
		Stock_Fire_Left = animation("alt_changefire_left"),
		Stock_On = animation("alt_stockon"),
		Stock_Off = animation("alt_stockoff"),
		Reload_Start = animation("reload_start"),
		Reload_Start_Vet = animation("reload_start_vet"),
		Reload_Full = animation("reload_full"),
		Reload_Full_Vet = animation("reload_full_vet"),
		Reload_One = animation("reload_one"),
		Reload_One_Vet = animation("reload_one_vet"),
		Check = animation("check"),
		Check_Empty = animation("check_empty"),
	}

	self.animation_speeds = {
		Draw = 1 / (blackHand and WEAPON_STATS.black_hand_draw_speed or WEAPON_STATS.draw_speed),
		Aim = 1 / (blackHand and WEAPON_STATS.black_hand_aim_speed or WEAPON_STATS.aim_speed),
		Aim_Left = 1 / (blackHand and WEAPON_STATS.black_hand_aim_speed or WEAPON_STATS.aim_speed),
		Stock_Aim = 1 / (blackHand and WEAPON_STATS.black_hand_aim_speed or WEAPON_STATS.aim_speed),
		Stock_Aim_Left = 1 / (blackHand and WEAPON_STATS.black_hand_aim_speed or WEAPON_STATS.aim_speed),
		Reload_Start = 1 / WEAPON_STATS.reload_empty,
		Reload_Start_Vet = 1 / WEAPON_STATS.reload_empty,
		Reload_Full = 1 / WEAPON_STATS.reload_full,
		Reload_Full_Vet = 1 / WEAPON_STATS.veteran_reload_full,
		Reload_One = 1 / WEAPON_STATS.reload_full,
		Reload_One_Vet = 1 / WEAPON_STATS.veteran_reload_full,
	}

	self:applyFirearmConfig(WEAPON_STATS)
	self.FireSound = SoundFolder and SoundFolder:FindFirstChild("fire")
	self.SoundFolder = SoundFolder
	self.FxFolder = FxFolder
	self.Round_Target_Part = "Left Arm"
	self.MuzzlePartName = "muzzle"
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.IsVeteran = hasPerk("vet")
	self.IsBlackHand = blackHand
	self.StockAttached = false
	self.FireInterval = blackHand and WEAPON_STATS.black_hand_fire_rate or WEAPON_STATS.fire_rate
	if self.IsVeteran then
		self.Starting_Reserve_Ammo = self.Max_Reserve_Ammo
	end

	self.FireEmissions = {
		flash = 1,
		flash_general = 1,
		smoke_medium = function() return math.random(1, 3) end,
		smoke_forward = function() return math.random(2, 4) end,
	}

	self:_initShoulderTracking()
	return self
end

function HonourPistol:_applyStockStats()
	if self.StockAttached then
		self.Accuracy = WEAPON_STATS.stock_accuracy
		self.Moving_Accuracy = WEAPON_STATS.stock_moving_accuracy
		self.recoil = WEAPON_STATS.stock_recoil
		self.FireInterval = self.IsBlackHand and WEAPON_STATS.black_hand_stock_fire_rate or WEAPON_STATS.stock_fire_rate
	else
		self.Accuracy = WEAPON_STATS.accuracy
		self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
		self.recoil = WEAPON_STATS.recoil
		self.FireInterval = self.IsBlackHand and WEAPON_STATS.black_hand_fire_rate or WEAPON_STATS.fire_rate
	end
end

function HonourPistol:_setStockVisible(visible: boolean)
	local model = self.actual_model
	local stock = model and model:FindFirstChild("stock", true)
	if not stock then return end
	for _, descendant in ipairs(stock:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = visible and 0 or 1
		end
	end
	if stock:IsA("BasePart") then
		stock.Transparency = visible and 0 or 1
	end
end

function HonourPistol:_aimTrack(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	if self.StockAttached then
		return (self.current_shoulder == "Right") and anims.Stock_Aim or anims.Stock_Aim_Left
	end
	return BasePistol._aimTrack(self)
end

function HonourPistol:_killAimTracks()
	BasePistol._killAimTracks(self)
	local anims = self.RegisteredAnimations
	if not anims then return end
	for _, name in ipairs({ "Stock_Aim", "Stock_Aim_Left" }) do
		local track = anims[name]
		if track and track.IsPlaying then track:Stop(0.06) end
	end
end

function HonourPistol:_restoreBase()
	BasePistol._restoreBase(self)
	local anims = self.RegisteredAnimations
	if not anims or not self.Equipped or self.Aiming or self:_isBusy() then return end
	local hold = self.StockAttached and anims.Stock_Hold or anims.Hold
	if hold and not hold.IsPlaying then
		hold:Play(0.06)
		hold:AdjustSpeed(0.2)
	end
end

function HonourPistol:setAltMode()
	if not self.Equipped or self:_isBusy() then return end
	self.Alting = true
	self:_stopAllExcept()
	local nextStock = not self.StockAttached
	local track = self:_playAnim(nextStock and "Stock_On" or "Stock_Off")
	if track then track.Stopped:Wait() end
	if not self.Equipped then
		self.Alting = false
		return
	end
	self.StockAttached = nextStock
	self:_setStockVisible(self.StockAttached)
	self:_applyStockStats()
	Players.LocalPlayer:SetAttribute("CantUnequip", self.StockAttached and true or nil)
	self:notify(self.StockAttached and "Stock attached" or "Stock detached")
	self.Alting = false
	self:_restoreBaseDeferred()
end

function HonourPistol:fire()
	local left = self.current_shoulder ~= "Right"
	local fireAnimation = if self.StockAttached
		then (left and self.RegisteredAnimations and self.RegisteredAnimations.Stock_Fire_Left and "Stock_Fire_Left" or "Stock_Fire")
		else (left and self.RegisteredAnimations and self.RegisteredAnimations.Fire_Left and "Fire_Left" or "Fire")
	self:_fireSingleShot({
		bulletSpeed = self.BulletSpeed,
		fireAnimation = fireAnimation,
		sound = self.FireSound,
		fireDelay = self.FireInterval,
	})
end

function HonourPistol:reload()
	if not self.Equipped or self.Reloading or self.Equipping then return end
	if self.Capacity >= self.Max_Capacity then return end
	local reserveAmmo = self:_getReserveAmmo()
	if not reserveAmmo then
		warn(self.className .. ": Cannot reload because Reserve_Ammo is missing")
		return
	end
	if reserveAmmo.Value <= 0 then
		self:notify("I don't have any more ammo...")
		self:_restoreBase()
		return
	end
	if reserveAmmo.Value < self.Max_Capacity and not self.IsVeteran then
		self:notify("I need a full clip to reload...")
		return
	end

	self.Reloading = true
	self._reloadCancelled = false
	Players.LocalPlayer:SetAttribute("CantUnequip", true)
	self:_stopAllExcept()

	local hadAmmo = self.Capacity > 0
	local startName = self.IsVeteran and "Reload_Start_Vet" or "Reload_Start"
	local reloadName = if hadAmmo
		then (self.IsVeteran and "Reload_One_Vet" or "Reload_One")
		else (self.IsVeteran and "Reload_Full_Vet" or "Reload_Full")

	local startTrack = self:_playAnim(startName)
	if startTrack then startTrack.Stopped:Wait() end

	if not self.IsVeteran and hadAmmo then
		self.Capacity = 0
	end

	local reloadTrack = self:_playAnim(reloadName)
	if reloadTrack then reloadTrack.Stopped:Wait() end

	if self.Equipped and not self._reloadCancelled then
		local needed = self.Max_Capacity - self.Capacity
		local loadAmount = math.min(needed, reserveAmmo.Value, CLIP_SIZE)
		if loadAmount > 0 then
			self.Capacity += loadAmount
			self:_fire_ammo(loadAmount)
		end
	end

	self.Reloading = false
	self._reloadCancelled = false
	Players.LocalPlayer:SetAttribute("CantUnequip", self.StockAttached and true or nil)
	self:_blockFireFor(self.PostReloadDelay or 0)
	self:_restoreBaseDeferred()
end

function HonourPistol:activate()
	if self.Reloading then
		self._reloadCancelled = true
		return
	end
	if not self.actual_model or self:_isBusy() then return end
	if self.Aiming then self:fire() else self:melee() end
end

function HonourPistol:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	self:_setStockVisible(self.StockAttached)
	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local origin = cast.UserData and cast.UserData.Origin
		local distance = origin and (result.Position - origin).Magnitude or 0
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level, self:_damageAtDistance(distance), self.KnockBack_Force)
	end)
end

function HonourPistol:_on_unequip()
	if self.StockAttached then
		self.Equipped = true
		Players.LocalPlayer:SetAttribute("CantUnequip", true)
		return
	end
	self.Equipped = false
	self.Firing = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = true
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
	Players.LocalPlayer:SetAttribute("CantUnequip", nil)
	local character = Players.LocalPlayer.Character
	if character then
		character:SetAttribute("Aiming", false)
		character:SetAttribute("Sprint_Animation", nil)
	end
end

function HonourPistol:Destroy()
	self:_disconnectInput()
	BasePistol.destroy(self)
end

HonourPistol.name = WEAPON_STATS.name
HonourPistol.Display_Name = WEAPON_STATS.name
HonourPistol.Tool_Image = "rbxassetid://18193612933"
HonourPistol.Medal_Cost = 1
HonourPistol.Weight = 1
HonourPistol.Designation = "Secondary"
HonourPistol.desc = WEAPON_STATS.desc
HonourPistol.lore = WEAPON_STATS.lore
HonourPistol.assists = WEAPON_STATS.assists
HonourPistol.icon = WEAPON_STATS.icon
HonourPistol.tooltype = WEAPON_STATS.tooltype
HonourPistol.damage = WEAPON_STATS.damage
HonourPistol.range = WEAPON_STATS.range
HonourPistol.range_damage = WEAPON_STATS.range_damage
HonourPistol.far = WEAPON_STATS.far
HonourPistol.far_damage = WEAPON_STATS.far_damage
HonourPistol.accuracy = WEAPON_STATS.accuracy
HonourPistol.moving_accuracy = WEAPON_STATS.moving_accuracy
HonourPistol.fire_rate = WEAPON_STATS.fire_rate
HonourPistol.recoil = WEAPON_STATS.recoil
HonourPistol.recoil_count = WEAPON_STATS.recoil_count
HonourPistol.capacity = WEAPON_STATS.capacity
HonourPistol.ammo_give = WEAPON_STATS.ammo_give
HonourPistol.ammo_reserves = WEAPON_STATS.ammo_reserves
HonourPistol.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
HonourPistol.pen = WEAPON_STATS.pen

return HonourPistol
