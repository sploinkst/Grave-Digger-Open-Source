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

local Started = false

-- // Functions

local function ResolveInteraction(Detector: ClickDetector)
	local Part = Detector.Parent
	local Object = Part and Part.Parent

	if Detector.Name ~= "clicker"
		or not Part
		or not Part:IsA("BasePart")
		or Part.Name ~= "click"
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
	local Part = Highlight.Parent and Highlight.Parent:FindFirstChild("click")

	if Part and Part:IsA("BasePart") then
		Highlight.Enabled = false
	end
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

local function HandleInteract(Action: string)
	if Action ~= "AmmoRestock" then
		return
	end

	PlayRestockAnimation()
end

local function HandleCharacterRemoving()
	StopActiveTrack()
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

return Module