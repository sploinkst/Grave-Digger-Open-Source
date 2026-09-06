local Service = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local markers = {}
local started = false

local function billboard(adornee, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ClassIntel"; gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(100, 26); gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Text = text; label.TextColor3 = color; label.TextStrokeTransparency = 0.2
	label.TextSize = 14; label.Parent = gui
	local icon = Instance.new("ImageLabel")
	icon.Name = "ClassIcon"; icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromOffset(24, 24); icon.Position = UDim2.fromOffset(-24, 0)
	icon.Parent = gui
	gui.Parent = localPlayer:WaitForChild("PlayerGui")
	return gui, label
end

function Service.start_module()
	if started then return end
	started = true
	local remote = ReplicatedStorage.Shared.Library.Events:WaitForChild("ClassIntel")
	remote.OnClientEvent:Connect(function(kind, target, duration)
		if kind == "Mark" and typeof(target) == "Instance" and target:IsA("Model") then
			local old = markers[target]
			if old then old:Destroy() end
			local highlight = Instance.new("Highlight")
			highlight.Adornee = target; highlight.FillTransparency = 0.8
			highlight.FillColor = Color3.fromRGB(230, 95, 70)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = target; markers[target] = highlight
			task.delay(duration, function()
				if markers[target] == highlight then markers[target] = nil end
				highlight:Destroy()
			end)
		elseif kind == "Mining" and typeof(target) == "Vector3" then
			local anchor = Instance.new("Part")
			anchor.Anchored = true; anchor.CanCollide = false; anchor.CanQuery = false
			anchor.CanTouch = false; anchor.Transparency = 1; anchor.Position = target
			anchor.Parent = workspace
			local gui = billboard(anchor, "Mining", Color3.fromRGB(220, 195, 120))
			game:GetService("Debris"):AddItem(gui, duration)
			game:GetService("Debris"):AddItem(anchor, duration)
		end
	end)
	local icons = {}
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.25 then return end
		elapsed = 0
		local localCharacter = localPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		local data = localPlayer:FindFirstChild("PlayerData")
		local settings = data and data:FindFirstChild("Settings Data")
		local setting = settings and settings:FindFirstChild("HideTeammateClassIcons", true)
		local hidden = setting and setting:FindFirstChild("Current") and setting.Current.Value == true
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local head = character and character:FindFirstChild("Head")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local name = character and character:GetAttribute("Class")
			local visible = not hidden and player ~= localPlayer and localPlayer.Team ~= nil and player.Team == localPlayer.Team
				and head and humanoid and humanoid.Health > 0 and localRoot and name
			if visible then
				local range = if name == "Officer" or localCharacter:GetAttribute("Class") == "Officer" then 200 else 80
				visible = (head.Position - localRoot.Position).Magnitude <= range
			end
			if visible then
				if not icons[player] then
					local gui, label = billboard(head, name, Color3.fromRGB(225, 220, 185))
					icons[player] = {gui = gui, label = label}
				end
				icons[player].gui.Adornee = head; icons[player].label.Text = name
				local menus = ReplicatedStorage.Shared.Library.UI:FindFirstChild("Menu_Scenes")
				local loadout = menus and menus:FindFirstChild("Loadout")
				local main = loadout and loadout:FindFirstChild("Main_Frame")
				local options = main and main:FindFirstChild("Classes_Options")
				local option = options and options:FindFirstChild(string.lower(name))
				local source = option and option:FindFirstChild("classicon")
				icons[player].gui.ClassIcon.Image = source and source.Image or ""
			elseif icons[player] then icons[player].gui:Destroy(); icons[player] = nil end
		end
		for player, icon in icons do
			if not player.Parent then icon.gui:Destroy(); icons[player] = nil end
		end
	end)
end
return Service

-- Kinda Weird to make this a runservice wouldn't an easier system just be detecting when every player ClassAttribute Changes?