--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Combat = require(script.Parent.Parent.MeleeController)

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
	return (Players.LocalPlayer and Players.LocalPlayer.Team and Players.LocalPlayer.Team.Name) or "Royal Nation"
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
	self.AnimationGunType = "lance"
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
		RaiseFlag = animations and animations:FindFirstChild("raise_flag"),
	}
	self.Melee_Damage = 130
	self.MeleeRange = 7
	self.StabDamage = 190
	self.StabRange = 10
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
	Combat.Swing(self, self.Aiming and "Stab" or "Sweep")
end

function Lance:melee()
	self:activate()
end

function Lance:_on_give()
	self._combatConnection = Combat.Remote().OnClientEvent:Connect(function(kind)
		if not self.Equipped then return end
		if kind == "Charge" then
			self.Charging = true; self.ForceBlockFire = true
			self:endAiming(); self:_stopAllExcept()
			local track = self:_playAnim("Charge")
			if track then track.Looped = true end
		elseif kind == "ChargeStop" then
			self.Charging = false; self.ForceBlockFire = false
			self:_stopAllExcept(); self:_playAnim("Charge_Stop")
			task.delay(1, function() if self.Equipped then self:_restoreBase() end end)
		elseif kind == "CloseSweep" then
			self:_stopAllExcept(); self:_playAnim("Melee1")
		elseif kind == "Inspire" then
			self.Inspiring = true
			self:_stopAllExcept()
			local track = self:_playAnim("RaiseFlag")
			task.delay(track and math.max(track.Length, 1) or 1, function()
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
	self.Charging = false
	self.ForceBlockFire = false
	self:_disconnectInput()
	self:_stopAimTracking()
end

function Lance:setAltMode()
	if not self.Equipped or self.Meleeing or self.Inspiring or self.Charging then return end
	Combat.Remote():FireServer("Charge", Combat.Direction())
end

-- T is the existing Check Ammo binding; on the lance it waves the flag.
function Lance:ammo_check()
	if self.Equipped and not self.Meleeing and not self.Charging then Combat.Remote():FireServer("Inspire") end
end

function Lance:destroy()
	if self._combatConnection then self._combatConnection:Disconnect() end
	BaseTool.destroy(self)
end

Lance.Tool_Image = ""
Lance.Weight = 2
Lance.Designation = "Primary"

return Lance
