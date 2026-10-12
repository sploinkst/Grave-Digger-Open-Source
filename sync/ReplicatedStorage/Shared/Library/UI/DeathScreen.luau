local Players = game:GetService("Players")
local Quotes = require(script.Parent.Parent.DeathQuotes)

local DeathScreen = {}
local player = Players.LocalPlayer
local gui, top, bottom, title, quoteLabel, targetLabel
local quoteCharacter, selectedQuote
local shown = false
local authored = false
local spawnBound, spawnRemote
local spawnConnections = {}
local function setEnabled(value)
	if not gui then return end
	if gui:IsA("ScreenGui") then gui.Enabled = value else gui.Visible = value end
end
local function isEnabled()
	return gui and (gui:IsA("ScreenGui") and gui.Enabled or gui:IsA("GuiObject") and gui.Visible)
end
local function removeLegacyScreens()
	-- The supplied nested death panel is owned by this controller and retained.
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end
	for _, item in ipairs(playerGui:GetChildren()) do
		if item.Name == "DeathScreenOverlay" and item:IsA("ScreenGui") and item ~= gui then item.Enabled = false end
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
	local assets = require(game:GetService("ReplicatedStorage").Shared.Library.AuthoredAssets)
	local panel = assets.Widget("deathscreen")
	local authoredTop = panel and panel:FindFirstChild("topframe")
	local authoredBottom = panel and panel:FindFirstChild("bottomframe")
	if authoredTop and authoredBottom then
		local a = authoredTop:FindFirstChild("toptext")
		local b = authoredTop:FindFirstChild("lowertext")
		local c = authoredBottom:FindFirstChild("lowertext")
		if a and b and c then
			gui, top, bottom, title, quoteLabel, targetLabel = panel, authoredTop, authoredBottom, a, b, c
			authored = true
            local screen=assets.Screen("Spectate"); if screen then screen.Enabled=true end
			gui.Visible = false
			return
		end
	end
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

local function bindSpawn()
	if not authored or spawnBound == gui then return end
	for _, connection in ipairs(spawnConnections) do connection:Disconnect() end
	table.clear(spawnConnections)
	spawnBound = gui
	local panel=gui:FindFirstChild("spawnframe")
	local list=panel and panel:FindFirstChild("spawns")
	spawnRemote=game:GetService("ReplicatedStorage").Shared.Library.Events:WaitForChild("MatchControl")
	local engineer=panel and panel:FindFirstChild("engineerrespawn")
 if engineer then engineer.Visible=false;engineer.Active=false end
 local buttons={base=list and list:FindFirstChild("base"),train=list and list:FindFirstChild("train")}
	for kind, button in pairs(buttons) do
		if button and button:IsA("GuiButton") then
			button.Visible=kind=="base"
			table.insert(spawnConnections,button.Activated:Connect(function() spawnRemote:FireServer("SelectSpawn",kind) end))
		end
	end
	table.insert(spawnConnections,spawnRemote.OnClientEvent:Connect(function(action,value)
		if action=="SpawnOptions" and type(value)=="table" then
			for kind,button in pairs(buttons) do button.Visible=value[kind]==true end
		elseif action=="SpawnSelected" then
			for kind,button in pairs(buttons) do button.BackgroundColor3=kind==value and Color3.new(1,1,1) or Color3.new(0,0,0) end
		end
	end))
	if panel then panel.Visible=false end
end

function DeathScreen.Show(character)
 local current=player.Character
 local humanoid=current and current:FindFirstChildOfClass("Humanoid")
 if character~=current or humanoid and humanoid.Health>0 then DeathScreen.Hide();return end
	ensureGui()
	bindSpawn()
	if spawnRemote then spawnRemote:FireServer("SpawnOptions") end
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
	shown = true
	setEnabled(player:GetAttribute("MenuOpen") ~= true)
	-- The master script sets the text and shows the screen immediately.
	if not authored then
		top.Position = UDim2.fromScale(0, 0)
		bottom.Position = UDim2.fromScale(0, 1)
	end
end

function DeathScreen.SetSpectating(target)
	if not isEnabled() then return end
	targetLabel.Text = if target then target.Name else ""
end

function DeathScreen.Hide()
	shown = false
	-- Capture the original typography before retiring its GUI.
	ensureGui()
	setEnabled(false)
	removeLegacyScreens()
end

if player then
 player.CharacterAdded:Connect(function() DeathScreen.Hide() end)
	player:GetAttributeChangedSignal("MenuOpen"):Connect(function()
		setEnabled(shown and player:GetAttribute("MenuOpen") ~= true)
	end)
end

return DeathScreen
