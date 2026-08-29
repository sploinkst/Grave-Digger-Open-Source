-----------------------
--@Praxitos
--GraceRevolver
------------------------

--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local Types    = require(script.Parent.Parent.Parent.Types)
local BasePistol = require(script.Parent.Parent.BasePistol)
local Util     = require(script.Parent.Parent.Parent.Util)

-- // Assets

local Assets         = ReplicatedStorage.Shared.Assets
local Holster_Folder = Assets.Guns.Holsters
local Tool_Folder    = Assets.Guns.ToolModels
local Anim_Folder    = Assets.Animations.Tools.Guns.GraceRevolver
local FxFolder       = Assets.Guns.Effects

local SoundFolder = Assets.Guns:WaitForChild("Sounds"):WaitForChild("GraceRevolver")
local fire_sound  = SoundFolder.fire

-- // Tuning

local FIRE_RATE    = 0.75
local BULLET_SPEED = 800

-- // Animation layers

local ANIM_LAYERS: { [string]: number } = {
	Hold     = 0,
	Aim      = 0,
	Aim_Left = 0,

	Fire            = 1,
	Fire_Left       = 1,
	Fire_Empty      = 1,
	Fire_Empty_Left = 1,
	Short           = 1,
	Short_Alt       = 1,
	Spin            = 1,
	Spin_Start      = 1,

	Draw         = 2,
	Unequip      = 2,
	Check        = 2,
	Melee1       = 2,
	Melee2       = 2,
	Reload_Start = 2,
	Reload_Loop  = 2,
	Reload_End   = 2,
}

-- // Class

local GraceRevolver = {}
GraceRevolver.__index = GraceRevolver
setmetatable(GraceRevolver, { __index = BasePistol })

export type GraceRevolver = typeof(setmetatable({} :: {
	className:   "GraceRevolver",
	name:        string,
	item_image:  string,
	Designation: string,

	holster_reference: Instance?,
	actual_holster:    Model?,
	model_reference:   Model?,
	actual_model:      Model?,

	damage:                  number,
	Max_Capacity:            number,
	Capacity:                number,
	Ammo_Type:               string,
	recoil:                  number,
	recoil_count:            number,
	Penetration_Level:       number,
	Armor_Penetration_Level: number,
	KnockBack_Force:         number,
	Aiming_Number:           number,
	MuzzlePartName:          string,

	Aiming:    boolean,
	Firing:    boolean,
	Reloading: boolean,
	Spinning:  boolean,
	Meleeing:  boolean,

	_reloadCancelled: boolean,
	_spinCancelled:   boolean,

	ANIM_LAYERS:      { [string]: number },
	current_shoulder: string,

	Caster:         any,
	CasterBehavior: any,

	motor_6d:       Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
}, {} :: typeof(GraceRevolver)))

-- // Constructor

