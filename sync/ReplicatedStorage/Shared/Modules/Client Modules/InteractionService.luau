-- // @Praxitos

local Module = {}

-- // Services

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

-- // Constants

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Interact = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Events")
	:WaitForChild("Interact")

local RestockAnimationName = "cache_restock"

-- // Variables

local Connections = {}
local Animations = {}

local ActiveHighlight: Highlight?
local ActiveTrack: AnimationTrack?
local EliteSelection
local SelectionView = require(script.Parent.MasterUI.SelectionView)

local Started = false

-- // Functions

local function ResolveInteraction(Detector: ClickDetector)
	local Part = Detector.Parent
	local InteractionObject = Detector:FindFirstChild("InteractionObject")
	local Object = if InteractionObject and InteractionObject:IsA("ObjectValue")
		then InteractionObject.Value
		else Part and Part.Parent

	if Detector.Name ~= "clicker"
		or not Part
		or not Part:IsA("BasePart")
		or not Object then
		return
	end

	local Highlight = Object:FindFirstChildWhichIsA("Highlight")

	if not Highlight then
		return
	end
	if Object.Name == "BulwarkShield" and Object:GetAttribute("OwnerUserId") ~= Player.UserId then
		return
	end

	return Object, Part, Highlight
end

local function SetHighlight(Highlight: Highlight?, Enabled: boolean)
	if Highlight and Highlight.Parent then
		Highlight.Enabled = Enabled
	end
end

local function RegisterHighlight(Highlight: Highlight)
	local Parent = Highlight.Parent
	local Part = Parent and (Parent:FindFirstChild("click") or (Parent:IsA("BasePart") and Parent))

	if Part and Part:IsA("BasePart") then
		Highlight.Enabled = false
	end
end

local function CloseEliteKitSelection()
	if EliteSelection then
		EliteSelection:Close()
		EliteSelection = nil
	end
end

local function OpenEliteKitSelection(Object, Choices, _SelectedClass: string)
	CloseEliteKitSelection()
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 or type(Choices) ~= "table" then return end

	local Icons = {
		["Storm Trooper"] = "91411577441927",
		["Anti-Material Trooper"] = "118411408826732",
		["Flame Trooper"] = "87666811826102",
		["Radio Trooper"] = "91848564547336",
		["Geist Trooper"] = "104974838934360",
		["Trench Trooper"] = "121228156023729",
		["Bulwark Trooper"] = "127864303840900",
	}
	local Entries = {}
	for _, Choice in ipairs(Choices) do
		if type(Choice) == "table" and Icons[Choice.Name] then
			table.insert(Entries, {id = Choice.Name, name = Choice.Name, icon = Icons[Choice.Name]})
		end
	end
	if #Entries == 0 then return end

	local View = SelectionView.new(function(Kit)
		Interact:FireServer(Object, "SelectEliteKit", Kit)
	end, function()
		return Player.Character == Character and Humanoid.Health > 0
	end, "EliteKitSelecting")
	EliteSelection = View
	if not View:Open(Character, Entries) then EliteSelection = nil; return end
	-- The server's offer expires after twenty seconds too.
	task.delay(20, function()
		if EliteSelection == View then CloseEliteKitSelection() end
	end)
	table.insert(View.Connections, Humanoid.Died:Connect(CloseEliteKitSelection))
end

local function RegisterClickDetector(Detector: ClickDetector)
	if Connections[Detector] then
		return
	end

	Connections[Detector] = Detector.MouseClick:Connect(function()
		local Object = ResolveInteraction(Detector)

		if Object then
			if Object.Name == "BulwarkShield" then
				local Ability = ReplicatedStorage.Shared.Library.Events:FindFirstChild("BulwarkAbility")
				if Ability then Ability:FireServer("Pickup", Object) end
			else
				Interact:FireServer(Object)
			end
		end
	end)
end

local function RegisterInstance(Instance: Instance)
	if Instance:IsA("Highlight") then
		RegisterHighlight(Instance)
	elseif Instance:IsA("ClickDetector") then
		RegisterClickDetector(Instance)
	end
end

local function RemoveInstance(Instance: Instance)
	local Connection = Connections[Instance]

	if Connection then
		Connection:Disconnect()
		Connections[Instance] = nil
	end

	if Instance == ActiveHighlight then
		SetHighlight(ActiveHighlight, false)
		ActiveHighlight = nil
	end
