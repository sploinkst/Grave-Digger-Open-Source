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

local function MarkFirstBodyAsUsed()
	local bodiesFolder = workspace.Game_Details.Bodies
	
	while true do
		for _, body in ipairs(bodiesFolder:GetChildren()) do

			if body.Name == LocalPlayer.Name
				and not body:GetAttribute("DeathCameraUsed") then
				body:SetAttribute("DeathCameraUsed", true)
				return
			end
		end

		bodiesFolder.ChildAdded:Wait()
	end
	
end
local function HandleRegularDeath()
	local bodiesFolder = workspace.Game_Details.Bodies

	while true do
		for _, body in ipairs(bodiesFolder:GetChildren()) do

			if body.Name == LocalPlayer.Name
				and not body:GetAttribute("DeathCameraUsed") then

				MarkFirstBodyAsUsed()

				local head = body:WaitForChild("Head")

				Camera.CameraType = Enum.CameraType.Custom
				Camera.CameraSubject = head

				return
			end
		end

		bodiesFolder.ChildAdded:Wait()

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

	currentHighlight = Instance.new("Highlight")
	currentHighlight.Parent = killerCharacter

	Camera.CameraType = Enum.CameraType.Scriptable

	RunService:BindToRenderStep(
		"KillCamera",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			if not root.Parent then
				return
			end

			Camera.CFrame = CFrame.lookAt(
				Camera.CFrame.Position,
				root.Position
			)
			
			-- // lerp camera to 70 fov
			Camera.FieldOfView = Camera.FieldOfView + (60 - Camera.FieldOfView) * 0.1
		end
	)
	
	MarkFirstBodyAsUsed()
	
	task.delay(3, function()
		currentHighlight:Destroy()
		currentHighlight = nil
		
		RunService:UnbindFromRenderStep("KillCamera")
		CameraService.SwitchCamera("SpectateCamera", true)
		print("SpectateCamera")
	end)
end


function DeathCamera:Start()
	CameraService = require(script.Parent)
	
	RunService:UnbindFromRenderStep("KillCamera")

	local lastTagged = LocalPlayer:GetAttribute("LastTagged")

	if lastTagged then
		LocalPlayer:SetAttribute("LastTagged", nil)
	end

	if lastTagged then
		HandleKillDeath(lastTagged)
	else
		HandleRegularDeath()
	end

	LocalPlayer.CharacterAdded:Connect(function()
		local cameraService = require(script.Parent)
		cameraService.EndCameraByName("DeathCamera", true)
	end)
end


function DeathCamera:Resume()
	self:Start()
end


function DeathCamera:End()

	RunService:UnbindFromRenderStep("KillCamera")

	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end

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