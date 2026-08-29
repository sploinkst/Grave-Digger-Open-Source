local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events_folder = ReplicatedStorage.Shared.Library:WaitForChild("Events")
local datapush_remoteevent = events_folder:FindFirstChild("Datapush")
if not datapush_remoteevent then
	datapush_remoteevent = Instance.new("RemoteEvent")
	datapush_remoteevent.Name = "Datapush"
	datapush_remoteevent.Parent = events_folder
end
local gun_classes = ReplicatedStorage.Shared.Library.Classes.GunClasses

-- lookup table
local allowedchanges_table = {
	ChatMode = true
}

local loadout_targets = {
	LoadoutPrimary = "Primary",
	LoadoutSecondary = "Secondary",
}
local MAX_LOADOUT_WEIGHT = 3

local started = false

local function set_loadout(player: Player, target: string, weapon_name: any)
	local slot_name = loadout_targets[target]
	if not slot_name or type(weapon_name) ~= "string" then return end

	local weapon_script = gun_classes:FindFirstChild(weapon_name)
	if not weapon_script or not weapon_script:IsA("ModuleScript") then return end

	local success, weapon_class = pcall(require, weapon_script)
	if not success or type(weapon_class.Weight) ~= "number" then return end

	local player_data = player:FindFirstChild("PlayerData")
	local data = player_data and player_data:FindFirstChild("PlayerData")
	local equipment = data and data:FindFirstChild("Equipment")
	local slot = equipment and equipment:FindFirstChild(slot_name)
	if not slot or not slot:IsA("StringValue") then return end

	local other_name = slot_name == "Primary" and "Secondary" or "Primary"
	local other_slot = equipment:FindFirstChild(other_name)
	local other_weight = 0
	if other_slot and other_slot:IsA("StringValue") and other_slot.Value ~= "" then
		local other_script = gun_classes:FindFirstChild(other_slot.Value)
		if other_script and other_script:IsA("ModuleScript") then
			local other_success, other_class = pcall(require, other_script)
			if other_success and type(other_class.Weight) == "number" then
				other_weight = other_class.Weight
			end
		end
	end

	if weapon_class.Weight + other_weight > MAX_LOADOUT_WEIGHT then return end
	slot.Value = weapon_name
end

function module.start_module()
	if started then return end
	started = true

	datapush_remoteevent.OnServerEvent:Connect(function(player, target, value)
		if loadout_targets[target] then
			set_loadout(player, target, value)
			return
		end

		if not allowedchanges_table[target] then return end

		for _, child in ipairs(player.PlayerData:GetDescendants()) do
			if child.Name == target and child.Parent.Name ~= "Bindings" then
				child.Value = value
			end
		end
	end)
end

return module
