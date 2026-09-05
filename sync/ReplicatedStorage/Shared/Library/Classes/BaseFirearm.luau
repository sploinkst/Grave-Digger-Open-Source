--!native
--!optimize 2

-- Firearm-only behavior shared by rifle and pistol category bases.
-- This class is not meant to be used directly, but rather as a base for other firearm classes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local BaseTool = require(script.Parent.BaseTool)
local utilities_module = require(ReplicatedStorage.Shared.Library.Util)
local replicant_service = require(ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService)

local LOCAL_PLAYER = game:GetService("Players").LocalPlayer
local events = ReplicatedStorage.Shared.Library.Events
local fast_cast_replication = events.FastCast
local hit_connection = events.Hit
local vfx_cast_event = events.VFX
local texture_event = events.Texture
local casing_event = events.Casing
local ammo_communication = events.Ammo
local FX_BULLET_HOLE = ReplicatedStorage.Shared.Assets.Guns.Effects.BulletHole
local CUT = 0.15
local MIN_AMMO_CHECK_DISPLAY_TIME = 1

local BaseFirearm = {}
BaseFirearm.__index = BaseFirearm
setmetatable(BaseFirearm, { __index = BaseTool })

export type BaseFirearm = BaseTool.BaseTool

function BaseFirearm.new(info): BaseFirearm
	local self = BaseTool.new(info) :: any
	self.AnimationDrivenGrip = false
	-- Shared rifle mount matches Prince's original scripted attachment.
	self.DefaultGripC0 = CFrame.new(0.254, -1.703, -0.566)
		* CFrame.Angles(math.rad(0.979), math.rad(-90), math.rad(90))
	return setmetatable(self, BaseFirearm)
end

-- Optional empty variants are shared behavior, even for guns with explicit
-- animation tables. Capacity is magazine ammo; reserves never select a pose.
function BaseFirearm:_prepareAnimations()
	local folders = ReplicatedStorage:FindFirstChild("ToolAnimations")
	local source = folders and self.AnimationGunType and folders:FindFirstChild(self.AnimationGunType)
	if not source or not self.animations then return end
	local resolve = require(script.Parent.GunClasses.AnimationResolver)(self.AnimationGunType)
	for key, clipName in {Draw = "draw", Reload_Empty = "reload_empty", Check_Empty = "check_empty"} do
		if not self.animations[key] and source:FindFirstChild(clipName, true) then
			self.animations[key] = resolve({clipName}, clipName)
		end
	end
	if self.ANIM_LAYERS then
		self.ANIM_LAYERS = table.clone(self.ANIM_LAYERS)
		self.ANIM_LAYERS.Reload_Empty = self.ANIM_LAYERS.Reload_Start or 2
		self.ANIM_LAYERS.Check_Empty = self.ANIM_LAYERS.Check or 2
	end
end

function BaseFirearm:_magazineAnimation(name: string): string
	local emptyName = if name == "Reload_Start" or name == "Reload_Alt" then "Reload_Empty"
		elseif name == "Check" then "Check_Empty" else nil
	if self.Capacity == 0 and emptyName and self.RegisteredAnimations and self.RegisteredAnimations[emptyName] then
		return emptyName
	end
	return name
end

function BaseFirearm:_playAnim(name: string, bypassEquipped: boolean?)
	return BaseTool._playAnim(self, self:_magazineAnimation(name), bypassEquipped)
end

function BaseFirearm:_onBulletHit(cast, result, velocity, muzzle, penetrationLevel, damage, knockback_force)
	if not result then return end

	local instance  = result.Instance
	local direction = cast.UserData.Direction :: Vector3

	local hitModel    = instance:FindFirstAncestorOfClass("Model")
	local isCharacter = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

	if isCharacter then
		-- Apply damage to the character.
		self:_applyHit(result, damage, direction, knockback_force, cast.UserData)
		return
	end

	self:_applyHit(result, damage, direction, knockback_force, cast.UserData)

	-- // if roblox terrain return
	if instance:IsDescendantOf(workspace.Terrain) then
		return
	else	
		--	self:bullet_hole(result.Position, result.Normal)
	end
