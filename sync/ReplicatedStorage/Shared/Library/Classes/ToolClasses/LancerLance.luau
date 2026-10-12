--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Combat = require(script.Parent.Parent.MeleeController)

local Types = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local Assets = ReplicatedStorage.Shared.Assets
local AuthoredAssets = require(ReplicatedStorage.Shared.Library.AuthoredAssets)
local Playback = require(ReplicatedStorage.Shared.Library.SoundPlayback)

local Lance = {}
Lance.__index = Lance
setmetatable(Lance, { __index = BaseTool })

export type Lance = typeof(setmetatable({} :: any, Lance))

local function faction(owner: Player?): string
	if owner and owner.Team then return owner.Team.Name end
	local character = owner and owner.Character
	local team = character and character:FindFirstChild("team")
	if team and team:IsA("StringValue") and team.Value ~= "" then return team.Value end
	return "Royal Nation"
end

local function modelForFaction(owner: Player?): Model?
	local name = faction(owner) == "Golden Empire" and "empirelance" or "lance"
	local guns = Assets:FindFirstChild("Guns")
	local roots = {}
	local models = guns and guns:FindFirstChild("ToolModels")
	local equipment = Assets:FindFirstChild("Equipment")
	if models then table.insert(roots, models) end
	if equipment then table.insert(roots, equipment) end
	local source = AuthoredAssets.Find(name, roots) or AuthoredAssets.Find(name == "lance" and "Lance" or "EmpireLance", roots)
	if not source then warn("[Lance] Missing authored model: " .. name); return nil end
	if source:IsA("Model") then return source end
	if source:IsA("BasePart") or source:IsA("Folder") then
		local model = Instance.new("Model")
		model.Name = source.Name
		local clone = source:Clone()
		if clone:IsA("BasePart") then clone.Parent = model; model.PrimaryPart = clone
		else for _, child in clone:GetChildren() do child.Parent = model end; clone:Destroy() end
		return model
	end
	return nil
end

local function animationFolder(): Instance?
	local animations = Assets:FindFirstChild("Animations")
	local tools = animations and animations:FindFirstChild("Tools")
	local melee = tools and tools:FindFirstChild("Melee")
	local guns = tools and tools:FindFirstChild("Guns")
	return (melee and (melee:FindFirstChild("Lance") or melee:FindFirstChild("lance")))
		or (guns and (guns:FindFirstChild("Lance") or guns:FindFirstChild("lance")))
		or (tools and tools:FindFirstChild("lance"))
end

function Lance.new(info: Types.BaseToolCreateInfo): Lance
	local self = setmetatable(BaseTool.new(info), Lance)
	local owner = (info :: any).player or Players.LocalPlayer
	self.className = "LancerLance"
	self.name = "LancerLance"
	self.Display_Name = "Heavy Lance"
	self.item_image = faction(owner) == "Golden Empire" and "rbxassetid://83022012975342" or "rbxassetid://101804862805033"
	self.draw_speed = 1
	self.aim_speed = 0.5
	self.EquipWelds = {
		lefthand = false,
		equipc0 = CFrame.new(-0.334197998, -0.969068766, 0.2840271, 0, 0, -1, 0.999998391, 0, 0, 0, -0.99999845, 0),
		equipc1 = CFrame.identity,
	}
	self.AnimationGunType = "lance"
	self.Designation = "Primary"
	self.WeaponCategory = "Melee"
	self.model_reference = modelForFaction(owner)
	self.TeamModel = faction(owner)
	self.Can_Drop = false
	self.UseAuthoredGrip = true
	local animations = animationFolder()
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
		RaiseFlag = animations and animations:FindFirstChild("raise_flag"),
	}
	self.Melee_Damage = 130
	self.MeleeRange = 7
	self.StabDamage = 190
	self.StabRange = 10
	self.Charging = false
	self._meleeStep = 0
	local model = self.model_reference
	local hitbox = model and model:FindFirstChild("hitbox", true)
	local grip = hitbox and hitbox:IsA("BasePart") and hitbox
		or (model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)))
	if model and not grip then warn("[Lance] Authored model has no grip part: " .. model.Name) end
	self.motor_6d_data = {
		Parent = "Right Arm", Part0 = "Right Arm", Part1 = grip,
		C0 = self.EquipWelds.equipc0, C1 = self.EquipWelds.equipc1,
	}
	return self
