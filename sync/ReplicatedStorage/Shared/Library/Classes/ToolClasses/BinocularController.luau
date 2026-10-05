local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Assets = require(RS.Shared.Library.AuthoredAssets)
local Tool = require(script.Parent.Parent.MasterTool)
local Class = {}; Class.__index=Class; setmetatable(Class,{__index=Tool})
function Class.new(info)
	return setmetatable(Tool.new(info,"Binoculars","binocs"),Class)
end
function Class:aim()
	if not self:Ready() then return end
	if self.RangeConnection then return end
	Tool.aim(self)
	local camera=workspace.CurrentCamera
	self.SavedFOV=camera.FieldOfView
	local core=Assets.CoreGame(); self.Overlay=core and core:FindFirstChild("binocsoverlay")
	if self.Overlay then self.Overlay.Visible=true end
	self.Zoom=65 / 3.5 / 1.5
	self.RangeConnection=RunService.RenderStepped:Connect(function()
		if not self.Aiming then return end
		Players.LocalPlayer.Character:SetAttribute("WeaponFOV",self.Zoom)
		local hit=self:Target(1000)
		local label=self.Overlay and self.Overlay:FindFirstChild("rangefinder")
		local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if label and hit and root then label.Text=math.ceil((root.Position-hit.Position).Magnitude).." studs" end
	end)
end
function Class:endAiming()
	Tool.endAiming(self)
	if self.ZoomConnection then self.ZoomConnection:Disconnect(); self.ZoomConnection=nil end
	if self.RangeConnection then self.RangeConnection:Disconnect(); self.RangeConnection=nil end
	if self.Overlay then self.Overlay.Visible=false end
	if Players.LocalPlayer.Character then Players.LocalPlayer.Character:SetAttribute("WeaponFOV",nil) end
	if self.SavedFOV and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=self.SavedFOV; self.SavedFOV=nil end
end
function Class:activate()
	if self:Ready() and self.Aiming then self:Action("Point",0.1,function() self:Request("ReconAction","Mark",self:Direction()) end) end
end
function Class:setAltMode()
	if self:Ready() and self.Aiming then self:Request("ReconAction","Ping",self:Direction()) end
end
function Class:reload()
	if self:Ready() and not self.Aiming then self:Action("Telescope",0.1,function() self:Request("ReconAction","Telescope") end,0.7) end
end
function Class:ammo_check()
	if self:Ready() and not self.Aiming then
		self:Action(self.current_shoulder=="Left" and "Flare" or "Flare_Right",0.5,function()
			self:Request("ReconAction","Flare",self:Direction())
		end,0.5)
	end
end
function Class:_on_unequip() self:endAiming(); Tool._on_unequip(self) end
function Class:destroy() self:endAiming(); Tool.destroy(self) end
Class.Weight=0; Class.Designation="Equipment"; Class.Tool_Image="rbxassetid://18693337243"
return Class
