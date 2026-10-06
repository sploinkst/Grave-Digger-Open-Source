local Module = {}

-- // Services
local WorkspaceService = game:GetService("Workspace")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")
local SoundPlayback = require(ReplicatedStorageService.Shared.Library.SoundPlayback)

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

local Debris = game:GetService("Debris")
local miningCooldowns = setmetatable({}, {__mode = "k"})
local MINING_REACH = 5
local TUNNEL_SIZE = Vector3.new(16, 14, 14)
local DEBRIS_DELAY = 0.08

local function playRockImpact(position, normal)
	local assets = ReplicatedStorageService.Shared.Assets
	local effects = assets:FindFirstChild("Effects")
	local mining = effects and effects:FindFirstChild("Mining")
	local template = (mining and mining:FindFirstChild("rockbreak"))
		or assets.Guns.Effects:FindFirstChild("rockbreak")
		or (mining and mining:FindFirstChild("smallrock"))
		or assets.Guns.Effects:FindFirstChild("smallrock")
	local anchor = Instance.new("Part")
	anchor.Name = "RockMiningImpact"
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.CFrame = CFrame.lookAt(position, position + normal)
	anchor.Parent = workspace
	local lifetime = 3
	local effect = template and template:Clone()
	if effect then
		effect.Parent = anchor
		if effect:IsA("BasePart") then effect.CFrame = anchor.CFrame
		elseif effect:IsA("Model") then effect:PivotTo(anchor.CFrame) end
		local descendants = effect:GetDescendants()
		table.insert(descendants, effect)
		for _, item in descendants do
			if item:IsA("BasePart") then
				item.Anchored = true
				item.Transparency = 1
				item.CanCollide = false
				item.CanQuery = false
				item.CanTouch = false
			elseif item:IsA("ParticleEmitter") then
				item.Enabled = false
				lifetime = math.max(lifetime, item.Lifetime.Max + 1)
				task.delay(0.05, function()
					if item.Parent and item.Name ~= "coalbreak" then
						item:Emit(item:GetAttribute("EmitCount") or 20)
					end
				end)
			end
		end
	end
	local atmosphere = assets.Sounds:FindFirstChild("Atmosphere")
	local rocks = atmosphere and atmosphere:FindFirstChild("Rocks")
	local breakSound = rocks and rocks:FindFirstChild("break")
	local options = {RollOffMaxDistance = 70, PitchVariation = 0.1}
	if breakSound and breakSound:IsA("Sound") then SoundPlayback.Play(breakSound, anchor, options) end
	local debrisSounds = {}
	for index = 1, 5 do
		local sound = rocks and rocks:FindFirstChild("debris" .. index)
		if sound and sound:IsA("Sound") then table.insert(debrisSounds, sound) end
	end
	if #debrisSounds > 0 then
		local debrisSound = debrisSounds[math.random(#debrisSounds)]
		task.delay(DEBRIS_DELAY, function()
			if anchor.Parent then SoundPlayback.Play(debrisSound, anchor, options) end
		end)
	end
	Debris:AddItem(anchor, lifetime)
end

local function HandleDeleteTerrain(player, direction)
	if typeof(direction) ~= "Vector3" then return end
	local magnitude = direction.Magnitude
	if magnitude ~= magnitude or magnitude == math.huge or magnitude < 0.01 then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	local tool = character and character:FindFirstChildOfClass("Tool")
	if not head or not humanoid or humanoid.Health <= 0 or not tool
		or (tool.Name ~= "Pickaxe" and tool.Name ~= "HeavyPickaxe") then return end
	if (miningCooldowns[player] or 0) > os.clock() then return end
	miningCooldowns[player] = os.clock() + 0.4
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local unit = direction.Unit
	local hit = workspace:Raycast(head.Position, unit * MINING_REACH, params)
	if not hit or hit.Instance ~= workspace.Terrain then return end
	if hit.Material ~= Enum.Material.Rock then
		return
	end
	local center = hit.Position + unit * (TUNNEL_SIZE.Z / 2 - 2)
	TerrainService:FillBlock(CFrame.lookAt(center, center + unit), TUNNEL_SIZE, Enum.Material.Air)
	playRockImpact(hit.Position, hit.Normal)
	DeleteTerrainEvent:FireClient(player)
	require(script.Parent.Parent.ClassService).RecordMining(player)
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

-- Explosive mining follows the same Rock-only, region-bounded rule as picks.
function Module.MineImpact(player, position, direction, radius)
 if typeof(position) ~= "Vector3" or typeof(direction) ~= "Vector3" then return false end
 local localPosition = MineableRegion.CFrame:PointToObjectSpace(position)
 local half = MineableRegion.Size / 2
 if math.abs(localPosition.X) > half.X or math.abs(localPosition.Y) > half.Y or math.abs(localPosition.Z) > half.Z then return false end
 local size = math.clamp(radius, 1, 6)
 local region = Region3.new(position - Vector3.one * size, position + Vector3.one * size):ExpandToGrid(4)
 local materials, occupancy = TerrainService:ReadVoxels(region, 4)
 for x, plane in ipairs(materials) do
  for y, row in ipairs(plane) do
   for z, material in ipairs(row) do
    if material == Enum.Material.Rock then materials[x][y][z] = Enum.Material.Air; occupancy[x][y][z] = 0 end
   end
  end
 end
 TerrainService:WriteVoxels(region, 4, materials, occupancy)
 require(script.Parent.Parent.ClassService).RecordMining(player)
 return true
end

return Module
