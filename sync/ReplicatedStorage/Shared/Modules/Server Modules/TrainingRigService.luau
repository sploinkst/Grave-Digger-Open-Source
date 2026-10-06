-- Passive, fully equipped R6 targets; no weapon controller is activated.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Library = RS.Shared.Library
local Items = require(script.Parent.ItemsService)
local PlayerSetup = require(script.Parent.PlayerService)
local Medical = require(script.Parent.MedicalService)
local Voice = require(Library.CharacterVoice)
local Playback = require(Library.SoundPlayback)
local Resolver = require(Library.Classes.GunClasses.AnimationResolver)
local Util = require(Library.Util)
local Service = {}
local owners = setmetatable({}, {__mode = "k"})
local WeaponIds = require(Library.WeaponIds)
local configurations = {
	NationRig = {team = "Royal Nation", primary = "PrinceRifle"},
	EmpireRig = {team = "Golden Empire", primary = "VolkRifle"},
}

local function folder(parent, name)
	local result = parent:FindFirstChild(name) or Instance.new("Folder")
	result.Name, result.Parent = name, parent
	return result
end

local function loadTrack(animator, source, weapon, binding, looped, priority)
	if not source then return nil end
	local playable = Resolver.Resolve(source, weapon, binding)
	if not playable then return nil end
	local track = animator:LoadAnimation(playable)
	track.Looped, track.Priority = looped, priority
	return track
end

