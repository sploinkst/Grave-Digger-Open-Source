local Module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local AccessoryService = require(script.Parent.AccessoryService)
local ItemsService = require(script.Parent.ItemsService)
local Interact = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Interact")
local Util = require(ReplicatedStorage.Shared.Library.Util)
local cooldowns = {}
local started = false

local function isCache(object)
	return object.Name == "ammocache" or object.Name == "obj_cache"
end

-- Normalize every cache as it enters the world, including later map clones.
local function prepareCache(object)
	if not isCache(object) then return end
	local part = object:FindFirstChild("click") or object:FindFirstChild("clickpart")
	if not part or not part:IsA("BasePart") then return end
	part.Name = "click"
	part.CanQuery = true
	local detector = part:FindFirstChildWhichIsA("ClickDetector")
	if not detector then detector = Instance.new("ClickDetector"); detector.Parent = part end
	detector.Name = "clicker"
	if detector.MaxActivationDistance <= 0 then detector.MaxActivationDistance = 32 end
	local highlight = object:FindFirstChildWhichIsA("Highlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "Highlight"
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Enabled = false
		highlight.Parent = object
	end
	highlight.Enabled = false
	if object:IsA("Model") or object:IsA("BasePart") then highlight.Adornee = object end
end

local function publishAnimations()
	local folder = ReplicatedStorage.Shared:FindFirstChild("InteractionAnimations")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "InteractionAnimations"
		folder.Parent = ReplicatedStorage.Shared
	end
	-- The place stores these under ServerStorage/animations/shared. Search also
	-- supports Shared/Animations without depending on folder capitalization.
	for _, name in {"cache_restock"} do
		local source = ServerStorage:FindFirstChild(name, true)
		if source and (source:IsA("Animation") or source:IsA("KeyframeSequence")) then
			if not folder:FindFirstChild(name) then source:Clone().Parent = folder end
		else
			warn("[InteractionManager] Missing ServerStorage animation: " .. name)
		end
	end
end

local function restock(player, character)
	local backpack = player:FindFirstChildOfClass("Backpack")
	local playerData = player:FindFirstChild("PlayerData")
	local data = playerData and playerData:FindFirstChild("PlayerData")
	local loadout = data and data:FindFirstChild("Equipment")
	if backpack and loadout then
		for _, slot in {"Primary", "Secondary"} do
			local item = loadout:FindFirstChild(slot)
			if item and item.Value ~= "" and not backpack:FindFirstChild(item.Value) and not character:FindFirstChild(item.Value) then
				ItemsService.give_item(player, item.Value)
			end
		end
	end
	Util.setammo(player)
	local characterData = character:FindFirstChild("CharacterData")
	local equipment = characterData and characterData:FindFirstChild("Equipment")
	if equipment then
		for _, child in equipment:GetChildren() do
			if string.find(child.Name, "Helmet") then
				local name = child.Name
				child:Destroy()
				local head = character:FindFirstChild("Head")
				local weld = head and head:FindFirstChild("AccessoryWeld")
				if weld then weld:Destroy() end
				AccessoryService.GiveAccessory(player, name, true, false, true)
				break
			end
		end
	end
end

function Module.start_module()
	if started then return end
	started = true
	publishAnimations()
	Workspace.DescendantAdded:Connect(function(instance)
		if isCache(instance) then prepareCache(instance)
		elseif instance:IsA("BasePart") and instance.Parent and isCache(instance.Parent) then prepareCache(instance.Parent) end
	end)
	for _, instance in Workspace:GetDescendants() do
		if isCache(instance) then prepareCache(instance) end
	end
	Players.PlayerRemoving:Connect(function(player) cooldowns[player] = nil end)
	Interact.OnServerEvent:Connect(function(player, object)
		if typeof(object) ~= "Instance" or not object:IsDescendantOf(Workspace) then return end
		local part = object:FindFirstChild("click")
		local detector = part and part:FindFirstChild("clicker")
		if not part or not part:IsA("BasePart") or not detector or not detector:IsA("ClickDetector") or not object:FindFirstChildWhichIsA("Highlight") then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not root then return end
		if detector.MaxActivationDistance <= 0 or (root.Position - part.Position).Magnitude > detector.MaxActivationDistance then return end
		if not isCache(object) or (cooldowns[player] or 0) > os.clock() then return end
		cooldowns[player] = os.clock() + 2
		Interact:FireClient(player, "AmmoRestock")
		restock(player, character)
	end)
end
return Module
