--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local Util = require(script.Parent.Parent.Parent.Util)
local createAnimationResolver = require(script.Parent.Parent.GunClasses.AnimationResolver)

local LOCAL_PLAYER = Players.LocalPlayer
local Assets = ReplicatedStorage.Shared.Assets
local GunAssets = Assets.Guns
local FxFolder = GunAssets.Effects
local legacyAnimations = Assets.Animations.Tools.Guns:FindFirstChild("cavsword")
local animation = createAnimationResolver("cavsword")
local Events = ReplicatedStorage.Shared.Library.Events

local function getDualWieldEvent(): RemoteEvent
	return Events:WaitForChild("DualWield") :: RemoteEvent
end

local SWING_DAMAGE = 120
local SWING_INTERVAL = 0.8
local DUAL_RPM_MULTIPLIER = 0.9
local BULLET_SPEED = 800

local ANIM_LAYERS: { [string]: number } = {
	Hold = 0,
	Aim = 0,
	Aim_Dual = 0,
	Aim_Normal = 0,
	Melee1 = 1,
	Melee2 = 1,
	Melee_Alt1 = 1,
	Melee_Alt2 = 1,
	Shoot = 1,
	Shoot_Empty = 1,
	Draw = 2,
	Draw_Dual = 2,
	Unequip = 2,
	Sprint = 2,
	Sprint_Dual = 2,
	Sprint_Normal = 2,
}

local CavalrySword = {}
CavalrySword.__index = CavalrySword
setmetatable(CavalrySword, { __index = BaseTool })

export type CavalrySword = typeof(setmetatable({} :: any, CavalrySword))

local function getModelReference(): Model?
	local source = GunAssets.ToolModels:FindFirstChild("cavsword")
	if not source then return nil end
	if source:IsA("Model") then return source end

	local model = Instance.new("Model")
	model.Name = "cavsword"
	local clone = source:Clone()
	for _, child in ipairs(clone:GetChildren()) do child.Parent = model end
	clone:Destroy()
	local authoredWeld = model:FindFirstChildWhichIsA("Weld", true)
	local grip = authoredWeld and (authoredWeld.Part0 or authoredWeld.Part1)
		or model:FindFirstChildWhichIsA("BasePart", true)
	if grip then model.PrimaryPart = grip end
	return model
end

function CavalrySword.new(info: Types.BaseToolCreateInfo): CavalrySword
	local self = setmetatable(BaseTool.new(info), CavalrySword)
	self.className = "CavalrySword"
	self.name = "CavalrySword"
	self.item_image = CavalrySword.Tool_Image
	self.Designation = "Primary"
	self.WeaponCategory = "Melee"
	self.ANIM_LAYERS = ANIM_LAYERS
	self.model_reference = getModelReference()
	self.holster_reference = GunAssets.Holsters:FindFirstChild("cavswordHolster")
		or GunAssets.Holsters:FindFirstChild("CavalrySwordHolster")
	local grip = self.model_reference and self.model_reference.PrimaryPart
	self.motor_6d_data = {
		Parent = "Right Arm",
		Part0 = "Right Arm",
		Part1 = grip,
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
		C1 = CFrame.identity,
	}
	self.animations = {
		Hold = animation({ "held" }, "held"),
		Aim = animation({ "aim" }, "aim"),
		Aim_Dual = animation({ "aim_dual" }, "aim_dual"),
		Aim_Normal = animation({ "aim_normal" }, "aim_normal"),
		Draw = animation({ "draw" }, "draw"),
		Draw_Dual = animation({ "draw_dual" }, "draw_dual"),
		Melee1 = animation({ "melee1" }, "melee1"),
		Melee2 = animation({ "melee2" }, "melee2"),
		Melee_Alt1 = animation({ "melee_alt1" }, "melee_alt1"),
		Melee_Alt2 = animation({ "melee_alt2" }, "melee_alt2"),
		Shoot = animation({ "shoot" }, "shoot"),
		Shoot_Empty = animation({ "shoot_empty" }, "shoot_empty"),
		Sprint = animation({ "sprint" }, "sprint"),
		Sprint_Dual = animation({ "sprint_dual" }, "sprint_dual"),
		Sprint_Normal = animation({ "sprint_normal" }, "sprint_normal"),
		Unequip = animation({ "unequip" }, "unequip"),
	}
	self.animation_speeds = {
		Melee1 = 2,
		Melee2 = 2,
		Melee_Alt1 = 2,
		Melee_Alt2 = 2,
	}
	self.Melee_Damage = SWING_DAMAGE
	self.MeleeRange = 6
	self.Can_Drop = true
	self.DualWielding = false
	self.dualWeapon = nil
	self._nextSwingAt = 0
	self._nextShotAt = 0
	return self
end

function CavalrySword:setDualWieldWeapon(weapon)
	self.dualWeapon = if weapon and weapon.WeaponCategory == "Pistol" then weapon else nil
	self.DualWielding = self.dualWeapon ~= nil
	local animations = self.RegisteredAnimations
	if animations and animations.Draw and animations.Draw_Dual then
		if not self._normalDrawTrack then self._normalDrawTrack = animations.Draw end
		animations.Draw = self.DualWielding and animations.Draw_Dual or self._normalDrawTrack
	end
end

