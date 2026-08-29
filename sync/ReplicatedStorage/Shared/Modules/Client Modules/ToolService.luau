local Module = {}

local LocalPlayer = game:GetService("Players").LocalPlayer
local GameData = LocalPlayer:WaitForChild("GameData")
local AccessoryFolder = GameData:WaitForChild("Accessorys")
local HolsterFolder = AccessoryFolder:WaitForChild("Holsters")
local ToolHolsterFolder = game:GetService("ReplicatedStorage").Shared.Assets.Guns.Holsters:FindFirstChild("Tool Holsters")
local GunClasses = game:GetService("ReplicatedStorage").Shared.Library.Classes.GunClasses
local ToolClasses = game:GetService("ReplicatedStorage").Shared.Library.Classes.ToolClasses
local InventoryService = require(script.Parent.InventoryService)
local UtilModule = require(script.Parent.Parent.Parent.Library.Util)

Module.RegisteredTools = {}

-- // Tracks live ChildAdded/ChildRemoved connections per backpack
local backpackConnections = {}

-- Disconnect the old tool before removing it from the registry.
local function DestroyToolInstance(instance)
	if not instance then return end

	if type(instance.Destroy) == "function" then
		instance:Destroy()
	elseif type(instance.destroy) == "function" then
		instance:destroy()
	end
end

local function ConnectBackpack(backpack)
	print("[ToolService] ConnectBackpack called on:", backpack:GetFullName())

	local existingConnections = backpackConnections[backpack]
	if existingConnections then
		existingConnections.added:Disconnect()
		existingConnections.removed:Disconnect()
		backpackConnections[backpack] = nil
		print("[ToolService] Disconnected previous listeners on:", backpack:GetFullName())
	end

	local addedConnection = backpack.ChildAdded:Connect(function(child)
		print("[ToolService] ChildAdded fired:", child.Name, "| IsA Tool:", child:IsA("Tool"))

		if not child:IsA("Tool") then
			print("[ToolService] Skipping non-tool:", child.Name)
			return
		end

		-- // Yield one frame so the tool's properties finish replicating
		task.wait()

		if not child.Parent then
			print("[ToolService] Tool removed before registration could complete:", child.Name)
			return
		end

		if Module.RegisteredTools[child] then
			print("[ToolService] Tool already registered, skipping:", child.Name)
			return
		end

		print("[ToolService] Looking up class for:", child.Name)
		local moduleScript =
			GunClasses:FindFirstChild(child.Name, true)
			or ToolClasses:FindFirstChild(child.Name, true)

		if not moduleScript then
			warn("[ToolService] No class found for item:", child.Name)
			return
		end

		print("[ToolService] Found class module:", moduleScript:GetFullName())

		local class = require(moduleScript)
		local instance = class.new({ name = child.Name })
		instance:on_give(child)
		Module.RegisteredTools[child] = instance
		InventoryService.AssignTool(instance)
		print("[ToolService] Successfully registered tool:", child.Name)
	end)

	local removedConnection = backpack.ChildRemoved:Connect(function(child)
		if not child:IsA("Tool") then
			return
		end
		print("[ToolService] ChildRemoved fired:", child.Name)

		local instance = Module.RegisteredTools[child]
		if not instance then
			print("[ToolService] No registered instance found for removed tool:", child.Name)
			return
		end

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(child.Name) then
			print("[ToolService] Tool moved to character, not removing from registry:", child.Name)
			return
		end

		InventoryService.RemoveTool(instance)
		DestroyToolInstance(instance)
		Module.RegisteredTools[child] = nil
		print("[ToolService] Removed tool from registry:", child.Name)
	end)

	backpackConnections[backpack] = { added = addedConnection, removed = removedConnection }

	-- // Scan anything already in the backpack at connect time
	local existing = backpack:GetChildren()
	print("[ToolService] Scanning existing backpack children, count:", #existing)

	for _, child in ipairs(existing) do
		if not child:IsA("Tool") then
			continue
		end
		if Module.RegisteredTools[child] then
			print("[ToolService] Already registered (scan):", child.Name)
			continue
		end

		print("[ToolService] Registering existing tool (scan):", child.Name)

		local moduleScript =
			GunClasses:FindFirstChild(child.Name, true)
			or ToolClasses:FindFirstChild(child.Name, true)

		if not moduleScript then
			warn("[ToolService] No class found for item (scan):", child.Name)
			continue
		end

		local class = require(moduleScript)
		local instance = class.new({ name = child.Name })
		instance:on_give(child)
		Module.RegisteredTools[child] = instance
		InventoryService.AssignTool(instance)
		print("[ToolService] Registered existing tool (scan):", child.Name)
	end

	print("[ToolService] ConnectBackpack finished for:", backpack:GetFullName())
end

local function WaitForInventoryReady(character)
	if character:GetAttribute("InventoryReady") == true then
		return
	end

	local deadline = tick() + 10
	while character:GetAttribute("InventoryReady") ~= true do
		if tick() > deadline then
			warn("[ToolService] Timed out waiting for InventoryReady on", character.Name, "- scanning backpack anyway.")
			return
		end
		character:GetAttributeChangedSignal("InventoryReady"):Wait()
	end
end

function Module.start_module()
	print("[ToolService] StartModule called")

	if LocalPlayer.Character then
		WaitForInventoryReady(LocalPlayer.Character)
	end
	ConnectBackpack(LocalPlayer:WaitForChild("Backpack"))

	LocalPlayer.CharacterAdded:Connect(function(character)
		print("[ToolService] CharacterAdded fired, resetting registered tools")
		-- Disconnect old tools before scanning the backpack again.
		for _, instance in pairs(Module.RegisteredTools) do
			InventoryService.RemoveTool(instance)
			DestroyToolInstance(instance)
		end
		Module.RegisteredTools = {}
		WaitForInventoryReady(character)
		local backpack = LocalPlayer:WaitForChild("Backpack")
		print("[ToolService] Connecting to backpack:", backpack:GetFullName())
		ConnectBackpack(backpack)
	end)

	print("[ToolService] StartModule finished, waiting for tools...")
end

return Module
