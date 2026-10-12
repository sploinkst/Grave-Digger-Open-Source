--!strict

-- // @Praxitos
-- // Primary Camera Service Handler

local Module = {}

-- // Services
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local DeathScreen = require(ReplicatedStorageService.Shared.Library.UI.DeathScreen)

-- // Constants
local LibraryFolder = ReplicatedStorageService.Shared.Library
local ExternalsFolder = LibraryFolder.Externals
local TypeCheckerModule = require(ExternalsFolder.TypeChecker)
local CameraClass = require(LibraryFolder.Classes.Miscellanous.CameraClass)

-- // Stack (LIFO)
local CamerasStack = {}

local function NormalizeGameplayCamera(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local camera = WorkspaceService.CurrentCamera
	PlayerService.LocalPlayer.CameraMode = Enum.CameraMode.Classic
	PlayerService.LocalPlayer.CameraMaxZoomDistance = 10
	camera.FieldOfView = 90
	if humanoid then camera.CameraSubject = humanoid end
end

-- // Internal Helpers

local function GetTopCamera()
	return CamerasStack[#CamerasStack]
end

local function PushCamera(cameraInstance)
	table.insert(CamerasStack, cameraInstance)
end

local function PopCamera()
	return table.remove(CamerasStack)
end

local function FindCameraIndex(name: string)
	for i = #CamerasStack, 1, -1 do
		if CamerasStack[i].name == name then
			return i
		end
	end
	return nil
end

local function CheckCameras()
	for childName, child in pairs(script:GetChildren()) do
		if not TypeCheckerModule.new(CameraClass.Camera_Type)(child) then
			warn("[CAMERASERVICE::] CameraModule: ", childName, " fails the type check!")
		end
	end
end

local function ResumeCamera(camera)
	WorkspaceService.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	if camera.Resume then
		camera:Resume()
	else
		camera:Start()
	end
end

local function HandleDeath(character)
	local humanoid = character:WaitForChild("Humanoid")
	Module.EndCameraByName("SpectateCamera", true)

	humanoid.Died:Connect(function()
		if PlayerService.LocalPlayer.Character ~= character then return end
		if PlayerService.LocalPlayer:GetAttribute("MenuOpen") then
			Module.EndCameraByName("MenuCamera", true)
			Module.SwitchCamera("DeathCamera", true)
			Module.SwitchCamera("MenuCamera", true)
			return
		end
		Module.SwitchCamera("DeathCamera", true)
	end)
end

-- // Core

function Module.start_module()
	CheckCameras()
	WorkspaceService.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Module.SwitchCamera("SpectateCamera", true)

	local function OnCharacterAdded(character)
		local menuOpen = PlayerService.LocalPlayer:GetAttribute("MenuOpen") == true
        -- Tear down the old stack without resuming dead cameras between removals.
        local oldStack=table.clone(CamerasStack);table.clear(CamerasStack)
        for index=#oldStack,1,-1 do
            local ok,problem=pcall(function() oldStack[index]:Cut() end)
            if not ok then warn("[CameraService] Respawn cleanup: "..tostring(problem)) end
        end
        DeathScreen.Hide()
        local humanoid=character:WaitForChild("Humanoid",10)
        if PlayerService.LocalPlayer.Character~=character or not humanoid then return end
        PlayerService.LocalPlayer:SetAttribute("CantUnequip",nil)
        if not menuOpen then PlayerService.LocalPlayer:SetAttribute("MenuLocked",nil) end
		NormalizeGameplayCamera(character)
		DeathScreen.Hide()
		Module.SwitchCamera("BaseCamera", true)
		if menuOpen then Module.SwitchCamera("MenuCamera", true) end
		HandleDeath(character)
	end

	if PlayerService.LocalPlayer.Character then
		Module.EndCameraByName("SpectateCamera", true)
		OnCharacterAdded(PlayerService.LocalPlayer.Character)
	end

	PlayerService.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
end

function Module.SwitchCamera(targetCameraName: string, abruptChange: boolean)
	local targetCameraModule = script:FindFirstChild(targetCameraName)

	if not targetCameraModule then
		warn("[CAMERASERVICE::] No Camera Module Found with the name: ", targetCameraName)
		return
	end

	local targetCameraClass = require(targetCameraModule)
	local currentCamera = GetTopCamera()

	if currentCamera and currentCamera.name == targetCameraName then
		warn("[CAMERASERVICE::] Already using camera: ", targetCameraName)
		return
	end

	if currentCamera and targetCameraClass.priority < currentCamera.priority then
		warn("[CAMERASERVICE::] Target Camera Module:", targetCameraName, "has lower priority than current: ", currentCamera.name)
		return
	end

	if currentCamera then
		if abruptChange then
			currentCamera:Cut()
		else
			currentCamera:End()
		end
	end

	local newCamera = targetCameraClass.new({
		name = targetCameraName,
		priority = targetCameraClass.priority or 0,
	})

	PushCamera(newCamera)

	WorkspaceService.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	newCamera:Start()
end

function Module.EndCurrentCamera(abrupt: boolean)
	local currentCamera = PopCamera()
	if not currentCamera then
		return
	end

	if abrupt then
		currentCamera:Cut()
	else
		currentCamera:End()
	end

	local previousCamera = GetTopCamera()

	if previousCamera then
		ResumeCamera(previousCamera)
	else
		WorkspaceService.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function Module.EndCameraByName(cameraName: string, abrupt: boolean)
	local index = FindCameraIndex(cameraName)

	if not index then
		return
	end

	local removedCamera = table.remove(CamerasStack, index)

	if abrupt then
		removedCamera:Cut()
	else
		removedCamera:End()
	end

	local currentCamera = GetTopCamera()

	if currentCamera then
		ResumeCamera(currentCamera)
	else
		WorkspaceService.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function Module.ApplyRecoil(vertical: number, horizontal: number, steps: number?, doRoll: boolean?, scale: number?)
	local currentCamera = GetTopCamera()
	if currentCamera and currentCamera.ApplyRecoil then
		currentCamera:ApplyRecoil(vertical, horizontal, steps, doRoll, scale)
	end
end

function Module.GetCurrentCamera()
	return GetTopCamera()
end

return Module
