local Module = {}

-- // Services
local WorkspaceService = game:GetService("Workspace")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")

-- // Constants
local GameSetup = WorkspaceService.Game_Details.Main_Game
local FieldSetup = GameSetup.field_setup
local MineableRegion = FieldSetup.mineable_region

local TerrainService = WorkspaceService.Terrain

local NationSpawn = ReplicatedStorageService.Shared.Assets.Maps.Spawn_Rooms.Regular.Nation
local EmpireSpawn = ReplicatedStorageService.Shared.Assets.Maps.Spawn_Rooms.Regular.Empire

local DeleteTerrainEvent = ReplicatedStorageService.Shared.Library.Events.DeleteTerrain

local Sounds = ReplicatedStorageService:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Music")
local RadioFolder = Sounds:WaitForChild("Radio")
local GramophoneFolder = Sounds:WaitForChild("Gramophone")

-- // mineable regions

local function FillMineableRegion()
	TerrainService:FillBlock(
		MineableRegion.CFrame,
		MineableRegion.Size,
		Enum.Material.Rock
	)
end

local function FillUnminableRegions()
	for _, child in ipairs(FieldSetup:GetDescendants()) do
		if child:IsA("BasePart") and child.Name:lower():find("nomining") then
			TerrainService:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Basalt
			)

			print(child.Name, "filled")
		end
	end
end

-- // spawn rooms

local function SetSpawnRooms()
	NationSpawn.Parent = GameSetup
	EmpireSpawn.Parent = GameSetup

	local radioSong = RadioFolder:FindFirstChild(1, #RadioFolder:GetChildren()):Clone()
	local gramoSong = GramophoneFolder:FindFirstChild(1, #GramophoneFolder:GetChildren()):Clone()

	gramoSong.Parent = EmpireSpawn.Details.gramophone.musicpart
	RadioFolder.Parent = NationSpawn.Details.radio_stuff

	gramoSong:Play()
	radioSong:Play()
end

local maxX = 100

local function RandomizeSpawn(model: Model)
	print("[TerrainService] randomizing spawn room location...")

	local currentCFrame = model:GetPivot()
	local newCFrame = currentCFrame * CFrame.new(0, 0, math.random(-maxX, maxX))
	print("[TerrainService] CurrentCFrame is: ", currentCFrame, "New CFrame Is:", newCFrame)

	model:PivotTo(newCFrame)
	print("[TerrainService] Spawn room location randomized!")
	
	-- // add wait to make sure script continues once model is actually pivoted
	task.wait(1)
end

local function BasaltSpawns()
	local padding = Vector3.new(50, 50, 50)

	TerrainService:FillBlock(
		NationSpawn.Terrain.Air.CFrame,
		NationSpawn.Terrain.Air.Size + padding,
		Enum.Material.Basalt
	)

	TerrainService:FillBlock(
		EmpireSpawn.Terrain.Air.CFrame,
		EmpireSpawn.Terrain.Air.Size + padding,
		Enum.Material.Basalt
	)
end

local function CarveSpawnRooms()
	TerrainService:FillBlock(
		NationSpawn.Terrain.Air.CFrame,
		NationSpawn.Terrain.Air.Size,
		Enum.Material.Air
	)

	TerrainService:FillBlock(
		EmpireSpawn.Terrain.Air.CFrame,
		EmpireSpawn.Terrain.Air.Size,
		Enum.Material.Air
	)
end

local function FillSpawnRooms()
	TerrainService:FillBlock(
		NationSpawn.Terrain.Air.CFrame,
		NationSpawn.Terrain.Air.Size,
		Enum.Material.Basalt
	)

	TerrainService:FillBlock(
		EmpireSpawn.Terrain.Air.CFrame,
		EmpireSpawn.Terrain.Air.Size,
		Enum.Material.Basalt
	)
end

local function CarveEntrances()
	for _, child in ipairs(EmpireSpawn.Entrances:GetChildren()) do
		if child:IsA("BasePart") then
			TerrainService:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Air
			)
		end
	end

	for _, child in ipairs(NationSpawn.Entrances:GetChildren()) do
		if child:IsA("BasePart") then
			TerrainService:FillBlock(
				child.CFrame,
				child.Size,
				Enum.Material.Air
			)
		end
	end
end

local function HandleDeleteTerrain(...)
	local args = { ... }

	local position
	local size

	-- // Vector3 position supplied
	if typeof(args[2]) == "Vector3" then
		position = args[2]
		size = args[3]

		-- // XYZ supplied separately
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

	TerrainService:FillBlock(
		CFrame.new(position),
		size,
		Enum.Material.Air
	)
end

-- // Start
function Module.start_module()
	SetSpawnRooms()

	RandomizeSpawn(EmpireSpawn)
	RandomizeSpawn(NationSpawn)
	FillMineableRegion()
	FillUnminableRegions()

	BasaltSpawns()
	CarveSpawnRooms()
	CarveEntrances()

	DeleteTerrainEvent.OnServerEvent:Connect(HandleDeleteTerrain)
end

function Module.FillTerrain()
	FillMineableRegion()
	FillUnminableRegions()
end

function Module.RandomizeSpawnRooms()
	FillSpawnRooms()
	RandomizeSpawn(EmpireSpawn)
	RandomizeSpawn(NationSpawn)
	BasaltSpawns()
	CarveSpawnRooms()
	CarveEntrances()
end

return Module