function GraceRevolver.new(info: Types.BaseToolCreateInfo): GraceRevolver
	local self = setmetatable(BasePistol.new(info), GraceRevolver)

	self.className   = "GraceRevolver"
	self.item_image  = "rbxassetid://17601078078"
	self.Designation = "Secondary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.holster_reference = Holster_Folder and Holster_Folder:FindFirstChild("GraceRevolverHolster")
	self.model_reference   = Tool_Folder:FindFirstChild("GraceRevolver")
	self.Round             = Assets.Guns.Rounds.GraceRevolver_Round
	self.Round_Target_Part = "Left Arm"

	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0  = "Right Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("GraceRevolver_Middle"),
		C0     = CFrame.new(-0.258, -1.438, -0.506) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Hold    = Anim_Folder.GraceRevolver_Held,
		Draw    = Anim_Folder.GraceRevolver_Draw,
		Unequip = Anim_Folder.GraceRevolver_Unequip,

		Aim      = Anim_Folder.GraceRevolver_Aim,
		Aim_Left = Anim_Folder.GraceRevolver_Aim_left,

		Fire            = Anim_Folder.GraceRevolver_Fire,
		Fire_Left       = Anim_Folder.GraceRevolver_Fire_Left,
		Fire_Empty      = Anim_Folder.GraceRevolver_Fire_Empty,
		Fire_Empty_Left = Anim_Folder.GraceRevolver_Fire_Empty_Left,

		Short     = Anim_Folder.GraceRevolver_Short,
		Short_Alt = Anim_Folder.GraceRevolver_Short_alt,

		Spin       = Anim_Folder.GraceRevolver_Spin,
		Spin_Start = Anim_Folder.GraceRevolver_Spin_start,

		Reload_Start      = Anim_Folder.GraceRevolver_Reload_start,
		Reload_Loop       = Anim_Folder.GraceRevolver_Reload_loop,
		Reload_Loop_After = Anim_Folder.GraceRevolver_Reload_loop_after,
		Reload_End        = Anim_Folder.GraceRevolver_Reload_end,

		Check  = Anim_Folder.GraceRevolver_Check,
		Melee1 = Anim_Folder.GraceRevolver_Melee1,
		Melee2 = Anim_Folder.GraceRevolver_Melee2,

		Drop = Anim_Folder.Parent.Parent.Misc.Drop_Pistol,
	}

	self.animation_speeds = {
		Melee1            = 1.43,
		Melee2            = 1.43,
		Fire              = 1.33,
		Fire_Left         = 1.33,
		Draw              = 5.0,
		Aim               = 8.0,
		Aim_Left          = 8.0,
		Reload_Start      = 0.91,
		Reload_Loop       = 2.5,
		Reload_Loop_After = 10,
		Reload_End        = 1.54,
	}

	self.damage                  = 120
	self.Max_Capacity            = 6
	self.Capacity                = 6
	self.Ammo_Type               = ".45 Lead"
	self.recoil                  = 50
	self.recoil_count            = 10
	self.do_roll 				 = true
	self.Penetration_Level       = 1
	self.Armor_Penetration_Level = 2
	self.KnockBack_Force         = 8
	self.Aiming_Number           = 80
	self.Short_Distance          = 3.5
	self.MuzzlePartName          = "GraceRevolver_Muzzle"
	self.AmmoCheckPartName       = "GraceRevolver_Middle"
	self.Can_Drop                = true
	self.Melee_Distance          = 5
	self.Melee_Damage            = 80
	self.Accuracy                = 6
	self.Moving_Accuracy         = 50

	self.SoundFolder             = SoundFolder

	self.unequip_wait     = false
	self.Aiming           = false
	self.Firing           = false
	self.Reloading        = false
	self.Spinning         = false
	self.Meleeing         = false
	self._reloadCancelled = false
	self._spinCancelled   = false

	self.FireEmissions = {
		flash = {
			chance = 0.5,
			count = 1,
		},

		flash_general = {
			chance = 0.5,
			count = 1,
		},

		smoke_flash_heavy = 1,

		smoke_medium = function()
			return math.random(2, 4)
		end,

		smoke_forward = function()
			return math.random(4, 6)
		end,

		smoke_linger_strong = 1,
	}
	
	self:_initShoulderTracking()

	return self
end

-- // Key bindings

function GraceRevolver:_getKeyBindings()
	local base = BasePistol._getKeyBindings(self)
	base.Spin = Enum.KeyCode.Q
	return base
end

function GraceRevolver:setAltMode()
	task.spawn(function() self:spin() end)
end

-- // isBusy override (Spinning counts)

function GraceRevolver:_isBusy(): boolean
	return self.Firing or self.Reloading or self.Spinning or self.Meleeing or self.Checking
end

-- // Actions

function GraceRevolver:_cancelSpin()
	self._spinCancelled = true
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Spin       and anims.Spin.IsPlaying       then anims.Spin:Stop(0)       end
	if anims.Spin_Start and anims.Spin_Start.IsPlaying then anims.Spin_Start:Stop(0) end
end

function GraceRevolver:spin()
	if self:_isBusy() then return end
	self.Spinning       = true
	self._spinCancelled = false

	self:_playAnim("Spin_Start").Stopped:Wait()

	if self._spinCancelled then
		self.Spinning       = false
		self._spinCancelled = false
		self:_restoreBaseDeferred()
		return
	end

	self:_playAnim("Spin").Stopped:Wait()

	self.Spinning       = false
	self._spinCancelled = false
	self:_restoreBaseDeferred()
end

