--!strict

local Module = {}

-- // Services
local WorkspaceService = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- // Constants
local Camera = WorkspaceService.CurrentCamera
local CameraClass = require(script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass)
local BaseCamera = setmetatable({}, { __index = CameraClass })
BaseCamera.__index = BaseCamera

local GameDetails = WorkspaceService:WaitForChild("Game_Details")
local MenusFolder = GameDetails:WaitForChild("Menus")

local CameraInfoTables = {
	["Appearance"] = { MenusFolder.Appearance_Scene.Camera_Values },
	["Credits"] = { MenusFolder.Credits_Scene.Camera_Values },
	["Loadout"] = { MenusFolder.Loadout_Scene.Camera_Values },
	["Servers"] = { MenusFolder.Servers_Scene.Camera_Values },
	["Settings"] = { MenusFolder.Settings_Scene.Camera_Values },
}

local currentScene = "Loadout"

-- // Internal State
local activeTween: Tween? = nil

-- // Utilities

local function GetCameraValue(scene: string): CFrame?
	local data = CameraInfoTables[scene]
	if not data or not data[1] then
		warn("[MENUCAMERA::] No data found for scene:", scene)
		return nil
	end
	return data[1].Value
end

local function CancelTween()
	if activeTween then
		activeTween:Cancel()
		activeTween = nil
	end
end

local function TweenTo(cf: CFrame, duration: number)
	CancelTween()
	activeTween = TweenService:Create(
		Camera,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = cf }
	)
	activeTween:Play()
end

local function SetCameraInstant(cf: CFrame)
	CancelTween()
	Camera.CFrame = cf
end

local function SetCameraIntro(cf: CFrame)
	CancelTween()
	Camera.CFrame = cf * CFrame.new(0, 0, 3)
	TweenTo(cf, 1.5)
end

-- // Core Methods

function BaseCamera:Start()
	print("CameraService: MenuCamera started")
	Camera.CameraType = Enum.CameraType.Scriptable
	local cf = GetCameraValue(currentScene)
	if not cf then
		return
	end
	SetCameraIntro(cf)
end

function BaseCamera:Resume()
	-- // MenuCamera has no paused state to restore; treat resume as a fresh start
	self:Start()
end

function BaseCamera:End()
	print("CameraService: MenuCamera ended")
	CancelTween()
	-- // leave CameraType alone — CameraService resets it before handing off
end

function BaseCamera:Cut(targetScene: string?)
	CancelTween()
	if targetScene then
		if not CameraInfoTables[targetScene] then
			warn("[MENUCAMERA::] No Camera Info Table for scene:", targetScene)
			return
		end
		currentScene = targetScene
	end
	local cf = GetCameraValue(currentScene)
	if not cf then
		return
	end
	SetCameraInstant(cf)
end

function BaseCamera:Switch(targetScene: string)
	if not CameraInfoTables[targetScene] then
		warn("[MENUCAMERA::] No Camera Info Table for scene:", targetScene)
		return
	end
	currentScene = targetScene
	local cf = GetCameraValue(targetScene)
	if not cf then
		return
	end
	SetCameraIntro(cf)
end

-- // Constructor

function BaseCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, BaseCamera)
	self.className = "MenuCamera"
	self.name = "MenuCamera"
	self.CameraPosition = Camera.CFrame.Position
	self.priority = 3
	return self
end

BaseCamera.priority = 3

return BaseCamera