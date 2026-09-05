local Module = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local Interact = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Interact")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local connections = {}
local animations = {}
local activeHighlight
local activeTrack
local started = false

local function resolve(detector)
	local part = detector.Parent
	local object = part and part.Parent
	if detector.Name ~= "clicker" or not part or not part:IsA("BasePart") or part.Name ~= "click" or not object then return end
	local highlight = object:FindFirstChildWhichIsA("Highlight")
	if highlight then return object, part, highlight end
end

local function register(instance)
	if instance:IsA("Highlight") then
		local part = instance.Parent:FindFirstChild("click")
		if part and part:IsA("BasePart") then instance.Enabled = false end
	elseif instance:IsA("ClickDetector") and not connections[instance] then
		connections[instance] = instance.MouseClick:Connect(function()
			local object = resolve(instance)
			if object then
				Interact:FireServer(object)
			end
		end)
	end
end

function Module.start_module()
	if started then return end
	started = true
	Workspace.DescendantAdded:Connect(register)
	Workspace.DescendantRemoving:Connect(function(instance)
		if connections[instance] then connections[instance]:Disconnect(); connections[instance] = nil end
		if instance == activeHighlight then activeHighlight.Enabled = false; activeHighlight = nil end
	end)
	for _, instance in Workspace:GetDescendants() do register(instance) end
	-- Resolve hover continuously so removal, streaming, death and walking out of
	-- range cannot leave a highlight enabled. Reuse the object's own Highlight.
	RunService.RenderStepped:Connect(function()
		local target = Mouse.Target
		local detector = target and target:FindFirstChild("clicker")
		local character = Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local nextHighlight
		if detector and detector:IsA("ClickDetector") and root and humanoid and humanoid.Health > 0 then
			local object, part, highlight = resolve(detector)
			if object and detector.MaxActivationDistance > 0 and (root.Position - part.Position).Magnitude <= detector.MaxActivationDistance then
				nextHighlight = highlight
			end
		end
		if activeHighlight ~= nextHighlight then
			if activeHighlight then activeHighlight.Enabled = false end
			activeHighlight = nextHighlight
			if activeHighlight then activeHighlight.Enabled = true end
		end
	end)
	Interact.OnClientEvent:Connect(function(action)
		if action ~= "AmmoRestock" then return end
		local character = Player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		local folder = ReplicatedStorage.Shared:FindFirstChild("InteractionAnimations")
		local name = "cache_restock"
		local source = folder and folder:FindFirstChild(name)
		if not animator or not source then return end
		local success, err = pcall(function()
			local animation = animations[source]
			if not animation then
				if source:IsA("Animation") then
					animation = source
				elseif source:IsA("KeyframeSequence") then
					animation = Instance.new("Animation")
					animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(source)
				else return end
				animations[source] = animation
			end
			if activeTrack then activeTrack:Stop(0.1); activeTrack:Destroy() end
			activeTrack = animator:LoadAnimation(animation)
			activeTrack.Priority = Enum.AnimationPriority.Action4
			activeTrack.Looped = false
			activeTrack:Play(0.1)
		end)
		if not success then warn("[InteractionService] Restock animation failed: " .. tostring(err)) end
	end)
	Player.CharacterRemoving:Connect(function()
		if activeTrack then activeTrack:Stop(); activeTrack:Destroy(); activeTrack = nil end
	end)
end
return Module