function GraceRevolver:fire()
	if self.Firing then return end
	if self.ForceBlockFire then return end
	self.Firing = true

	if self.Spinning then self:_cancelSpin() end

	-- Dry fire
	if self.Capacity <= 0 then
		local emptyAnim = (self.current_shoulder == "Right") and "Fire_Empty" or "Fire_Empty_Left"
		self:_playAnim(emptyAnim).Stopped:Wait()
		self.Firing = false
		self:_restoreBaseDeferred()
		return
	end

	local muzzle = self:_findModelPart(self.MuzzlePartName)
	if not muzzle or self:_if_sprinting() then self.Firing = false; return end

	local camera = workspace.CurrentCamera

	local mousePos = UserInputService:GetMouseLocation()
	local ray      = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

	-- Skip transparent parts so invisible walls don't deflect the aimed direction.
	local result    = Util.raycastSkipTransparent(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir  = (targetPos - muzzle.Position).Unit

	shootDir = self:get_spread(muzzle, shootDir)

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, BULLET_SPEED, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false
	activeCast.UserData.Origin     = muzzle.Position
	activeCast.UserData.Shooter    = game.Players.LocalPlayer

	self:_connect_FastCast(muzzle.Position, shootDir, BULLET_SPEED, {
		bulletTemplate   = FxFolder.Bullet,
		bulletContainer  = workspace.Game_Details.Effects.Bullets,
		isPenetration    = false,
		penetrationLevel = self.Penetration_Level,
		damage           = self.damage,
		knockbackForce   = self.KnockBack_Force,
	})

	self.Capacity -= 1
	Util.applyRecoil(self.recoil, self.recoil_count, 10, false, 1)

	local fireAnim  = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	local fireTrack = self:_playAnim(fireAnim)

	self:_play_sfx(fire_sound, muzzle, nil, self.Alt_Mode and 0.5 or nil)
	self:_bounce_scoped_ui()
	self:_fireMuzzleFlash()

	fireTrack.Stopped:Once(function()
		if not self.Reloading and not self.Spinning then
			self:_restoreBaseDeferred()
		end
	end)

	task.wait(FIRE_RATE)
	self.Firing = false
end

function GraceRevolver:reload()
	if self.Reloading or self.Capacity >= self.Max_Capacity or self.Equipping then return end

	if self.Spinning then self:_cancelSpin() end
	if self.Aiming   then self:endAiming()   end

	self.RegisteredAnimations["Reload_Start"]:AdjustWeight(1)
	self.RegisteredAnimations["Reload_Loop"]:AdjustWeight(1)
	self:_set_sprint_arms(true)
	self:_stopLayer(2)

	self.Reloading        = true
	self._reloadCancelled = false

	game.Players.LocalPlayer:SetAttribute("CantUnequip", true)
	self:_playAnim("Reload_Start").Stopped:Wait()
	self.Capacity = 0

	while self.Capacity < self.Max_Capacity and not self._reloadCancelled do
		self:_playAnim("Reload_Loop").Stopped:Wait()
		if self._reloadCancelled then break end
		self.Capacity += 1
		self:_fire_ammo(1)
		self:_playAnim("Reload_Loop_After").Stopped:Wait()
	end

	if not self._reloadCancelled then
		self:_playAnim("Reload_End").Stopped:Wait()

		-- Reset cylinder rotation
		local cylinder_motor: Motor6D =
			self.actual_model
			:FindFirstChild(self.className .. "_Middle")
			:FindFirstChild(self.className .. "_Cylinder")

		local pos = cylinder_motor.C0.Position
		cylinder_motor.C0 = CFrame.new(pos)
	else
		local anims = self.RegisteredAnimations
		if anims.Reload_Loop  and anims.Reload_Loop.IsPlaying  then anims.Reload_Loop:Stop(0)  end
		if anims.Reload_Start and anims.Reload_Start.IsPlaying then anims.Reload_Start:Stop(0) end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	self:_set_sprint_arms(false)
	game.Players.LocalPlayer:SetAttribute("CantUnequip", false)
end

function GraceRevolver:activate()
	if not self.actual_model then return end
	if self:_isBusy() or self.Firing then return end

	if self.Aiming then
		self:fire()
	else
		self:melee()
	end
end

-- // Lifecycle hooks

function GraceRevolver:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()

	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local muzzle = self:_findModelPart(self.MuzzlePartName)
		self:_onBulletHit(cast, result, velocity, muzzle, self.Penetration_Level, self.damage, self.KnockBack_Force)
	end)
end

function GraceRevolver:_on_unequip()
	self._reloadCancelled = true
	self.Equipped         = false

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_cancelSpin()
	self:_stopLayer(2)
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	self.Firing    = false
	self.Reloading = false
	self.Spinning  = false

	local char = game.Players.LocalPlayer.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

-- // Cleanup

function GraceRevolver:Destroy()
	self:_disconnectInput()
	BasePistol.destroy(self)
end

GraceRevolver.Tool_Image = "rbxassetid://17601078078"
GraceRevolver.Medal_Cost = 1
GraceRevolver.Weight     = 1
GraceRevolver.Designation = "Secondary"

return GraceRevolver
