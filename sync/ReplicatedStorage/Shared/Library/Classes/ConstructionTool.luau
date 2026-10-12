local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Assets = require(script.Parent.Parent.AuthoredAssets)
local Rules = require(script.Parent.Parent.MasterPortRules)
local MasterTool = require(script.Parent.MasterTool)
local Selection = require(RS.Shared.Modules["Client Modules"].MasterUI.SelectionView)

local Utils = require(RS:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild('Util'))
local VALID_COLOR = Color3.new(0.9, 0.9, 0.9)
local INVALID_COLOR = Color3.new(0.7, 0.2, 0.2)
local PREVIEW_TRANSPARENCY = 0.5
local HAMMER_WINDUP = 0.2
local FORWARD_CHECK_DISTANCE = 4
local GROUND_CHECK_DISTANCE = 5
local GROUND_CHECK_FORWARD_OFFSET = 3
local TRIPWIRE_REACH = 8
local TRAP_REACH = 5

local Class = {}
Class.__index = Class
setmetatable(Class, { __index = MasterTool })

--// Helpers

local function validColor(isValid)
	return if isValid then VALID_COLOR else INVALID_COLOR
end

-- Turns a cloned deployable into a non-interactive ghost.
local function preparePreview(model)
	local finished = model:FindFirstChild("finished") or model

	for _, inst in model:GetDescendants() do
		if inst:IsA("BasePart") then
			inst.Anchored = true
			inst.CanCollide = false
			inst.CanTouch = false
			inst.CanQuery = false
			inst.Material = Enum.Material.SmoothPlastic
			inst.Transparency = if inst:IsDescendantOf(finished) then PREVIEW_TRANSPARENCY else 1
		elseif inst:IsA("Decal") or inst:IsA("Script") or inst:IsA("LocalScript") then
			inst:Destroy()
		end
	end
end

local function tintPreview(model, color)
	for _, inst in model:GetDescendants() do
		if inst:IsA("BasePart") then
			inst.Color = color
		end
	end
end

local function makeWire()
	local wire = Instance.new("Part")
	wire.Name = "TripwirePreview"
	wire.Anchored = true
	wire.CanCollide = false
	wire.CanTouch = false
	wire.CanQuery = false
	wire.Material = Enum.Material.SmoothPlastic
	wire.Transparency = PREVIEW_TRANSPARENCY
	return wire
end

-- Finds the closest unobstructed fuse hook owned by the local player.
local function findNearestHook(position, raycastParams)
	local folder = workspace:FindFirstChild("constructions")
	if not folder then
		return nil, nil
	end

	local userId = Players.LocalPlayer.UserId
	local bestHook, bestDistance

	for _, construct in folder:GetChildren() do
		local hook = construct:FindFirstChild("fuse_hook")
		if
			hook
			and construct:FindFirstChild("tripwires")
			and not construct:FindFirstChild("triggered")
			and construct:GetAttribute("OwnerUserId") == userId
		then
			local offset = hook.Position - position
			local distance = offset.Magnitude

			if distance <= Rules.TripwireRange and (not bestDistance or distance < bestDistance) then
				local obstruction = workspace:Raycast(position, offset, raycastParams)
				if not obstruction or obstruction.Instance:IsDescendantOf(construct) then
					bestHook, bestDistance = hook, distance
				end
			end
		end
	end

	return bestHook, bestDistance
end

--// Construction

function Class.new(info, traps)
	local self = setmetatable(
		MasterTool.new(info, traps and "HunterKit" or "ConstructHammer", traps and "jaegerkit" or "hammer"),
		Class
	)

	self.Traps = traps
	self.Placing = traps == true
	self.Selected = if traps then "Mantrap" else "Barricade"
	self.Options = if traps then Rules.Traps else Rules.Constructs

	return self
end

--// Preview

function Class:_clearPreview()
	if self.Preview then
		self.Preview:Destroy()
		self.Preview = nil
	end
	if self.Wire then
		self.Wire:Destroy()
		self.Wire = nil
	end
	self.Placement = nil
	self.ValidPlacement = false
end

function Class:_ensurePreview(name)
	if self.Preview and self.Preview.Name ~= name then
		self:_clearPreview()
	end

	if self.Preview then
		return true
	end

	local template = Assets.Deployable(name)
	if not template then
		return false
	end

	local preview = template:Clone()
	preview.Name = name
	preparePreview(preview)
	preview.Parent = workspace.CurrentCamera
	self.Preview = preview

	return true
end

