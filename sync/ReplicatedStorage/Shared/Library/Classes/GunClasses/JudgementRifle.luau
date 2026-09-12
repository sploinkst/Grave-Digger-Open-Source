--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseRifle = require(script.Parent.Parent.BaseRifle)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local ToolFolder = GunAssets.ToolModels
local FxFolder = GunAssets.Effects

local judgementAnimations = Assets.Animations.Tools.Guns:FindFirstChild("JudgementRifle")

local judgementSounds = GunAssets.Sounds:FindFirstChild("henry")
	or GunAssets.Sounds:FindFirstChild("JudgementRifle")
	or GunAssets.Sounds:FindFirstChild("Judgement")
	or GunAssets.Sounds:FindFirstChild("lever")
local SoundFolder = judgementSounds or GunAssets.Sounds.PrinceRifle

local FIRE_INTERVAL = 60 / 80
local BULLET_SPEED = 1000
local RELOAD_ROUND_TIME = 2
local CHARGE_MIN_SPEED = 17.5
local CHARGE_SPEED = 22
local CHARGE_DURATION = 3
local CHARGE_TURN_RATE = math.rad(5)
local CHARGE_RANGE = 30
local CHARGE_DAMAGE = 300
local WEAPON_STATS = {
	name = "'Judgement' Breech Rifle",
	desc = "A devastating, breech loading, single shot rifle fitted with a Bayonet.",
	lore = [[Though bayonets have fallen out of favor in the caves' confines - manuverability and handling is often paramount to survival in these circumstances - in the case of the 'Judgement', the bayonet not only serves as a stalwart backup to the single-shot nature of the rifle, but also a superstitious role.

Corrosive shells hammered into the Empire's zealots as 'Able Four' marched through the hellish scene, gas masks adorned and automatic weapons at the ready. One of, if not the most battle-proven teams of the Royal Nation, this simple artillery ambush would prove to be their undoing - as knightly men blitzed through noxious fumes, flesh peeling and eyes bulging as they skewered the venerated Shock Troopers in cold blood. The horrific sight caused even these grizzled men to hesitate - and in those crucial moments, .577/450 rounds tore through their Vanguards' Shields, their flesh, and soon, their spirit.

...Or so the legend goes.]],
	size = 2,
	icon = "18724437158",
	animations = "henry",
	ammo_give = ".577 Alloy",
	melee_sound = "bayonet",
	assists = {
		"Deals significant damage at all ranges.",
		"Affixed bayonet provides superior melee capabilities.",
		"Capable of obliterating through helmets at close range.",
		"Un-wieldy and cumbersome, Steady Aim is your best friend.",
		"[@ALT] while in a Full Sprint to initiate the Bayonet Charge.",
		"Bayonet Charges are not effective for a short period after starting.",
	},
	tooltype = "gun",
	damage = 199,
	range = 60,
	range_damage = 180,
	far = 100,
	far_damage = 120,
	melee_damage = 105,
	melee_swing_speed = 0.65,
	melee_range = 7.5,
	pen = 4,
	wallpen_distance = 70,
	wallpen_studs = 4,
	accuracy = 12,
	moving_accuracy = 150,
	fire_rate = 0.75,
	display_fire_rate = 21,
	cycle = 0,
	cycle_rest = 0,
	draw_speed = 1.2,
	aim_speed = 0.4,
	wound = 1,
	length = 6,
	recoil = 25,
	recoil_count = 9,
	movement = 3,
	firing_movement = 2.5,
	firing_movement_last = 0.75,
	ammo_reserves = 8,
	ammo_reserves_max = 14,
	capacity = 1,
	chamber = false,
	reload_start = 2,
	reload_empty = 0,
	reload_loop = 0,
	reload_end = 0,
	reload_alt = 0,
	holster_point = "Torso",
	holsterc0 = CFrame.new(-0.932582855, 2.12966585, 0.536758423, 0, 0.999995708, 0, -1, 0, 0, 0, 0, 0.999995708),
	holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	alt_holsterc0 = CFrame.new(-0.43554306, 2.12966585, 0.570640564, -0.0355006903, 0.999369681, 0, -0.99936974, -0.0355006866, 0, -0, 0, 1),
	alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	lefthand = true,
	equipc0 = CFrame.new(0.367686272, -3.14173198, -0.561454773, 0, 0, -0.999995708, 0.99999994, 0, 0, 0, -0.999995708, 0),
	equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	special = {},
}
local HENRY_HOLSTER_C0 = WEAPON_STATS.holsterc0

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Left = 0,
	Fire = 1,
	Fire_Left = 1,
	Fire_Empty = 1,
	Fire_Empty_Left = 1,
	Fire_Last = 1,
	Fire_Last_Left = 1,
	Recoil = 1,
	Recoil_Left = 1,
	Cycle = 1,
	Draw = 2,
	Unequip = 2,
	Reload_Start = 2,
	Reload_Loop = 2,
	Reload_End = 2,
	Check = 2,
	Melee1 = 2,
	Melee2 = 2,
	Short = 2,
	Charge = 2,
	Charge_Stop = 2,
}

