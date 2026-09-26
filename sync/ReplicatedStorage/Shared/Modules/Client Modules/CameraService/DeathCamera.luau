local workspace_service = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Camera = workspace_service.CurrentCamera

local CameraClass = require(
	script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass
)

local DeathCamera = setmetatable({}, { __index = CameraClass })
DeathCamera.__index = DeathCamera

local LocalPlayer = PlayerService.LocalPlayer

local currentHighlight
local CameraService

local characterAddedConnection

local ended = false
local deathScreenTweens = {}
local deathScreenToken = 0
local deathFramePositions: {[Instance]: UDim2} = {}

local function GetDeathScreen(): GuiObject?
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local main = playerGui and playerGui:FindFirstChild("main")
	local coreGame = main and main:FindFirstChild("core_game")
	local deathScreen = main and main:FindFirstChild("deathscreen")
		or (coreGame and coreGame:FindFirstChild("deathscreen"))
	return if deathScreen and deathScreen:IsA("GuiObject") then deathScreen else nil
end

local function CancelDeathScreenTweens()
	for _, tween in ipairs(deathScreenTweens) do tween:Cancel() end
	table.clear(deathScreenTweens)
end

local function HideDeathScreen()
	deathScreenToken += 1
	CancelDeathScreenTweens()
	local screen = GetDeathScreen()
	if not screen then return end
	local spawnFrame = screen:FindFirstChild("spawnframe")
	if spawnFrame and spawnFrame:IsA("GuiObject") then spawnFrame.Visible = false end
	local blackout = screen:FindFirstChild("totalblackout")
	if blackout and blackout:IsA("GuiObject") then blackout.BackgroundTransparency = 1 end
	for _, name in ipairs({"topframe", "bottomframe"}) do
		local frame = screen:FindFirstChild(name)
		if frame and frame:IsA("GuiObject") and deathFramePositions[frame] then
			frame.Position = deathFramePositions[frame]
		end
	end
	screen.Visible = false
end

local function PlayDeathScreen()
	deathScreenToken += 1
	CancelDeathScreenTweens()
	local screen = GetDeathScreen()
	if not screen then
		warn("[DEATHCAMERA] Missing main.deathscreen")
		return
	end

	local top = screen:FindFirstChild("topframe")
	local bottom = screen:FindFirstChild("bottomframe")
	local spawnFrame = screen:FindFirstChild("spawnframe")
	if spawnFrame and spawnFrame:IsA("GuiObject") then spawnFrame.Visible = false end
	screen.Visible = true

	local function slide(frame: Instance?, fromY: number)
		if not frame or not frame:IsA("GuiObject") then return end
		if not deathFramePositions[frame] then deathFramePositions[frame] = frame.Position end
		local finalPosition = deathFramePositions[frame]
		frame.Visible = true
		frame.Position = UDim2.new(finalPosition.X.Scale, finalPosition.X.Offset, fromY, finalPosition.Y.Offset)
		local tween = TweenService:Create(frame, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = finalPosition,
		})
		table.insert(deathScreenTweens, tween)
		tween:Play()
	end

	slide(top, -1)
	slide(bottom, 1)
	local blackout = screen:FindFirstChild("totalblackout")
	if blackout and blackout:IsA("GuiObject") then
		blackout.Visible = false
		blackout.BackgroundTransparency = 1
	end
end


-- // Finds an unused body and marks that exact body as used.
-- // The body is returned so the caller can actually use it.
local function GetUnusedBody()
	local bodiesFolder = workspace.Game_Details.Bodies

	local function tryClaim()
		for _, body in ipairs(bodiesFolder:GetChildren()) do
			if body.Name == LocalPlayer.Name
				and not body:GetAttribute("DeathCameraUsed") then

				body:SetAttribute("DeathCameraUsed", true)
				return body
			end
		end
		return nil
	end

	while not ended do
		local found = tryClaim()
		if found then
			return found
		end
		bodiesFolder.ChildAdded:Wait()

		if ended then
			return nil
		end
		
		task.wait()

		found = tryClaim()
		if found then
			return found
		end
	end

	return nil