function Service.Load(character, config)
	if character:GetAttribute("TrainingRigLoaded") then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then error(character.Name .. " requires a Humanoid and HumanoidRootPart") end
	if humanoid.RigType ~= Enum.HumanoidRigType.R6 then error(character.Name .. " must use R6, like the player characters") end
	character:SetAttribute("TrainingRigLoaded", true)
	character:SetAttribute("IsTrainingRig", true)
	character:SetAttribute("Team", config.team)
	character:SetAttribute("Class", "Soldat")
	character:SetAttribute("ClassPrimary", config.primary)
	character:SetAttribute("ClassSecondary", "GraceRevolver")
	character:SetAttribute("ClassMelee", "Knife")
	character:SetAttribute("ClassSnapshotReady", true)
	character:SetAttribute("Equipment", "AmmoPack")
	for _, item in character:GetDescendants() do
		if item:IsA("BasePart") then item.Anchored = false end
		if item:IsA("Script") or item:IsA("LocalScript") then item.Enabled = false end
	end
	root:SetNetworkOwner(nil)
	humanoid.MaxHealth, humanoid.Health = 200, 200
	humanoid.BreakJointsOnDeath = false
	humanoid.DisplayName = character.Name
	PlayerSetup.SetupTrainingCharacter(character, config.team)
	character.gender.Value = character:GetAttribute("Gender") or "m"
	character.language.Value = "american"
	character.class.Value = "Soldat"
	character.CharacterData.State.Equipment.Value = "AmmoPack"
	local backpack = folder(character, "Backpack")
	local gameData = folder(character, "GameData")
	local accessories = folder(gameData, "Accessorys")
	folder(accessories, "Holsters")
	folder(accessories, "Hairs")
	folder(accessories, "Hats")
	-- ItemsService only needs a character and inventory owner for passive items.
	-- This adapter is never inserted into Players or used to authorize remotes.
	local owner = {Name = character.Name, Character = character, GameData = gameData}
	function owner:FindFirstChild(name) return character:FindFirstChild(name) end
	function owner:WaitForChild(name) return character:WaitForChild(name) end
	function owner:GetAttribute(name) return character:GetAttribute(name) end
	function owner:SetAttribute(name, value) character:SetAttribute(name, value) end
	owners[character] = owner
	local loadout = {config.primary, "GraceRevolver", "Compass", "Medkit", "Knife", "Pickaxe"}
	for index, name in ipairs(loadout) do
		local designation = index == 1 and "Primary" or index == 2 and "Secondary" or index == 5 and "Melee" or nil
		local result = Items.give_item(owner, name, nil, designation)
		if result ~= "Successfully gave item." then error("Unable to grant " .. name .. ": " .. tostring(result)) end
		local tool = backpack:FindFirstChild(name)
		local reserve = tool and tool:FindFirstChild("Reserve_Ammo")
		local maximum = tool and tool:FindFirstChild("Max_Ammo")
		if reserve and maximum then reserve.Value = maximum.Value end
	end
	-- Holsters normally render on clients for actual Players. Render this NPC's
	-- same authored assemblies on the server so every observer sees them.
	for _, value in accessories.Holsters:GetChildren() do
		local source = Library.Parent.Assets.Guns.Holsters:FindFirstChild(value.Name)
		if source and source:IsA("Model") then
			local clone = Util.create_object(character, source)
			if clone then
				clone.Parent = character.CharacterData.Rendered_Holsters
				local originalTransparency = {}
				for _, part in clone:GetDescendants() do
					if part:IsA("BasePart") then originalTransparency[part] = part.Transparency end
				end
				value:GetPropertyChangedSignal("Value"):Connect(function()
					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") then part.Transparency = value.Value and originalTransparency[part] or 1 end
					end
				end)
			end
		end
	end
	local equipment = folder(character.equipment, "AmmoPack")
	local charges = Instance.new("IntValue")
	charges.Name, charges.Value, charges.Parent = "Charges", 2, equipment
	local primary = backpack:FindFirstChild(config.primary)
	if primary then humanoid:EquipTool(primary) end
	character.tools_loaded.Value = true
	character:SetAttribute("ClassEquipmentGranted", true)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local characterAnimations = RS.Shared.Assets.Animations.Character
	local idleSource = characterAnimations:FindFirstChild("Stand_Idle", true)
	local idle = loadTrack(animator, idleSource, nil, nil, true, Enum.AnimationPriority.Idle)
	if idle then idle:Play(0.1) end
	local weapons = RS:FindFirstChild("ToolAnimations")
	local weapon
	for _, alias in WeaponIds.Aliases(config.primary) do
		weapon = weapons and weapons:FindFirstChild(alias)
		if weapon then break end
	end
	local held = loadTrack(animator, weapon and weapon:FindFirstChild("held", true), config.primary, "held", true, Enum.AnimationPriority.Action)
	if held then held:Play(0.1) end
	local movement = RS:FindFirstChild("MovementAnimations")
	local reactions = {}
	for _, name in ipairs({"injured_left", "injured_right"}) do
		local track = loadTrack(animator, movement and movement:FindFirstChild(name), nil, nil, false, Enum.AnimationPriority.Action2)
		if track then table.insert(reactions, track) end
	end
	local lastHealth = humanoid.Health
	humanoid.HealthChanged:Connect(function(health)
		local damage = lastHealth - health
		lastHealth = health
		character:SetAttribute("Injured", health > 0 and health < 100 or nil)
		if damage <= 0 then return end
		local clip = Voice.Choose(character, damage > 100 and "heavy" or "hurt")
		if clip then Playback.Play(clip, root, {RollOffMaxDistance = 75}) end
		if health > 0 and #reactions > 0 then
			for _, track in ipairs(reactions) do track:Stop(0.05) end
			reactions[math.random(#reactions)]:Play(0.05)
		end
	end)
	Medical.TrackHumanoid(humanoid)
	humanoid.Died:Connect(function()
		owners[character] = nil
		require(script.Parent.StatusService).RemoveAllStatuses(owner)
		for _, track in animator:GetPlayingAnimationTracks() do track:Stop(0) end
		require(Library.Classes.StatusClasses.RagdollStatus).new():_special_apply(character)
	end)
	character.Destroying:Connect(function()
		owners[character] = nil
		require(script.Parent.StatusService).RemoveAllStatuses(owner)
	end)
	character:SetAttribute("TrainingRigReady", true)
end

function Service.ApplyDamageStatus(character, origin, weaponName)
	local owner = owners[character]
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not owner or not humanoid or humanoid.Health <= 0 then return end
	local Status = require(script.Parent.StatusService)
	Status.GiveStatus(owner, "ClottingStatus", 5)
	Status.GiveStatus(owner, "HitstunStatus", 1)
	if humanoid.Health < 100 then Status.GiveStatus(owner, "WoundStatus", "Bullet", origin) end
	if weaponName == "AntiMaterialRifle" then Status.GiveStatus(owner, "ConcussionStatus") end
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	-- Only explicitly named rigs are initialized outside Studio.
	local rig = workspace:FindFirstChild("Rig")
	if RunService:IsStudio() and rig and rig:IsA("Model") and rig:FindFirstChildOfClass("Humanoid") then
		for name in pairs(configurations) do
			if not workspace:FindFirstChild(name) then
				local clone = rig:Clone()
				clone.Name = name
				clone:PivotTo(rig:GetPivot() * CFrame.new(name == "NationRig" and -5 or 5, 0, 0))
				clone.Parent = workspace
			end
		end
		rig.Parent = game:GetService("ServerStorage") -- Preserve the source template.
	end
	local function added(character)
		local config = configurations[character.Name]
		if config and character:IsA("Model") then
			task.spawn(function()
				local ok, err = pcall(Service.Load, character, config)
				if not ok then
					character:SetAttribute("TrainingRigReady", false)
					warn("[TrainingRigs] " .. character.Name .. ": " .. tostring(err))
				end
			end)
		end
	end
	workspace.ChildAdded:Connect(added)
	for _, character in workspace:GetChildren() do added(character) end
end
return Service
