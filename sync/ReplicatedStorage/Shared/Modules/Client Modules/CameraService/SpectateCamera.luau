--!strict
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Camera = Workspace.CurrentCamera
local CameraClass = require(script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass)
local SpectateCamera = setmetatable({}, {__index = CameraClass})
SpectateCamera.__index = SpectateCamera
local LocalPlayer = Players.LocalPlayer

local targets: {Player} = {}
local currentIndex = 1
local active = false
local inputConnection: RBXScriptConnection?
local heartbeatConnection: RBXScriptConnection?
local characterConnection: RBXScriptConnection?
local playerAddedConnection: RBXScriptConnection?
local playerRemovingConnection: RBXScriptConnection?
local teamConnection: RBXScriptConnection?
local lastRefresh = 0

local function humanoidFor(player: Player): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function isEligible(player: Player): boolean
	if player == LocalPlayer then return false end
	if LocalPlayer.Team and player.Team ~= LocalPlayer.Team then return false end
	local humanoid = humanoidFor(player)
	return humanoid ~= nil and humanoid.Health > 0 and humanoid.RootPart ~= nil
end

local function targetPart(player: Player): BasePart?
	local character = player.Character
	if not character then return nil end
	local head = character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then return head end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function spectateGui(): Instance?
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return nil end
	local main = playerGui:FindFirstChild("main")
	return playerGui:FindFirstChild("Spectate") or (main and main:FindFirstChild("spectate"))
end

local function setGuiEnabled(enabled: boolean)
	local gui = spectateGui()
	if not gui then return end
	if gui:IsA("ScreenGui") then gui.Enabled = enabled elseif gui:IsA("GuiObject") then gui.Visible = enabled end
end

local function updateGui(player: Player?)
	local gui = spectateGui()
	if not gui then return end
	local display = player and player.DisplayName or "No living allies"
	for _, name in ipairs({"playername", "username", "spectating", "target", "maintext"}) do
		local label = gui:FindFirstChild(name, true)
		if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
			label.Text = player and ("SPECTATING  " .. display) or display
			break
		end
	end
end

local function currentTarget(): Player?
	return targets[currentIndex]
end

function SpectateCamera:RefreshTargets()
	local previous = currentTarget()
	table.clear(targets)
	for _, player in ipairs(Players:GetPlayers()) do if isEligible(player) then table.insert(targets, player) end end
	table.sort(targets, function(a, b) return a.Name < b.Name end)
	currentIndex = 1
	if previous then for index, player in ipairs(targets) do if player == previous then currentIndex = index; break end end end
	self:UpdateCamera()
end

function SpectateCamera:UpdateCamera()
	local player = currentTarget()
	local part = player and targetPart(player)
	if part then Camera.CameraType = Enum.CameraType.Custom; Camera.CameraSubject = part else Camera.CameraSubject = nil end
	updateGui(player)
end

function SpectateCamera:Cycle(direction: number)
	self:RefreshTargets()
	if #targets == 0 then return end
	currentIndex = ((currentIndex - 1 + direction) % #targets) + 1
	self:UpdateCamera()
end

local function disconnect(connection: RBXScriptConnection?) if connection then connection:Disconnect() end end

function SpectateCamera:Start()
	local localHumanoid = humanoidFor(LocalPlayer)
	if localHumanoid and localHumanoid.Health > 0 then self:End(); return end
	self:End()
	active = true
	Camera.CameraType = Enum.CameraType.Custom
	setGuiEnabled(true)
	self:RefreshTargets()

	inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonL1 then self:Cycle(-1)
		elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonR1 then self:Cycle(1) end
	end)
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not active then return end
		if os.clock() - lastRefresh >= 0.25 then lastRefresh = os.clock(); self:RefreshTargets() end
		local player = currentTarget(); local part = player and targetPart(player)
		if part and Camera.CameraSubject ~= part then Camera.CameraSubject = part end
	end)
	characterConnection = LocalPlayer.CharacterAdded:Connect(function() self:End() end)
	playerAddedConnection = Players.PlayerAdded:Connect(function() task.defer(function() if active then self:RefreshTargets() end end) end)
	playerRemovingConnection = Players.PlayerRemoving:Connect(function() task.defer(function() if active then self:RefreshTargets() end end) end)
	teamConnection = LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function() if active then self:RefreshTargets() end end)
end

function SpectateCamera:Resume() self:Start() end

function SpectateCamera:End()
	active = false
	disconnect(inputConnection); inputConnection = nil
	disconnect(heartbeatConnection); heartbeatConnection = nil
	disconnect(characterConnection); characterConnection = nil
	disconnect(playerAddedConnection); playerAddedConnection = nil
	disconnect(playerRemovingConnection); playerRemovingConnection = nil
	disconnect(teamConnection); teamConnection = nil
	table.clear(targets)
	setGuiEnabled(false)
end

function SpectateCamera:Cut() self:End() end
function SpectateCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, SpectateCamera)
	self.className, self.name, self.CameraPosition, self.priority = "SpectateCamera", "SpectateCamera", Camera.CFrame.Position, 2
	return self
end
SpectateCamera.priority = 2
return SpectateCamera
