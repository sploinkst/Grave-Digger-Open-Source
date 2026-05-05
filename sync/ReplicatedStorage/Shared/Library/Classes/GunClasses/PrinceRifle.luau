--!strict
--!native
--!optimize 2

--------------------------------------------------------------------------------
-- PrinceRifle
-- Bolt-action rifle with manual cycling, shoulder-swappable aiming, and an
-- alt (repeating) fire mode that auto-cycles via lever-action animation.
--------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService =  game:GetService("UserInputService")

local Types    = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local Util     = require(script.Parent.Parent.Parent.Util)

--------------------------------------------------------------------------------
-- Asset paths
--------------------------------------------------------------------------------

local Assets      = ReplicatedStorage.Shared.Assets
local SoundFolder = Assets.Guns:WaitForChild("Sounds"):WaitForChild("PrinceRifle")
local HolsterFolder = Assets.Guns.Holsters:FindFirstChild("Gun Holsters")
local ToolFolder  = Assets.Guns.ToolModels
local AnimFolder  = Assets.Animations.Tools.Guns.PrinceRifle
local FxFolder    = Assets.Guns.Effects.Shooting

local FX_MUZZLE_FLASH = FxFolder.Muzzle_Flash

local fire_sound = SoundFolder.fire
--------------------------------------------------------------------------------
-- Tuning
--------------------------------------------------------------------------------

local CYCLE_REST_TIME = 1
local FIRE_RATE       = 0.30
local BULLET_SPEED    = 1000

--------------------------------------------------------------------------------
-- Animation layers
-- Layer 0 = base pose  (Hold, Aim, Aim_Left)
-- Layer 1 = fire/cycle overlay (stops only same-layer peers)
-- Layer 2 = full takeover (Draw, Unequip, Reload*, Alt_Mode*, Check)
--------------------------------------------------------------------------------

local ANIM_LAYERS: { [string]: number } = {
	Hold    = 0,
	Aim     = 0,
	Aim_Left = 0,

	Fire      = 1,
	Fire_Left = 1,
	Cycle     = 1,

	Draw         = 2,
	Unequip      = 2,
	Check        = 2,
	Reload_Empty = 2,
	Reload_Start = 2,
	Reload_Loop  = 2,
	Reload_End   = 2,
	Reload_Alt   = 2,
	Alt_Mode_On  = 2,
	Alt_Mode_Off = 2,
	Melee1  = 2,
	Melee2  = 2,
}

--------------------------------------------------------------------------------
-- Class
--------------------------------------------------------------------------------

local PrinceRifle = {}
PrinceRifle.__index = PrinceRifle
setmetatable(PrinceRifle, { __index = BaseTool })

export type PrinceRifle = typeof(setmetatable({} :: {
	className:   "PrinceRifle",
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
	Check_Delay: 			 number,
	MuzzlePartName:          string,

	Aiming:    boolean,
	Cycled:    boolean,
	Firing:    boolean,
	Cycling:   boolean,
	Reloading: boolean,
	Alt_Mode:  boolean,
	Alting:    boolean,
	Checking: boolean,

	_reloadCancelled: boolean,

	ANIM_LAYERS: { [string]: number },

	current_shoulder: string,

	Caster:         any,
	CasterBehavior: any,

	motor_6d:       Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
}, {} :: typeof(PrinceRifle)))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function PrinceRifle.new(info: Types.BaseToolCreateInfo): PrinceRifle
	local self = setmetatable(BaseTool.new(info), PrinceRifle)
	self.className   = "PrinceRifle"
	self.item_image  = "rbxassetid://17496049645"
	self.Designation = "Primary"
	self.ANIM_LAYERS = ANIM_LAYERS

	self.holster_reference = HolsterFolder and HolsterFolder:FindFirstChild("PrinceRifleHolster")
	self.model_reference   = ToolFolder:FindFirstChild("PrinceRifle")
	self.Round             = Assets.Guns.Rounds.PrinceRifle_Round

	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0  = "Left Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("PrinceRifle_Middle"),
		C0     = CFrame.new(0.254, -1.703, -0.566)
			* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90)),
	}

	self.animations = {
		Draw    = AnimFolder.PrinceRifle_Draw,
		Hold    = AnimFolder.PrinceRifle_Held,
		Unequip = AnimFolder.PrinceRifle_Unequip,

		Aim      = AnimFolder.PrinceRifle_Aim,
		Aim_Left = AnimFolder.PrinceRifle_Aim_Left,

		Fire      = AnimFolder.PrinceRifle_Fire,
		Fire_Left = AnimFolder.PrinceRifle_Fire_Left,

		Cycle = AnimFolder.PrinceRifle_Reload_Alt, 

		Reload_Empty = AnimFolder.PrinceRifle_Reload_Empty,
		Reload_Start = AnimFolder.PrinceRifle_Reload_Start,
		Reload_Loop  = AnimFolder.PrinceRifle_Reload_Loop,
		Reload_End   = AnimFolder.PrinceRifle_Reload_End,
		Reload_Alt   = AnimFolder.PrinceRifle_Cycle,

		Alt_Mode_On  = AnimFolder.PrinceRifle_Alt_Mode_On,
		Alt_Mode_Off = AnimFolder.PrinceRifle_Alt_Mode_Off,

		Check = AnimFolder.PrinceRifle_Check,

		Melee1 = AnimFolder.PrinceRifle_Melee1,
		Melee2 = AnimFolder.PrinceRifle_Melee2,
		
		Drop = AnimFolder.Parent.Parent.Misc.Drop_Rifle,
		
		Short = AnimFolder.PrinceRifle_Short,
	}

	self.damage                  = 105
	self.Max_Capacity            = 10
	self.Capacity                = 10
	self.Ammo_Type               = "8mm Smokeless"
	self.recoil                  = 10
	self.recoil_count            = 6
	self.Penetration_Level       = 2
	self.Armor_Penetration_Level = 3
	self.KnockBack_Force         = 10
	self.Aiming_Number           = 100
	self.Check_Delay			 = 1
	self.MuzzlePartName          = "PrinceRifle_Muzzle"
	self.Can_Drop 				 = true
	self.SoundFolder 			 = SoundFolder
	self.Short_Distance			 = 2.3

	self.unequip_wait     = false
	self.Cycled           = true
	self.Firing           = false
	self.Cycling          = false
	self.Reloading        = false
	self.Alt_Mode         = true
	self.Alting           = false
	self._reloadCancelled = false
	self.Checking		  = false
	self.Check_Delayed 	  = false
	self.Meleeing		  = false

	self:_initShoulderTracking()

	return self
