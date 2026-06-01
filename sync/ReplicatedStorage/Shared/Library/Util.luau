--!strict

local TweenService = game:GetService("TweenService")

local Util = {}

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
		print("Checking", anim.Name, "has value of:", anim.AnimationId)

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
	Sets up a FastCast caster with bullet trail visuals.

	config = {
		bulletTemplate  : Instance        -- cosmetic bullet part template
		bulletContainer : Instance        -- where cosmetic bullets are parented (usually workspace)
		trailFadeTime   : number?         -- seconds for trail to fade out (default 0.15)
		trailColor      : BrickColor?     -- trail color (default White)
		trailThickness  : number?         -- trail diameter (default 0.07)
		onHit           : (cast, result: RaycastResult, cosmeticBullet: BasePart?) -> ()?
	}

	Returns: caster, behavior
]]


function Util.setupFastCast(config: {
	bulletTemplate: Instance,
	bulletContainer: Instance,
	trailFadeTime: number?,
	trailColor: BrickColor?,
	trailThickness: number?,
	penetrationLevel: number?,
	armorPenetrationLevel: number?,
	onHit: ((cast: any, result: RaycastResult, cosmeticBullet: BasePart?) -> ())?,
	})
	local FastCast = require(game:GetService("ReplicatedStorage").Shared.Library.Externals.FastCast)
	local TweenService = game:GetService("TweenService")

	local caster = FastCast.new()
	local behavior = FastCast.newBehavior()

	-- RaycastParams setup to hit everything except the bullets themselves
	local rayParams = RaycastParams.new()
	rayParams.IgnoreWater = true
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { config.bulletContainer }
	behavior.RaycastParams = rayParams

	behavior.RaycastParams = rayParams
	behavior.CosmeticBulletTemplate = config.bulletTemplate
	behavior.CosmeticBulletContainer = config.bulletContainer
	behavior.AutoIgnoreContainer = true

	behavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Always
	behavior.HighFidelitySegmentSize = 0.1 -- smaller segments for fast bullets

	local fadeTime = config.trailFadeTime or 0.15
	local trailColor = config.trailColor or BrickColor.new("White")
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
			cosmeticBullet.Position = lastPoint + (direction * length)
		end

		if not castTrails[cast] then
			local trail = Instance.new("Part")
			trail.Anchored = true
			trail.CanCollide = false
			trail.CanQuery = false
			trail.CastShadow = false
			trail.Material = Enum.Material.Neon
			trail.BrickColor = trailColor
			trail.Transparency = 0.4
			trail.Parent = workspace
			castTrails[cast] = trail
		end

		local trail = castTrails[cast]
		local tipPosition = lastPoint + (direction * length)
		local midPoint = (lastPoint + tipPosition) / 2

		trail.Size = Vector3.new(trailThickness, trailThickness, length)
		trail.CFrame = CFrame.new(midPoint, tipPosition)
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

		local trail = castTrails[cast]
		if trail then
			castTrails[cast] = nil
			fadeAndDestroy(trail)
		end
	end)

	caster.CastTerminating:Connect(function(cast)
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
function Util.applyRecoil(recoil: number, recoilCount: number, spread: number, doRoll: boolean?)
	local vertical   = recoil / 10
	local horizontal = math.random(-spread * 10, spread * 10) / 100

	Camera_Service.apply_recoil(math.rad(vertical), math.rad(horizontal), recoilCount)

	if doRoll then
		task.spawn(function()
			for _ = 1, 4 do
				Camera_Service.apply_recoil(0, math.rad(2))
				task.wait(0.015)
			end
		end)
	end
end

function Util.quick_give_accessory(player, accessory:Model, create_object: boolean)
	local character = player.Character
	local accessory_folder = character.CharacterData.Equipment



	if create_object then
		local primary_part_reference = accessory.PrimaryPart
		local character_reference = character:FindFirstChild(primary_part_reference.Name)

		if not primary_part_reference then
			warn("Accessory has no PrimaryPart:", accessory.Name)
			return
		end


		if not character_reference then
			warn("Accessory's PrimaryPart not found in character:", primary_part_reference)
			return
		end



		accessory.Parent = accessory_folder

		if accessory:GetAttribute("HideHair") then
			for _, hair in character:GetChildren() do
				if hair:IsA("Accessory") then
					hair.Handle.Transparency = 1
				end
			end
		end


		Util.quick_weld(character_reference, primary_part_reference, character_reference, "AccessoryWeld")
	end
	
	
	local string_value = Instance.new("StringValue")
	string_value.Parent = accessory_folder
	string_value.Name = accessory.Name
end

return Util