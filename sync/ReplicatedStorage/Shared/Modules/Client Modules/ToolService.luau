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
local DebugEnabled = false

local function Debug(...)
	if DebugEnabled then
		print("[ToolService]", ...)
	end
end

local function DestroyToolInstance(instance)
	if not instance then
		Debug("DestroyToolInstance called with nil instance")
		return
	end

	Debug("Destroying controller:", instance.name or instance.Name or tostring(instance))

	if type(instance.Destroy) == "function" then
		instance:Destroy()
	elseif type(instance.destroy) == "function" then
		instance:destroy()
	else
		Debug("WARNING: Controller has no Destroy/destroy method")
	end
end

local function RegisterTool(tool: Tool, equipImmediately: boolean?)
	Debug("========================================")
	Debug("RegisterTool called:", tool:GetFullName())
	Debug("Tool name:", tool.Name)
	Debug("Tool parent:", tool.Parent and tool.Parent:GetFullName() or "nil")
	Debug("equipImmediately:", equipImmediately)

	if Module.RegisteredTools[tool] then
		Debug("Tool is ALREADY registered:", tool.Name)
		Debug("Existing controller:", Module.RegisteredTools[tool])
		return Module.RegisteredTools[tool]
	end

	local controllerName = tool.Name == "TrenchWhistleTool" and "TrenchWhistle" or tool.Name

	Debug("Looking for controller:", controllerName)

	local moduleScript =
		GunClasses:FindFirstChild(controllerName, true)
		or ToolClasses:FindFirstChild(controllerName, true)

	if not moduleScript then
		warn("[ToolService] No class found for item:", tool.Name)
		Debug("FAILED: No module script found for:", controllerName)
		return nil
	end

	Debug("Found controller module:", moduleScript:GetFullName())

	local class = require(moduleScript)

	Debug("Required controller module successfully")
	Debug("Creating controller instance...")

	local instance = class.new({ name = tool.Name })
	local inventorySlot = tool:FindFirstChild("slot")
	if inventorySlot and inventorySlot:IsA("StringValue") and inventorySlot.Value ~= "" then
		instance.Designation = inventorySlot.Value
	end

	Debug("Controller instance created:", instance)

	Debug("Calling instance:on_give()...")
	local give_success, give_error = xpcall(function()
		instance:on_give(tool)
	end, debug.traceback)

	if not give_success then
		warn("[ToolService] on_give() ERROR for", tool.Name, "\n", give_error)
		Debug("on_give FAILED")
		return nil
	end

	Debug("on_give() completed successfully")

	Module.RegisteredTools[tool] = instance

	Debug("RegisteredTools entry created")
	Debug("Registered controller:", instance)
	Debug("Registered tool parent:", tool.Parent and tool.Parent:GetFullName() or "nil")

	tool.Destroying:Connect(function()
		Debug("Tool.Destroying fired:", tool.Name)

		InventoryService.RemoveTool(instance)
		DestroyToolInstance(instance)
		Module.RegisteredTools[tool] = nil

		Debug("Removed controller from RegisteredTools:", tool.Name)
	end)

	if tool.Name ~= "TrenchWhistleTool" then
		Debug("Calling InventoryService.AssignTool()...")

		local assign_success, assign_error = xpcall(function()
			InventoryService.AssignTool(instance)
		end, debug.traceback)

		if not assign_success then
			warn("[ToolService] InventoryService.AssignTool() ERROR for", tool.Name, "\n", assign_error)
			Debug("AssignTool FAILED")
		else
			Debug("InventoryService.AssignTool() completed successfully")
		end

		if tool:GetAttribute("EquipThroughInventory") == true then
			task.defer(function()
				if Module.RegisteredTools[tool] == instance then
					InventoryService.EquipTool(instance)
				end
			end)
		end
	else
		Debug("Skipping InventoryService.AssignTool() for whistle")
	end

	Debug("Checking InstantEquip...")
	Debug("instance.InstantEquip =", instance.InstantEquip)

	if instance.InstantEquip and instance.InstantEquip == true then
		Debug("InstantEquip is TRUE")
		Debug("Scheduling automatic equip...")

		task.defer(function()
			Debug("========== INSTANT EQUIP START ==========")
			Debug("Tool:", tool.Name)
			Debug("Current tool parent:", tool.Parent and tool.Parent:GetFullName() or "nil")
			Debug("Current character:", LocalPlayer.Character and LocalPlayer.Character:GetFullName() or "nil")
			Debug("Registered controller:", Module.RegisteredTools[tool])

			if not tool.Parent then
				Debug("WARNING: Tool has no parent before equip")
			end

			if tool.Parent ~= LocalPlayer.Character then
				Debug("WARNING: Tool is NOT parented to Character")
				Debug("Expected:", LocalPlayer.Character and LocalPlayer.Character:GetFullName() or "nil")
				Debug("Actual:", tool.Parent and tool.Parent:GetFullName() or "nil")
			end

			if Module.RegisteredTools[tool] ~= instance then
				Debug("WARNING: RegisteredTools controller does not match instance")
			else
				Debug("RegisteredTools controller matches instance")
			end

			if type(instance.equip) ~= "function" then
				Debug("ERROR: instance.equip is not a function")
				Debug("Actual type:", typeof(instance.equip))
				return
			end

			Debug("Calling instance:equip()...")

			local equip_success, equip_error = xpcall(function()
				instance:equip()
			end, debug.traceback)

			if not equip_success then
				warn("[ToolService] instance:equip() ERROR for", tool.Name, "\n", equip_error)
				Debug("EQUIP FAILED")
			else
				Debug("instance:equip() completed successfully")
			end

			Debug("Tool parent AFTER equip:", tool.Parent and tool.Parent:GetFullName() or "nil")
			Debug("Character AFTER equip:", LocalPlayer.Character and LocalPlayer.Character:GetFullName() or "nil")
			Debug("========== INSTANT EQUIP END ==========")
		end)
	else
		Debug("InstantEquip is FALSE/nil; skipping automatic equip")
	end

	Debug("RegisterTool completed:", tool.Name)
	Debug("========================================")

	return instance
