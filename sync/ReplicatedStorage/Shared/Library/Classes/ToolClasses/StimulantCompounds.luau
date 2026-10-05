local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local BaseTool = require(script.Parent.Parent.BaseTool)
local MixtureView = require(RS.Shared.Modules["Client Modules"].MedicalUI.MixtureView)
local Compounds = setmetatable({}, {__index = BaseTool})
Compounds.__index = Compounds
Compounds.Weight = 0
Compounds.Designation = "Equipment"
Compounds.Medal_Cost = 0
Compounds.Tool_Image = "rbxassetid://17778483374"

function Compounds.new(info)
	local self = setmetatable(BaseTool.new(info), Compounds)
	self.className = "StimulantCompounds"; self.name = self.className
	self.Designation = "Equipment"; self.Can_Drop = false
	self.item_image = Compounds.Tool_Image
	self.AnimationGunType = "stimbottle"
	self.AnimationPlayback={Load={speed=1.5,fade=0.1},Ready={speed=1.5,fade=0.1},
		Throw={speed=2,fade=0.1},Discard={speed=1.5,fade=0.2}}
	self.model_reference = RS.Shared.Assets.Guns.ToolModels:FindFirstChild("stimbottle")
	self.UseAuthoredGrip = true
	self.motor_6d_data = {Parent = "Right Arm", Part0 = "Right Arm",
		Part1 = self.model_reference and self.model_reference:FindFirstChild("hitbox", true), C0 = CFrame.new(0, -1, 0)}
	return self
end

function Compounds:_prepareAnimations()
	local folder = RS:FindFirstChild("ToolAnimations")
	folder = folder and folder:FindFirstChild("stimbottle")
	self.animations = {}
	for binding, name in {Draw = "draw", Hold = "held", Load = "load", Ready = "ready", Throw = "throw_over", Discard = "new", Choosing = "choosing", Check = "checkstim"} do
		local clip = folder and folder:FindFirstChild(name, true)
		if not clip and binding == "Discard" then clip = folder and folder:FindFirstChild("unload", true) end
		if clip then self.animations[binding] = clip end
	end
end

function Compounds:_remote()
	return RS.Shared.Library.Events:WaitForChild("StimulantCompounds")
end

function Compounds:_ready()
	local character = Players.LocalPlayer.Character
	return self.Equipped and not self.Equipping and os.clock() >= (self.NextAction or 0) and self.tool and self.tool.Parent == character
		and character and not Players.LocalPlayer:GetAttribute("MenuOpen") and not character:GetAttribute("ActionBlocked")
end

-- Tool actions stay here; UI and bloodstream behavior belong to services.
function Compounds:_action(animation, seconds, action, argument)
	self.NextAction = os.clock() + seconds
	if action then self:_remote():FireServer(action, argument) end
	if self.RegisteredAnimations and self.RegisteredAnimations[animation] then self:_playAnim(animation) end
end

function Compounds:_mix(name)
	if not self:_ready() then return end
	if (Players.LocalPlayer.Character:GetAttribute("StimulantSupplies") or 0) <= 0 then
		self:notify("No Supplies left. Restock at a Resupply Cache."); return
	end
	self.View:CloseSelector()
	if self.RegisteredAnimations and self.RegisteredAnimations.Choosing then self.RegisteredAnimations.Choosing:Stop(0.1) end
	self:_action("Load", 0.73, "Mix", name)
end

function Compounds:_on_equip()
	self:_connectInput()
	if not self.View then
		self.View = MixtureView.new(function(name) self:_mix(name) end, function() return self:_ready() end, function()
			local choosing = self.RegisteredAnimations and self.RegisteredAnimations.Choosing
			if choosing then choosing:Stop(0.1) end
		end)
	end
	self.View:Show(Players.LocalPlayer.Character)
end
function Compounds:_on_unequip()
	self.ThrowGeneration=(self.ThrowGeneration or 0)+1; self.NextAction=0
	if self.View then self.View:Hide() end
end
function Compounds:setAltMode()
	if not self:_ready() then return end
	self.View:ToggleSelector()
	local choosing = self.RegisteredAnimations and self.RegisteredAnimations.Choosing
	if choosing then
		if self.View.Selecting then self:_playAnim("Choosing") else choosing:Stop(0.1) end
	end
end
function Compounds:ammo_check()
	if not self:_ready() then return end
	self.View:CloseSelector(); self.View:ToggleEffects()
	self:_action("Check", 1)
end
function Compounds:reload()
	if not self:_ready() then return end
	self.View:CloseSelector()
	self:_action("Discard", 0.75, "Discard")
end
function Compounds:activate()
	if not self:_ready() or self.View.Selecting then return end
	local ok, mix = pcall(HttpService.JSONDecode, HttpService, Players.LocalPlayer.Character:GetAttribute("StimulantMixture") or "[]")
	if not ok or #mix == 0 then self:notify("The bottle is empty. Press Q to mix chemicals."); return end
	local camera = workspace.CurrentCamera
	if not camera then return end
	local point = UIS:GetMouseLocation()
	local direction=camera:ScreenPointToRay(point.X, point.Y).Direction.Unit
	self.ThrowGeneration=(self.ThrowGeneration or 0)+1
	local generation=self.ThrowGeneration
	local character=Players.LocalPlayer.Character
	local function active() return self.Equipped and self.ThrowGeneration==generation and self.tool.Parent==character end
	self.NextAction=os.clock()+1.95
	self:_playAnim("Ready")
	task.delay(0.7,function()
		if not active() then return end
		self:_playAnim("Throw"); self:_remote():FireServer("Throw",direction)
		task.delay(0.5,function()
			if not active() then return end
			local throwing=self.RegisteredAnimations and self.RegisteredAnimations.Throw
			if throwing then throwing:Stop(0.2) end
			self:_playAnim("Discard")
		end)
	end)
end
function Compounds:aim() end
function Compounds:endAiming() end
function Compounds:destroy()
	self.ThrowGeneration = (self.ThrowGeneration or 0) + 1
	if self.View then self.View:Destroy(); self.View = nil end
	BaseTool.destroy(self)
end
return Compounds
