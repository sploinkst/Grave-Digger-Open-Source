--!strict

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Accessories_Folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Accessories")
local Util = {}

local HitMarker = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild('HitMarker')

-- // Penetration profiles (used by CanPierceFunction inside setupFastCast)

local Penetration_Profiles = {
	[4] = { Stud_Limit = 4, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 70 },
	[3] = { Stud_Limit = 3, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 50 },
	[2] = { Stud_Limit = 2, Materials = { Enum.Material.Wood, Enum.Material.WoodPlanks }, Distance_Limiter = 30 },
	[1] = { Stud_Limit = 1, Materials = {},                                                Distance_Limiter = 0  },
}

-- Deep copy table
function Util.deepCopy(src: {}): {}
	local copy = {}
	for k, v in pairs(src) do
		if type(v) == "table" then
			copy[k] = Util.deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Merge tables recursively
function Util.merge(dest: {}, src: {}): {}
	for k, v in pairs(src) do
		if type(v) == "table" and type(dest[k]) == "table" then
			Util.merge(dest[k], v)
		else
			dest[k] = v
		end
	end
	return dest
end

function Util.quick_weld(p0, p1, parent, name, weld_type)
	if not weld_type then weld_type = Instance.new("Weld") end

	weld_type.Part0 = p0
	weld_type.Part1 = p1
	weld_type.Parent = parent
	weld_type.Name = name
	return weld_type
end

function Util.hide_holster(player: Player, holster_reference: Instance)
	for _, child in pairs(holster_reference:GetDescendants()) do
		if child:GetAttribute("Hide_On_Equip") then
			child.Transparency = 1
		end
	end
end

function Util.show_holster(player: Player, holster_reference: Instance)
	for _, child in pairs(holster_reference:GetDescendants()) do
		if child:GetAttribute("Hide_On_Equip") then
			child.Transparency = 0
		end
	end
end

-- // only use when you know the holster is there
function Util.reverse_search_holster(player: Player, name: string)
	print("Player, name is:", player.Name, name)

	local character = player.Character or player.CharacterAdded:Wait()
	local characterData = character:WaitForChild("CharacterData")
	local renderedHolsters = characterData:WaitForChild("Rendered_Holsters")

	local holster = renderedHolsters:WaitForChild(name)

	if not holster then
		warn("Could not find holster with:", name)
	end

	return holster
end

function Util.reverse_search_model(player, name: string)
	local character = player.Character or player.CharacterAdded:Wait()
	local characterdata = character:WaitForChild("CharacterData")
	local Equipment_Folder = characterdata:WaitForChild("Equipment")

	return Equipment_Folder:WaitForChild(name)
end

function Util.send_raycast(origin: Vector3, direction: Vector3, blacklist: table, whitelist: table)
	if not origin or not direction then warn("[SEND_RAYCAST() FAILED! Origin/Direction not provided") return end

	local raycast_params = RaycastParams.new()

	if blacklist then
		raycast_params.FilterType = Enum.RaycastFilterType.Blacklist
		raycast_params.FilterDescendantsInstances = blacklist
	elseif whitelist then
		raycast_params.FilterType = Enum.RaycastFilterType.Whitelist
		raycast_params.FilterDescendantsInstances = whitelist
	end

	local raycast_result = workspace:Raycast(origin, direction, raycast_params)
	return raycast_result
end

-- // Shared raycast helper that skips fully-transparent parts (invisible walls etc.)
-- Returns the first non-transparent, non-character RaycastResult, or nil if nothing
-- is hit within the given direction vector.
function Util.raycastSkipTransparent(origin: Vector3, direction: Vector3, params: RaycastParams): RaycastResult?
	local ignoreList = table.clone(params.FilterDescendantsInstances or {})

	while true do
		params.FilterDescendantsInstances = ignoreList

		local result = workspace:Raycast(origin, direction, params)

		if not result then
			return nil
		end

		local hit = result.Instance

		-- Skip transparent parts unless explicitly marked as solid
		if hit.Transparency >= 1 and not hit:GetAttribute("Unpiercable") then
			table.insert(ignoreList, hit)
			continue
		end

		return result
	end
end

