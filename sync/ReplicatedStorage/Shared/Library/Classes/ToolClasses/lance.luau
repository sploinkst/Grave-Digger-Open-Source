--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local MeleeAnimations = ReplicatedStorage.Shared.Assets.Animations.Tools.Melee

local Lance = {}
Lance.__index = Lance
setmetatable(Lance, { __index = BaseTool })

export type Lance = typeof(setmetatable({} :: any, Lance))

local function faction(character: Model?): string
	local team = character and character:FindFirstChild("team")
	if team and team:IsA("StringValue") and team.Value ~= "" then return team.Value end
	return (Players.LocalPlayer.Team and Players.LocalPlayer.Team.Name) or "Royal Nation"
end

local function modelForFaction(character: Model?): Model?
	local name = faction(character) == "Golden Empire" and "empirelance" or "lance"
	local model = ReplicatedStorage.Shared.Assets.Equipment:FindFirstChild(name)
	return if model and model:IsA("Model") then model else nil
end

function Lance.new(info: Types.BaseToolCreateInfo): Lance
	local self = setmetatable(BaseTool.new(info), Lance)
	local owner = (info :: any).player or Players.LocalPlayer
	self.className = "lance"
	self.name = "lance"
	self.AnimationGunType = "Lance"
	self.Designation = "Primary"
	self.WeaponCategory = "Melee"
	self.model_reference = modelForFaction(owner and owner.Character)
	self.TeamModel = faction(owner and owner.Character)
	self.Can_Drop = false
	self.UseAuthoredGrip = true
	local animations = MeleeAnimations:FindFirstChild("Lance")
	self.animations = {
		Aim = animations and animations:FindFirstChild("aim"),
		Charge = animations and animations:FindFirstChild("charge"),
		Charge_Stop = animations and animations:FindFirstChild("charge_stop"),
		Draw = animations and animations:FindFirstChild("draw"),
		Hold = animations and animations:FindFirstChild("held"),
		Melee1 = animations and animations:FindFirstChild("melee1"),
		Melee2 = animations and animations:FindFirstChild("melee2"),
		Stab1 = animations and animations:FindFirstChild("stab1"),
		Stab2 = animations and animations:FindFirstChild("stab2"),
		Sprint = animations and animations:FindFirstChild("sprint"),
		Unequip = animations and animations:FindFirstChild("unequip"),
	}
	self.Melee_Damage = 135
	self.MeleeRange = 7
	self.ChargeDamage = 220
	self.ChargeRange = 24
	self.ChargeRecovery = 0.8
	self.Charging = false
	self._meleeStep = 0
	local grip = self.model_reference and self.model_reference:FindFirstChild("hitbox", true)
	self.motor_6d_data = {
		Parent = "Right Arm", Part0 = "Right Arm", Part1 = grip,
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)), C1 = CFrame.identity,
	}
	return self
end

function Lance:activate()
	if not self.Charging then self:melee() end
end

function Lance:_getMeleeAnimationName(_randomIndex: number): string
	-- Lance attacks are a fixed two-hit chain, never random.
	self._meleeStep = (self._meleeStep % 2) + 1
	return (if self.Aiming then "Stab" else "Melee") .. self._meleeStep
end

function Lance:_on_equip()
	self:_connectInput()
end

function Lance:_on_unequip()
	self.Charging = false
	self.ForceBlockFire = false
	self:_disconnectInput()
	self:_stopAimTracking()
end

function Lance:setAltMode()
	if self.Charging or not self.Equipped or self:_isBusy() then return end
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or not root or humanoid.Health <= 0 then return end
	if character:GetAttribute("Sprinting") ~= true then
		self:notify("Sprint before charging")
		return
	end

	self.Charging = true
	self.ForceBlockFire = true
	self:_stopAllExcept()
	local charge = self:_playAnim("Charge")
	local attachment = Instance.new("Attachment")
	attachment.Name = "LanceChargeAttachment"
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "LanceChargeVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.MaxForce = math.huge
	velocity.Parent = root

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local expiresAt = os.clock() + 2.5
	local hitTarget: Model? = nil
	while self.Equipped and humanoid.Health > 0 and os.clock() < expiresAt do
		local direction = root.CFrame.LookVector
		velocity.VectorVelocity = direction * 23
		local result = workspace:Raycast(root.Position, direction * self.ChargeRange, params)
		local target = result and result.Instance:FindFirstAncestorOfClass("Model")
		local targetHumanoid = target and target:FindFirstChildOfClass("Humanoid")
		if target and targetHumanoid and targetHumanoid.Health > 0 and target ~= character then
			hitTarget = target
			break
		end
		RunService.Heartbeat:Wait()
	end
	velocity:Destroy()
	attachment:Destroy()
	if charge and charge.IsPlaying then charge:Stop(0.08) end
	if hitTarget then self:_damageMeleeTarget(hitTarget, self.ChargeRange, self.ChargeDamage) end
	local stop = self:_playAnim("Charge_Stop")
	if stop then stop.Stopped:Wait() end
	-- A lance charge has recovery whether it hits, kills, or simply runs out.
	-- Freeze the same humanoid we charged with, then restore its live settings.
	local walkSpeed = humanoid.WalkSpeed
	local autoRotate = humanoid.AutoRotate
	humanoid.WalkSpeed = 0
	humanoid.AutoRotate = false
	task.wait(self.ChargeRecovery)
	if humanoid.Parent and humanoid.Health > 0 then
		humanoid.WalkSpeed = walkSpeed
		humanoid.AutoRotate = autoRotate
	end
	self.Charging = false
	self.ForceBlockFire = false
	self:_restoreBaseDeferred()
end

Lance.Tool_Image = ""
Lance.Weight = 2
Lance.Designation = "Primary"

return Lance