end

local function chargeSound(name)
	local sounds = Assets:FindFirstChild("Sounds")
	local misc = sounds and sounds:FindFirstChild("misc")
	local sound = misc and misc:FindFirstChild(name)
	return sound and sound:IsA("Sound") and sound or nil
end

function Lance:_stopChargeAudio()
	if self._chargeHeartbeat then self._chargeHeartbeat:Destroy(); self._chargeHeartbeat = nil end
end

function Lance:aim()
	if self.Charging or self.Inspiring then return end
	BaseTool.aim(self)
end

function Lance:activate()
	if self.Charging or self.Inspiring or self.ForceBlockFire then return end
	Combat.Swing(self, self.Aiming and "Stab" or "Sweep")
end

function Lance:melee()
	self:activate()
end

function Lance:_on_give()
	self._combatConnection = Combat.Remote().OnClientEvent:Connect(function(kind)
		if not self.Equipped then return end
		if kind == "Charge" then
			self:_stopChargeAudio()
			local start = chargeSound("chargestart")
			if start then Playback.Play(start, workspace.CurrentCamera) end
			local heartbeat = chargeSound("charge_heartbeat")
			if heartbeat then
				self._chargeHeartbeat = heartbeat:Clone()
				self._chargeHeartbeat.Parent = workspace.CurrentCamera
				self._chargeHeartbeat:Play()
			end
			self.Charging = true; self.ForceBlockFire = true
			self:endAiming(); self:_stopAllExcept()
			local track = self:_playAnim("Charge")
			if track then track.Looped = true end
			if track then track:AdjustSpeed(1.5) end
		elseif kind == "ChargeStop" then
			self:_stopChargeAudio()
			local ending = chargeSound("chargeend")
			if ending then Playback.Play(ending, workspace.CurrentCamera) end
			self.Charging = false; self.ForceBlockFire = false
			self:_stopAllExcept()
			local track = self:_playAnim("Charge_Stop")
			if track then track:AdjustSpeed(1.5) end
			local generation = self._equipGeneration
			task.delay(1, function()
				if self.Equipped and self._equipGeneration == generation and not self.Charging then self:_restoreBase() end
			end)
		elseif kind == "CloseSweep" then
			self:_stopAllExcept(); self:_playAnim("Melee1")
		elseif kind == "Inspire" then
			self.Inspiring = true
			self:_stopAllExcept()
			self:_playAnim("RaiseFlag")
			local generation = self._equipGeneration
			task.delay(2.5, function()
				if self._equipGeneration ~= generation then return end
				self.Inspiring = false
				if self.Equipped then self:_restoreBase() end
			end)
		end
	end)
end

function Lance:_on_equip()
	self:_connectInput()
end

function Lance:_on_unequip()
	self:_stopChargeAudio()
	self.Charging = false
	self.Inspiring = false
	self.ForceBlockFire = false
	self:_disconnectInput()
	self:_stopAimTracking()
end

function Lance:setAltMode()
	if not self.Equipped or self.Equipping or self.Meleeing or self.Inspiring or self.Charging then return end
	local character = Players.LocalPlayer.Character
	if not character or character:GetAttribute("SprintProgress") ~= 1 then return end
	Combat.Remote():FireServer("Charge", Combat.Direction())
end

-- T is the existing Check Ammo binding; on the LancerLance it waves the flag.
function Lance:ammo_check()
	if self.Equipped and not self.Meleeing and not self.Charging and not self.Inspiring then Combat.Remote():FireServer("Inspire") end
end

function Lance:destroy()
	self:_stopChargeAudio()
	if self._combatConnection then self._combatConnection:Disconnect() end
	BaseTool.destroy(self)
end

Lance.Tool_Image = "rbxassetid://101804862805033"
Lance.Weight = 2
Lance.Designation = "Primary"
Lance.HiddenFromLoadout = true

return Lance