local JudgementRifle = {}
JudgementRifle.__index = JudgementRifle
setmetatable(JudgementRifle, { __index = BaseRifle })

export type JudgementRifle = typeof(setmetatable({} :: any, JudgementRifle))

local function get_holster_reference(model_reference: Model?): Model?
	local existing = GunAssets.Holsters:FindFirstChild("henryHolster")
		or GunAssets.Holsters:FindFirstChild("JudgementRifleHolster")
	if existing and existing:IsA("Model") then return existing end
	if not RunService:IsServer() or not model_reference then return nil end

	local holster = model_reference:Clone()
	holster.Name = "JudgementRifleHolster"
	local hitbox = holster:FindFirstChild("hitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then
		holster:Destroy()
		return nil
	end

	hitbox.Name = "JudgementRifle_Torso"
	holster.PrimaryPart = hitbox
	holster:SetAttribute("HolsterC0", HENRY_HOLSTER_C0)
	for _, descendant in ipairs(holster:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.Massless = true
			descendant:SetAttribute("Hide_On_Equip", true)
		end
	end
	hitbox.Transparency = 1
	hitbox:SetAttribute("Hide_On_Equip", nil)
	holster.Parent = GunAssets.Holsters
	return holster
end

function JudgementRifle.new(info: Types.BaseToolCreateInfo): JudgementRifle
	local self = setmetatable(BaseRifle.new(info), JudgementRifle)

	self.className = "JudgementRifle"
	self.PostShotReloadDelay = 0.3
	self.CanCancelReload = false
	self.item_image = JudgementRifle.Tool_Image
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.model_reference = ToolFolder:FindFirstChild("henry")
		or ToolFolder:FindFirstChild("Henry")
		or ToolFolder:FindFirstChild("JudgementRifle")
		or ToolFolder:FindFirstChild("Judgement")
	self.holster_reference = get_holster_reference(self.model_reference)
	
	self.DefaultGripC0 = WEAPON_STATS.equipc0
	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0 = "Left Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true),
		C0 = self.DefaultGripC0,
		C1 = WEAPON_STATS.equipc1,
	}

	self.AnimationGunType = "henry"
	self.animations = {
		Hold = judgementAnimations.held,
		Aim = judgementAnimations.aim,
		Aim_Left = judgementAnimations.aim_left,
		Fire = judgementAnimations.fire,
		Fire_Left = judgementAnimations.fire_left,
		Draw = judgementAnimations.draw,
		Unequip = judgementAnimations.Parent.PrinceRifle.PrinceRifle_Unequip,
		Reload_Start = judgementAnimations.reload_start,
		Check = judgementAnimations.check,
		Melee1 = judgementAnimations.melee1,
		Melee2 = judgementAnimations.melee2,
		Short = judgementAnimations.short,
		Charge = judgementAnimations.charge,
		Charge_Stop = judgementAnimations.charge_stop,
	}

	self.animation_speeds = {
		Draw = 1 / WEAPON_STATS.draw_speed,
		Aim = 1 / WEAPON_STATS.aim_speed,
		Aim_Left = 1 / WEAPON_STATS.aim_speed,
		Reload_Start = 1 / WEAPON_STATS.reload_start,
	}

	self.damage = WEAPON_STATS.damage
	self.Max_Capacity = WEAPON_STATS.capacity
	self.Capacity = WEAPON_STATS.capacity
	self.Starting_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves
	self.Max_Reserve_Ammo = WEAPON_STATS.capacity * WEAPON_STATS.ammo_reserves_max
	self.Ammo_Type = WEAPON_STATS.ammo_give
	self.recoil = WEAPON_STATS.recoil
	self.recoil_count = WEAPON_STATS.recoil_count
	self.Penetration_Level = WEAPON_STATS.pen
	self.Armor_Penetration_Level = WEAPON_STATS.pen
	self.KnockBack_Force = 14
	self.Aiming_Number = 80
	self.MuzzlePartName = "muzzle"
	self.BulletSpeed = BULLET_SPEED
	self.AmmoCheckPartName = "hitbox"
	self.Can_Drop = true
	self.Short_Distance = 3.5
	self.Melee_Distance = WEAPON_STATS.melee_range
	self.Melee_Damage = WEAPON_STATS.melee_damage
	self.Accuracy = WEAPON_STATS.accuracy
	self.Moving_Accuracy = WEAPON_STATS.moving_accuracy
	self.SoundFolder = SoundFolder
	self.FireSound = SoundFolder:FindFirstChild("fire")
	self.FireInterval = WEAPON_STATS.fire_rate
	self.ReloadStartAnimation = "Reload_Start"
	self.ReloadLoopAnimation = false
	self.ReloadEndAnimation = false

	self.Equipped = false
	self.Firing = false
	self.Cycling = false
	self.Reloading = false
	self.Alting = false
	self._reloadCancelled = false
	self.unequip_wait = false

	self.FireEmissions = {
		smoke_medium = function()
			return math.random(2, 4)
		end,
		smoke_forward = function()
			return math.random(4, 6)
		end,
	}

	self:_initShoulderTracking()
	self:applyFirearmConfig(WEAPON_STATS)
	return self
end

function JudgementRifle:get_spread(muzzle: BasePart, shootDirection: Vector3): Vector3
	return BaseRifle.get_spread(self, muzzle, shootDirection)
end

function JudgementRifle:aim()
	BaseRifle.aim(self)
end

function JudgementRifle:endAiming()
	BaseRifle.endAiming(self)
end

function JudgementRifle:setAltMode()
	if self:_isBusy() or not self.Equipped then return end

	local character = LOCAL_PLAYER.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or not root or not root:IsA("BasePart") then return end
	if character:GetAttribute("Sprinting") ~= true or humanoid.WalkSpeed < CHARGE_MIN_SPEED then
		self:notify("Reach full sprint speed to bayonet charge")
		return
	end

	self.Alting = true
	self.ForceBlockFire = true
	self:_stopAllExcept()
	self:_set_sprint_arms(true)
	local chargeTrack = self:_playAnim("Charge")
	
	Players.LocalPlayer.Character:SetAttribute("charging", true)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local startedAt = os.clock()
	local hitTarget: Model? = nil
	local chargeAttachment = Instance.new("Attachment")
	chargeAttachment.Name = "JudgementChargeAttachment"
	chargeAttachment.Parent = root
	local chargeVelocity = Instance.new("LinearVelocity")
	chargeVelocity.Name = "JudgementChargeVelocity"
	chargeVelocity.Attachment0 = chargeAttachment
	chargeVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	chargeVelocity.MaxForce = math.huge
	chargeVelocity.VectorVelocity = root.CFrame.LookVector * CHARGE_SPEED
	chargeVelocity.Parent = root

	while self.Equipped and humanoid.Health > 0 and os.clock() - startedAt < CHARGE_DURATION do
		local deltaTime = RunService.Heartbeat:Wait()
		local desiredDirection = humanoid.MoveDirection * Vector3.new(1, 0, 1)
		if desiredDirection.Magnitude > 0.05 then
			desiredDirection = desiredDirection.Unit
			local currentDirection = root.CFrame.LookVector * Vector3.new(1, 0, 1)
			if currentDirection.Magnitude > 0.05 then
				currentDirection = currentDirection.Unit
				local currentYaw = math.atan2(-currentDirection.X, -currentDirection.Z)
				local desiredYaw = math.atan2(-desiredDirection.X, -desiredDirection.Z)
				local yawDelta = math.atan2(math.sin(desiredYaw - currentYaw), math.cos(desiredYaw - currentYaw))
				local nextYaw = currentYaw + math.clamp(yawDelta, -CHARGE_TURN_RATE * deltaTime, CHARGE_TURN_RATE * deltaTime)
				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, nextYaw, 0)
			end
		end

		local forward = root.CFrame.LookVector
		chargeVelocity.VectorVelocity = forward * CHARGE_SPEED
		humanoid:Move(forward, false)

		local result = workspace:Raycast(root.Position, forward * CHARGE_RANGE, params)
		if result then
			local model = result.Instance:FindFirstAncestorOfClass("Model")
			local targetHumanoid = model and model:FindFirstChildOfClass("Humanoid")
			local targetPlayer = model and Players:GetPlayerFromCharacter(model)
			if targetHumanoid and targetHumanoid.Health > 0 and targetPlayer and targetPlayer.Team ~= LOCAL_PLAYER.Team then
				hitTarget = model
			end
			break
		end

	end
	chargeVelocity:Destroy()
	chargeAttachment:Destroy()

	if chargeTrack and chargeTrack.IsPlaying then chargeTrack:Stop(0.08) end
	if hitTarget then
		self:_damageMeleeTarget(hitTarget, CHARGE_RANGE, CHARGE_DAMAGE)
	end
	if self.Equipped then
		local stopTrack = self:_playAnim("Charge_Stop")
		Players.LocalPlayer.Character:SetAttribute("charging", nil)
		if stopTrack then stopTrack.Stopped:Wait() end
	end
	self:_set_sprint_arms(false)
	self.ForceBlockFire = false
	self.Alting = false
	self:_restoreBaseDeferred()
	Players.LocalPlayer.Character:SetAttribute("charging", nil)
