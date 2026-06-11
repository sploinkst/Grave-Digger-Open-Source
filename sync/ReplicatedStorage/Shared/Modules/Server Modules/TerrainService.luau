local module = {}

-- // services
local workspace_service = game:GetService("Workspace")
local replicatedstorage_service = game:GetService("ReplicatedStorage")

-- // constants
local game_setup = workspace_service.Game_Details.Main_Game
local field_setup = game_setup.field_setup
local mineable_region = field_setup.mineable_region

local terrain_service = workspace_service.Terrain

local nation_spawn = replicatedstorage_service.Shared.Assets.Maps.Spawn_Rooms.Regular.Nation
local empire_spawn = replicatedstorage_service.Shared.Assets.Maps.Spawn_Rooms.Regular.Empire

local delete_terrain_event = replicatedstorage_service.Shared.Library.Events.Terrain_Communication.Delete_Terrain
-- // variables


-- // funcs

---------------
-- BASE SETUPS
---------------
-- fills area with rock
local function fill_mineable_region()
	
	terrain_service:FillBlock(mineable_region.CFrame, mineable_region.Size, Enum.Material.Rock)
end

-- fills area with basalt
local function fill_unminable_regions()
	
	for _, child in pairs(mineable_region:GetChildren()) do
		if string.find(child.Name, "nomining") then
			terrain_service:FillBlock(child.CFrame, child.Size, Enum.Material.Basalt)
		end
	end
end

-----------------------
-- SPAWN ROOMS
-----------------------
local function set_spawn_rooms()
	
	nation_spawn.Parent = workspace_service.Game_Details.Main_Game
	empire_spawn.Parent = workspace_service.Game_Details.Main_Game
end



local function carve_spawn_rooms()
	
	terrain_service:FillBlock(nation_spawn.basecenter.CFrame, nation_spawn.basecenter.Size, Enum.Material.Air)
	terrain_service:FillBlock(empire_spawn.Terrain.Air.CFrame, empire_spawn.Terrain.Air.Size, Enum.Material.Air)
end


local function basalt_spawns()
	terrain_service:FillBlock(nation_spawn.basecenter.CFrame, nation_spawn.basecenter.Size + Vector3.new(50, 50, 50), Enum.Material.Basalt)
	terrain_service:FillBlock(empire_spawn.Terrain.Air.CFrame, empire_spawn.Terrain.Air.Size + Vector3.new(50, 50, 50), Enum.Material.Basalt)
end

local function carve_entrances()
	-- // carving only entrance for now

	for _, child in pairs(empire_spawn.Entrances:GetChildren()) do
		terrain_service:FillBlock(child.CFrame, child.Size, Enum.Material.Air)
	end

	for _, child in pairs(nation_spawn.Entrances:GetChildren()) do
		terrain_service:FillBlock(child.CFrame, child.Size, Enum.Material.Air)
	end
end


-------------------------
-- CONNECTS
-------------------------
local function handle_delete_terrain(...)
	local args = {...}

	local player = args[1]

	local position
	local size

	-- Case 1: Proper Vector3 passed
	if typeof(args[2]) == "Vector3" then
		position = args[2]
		size = args[3]

		-- Case 2: XYZ passed separately
	elseif typeof(args[2]) == "number" and typeof(args[3]) == "number" and typeof(args[4]) == "number" then
		position = Vector3.new(args[2], args[3], args[4])
		size = args[5]
	end

	-- Normalize size
	if typeof(size) == "number" then
		size = Vector3.new(size, size, size)
	end

	terrain_service:FillBlock(CFrame.new(position), size, Enum.Material.Air)
end

function module.start_module()
	
	set_spawn_rooms()
	fill_mineable_region()
	fill_unminable_regions()
	basalt_spawns()
	carve_spawn_rooms()
	carve_entrances()
	
	delete_terrain_event.OnServerEvent:Connect(handle_delete_terrain)
end

return module
