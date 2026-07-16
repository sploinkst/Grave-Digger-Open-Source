local module = {}
local LocalPlayer = game:GetService("Players").LocalPlayer
local GameData = LocalPlayer:WaitForChild("GameData")
local Accessory_Folder = GameData:WaitForChild("Accessorys")
local Holster_Folder = Accessory_Folder:WaitForChild("Holsters")
local ToolHolster_Folder = game:GetService("ReplicatedStorage").Shared.Assets.Guns.Holsters:FindFirstChild("Tool Holsters")
local GunClasses = game:GetService("ReplicatedStorage").Shared.Library.Classes.GunClasses
local ToolClasses = game:GetService("ReplicatedStorage").Shared.Library.Classes.ToolClasses
local inventory_service = require(script.Parent.InventoryService)
local Util_Module = require(script.Parent.Parent.Parent.Library.Util)

module.RegisteredTools = {}

-- // Tracks live ChildAdded/ChildRemoved connections per backpack so
-- // connect_backpack() can be called again on respawn without stacking
-- // duplicate listeners on the same (reused) Backpack instance.
local backpack_connections = {}

local function connect_backpack(backpack)
	print("[ToolService] connect_backpack called on:", backpack:GetFullName())

	local existing_connections = backpack_connections[backpack]
	if existing_connections then
		existing_connections.added:Disconnect()
		existing_connections.removed:Disconnect()
		backpack_connections[backpack] = nil
		print("[ToolService] Disconnected previous listeners on:", backpack:GetFullName())
	end

	local added_connection = backpack.ChildAdded:Connect(function(child)
		print("[ToolService] ChildAdded fired:", child.Name, "| IsA Tool:", child:IsA("Tool"))

		if not child:IsA("Tool") then
			print("[ToolService] Skipping non-tool:", child.Name)
			return
		end

		-- Yield one frame so the tool's properties finish replicating
		task.wait()

		if not child.Parent then
			print("[ToolService] Tool removed before registration could complete:", child.Name)
			return
		end

		if module.RegisteredTools[child.Name] then
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

		local class    = require(moduleScript)
		local instance = class.new({ name = child.Name })
		instance:on_give(child)
		module.RegisteredTools[child.Name] = instance
		inventory_service.assign_tool(instance)
		print("[ToolService] Successfully registered tool:", child.Name)
	end)

	local removed_connection = backpack.ChildRemoved:Connect(function(child)
		if not child:IsA("Tool") then return end
		print("[ToolService] ChildRemoved fired:", child.Name)

		local instance = module.RegisteredTools[child.Name]
		if not instance then
			print("[ToolService] No registered instance found for removed tool:", child.Name)
			return
		end

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(child.Name) then
			print("[ToolService] Tool moved to character, not removing from registry:", child.Name)
			return
		end

		inventory_service.remove_tool(instance)
		module.RegisteredTools[child.Name] = nil
		print("[ToolService] Removed tool from registry:", child.Name)
	end)

	backpack_connections[backpack] = { added = added_connection, removed = removed_connection }

	-- Scan anything already in the backpack at connect time
	local existing = backpack:GetChildren()
	print("[ToolService] Scanning existing backpack children, count:", #existing)

	for _, child in ipairs(existing) do
		if not child:IsA("Tool") then continue end
		if module.RegisteredTools[child.Name] then
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

		local class    = require(moduleScript)
		local instance = class.new({ name = child.Name })
		instance:on_give(child)
		module.RegisteredTools[child.Name] = instance
		inventory_service.assign_tool(instance)
		print("[ToolService] Registered existing tool (scan):", child.Name)
	end

	print("[ToolService] connect_backpack finished for:", backpack:GetFullName())
end

local function wait_for_inventory_ready(character)
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

function module.start_module()
	print("[ToolService] start_module called")

	if LocalPlayer.Character then
		wait_for_inventory_ready(LocalPlayer.Character)
	end
	connect_backpack(LocalPlayer:WaitForChild("Backpack"))

	LocalPlayer.CharacterAdded:Connect(function(character)
		print("[ToolService] CharacterAdded fired, resetting registered tools")
		module.RegisteredTools = {}
		wait_for_inventory_ready(character)
		local backpack = LocalPlayer:WaitForChild("Backpack")
		print("[ToolService] Connecting to backpack:", backpack:GetFullName())
		connect_backpack(backpack)
	end)

	print("[ToolService] start_module finished, waiting for tools...")
end

return module