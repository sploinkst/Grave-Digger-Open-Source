--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Parent.Types)
local BaseTool = require(script.Parent.Parent.BaseTool)
local MeleeAnimations = ReplicatedStorage.Shared.Assets.Animations.Tools.Utility
local Combat = require(script.Parent.Parent.MeleeController)

local Shield = {}
Shield.__index = Shield
setmetatable(Shield, { __index = BaseTool })

export type Shield = typeof(setmetatable({} :: any, Shield))

local function faction(character: Model?): string
	local team = character and character:FindFirstChild("team")
	if team and team:IsA("StringValue") and team.Value ~= "" then return team.Value end
	return (Players.LocalPlayer and Players.LocalPlayer.Team and Players.LocalPlayer.Team.Name) or "Royal Nation"
end

function Shield.new(info: Types.BaseToolCreateInfo): Shield
	local self = setmetatable(BaseTool.new(info), Shield)
	local owner = (info :: any).player or Players.LocalPlayer
	self.className = "shield"
	self.name = "shield"
	self.AnimationGunType = "vanguardshield"
	self.Designation = "Primary"
	self.WeaponCategory = "Melee"
	self.TeamModel = faction(owner and owner.Character)
	local modelName = self.TeamModel == "Golden Empire" and "empirevanguard" or "vanguardshield"
	local model = ReplicatedStorage.Shared.Assets.Equipment:FindFirstChild(modelName)
	self.model_reference = if model and model:IsA("Model") then model else nil
	self.Can_Drop = false
	self.UseAuthoredGrip = true
	local animations = MeleeAnimations:FindFirstChild("Shield")
	self.animations = {
		Aim = animations and (animations:FindFirstChild("shieldraised_aimed") or animations:FindFirstChild("aim_normal")),
		Aim_Normal = animations and animations:FindFirstChild("aim_normal"),
		Aim_Raised = animations and animations:FindFirstChild("shieldraised_aimed"),
		FullGuardAim = animations and animations:FindFirstChild("sword_fullguard_aimed"),
		FullGuardHold = animations and animations:FindFirstChild("sword_fullguard_idle"),
		Draw = animations and animations:FindFirstChild("draw"),
		Hold = animations and (animations:FindFirstChild("held") or animations:FindFirstChild("shieldraised_idle")),
		Hold_Normal = animations and animations:FindFirstChild("held"),
		Melee1 = animations and animations:FindFirstChild("melee1"),
		Melee2 = animations and animations:FindFirstChild("melee2"),
		Sprint = animations and (animations:FindFirstChild("sprint_normal") or animations:FindFirstChild("sprint")),
		Sprint_Normal = animations and animations:FindFirstChild("sprint_normal"),
		Sprint_Dual = animations and animations:FindFirstChild("sprint_dual"),
		Unequip = animations and animations:FindFirstChild("unequip"),
		ShieldPlant = animations and animations:FindFirstChild("shield_plant"),
		Blocked1 = animations and animations:FindFirstChild("blocked1"),
		Blocked2 = animations and animations:FindFirstChild("blocked2"),
		FoldInLeft = animations and animations:FindFirstChild("shield_foldin_left"),
		FoldInRight = animations and animations:FindFirstChild("shield_foldin_right"),
		FoldOutLeft = animations and animations:FindFirstChild("shield_foldout_left"),
		FoldOutRight = animations and animations:FindFirstChild("shield_foldout_right"),
	}
	local authored = ReplicatedStorage:FindFirstChild("ToolAnimations")
 authored = authored and authored:FindFirstChild("vanguardshield")
 for _, name in ipairs({"leftshield", "rightshield", "topshield"}) do
  self.animations["Replace_" .. name] = authored and authored:FindFirstChild("replace_" .. name)
  self.animations["Remove_" .. name] = authored and authored:FindFirstChild("remove_" .. name)
 end
 self.Melee_Damage = 90
	self.MeleeRange = 5
	local grip = self.model_reference and self.model_reference:FindFirstChild("hitbox", true)
	self.motor_6d_data = {
		Parent = "Left Arm", Part0 = "Left Arm", Part1 = grip,
		C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90)), C1 = CFrame.identity,
	}
	return self
end

