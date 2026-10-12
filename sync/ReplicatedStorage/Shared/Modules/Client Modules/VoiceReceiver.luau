local VoiceReceiver = {}
local Assets = require(game:GetService("ReplicatedStorage").Shared.Library.AuthoredAssets)
local Rules = require(game:GetService("ReplicatedStorage").Shared.Library.VoiceCommandRules)
local Settings = require(script.Parent.SettingsManager)
local Input = game:GetService("UserInputService")
local selected, wheel, wheelConnections = nil, nil, {}
local wheelOpen=false
local cursorState
local function alive()
 local player = game:GetService("Players").LocalPlayer
 local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 return humanoid and humanoid.Health > 0 and player:GetAttribute("MenuOpen") ~= true
end
local function send(command)
 if not Rules.Commands[command] or not alive() then return end
 local camera = workspace.CurrentCamera
 local payload
 if command == "danger" then
  if not camera then return end
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances = {game:GetService("Players").LocalPlayer.Character}
  local hit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 1000, params)
  if not hit then return end
  payload = {Position=hit.Position, Hit=hit.Instance}
 end
 game:GetService("ReplicatedStorage").Shared.Library.Events.VoiceComms:FireServer(command,payload)
end
local function closeWheel(submit)
 if wheel then wheel.Visible = false end
 local command=wheelOpen and submit and selected or nil
 wheelOpen=false
 if command then send(command) end
 selected = nil
 if cursorState then
  local player = game:GetService("Players").LocalPlayer
  if player:GetAttribute("MenuOpen") ~= true then
   Input.MouseBehavior = cursorState[1]; Input.MouseIconEnabled = cursorState[2]
  end
  cursorState = nil
 end
end
local function bindWheel()
 local nextWheel = Assets.Widget("voicewheel")
 if nextWheel == wheel then return end
 closeWheel(false)
 for _, connection in ipairs(wheelConnections) do connection:Disconnect() end
 table.clear(wheelConnections)
 wheel = nextWheel
 if not wheel then return end
 wheel.Visible = false
 for _, entry in ipairs(wheel:GetChildren()) do
  local button = entry:FindFirstChild("bar") and entry.bar:FindFirstChild("button")
  if button and button:IsA("GuiButton") then
   table.insert(wheelConnections,button.MouseEnter:Connect(function() if wheelOpen then selected=entry.Name end end))
   table.insert(wheelConnections,button.MouseLeave:Connect(function() if selected==entry.Name then selected=nil end end))
   table.insert(wheelConnections,button.Activated:Connect(function() if wheelOpen then selected=entry.Name;closeWheel(true) end end))
  end
 end
end
-- @Praxitos
-- Handles Client VoiceManager

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Constants
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = Shared:WaitForChild("Library")
local Events = Library:WaitForChild("Events")
local VoiceComms = Events:WaitForChild('VoiceComms')

-- // Variables

-- // Functions

-- temp
local function CreateBillBoard(position)
	local part = Instance.new("Part")
	part.Name = "DangerPing"
	part.Size = Vector3.new(3,3,3)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DangerBillboard"
	billboard.Size = UDim2.fromOffset(100, 25)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = part
	billboard.Parent = workspace

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "DANGER"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 0, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard



	task.delay(10, function()
		billboard:Destroy()
		part:Destroy()
	end)
end

function VoiceReceiver.start_module()
 if VoiceReceiver.started then return end
 VoiceReceiver.started = true
 local player = Players.LocalPlayer
 bindWheel()
 local legacy = player.PlayerGui:FindFirstChild("VoiceWheel")
 if legacy and legacy:IsA("ScreenGui") then legacy.Enabled=true end
 player.PlayerGui.DescendantAdded:Connect(function(child) if child.Name=="voicewheel" then task.defer(bindWheel) end end)
 player.CharacterRemoving:Connect(function() closeWheel(false) end)
 player:GetAttributeChangedSignal("MenuOpen"):Connect(function() if player:GetAttribute("MenuOpen") then closeWheel(false) end end)
 Settings.HookInput("Voice Lines",function(_,pressed)
  if not pressed then closeWheel(true);return end
  if not alive() then return end
  bindWheel()
  if not wheel then return end
  for _, entry in ipairs(wheel:GetChildren()) do
   if entry:IsA("GuiObject") and Rules.Officer[entry.Name] then entry.Visible=player.Character:GetAttribute("Class")=="Officer" end
  end
  selected=nil;wheelOpen=true
  cursorState={Input.MouseBehavior,Input.MouseIconEnabled}
  Input.MouseBehavior=Enum.MouseBehavior.Default;Input.MouseIconEnabled=true;wheel.Visible=true
 end)
 -- Commands are submitted exclusively through the open voice wheel.
	VoiceComms.OnClientEvent:Connect(function(sender, VoiceComm, data)
		print("VoiceReceiver: received voicecomm from server:", VoiceComm, data)
		
		if VoiceComm ~= "danger" and Rules.Commands[VoiceComm] then
   if Rules.Officer[VoiceComm] and Settings.GetSetting("muteofficers") then return end
   if Rules.Requests[VoiceComm] and Settings.GetSetting("hiderequests") then return end
   local notifications=player.PlayerGui:FindFirstChild("Notifications")
   local utils=notifications and notifications:FindFirstChild("Utils")
   if utils then
    require(utils).send_notification({}, (sender and sender.DisplayName or "Soldier")..": "..(Rules.Labels[VoiceComm] or VoiceComm))
   end
  elseif VoiceComm == "danger" then
			CreateBillBoard(data.Position)
			print("VoiceReceiver: Fired CreateBillBoard to", data.Position)
			
			local Notifications = require(game.Players.LocalPlayer.PlayerGui:WaitForChild('Notifications').Utils)
			Notifications.send_notification({}, sender.DisplayName .. ": Danger over there")
		end
	end)
end

return VoiceReceiver
