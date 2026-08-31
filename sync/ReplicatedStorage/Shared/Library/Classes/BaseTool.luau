-----------------------
--@Praxitos
--BaseTool
------------------------

--!native
--!optimize 2

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local Types            = require(script.Parent.Parent.Types)
local utilities_module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA       = workspace.CurrentCamera

local Assets   = ReplicatedStorage.Shared.Assets
local FxFolder = Assets.Guns.Effects

local events_replication_folder     = ReplicatedStorage.Shared.Library.Events

local SettingsManager = require(ReplicatedStorage.Shared.Modules["Client Modules"].SettingsManager)

local gun_communication  = events_replication_folder
local drop_connection    = gun_communication.DropWeapon
local melee_communication = events_replication_folder.Melee

local general_sfx        = ReplicatedStorage.Shared.Assets.Guns.Sounds.Shared
local bullet_warning_part = ReplicatedStorage.Shared.Assets.UI.Warning_Barrel

-- // Tuning

local AIM_LERP_ALPHA   = 0.1
local MOTOR_LERP_ALPHA = 0.15
local MOTOR_SNAP_DIST  = 0.001
local CUT              = 0.15
local CHARACTER_TRANSPARENCY = 0.95

-- // Class

local BaseTool = {}
BaseTool.__index = BaseTool

export type BaseTool = typeof(setmetatable({} :: {
	className: "BaseTool",
	name: string,
	tool: Tool?,
	model_reference: Model?,
	actual_model: Model?,
	holster_reference: Instance?,
	actual_holster: Model?,
	animations: { [string]: Animation }?,
	RegisteredAnimations: { [string]: AnimationTrack }?,
	ANIM_LAYERS: { [string]: number }?,
	motor_6d_data: {
		Parent: string,
		Part0: string,
		Part1: string | BasePart,
		C0: CFrame,
		C1: CFrame?,
		UseRightGripAttachment: boolean?,
		ReloadGripC0: CFrame?,
		ReloadGripC1: CFrame?,
	}?,
	motor_6d: Motor6D?,
	_motorOriginal: { C0: CFrame, C1: CFrame, Part0: BasePart?, Part1: BasePart? }?,
	current_shoulder: string,
	Aiming: boolean,
	_aimVersion: number,
	_aimConnection: RBXScriptConnection?,
	Firing: boolean,
	Reloading: boolean,
	Cycling: boolean,
	Alting: boolean,
	Spinning: boolean,
	Checking: boolean,
	Meleeing: boolean,
	_activationConnection: RBXScriptConnection?,
	_drawStoppedConnection: RBXScriptConnection?,
	_inputBeganConn: RBXScriptConnection?,
	_inputEndedConn: RBXScriptConnection?,
	_shoulderChangedConn: RBXScriptConnection?,
	character_connection: RBXScriptConnection?,
	Caster: any?,
	CasterBehavior: any?,
	Equipped: boolean?,
	Equipping: boolean?,
}, {} :: typeof(BaseTool)))

-- // Constructor

function BaseTool.new(BaseToolCreateInfo: Types.BaseToolCreateInfo): BaseTool
	local self = setmetatable({}, BaseTool)

	self.className = "BaseTool"
	self.name      = BaseToolCreateInfo.name

	self.tool           = nil
	self.actual_model   = nil
	self.actual_holster = nil
	self.RegisteredAnimations = nil

	self.Aiming           = false
	self._aimVersion      = 0
	self.current_shoulder = "Right"

	self.Firing    = false
	self.Reloading = false
	self.Cycling   = false
	self.Alting    = false
	self.Spinning  = false
	self.Checking  = false
	self.Meleeing  = false

	self.Equipped  = false
	self.Equipping = false

	self.ForceBlockFire = false

	self._activationConnection = nil
	self._drawStoppedConnection = nil
	self._inputBeganConn       = nil
	self._inputEndedConn       = nil
	self._shoulderChangedConn  = nil
	self._aimConnection        = nil
	self._shortTrack           = nil
	self._shortActive          = false
	self._shortAlpha           = 0

	self.Caster         = nil
	self.CasterBehavior = nil
	self.keyframe_connections = {}

	return self
end

-- // on_give

function BaseTool:on_give(tool: Tool, holster: Model?, model: Model?)
	self.tool = tool

	if self.animations then
		self.RegisteredAnimations = utilities_module.register_animations(LOCAL_PLAYER, self.animations)
		if not self.RegisteredAnimations then
			warn("[" .. self.className .. "] Failed to register animations")
		end

		-- Saved KeyframeSequences retain their authoring loop/priority settings,
		-- which are not necessarily correct for runtime weapon actions. Persistent
		-- poses loop; every action must finish so it cannot leave _isBusy() stuck.
		if self.RegisteredAnimations then
			for animName, track in pairs(self.RegisteredAnimations) do
				local persistent = animName == "Hold" or animName == "Aim" or animName == "Aim_Left"
					or animName == "Hip_Hold" or animName == "Hip_Aim" or animName == "Hip_Aim_Left"
					or animName == "Charge"
				track.Looped = persistent

				if animName == "Hold" then
					track.Priority = Enum.AnimationPriority.Action
				elseif animName == "Aim" or animName == "Aim_Left"
					or animName == "Hip_Aim" or animName == "Hip_Aim_Left" then
					track.Priority = Enum.AnimationPriority.Action2
				elseif animName == "Fire" or animName == "Fire_Left"
					or animName == "Recoil" or animName == "Recoil_Left"
					or animName == "Cycle" or animName == "Short" then
					track.Priority = Enum.AnimationPriority.Action3
				else
					track.Priority = Enum.AnimationPriority.Action4
				end
			end
		end

		if self.animation_speeds then
			for animName, speed in pairs(self.animation_speeds) do
				print(animName, speed)
				local track = self.RegisteredAnimations[animName]
				if track then
					print("Adjusting speed for:", track)
					track:AdjustSpeed(speed)
				else
					warn("Animation '" .. animName .. "' not found for speed adjustment")
				end
			end
		end
	end

	if self._activationConnection then
		self._activationConnection:Disconnect()
	end
	self._activationConnection = tool.Activated:Connect(function()
		self:activate()
	end)

	if self._on_give then
		self:_on_give(tool, holster, model)
	end
end

-- // Short mechanic

