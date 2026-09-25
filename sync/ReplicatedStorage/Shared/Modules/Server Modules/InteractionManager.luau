-- // @Praxitos

local Module = {}

-- // Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- // Dependencies

local AccessoryService = require(script.Parent.AccessoryService)
local ItemsService = require(script.Parent.ItemsService)
local ClassService = require(script.Parent.ClassService)
local Classes = require(ReplicatedStorage.Shared.Library.ClassDefinitions)
local Util = require(ReplicatedStorage.Shared.Library.Util)

-- // Constants

local Interact = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Events")
	:WaitForChild("Interact")

local InteractionAnimations = {
	"cache_restock",
}

local RestockCooldown = 2
local DefaultActivationDistance = 32

-- // Variables

local Cooldowns = {}
local PendingEliteKits = {}
local Started = false
local CommandSelectionToken = "ShockTrooperCommandSelection"

-- // Functions

local function IsCache(Object: Instance): boolean
	return Object.Name == "ammocache"
		or Object.Name == "obj_cache"
end

local function IsEliteKit(Object: Instance): boolean
	local Name = string.lower(Object.Name)
	return Name == "elitekit1" or Name == "elitekit2"
end

local function IsInteractable(Object: Instance): boolean
	return IsCache(Object) or IsEliteKit(Object)
end

local function GetCacheClickPart(Cache: Instance): BasePart?
	if IsEliteKit(Cache) and Cache:IsA("BasePart") then
		return Cache
	end

	local Part = Cache:FindFirstChild("click")
		or Cache:FindFirstChild("clickpart")

	if not Part or not Part:IsA("BasePart") then
		return
	end

	return Part
end

local function PrepareCache(Cache: Instance)
	if not IsInteractable(Cache) then
		return
	end

	local Part = GetCacheClickPart(Cache)

	if not Part then
		return
	end

	if not IsEliteKit(Cache) then
		Part.Name = "click"
	end
	Part.CanQuery = true

	local Detector = Part:FindFirstChildWhichIsA("ClickDetector")

	if not Detector then
		Detector = Instance.new("ClickDetector")
		Detector.Parent = Part
	end

	Detector.Name = "clicker"
	local InteractionObject = Detector:FindFirstChild("InteractionObject")
	if InteractionObject and not InteractionObject:IsA("ObjectValue") then
		InteractionObject:Destroy()
		InteractionObject = nil
	end
	if not InteractionObject then
		InteractionObject = Instance.new("ObjectValue")
		InteractionObject.Name = "InteractionObject"
		InteractionObject.Parent = Detector
	end
	(InteractionObject :: ObjectValue).Value = Cache

	if Detector.MaxActivationDistance <= 0 then
		Detector.MaxActivationDistance = DefaultActivationDistance
	end

	local Highlight = Cache:FindFirstChildWhichIsA("Highlight")

	if not Highlight then
		Highlight = Instance.new("Highlight")
		Highlight.Name = "Highlight"
		Highlight.FillTransparency = 0.5
		Highlight.FillColor = Color3.new(1, 1, 1)
		Highlight.OutlineColor = Color3.new(1, 1, 1)
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		Highlight.Enabled = false
		Highlight.Parent = Cache
	end

	Highlight.Enabled = false

	if Cache:IsA("Model") or Cache:IsA("BasePart") then
		Highlight.Adornee = Cache
	end
end

local function PublishAnimations()
	local Folder = ReplicatedStorage.Shared:FindFirstChild("InteractionAnimations")

	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "InteractionAnimations"
		Folder.Parent = ReplicatedStorage.Shared
	end

	for _, AnimationName in InteractionAnimations do
		if Folder:FindFirstChild(AnimationName) then
			continue
		end

		local Source = ServerStorage:FindFirstChild(AnimationName, true)

		if not Source then
			warn("[InteractionManager] Missing ServerStorage animation: " .. AnimationName)
			continue
		end

		if not Source:IsA("Animation")
			and not Source:IsA("KeyframeSequence") then
			warn("[InteractionManager] Invalid interaction animation: " .. AnimationName)
			continue
		end

		Source:Clone().Parent = Folder
	end
end

local function RestockItems(Player: Player, Character: Model)
	local Backpack = Player:FindFirstChildOfClass("Backpack")
	local PlayerData = Player:FindFirstChild("PlayerData")
	local Data = PlayerData and PlayerData:FindFirstChild("PlayerData")
	local Loadout = Data and Data:FindFirstChild("Equipment")

	if not Backpack or not Loadout then
		return
	end

	for _, SlotName in {"Primary", "Secondary"} do
		local Item = Loadout:FindFirstChild(SlotName)

		if not Item
			or Item.Value == ""
			or Backpack:FindFirstChild(Item.Value)
			or Character:FindFirstChild(Item.Value) then
			continue
		end

		ItemsService.give_item(Player, Item.Value)
	end
end

local function RestockHelmet(Player: Player, Character: Model)
	local CharacterData = Character:FindFirstChild("CharacterData")
	local Equipment = CharacterData and CharacterData:FindFirstChild("Equipment")

	if not Equipment then
		return
	end

	for _, Child in Equipment:GetChildren() do
		if not string.find(Child.Name, "Helmet") then
			continue
		end

		local HelmetName = Child.Name

		Child:Destroy()

		local Head = Character:FindFirstChild("Head")
		local AccessoryWeld = Head and Head:FindFirstChild("AccessoryWeld")

		if AccessoryWeld then
			AccessoryWeld:Destroy()
		end

		AccessoryService.GiveAccessory(
			Player,
			HelmetName,
			true,
			false,
			true
		)

		break
	end