function Util.MakeFuzzyFinder(list)
	local function score(str, pat)
		local score = 0
		local ip = 1
		for i = 1, #pat do
			local j = string.find(str, string.sub(pat, i, i), j or 1, true)
			if j then
				score += 1 / (0.1 + j + i / #pat)
				ip = i + 1
			end
		end
		return score
	end

	return function(text)
		table.sort(list, function(a, b)
			return score(a, text) > score(b, text)
		end)
		return list
	end
end

function Util.GetNames(list)
	local names = {}
	for _, item in list do
		table.insert(names, typeof(item) == "Instance" and item.Name or tostring(item))
	end
	return names
end

function Util.register_animations(player: Player, animations_table: table)
	print("UTIL:: Received registering animations with:", player.Name, animations_table)
	local character = player.Character
	if not character then
		warn("register_animations: Character not found for", player.Name)
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("register_animations: Humanoid not found for", player.Name)
		return nil
	end

	local animator: Animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn("register_animations: Animator not found, creating one for", player.Name)
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local Animations = {}

	for name, anim in pairs(animations_table) do
		if typeof(anim) ~= "Instance" or not anim:IsA("Animation") then
			warn("Invalid animation for key:", name, "| Expected Animation, got:", typeof(anim))
			continue
		end

		if not anim.AnimationId or anim.AnimationId == "" then
			warn("Animation missing AnimationId:", name)
			continue
		end

		local success, loadedAnim = pcall(function()
			return animator:LoadAnimation(anim)
		end)

		if success and loadedAnim then
			Animations[name] = loadedAnim
		else
			warn("Failed to load animation:", name, loadedAnim)
		end
	end

	return Animations
end

function Util.emit_part(part: Part)
	for _, child in pairs(part:GetDescendants()) do
		if child:IsA("ParticleEmitter") then
			child:Emit(child:GetAttribute("EmitCount") or 1)
		end
	end
end

--[[
	Sets up a FastCast caster with bullet trail visuals and built-in material penetration.

	config = {
		bulletTemplate    : Instance        -- cosmetic bullet part template
		bulletContainer   : Instance        -- where cosmetic bullets are parented
		penetrationLevel  : number?         -- 1-4, drives CanPierceFunction (default 1)
		trailFadeTime     : number?         -- seconds for trail to fade out (default 0.15)
		trailColor        : BrickColor?     -- trail color (default White)
		trailThickness    : number?         -- trail diameter (default 0.07)
		onHit             : (cast, result: RaycastResult, velocity: Vector3) -> ()?
	}

	The caller should set `activeCast.UserData.Shooter` when firing the cast.
	If it is missing, the friendly-fire check will not block the hit.

	Returns: caster, behavior
]]
function Util.setupFastCast(config: {
	bulletTemplate: Instance,
	bulletContainer: Instance,
	penetrationLevel: number?,
	trailFadeTime: number?,
	trailColor: BrickColor?,
	trailThickness: number?,
	onHit: ((cast: any, result: RaycastResult, velocity: Vector3) -> ())?,
	})
	local FastCast = require(game:GetService("ReplicatedStorage").Shared.Library.Externals.FastCast)

	local caster   = FastCast.new()
	local behavior = FastCast.newBehavior()

	local rayParams = RaycastParams.new()
	rayParams.IgnoreWater = true
	rayParams.FilterType  = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { config.bulletContainer }
	behavior.RaycastParams = rayParams

	behavior.CosmeticBulletTemplate  = config.bulletTemplate
	behavior.CosmeticBulletContainer = config.bulletContainer
	behavior.AutoIgnoreContainer     = true

	behavior.HighFidelityBehavior    = FastCast.HighFidelityBehavior.Default
	behavior.HighFidelitySegmentSize = 0.5

	local pierceSnapData: { [any]: Vector3 } = {}

	-- // Resolved once per caster instead of once per hit
	local profile = Penetration_Profiles[config.penetrationLevel or 1]

	local materialSet = {}
	if profile then
		for _, mat in ipairs(profile.Materials) do
			materialSet[mat] = true
		end
	end

	-- // Reused RaycastParams instead of allocating new ones on every pierce
	local thicknessParams = RaycastParams.new()
	thicknessParams.FilterType = Enum.RaycastFilterType.Include

	local exitParams = RaycastParams.new()
	exitParams.FilterType = Enum.RaycastFilterType.Include

	-- // FX references hoisted out of the hot path (indexed once, not per-hit)
	local FxFolder       = ReplicatedStorage.Shared.Assets.Guns.Effects
	local FX_BULLET_HOLE = FxFolder.BulletHole
	local FX_WOOD_CHIPS  = FxFolder.Wood_Chips
	local holesFolder    = workspace.Game_Details.Effects.BulletHoles

	local WOOD_CHIP_NAMES = {
		woodchip1 = true,
		woodchip2 = true,
		woodchip3 = true,
	}

	local woodChipTemplates = {}
	for _, child in FX_WOOD_CHIPS:GetDescendants() do
		if WOOD_CHIP_NAMES[child.Name] then
			table.insert(woodChipTemplates, child)
		end
	end

	behavior.CanPierceFunction = function(cast, result, segmentVelocity)
		if not cast.UserData then
			cast.UserData = {}
		end
		
		local shooter    = cast.UserData and cast.UserData.Shooter
		print("UserData is:", table.concat(cast.UserData, ","))

		local hit = result.Instance
		if not hit then return false end

		if hit.Name == "innerprotection" then
			print("innerprotection hit")
			local faction = hit.Parent.Parent.Name
			local team = shooter.Team.Name

			if (faction == "Empire" and team == "Golden Empire")
				or (faction == "Nation" and team == "Royal Nation") then
				print("friendly fire guard passed", faction.Name, team.Name, shooter.Name)
				return true
			end
			
			print("friendly fire guard failed", faction.Name, team.Name, shooter.Name)
			return false
		end
		if hit.Transparency >= 1 then
			return not hit:GetAttribute("Unpiercable")
		end

		if not hit.CanCollide then
			return not hit:GetAttribute("Unpiercable")
		end

		if hit.Name == "Helmet" and hit.Parent.Name == "Debris" then
			return true
		end

		if not profile then return false end

		local origin = cast.UserData.Origin
		if origin and (origin - result.Position).Magnitude > profile.Distance_Limiter then
			return false
		end

		if not materialSet[result.Material] then
			return false
		end

		-- // Only compute direction once we know we might actually pierce
		local direction = segmentVelocity.Unit

		thicknessParams.FilterDescendantsInstances = { hit }

		local tooThick = workspace:Raycast(
			result.Position + direction * 0.05,
			direction * profile.Stud_Limit,
			thicknessParams
		)

		if tooThick then return false end

		local ancestorModel = hit:FindFirstAncestorWhichIsA("Model")
		if ancestorModel and ancestorModel:FindFirstChild("Humanoid") then
			local hitPlayer = Players:GetPlayerFromCharacter(ancestorModel)

			if hitPlayer and shooter and hitPlayer ~= shooter
				and hitPlayer.Team and shooter.Team
				and hitPlayer.Team.Name ~= shooter.Team.Name then
				return false
			end
		end

		-- // FX

		local entryClone = FX_BULLET_HOLE:Clone()
		entryClone.CFrame = CFrame.new(result.Position, result.Position + result.Normal)
		entryClone.Parent = holesFolder

		if result.Material == Enum.Material.Wood or result.Material == Enum.Material.WoodPlanks then
			for _, template in woodChipTemplates do
				local clone = template:Clone()
				local part = Instance.new("Part")

				part.Size = Vector3.new(0.05, 0.05, 0.05)
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 1
				part.CFrame = CFrame.new(result.Position, result.Position + result.Normal)
				part.Parent = workspace

				clone.Parent = part

				if clone:IsA("ParticleEmitter") then
					clone:Emit(20)
					task.delay(clone.Lifetime.Max + 0.1, function()
						part:Destroy()
					end)
				end
			end
		end

		-- // EXIT LOGIC

		exitParams.FilterDescendantsInstances = { hit }

		local exitOrigin = result.Position + direction * 0.01

		local exitResult = workspace:Raycast(
			exitOrigin,
			direction * profile.Stud_Limit,
			exitParams
		)

		if exitResult then
			local exitClone = FX_BULLET_HOLE:Clone()
			exitClone.CFrame = CFrame.new(exitResult.Position, exitResult.Position + exitResult.Normal)
			exitClone.Parent = holesFolder
		end

		cast.UserData.LastPiercePosition = result.Position
		pierceSnapData[cast] = result.Position

		return true
	end

	-- // Trail helpers

	local fadeTime       = config.trailFadeTime  or 0.15
	local trailColor     = config.trailColor     or BrickColor.new("White")
	local trailThickness = config.trailThickness or 0.07

	local castTrails: { [any]: Part } = {}

	local function fadeAndDestroy(part: Part)
		local tween = TweenService:Create(
			part,
			TweenInfo.new(fadeTime, Enum.EasingStyle.Linear),
			{ Transparency = 1 }
		)
		tween:Play()
		tween.Completed:Connect(function()
			part:Destroy()
		end)
	end

	caster.LengthChanged:Connect(function(cast, lastPoint, direction, length, velocity, cosmeticBullet)
		if cosmeticBullet then
			local snapPos = pierceSnapData[cast]
			if snapPos then
				-- Snap to the pierce position. Use task.defer to clear AFTER
				-- this frame fully resolves so FastCast's own internal reposition
				-- cannot overwrite our snap before it renders.
				cosmeticBullet.Position = snapPos
				task.defer(function()
					pierceSnapData[cast] = nil
				end)
			else
				cosmeticBullet.Position = lastPoint + (direction * length)
			end
		end
	end)

	caster.RayHit:Connect(function(cast, result, velocity, cosmeticBullet)
		if config.onHit then
			local success, err = pcall(config.onHit, cast, result, velocity, cosmeticBullet)
			if not success then
				warn("[FastCast::onHit ERROR]:", err)
			end
		end

		if cosmeticBullet then
			cosmeticBullet:Destroy()
		end

		pierceSnapData[cast] = nil

		local trail = castTrails[cast]
		if trail then
			castTrails[cast] = nil
			fadeAndDestroy(trail)
		end


		if result.Instance and result.Instance.Parent:FindFirstChild("Humanoid") then
			print("HIT")
			local Clone = HitMarker:Clone()
			Clone.Parent = game.Workspace
			Clone.CFrame = CFrame.new(result.Position)
			local tween = TweenService:Create(Clone.bb.img, TweenInfo.new(1), {ImageTransparency = 1})
			tween:Play()
			game.Debris:AddItem(Clone, 3)
		end
	end)

	caster.CastTerminating:Connect(function(cast)
		pierceSnapData[cast] = nil

		local trail = castTrails[cast]
		if trail then
			castTrails[cast] = nil
			fadeAndDestroy(trail)
		end
	end)

	return caster, behavior
end

local Camera_Service = require(game.ReplicatedStorage.Shared.Modules["Client Modules"].CameraService)

-- Recoil
function Util.applyRecoil(
	recoil: number,
	recoilCount: number,
	spread: number,
	doRoll: boolean?,
	scale: number
)
	-- Keep most shots close to the weapon's normal recoil while allowing
	-- occasional stronger or weaker kicks.
	local function gaussian(): number
		local u1 = math.max(math.random(), 1e-6)
		local u2 = math.random()
		return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
	end

	-- Guns predominantly climb, but every shot can also pull left or right.
	local verticalScale = math.clamp(0.055 + gaussian() * 0.008, 0.035, 0.075)
	local horizontalScale = math.clamp(gaussian() * 0.018, -0.04, 0.04)
	local verticalDegrees = recoil * verticalScale
	local horizontalDegrees = recoil * horizontalScale
	local vertical = math.rad(verticalDegrees)
	local horizontal = math.rad(horizontalDegrees)

	Camera_Service.ApplyRecoil(
		vertical,
		horizontal,
		recoilCount,
		doRoll,
		scale
	)
end

function Util.check_for_helmet(character)
	local character_head = character:FindFirstChild("Head")
	if not character_head then return nil, false end

	-- Search head children for AccessoryWeld
	for _, weld in character_head:GetChildren() do
		if (not weld:IsA("Weld") and not weld:IsA("Motor6D")) then continue end
		if weld.Name ~= "AccessoryWeld" then continue end

		local part1 = weld.Part1
		if not part1 then continue end

		local accessoryModel = part1.Parent
		if not accessoryModel then continue end

		if accessoryModel:FindFirstChild("Helmet") then
			local unknockable = accessoryModel:GetAttribute("Unknockable")
			return accessoryModel, not unknockable
		end
	end

	-- Also search via character accessories in case weld is parented differently
	for _, child in character:GetChildren() do
		if not child:IsA("Accessory") and not child:IsA("Model") then continue end
		if not child:FindFirstChild("Helmet") then continue end

		-- Verify it's on the head via attachment or weld
		local handle = child:FindFirstChildWhichIsA("BasePart")
		if not handle then continue end

		local hasHeadConnection = false
		for _, weld in handle:GetChildren() do
			if (weld:IsA("Weld") or weld:IsA("Motor6D")) and
				(weld.Part0 == character_head or weld.Part1 == character_head) then
				hasHeadConnection = true
				break
			end
		end

		if hasHeadConnection then
			local unknockable = child:GetAttribute("Unknockable")
			return child, not unknockable
		end
	end

	return nil, false
end

function Util.fetch_accessory(accessory_name)
	local Accessory = Accessories_Folder:FindFirstChild(accessory_name, true)

	if not Accessory then
		warn("Accessory not found:", accessory_name)
		return false
	end

	return Accessory
end

function Util.create_object(character, accessory)
	local accessory_folder = character:WaitForChild("CharacterData"):WaitForChild("Equipment")

	local clone = accessory:Clone()
	clone.Parent = accessory_folder

	local clone_primary = clone.PrimaryPart
	if not clone_primary then
		warn("Accessory has no PrimaryPart:", clone.Name)
		clone:Destroy()
		return
	end

	local character_reference = character:FindFirstChild(clone_primary.Name)

	if not character_reference then
		warn("Accessory's PrimaryPart not found in character:", clone_primary.Name)
		clone:Destroy()
		return
	end

	if clone:GetAttribute("HideHair") then
		for _, hair in character:GetChildren() do
			if hair:IsA("Accessory") then
				local handle = hair:FindFirstChild("Handle")

				if handle then
					handle.Transparency = 1
					handle.LocalTransparencyModifier = 1
				end
			end
		end
	end

	Util.quick_weld(
		character_reference,
		clone_primary,
		character_reference,
		"AccessoryWeld"
	)

	return clone
end

function Util.quick_give_accessory(player, accessory: Model, create_object: boolean, server_handled: boolean, create_string: boolean)
	if not accessory then
		warn("quick_give_accessory received nil accessory")
		return
	end

	local player_accessory_folder = player.GameData.Accessorys

	if create_string then
		local string_value = Instance.new("StringValue")
		string_value.Name = accessory.Name
		string_value.Parent = player_accessory_folder

		if server_handled then
			string_value:SetAttribute("ServerHandled", true)
		end
	end

	if create_object then
		return Util.create_object(player.Character, accessory)
	end
end

function Util.hasfullammo(player)
	local full = true

	for _, tool in player.Backpack:GetChildren() do
		if tool:FindFirstChild("Reserve_Ammo") then
			if tool.Max_Ammo.Value ~= tool.Reserve_Ammo.Value then
				full = false
			end
		end
	end

	for _, tool in player.Character:GetChildren() do
		if tool:FindFirstChild("Reserve_Ammo") then
			if tool.Max_Ammo.Value ~= tool.Reserve_Ammo.Value then
				full = false
			end
		end
	end

	return full
end
function Util.setammo(player)
	print("[INTERACTIONMANAGER] Adding ammo to player's tools", player.Name)
	for _, tool in player.Backpack:GetChildren() do
		if tool:FindFirstChild("Reserve_Ammo") then
			tool.Reserve_Ammo.Value = tool.Max_Ammo.Value
			print("[INTERACTIONMANAGER] Added ammo to " .. tool.Name)
		end
	end

	for _, tool in player.Character:GetChildren() do
		if tool:FindFirstChild("Reserve_Ammo") then
			tool.Reserve_Ammo.Value = tool.Max_Ammo.Value
			print("[INTERACTIONMANAGER] Added ammo to " .. tool.Name)
		end
	end
end
return Util
