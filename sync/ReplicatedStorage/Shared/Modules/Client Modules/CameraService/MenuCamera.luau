--!strict
local module = {}

-- // Services
local workspace_service = game:GetService("Workspace")
local tween_service     = game:GetService("TweenService")

-- // Constants
local Camera      = workspace_service.CurrentCamera
local CameraClass = require(script.Parent.Parent.Parent.Parent.Library.Classes.Miscellanous.CameraClass)
local BaseCamera  = setmetatable({}, { __index = CameraClass })
BaseCamera.__index = BaseCamera

local game_details = workspace_service:WaitForChild("Game_Details")
local menus_folder = game_details:WaitForChild("Menus")

local Camera_Info_Tables = {
	["Appearance"] = { menus_folder.Appearance_Scene.Camera_Values },
	["Credits"]    = { menus_folder.Credits_Scene.Camera_Values    },
	["Loadout"]    = { menus_folder.Loadout_Scene.Camera_Values    },
	["Servers"]    = { menus_folder.Servers_Scene.Camera_Values    },
	["Settings"]   = { menus_folder.Settings_Scene.Camera_Values   },
}

local current_scene = "Loadout"

-- // Internal State
local active_tween: Tween? = nil

-- // Utilities

local function get_camera_value(scene: string): CFrame?
	local data = Camera_Info_Tables[scene]
	if not data or not data[1] then
		warn("[MENUCAMERA::] No data found for scene:", scene)
		return nil
	end
	return data[1].Value
end

local function cancel_tween()
	if active_tween then
		active_tween:Cancel()
		active_tween = nil
	end
end

local function tween_to(cf: CFrame, duration: number)
	cancel_tween()
	active_tween = tween_service:Create(
		Camera,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = cf }
	)
	active_tween:Play()
end

local function set_camera_instant(cf: CFrame)
	cancel_tween()
	Camera.CFrame = cf
end

local function set_camera_intro(cf: CFrame)
	cancel_tween()
	Camera.CFrame = cf * CFrame.new(0, 0, 3)
	tween_to(cf, 1.5)
end

-- // Core Methods

function BaseCamera:Start()
	print("CameraService: MenuCamera started")
	Camera.CameraType = Enum.CameraType.Scriptable
	local cf = get_camera_value(current_scene)
	if not cf then return end
	set_camera_intro(cf)
end

function BaseCamera:Resume()
	-- MenuCamera has no paused state to restore; treat resume as a fresh start
	self:Start()
end

function BaseCamera:End()
	print("CameraService: MenuCamera ended")
	cancel_tween()
	-- leave CameraType alone — CameraService resets it before handing off
end

function BaseCamera:Cut(target_scene: string?)
	cancel_tween()
	if target_scene then
		if not Camera_Info_Tables[target_scene] then
			warn("[MENUCAMERA::] No Camera Info Table for scene:", target_scene)
			return
		end
		current_scene = target_scene
	end
	local cf = get_camera_value(current_scene)
	if not cf then return end
	set_camera_instant(cf)
end

function BaseCamera:Switch(target_scene: string)
	if not Camera_Info_Tables[target_scene] then
		warn("[MENUCAMERA::] No Camera Info Table for scene:", target_scene)
		return
	end
	current_scene = target_scene
	local cf = get_camera_value(target_scene)
	if not cf then return end
	set_camera_intro(cf)
end

-- // Constructor

function BaseCamera.new(cameraInfo)
	local self = CameraClass.new(cameraInfo)
	setmetatable(self, BaseCamera)
	self.className      = "MenuCamera"
	self.name           = "MenuCamera"
	self.CameraPosition = Camera.CFrame.Position
	self.priority       = 3
	return self
end

BaseCamera.priority = 3

return BaseCamera