end

function JudgementRifle:_on_unequip()
	BaseRifle._on_unequip(self)
	local character = LOCAL_PLAYER.Character
	if character then
		character:SetAttribute("charging", nil)
	end
end

function JudgementRifle:Destroy()
	self:_disconnectInput()
	BaseRifle.destroy(self)
end

JudgementRifle.Tool_Image = "rbxassetid://" .. WEAPON_STATS.icon
JudgementRifle.Medal_Cost = 0
JudgementRifle.Weight = 2
JudgementRifle.Designation = "Primary"
JudgementRifle.name = WEAPON_STATS.name
JudgementRifle.Display_Name = WEAPON_STATS.name
JudgementRifle.desc = WEAPON_STATS.desc
JudgementRifle.lore = WEAPON_STATS.lore
JudgementRifle.assists = WEAPON_STATS.assists
JudgementRifle.icon = WEAPON_STATS.icon
JudgementRifle.tooltype = WEAPON_STATS.tooltype
JudgementRifle.size = WEAPON_STATS.size
JudgementRifle.damage = WEAPON_STATS.damage
JudgementRifle.range = WEAPON_STATS.range
JudgementRifle.range_damage = WEAPON_STATS.range_damage
JudgementRifle.far = WEAPON_STATS.far
JudgementRifle.far_damage = WEAPON_STATS.far_damage
JudgementRifle.melee_damage = WEAPON_STATS.melee_damage
JudgementRifle.melee_swing_speed = WEAPON_STATS.melee_swing_speed
JudgementRifle.melee_range = WEAPON_STATS.melee_range
JudgementRifle.accuracy = WEAPON_STATS.accuracy
JudgementRifle.moving_accuracy = WEAPON_STATS.moving_accuracy
JudgementRifle.fire_rate = WEAPON_STATS.fire_rate
JudgementRifle.display_fire_rate = WEAPON_STATS.display_fire_rate
JudgementRifle.cycle = WEAPON_STATS.cycle
JudgementRifle.cycle_rest = WEAPON_STATS.cycle_rest
JudgementRifle.recoil = WEAPON_STATS.recoil
JudgementRifle.recoil_count = WEAPON_STATS.recoil_count
JudgementRifle.capacity = WEAPON_STATS.capacity
JudgementRifle.ammo_give = WEAPON_STATS.ammo_give
JudgementRifle.ammo_reserves = WEAPON_STATS.ammo_reserves
JudgementRifle.ammo_reserves_max = WEAPON_STATS.ammo_reserves_max
JudgementRifle.pen = WEAPON_STATS.pen
JudgementRifle.wallpen_distance = WEAPON_STATS.wallpen_distance
JudgementRifle.wallpen_studs = WEAPON_STATS.wallpen_studs
JudgementRifle.wound = WEAPON_STATS.wound
JudgementRifle.length = WEAPON_STATS.length
JudgementRifle.chamber = WEAPON_STATS.chamber
JudgementRifle.reload_start = WEAPON_STATS.reload_start
JudgementRifle.reload_empty = WEAPON_STATS.reload_empty
JudgementRifle.reload_loop = WEAPON_STATS.reload_loop
JudgementRifle.reload_end = WEAPON_STATS.reload_end
JudgementRifle.reload_alt = WEAPON_STATS.reload_alt
JudgementRifle.holster_point = WEAPON_STATS.holster_point
JudgementRifle.holsterc0 = WEAPON_STATS.holsterc0
JudgementRifle.holsterc1 = WEAPON_STATS.holsterc1
JudgementRifle.alt_holsterc0 = WEAPON_STATS.alt_holsterc0
JudgementRifle.alt_holsterc1 = WEAPON_STATS.alt_holsterc1
JudgementRifle.lefthand = WEAPON_STATS.lefthand
JudgementRifle.equipc0 = WEAPON_STATS.equipc0
JudgementRifle.equipc1 = WEAPON_STATS.equipc1
JudgementRifle.special = WEAPON_STATS.special

return JudgementRifle
