local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicatedfirst = script.Parent

replicatedfirst:RemoveDefaultLoadingScreen()

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local intro_frame = playerGui:FindFirstChild("Intro")

-- ReplicatedFirst runs before PlayerService has copied the shared UI. Create
-- Intro locally instead of yielding forever and blocking the intro sequence.
if not intro_frame then
	local uiFolder = ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Library")
		:WaitForChild("UI")
	local introTemplate = uiFolder:WaitForChild("Intro")
	intro_frame = introTemplate:Clone()
	intro_frame.Parent = playerGui
end

intro_frame.ResetOnSpawn = false

-- PlayerService may also replicate its copy after this local one is created.
-- Keep a single persistent Intro rather than accumulating duplicate GUIs.
playerGui.ChildAdded:Connect(function(child)
	if child.Name == "Intro" and child ~= intro_frame then
		child:Destroy()
	end
end)

local userinputservice = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")

intro_frame.Enabled = true


local function set_invsible()
	for _, v in pairs(intro_frame:GetDescendants()) do
		if v:IsA("TextLabel") then
			local tween = tween_service:Create(v, TweenInfo.new(0.5), {TextTransparency = 1})
			tween:Play()
		elseif v:IsA("ImageLabel") then
			local tween = tween_service:Create(v, TweenInfo.new(0.5), {ImageTransparency = 1})
			tween:Play()
		elseif v:IsA("Frame") then
			local tween = tween_service:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1})
			tween:Play()
		end
	end
	-- REMOVE LATER
	local MusicPlayer = workspace.MusicPlayer.music
	local tween = tween_service:Create(MusicPlayer, TweenInfo.new(3), {Volume = 0.35})
	tween:Play()
end

userinputservice.InputBegan:Connect(function(input, gps)
	if gps then return end

	if input.KeyCode == Enum.KeyCode.E then
		set_invsible()
	end
end)


task.delay(20, function()
	set_invsible()
end)

if localPlayer:GetAttribute("Whitelisted") then
	intro_frame.Enabled = true
end

localPlayer:GetAttributeChangedSignal("Whitelisted"):Connect(function()
	if localPlayer:GetAttribute("Whitelisted") then
		intro_frame.Enabled = true
	end
end)
