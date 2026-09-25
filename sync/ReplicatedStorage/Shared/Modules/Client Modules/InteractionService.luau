-- // @Praxitos

local Module = {}

-- // Services

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local UserInputService = game:GetService("UserInputService")

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
local EliteKitGui: GuiObject?
local ActiveEliteKit: any
local EliteButtonConnections = {}

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

local function CloseGeneratedEliteKitSelection()
	if EliteKitGui then
		EliteKitGui:Destroy()
		EliteKitGui = nil
	end
	ActiveEliteKit = nil
end

local function AddCorner(Parent: Instance, Radius: number)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Radius)
	Corner.Parent = Parent
end

local function OpenGeneratedEliteKitSelection(Object, Choices, SelectedClass: string)
	CloseGeneratedEliteKitSelection()
	ActiveEliteKit = Object

	local Gui = Instance.new("ScreenGui")
	Gui.Name = "EliteKitSelection"
	Gui.DisplayOrder = 80
	Gui.IgnoreGuiInset = true
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	Gui.Parent = Player:WaitForChild("PlayerGui")

	local Shade = Instance.new("TextButton")
	Shade.Name = "Shade"
	Shade.Text = ""
	Shade.AutoButtonColor = false
	Shade.Modal = true
	Shade.BackgroundColor3 = Color3.fromRGB(5, 7, 9)
	Shade.BackgroundTransparency = 0.2
	Shade.BorderSizePixel = 0
	Shade.Size = UDim2.fromScale(1, 1)
	Shade.Parent = Gui
	Shade.Activated:Connect(CloseGeneratedEliteKitSelection)

	local Panel = Instance.new("Frame")
	Panel.Name = "Panel"
	Panel.AnchorPoint = Vector2.new(0.5, 0.5)
	Panel.Position = UDim2.fromScale(0.5, 0.5)
	Panel.Size = UDim2.new(0.88, 0, 0.78, 0)
	Panel.BackgroundColor3 = Color3.fromRGB(24, 27, 29)
	Panel.BorderSizePixel = 0
	Panel.Parent = Shade
	AddCorner(Panel, 8)

	local SizeConstraint = Instance.new("UISizeConstraint")
	SizeConstraint.MaxSize = Vector2.new(760, 620)
	SizeConstraint.MinSize = Vector2.new(320, 390)
	SizeConstraint.Parent = Panel

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(24, 16)
	Title.Size = UDim2.new(1, -80, 0, 34)
	Title.Font = Enum.Font.GothamBold
	Title.Text = "SELECT SHOCK TROOPER"
	Title.TextColor3 = Color3.fromRGB(236, 226, 196)
	Title.TextSize = 24
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Panel

	local Subtitle = Instance.new("TextLabel")
	Subtitle.BackgroundTransparency = 1
	Subtitle.Position = UDim2.fromOffset(24, 50)
	Subtitle.Size = UDim2.new(1, -48, 0, 38)
	Subtitle.Font = Enum.Font.Gotham
	Subtitle.Text = "Any class can use any kit. Your " .. SelectedClass .. " specialty is marked recommended."
	Subtitle.TextColor3 = Color3.fromRGB(170, 174, 175)
	Subtitle.TextSize = 14
	Subtitle.TextWrapped = true
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = Panel

	local Close = Instance.new("TextButton")
	Close.BackgroundTransparency = 1
	Close.Position = UDim2.new(1, -54, 0, 14)
	Close.Size = UDim2.fromOffset(40, 40)
	Close.Font = Enum.Font.GothamBold
	Close.Text = "X"
	Close.TextColor3 = Color3.fromRGB(205, 205, 205)
	Close.TextSize = 20
	Close.Parent = Panel
	Close.Activated:Connect(CloseGeneratedEliteKitSelection)

	local List = Instance.new("ScrollingFrame")
	List.BackgroundTransparency = 1
	List.BorderSizePixel = 0
	List.Position = UDim2.fromOffset(20, 100)
	List.Size = UDim2.new(1, -40, 1, -120)
	List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	List.CanvasSize = UDim2.new()
	List.ScrollBarThickness = 5
	List.Parent = Panel

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 9)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = List

	for Index, Choice in ipairs(Choices) do
		local Button = Instance.new("TextButton")
		Button.Name = Choice.Name
		Button.LayoutOrder = Index
		Button.AutoButtonColor = true
		Button.BackgroundColor3 = if Choice.Recommended then Color3.fromRGB(93, 78, 42) else Color3.fromRGB(44, 48, 51)
		Button.BorderSizePixel = 0
		Button.Size = UDim2.new(1, -8, 0, 58)
		Button.Font = Enum.Font.GothamBold
		Button.Text = Choice.Name .. "\nAVAILABLE TO ALL CLASSES"
		Button.TextColor3 = Color3.fromRGB(239, 239, 235)
		Button.TextSize = 16
		Button.TextWrapped = true
		Button.Parent = List
		AddCorner(Button, 5)
		Button.Activated:Connect(function()
			if ActiveEliteKit ~= Object then return end
			Button.Active = false
			Interact:FireServer(Object, "SelectEliteKit", Choice.Name)
		end)
	end
