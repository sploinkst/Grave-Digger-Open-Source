--!strict
local module = {}

-------------------
-- @Praxitos
-- Primary Camera Service Handler
-------------------

-- // Services
local replicatedstorage_service = game:GetService("ReplicatedStorage")
local player_service            = game:GetService("Players")
local workspace_service         = game:GetService("Workspace")

-- // Constants
local library_folder     = replicatedstorage_service.Shared.Library
local externals_folder   = library_folder.Externals
local typechecker_module = require(externals_folder.TypeChecker)
local camera_class       = require(library_folder.Classes.Miscellanous.CameraClass)

-- // Stack (LIFO)
local Cameras_Stack = {}

-- // Internal Helpers

local function get_top_camera()
	return Cameras_Stack[#Cameras_Stack]
end

local function push_camera(camera_instance)
	table.insert(Cameras_Stack, camera_instance)
end

local function pop_camera()
	return table.remove(Cameras_Stack)
end

local function find_camera_index(name: string)
	for i = #Cameras_Stack, 1, -1 do
		if Cameras_Stack[i].name == name then
			return i
		end
	end
	return nil
end

local function remove_camera_by_name(name: string)
	local index = find_camera_index(name)
	if not index then return nil, nil end
	local cam = table.remove(Cameras_Stack, index)
	return cam, index
end

local function check_cameras()
	for childname, child in pairs(script:GetChildren()) do
		if not typechecker_module.new(camera_class.Camera_Type)(child) then
			warn("[CAMERASERVICE::] CameraModule: ", childname, " fails the type check!")
		end
	end
end

local function resume_camera(camera)
	workspace_service.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	if camera.Resume then
		camera:Resume()
	else
		camera:Start()
	end
end

-- // Core

function module.start_module()
	check_cameras()
	workspace_service.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	module.switch_camera("BaseCamera")
end

function module.switch_camera(target_camera_name: string, abrupt_change: boolean)
	local target_camera_module = script:FindFirstChild(target_camera_name)

	if not target_camera_module then
		warn("[CAMERASERVICE::] No Camera Module Found with the name: ", target_camera_name)
		return
	end

	local target_camera_class = require(target_camera_module)
	local current_camera      = get_top_camera()

	if current_camera and current_camera.name == target_camera_name then
		warn("[CAMERASERVICE::] Already using camera: ", target_camera_name)
		return
	end

	if current_camera and target_camera_class.priority < current_camera.priority then
		warn("[CAMERASERVICE::] Target Camera Module:", target_camera_name, "has lower priority than current: ", current_camera.name)
		return
	end

	if current_camera then
		if abrupt_change then
			current_camera:Cut()
		else
			current_camera:End()
		end
	end

	local new_camera = target_camera_class.new({
		name     = target_camera_name,
		priority = target_camera_class.priority or 0,
	})

	push_camera(new_camera)

	workspace_service.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	new_camera:Start()
end

function module.end_current_camera(abrupt: boolean)
	local current_camera = pop_camera()
	if not current_camera then return end

	if abrupt then
		current_camera:Cut()
	else
		current_camera:End()
	end

	local previous_camera = get_top_camera()

	if previous_camera then
		resume_camera(previous_camera)
	else
		workspace_service.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function module.end_camera_by_name(camera_name: string, abrupt: boolean)
	local index = find_camera_index(camera_name)
	if not index then return end

	local is_top         = (index == #Cameras_Stack)
	local removed_camera = table.remove(Cameras_Stack, index)

	if is_top then
		if abrupt then
			removed_camera:Cut()
		else
			removed_camera:End()
		end

		local previous_camera = get_top_camera()

		if previous_camera then
			resume_camera(previous_camera)
		else
			workspace_service.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	else
		removed_camera:End()
	end
end

function module.apply_recoil(vertical: number, horizontal: number, steps: number?, doRoll: boolean?)
	local current_camera = get_top_camera()
	if current_camera then
		current_camera:ApplyRecoil(vertical, horizontal, steps, doRoll)
	end
end

return module