end

function BaseFirearm:_applyHit(result: RaycastResult, damage: number, direction: Vector3, knockback_force: number, metadata: any?)
	if not result then return end
	hit_connection:FireServer({
		Position  = result.Position,
		Normal    = result.Normal,
		Instance  = result.Instance,
		Material  = result.Material,
		Direction = direction,
		WeaponName = self.className,
		ArmorPenetration = self.Armor_Penetration_Level,
		HeadshotMultiplier = self.HeadshotMultiplier,
		ShotId = metadata and metadata.ShotId,
		PelletIndex = metadata and metadata.PelletIndex,
		PelletCount = metadata and metadata.PelletCount,
	}, damage, knockback_force)
end

-- // FastCast setup

function BaseFirearm:_setupFastCast(fxFolder: Folder, onHitCallback: (any, RaycastResult, Vector3) -> ())
	local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
	self.Caster, self.CasterBehavior = Util.setupFastCast({
		bulletTemplate   = fxFolder.Bullet,
		bulletContainer  = workspace.Game_Details.Effects.Bullets,
		penetrationLevel = self.Penetration_Level or 1,
		onHit            = onHitCallback,
	})
end

-- // Projectile firing

function BaseFirearm:_fireProjectile(bulletSpeed, penetrationLevel, damage, knockbackForce): boolean
	if self:_if_sprinting() or self:_if_jumping() then return false end

	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then warn(self.className .. ": Muzzle not found") return false end

	local camera = workspace.CurrentCamera
	if not camera then return false end

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LOCAL_PLAYER.Character }

	-- Use the shared skip-transparent helper so invisible walls between the
	-- camera and the target don't deflect the aimed direction.
	local result    = utilities_module.raycastSkipTransparent(ray.Origin, ray.Direction * 1000, raycastParams)
	local targetPos = result and result.Position or (ray.Origin + ray.Direction * 1000)
	local shootDir  = (targetPos - muzzle.Position).Unit

	local activeCast = self.Caster:Fire(muzzle.Position, shootDir, bulletSpeed, self.CasterBehavior)
	activeCast.UserData.Direction  = shootDir
	activeCast.UserData.Penetrated = false
	activeCast.UserData.Origin     = muzzle.Position
	activeCast.UserData.Shooter    = LOCAL_PLAYER

	self:_connect_FastCast(muzzle.Position, shootDir, bulletSpeed)
	return true
end

-- // Muzzle flash

function BaseFirearm:emit_effect(effect, CFrame_Value, emissions, parent, attach_to_parent)
	for _, child in ipairs(effect:GetDescendants()) do
		local emit_count = emissions[child.Name]

		if not emit_count then
			continue
		end

		local clone = child:Clone()

		if attach_to_parent then
			clone.Parent = parent

			if clone:IsA("ParticleEmitter") then
				clone.Enabled = true
				clone:Emit(emit_count)

				task.delay(clone.Lifetime.Max + 0.1, function()
					if clone then
						clone:Destroy()
					end
				end)
			end

			continue
		end


		local part = Instance.new("Part")
		part.Size = Vector3.new(0.05, 0.05, 0.05)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.CFrame = CFrame_Value
		part.Parent = workspace


		clone.Parent = part

		if clone:IsA("ParticleEmitter") then
			clone.Enabled = true
			clone:Emit(emit_count)

			task.delay(clone.Lifetime.Max + 0.1, function()
				if part then
					part:Destroy()
				end
			end)
		end
	end

	vfx_cast_event:FireServer(
		effect,
		CFrame_Value,
		emissions,
		parent,
		attach_to_parent
	)
end

-- // Generic reload sequence