end

local function CloseEliteKitSelection()
	for _, Connection in EliteButtonConnections do
		Connection:Disconnect()
	end
	table.clear(EliteButtonConnections)
	if EliteKitGui then
		EliteKitGui.Visible = false
		EliteKitGui = nil
	end
	ActiveEliteKit = nil
end

local function OpenEliteKitSelection(Object, Choices, _SelectedClass: string)
	CloseEliteKitSelection()
	ActiveEliteKit = Object

	local Main = Player:WaitForChild("PlayerGui"):FindFirstChild("main")
	local CoreGame = Main and Main:FindFirstChild("core_game")
	local SelectionBoxes = CoreGame and CoreGame:FindFirstChild("selectionboxes")
	local Selections = SelectionBoxes and SelectionBoxes:FindFirstChild("selections")
	if not SelectionBoxes or not SelectionBoxes:IsA("GuiObject") or not Selections then
		ActiveEliteKit = nil
		warn("[InteractionService] Missing main.core_game.selectionboxes.selections")
		return
	end

	local Available = {}
	for _, Choice in Choices do
		Available[Choice.Name] = true
	end
	local Entries = {
		{ Button = "1storm", Kit = "Storm Trooper" },
		{ Button = "2rook", Kit = "Anti-Material Trooper" },
		{ Button = "3flame", Kit = "Flame Trooper" },
		{ Button = "4radio", Kit = "Radio Trooper" },
		{ Button = "5jaeger", Kit = "Geist Trooper" },
		{ Button = "6trench", Kit = "Trench Trooper" },
		{ Button = "7bulwark", Kit = "Bulwark Trooper" },
	}
	local Wanted = {}
	for _, Entry in Entries do Wanted[Entry.Button] = true end
	for _, Child in Selections:GetChildren() do
		if Child:IsA("GuiObject") then
			Child.Visible = Wanted[Child.Name] == true
		end
	end

	for Index, Entry in Entries do
		local Existing = Selections:FindFirstChild(Entry.Button)
		if Existing and Existing:IsA("GuiObject") then
			Existing.LayoutOrder = Index
		end
		local Button = if Existing and Existing:IsA("GuiButton")
			then Existing
			else Existing and Existing:FindFirstChildWhichIsA("GuiButton", true)
		if not Button then
			warn("[InteractionService] Missing Shock Trooper selection button: " .. Entry.Button)
			continue
		end
		Button.Active = Available[Entry.Kit] == true
		table.insert(EliteButtonConnections, Button.Activated:Connect(function()
			if ActiveEliteKit ~= Object or not Available[Entry.Kit] then return end
			Interact:FireServer(Object, "SelectEliteKit", Entry.Kit)
		end))
	end

	EliteKitGui = SelectionBoxes
	if Selections:IsA("GuiObject") then Selections.Visible = true end
	SelectionBoxes.Visible = true
end

local function RegisterClickDetector(Detector: ClickDetector)
	if Connections[Detector] then
		return
	end

	Connections[Detector] = Detector.MouseClick:Connect(function()
		local Object = ResolveInteraction(Detector)

		if Object then
			Interact:FireServer(Object)
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
	UserInputService.InputBegan:Connect(function(Input, Processed)
		if not Processed and Input.KeyCode == Enum.KeyCode.Escape and EliteKitGui then
			CloseEliteKitSelection()
		end
	end)

	Player.CharacterRemoving:Connect(HandleCharacterRemoving)

	for _, Instance in Workspace:GetDescendants() do
		RegisterInstance(Instance)
	end
end

-- Client.client uses the repository-wide lowercase lifecycle name.
Module.start_module = Module.StartModule

return Module