end

--------------------------------------------------------------------------------
-- Private: key bindings (extends BaseTool defaults)
--------------------------------------------------------------------------------

function PrinceRifle:_getKeyBindings()
	local base = BaseTool._getKeyBindings(self)
	base.AltMode = Enum.KeyCode.Q
	return base
end

-- Called by BaseTool._connectInput when Q is pressed.
function PrinceRifle:AltMode()
	self:setAltMode()
end

--------------------------------------------------------------------------------
-- Private: isBusy (includes Alting)
--------------------------------------------------------------------------------

function PrinceRifle:_isBusy(): boolean
	return self.Firing or self.Cycling or self.Reloading or self.Alting
end

--------------------------------------------------------------------------------
-- Public: Actions
--------------------------------------------------------------------------------

function PrinceRifle:setAltMode()
	if self:_isBusy() then return end
	self.Alting = true

	local anims = self.RegisteredAnimations
	self:_stopAllExcept()

	if self.Alt_Mode then
		anims.Alt_Mode_Off:Play()
		anims.Alt_Mode_Off.Stopped:Wait()
		self.Alt_Mode = false
		self:notify("Firemode: Single Fire")
	else
		anims.Alt_Mode_On:Play()
		anims.Alt_Mode_On.Stopped:Wait()
		self.Alt_Mode = true
		self:notify("Firemode: Repeating Fire")
	end

	self.Alting = false
	self:_restoreBase()
end

function PrinceRifle:cycle()
	if self.Cycling then return end
	if self.Alt_Mode then return end
	self.Cycling = true

	local anims = self.RegisteredAnimations
	if not anims then self.Cycling = false; print("Anims not found.") return end

	self:_stopAllExcept()
	anims.Cycle:Play(0.15)
	task.delay(CYCLE_REST_TIME, function()

		self.Cycled  = true
		self.Cycling = false  

		self:_restoreBase()
	end)
end

function PrinceRifle:fire()
	if self.Capacity <= 0 then
		self:reload()
		return
	end
	if self.Firing then return end
	self.Firing = true

	if self:_if_sprinting() then
		self.Firing = false
		return
	end

	local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName)
	if not muzzle then
		self.Firing = false
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		self.Firing = false
		return
	end

	if self.ForceBlockFire == true then
		self.Firing = false
		return
	end
	-- === AIMLOGIC ===

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)

	local shootDir = (targetPos - muzzle.Position).Unit

	-- === FIRE ===
	if self.Alt_Mode then
		self:_play_sfx(fire_sound, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.5)
	else
		self:_play_sfx(fire_sound, self.actual_model:WaitForChild(self.MuzzlePartName))
	end

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, BULLET_SPEED, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false


	self:_connect_FastCast(muzzle.Position, shootDir, BULLET_SPEED, {
		bulletTemplate = FxFolder.Bullet,
		bulletContainer = workspace.Game_Details.Effects.Bullets,
		isPenetration = false,
		penetrationLevel = self.Penetration_Level,
		damage = self.damage,
		knockbackForce = self.KnockBack_Force
	})

	self.Cycled   = false
	self.Capacity -= 1

	local anims    = self.RegisteredAnimations
	local fireAnim = (self.current_shoulder == "Right") and anims.Fire or anims.Fire_Left
	fireAnim:Play()
	

	Util.applyRecoil(self.recoil, self.recoil_count, 10, false)

	-- Muzzle flash
	self:_fireMuzzleFlash()
	


	task.wait(FIRE_RATE)
	self.Firing = false
	self:_restoreBase()

	if self.Alt_Mode then
		self:_altReload()
	end