function BaseFirearm:_reloadSequence(startAnimName, loopAnimName, endAnimName, onLoopCallback, maxAmmo, currentAmmo): boolean
	if self.Reloading or currentAmmo >= maxAmmo then return false end

	self:_stopAllExcept()
	self.Reloading        = true
	self._reloadCancelled = false

	local anims = self.RegisteredAnimations
	if not anims then self.Reloading = false; return false end

	if startAnimName then startAnimName = self:_magazineAnimation(startAnimName) end
	if startAnimName and anims[startAnimName] then
		self:_playAnim(startAnimName).Stopped:Wait()
	end

	while currentAmmo < maxAmmo and not self._reloadCancelled do
		if loopAnimName and anims[loopAnimName] then
			self:_playAnim(loopAnimName).Stopped:Wait()
		end
		if self._reloadCancelled then break end
		currentAmmo += 1
		if onLoopCallback then onLoopCallback(currentAmmo) end
	end

	if not self._reloadCancelled then
		if endAnimName and anims[endAnimName] then
			self:_playAnim(endAnimName).Stopped:Wait()
		end
	else
		for _, name in ipairs({ startAnimName, loopAnimName, endAnimName }) do
			if name and anims[name] and anims[name].IsPlaying then anims[name]:Stop(CUT) end
		end
	end

	self.Reloading        = false
	self._reloadCancelled = false
	self:_restoreBaseDeferred()
	return true
end

-- // Replication

function BaseFirearm:_connect_FastCast(...)
	fast_cast_replication:FireServer(...)
end

function BaseFirearm:_play_sfx(...)
	replicant_service.ConnectSfx(LOCAL_PLAYER, ...)
end

function BaseFirearm:_fire_ammo(count)
	ammo_communication:FireServer(self.tool, count or 1)
	print("Firing ammo:", count)
end

-- // Aiming UI

function BaseFirearm:_enable_aiming_ui(max_aiming: number)
	local aiming_gui = game.Players.LocalPlayer.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = false
	aiming_gui.Scoped_In.Visible = true

	local scoped = aiming_gui.Scoped_In.main
	local down, left, right, up = scoped.down, scoped.left, scoped.right, scoped.up

	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
	local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
	if not root or not humanoid or character ~= game.Players.LocalPlayer.Character then
		return
	end

	if self.character_connection then
		self.character_connection:Disconnect()
	end

	local fixedSpread = self.FixedAimingSpread
	local currentSpread = fixedSpread or 0

	self.character_connection = RunService.RenderStepped:Connect(function()
		if not root or not humanoid then
			return
		end

		local holdingBreath = character:GetAttribute("HoldBreathe") == true
		local targetSpread

		if fixedSpread then
			targetSpread = fixedSpread
		elseif holdingBreath then
			if not self._breathStartTime then
				self._breathStartTime = tick()
				self._spreadAtBreath = currentSpread
			end

			local breathHeldFor = tick() - self._breathStartTime
			local windUp = math.clamp(breathHeldFor / 0.5, 0, 1)

			local breathBonus = 5

			targetSpread = (self._spreadAtBreath or currentSpread)
				+ ((-breathBonus) - (self._spreadAtBreath or currentSpread)) * windUp
		else
			self._breathStartTime = nil
			self._spreadAtBreath = nil

			local speed = Vector3.new(
				root.AssemblyLinearVelocity.X,
				0,
				root.AssemblyLinearVelocity.Z
			).Magnitude

			local alpha = (humanoid.WalkSpeed > 0)
				and math.clamp(speed / humanoid.WalkSpeed, 0, 1)
				or 0

			targetSpread = alpha * max_aiming
		end

		currentSpread = currentSpread + (targetSpread - currentSpread) * 0.3

		local offset = math.max(1, 5 + currentSpread)

		up.Position    = UDim2.new(0.5, 0, 0, -offset)
		down.Position  = UDim2.new(0.5, 0, 1, offset)
		left.Position  = UDim2.new(0, -offset, 0.5, 0)
		right.Position = UDim2.new(1, offset, 0.5, 0)
	end)
end

