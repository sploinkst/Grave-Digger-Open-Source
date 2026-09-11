local workspace_service = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

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
	self:End()
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