local module = {}

-- // Services
local workspace_service = game:GetService("Workspace")
local replicatedstorage_service = game:GetService("ReplicatedStorage")

-- // Constants
local game_setup = workspace_service.Game_Details.Main_Game
local field_setup = game_setup.field_setup
local mineable_region = field_setup.mineable_region

local terrain_service = workspace_service.Terrain

local nation_spawn = replicatedstorage_service.Shared.Assets.Maps.Spawn_Rooms.Regular.Nation
local empire_spawn = replicatedstorage_service.Shared.Assets.Maps.Spawn_Rooms.Regular.Empire

local delete_terrain_event = replicatedstorage_service.Shared.Library.Events.Terrain_Communication.Delete_Terrain

--------------------------------------------------
-- BASE SETUPS
--------------------------------------------------

local function fill_mineable_region()
	terrain_service:FillBlock(
		mineable_region.CFrame,
		mineable_region.Size,
		Enum.Material.Rock
	)
end

local function fill_unminable_regions()
	for _, child in ipairs(field_setup:GetDescendants()) do
		if child:IsA("BasePart") and child.Name:lower():find("nomining") then
			terrain_service:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Basalt
			)
			
			print(child.Name, "filled")
		end
	end
end

--------------------------------------------------
-- SPAWN ROOMS
--------------------------------------------------

local function set_spawn_rooms()
	nation_spawn.Parent = game_setup
	empire_spawn.Parent = game_setup
end

local max_x = 100

local function randomize_spawn(model: Model)
	print("[TerrainService] randomizing spawn room location...")
	
	local CurrentCFrame = model:GetPivot()
	local NewCFrame = CurrentCFrame * CFrame.new(0, 0,math.random(-max_x, max_x))
	print("[TerrainService] CurrentCFrame is: ", CurrentCFrame, "New CFrame Is:", NewCFrame)
	
	model:PivotTo(NewCFrame)
	print("[TerrainService] Spawn room location randomized!")
end

local function basalt_spawns()
	local padding = Vector3.new(50, 50, 50)

	terrain_service:FillBlock(
		nation_spawn.basecenter.CFrame,
		nation_spawn.basecenter.Size + padding,
		Enum.Material.Basalt
	)

	terrain_service:FillBlock(
		empire_spawn.Terrain.Air.CFrame,
		empire_spawn.Terrain.Air.Size + padding,
		Enum.Material.Basalt
	)
end

local function carve_spawn_rooms()
	terrain_service:FillBlock(
		nation_spawn.basecenter.CFrame,
		nation_spawn.basecenter.Size,
		Enum.Material.Air
	)

	terrain_service:FillBlock(
		empire_spawn.Terrain.Air.CFrame,
		empire_spawn.Terrain.Air.Size,
		Enum.Material.Air
	)
end

local function fill_spawn_rooms()
	terrain_service:FillBlock(
		nation_spawn.basecenter.CFrame,
		nation_spawn.basecenter.Size,
		Enum.Material.Basalt
	)

	terrain_service:FillBlock(
		empire_spawn.Terrain.Air.CFrame,
		empire_spawn.Terrain.Air.Size,
		Enum.Material.Basalt
	)
end

local function carve_entrances()
	for _, child in ipairs(empire_spawn.Entrances:GetChildren()) do
		if child:IsA("BasePart") then
			terrain_service:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Air
			)
		end
	end

	for _, child in ipairs(nation_spawn.Entrances:GetChildren()) do
		if child:IsA("BasePart") then
			terrain_service:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Air
			)
		end
	end
end


local function handle_delete_terrain(...)
	local args = { ... }

	local position
	local size

	-- Vector3 position supplied
	if typeof(args[2]) == "Vector3" then
		position = args[2]
		size = args[3]

		-- XYZ supplied separately
	elseif typeof(args[2]) == "number"
		and typeof(args[3]) == "number"
		and typeof(args[4]) == "number" then

		position = Vector3.new(
			args[2],
			args[3],
			args[4]
		)

		size = args[5]
	end

	if not position or not size then
		warn("Delete terrain called with invalid arguments")
		return
	end

	if typeof(size) == "number" then
		size = Vector3.new(size, size, size)
	end

	terrain_service:FillBlock(
		CFrame.new(position),
		size,
		Enum.Material.Air
	)
end

-- // Start
function module.start_module()
	set_spawn_rooms()
	
	randomize_spawn(empire_spawn)
	randomize_spawn(nation_spawn)
	fill_mineable_region()
	fill_unminable_regions()

	basalt_spawns()
	carve_spawn_rooms()
	carve_entrances()

	delete_terrain_event.OnServerEvent:Connect(handle_delete_terrain)
end

function module.fill_terrain()
	fill_mineable_region()
	fill_unminable_regions()
end

function module.randomize_spawn_rooms()
	fill_spawn_rooms()
	randomize_spawn(empire_spawn)
	randomize_spawn(nation_spawn)
	carve_spawn_rooms()
	carve_entrances()
end
return module