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

local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local miningCooldowns = setmetatable({}, {__mode = "k"})
local MINING_REACH = 5
local TUNNEL_SIZE = Vector3.new(16, 14, 14)
local ROCK_MINED_SOUND_ID = "rbxassetid://0" -- Replace when the mining sound is available.

local function playRockImpact(position, normal)
	local assets = ReplicatedStorageService.Shared.Assets
	local template = assets.Guns.Effects:FindFirstChild("rockbreak")
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
				item.CanCollide = false
				item.CanQuery = false
				item.CanTouch = false
			elseif item:IsA("ParticleEmitter") then
				item.Enabled = false
				lifetime = math.max(lifetime, item.Lifetime.Max + 1)
				task.delay(0.05, function()
					if item.Parent then item:Emit(item:GetAttribute("EmitCount") or 20) end
				end)
			end
		end
	end
	local sound = effect and effect:FindFirstChildWhichIsA("Sound", true)
	if not sound then
		local soundTemplate = assets:FindFirstChild("rock_mined", true)
			or ServerStorage:FindFirstChild("rock_mined", true)
		sound = soundTemplate and soundTemplate:IsA("Sound") and soundTemplate:Clone() or Instance.new("Sound")
		if sound.SoundId == "" then sound.SoundId = ROCK_MINED_SOUND_ID end
		sound.Parent = anchor
	end
	sound.RollOffMaxDistance = 70
	if sound.SoundId ~= "" and sound.SoundId ~= "rbxassetid://0" then
		sound:Play()
		lifetime = math.max(lifetime, sound.TimeLength + 1)
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
	if not hit or hit.Instance ~= workspace.Terrain or hit.Material ~= Enum.Material.Rock then return end
	local center = hit.Position + unit * (TUNNEL_SIZE.Z / 2 - 2)
	TerrainService:FillBlock(CFrame.lookAt(center, center + unit), TUNNEL_SIZE, Enum.Material.Air)
	playRockImpact(hit.Position, hit.Normal)
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