function BaseFirearm:_bounce_scoped_ui()
	local Scoped_In = LOCAL_PLAYER.PlayerGui.Aiming.Scoped_In
	local main = Scoped_In.main

	local currentSize = main.Size.X.Offset
	local kickSize = currentSize + 40

	TweenService:Create(main, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, kickSize, 0, kickSize)
	}):Play()

	task.delay(0.03, function()
		TweenService:Create(main, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, currentSize, 0, currentSize)
		}):Play()
	end)
end

function BaseFirearm:_disable_aiming_ui()
	local aiming_gui = LOCAL_PLAYER.PlayerGui.Aiming
	aiming_gui.Regular_Crosshair.Visible = true
	aiming_gui.Scoped_In.Visible = false
	if self.character_connection then
		self.character_connection:Disconnect()
		self.character_connection = nil
	end
end

-- // Notifications


function BaseFirearm:end_ammo_check(force: boolean?)
	local displayId = self._ammoCheckDisplayId
	local shownAt = self._ammoCheckShownAt
	local remaining = force and 0
		or math.max(0, MIN_AMMO_CHECK_DISPLAY_TIME - (shownAt and (os.clock() - shownAt) or 0))

	local function finishAmmoCheck()
		if not force and (self._ammoCheckHeld or displayId ~= self._ammoCheckDisplayId) then return end

		local checkTrack = self._ammoCheckTrack
		if self._ammoCheckPaused and checkTrack and checkTrack.IsPlaying then
			self._ammoCheckPaused = false
			checkTrack:AdjustSpeed(self.animation_speeds and self.animation_speeds[self._ammoCheckAnimationName] or 1)
		end

		if self._ammoCheckUtils and type(self._ammoCheckUtils.hide) == "function" then
			task.spawn(self._ammoCheckUtils.hide)
		end
	end

	if force then
		finishAmmoCheck()
	else
		task.delay(remaining, finishAmmoCheck)
	end
end