function Class:_updateWire(position, hook, distance)
	if not hook then
		if self.Wire then
			self.Wire.Parent = nil
		end
		return
	end

	if not self.Wire then
		self.Wire = makeWire()
	end

	local wire = self.Wire
	wire.Size = Vector3.new(0.1, 0.1, distance)
	wire.CFrame = CFrame.lookAt(position, hook.Position) * CFrame.new(0, 0, -distance / 2)
	wire.Color = validColor(self.ValidPlacement)
	wire.Parent = workspace.CurrentCamera
end

function Class:_preview()
	if not self.Equipped or not self.Placing or self.View.Selecting then
		self:_clearPreview()
		return
	end

	local camera = workspace.CurrentCamera
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not camera then
		return
	end

	local isTripwire = self.Traps and self.Aiming
	local name = if isTripwire then "Tripwire" else self.Selected
	if not self:_ensurePreview(name) then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character, camera }

	-- Find where we're trying to place
	local look = root.CFrame.LookVector
	local hit
	if self.Traps then
		hit = self:Target(if isTripwire then TRIPWIRE_REACH else TRAP_REACH)
	else
		hit = workspace:Raycast(
			root.Position + look * GROUND_CHECK_FORWARD_OFFSET,
			Vector3.new(0, -GROUND_CHECK_DISTANCE, 0),
			raycastParams
		)
	end

	if not hit then
		self.ValidPlacement = false
		if self.Wire then
			self.Wire.Parent = nil
		end
		return
	end

	local position = hit.Position + hit.Normal * 0.5
	if self.Traps then
		self.Placement = CFrame.lookAt(position, position - hit.Normal) * CFrame.Angles(math.pi / 2, 0, 0)
	else
		self.Placement = CFrame.new(position) * root.CFrame.Rotation
	end
	self.Preview:PivotTo(self.Placement)

	-- Validate placement
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { character, camera, hit.Instance }

	local blockedAhead = not self.Traps and workspace:Raycast(root.Position, look * FORWARD_CHECK_DISTANCE, raycastParams)
	local bounding = self.Preview:FindFirstChild("bounding")
	local overlapping = bounding
		and #workspace:GetPartBoundsInBox(bounding.CFrame, bounding.Size * 0.95, overlapParams) > 0

	self.ValidPlacement = not blockedAhead and hit.Instance.Name ~= "nobuild" and not overlapping

	-- Tripwires also need a hook to attach to
	if isTripwire then
		local hook, distance = findNearestHook(position, raycastParams)
		self.ValidPlacement = self.ValidPlacement and hook ~= nil
		self:_updateWire(position, hook, distance)
	elseif self.Wire then
		self.Wire:Destroy()
		self.Wire = nil
	end

	tintPreview(self.Preview, validColor(self.ValidPlacement))
end

--// Tool callbacks

function Class:_on_equip()
	MasterTool._on_equip(self)

	if not self.View then
		self.View = Selection.new(function(name)
			self.Selected = name
			self:_clearPreview()
		end, function()
			return self:Ready()
		end, "ConstructionSelecting", function()
			local choosing = self.RegisteredAnimations and self.RegisteredAnimations.Choosing
			if choosing then
				choosing:Stop(0.1)
			end
			self:_restoreBaseDeferred()
		end)
	end

	self.RenderConnection = RunService.RenderStepped:Connect(function()
		self:_preview()
	end)
end

function Class:_on_unequip()
	if self.RenderConnection then
		self.RenderConnection:Disconnect()
		self.RenderConnection = nil
	end
	self:_clearPreview()
	Utils.CloseSelectionUI()
	MasterTool._on_unequip(self)
end

function Class:reload()
	if not self:Ready() then
		return
	end

	if self.View.Selecting then
		self.View:Close()
		return
	end

	local entries = {}
	for _, name in self.Options do
		table.insert(entries, { id = name, name = name, icon = Rules.Icons[name] })
	end

	if self.View:Open(Players.LocalPlayer.Character, entries) then
		self:_playAnim("Choosing")
	end
end

function Class:setAltMode()
	if not self:Ready() or self.Traps then
		return
	end

	self.Placing = not self.Placing
	if not self.Placing then
		self:_clearPreview()
	end
	
	Utils.CreateSelectionUI("Medical", function(selection)
		
	end)
end

function Class:ammo_check()
	if self:Ready() then
		self:Request("ConstructionAction", "DestroyAll", self.Selected)
	end
end

function Class:activate()
	if not self:Ready() or self.View.Selecting then
		return
	end

	if self.Placing then
		if self.ValidPlacement then
			self:Request("ConstructionAction", "Place", {
				name = self.Preview.Name,
				cframe = self.Placement,
			})
		end
	else
		self:Action("Melee1", HAMMER_WINDUP, function()
			self:Request("ConstructionAction", "Hammer", self:Direction())
		end)
	end
end

function Class:destroy()
	self:_on_unequip()
	MasterTool.destroy(self)
end

return Class