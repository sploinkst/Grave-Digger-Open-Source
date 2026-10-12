local Players = game:GetService("Players")
local Quotes = require(script.Parent.Parent.DeathQuotes)

local DeathScreen = {}
local player = Players.LocalPlayer
local gui, top, bottom, title, quoteLabel, targetLabel
local quoteCharacter, selectedQuote
local function removeLegacyScreens()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end
	for _, container in ipairs({playerGui, game:GetService("StarterGui")}) do
		for _, descendant in ipairs(container:GetDescendants()) do
			local oldDeathScreen = descendant.Name == "deathscreen" and descendant:IsA("GuiObject")
			local oldSpectateScreen = descendant.Name == "Spectate" and descendant:IsA("ScreenGui")
				or (descendant.Name == "spectate" and descendant.Parent
					and descendant.Parent.Name == "main" and descendant:IsA("GuiObject"))
			if oldDeathScreen or oldSpectateScreen then descendant:Destroy() end
		end
	end
end

local function authoredLabel(panelName, labelName)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return nil end
	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if descendant.Name == "deathscreen" and descendant:IsA("GuiObject") then
			local panel = descendant:FindFirstChild(panelName, true)
			local source = panel and panel:FindFirstChild(labelName, true)
			if source and source:IsA("TextLabel") then return source end
		end
	end
	return nil
end

local function label(parent, name, text, y, height, maximumSize, panelName, labelName)
	local result = Instance.new("TextLabel")
	result.Name = name
	result.BackgroundTransparency = 1
	result.Position = UDim2.fromScale(0.08, y)
	result.Size = UDim2.fromScale(0.84, height)
	result.Text = text
	result.TextColor3 = Color3.new(1, 1, 1)
	result.TextScaled = true
	result.TextWrapped = true
	result.ZIndex = 2
	local size = Instance.new("UITextSizeConstraint")
	size.MinTextSize = 10
	size.MaxTextSize = maximumSize
	size.Parent = result
	local source = authoredLabel(panelName, labelName)
	if source then
		-- The master scripts inherit their typography from these authored labels.
		result.FontFace = source.FontFace
		result.TextSize = source.TextSize
		result.TextScaled = source.TextScaled
		result.TextWrapped = source.TextWrapped
		result.TextStrokeColor3 = source.TextStrokeColor3
		result.TextStrokeTransparency = source.TextStrokeTransparency
		size:Destroy()
		local authoredSize = source:FindFirstChildOfClass("UITextSizeConstraint")
		if authoredSize then authoredSize:Clone().Parent = result end
	end
	result.Parent = parent
	return result
end

local function ensureGui()
	if gui and gui.Parent then return end
	local playerGui = player:WaitForChild("PlayerGui")
	gui = Instance.new("ScreenGui")
	gui.Name = "DeathScreenOverlay"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 1000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = false

	top = Instance.new("Frame")
	top.Name = "TopPanel"
	top.Size = UDim2.fromScale(1, 0.22)
	top.BackgroundColor3 = Color3.new(0, 0, 0)
	top.BackgroundTransparency = 0.5
	top.BorderSizePixel = 0
	top.Parent = gui
	title = label(top, "Title", Quotes.Title, 0.2, 0.32, 36, "topframe", "toptext")
	quoteLabel = label(top, "Quote", "", 0.57, 0.3, 26, "topframe", "lowertext")

	bottom = Instance.new("Frame")
	bottom.Name = "BottomPanel"
	bottom.AnchorPoint = Vector2.new(0, 1)
	bottom.Position = UDim2.fromScale(0, 1)
	bottom.Size = UDim2.fromScale(1, 0.18)
	bottom.BackgroundColor3 = Color3.new(0, 0, 0)
	bottom.BackgroundTransparency = 0.5
	bottom.BorderSizePixel = 0
	bottom.Parent = gui
	label(bottom, "Controls", "[Q] Spectate [E]", 0.15, 0.4, 36, "bottomframe", "toptext")
	targetLabel = label(bottom, "Target", "", 0.62, 0.25, 22, "bottomframe", "lowertext")

	gui.Parent = playerGui
end

function DeathScreen.Show(character)
	ensureGui()
	removeLegacyScreens()
	if character ~= quoteCharacter or not selectedQuote then
		quoteCharacter = character
		selectedQuote = Quotes.Choose(player:FindFirstChild("useelitedeathquote") ~= nil
			or (character ~= nil and character:GetAttribute("IsShockTrooper") == true))
	end
	title.Text = Quotes.Title
	quoteLabel.Text = selectedQuote
	targetLabel.Text = ""
	top.Visible = true
	bottom.Visible = true
	gui.Enabled = true
	-- The master script sets the text and shows the screen immediately.
	top.Position = UDim2.fromScale(0, 0)
	bottom.Position = UDim2.fromScale(0, 1)
end

function DeathScreen.SetSpectating(target)
	if not gui or not gui.Enabled then return end
	targetLabel.Text = if target then target.Name else ""
end

function DeathScreen.Hide()
	-- Capture the original typography before retiring its GUI.
	ensureGui()
	if gui then gui.Enabled = false end
	removeLegacyScreens()
end

return DeathScreen