end

function PrinceRifle:melee()
	if self.Meleeing then return end
	self.Meleeing = true
	local random_animation = math.random(1, 2)

	local anims = self.RegisteredAnimations
	self:_stopAllExcept()
	anims["Melee"..random_animation]:Play()
	anims["Melee"..random_animation].Stopped:Wait()
	self.Meleeing = false
	self:_restoreBase()
end

function PrinceRifle:_altReload()
	local anims = self.RegisteredAnimations
	self:_stopAllExcept()
	anims.Reload_Alt:Play()
	anims.Reload_Alt.Stopped:Wait()
	self.Cycled   = true
	self.Capacity += 1
	self:_restoreBase()
end

function PrinceRifle:reload()
	if self.Reloading then return end
	if self.Capacity >= self.Max_Capacity then return end

	if self.Aiming then self:endAiming() end

	self:_stopAllExcept()
	self.Reloading        = true
	self._reloadCancelled = false

	local anims = self.RegisteredAnimations

	if self.Capacity == 0 then
		anims.Reload_Empty:Play()
		anims.Reload_Empty.Stopped:Wait()
	else
		anims.Reload_Start:Play()
		anims.Reload_Start.Stopped:Wait()
	end

	while self.Capacity < self.Max_Capacity and not self._reloadCancelled do
		anims.Reload_Loop:Play()
		anims.Reload_Loop.Stopped:Wait()
		if self._reloadCancelled then break end

		self.Capacity += 1

		if not self.Cycled then
			self:cycle()
		end
	end

	if not self._reloadCancelled then
		anims.Reload_End:Play()
		anims.Reload_End.Stopped:Wait()
	else
		for _, name in ipairs({ "Reload_Loop", "Reload_Start", "Reload_Empty" }) do
			local t = anims[name]
			if t and t.IsPlaying then t:Stop(0.15) end
		end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBase()
end

function PrinceRifle:activate()
	if not self.actual_model then return end
	if self:_isBusy() then return end

	if not self.Cycled then
		task.spawn(function() self:cycle() end)
		return
	end

	if self.Aiming then
		if self.Cycling then 
			print("Cycling, cancelling activate")
			return
		else
			print("Activating, self.Cycling is:", self.Cycling)
		end

		task.spawn(function() self:fire() end)
	else
		self:melee()
	end
end

--------------------------------------------------------------------------------
-- BaseTool lifecycle hooks
--------------------------------------------------------------------------------

function PrinceRifle:_on_equip()
	self.Equipped = true
	self:_cacheMotor6D()
	self:_connectInput()
	self:_initShoulderTracking()

	local char = game.Players.LocalPlayer.Character
	char:SetAttribute("Sprint_Animation", "PrinceRifle")

	-- Setup FastCast
	self:_setupFastCast(FxFolder, function(cast, result, velocity)
		local muzzle = self.actual_model and self.actual_model:FindFirstChild(self.MuzzlePartName)
		self:_onBulletHit(
			cast, result, velocity,
			muzzle,
			self.Penetration_Level,
			self.damage,
			self.KnockBack_Force
		)
	end)

	-- Keyframe-driven round visibility
	for _, track in pairs(self.RegisteredAnimations) do
		if not track:IsA("AnimationTrack") then continue end
		track.KeyframeReached:Connect(function(keyframe)
			local rightArm = char:FindFirstChild("Right Arm")
			if not rightArm then return end
			local round = rightArm:FindFirstChild(self.Round.Name)
			if not round then return end
			if keyframe == "vfx_hand_shell_visible" then
				round.Transparency = 0
			elseif keyframe == "vfx_hand_shell_invisible" then
				round.Transparency = 1
			end
			
			if keyframe:sub(1,4) == "sfx_" then
				local soundName = keyframe:sub(5)
				local sound = SoundFolder:FindFirstChild(soundName)
				if sound then
					-- For Lebel fire sounds
					self:_play_sfx(sound, self.actual_model:WaitForChild(self.MuzzlePartName), nil, 0.1)
				else
					warn("Sound not found for keyframe:", soundName)
				end
			end
		end)
	end
end

function PrinceRifle:_on_unequip()
	self.Equipped         = false
	self._reloadCancelled = true

	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()

	self.Aiming    = false
	self.Cycled    = true
	self.Firing    = false
	self.Cycling   = false
	self.Reloading = false
	self.Alt_Mode  = false
	self.Alting    = false

	local char = game.Players.LocalPlayer.Character
	if char then
		char:SetAttribute("Aiming", false)
		char:SetAttribute("Sprint_Animation", nil)
	end
end

--------------------------------------------------------------------------------
-- Cleanup
--------------------------------------------------------------------------------

function PrinceRifle:Destroy()
	self:_disconnectInput()
	BaseTool.destroy(self)
end

--------------------------------------------------------------------------------
-- Static metadata
--------------------------------------------------------------------------------

PrinceRifle.Tool_Image = "rbxassetid://17496049645"
PrinceRifle.Medal_Cost = 0
PrinceRifle.Weight     = 2

return PrinceRifle