function BaseFirearm:ammo_check()
	local checkName = self:_magazineAnimation("Check")
	if not self.RegisteredAnimations or not self.RegisteredAnimations[checkName] then return end
	if self:_isBusy() or self.Checking or self.Check_Delayed then return end
	if self.Equipping then return end
	if not self.Equipped then return end

	local reserveAmmo = self.tool:FindFirstChild("Reserve_Ammo")
	if not reserveAmmo then
		warn("BaseTool: Cannot check ammo because Reserve_Ammo is missing from", self.tool:GetFullName())
		return
	end

	local actualModel = self.actual_model
	if not actualModel then
		warn("BaseTool: Cannot check ammo because the equipped model is missing for", self.className)
		return
	end

	local ammoCheckPartName = self.AmmoCheckPartName or self.className .. "_Middle"
	local middle = actualModel:FindFirstChild(ammoCheckPartName, true)
		or actualModel.PrimaryPart
		or actualModel:FindFirstChildWhichIsA("BasePart", true)
	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then
		for _, descendant in ipairs(actualModel:GetDescendants()) do
			if descendant:IsA("BasePart") and string.find(string.lower(descendant.Name), "muzzle", 1, true) then
				muzzle = descendant
				break
			end
		end
	end
	if not middle or not middle:IsA("BasePart") then
		warn("BaseFirearm: Cannot check ammo because the equipped model has no usable parts for", self.className)
		return
	end
	if not muzzle or not muzzle:IsA("BasePart") then
		-- The ammo display only needs a stable weld target. Some cosmetic model
		-- variants omit their dedicated muzzle marker, so use the body part.
		muzzle = middle
	end

	self:_set_sprint_arms(true)
	self.Checking     = true
	self.Check_Delayed = true
	self._ammoCheckDisplayId = (self._ammoCheckDisplayId or 0) + 1

	local ammo_check_part, ammo_check_utils
	local cam = workspace.CurrentCamera
	if not cam:FindFirstChild("Ammo_Check") then
		ammo_check_part  = game.ReplicatedStorage.Shared.Assets.Guns.Effects.Ammo_Check:Clone()
		ammo_check_part.Parent = cam
		ammo_check_utils = require(ammo_check_part.Utils)
	else
		ammo_check_part  = cam.Ammo_Check
		ammo_check_utils = require(cam.Ammo_Check.Utils)
	end
	self._ammoCheckUtils = ammo_check_utils

	self:_stopLayer(1)
	self:_killAimTracks()
	if self.RegisteredAnimations.Hold and self.RegisteredAnimations.Hold.IsPlaying then
		self.RegisteredAnimations.Hold:Stop(CUT)
	end

	local checkTrack = self.RegisteredAnimations[checkName]
	self._ammoCheckTrack = checkTrack
	self._ammoCheckAnimationName = checkName
	self._ammoCheckPaused = false
	checkTrack:AdjustWeight(1)
	self:_playAnim(checkName)

	-- Leave enough of the animation after this point to close and recock the gun.
	-- Releasing the ammo-check key before this point simply lets it finish normally.
	task.delay(self.AmmoCheckHoldTime or 0.65, function()
		if self.Checking and self._ammoCheckHeld and checkTrack.IsPlaying then
			self._ammoCheckPaused = true
			checkTrack:AdjustSpeed(0)
		end
	end)

	ammo_check_part.CFrame = middle.CFrame + middle.CFrame.rightVector * -0.5 + middle.CFrame.upVector * 1


	if not ammo_check_part:FindFirstChild("WeldConstraint") then
		local weld   = Instance.new("WeldConstraint")
		weld.Part0   = ammo_check_part
		weld.Part1   = muzzle
		weld.Parent  = ammo_check_part
	end

	ammo_check_utils.utils(self.Ammo_Type, math.clamp(self.Capacity / self.Max_Capacity, 0, 1),
		false, reserveAmmo.Value / (self.Max_Capacity * 3))
	self._ammoCheckShownAt = os.clock()
	if not self._ammoCheckHeld then
		self:end_ammo_check()
	end

	checkTrack.Stopped:Wait()

	self._ammoCheckPaused = false
	self.Checking = false
	self:_restoreBase()
	self:_set_sprint_arms(false)

	task.delay(self.Check_Delay or 1, function()
		self.Check_Delayed = false
	end)
end


function BaseFirearm:_fireMuzzleFlash()
	if not self.FireEmissions then return end
	if not self.actual_model then return end

	local muzzle = self:_findModelPart(self.MuzzlePartName or "Muzzle")
	if not muzzle then return end

	local emissions = {}

	for effect, value in pairs(self.FireEmissions) do
		if type(value) == "table" and value.chance then
			if math.random() <= value.chance then
				emissions[effect] = value.count
			end

		elseif type(value) == "function" then
			emissions[effect] = value()

		else
			emissions[effect] = value
		end
	end

	if math.random(1, 2) == 1 then
		emissions.flash = 1
		emissions.flash_general = 1
	end

	self:emit_effect(
		ReplicatedStorage.Shared.Assets.Guns.Effects.Muzzle_Flash,
		muzzle.CFrame * CFrame.new(-0.1, 0, -2),
		emissions,
		muzzle,
		false
	)
end

function BaseFirearm:bullet_hole(position: Vector3, normal: Vector3)
	local folder = workspace.Game_Details.Effects.BulletHoles
	local clone  = FX_BULLET_HOLE:Clone()
	clone.CFrame = CFrame.new(position, position + normal)
	clone.Parent = folder
	texture_event:FireServer(FX_BULLET_HOLE, position, normal, folder)
end

function BaseFirearm:emit_casing(casing: Part, origin: CFrame, direction: Vector3)
	print("Fired casing event with:", casing.Name, origin, direction)
	replicant_service.HandleCasingReplication(LOCAL_PLAYER, casing, origin, direction)
	casing_event:FireServer(casing, origin, direction)
end

-- // Stubs


return BaseFirearm