end

local function UpdateHighlight()
	local Character = Player.Character

	if not Character then
		if ActiveHighlight then
			SetHighlight(ActiveHighlight, false)
			ActiveHighlight = nil
		end

		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Root or not Humanoid or Humanoid.Health <= 0 then
		if ActiveHighlight then
			SetHighlight(ActiveHighlight, false)
			ActiveHighlight = nil
		end

		return
	end

	local Target = Mouse.Target
	local Detector = Target and Target:FindFirstChild("clicker")

	local NextHighlight: Highlight?

	if Detector and Detector:IsA("ClickDetector") then
		local Object, Part, Highlight = ResolveInteraction(Detector)

		if Object
			and Part
			and Highlight
			and Detector.MaxActivationDistance > 0
			and (Root.Position - Part.Position).Magnitude <= Detector.MaxActivationDistance then
			NextHighlight = Highlight
		end
	end

	if ActiveHighlight == NextHighlight then
		return
	end

	SetHighlight(ActiveHighlight, false)

	ActiveHighlight = NextHighlight

	SetHighlight(ActiveHighlight, true)
end

local function StopActiveTrack(FadeTime: number?)
	if not ActiveTrack then
		return
	end

	ActiveTrack:Stop(FadeTime or 0)
	ActiveTrack:Destroy()
	ActiveTrack = nil
end

local function GetRestockAnimation(): Animation?
	local CharacterAnimations = ReplicatedStorage
		:WaitForChild("Shared")
		:FindFirstChild("Assets")
		and ReplicatedStorage.Shared.Assets:FindFirstChild("Animations")

	local LegacyFolder = ReplicatedStorage.Shared:FindFirstChild("InteractionAnimations")

	local Source = CharacterAnimations
		and CharacterAnimations:FindFirstChild(RestockAnimationName, true)

	if not Source and LegacyFolder then
		Source = LegacyFolder:FindFirstChild(RestockAnimationName)
	end

	if not Source then
		return
	end

	local CachedAnimation = Animations[Source]

	if CachedAnimation then
		return CachedAnimation
	end

	if Source:IsA("Animation") then
		Animations[Source] = Source
		return Source
	end

	if not Source:IsA("KeyframeSequence") then
		return
	end

	local Animation = Instance.new("Animation")
	Animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(Source)

	Animations[Source] = Animation

	return Animation
end

local function PlayRestockAnimation()
	local Character = Player.Character

	if not Character or Character:GetAttribute("GunEquipped") == true then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return
	end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")

	if not Animator then
		return
	end

	local Animation = GetRestockAnimation()

	if not Animation then
		return
	end

	StopActiveTrack(0.1)

	local Success, Error = pcall(function()
		ActiveTrack = Animator:LoadAnimation(Animation.AnimationId)
		ActiveTrack.Priority = Enum.AnimationPriority.Action4
		ActiveTrack.Looped = false
		ActiveTrack:Play(0.1)
	end)

	if not Success then
		ActiveTrack = nil
		warn("[InteractionService] Restock animation failed: " .. tostring(Error))
	end
end

local function HandleInteract(Action: string, ...)
	if Action == "AmmoRestock" then
		PlayRestockAnimation()
	elseif Action == "EliteKitSelection" then
		OpenEliteKitSelection(...)
	elseif Action == "EliteKitResult" then
		CloseEliteKitSelection()
	end
end

local function HandleCharacterRemoving()
	StopActiveTrack()
	CloseEliteKitSelection()
end

-- // Connections

function Module.StartModule()
	if Started then
		return
	end

	Started = true

	Workspace.DescendantAdded:Connect(RegisterInstance)
	Workspace.DescendantRemoving:Connect(RemoveInstance)

	RunService.RenderStepped:Connect(function()
		local Character = Player.Character

		if ActiveTrack
			and Character
			and Character:GetAttribute("GunEquipped") == true then
			StopActiveTrack()
		end

		UpdateHighlight()
	end)

	Interact.OnClientEvent:Connect(HandleInteract)

	Player.CharacterRemoving:Connect(HandleCharacterRemoving)

	for _, Instance in Workspace:GetDescendants() do
		RegisterInstance(Instance)
	end
end

Module.start_module = Module.StartModule

return Module
