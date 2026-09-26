--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Library"):WaitForChild("Events")
local compassInstance = Events:FindFirstChild("Compass")
if not compassInstance then
	compassInstance = Instance.new("RemoteEvent")
	compassInstance.Name = "Compass"
	compassInstance.Parent = Events
end
assert(compassInstance:IsA("RemoteEvent"), "Events.Compass must be a RemoteEvent")
local CompassEvent: RemoteEvent = compassInstance
local Util = require(Shared.Library.Util)

local Service = {}
local started = false
local activeModels: { [Player]: Model } = {}
local needleConnections: { [Player]: RBXScriptConnection } = {}
local lastRequest: { [Player]: number } = {}

local function tweenLid(lid: Instance, angle: number): Tween?
	local weld: any = if lid:IsA("Weld") or lid:IsA("Motor6D")
		then lid
		else lid:FindFirstChildWhichIsA("Weld") or lid:FindFirstChildWhichIsA("Motor6D")
	if not weld then return nil end
	local position = weld.C0.Position
	local target = CFrame.new(position) * CFrame.fromOrientation(0, 0, math.rad(angle))
	local tween = TweenService:Create(weld, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { C0 = target })
	tween:Play()
	return tween
end

local function cleanup(player: Player, animate: boolean)
	local connection = needleConnections[player]
	if connection then connection:Disconnect(); needleConnections[player] = nil end
	local model = activeModels[player]
	activeModels[player] = nil
	if not model or not model.Parent then return end
	if animate then
		local lid = model:FindFirstChild("lid_rotate", true)
		local tween = lid and tweenLid(lid, 0)
		if tween then tween.Completed:Wait() end
	end
	if model.Parent then model:Destroy() end
end

local function show(player: Player, requestedArm: any)
	local now = os.clock()
	if now - (lastRequest[player] or 0) < 0.1 then return end
	lastRequest[player] = now
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid or humanoid.Health <= 0
		or character:GetAttribute("Aiming") == true
		or character:GetAttribute("CompassDenied") == true then return end

	local expectedArm = if character:GetAttribute("CompassRight") == true then "Right Arm" else "Left Arm"
	if requestedArm ~= expectedArm then return end
	local arm = character:FindFirstChild(expectedArm)
	if not arm or not arm:IsA("BasePart") then return end
	local items = Shared.Assets:FindFirstChild("Items")
	local template = items and items:FindFirstChild(if player.Team and player.Team.Name == "Golden Empire" then "empirecompass" else "nationcompass")
	if not template or not template:IsA("Model") then return end

	cleanup(player, false)
	local clone = template:Clone()
	clone.Name = "ActiveCompass"
	clone.Parent = arm
	clone:PivotTo(arm.CFrame)
	local base = clone:FindFirstChild("base")
	if not base or not base:IsA("BasePart") then clone:Destroy(); return end
	local weld = Util.quick_weld(arm, base, clone, "Weld")
	weld.C0 = if expectedArm == "Right Arm"
		then CFrame.new(-0.6, -0.5, 0) * CFrame.fromOrientation(math.rad(180), 0, math.rad(90))
		else CFrame.new(0.6, -0.5, 0) * CFrame.fromOrientation(0, 0, math.rad(-90))
	activeModels[player] = clone

	local lid = clone:FindFirstChild("lid_rotate", true)
	if lid then task.delay(0.3, function() if clone.Parent then tweenLid(lid, -90) end end) end
	local needlePart = clone:FindFirstChild("compass_rotate", true)
	local needleWeld = needlePart and needlePart:FindFirstChildWhichIsA("Weld")
	if not needlePart or not needlePart:IsA("BasePart") or not needleWeld then return end
	local originalC0 = needleWeld.C0
	local position = originalC0.Position
	local rotation = originalC0 - position
	needleConnections[player] = RunService.Heartbeat:Connect(function()
		if activeModels[player] ~= clone or not clone.Parent then cleanup(player, false); return end
		local localNorth = needlePart.CFrame:VectorToObjectSpace(Vector3.new(0, 0, 1))
		local angle = math.atan2(localNorth.X, -localNorth.Z)
		needleWeld.C0 = CFrame.new(position) * rotation * CFrame.Angles(0, angle, 0)
	end)
end

function Service.start_module()
	if started then return end
	started = true
	CompassEvent.OnServerEvent:Connect(function(player, action, arm)
		if action == "Show" then show(player, arm)
		elseif action == "Hide" then cleanup(player, true) end
	end)
	Players.PlayerRemoving:Connect(function(player) cleanup(player, false); lastRequest[player] = nil end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterRemoving:Connect(function() cleanup(player, false) end)
	end)
	for _, player in Players:GetPlayers() do
		player.CharacterRemoving:Connect(function() cleanup(player, false) end)
	end
end

return Service