end

-- // The whistle is created and equipped by the server in the same frame.
local function RegisterWhistleTool(tool)
	Debug("RegisterWhistleTool called:", tool.Name)

	if tool.Name ~= "TrenchWhistleTool" then
		Debug("Not a whistle, skipping")
		return
	end

	if Module.RegisteredTools[tool] then
		Debug("Whistle already registered")
		return
	end

	Debug("Registering whistle")
	RegisterTool(tool, tool.Parent == LocalPlayer.Character)
end

local function ConnectBackpack(backpack)
	Debug("========================================")
	Debug("ConnectBackpack called:", backpack:GetFullName())

	local existingConnections = backpackConnections[backpack]

	if existingConnections then
		Debug("Existing backpack connections found; disconnecting")

		existingConnections.added:Disconnect()
		existingConnections.removed:Disconnect()

		backpackConnections[backpack] = nil

		Debug("Previous backpack listeners disconnected")
	end

	local addedConnection = backpack.ChildAdded:Connect(function(child)
		Debug("Backpack.ChildAdded:", child.Name)
		Debug("Class:", child.ClassName)

		if not child:IsA("Tool") then
			Debug("Skipping non-tool:", child.Name)
			return
		end

		Debug("Tool entered backpack:", child.Name)

		task.wait()

		Debug("After replication wait")
		Debug("Tool parent:", child.Parent and child.Parent:GetFullName() or "nil")

		if not child.Parent then
			Debug("Tool removed before registration:", child.Name)
			return
		end

		if Module.RegisteredTools[child] then
			Debug("Tool already registered:", child.Name)
			return
		end

		Debug("Beginning registration from Backpack.ChildAdded")

		local instance = RegisterTool(child, false)

		if not instance then
			Debug("Registration FAILED:", child.Name)
			return
		end

		Debug("Successfully registered:", child.Name)
	end)

	local removedConnection = backpack.ChildRemoved:Connect(function(child)
		if not child:IsA("Tool") then
			return
		end

		Debug("Backpack.ChildRemoved:", child.Name)
		Debug("Tool new parent:", child.Parent and child.Parent:GetFullName() or "nil")

		local instance = Module.RegisteredTools[child]

		if not instance then
			Debug("No registered instance for removed tool:", child.Name)
			return
		end

		if LocalPlayer.Character and child.Parent == LocalPlayer.Character then
			Debug("Tool moved into Character; keeping registered:", child.Name)
			return
		end

		Debug("Tool genuinely left Backpack and Character:", child.Name)

		if child.Name ~= "TrenchWhistleTool" then
			Debug("Calling InventoryService.RemoveTool()")

			local remove_success, remove_error = xpcall(function()
				InventoryService.RemoveTool(instance)
			end, debug.traceback)

			if not remove_success then
				warn("[ToolService] RemoveTool ERROR for", child.Name, "\n", remove_error)
			end
		end

		DestroyToolInstance(instance)
		Module.RegisteredTools[child] = nil

		Debug("Removed tool from registry:", child.Name)
	end)

	backpackConnections[backpack] = {
		added = addedConnection,
		removed = removedConnection
	}

	Debug("Backpack connections created")

	local existing = backpack:GetChildren()

	Debug("Scanning existing backpack children:", #existing)

	for _, child in ipairs(existing) do
		if not child:IsA("Tool") then
			continue
		end

		Debug("Existing backpack tool:", child.Name)

		if Module.RegisteredTools[child] then
			Debug("Already registered:", child.Name)
			continue
		end

		Debug("Registering existing backpack tool:", child.Name)

		local instance = RegisterTool(child, false)

		if instance then
			Debug("Existing tool registered successfully:", child.Name)
		else
			Debug("Existing tool registration FAILED:", child.Name)
		end
	end

	Debug("ConnectBackpack finished:", backpack:GetFullName())
	Debug("========================================")
end

local function WaitForInventoryReady(character)
	Debug("Waiting for InventoryReady:", character.Name)

	if character:GetAttribute("InventoryReady") == true then
		Debug("InventoryReady already true")
		return
	end

	local deadline = tick() + 10

	while character:GetAttribute("InventoryReady") ~= true do
		if tick() > deadline then
			warn("[ToolService] Timed out waiting for InventoryReady on", character.Name)
			Debug("Continuing despite InventoryReady timeout")
			return
		end

		Debug("Waiting for InventoryReady attribute...")
		character:GetAttributeChangedSignal("InventoryReady"):Wait()
	end

	Debug("InventoryReady became true")
end

function Module.start_module()
	Debug("========================================")
	Debug("start_module() called")

	if LocalPlayer.Character then
		Debug("Existing character found:", LocalPlayer.Character:GetFullName())
		WaitForInventoryReady(LocalPlayer.Character)
	else
		Debug("No existing character")
	end

	local backpack = LocalPlayer:WaitForChild("Backpack")

	Debug("Backpack found:", backpack:GetFullName())

	ConnectBackpack(backpack)

	local function watchCharacter(character)
		Debug("watchCharacter() called:", character:GetFullName())

		character.ChildAdded:Connect(function(child)
			Debug("Character.ChildAdded:", child.Name)
			Debug("Class:", child.ClassName)

			if not child:IsA("Tool") then
				Debug("Skipping non-tool character child:", child.Name)
				return
			end

			Debug("Tool entered Character:", child.Name)

			task.wait()

			Debug("Registering character tool:", child.Name)

			local instance = RegisterTool(child, true)

			if instance then
				Debug("Character tool registered:", child.Name)
			else
				Debug("Character tool registration FAILED:", child.Name)
			end
		end)

		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") then
				Debug("Found existing character tool:", child.Name)

				local instance = RegisterTool(child, true)

				if instance then
					Debug("Existing character tool registered:", child.Name)
				end
			end
		end
	end

	if LocalPlayer.Character then
		watchCharacter(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		Debug("========================================")
		Debug("CharacterAdded fired:", character:GetFullName())

		Debug("Destroying old registered controllers...")

		for tool, instance in pairs(Module.RegisteredTools) do
			Debug("Cleaning up:", tool.Name)

			InventoryService.RemoveTool(instance)
			DestroyToolInstance(instance)
		end

		Module.RegisteredTools = {}

		Debug("RegisteredTools reset")

		WaitForInventoryReady(character)

		local backpack = LocalPlayer:WaitForChild("Backpack")

		Debug("New backpack found:", backpack:GetFullName())

		ConnectBackpack(backpack)
		watchCharacter(character)

		Debug("New character setup complete")
		Debug("========================================")
	end)

	Debug("start_module() finished")
	Debug("========================================")
end

return Module