end

local function Restock(Player: Player, Character: Model)
	RestockItems(Player, Character)

	Util.setammo(Player)

	RestockHelmet(Player, Character)
end

local function IsValidInteraction(
	Player: Player,
	Object: Instance
): (boolean, BasePart?, ClickDetector?)
	if typeof(Object) ~= "Instance"
		or not Object:IsDescendantOf(Workspace)
		or not IsInteractable(Object) then
		return false
	end

	local Part = GetCacheClickPart(Object)
	local Detector = Part and Part:FindFirstChild("clicker")
	local Highlight = Object:FindFirstChildWhichIsA("Highlight")

	if not Part
		or not Detector
		or not Detector:IsA("ClickDetector")
		or not Highlight then
		return false
	end

	local Character = Player.Character

	if not Character then
		return false
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Root = Character:FindFirstChild("HumanoidRootPart")

	if not Humanoid
		or Humanoid.Health <= 0
		or not Root then
		return false
	end

	if Detector.MaxActivationDistance <= 0 then
		return false
	end

	local Distance = (Root.Position - Part.Position).Magnitude

	if Distance > Detector.MaxActivationDistance then
		return false
	end

	return true, Part, Detector
end

local function GetEliteKitChoices(Player: Player)
	local Choices = {}
	local SelectedClass = Classes.Selected(Player)

	for _, EliteName in {
		"Storm Trooper",
		"Anti-Material Trooper",
		"Flame Trooper",
		"Radio Trooper",
		"Geist Trooper",
		"Trench Trooper",
		"Bulwark Trooper",
	} do
		local Elite = Classes.EliteDefinitions[EliteName]
		if Elite and not Elite.RequiresUnlock then
			table.insert(Choices, {
				Name = EliteName,
				OutfitClass = Elite.OutfitClass,
				Recommended = false,
			})
		end
	end

	return Choices, SelectedClass
end

local function OpenEliteKitSelection(Player: Player, Object)
	local Choices, SelectedClass = GetEliteKitChoices(Player)
	PendingEliteKits[Player] = {
		Object = Object,
		Character = Player.Character,
		ExpiresAt = os.clock() + 20,
	}
	Interact:FireClient(Player, "EliteKitSelection", Object, Choices, SelectedClass)
end

local function IsOnCooldown(Player: Player): boolean
	return (Cooldowns[Player] or 0) > os.clock()
end

local function SetCooldown(Player: Player)
	Cooldowns[Player] = os.clock() + RestockCooldown
end

local function HandleEliteKitSelection(Player: Player, Object, EliteName): boolean
	local Pending = PendingEliteKits[Player]
	if not Pending
		or Pending.Object ~= Object
		or Pending.Character ~= Player.Character
		or Pending.ExpiresAt < os.clock()
		or type(EliteName) ~= "string"
		or IsOnCooldown(Player) then
		return false
	end

	local Elite, CanonicalName = Classes.GetElite(EliteName)
	if not Elite
		or not CanonicalName
		or Elite.RequiresUnlock
		or not Classes.CanUseElite(Player, CanonicalName) then
		return false
	end

	PendingEliteKits[Player] = nil
	SetCooldown(Player)
	local Success, Result = ClassService.SetShockTrooper(Player, CanonicalName)
	Interact:FireClient(Player, "EliteKitResult", Success, Result)
	return true
end

local function HandleInteraction(Player: Player, Object, Action: string?, EliteName: string?)
	if Object == CommandSelectionToken then
		if Action == "SelectEliteKit" then
			HandleEliteKitSelection(Player, Object, EliteName)
		end
		return
	end

	local IsValid = IsValidInteraction(Player, Object)

	if not IsValid then
		return
	end

	if IsEliteKit(Object) then
		if Action == "SelectEliteKit" then
			HandleEliteKitSelection(Player, Object, EliteName)
			return
		end

		OpenEliteKitSelection(Player, Object)
		return
	end

	if IsOnCooldown(Player) then
		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	SetCooldown(Player)

	Interact:FireClient(Player, "AmmoRestock")

	Restock(Player, Character)
end

local function HandleDescendantAdded(Instance: Instance)
	if IsInteractable(Instance) then
		PrepareCache(Instance)
		return
	end

	if not Instance:IsA("BasePart") then
		return
	end

	local Parent = Instance.Parent

	if Parent and IsInteractable(Parent) then
		PrepareCache(Parent)
	end
end

local function HandlePlayerRemoving(Player: Player)
	Cooldowns[Player] = nil
	PendingEliteKits[Player] = nil
end

function Module.OpenEliteKitSelection(Player: Player)
	if not Player or not Player:IsDescendantOf(Players) then
		return false
	end
	OpenEliteKitSelection(Player, CommandSelectionToken)
	return true
end

-- // Connections

function Module.StartModule()
	if Started then
		return
	end

	Started = true

	PublishAnimations()

	Workspace.DescendantAdded:Connect(HandleDescendantAdded)
	Players.PlayerRemoving:Connect(HandlePlayerRemoving)

	Interact.OnServerEvent:Connect(HandleInteraction)

	for _, Instance in Workspace:GetDescendants() do
		if IsInteractable(Instance) then
			PrepareCache(Instance)
		end
	end
end

-- ServerStarter uses the repository-wide lowercase lifecycle name.
Module.start_module = Module.StartModule

return Module