function BaseTool:GetBarrelWarningPart()
	local clone = bullet_warning_part:Clone()
	clone.CanQuery = false

	local hitAttach = Instance.new("Attachment")
	hitAttach.Name = "HitWarningAttach"
	hitAttach.Parent = clone
	clone:SetAttribute("HitAttachName", hitAttach.Name)

	return clone
end

local function raycastIgnoringCharactersAndInvisible(origin, direction, params)
	local ignoreList = table.clone(params.FilterDescendantsInstances or {})

	while true do
		params.FilterDescendantsInstances = ignoreList

		local result = workspace:Raycast(origin, direction, params)

		if not result then
			return nil
		end

		local hit = result.Instance

		local model = hit:FindFirstAncestorOfClass("Model")
		if model and Players:GetPlayerFromCharacter(model) then
			table.insert(ignoreList, model)
			continue
		end

		if hit.Transparency >= 1 and not hit:GetAttribute("Unpiercable") then
			table.insert(ignoreList, hit)
			continue
		end

		return result
	end
end

function BaseTool:clearMuzzleFX()
	if self.warning_beam then
		self.warning_beam.Enabled = false
	end

	if self.billboard_ui then
		self.billboard_ui.Enabled = false
	end

	if self.barrelWarning.Parent then
		self.barrelWarning.Parent = nil
	end

	self.muzzleAttach.Parent = nil
end

-- Resolve only physical parts. Some models contain Welds or attachments with
-- the same name as their muzzle part.
function BaseTool:_findModelPart(partName: string?): BasePart?
	local model = self.actual_model
	if not model or not partName then return nil end

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == partName then
			return descendant
		end
	end

	local lowerName = string.lower(partName)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and string.lower(descendant.Name) == lowerName then
			return descendant
		end
	end

	return nil
end

function BaseTool:init_short_mechanic()
	if not self.RegisteredAnimations.Short then
		return
	end

	local short_distance = self.Short_Distance or 4


	if not self.hitAttach then
		self.hitAttach = Instance.new("Attachment")
		self.hitAttach.Name = "HitWarningAttach"
		self.hitAttach.Parent = self.barrelWarning
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local mouse = LOCAL_PLAYER:GetMouse()

	if self.short_connection then
		self.short_connection:Disconnect()
	end

	self.short_connection = RunService.RenderStepped:Connect(function()
		if not self.Aiming then
			self.IsShorted = false
			self.ForceBlockFire = false

			if self._shortTrack and self._shortTrack.IsPlaying then
				self._shortTrack:Stop()
				self._shortTrack = nil
			end

			self:clearMuzzleFX()
			return
		end

		local character = LOCAL_PLAYER.Character

		if not character or not self.Equipped then
			self:clearMuzzleFX()
			return
		end

		local head = character:FindFirstChild("Head")

		if not head or not self.actual_model then
			self:clearMuzzleFX()
			return
		end

		local muzzle = self:_findModelPart(self.MuzzlePartName)

		if not muzzle then
			self:clearMuzzleFX()
			return
		end

		rayParams.FilterDescendantsInstances = {
			character,
			self.actual_model,
			self.barrelWarning
		}

		local lookDir = head.CFrame.LookVector

		local shortResult = raycastIgnoringCharactersAndInvisible(
			head.Position,
			lookDir * short_distance,
			rayParams
		)

		local targetPosition = mouse.Hit.Position
		local aimDirection = (targetPosition - muzzle.Position).Unit

		local muzzleResult = raycastIgnoringCharactersAndInvisible(
			muzzle.Position,
			aimDirection * short_distance,
			rayParams
		)

		local muzzleBlocked = muzzleResult ~= nil

		if shortResult then

			local alpha = math.clamp(
				1 - (shortResult.Distance / short_distance) + 0.4,
				0,
				1
			)

			self.IsShorted = true


			if not self._shortTrack or not self._shortTrack.IsPlaying then
				self._shortTrack = self.RegisteredAnimations.Short
				self._shortTrack:Play(0.1, alpha, 0.001)
			end

			self._shortTrack:AdjustWeight(alpha)
			self._shortTrack:AdjustSpeed(0.001)
		else
			self.IsShorted = false

			if self._shortTrack and self._shortTrack.IsPlaying then
				local w = self._shortTrack.WeightCurrent - 0.8

				if w <= 0 then
					self._shortTrack:Stop(0.1)
					self._shortTrack = nil
					self:_restoreBase()
				else
					self._shortTrack:AdjustWeight(w)
				end
			end
		end

		self.ForceBlockFire = self.IsShorted

		if self.muzzleAttach.Parent ~= muzzle then
			self.muzzleAttach.Parent = muzzle
		end

		self.barrelWarning.CFrame = CFrame.new(
			muzzleBlocked and muzzleResult.Position or (muzzle.Position + aimDirection * short_distance)
		)

		if muzzleBlocked then

			if self.warning_beam then
				self.warning_beam.Attachment0 = self.muzzleAttach
				self.warning_beam.Attachment1 = self.hitAttach
				self.warning_beam.Enabled = true
			end

			if self.billboard_ui then
				self.billboard_ui.Enabled = true
			end

			if self.barrelWarning.Parent ~= workspace then
				self.barrelWarning.Parent = workspace
			end
		else
			self:clearMuzzleFX()
		end
	end)
end

function BaseTool:clean_up_short()
	if self.short_connection then
		self.short_connection:Disconnect()
		self.short_connection = nil
	end

	self:clearMuzzleFX()
end

function BaseTool:define_shorts()
	self.barrelWarning = self:GetBarrelWarningPart()
	if not self.barrelWarning then
		warn("[BASETOOL] barrelWarning missing")
		return
	end

	self.warning_beam = self.barrelWarning:FindFirstChild("warningbeam", true)
	self.billboard_ui = self.barrelWarning:FindFirstChild("x", true)

	self.muzzleAttach = Instance.new("Attachment")
	self.muzzleAttach.Name = "MuzzleWarningAttach"

	self.hitAttach = self.barrelWarning:FindFirstChild("HitWarningAttach", true)
end

-- // Equip / Unequip

