local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Library = RS.Shared.Library
local Classes = require(Library.ClassDefinitions)
local Assets = require(Library.AuthoredAssets)
local Playback = require(Library.SoundPlayback)
local Rules = require(Library.TrackerRules)
local player = Players.LocalPlayer
local Service = {}
local lastPing, lastSonar, lastHeartbeat = -math.huge, -math.huge, -math.huge
local trails, lastPositions, effects = {}, {}, {}
local ids = {sonar = 127944151138983, tracking_heartbeat = 18871019672}
local function sound(name)
	local source = Assets.Find(name, {RS.Shared.Assets}, "Sound")
	local fallback
	if not source then fallback = Instance.new("Sound"); fallback.SoundId = "rbxassetid://" .. ids[name]; source = fallback end
	local played = Playback.Play(source, nil, {PitchVariation = name == "tracking_heartbeat" and 0.1 or 0})
	if fallback then fallback:Destroy() end
	if played then effects[played] = true; played.Destroying:Once(function() effects[played] = nil end) end
end
local function active()
	local c = player.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	return c and h and h.Health > 0 and player:GetAttribute("MenuOpen") ~= true
end
local function ping(position, name, lifetime)
	local anchor = Instance.new("Part")
	anchor.Name = name; anchor.Anchored = true; anchor.CanCollide = false; anchor.CanQuery = false; anchor.CanTouch = false
	anchor.Transparency = 1; anchor.Position = position; anchor.Parent = workspace.CurrentCamera or workspace
	local gui = Instance.new("BillboardGui")
	gui.Name = "ping"; gui.AlwaysOnTop = true; gui.Size = UDim2.fromOffset(20, 20); gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1; label.Size = UDim2.fromScale(1, 1); label.Text = name == "TrackerHeartbeat" and "?" or "?"
	label.TextColor3 = Color3.fromRGB(220, 90, 75); label.TextScaled = true; label.Parent = gui
	TweenService:Create(gui, TweenInfo.new(lifetime), {Size = UDim2.fromOffset(60, 60)}):Play()
	TweenService:Create(label, TweenInfo.new(lifetime), {TextTransparency = 1}):Play()
	effects[anchor] = true; anchor.Destroying:Once(function() effects[anchor] = nil end)
	Debris:AddItem(anchor, lifetime)
end
function Service.Sonar(position)
	if not active() or typeof(position) ~= "Vector3" then return end
	local c = player.Character
	local camera = workspace.CurrentCamera
	if not camera then return end
	local offset = position - camera.CFrame.Position
	if offset.Magnitude <= 1 or offset.Magnitude > 80 then return end
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {c}
	local hit = workspace:Raycast(camera.CFrame.Position, offset.Unit * (offset.Magnitude - 1), params)
	local allowed, audible = Rules.Sonar(os.clock() - lastPing, os.clock() - lastSonar, hit ~= nil, c:GetAttribute("Class") == "Jaeger")
	if not allowed then return end
	lastPing = os.clock()
	if audible then lastSonar = os.clock(); sound("sonar") end
	ping(position, "JaegerSonar", 1.5)
end
local function trail(c, root)
	local part = Instance.new("Part")
	part.Name = "footstep_trail"; part.Transparency = 1; part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.Massless = true
	part.CFrame = root.CFrame * CFrame.new(0, -2.8, 0)
	local a = Instance.new("Attachment"); a.Position = Vector3.new(-0.5, 0, 0); a.Parent = part
	local b = Instance.new("Attachment"); b.Position = Vector3.new(0.5, 0, 0); b.Parent = part
	local t = Instance.new("Trail"); t.Name = "trail"; t.Attachment0 = a; t.Attachment1 = b; t.Lifetime = 6
	t.Color = ColorSequence.new(Color3.fromRGB(180, 75, 65)); t.Transparency = NumberSequence.new(0.45, 1); t.FaceCamera = false; t.Parent = part
	local weld = Instance.new("WeldConstraint"); weld.Part0 = root; weld.Part1 = part; weld.Parent = part
	part.Parent = c
	return part
end
local function clear()
	for _, part in trails do part:Destroy() end
	for effect in effects do effect:Destroy() end
	table.clear(trails); table.clear(effects); table.clear(lastPositions)
	lastPing, lastSonar, lastHeartbeat = -math.huge, -math.huge, -math.huge
end
function Service.start_module()
	if Service.started then return end; Service.started = true
	player.CharacterRemoving:Connect(clear)
	local elapsed, scan = 0, 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt; scan += dt
		if elapsed < 0.25 then return end; elapsed = 0
		local c = player.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
		local tracking = active() and Classes.HasPerk(player, "Devil Dog")
		local jaeger = active() and c:GetAttribute("Class") == "Jaeger"
		local heartbeat = false; local seen = {}
		for _, target in Players:GetPlayers() do
			local enemy = target.Character; local other = enemy and enemy:FindFirstChild("HumanoidRootPart")
			local h = enemy and enemy:FindFirstChildOfClass("Humanoid")
			local eligible = root and player.Team and target.Team and target.Team ~= player.Team and other and h and h.Health > 0
			if eligible then
				seen[target] = true
				local distance = (root.Position - other.Position).Magnitude
				if tracking then
					if not trails[target] or trails[target].Parent ~= enemy then if trails[target] then trails[target]:Destroy() end; trails[target] = trail(enemy, other) end
					if scan >= 1 and Rules.Heartbeat(h.Health, distance) then heartbeat = true; ping(other.Position, "TrackerHeartbeat", 1) end
				elseif trails[target] then trails[target]:Destroy(); trails[target] = nil end
				local previous = lastPositions[target]
				if jaeger and distance <= 80 and previous and (other.Position - previous).Magnitude >= 1.5 then Service.Sonar(other.Position) end
				lastPositions[target] = other.Position
			end
		end
		for target, part in trails do if not seen[target] or not tracking then part:Destroy(); trails[target] = nil end end
		for target in lastPositions do if not seen[target] then lastPositions[target] = nil end end
		if scan >= 1 then
			scan = 0
			if heartbeat and os.clock() - lastHeartbeat >= 2 then lastHeartbeat = os.clock(); sound("tracking_heartbeat") end
		end
		if not active() then clear() end
	end)
end
return Service