function Shield:reload()
 if not self.Equipped or self:_isBusy() then return end
 if self.FullGuard then
  self:_playAnim("ShieldPlant")
  ReplicatedStorage.Shared.Library.Events:WaitForChild("ShieldAction"):FireServer(self.tool,"Plant")
 end
end

function Shield:ammo_check()
 if not self.Equipped or self:_isBusy() or not self.actual_model then return end
 local segments={}
 for _,name in ipairs({"leftshield","rightshield","topshield"}) do
  local segment=self.actual_model:FindFirstChild(name,true)
  local health=segment and segment:FindFirstChild("health")
  local maximum=health and (health:FindFirstChild("max") or health:FindFirstChild("maxhealth"))
  if maximum and (health.Value<=0 or name=="topshield" and health.Value<maximum.Value) then table.insert(segments,{name=name,health=health.Value}) end
 end
 table.sort(segments,function(a,b) return a.health<b.health end)
 local generation=self._equipGeneration
 self.Alting=true
 task.spawn(function()
  local selected={}
  local supplies=self.tool:GetAttribute("ShieldSupplies") or 2
  for index,segment in ipairs(segments) do
   if index>supplies then break end
   if not self.Equipped or self._equipGeneration~=generation then return end
   local model=self.actual_model:FindFirstChild(segment.name,true)
   local damaged=model and model:FindFirstChild("damagepart")
   if damaged and damaged.Transparency==0 then
    self:_playAnim("Remove_"..segment.name)
    task.wait(0.5)
    if not self.Equipped or self._equipGeneration~=generation then return end
    ReplicatedStorage.Shared.Library.Events:WaitForChild("ShieldAction"):FireServer(self.tool,"Remove",segment.name)
    task.wait(0.5)
   end
   table.insert(selected,segment)
  end
  for _,segment in ipairs(selected) do
   if not self.Equipped or self._equipGeneration~=generation then return end
   self:_playAnim("Replace_"..segment.name)
   task.wait(0.5)
   if not self.Equipped or self._equipGeneration~=generation then return end
   ReplicatedStorage.Shared.Library.Events:WaitForChild("ShieldAction"):FireServer(self.tool,"Replace",segment.name)
   task.wait(0.5)
  end
  if self.Equipped and self._equipGeneration==generation then self.Alting=false; self:_restoreBaseDeferred() end
 end)
end

function Shield:activate()
	if self.Alting then return end
	Combat.Swing(self, "ShieldSwing")
end

function Shield:_on_equip()
	self:_connectInput()
end

function Shield:_on_unequip()
	self.Alting=false
	self.FullGuard = false
	Combat.Remote():FireServer("Block", false)
	self:_disconnectInput()
	self:_stopAimTracking()
end

function Shield:melee()
	self:activate()
end

function Shield:aim()
	if not self.Equipped or self.Meleeing then return end
	BaseTool.aim(self)
	if self.FullGuard then self:_restoreBase() end
	Combat.Remote():FireServer("Block", true)
end

function Shield:endAiming()
	BaseTool.endAiming(self)
	Combat.Remote():FireServer("Block", self.FullGuard == true)
	if self.FullGuard then self:_restoreBase() end
end

function Shield:_aimTrack()
	local tracks = self.RegisteredAnimations
	if self.FullGuard and tracks and tracks.FullGuardAim then return tracks.FullGuardAim end
	return BaseTool._aimTrack(self)
end

function Shield:_restoreBase()
	local tracks = self.RegisteredAnimations
	if self.FullGuard and self.Equipped and not self:_isBusy() and tracks then
		local track = self.Aiming and tracks.FullGuardAim or tracks.FullGuardHold
		if track then
			self:_stopAllExcept(track)
			track.Looped = true
			track.Priority = Enum.AnimationPriority.Action2
			if not track.IsPlaying then track:Play(.1) end
			return
		end
	end
	BaseTool._restoreBase(self)
end

function Shield:setAltMode()
	if not self.Equipped or self.Equipping or self:_isBusy() then return end
	self.FullGuard = not self.FullGuard
	self:_stopAllExcept()
	Combat.Remote():FireServer("Block", self.FullGuard or self.Aiming == true)
	self:_restoreBase()
end

Shield.Tool_Image = ""
Shield.Weight = 2
Shield.Designation = "Primary"

return Shield