function BaseTool:equip()
	print("Equipping tool:", self.tool.Name)
	if not self.tool then return end

	self.Equipped  = true
	self.Equipping = true

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if not self.actual_holster and self.holster_reference then
		self.actual_holster = utilities_module.reverse_search_holster(LOCAL_PLAYER, self.holster_reference.Name)
	end

	character:SetAttribute("Sprint_Animation", self.className)
	humanoid:EquipTool(self.tool)

	if self._on_equip then self:_on_equip() end

	if self.CompassRight then
		character:SetAttribute("CompassRight", true)
	end

	if self.CompassDisabled then
		print("Compass Denied")
		LOCAL_PLAYER.Character:SetAttribute("CompassDenied", true)
		print("Given CompassDenied Attribute")
	else
		print("Compass Allowed")
	end

	self:define_shorts()
	if self.RegisteredAnimations then
		local draw = self.RegisteredAnimations.Draw
		local hold = self.RegisteredAnimations.Hold
		if draw then self:_playAnim("Draw", true) end
		if hold then
			-- Replace the previous draw callback when the tool is equipped again.
			if self._drawStoppedConnection then
				self._drawStoppedConnection:Disconnect()
			end
			local function finishDraw()
				if self.tool and self.tool.Parent == character and self.Equipped then
					self:_playAnim("Hold", true)
					hold:AdjustSpeed(0.2)
					self.Equipping = false
					self:init_short_mechanic()
				end
			end
			if draw then
				self._drawStoppedConnection = draw.Stopped:Connect(finishDraw)
			else
				finishDraw()
			end
		elseif not draw then
			self.Equipping = false
		end
	end

	if self.model_reference then
		self.actual_model = utilities_module.reverse_search_model(LOCAL_PLAYER, self.model_reference.Name)
		if not self.actual_model then warn("[" .. self.className .. "] Failed to find model") end
	end

	self:_startAimTracking()

	self.sprint_connection = character:GetAttributeChangedSignal("Sprinting"):Connect(function()
		if character:GetAttribute("Sprinting") == true then
			character:GetAttributeChangedSignal("Sprint_Animation"):Wait()
			self:_stopAllExcept()
			local hold = self.RegisteredAnimations.Hold
			hold:Stop()
			print("Is sprinting animation")
		else
			print("Is not sprinting animation")
			if not self.Equipped then return end
			if self.Aiming then
				local aimTrack = self:_aimTrack()
				if aimTrack and not aimTrack.IsPlaying then aimTrack:Play(CUT) end
				return
			end
			if self.RegisteredAnimations and self.RegisteredAnimations.Hold then
				self.RegisteredAnimations.Hold:AdjustSpeed(0.2)
				self:_playAnim("Hold", true)
			end
		end
	end)

	-- Keyframe dispatch
	for _, track in pairs(self.RegisteredAnimations) do
		if not track:IsA("AnimationTrack") then continue end

		table.insert(self.keyframe_connections, track.KeyframeReached:Connect(function(keyframe)

			local rightArm = LOCAL_PLAYER.Character:FindFirstChild("Right Arm")
			if not rightArm then return end
			local round


			if self.Round_Target_Part then
				if not self.Round then return end
				round = LOCAL_PLAYER.Character:FindFirstChild(self.Round_Target_Part):FindFirstChild(self.Round.Name)
			else
				if not self.Round then return end
				round = rightArm:FindFirstChild(self.Round.Name)
			end
			if not round then warn("No self.Round in Right_Arm") return end

			if keyframe == "vfx_hand_shell_visible" then
				round.Transparency = 0

			elseif keyframe == "vfx_hand_shell_invisible" then
				round.Transparency = 1
			elseif keyframe == "vfx_eject_casing" then
				local casing = self.actual_model:FindFirstChild(self.className .. "_Ejection")
				if not casing then warn("[BASETOOL] vfx_eject_casing: no casing for " .. self.className) return end
				self:emit_casing(casing, casing.CFrame)
				print("Ejecting casing")

			elseif keyframe == "vfx_cylinder_rotate_other" then
				local cylinder_motor: Motor6D =
					self.actual_model
					:FindFirstChild(self.className .. "_Middle")
					:FindFirstChild(self.className .. "_Cylinder")

				if not self.cylinder_rotation_degree then
					self.cylinder_rotation_degree = 360 / self.Max_Capacity
				end

				local newC0 = cylinder_motor.C0 * CFrame.Angles(math.rad(self.cylinder_rotation_degree), 0, 0)
				if self.cylinder_rotation then self.cylinder_rotation += 1 end

				TweenService:Create(cylinder_motor,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ C0 = newC0 }
				):Play()

			elseif keyframe == "vfx_cylinder_load" then
				local cylinder = self.actual_model:FindFirstChild(self.className .. "_Cylinder")
				local round_ref = cylinder:FindFirstChild(self.className .. "_Round" .. self.cylinder_rotation)
				round_ref.Transparency = 0
				round_ref.bullet.Transparency = 0

			elseif keyframe == "vfx_cylinder_empty" then
				local cylinder = self.actual_model:FindFirstChild(self.className .. "_Cylinder")
				for _, r in pairs(cylinder:GetChildren()) do
					if not r:IsA("MeshPart") or not string.find(r.Name, "Round") then continue end
					if r.Transparency == 1 then continue end
					r.Transparency = 1
					r.bullet.Transparency = 1
					r.CanCollide = true
					self:emit_casing(r, r.CFrame, r.CFrame.RightVector * math.random(0, 8))
				end
				self.cylinder_rotation = 1

			elseif keyframe:sub(1, 4) == "sfx_" then
				if not self.SFXFolder then return end
				local sound = self.SoundFolder:FindFirstChild(keyframe:sub(5))
				if sound then
					local muzzle = self:_findModelPart(self.MuzzlePartName)
					if muzzle then self:_play_sfx(sound, muzzle, nil, 0.1) end
					print("Playing sound: " .. keyframe:sub(5))
				else
					warn("Sound not found for keyframe: " .. keyframe)
				end

			elseif keyframe:sub(1, 5) == "gsfx_" then
				local baseName = keyframe:sub(6)
				local matches = {}
				for _, child in ipairs(general_sfx:GetChildren()) do
					if child.Name:sub(1, #baseName) == baseName then
						table.insert(matches, child)
					end
				end
				if #matches > 0 then
					if not self.actual_model then return end
					local muzzle = self:_findModelPart(self.MuzzlePartName)
					if not muzzle then return end
					self:_play_sfx(matches[math.random(1, #matches)], muzzle, nil, 0.1)
					print("Playing GSFX: " .. matches[math.random(1, #matches)].Name)
				else
					warn("No GSFX matches for: " .. baseName)
				end
			end
		end))
	end

	self.Moving_Connection = character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		self.LastMovedTime = tick()
	end)
end

function BaseTool:unequip()
	if not self.tool then return end
	if self.Reloading and not self.Emergency_Drop then return end

	self.Equipped = false

	local character = LOCAL_PLAYER.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	LOCAL_PLAYER:SetAttribute("CantUnequip", false)
	character:SetAttribute("Sprint_Animation", nil)
	if self._on_unequip then self:_on_unequip() end

	if self.RegisteredAnimations then
		for _, anim in pairs(self.RegisteredAnimations) do
			anim:Stop(0)
		end
	end

	self:_disable_aiming_ui()
	humanoid:UnequipTools()

	if self.sprint_connection then
		self.sprint_connection:Disconnect()
		self.sprint_connection = nil
	end
	if self._drawStoppedConnection then
		self._drawStoppedConnection:Disconnect()
		self._drawStoppedConnection = nil
	end

	if self.RegisteredAnimations then
		if self.Emergency_Drop then
			self:_playAnim("Drop", true)
		elseif self.RegisteredAnimations.Unequip then
			self:_playAnim("Unequip", true)
			if self.unequip_wait then
				self.RegisteredAnimations.Unequip.Stopped:Wait()
			end
		end
	end

	self:clean_up_short()
	self.actual_model = nil
	if LOCAL_PLAYER.Character then LOCAL_PLAYER.Character:SetAttribute("Aiming", nil) end

	local ammoCheck = workspace.CurrentCamera:FindFirstChild("Ammo_Check")
	if ammoCheck then ammoCheck:Destroy() end

	if #self.keyframe_connections > 0 then
		for _, conn in pairs(self.keyframe_connections) do conn:Disconnect() end
		self.keyframe_connections = {}
	end

	character:SetAttribute("CompassRight", nil)
	LOCAL_PLAYER.Character:SetAttribute("CompassDenied", nil)
	if self.Moving_Connection then
		self.Moving_Connection:Disconnect()
		self.Moving_Connection = nil
	end
end

-- // Automatic Spread
function BaseTool:get_spread(muzzle, shootDir)
	local character = game.Players.LocalPlayer.Character

	-- Hold breath
	local holdingBreath = character and character:GetAttribute("HoldBreathe") == true
	if holdingBreath then
		local windedUp = (tick() - (self.HoldBreathStartTime or 0)) >= (self.HoldBreathAccuracyTime or 0.35)
		if windedUp then
			return shootDir
		end
	end

	local isMoving = (tick() - (self.LastMovedTime or 0)) <= 0.1

	local spread = isMoving and self.Moving_Accuracy or self.Accuracy

	local hOffset = math.random(-spread, spread) / 1000
	local vOffset = math.random(-spread, spread) / 1000

	local muzzleCF = muzzle.CFrame

	return (
		shootDir
			+ muzzleCF.RightVector * hOffset
			+ muzzleCF.UpVector * vOffset
	).Unit
end

-- // State helpers

function BaseTool:_isBusy(): boolean
	local animations = self.RegisteredAnimations
	local drawTrack = animations and animations.Draw
	return self.Firing or self.Reloading or self.Cycling or self.Alting or self.Spinning
		or self.Checking or self.Meleeing
		or (drawTrack ~= nil and drawTrack.IsPlaying) or false
end

function BaseTool:_if_sprinting(): boolean
	local char = LOCAL_PLAYER.Character
	return char ~= nil and char:GetAttribute("Sprinting") == true
end

function BaseTool:_if_jumping(): boolean
	return LOCAL_PLAYER:GetAttribute("Jumping") == true
end

-- // Animation helpers

function BaseTool:_stopAllExcept(exception: AnimationTrack?)
	if not self.RegisteredAnimations then return end
	for _, track in pairs(self.RegisteredAnimations) do
		if track ~= exception and track:IsA("AnimationTrack") and track.IsPlaying then
			track:Stop(CUT)

			-- FIX: if this stops the Short track out from under init_short_mechanic's
			-- render loop, clear the reference immediately so the loop knows to
			-- replay it next time it's needed, instead of assuming it's still playing.
			if track == self._shortTrack then
				self._shortTrack = nil
			end
		end
	end
end

function BaseTool:_playAnim(name: string, bypass_equiped: boolean): AnimationTrack?
	local anims = self.RegisteredAnimations
	assert(anims, self.className .. ":_playAnim called before animations registered")

	local track = anims[name]
	assert(track, self.className .. ": unknown animation '" .. tostring(name) .. "'")


	if not self.Equipped and not bypass_equiped then
		warn(self.className .. ":_playAnim called while not equipped: " .. name)
		return track 
	end

	local layers = self.ANIM_LAYERS
	if layers then
		local myLayer = layers[name] or 0
		local maxLayer = 0
		for _, v in pairs(layers) do if v > maxLayer then maxLayer = v end end

		for trackName, layer in pairs(layers) do
			local shouldStop = (myLayer >= maxLayer) and (layer <= myLayer) or (layer == myLayer)
			if shouldStop then
				local t = anims[trackName]
				if t and t ~= track and t.IsPlaying then t:Stop(CUT) end
			end
		end
	end

	local speed = 1

	if self.animation_speeds then
		speed = self.animation_speeds[name] or 1
	end

	track:Play(CUT)
	track:AdjustSpeed(speed)

	return track
end

function BaseTool:_stopLayer(maxLayer: number)
	if not self.RegisteredAnimations then return end
	local layers = self.ANIM_LAYERS
	if not layers then self:_stopAllExcept() return end
	for trackName, layer in pairs(layers) do
		if layer <= maxLayer then
			local t = self.RegisteredAnimations[trackName]
			if t and t.IsPlaying then t:Stop(CUT) end
		end
	end
end

function BaseTool:_aimTrack(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Aim or anims.Aim_Left
end

function BaseTool:_getFireAnim(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	return (self.current_shoulder == "Right") and anims.Fire or anims.Fire_Left
end

function BaseTool:_playRecoilAnimation(): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end
	local recoil = (self.current_shoulder == "Right") and anims.Recoil or (anims.Recoil_Left or anims.Recoil)
	if recoil then recoil:Play(0.03) end
	return recoil
end

function BaseTool:_playFireAnimation(animationName: string, playRecoil: boolean?): AnimationTrack?
	local anims = self.RegisteredAnimations
	if not anims then return nil end

	-- Empty/last/recoil variants are optional in the saved rigs. Preserve the
	-- current shoulder when falling back; never substitute a right-side track
	-- while the weapon is on the left shoulder (or vice versa).
	local resolvedName = animationName
	if not anims[resolvedName] then
		resolvedName = (self.current_shoulder == "Right") and "Fire" or "Fire_Left"
	end
	local fireTrack = anims[resolvedName] and self:_playAnim(resolvedName) or nil
	if playRecoil ~= false then self:_playRecoilAnimation() end

	if fireTrack then
		fireTrack.Stopped:Once(function()
			if not self.Equipped or not self.Aiming then return end
			local aimTrack = self:_aimTrack()
			if not aimTrack then return end
			self:_killAimTracks()
			aimTrack:Play(0)
		end)
	elseif self.Equipped and self.Aiming then
		local aimTrack = self:_aimTrack()
		if aimTrack and not aimTrack.IsPlaying then aimTrack:Play(0) end
	end

	return fireTrack
end

function BaseTool:_killAimTracks()
	local anims = self.RegisteredAnimations
	if not anims then return end
	if anims.Aim      and anims.Aim.IsPlaying      then anims.Aim:Stop(CUT)      end
	if anims.Aim_Left and anims.Aim_Left.IsPlaying then anims.Aim_Left:Stop(CUT) end
end

function BaseTool:_restoreBase()
	if self:_isBusy() or not self.Equipped then return end

	local anims = self.RegisteredAnimations
	if not anims then return end

	if self.ANIM_LAYERS then
		for trackName, layer in pairs(self.ANIM_LAYERS) do
			if layer == 1 then
				local t = anims[trackName]
				if t and t.IsPlaying then t:Stop(CUT) end
			end
		end
	end

	if self.Aiming or self.holding_aim_button == true then
		if self.Aiming then
			local want = self:_aimTrack()
			local kill = (want == anims.Aim) and anims.Aim_Left or anims.Aim
			if kill and kill.IsPlaying then kill:Stop(CUT) end
			if anims.Hold and anims.Hold.IsPlaying then anims.Hold:Stop(CUT) end
			if want and not want.IsPlaying then want:Play() end
		else
			self:aim()
		end

		self:init_short_mechanic()
	else
		self:_killAimTracks()
		if anims.Hold and not anims.Hold.IsPlaying then
			anims.Hold:Play()
			anims.Hold:AdjustSpeed(0.2)
		end
	end
end

function BaseTool:_restoreBaseDeferred()
	task.defer(function() self:_restoreBase() end)
end

function BaseTool:_set_sprint_arms(enabled: boolean)
	if enabled then
		LOCAL_PLAYER.Character:SetAttribute("No_Sprint_Animation", true)
	else
		LOCAL_PLAYER.Character:SetAttribute("No_Sprint_Animation", nil)
	end
end

function BaseTool:_damageMeleeTarget(targetCharacter: Model, meleeRange: number, damage: number)
	melee_communication.Melee_Connection:FireServer(targetCharacter, meleeRange, damage)
end

-- // Melee (shared)
function BaseTool:melee()
	if self.Meleeing then return end
	if game.Players.LocalPlayer:GetAttribute("FreeLook") then return end

	self.Meleeing = true

	local player = Players.LocalPlayer
	local character = player.Character
	local camera = workspace.CurrentCamera

	self:_stopAllExcept()

	local meleeIndex = math.random(1, 2)
	local meleeAnimation = "Melee" .. meleeIndex
	if self._getMeleeAnimationName then
		meleeAnimation = self:_getMeleeAnimationName(meleeIndex)
	end
	local anim = self:_playAnim(meleeAnimation)
	if not anim then
		self.Meleeing = false
		self:_restoreBase()
		return
	end

	task.delay(0.15, function()
		if not character or not character.Parent then
			return
		end

		local meleeRange = self.MeleeRange or 4

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {LOCAL_PLAYER.Character}

		local origin = camera.CFrame.Position + camera.CFrame.LookVector
		local lookVector = camera.CFrame.LookVector

		local targetCharacter

		-- Primary melee raycast
		local result = workspace:Raycast(
			origin,
			lookVector * (meleeRange + 1),
			params
		)

		if result and result.Instance then
			local model = result.Instance:FindFirstAncestorOfClass("Model")

			if model and model ~= character then
				local humanoid = model:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					targetCharacter = model
				end
			end
		end

		if not targetCharacter then
			local center = origin + lookVector * (meleeRange / 2)
			local radius = meleeRange / 1.5

			local candidates = {}

			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player then
					local char = plr.Character

					if char then
						local humanoid = char:FindFirstChildOfClass("Humanoid")
						local root = char:FindFirstChild("HumanoidRootPart")

						if humanoid and humanoid.Health > 0 and root then
							if (root.Position - center).Magnitude <= radius then
								table.insert(candidates, char)
							end
						end
					end
				end
			end

			for _, candidate in ipairs(candidates) do
				local root = candidate:FindFirstChild("HumanoidRootPart")

				if root then
					local los = workspace:Raycast(
						origin,
						root.Position - origin,
						params
					)

					local visible = false

					if los then
						visible = los.Instance:IsDescendantOf(candidate)
					else
						visible = true
					end

					if visible then
						targetCharacter = candidate
						break
					end
				end
			end
		end

		if targetCharacter then
			self:_damageMeleeTarget(targetCharacter, meleeRange, self.Melee_Damage)
		end
	end)

	anim.Stopped:Connect(function()
		self.Meleeing = false
		self:_restoreBase()
	end)
end
-- // Shoulder tracking

function BaseTool:_onShoulderChanged()
	if self:_isBusy() or not self.Aiming then return end

	task.defer(function()
		if self:_isBusy() or not self.Aiming then return end

		local anims = self.RegisteredAnimations
		if not anims then return end

		local oldAimTrack = nil
		if anims.Aim      and anims.Aim.IsPlaying      then oldAimTrack = anims.Aim      end
		if anims.Aim_Left and anims.Aim_Left.IsPlaying then oldAimTrack = anims.Aim_Left end

		local newAimTrack = self:_aimTrack()
		if not newAimTrack or oldAimTrack == newAimTrack then return end

		if oldAimTrack and oldAimTrack.IsPlaying then oldAimTrack:Stop(CUT) end
		if not newAimTrack.IsPlaying then newAimTrack:Play(CUT) end
	end)
end

-- // Aim system

function BaseTool:aim()
	if not self.Equipped then return end 
	if self.Aiming or self:_isBusy() then return end
	if not self.RegisteredAnimations.Aim then return end
	if LOCAL_PLAYER:GetAttribute("FreeLook") then return end
	if self.Equipping or self.IsShorted then return end
	if self:_if_jumping() then return end

	self._smoothedYaw = nil
	self._lastYaw = nil

	local function updateAimAnimation()
		self:_killAimTracks()

		if LOCAL_PLAYER:GetAttribute("Jumping") then
			self.ForceBlockFire = true
			if self._shortTrack then self._shortTrack:Stop(0) end
			self._shortTrack = self:_playAnim("Short")
			if self._shortTrack then self._shortTrack:AdjustSpeed(1) end
			return
		end

		if self._shortTrack then
			self._shortTrack:Stop(CUT)
			self._shortTrack = nil
		end

		local aimTrack = self:_aimTrack()
		if aimTrack then
			aimTrack:Play(CUT)
			self.ForceBlockFire = false
			self.Aiming = true
		end
	end

	self._aimVersion += 1
	self:_startAimTracking()

	local anims = self.RegisteredAnimations
	if not anims then return end

	if anims.Hold and anims.Hold.IsPlaying then anims.Hold:Stop(CUT * 1.5) end

	updateAimAnimation()

	local character = LOCAL_PLAYER.Character
	if character then character:SetAttribute("Aiming", true) end

	self:_enable_aiming_ui(self.Aiming_Number or 50)
	self:_startTransparencyTracking()

	if not self._jumpAimConnection then
		self._jumpAimConnection = LOCAL_PLAYER:GetAttributeChangedSignal("Jumping"):Connect(function()
			if self.Aiming then updateAimAnimation() end
		end)
	end

	if not self._freeLookAimConnection then
		self._freeLookAimConnection = LOCAL_PLAYER:GetAttributeChangedSignal("FreeLook"):Connect(function()
			if LOCAL_PLAYER:GetAttribute("FreeLook") then self:endAiming() end
		end)
	end

	if not self._sprintConnection then
		self._sprintConnection = LOCAL_PLAYER:GetAttributeChangedSignal("Sprinting"):Connect(function()
			if LOCAL_PLAYER:GetAttribute("Sprinting") then self:endAiming() end
		end)
	end

	if not self.vaultConnection then
		self._vaultConnection = LOCAL_PLAYER:GetAttributeChangedSignal("Vaulting"):Connect(function()
			if LOCAL_PLAYER:GetAttribute("Vaulting") then self:endAiming() end
		end)
	end
end

function BaseTool:endAiming()
	if not self.Aiming then return end
	self.Aiming = false
	self._aimVersion += 1

	self:_stopTransparencyTracking()
	self:_killAimTracks()

	self.IsShorted     = false
	self.ForceBlockFire = false
	if not self:_isBusy() then
		local anims = self.RegisteredAnimations
		if anims and anims.Hold and not anims.Hold.IsPlaying then
			anims.Hold:Play(CUT)
			anims.Hold:AdjustSpeed(0.2)
		end
	end

	local char = LOCAL_PLAYER.Character
	if char then char:SetAttribute("Aiming", nil) end
	self:_disable_aiming_ui()
	self:_resetBodyTransparency()
end

-- // Transparency helpers

function BaseTool:_startTransparencyTracking()
	if self._transparencyConnection then self._transparencyConnection:Disconnect() end

	local char = LOCAL_PLAYER.Character
	if not char then return end

	self._transparencyConnection = RunService.RenderStepped:Connect(function()
		if not self.Aiming or not char or not char:FindFirstChild("Humanoid") then return end
		if LOCAL_PLAYER:GetAttribute("FirstPerson") then
			return
		end

		local pitchAngle = math.rad(CAMERA.CFrame:ToEulerAnglesYXZ() * 50)
		self:_setBodyTransparency((pitchAngle >= 0.43 or pitchAngle <= -0.9) and CHARACTER_TRANSPARENCY or 0)
	end)
end

function BaseTool:_stopTransparencyTracking()
	if self._transparencyConnection then
		self._transparencyConnection:Disconnect()
		self._transparencyConnection = nil
	end
end

function BaseTool:_setBodyTransparency(transparency: number)
	local char = LOCAL_PLAYER.Character
	if not char then return end
	for _, name in ipairs({"Left Arm", "Right Arm" }) do
		local part = char:FindFirstChild(name)
		if part then part.Transparency = transparency end
	end
end

function BaseTool:_resetBodyTransparency()
	self:_setBodyTransparency(0)
end

-- // Input
function BaseTool:_connectInput()
	if self._inputConnected then return end
	self._inputConnected = true

	self._inputBeganConn = UserInputService.InputBegan:Connect(function(input, gps)
		if gps then return end

		-- // right click
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.holding_aim_button = true
			self:aim()
		end
	end)

	self._inputEndedConn = UserInputService.InputEnded:Connect(function(input, gps)
		if gps then return end

		-- // right click
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:endAiming()
			self.holding_aim_button = false
		end
	end)

	self._reloadHook = function(_, pressed)
		if pressed then
			self:reload()
		end
	end
	SettingsManager.HookInput("Reload", self._reloadHook)

	self._checkAmmoHook = function(_, pressed)
		if pressed then
			if self.Can_Drop and self.Reloading and self.Equipped then
				self:drop()
				return
			else
				self._ammoCheckHeld = true
				task.spawn(function()
					self:ammo_check()
				end)
			end
		else
			self._ammoCheckHeld = false
			self:end_ammo_check()
		end
	end
	SettingsManager.HookInput("Check Ammo", self._checkAmmoHook)

	self._altHook = function(_, pressed)
		if pressed and self.Equipped then
			self:setAltMode()
		end
	end
	SettingsManager.HookInput("Alternate Action", self._altHook)
end

function BaseTool:_disconnectInput()
	self._ammoCheckHeld = false
	self:end_ammo_check(true)

	if self._inputBeganConn then self._inputBeganConn:Disconnect(); self._inputBeganConn = nil end
	if self._inputEndedConn then self._inputEndedConn:Disconnect(); self._inputEndedConn = nil end

	if self._reloadHook then
		SettingsManager.UnhookInput("Reload", self._reloadHook)
		self._reloadHook = nil
	end
	if self._checkAmmoHook then
		SettingsManager.UnhookInput("Check Ammo", self._checkAmmoHook)
		self._checkAmmoHook = nil
	end
	if self._altHook then
		SettingsManager.UnhookInput("Alternate Action", self._altHook)
		self._altHook = nil
	end

	self._inputConnected = false
end

-- // Shoulder tracking

function BaseTool:_initShoulderTracking()
	if not RunService:IsClient() then return end
	self.current_shoulder = LOCAL_PLAYER:GetAttribute("Current_Shoulder") or "Right"

	if self._shoulderChangedConn then self._shoulderChangedConn:Disconnect() end

	self._shoulderChangedConn = LOCAL_PLAYER:GetAttributeChangedSignal("Current_Shoulder"):Connect(function()
		self.current_shoulder = LOCAL_PLAYER:GetAttribute("Current_Shoulder") or "Right"
		self:_onShoulderChanged()
	end)
end

function BaseTool:_stopShoulderTracking()
	if self._shoulderChangedConn then
		self._shoulderChangedConn:Disconnect()
		self._shoulderChangedConn = nil
	end
end

-- // Aim motor tracking

function BaseTool:_startAimTracking()
	if self._aimConnection then return end

	local character = LOCAL_PLAYER.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local torso = character and character:FindFirstChild("Torso")
	if not (character and root and torso) then return end

	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	if not (leftShoulder and rightShoulder) then return end

	self._restLeftC0  = self._restLeftC0  or leftShoulder.C0
	self._restRightC0 = self._restRightC0 or rightShoulder.C0

	self._wasFreeLook  = self._wasFreeLook  or false
	self._freeLookYaw  = self._freeLookYaw  or 0
	self._smoothedYaw  = self._smoothedYaw  or 0
	self._lastYaw      = self._lastYaw      or 0

	local lerpAlpha = 0.15

	self._aimConnection = RunService.RenderStepped:Connect(function()
		if not self.Equipped then return end
		if LOCAL_PLAYER:GetAttribute("FreeLook") then return end

		local char = LOCAL_PLAYER.Character
		local r = char and char:FindFirstChild("HumanoidRootPart")
		local t = char and char:FindFirstChild("Torso")
		if not (char and r and t) then return end

		local ls = t:FindFirstChild("Left Shoulder")
		local rs = t:FindFirstChild("Right Shoulder")
		if not (ls and rs) then return end

		if not self.Aiming then
			if self._restLeftC0  then ls.C0 = ls.C0:Lerp(self._restLeftC0,  lerpAlpha) end
			if self._restRightC0 then rs.C0 = rs.C0:Lerp(self._restRightC0, lerpAlpha) end
			return
		end

		local leftArmCF
		local rightArmCF

		if LOCAL_PLAYER:GetAttribute("FirstPerson") then
			local camCF = CAMERA.CFrame

			local shoulderOffset = CFrame.new()
			if self.current_shoulder == "Left" then
				shoulderOffset = CFrame.new(-0.4, -1.75, 0)
			elseif self.current_shoulder == "Right" then
				shoulderOffset = CFrame.new(0.5, -1.75, 0)
			end

			leftArmCF = t.CFrame:ToObjectSpace(
				camCF
					* shoulderOffset
					* CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)
					* CFrame.new(-1, 0.5, 0)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			rightArmCF = t.CFrame:ToObjectSpace(
				camCF
					* shoulderOffset
					* CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)
					* CFrame.new(1, 0.5, 0)
					* CFrame.Angles(0, math.pi / 2, 0)
			)
		else
			local currentLookDir = CAMERA.CFrame.LookVector
			local cameraPitch    = math.asin(math.clamp(currentLookDir.Y, -1, 1))

			local relativeCF = r.CFrame:ToObjectSpace(CAMERA.CFrame)
			local lookDir    = relativeCF.LookVector

			local rawYaw = math.atan2(-lookDir.X, -lookDir.Z)

			if self._smoothedYaw == nil then
				self._smoothedYaw = rawYaw
			end

			while self._smoothedYaw >  math.pi do self._smoothedYaw -= math.pi * 2 end
			while self._smoothedYaw < -math.pi do self._smoothedYaw += math.pi * 2 end

			local deltaYaw = rawYaw - self._smoothedYaw
			while deltaYaw >  math.pi do deltaYaw -= math.pi * 2 end
			while deltaYaw < -math.pi do deltaYaw += math.pi * 2 end

			self._smoothedYaw = self._smoothedYaw + deltaYaw * 0.2
			self._smoothedYaw = math.clamp(self._smoothedYaw, math.rad(-85), math.rad(85))

			local yaw = self._smoothedYaw

			if not LOCAL_PLAYER:GetAttribute("FreeLook") then
				self._wasFreeLook = false
				self._freeLookYaw = yaw
			end

			local rotationCF =
				CFrame.Angles(0, yaw, 0)
				* CFrame.Angles(cameraPitch, 0, 0)

			local armRotation =
				rotationCF
				* CFrame.Angles(0, r.RootJoint.CurrentAngle, 0)

			leftArmCF = t.CFrame:ToObjectSpace(
				r.CFrame
					* armRotation
					* CFrame.new(-1, 0.5, 0)
					* CFrame.Angles(0, -math.pi / 2, 0)
			)

			rightArmCF = t.CFrame:ToObjectSpace(
				r.CFrame
					* armRotation
					* CFrame.new(1, 0.5, 0)
					* CFrame.Angles(0, math.pi / 2, 0)
			)
		end

		local leftRot  = leftArmCF.Rotation
		local rightRot = rightArmCF.Rotation

		self._fpLeftRot  = self._fpLeftRot  or leftRot
		self._fpRightRot = self._fpRightRot or rightRot

		self._fpLeftRot  = self._fpLeftRot:Lerp(leftRot,  0.12)
		self._fpRightRot = self._fpRightRot:Lerp(rightRot, 0.12)

		ls.C0 = CFrame.new(leftArmCF.Position)  * self._fpLeftRot
		rs.C0 = CFrame.new(rightArmCF.Position) * self._fpRightRot
	end)
end

function BaseTool:_stopAimTracking()
	if self._aimConnection then
		self._aimConnection:Disconnect()
		self._aimConnection = nil
	end

	local character = LOCAL_PLAYER.Character
	local torso = character and character:FindFirstChild("Torso")

	if torso then
		local resetInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ls = torso:FindFirstChild("Left Shoulder")
		local rs = torso:FindFirstChild("Right Shoulder")
		if ls and self._restLeftC0  then TweenService:Create(ls, resetInfo, { C0 = self._restLeftC0  }):Play() end
		if rs and self._restRightC0 then TweenService:Create(rs, resetInfo, { C0 = self._restRightC0 }):Play() end
	end

	task.delay(0.15, function()
		if not self.Aiming then self:_resetMotor6D() end
	end)
end

-- // Motor6D helpers

function BaseTool:_findToolMotor(): Motor6D?
	if self.motor_6d and self.motor_6d.Parent then return self.motor_6d end
	local character = LOCAL_PLAYER.Character
	if not character then return nil end
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("Motor6D") and descendant.Name == "ToolMotor" then
			if not self.actual_model or (descendant.Part1 and descendant.Part1:IsDescendantOf(self.actual_model)) then
				self.motor_6d = descendant
				return descendant
			end
		end
	end
	return nil
end

function BaseTool:_setGripArm(armName: string)
	local motor = self:_findToolMotor()
	local character = LOCAL_PLAYER.Character
	local arm = character and character:FindFirstChild(armName)
	if not motor or not arm or not arm:IsA("BasePart") or not self.motor_6d_data then return end

	motor.Parent = arm
	motor.Part0 = arm
	if armName == "Left Arm" then
		motor.C0 = self.motor_6d_data.ReloadGripC0 or self.motor_6d_data.C0
		motor.C1 = self.motor_6d_data.ReloadGripC1 or self.motor_6d_data.C1 or CFrame.identity
	else
		motor.C0 = self.motor_6d_data.C0
		motor.C1 = self.motor_6d_data.C1 or CFrame.identity
	end
end

function BaseTool:_cacheMotor6D()
	local motor = self:_findToolMotor()
	if not motor then return end
	self._motorOriginal = {
		C0    = motor.C0,
		C1    = motor.C1,
		Part0 = motor.Part0,
		Part1 = motor.Part1,
	}
end

function BaseTool:_resetMotor6D()
	if not self.motor_6d or not self._motorOriginal then return end
	local motor    = self.motor_6d
	local targetC0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(-math.rad(90), 0, 0)
	local targetC1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(-math.rad(90), 0, 0)
	local snapDist = (self :: any).MOTOR_SNAP_DIST or MOTOR_SNAP_DIST
	local alpha    = (self :: any).MOTOR_LERP_ALPHA or MOTOR_LERP_ALPHA
	local conn
	conn = RunService.PreSimulation:Connect(function()
		motor.C0 = motor.C0:Lerp(targetC0, alpha)
		motor.C1 = motor.C1:Lerp(targetC1, alpha)
		if (motor.C0.Position - targetC0.Position).Magnitude < snapDist then
			conn:Disconnect()
		end
	end)
end

-- // Notifications
function BaseTool:notify(text: string)
	local Notifications_util = require(
		LOCAL_PLAYER.PlayerGui:WaitForChild("Notifications"):WaitForChild("Utils")
	)
	Notifications_util.send_notification(LOCAL_PLAYER, text)
end

-- Optional category hooks. Firearm bases replace these with their full
-- implementations; generic tools can safely use the shared input lifecycle.
function BaseTool:_enable_aiming_ui(_max_aiming: number) end
function BaseTool:_disable_aiming_ui() end
function BaseTool:ammo_check() end
function BaseTool:end_ammo_check() end

function BaseTool:_play_sfx(...)
	-- Load replication only for tools whose animations actually emit sound
	-- keyframes; simple equipment never pays this initialization cost.
	local replicantService = require(ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService)
	replicantService.ConnectSfx(LOCAL_PLAYER, ...)
end

function BaseTool:drop()
	if not self.Equipped then return end

	self.Equipped = false
	self._reloadCancelled = true
	self.Emergency_Drop = true

	-- Emergency drop bypasses unequip(), so clear every character attribute
	-- that would otherwise keep the dropped weapon's animation overlays active.
	local character = LOCAL_PLAYER.Character
	if character then
		character:SetAttribute("Sprint_Animation", nil)
		character:SetAttribute("No_Sprint_Animation", nil)
		character:SetAttribute("Aiming", nil)
		character:SetAttribute("CompassRight", nil)
		character:SetAttribute("CompassDenied", nil)
	end
	LOCAL_PLAYER:SetAttribute("CantUnequip", nil)

	if self.RegisteredAnimations then
		for _, anim in pairs(self.RegisteredAnimations) do
			if anim:IsA("AnimationTrack") and anim.IsPlaying then
				anim:Stop(0)
			end
		end
	end

	drop_connection:FireServer(self.className, self.model_reference, true)
	self:destroy()
end

function BaseTool:activate() end
function BaseTool:reload() end

-- // Cleanup

function BaseTool:destroy()
	-- Disconnect everything created by this tool before removing it.
	if self._activationConnection then
		self._activationConnection:Disconnect()
		self._activationConnection = nil
	end

	self:_stopAllExcept()
	self:_disconnectInput()
	self:_stopShoulderTracking()
	self:_stopAimTracking()
	self:_resetMotor6D()

	if self._drawStoppedConnection then
		self._drawStoppedConnection:Disconnect()
		self._drawStoppedConnection = nil
	end
	if self.sprint_connection then
		self.sprint_connection:Disconnect()
		self.sprint_connection = nil
	end
	if self.Moving_Connection then
		self.Moving_Connection:Disconnect()
		self.Moving_Connection = nil
	end
	for _, connection in pairs(self.keyframe_connections) do
		connection:Disconnect()
	end
	self.keyframe_connections = {}

	if self.actual_model then
		self.actual_model:Destroy()
		self.actual_model = nil
	end

	self.Equipped = false
end

return BaseTool