end


local function HandleRegularDeath()
	local body = GetUnusedBody()

	if not body or ended then
		return
	end

	local head = body:FindFirstChild("Head")

	-- // The ragdoll may not have its Head immediately.
	if not head then
		head = body:WaitForChild("Head", 5)
	end

	if not head or ended or not body.Parent then
		return
	end

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = head

	-- // Make absolutely sure the camera snaps to the body.
	Camera.CFrame = head.CFrame
	
	if CameraService then
		CameraService.SwitchCamera("SpectateCamera", true)
		print("SpectateCamera")
	end
end


local function HandleKillDeath(playerName)
	local killer = PlayerService:FindFirstChild(playerName)

	if not killer then
		HandleRegularDeath()
		return
	end

	local killerCharacter = killer.Character

	if not killerCharacter then
		HandleRegularDeath()
		return
	end

	local root = killerCharacter:FindFirstChild("HumanoidRootPart")

	if not root then
		HandleRegularDeath()
		return
	end

	-- // Make sure an existing kill-camera connection doesn't survive.
	RunService:UnbindFromRenderStep("KillCamera")

	-- // Remove an existing highlight.
	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end

	-- // Highlight killer.
	currentHighlight = Instance.new("Highlight")
	currentHighlight.Parent = killerCharacter

	Camera.CameraType = Enum.CameraType.Scriptable

	RunService:BindToRenderStep(
		"KillCamera",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			if ended then
				return
			end

			if not root.Parent then
				return
			end

			Camera.CFrame = CFrame.lookAt(
				Camera.CFrame.Position,
				root.Position
			)

			Camera.FieldOfView += (60 - Camera.FieldOfView) * 0.1
		end
	)
end


local function DisconnectCharacterConnections()
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		characterAddedConnection = nil
	end
end


local function HandleCharacterAdded()
	if ended then
		return
	end

	ended = true

	RunService:UnbindFromRenderStep("KillCamera")

	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end

	DisconnectCharacterConnections()

	if CameraService then
		CameraService.EndCameraByName("DeathCamera", true)
	end
end


function DeathCamera:Start()
	CameraService = require(script.Parent)

	ended = false
	PlayDeathScreen()

	RunService:UnbindFromRenderStep("KillCamera")

	DisconnectCharacterConnections()

	-- // Get the player that last tagged/killed us.
	local lastTagged = LocalPlayer:GetAttribute("LastTagged")

	-- // Clear immediately so it can't be reused.
	if lastTagged then
		LocalPlayer:SetAttribute("LastTagged", nil)
	end

	
	characterAddedConnection = LocalPlayer.CharacterAdded:Connect(
		HandleCharacterAdded
	)
	
	if lastTagged then
		HandleKillDeath(lastTagged)
	else
		HandleRegularDeath()
	end
	
	task.delay(3, function()
		if ended then
			return
		end

		if currentHighlight then
			currentHighlight:Destroy()
			currentHighlight = nil
		end

		RunService:UnbindFromRenderStep("KillCamera")

		if CameraService then
			CameraService.SwitchCamera("SpectateCamera", true)
			print("SpectateCamera")
		end
	end)
end


function DeathCamera:Resume()
	self:Start()
end


function DeathCamera:End()
	ended = true
	HideDeathScreen()

	RunService:UnbindFromRenderStep("KillCamera")

	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end

	DisconnectCharacterConnections()

	Camera.CameraSubject = nil
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = 70
end


function DeathCamera:Cut()
	-- Cut means the kill/body camera is handing control to spectating. The
	-- player is still dead, so leave the deathscreen visible until respawn.
	ended = true
	RunService:UnbindFromRenderStep("KillCamera")
	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end
	DisconnectCharacterConnections()
	Camera.CameraSubject = nil
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = 70
end


function DeathCamera:Switch()
	self:End()
end


function DeathCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)

	setmetatable(self, DeathCamera)

	self.className = "DeathCamera"
	self.name = "DeathCamera"

	self.CameraPosition = Camera.CFrame.Position
	self.priority = 1

	return self
end


DeathCamera.priority = 1

return DeathCamera