function CavalrySword:_aimTrack(): AnimationTrack?
	local animations = self.RegisteredAnimations
	if not animations then return nil end
	return self.DualWielding and animations.Aim_Dual or animations.Aim_Normal or animations.Aim
end

function CavalrySword:_killAimTracks()
	local animations = self.RegisteredAnimations
	if not animations then return end
	for _, name in ipairs({ "Aim", "Aim_Dual", "Aim_Normal" }) do
		local track = animations[name]
		if track and track.IsPlaying then track:Stop(0.15) end
	end
end

function CavalrySword:_getMeleeAnimationName(index: number): string
	local preferred = self.DualWielding and ("Melee_Alt" .. index) or ("Melee" .. index)
	local animations = self.RegisteredAnimations
	if animations and animations[preferred] then return preferred end
	local normal = "Melee" .. index
	if animations and animations[normal] then return normal end
	if animations then
		for _, fallback in ipairs({ "Melee1", "Melee2", "Melee_Alt1", "Melee_Alt2" }) do
			if animations[fallback] then return fallback end
		end
	end
	return ""
end

function CavalrySword:melee()
	local now = os.clock()
	if now < self._nextSwingAt then return end
	local animationName = self:_getMeleeAnimationName(math.random(1, 2))
	if animationName == "" then
		warn("[CavalrySword] Swing blocked because cavsword_rig has no melee animation")
		return
	end
	self._nextSwingAt = now + SWING_INTERVAL
	BaseTool.melee(self)
end

function CavalrySword:setAltMode()
	-- Alternative actions remain reserved for the handgun's Secondary slot.
end

function CavalrySword:_setupDualWeapon()
	local weapon = self.dualWeapon
	if not weapon or not self.Equipped then return end
	getDualWieldEvent():FireServer(true, weapon.className)
	local character = LOCAL_PLAYER.Character
	local equipment = character and character:FindFirstChild("CharacterData")
		and character.CharacterData:FindFirstChild("Equipment")
	if not equipment then return end
	local model = equipment:FindFirstChild("DualWieldModel") or equipment:WaitForChild("DualWieldModel", 3)
	if not model or not model:IsA("Model") then return end
	weapon.actual_model = model
	weapon.Equipped = true
	weapon:_setupFastCast(FxFolder, function(cast, result, velocity)
		local muzzle = weapon:_findModelPart(weapon.MuzzlePartName)
		weapon:_onBulletHit(cast, result, velocity, muzzle, weapon.Penetration_Level,
			weapon.damage, weapon.KnockBack_Force)
	end)
end

function CavalrySword:_fireDualWeapon()
	local weapon = self.dualWeapon
	if not weapon or not weapon.actual_model or not weapon.Caster then return end
	local now = os.clock()
	local interval = (weapon.FireInterval or 0.75) / DUAL_RPM_MULTIPLIER
	if now < self._nextShotAt then return end
	self._nextShotAt = now + interval
	local animations = self.RegisteredAnimations
	if weapon.Capacity <= 0 then
		if animations and animations.Shoot_Empty then self:_playAnim("Shoot_Empty") end
		return
	end

	local muzzle = weapon:_findModelPart(weapon.MuzzlePartName)
	local camera = workspace.CurrentCamera
	if not muzzle or not muzzle:IsA("BasePart") or not camera then return end
	local mouse = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LOCAL_PLAYER.Character }
	local result = Util.raycastSkipTransparent(ray.Origin, ray.Direction * 1000, params)
	local target = result and result.Position or ray.Origin + ray.Direction * 1000
	local direction = weapon:get_spread(muzzle, (target - muzzle.Position).Unit)
	local cast = weapon.Caster:Fire(muzzle.Position, direction, BULLET_SPEED, weapon.CasterBehavior)
	cast.UserData = {
		Direction = direction, Penetrated = false, Origin = muzzle.Position, Shooter = LOCAL_PLAYER,
	}
	weapon:_connect_FastCast(muzzle.Position, direction, BULLET_SPEED, {
		bulletTemplate = FxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		isPenetration = false,
		penetrationLevel = weapon.Penetration_Level,
		damage = weapon.damage,
		knockbackForce = weapon.KnockBack_Force,
	})
	weapon.Capacity -= 1
	if animations and animations.Shoot then self:_playAnim("Shoot") end
	local sound = weapon.SoundFolder and weapon.SoundFolder:FindFirstChild("fire")
	if sound then weapon:_play_sfx(sound, muzzle) end
	weapon:_fireMuzzleFlash()
	Util.applyRecoil(weapon.recoil, weapon.recoil_count, 10, false, 1)
end

function CavalrySword:activate()
	if self.Aiming and self.DualWielding then
		self:_fireDualWeapon()
	else
		self:melee()
	end
end

function CavalrySword:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()
	if self.DualWielding then task.spawn(function() self:_setupDualWeapon() end) end
end

function CavalrySword:_on_unequip()
	getDualWieldEvent():FireServer(false)
	if self.dualWeapon then
		self.dualWeapon.Equipped = false
		self.dualWeapon.actual_model = nil
	end
	self.Equipped = false
	self.Aiming = false
	self.Meleeing = false
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()
end

CavalrySword.Tool_Image = "rbxassetid://17496049645"
CavalrySword.Medal_Cost = 0
CavalrySword.Weight = 2
CavalrySword.Designation = "Primary"

return CavalrySword
