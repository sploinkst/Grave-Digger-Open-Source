local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Assets = require(script.Parent.Parent.AuthoredAssets)
local Rules = require(script.Parent.Parent.MasterPortRules)
local MasterTool = require(script.Parent.MasterTool)
local Selection = require(RS.Shared.Modules["Client Modules"].MasterUI.SelectionView)
local Class = {}; Class.__index = Class; setmetatable(Class, {__index = MasterTool})
function Class.new(info, traps)
	local self = setmetatable(MasterTool.new(info, traps and "HunterKit" or "ConstructHammer", traps and "jaegerkit" or "hammer"), Class)
	self.Traps = traps; self.Placing = traps == true; self.Selected = traps and "Mantrap" or "Barricade"
	self.Options = traps and Rules.Traps or Rules.Constructs
	return self
end
function Class:_clearPreview()
	if self.Preview then self.Preview:Destroy(); self.Preview = nil end
	if self.Wire then self.Wire:Destroy(); self.Wire = nil end
	self.Placement = nil; self.ValidPlacement = false
end
function Class:_preview()
	if not self.Equipped or not self.Placing or self.View.Selecting then self:_clearPreview(); return end
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not workspace.CurrentCamera then return end
	local name = self.Traps and self.Aiming and "Tripwire" or self.Selected
	if self.Preview and self.Preview.Name ~= name then self:_clearPreview() end
	local template = Assets.Deployable(name)
	if not template then return end
	if not self.Preview then
		self.Preview = template:Clone(); self.Preview.Name = name
		for _, part in ipairs(self.Preview:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
				part.Transparency = part:IsDescendantOf(self.Preview:FindFirstChild("finished") or self.Preview) and 0.5 or 1
				part.Material = Enum.Material.SmoothPlastic
			elseif part:IsA("Decal") or part:IsA("Script") or part:IsA("LocalScript") then part:Destroy() end
		end
		self.Preview.Parent = workspace.CurrentCamera
	end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character, workspace.CurrentCamera}
	local forward = workspace:Raycast(root.Position, root.CFrame.LookVector * 4, params)
	local hit = if self.Traps then self:Target(name == "Tripwire" and 8 or 5)
		else workspace:Raycast(root.Position + root.CFrame.LookVector * 3, Vector3.new(0, -5, 0), params)
	if not hit then self.ValidPlacement = false; if self.Wire then self.Wire.Parent=nil end; return end
	local position = hit.Position + hit.Normal * 0.5
	self.Placement = if self.Traps then CFrame.lookAt(position, position - hit.Normal) * CFrame.Angles(math.pi / 2, 0, 0)
		else CFrame.new(position) * root.CFrame.Rotation
	self.Preview:PivotTo(self.Placement)
	local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = {character, workspace.CurrentCamera, hit.Instance}
	local bounding = self.Preview:FindFirstChild("bounding")
	self.ValidPlacement = (self.Traps or not forward) and hit.Instance.Name ~= "nobuild"
		and (not bounding or #workspace:GetPartBoundsInBox(bounding.CFrame, bounding.Size * 0.95, overlap) == 0)
	if name=="Tripwire" then
		local folder=workspace:FindFirstChild("constructions")
		local hook,distance
		for _,candidate in ipairs(folder and folder:GetChildren() or {}) do
			local target=candidate:FindFirstChild("fuse_hook")
			if target and candidate:FindFirstChild("tripwires") and not candidate:FindFirstChild("triggered")
				and candidate:GetAttribute("OwnerUserId")==Players.LocalPlayer.UserId then
				local d=(target.Position-position).Magnitude
				local obstruction=workspace:Raycast(position,target.Position-position,params)
				if d<=Rules.TripwireRange and (not distance or d<distance)
					and (not obstruction or obstruction.Instance:IsDescendantOf(candidate)) then hook=target; distance=d end
			end
		end
		self.ValidPlacement=self.ValidPlacement and hook~=nil
		if hook then
			if not self.Wire then
				self.Wire=Instance.new("Part"); self.Wire.Name="TripwirePreview"
				self.Wire.Anchored=true; self.Wire.Material=Enum.Material.SmoothPlastic; self.Wire.Transparency=0.5
				self.Wire.CanCollide=false; self.Wire.CanTouch=false; self.Wire.CanQuery=false
			end
			self.Wire.Size=Vector3.new(0.1,0.1,distance)
			self.Wire.CFrame=CFrame.lookAt(position,hook.Position)*CFrame.new(0,0,-distance/2)
			self.Wire.Color=self.ValidPlacement and Color3.new(0.9,0.9,0.9) or Color3.new(0.7,0.2,0.2)
			self.Wire.Parent=workspace.CurrentCamera
		elseif self.Wire then self.Wire.Parent=nil end
	elseif self.Wire then self.Wire:Destroy(); self.Wire=nil end
	for _, part in ipairs(self.Preview:GetDescendants()) do
		if part:IsA("BasePart") then part.Color = self.ValidPlacement and Color3.new(0.9, 0.9, 0.9) or Color3.new(0.7, 0.2, 0.2) end
	end
end
function Class:_on_equip()
	MasterTool._on_equip(self)
	if not self.View then
		self.View = Selection.new(function(name) self.Selected = name; self:_clearPreview() end,
			function() return self:Ready() end, "ConstructionSelecting",function()
				local choosing=self.RegisteredAnimations and self.RegisteredAnimations.Choosing
				if choosing then choosing:Stop(0.1) end; self:_restoreBaseDeferred()
			end)
	end
	self.RenderConnection = RunService.RenderStepped:Connect(function() self:_preview() end)
end
function Class:_on_unequip()
	if self.RenderConnection then self.RenderConnection:Disconnect(); self.RenderConnection = nil end
	self:_clearPreview(); MasterTool._on_unequip(self)
end
function Class:reload()
	if not self:Ready() then return end
	if self.View.Selecting then self.View:Close(); return end
	local entries = {}
	for _, name in ipairs(self.Options) do table.insert(entries, {id = name, name = name, icon = Rules.Icons[name]}) end
	if self.View:Open(Players.LocalPlayer.Character, entries) then self:_playAnim("Choosing") end
end
function Class:setAltMode()
	if not self:Ready() or self.Traps then return end
	self.Placing = not self.Placing
	if not self.Placing then self:_clearPreview() end
end
function Class:ammo_check()
	if self:Ready() then self:Request("ConstructionAction", "DestroyAll", self.Selected) end
end
function Class:activate()
	if not self:Ready() or self.View.Selecting then return end
	if self.Placing then
		if self.ValidPlacement then self:Request("ConstructionAction", "Place", {name = self.Preview.Name, cframe = self.Placement}) end
	else
		self:Action("Melee1", 0.2, function() self:Request("ConstructionAction", "Hammer", self:Direction()) end)
	end
end
function Class:destroy() self:_on_unequip(); MasterTool.destroy(self) end
return Class
