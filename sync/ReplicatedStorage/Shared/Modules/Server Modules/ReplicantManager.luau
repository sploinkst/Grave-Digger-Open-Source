local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local player_service = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local replicant_folder = ReplicatedStorage.Shared.Library.Events

local fastcast_replicant = replicant_folder.FastCast
local vfx_replicant = replicant_folder.VFX
local sfx_replicant = replicant_folder.Sounds
local texture_replicant = replicant_folder.Texture
local hit_connection = replicant_folder.Hit
local heal_connection = replicant_folder.Heal
local healnotify_connection = replicant_folder.HealNotify

local status_connection = replicant_folder.Status

local ammo_connection = replicant_folder.Ammo
local drop_connection = replicant_folder.DropWeapon

local melee_connection = replicant_folder.Melee
local casing_connection = replicant_folder.Casing

local InputChange = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("InputChange")
local SettingChange = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("SettingChange")

local GiveCompassEvent:RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("GiveCompass")
local RemoveCompass:RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("RemoveCompass")

local status_service = require(script.Parent.StatusService)

local item_service = require(script.Parent.ItemsService)

local stumble_animation = ReplicatedStorage:WaitForChild("Shared").Assets.Animations.Character.Miscellanous.Stumble

local AmmoPackEvent = replicant_folder:WaitForChild("AmmoPack")
local AmmoPack = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Equipment"):WaitForChild("AmmoPack")
local AmmoPouchSounds = ReplicatedStorage.Shared.Assets.Equipment.Sounds:FindFirstChild("ammopouch")
local WhistleSounds = ReplicatedStorage.Shared.Assets.Equipment.Sounds:FindFirstChild("whistle")
local EquipmentAssets = ReplicatedStorage.Shared.Assets:FindFirstChild("Equipment")
local WhistleOrderEvent = replicant_folder:FindFirstChild("WhistleOrder") :: RemoteEvent?
if not WhistleOrderEvent then
	WhistleOrderEvent = Instance.new("RemoteEvent")
	WhistleOrderEvent.Name = "WhistleOrder"
	WhistleOrderEvent.Parent = replicant_folder
end
local WhistleEquipEvent = replicant_folder:FindFirstChild("WhistleEquip") :: RemoteEvent?
if not WhistleEquipEvent then
	WhistleEquipEvent = Instance.new("RemoteEvent")
	WhistleEquipEvent.Name = "WhistleEquip"
	WhistleEquipEvent.Parent = replicant_folder
end
local Helmet_RemoteEvent        = ReplicatedStorage.Shared.Library.Events.Helmet
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local hellionHelmetHits = {}
-- Replace this asset when the final helmet-pop sound is uploaded.  The shooter
-- is recorded now so the client-only sound can be played for them later.
local HELMET_POP_SOUND_ID = "rbxassetid://0"
local jesseGrenadeEvent=replicant_folder:FindFirstChild("JesseGrenade")::RemoteEvent?
if not jesseGrenadeEvent then jesseGrenadeEvent=Instance.new("RemoteEvent"); jesseGrenadeEvent.Name="JesseGrenade"; jesseGrenadeEvent.Parent=replicant_folder end
local dualWieldEvent = replicant_folder:FindFirstChild("DualWield") :: RemoteEvent?
if not dualWieldEvent then
	dualWieldEvent = Instance.new("RemoteEvent")
	dualWieldEvent.Name = "DualWield"
	dualWieldEvent.Parent = replicant_folder
end

-- // funcs

local function getModelFromInstance(instance: Instance)
	if not instance then return nil end
	if instance:IsA("Model") then
		return instance
	end
	return instance:FindFirstAncestorOfClass("Model")
end

local function getHumanoid(model: Model)
	if not model then return nil end
	return model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildWhichIsA("Humanoid", true)
end

local function applyKnockback(part: BasePart, forceDir: Vector3, force: number)
	if part.Anchored then return end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(forceDir.X * force, 2, forceDir.Z * force)
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.P = 800
	bodyVelocity.Parent = part

	Debris:AddItem(bodyVelocity, 0.1)
end

local function getDistanceScaledForce(baseForce: number, distance: number)
	local MIN_FORCE = 10
	local FULL_FORCE_DISTANCE = 50
	local MIN_FORCE_DISTANCE = 150

	if distance <= FULL_FORCE_DISTANCE then
		return baseForce
	end

	if distance >= MIN_FORCE_DISTANCE then
		return MIN_FORCE
	end

	local alpha = (distance - FULL_FORCE_DISTANCE) / (MIN_FORCE_DISTANCE - FULL_FORCE_DISTANCE)
	local scaled = baseForce + (MIN_FORCE - baseForce) * alpha

	return math.max(scaled, MIN_FORCE)
end



function module.stumble_player(character)
	character.Humanoid.WalkSpeed = 0
	
	local loaded_animation = character:FindFirstChildOfClass("Humanoid"):LoadAnimation(stumble_animation)
	loaded_animation:Play()
	
	loaded_animation.Stopped:Connect(function()
		character.Humanoid.WalkSpeed = 10
	end)
end

function module.pop_helmet(character, helmet_model, knockable: boolean, shooter: Player?)
	print("[POP_HELMET] Attempting to pop helmet for character:", character.Name, helmet_model.Name, knockable)

	if knockable then
		if shooter then shooter:SetAttribute("LastHelmetPopSound", HELMET_POP_SOUND_ID) end
		print("[POP_HELMET] Helmet is knockable.")
		local head_part = helmet_model:FindFirstChild("Head")
		-- Outfit helmets mount directly to the character Head through an
		-- AccessoryWeld and do not contain a duplicate part named Head.
		local classWeld = character:FindFirstChild("Head") and character.Head:FindFirstChild("AccessoryWeld")
		local isMountedClassHelmet = classWeld and classWeld.Part1 and (
			classWeld.Part1 == helmet_model or classWeld.Part1:IsDescendantOf(helmet_model)
		)
		if not head_part and isMountedClassHelmet then
			classWeld:Destroy()
			helmet_model:PivotTo(CFrame.new(character.Head.Position))
			helmet_model.Parent = workspace.Game_Details.Debris
			helmet_model:SetAttribute("Knocked", true)
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					local original = part:GetAttribute("ClassHairTransparency")
					if type(original) == "number" then part.Transparency = original; part:SetAttribute("ClassHairTransparency", nil) end
				end
			end
			return
		end
		if not head_part then warn("Helmet head part missing"); return end

		for _, child in helmet_model:GetChildren() do
			if not child:GetAttribute("Knock") then
				continue
			end

			if not child:IsA("BasePart") then
				continue
			end

			print(child.Name, "is marked to be knocked...")

			local reference_weld = head_part:FindFirstChild(child.Name)

			if not reference_weld then
				print("No reference weld found for:", child.Name)
				continue
			end

			reference_weld:Destroy()

			print("Weld destroyed for:", child.Name)

			child.CanCollide = true
			child.Anchored = false

			-- Randomized pop direction
			local randomDirection = Vector3.new(
				math.random(-100, 100) / 100,
				1,
				math.random(-100, 100) / 100
			).Unit

			-- Apply instant velocity
			local velocity = Instance.new("LinearVelocity")
			velocity.Attachment0 = child:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", child)
			velocity.MaxForce = math.huge
			velocity.VectorVelocity = randomDirection * 15
			velocity.RelativeTo = Enum.ActuatorRelativeTo.World
			velocity.Parent = child

			-- Add some spin
			child.AssemblyAngularVelocity = Vector3.new(
				math.random(-20, 20),
				math.random(-20, 20),
				math.random(-20, 20)
			)

			-- Remove velocity object shortly after
			Debris:AddItem(velocity, 0.15)
			
			child.Parent = workspace.Game_Details.Debris
		end
		
		helmet_model:SetAttribute("Knocked", true)
		-- ClassAppearance hides hair only while the helmet is actually worn.
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				local original = part:GetAttribute("ClassHairTransparency")
				if type(original) == "number" then
					part.Transparency = original
					part:SetAttribute("ClassHairTransparency", nil)
				end
			end
		end
	else
		print("[POP_HELMET] Helmet is unknockable.")
		-- // force stumble character
		module.stumble_player(character)
	end
end

local function tweenLid(lidRotate: Motor6D, angle: number)
	local currentC0 = lidRotate.C0

	local targetC0 = CFrame.new(currentC0.Position) * CFrame.fromOrientation(
		0,
		0,
		math.rad(angle)
	)

	local tween = TweenService:Create(
		lidRotate,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		),
		{
			C0 = targetC0
		}
	)

	tween:Play()
	return tween
end

local function getCompassData(player, arm)
	local character = player.Character
	if not character then
		return
	end

	local armPart = character:FindFirstChild(arm)
	if not armPart then
		return
	end

	local compass = if player.Team and player.Team.Name == "Golden Empire"
		then ReplicatedStorage.Shared.Assets.Items.empirecompass
		else ReplicatedStorage.Shared.Assets.Items.nationcompass

	return armPart, compass
end

function module.start_module()
	-- A call is evaluated server-side every quarter second.  This keeps range,
	-- team checks, death, and players walking out of the radius authoritative.
	type OfficerCall = {order: string, expiresAt: number, character: Model, team: Team?}
	local officerCalls: {[Player]: {OfficerCall}} = {}
	local lastWhistleRequest = {}
	player_service.PlayerRemoving:Connect(function(player)
		officerCalls[player] = nil
		lastWhistleRequest[player] = nil
	end)
	local rareCooldownMessages = {
		"I'm just yapping right now.", "Who asked?", "Why is everyone so mean to me <.",
		"I'm being ignored, this is un-acceptable.", "Why is no one listening to me?",
	}
	local callMultipliers = {
		Advance = { speed = 1.15, reload = 1, fireRate = 1, focus = 1, recoil = 1 },
		Defend = { speed = 1, reload = 1.15, fireRate = 1.15, focus = 1, recoil = 1 },
		Focus = { speed = 1, reload = 1, fireRate = 1, focus = 1.15, recoil = 0.8 },
	}
	WhistleEquipEvent.OnServerEvent:Connect(function(player, equipped)
		if type(equipped) ~= "boolean" then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if character and humanoid and humanoid.Health > 0
			and character:GetAttribute("Class") == "Officer"
			and character:GetAttribute("Equipment") == "TrenchWhistle" then
			local existingTool = character:FindFirstChild("TrenchWhistleTool")
			if not equipped then
				character:SetAttribute("WhistleEquipped", nil)
				if existingTool then existingTool:Destroy() end
				local backpackTool = player:FindFirstChildOfClass("Backpack")
					and player.Backpack:FindFirstChild("TrenchWhistleTool")
				if backpackTool then backpackTool:Destroy() end
				return
			end
			if existingTool then return end
			local source = EquipmentAssets and (EquipmentAssets:FindFirstChild("whistle") or EquipmentAssets:FindFirstChild("Whistle"))
			if not source then warn("[TrenchWhistle] Missing Assets.Equipment.whistle"); return end
			local tool = Instance.new("Tool")
			tool.Name = "TrenchWhistleTool"
			tool.CanBeDropped = false
			tool.RequiresHandle = true
			local model = source:Clone()
			model.Parent = tool
			local handle = if model:IsA("BasePart") then model
				else model:FindFirstChild("hitbox", true) or model:FindFirstChild("Handle", true) or model:FindFirstChildWhichIsA("BasePart", true)
			if not handle or not handle:IsA("BasePart") then tool:Destroy(); warn("[TrenchWhistle] whistle needs a BasePart handle"); return end
			handle.Name = "Handle"
			handle.Parent = tool
			for _, part in tool:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = false
					part.CanCollide = false
					part.CanTouch = false
					part.Massless = true
					if part ~= handle then
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = handle; weld.Part1 = part; weld.Parent = handle
					end
				end
			end
			tool.Grip = CFrame.new(0, -.8, -.2) * CFrame.Angles(math.rad(90), 0, math.rad(90))
			-- This is a hidden hotbar Tool.  Unequip on the server first so every
			-- gun/melee item is removed from the hands before the whistle equips.
			local backpack = player:WaitForChild("Backpack")
			for _, heldTool in ipairs(character:GetChildren()) do
				if heldTool:IsA("Tool") then heldTool.Parent = backpack end
			end
			humanoid:UnequipTools()
			-- Follow the normal Backpack -> EquipTool pipeline. ToolService leaves
			-- this internal item to EquipmentClasses, so it never appears as a slot.
			tool.Parent = backpack
			character:SetAttribute("WhistleEquipped", true)
			humanoid:EquipTool(tool)
			local activeCalls = officerCalls[player] or {}
			WhistleOrderEvent:FireClient(player, "State",
				math.max(0, (character:GetAttribute("OfficerOrderCapacity") or 1) - #activeCalls))
			-- Switching back to a weapon holsters and removes the temporary whistle.
			tool.Unequipped:Connect(function()
				task.defer(function()
					if tool.Parent and tool.Parent ~= character then
						character:SetAttribute("WhistleEquipped", nil)
						tool:Destroy()
					end
				end)
			end)
		end
	end)

	WhistleOrderEvent.OnServerEvent:Connect(function(player, order, duration)
		if type(order) ~= "string" or not callMultipliers[order]
			or (duration ~= 30 and duration ~= 60) then return end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not humanoid or humanoid.Health <= 0 or not root
			or character:GetAttribute("Class") ~= "Officer"
			or character:GetAttribute("WhistleEquipped") ~= true
			or not character:FindFirstChild("TrenchWhistleTool") then return end
		local now = os.clock()
		if now - (lastWhistleRequest[player] or -math.huge) < .3 then return end
		lastWhistleRequest[player] = now
		local calls = officerCalls[player] or {}
		for index = #calls, 1, -1 do
			if calls[index].expiresAt <= now or calls[index].character ~= character then table.remove(calls, index) end
		end
		local capacity = math.clamp(character:GetAttribute("OfficerOrderCapacity") or 1, 1, 2)
		for _, call in calls do
			if call.order == order then
				local message = "That order is already active."
				if math.random(1, 20) == 1 then
					message = rareCooldownMessages[math.random(1, #rareCooldownMessages)]
				end
				WhistleOrderEvent:FireClient(player, "Rejected", message)
				return
			end
		end
		if #calls >= capacity then
			local message = "Your active order must expire before issuing another."
			if math.random(1, 20) == 1 then
				message = rareCooldownMessages[math.random(1, #rareCooldownMessages)]
			end
			WhistleOrderEvent:FireClient(player, "Rejected", message)
			return
		end
		table.insert(calls, { order = order, expiresAt = now + duration, character = character, team = player.Team })
		officerCalls[player] = calls
		character:SetAttribute("OfficerOrderCharges", capacity - #calls)
		WhistleOrderEvent:FireClient(player, "Accepted", capacity - #calls, order)
		task.delay(duration, function()
			if not player.Parent or player.Character ~= character then return end
			local current = officerCalls[player]
			if not current then return end
			for index = #current, 1, -1 do
				if current[index].expiresAt <= os.clock() then table.remove(current, index) end
			end
			WhistleOrderEvent:FireClient(player, "State", capacity - #current)
		end)

		local sound = WhistleSounds and WhistleSounds:FindFirstChild("whistle_" .. string.lower(order))
		if sound and sound:IsA("Sound") then
			local clone = sound:Clone()
			clone.PlaybackSpeed = 1.15
			clone.Volume *= 5
			clone.Parent = root
			clone:Play()
			Debris:AddItem(clone, math.max(clone.TimeLength + 0.25, 2))
		end
	end)

	local auraElapsed = 0
	RunService.Heartbeat:Connect(function(deltaTime)
		auraElapsed += deltaTime
		if auraElapsed < 0.25 then return end
		auraElapsed = 0
		local now = os.clock()
		-- Prune independently of recipients, including when everybody is dead.
		for officer, calls in officerCalls do
			local character = officer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			for index = #calls, 1, -1 do
				local call = calls[index]
				if call.expiresAt <= now or call.character ~= character or call.team ~= officer.Team
					or not humanoid or humanoid.Health <= 0 or character:GetAttribute("Class") ~= "Officer" then
					table.remove(calls, index)
				end
			end
			if #calls == 0 then officerCalls[officer] = nil end
		end
		for _, player in player_service:GetPlayers() do
			local character = player.Character
			if character then
				character:SetAttribute("OfficerOrderCharges", math.max(0,
					(character:GetAttribute("OfficerOrderCapacity") or 1) - #(officerCalls[player] or {})))
			end
		end
		for _, recipient in player_service:GetPlayers() do
			local character = recipient.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character and root and humanoid then
				local speed, reload, fireRate, focus, recoil = 1, 1, 1, 1, 1
				local applied = {}
				for officer, calls in pairs(officerCalls) do
					local officerCharacter = officer.Character
					local officerRoot = officerCharacter and officerCharacter:FindFirstChild("HumanoidRootPart")
					local officerHumanoid = officerCharacter and officerCharacter:FindFirstChildOfClass("Humanoid")
					for index = #calls, 1, -1 do
						if calls[index].expiresAt <= now then table.remove(calls, index) end
					end
					if not officerRoot or not officerHumanoid or officerHumanoid.Health <= 0 then
						officerCalls[officer] = nil
					elseif #calls == 0 then
						officerCalls[officer] = nil
					elseif humanoid.Health > 0 and (officer == recipient or (officer.Team ~= nil and officer.Team == recipient.Team))
						and (officerRoot.Position - root.Position).Magnitude <= 80 then
						for _, call in calls do
							if not applied[call.order] then
								-- Same-name orders from several Officers never stack.
								applied[call.order] = true
								local bonus = callMultipliers[call.order]
								speed *= bonus.speed; reload *= bonus.reload; fireRate *= bonus.fireRate
								focus *= bonus.focus; recoil *= bonus.recoil
							end
						end
					end
				end
				character:SetAttribute("OrderSpeedMultiplier", speed)
				character:SetAttribute("OrderReloadMultiplier", reload)
				character:SetAttribute("OrderFireRateMultiplier", fireRate)
				character:SetAttribute("OrderFocusMultiplier", focus)
				character:SetAttribute("OrderRecoilMultiplier", recoil)
			end
		end
	end)
	jesseGrenadeEvent.OnServerEvent:Connect(function(player,origin,direction)
		if typeof(origin)~="Vector3" or typeof(direction)~="Vector3" or direction.Magnitude<.9 then return end
		local character=player.Character; local root=character and character:FindFirstChild("HumanoidRootPart")
		local tool=character and character:FindFirstChild("JesseRifle"); local grenades=tool and tool:FindFirstChild("Grenades")
		if not root or not grenades or not grenades:IsA("NumberValue") or grenades.Value<=0 or (root.Position-origin).Magnitude>15 then return end
		grenades.Value-=1; local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={character}
		local result=workspace:Raycast(origin,direction.Unit*1000,params); local position=result and result.Position or origin+direction.Unit*1000
		local distance=(position-origin).Magnitude
		task.delay(distance/180,function()
			if distance<30 then local model=result and getModelFromInstance(result.Instance); local humanoid=model and getHumanoid(model); if humanoid then humanoid:TakeDamage(199) end; return end
			for _,target in player_service:GetPlayers() do
				if target~=player and target.Team~=player.Team then
					local c=target.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local r=c and c:FindFirstChild("HumanoidRootPart")
					if h and r and h.Health>0 and (r.Position-position).Magnitude<=18 then
						h:TakeDamage(99*(c:GetAttribute("ExplosiveDamageMultiplier") or 1))
						if result and result.Instance:IsDescendantOf(c) then h:TakeDamage(5); status_service.GiveStatus(target,"RagdollStatus",direction); task.delay(2,function() if target.Parent then status_service.RemoveStatus(target,"RagdollStatus") end end) end
					end
				end
			end
		end)
	end)

	fastcast_replicant.OnServerEvent:Connect(function(...)
		fastcast_replicant:FireAllClients(...)
	end)

	vfx_replicant.OnServerEvent:Connect(function(...)
		vfx_replicant:FireAllClients(...)
	end)

	sfx_replicant.OnServerEvent:Connect(function(player, ...)
		local rawArgs = {...}

		-- Flatten once if the first argument is a table (prevents nested payload bug)
		if typeof(rawArgs[1]) == "table" then
			rawArgs = rawArgs[1]
		end

		-- Repack with player at index [1]
		table.insert(rawArgs, 1, player)


		sfx_replicant:FireAllClients(table.unpack(rawArgs))
	end)
	
	casing_connection.OnServerEvent:Connect(function(...)
		casing_connection:FireAllClients(...)
		print("Casing server-replicated.")
	end)

	texture_replicant.OnServerEvent:Connect(function(...)
		texture_replicant:FireAllClients(...)
	end)

	hit_connection.OnServerEvent:Connect(function(player, hitData, damage: number, knockback_force: number)
		if not hitData then return end

		local instance: BasePart = hitData.Instance
		local position: Vector3  = hitData.Position
		local direction: Vector3 = hitData.Direction

		if not instance or not instance:IsDescendantOf(workspace) then return end
		if not direction then return end

		local character = player.Character
		if not character then return end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local model    = getModelFromInstance(instance)
		local humanoid = getHumanoid(model)

		if not humanoid or humanoid.Health <= 0 then return end

		local hitCharacter = model
		local hitPlayer    = game.Players:GetPlayerFromCharacter(hitCharacter)
		local weaponName = hitData.WeaponName
		local isJudgement = weaponName == "JudgementRifle"
			and character:FindFirstChild("JudgementRifle") ~= nil
		local isAMR = weaponName == "AntiMaterialRifle"
			and character:FindFirstChild("AntiMaterialRifle") ~= nil
		local isHellion = weaponName == "HellionShotgun"
			and character:FindFirstChild("HellionShotgun") ~= nil
		local isUnion = weaponName == "UnionPistol"
			and character:FindFirstChild("UnionPistol") ~= nil

		-- Prevent self-damage
		if hitPlayer and player.Team == hitPlayer.Team then return end
		if hitPlayer and hitPlayer == player then return end

		if hitPlayer then
			hitPlayer:SetAttribute("LastTagged", player.Name)
			require(script.Parent.ClassService).RecordHit(player, hitPlayer, weaponName)
		end
		
		-- Knockback
		local forceDirection = (direction.Unit + Vector3.new(0, 0.1, 0)).Unit
		local baseForce      = knockback_force or 5
		local distance       = (hrp.Position - position).Magnitude
		local finalForce     = getDistanceScaledForce(baseForce, distance)
		if isJudgement and (model:GetAttribute("Construct") == true or model:GetAttribute("IsConstruct") == true) then
			damage = (damage or 0) * 3
		end

		local knockbackTarget = if instance:IsA("BasePart")
			then instance
			else model and model.PrimaryPart

		if knockbackTarget then
			applyKnockback(knockbackTarget, forceDirection, finalForce)
		end

		-- Headshot / helmet logic
		local isHeadshot = (instance.Name == "Head") or
			(instance.Parent and instance.Parent.Name == "Hitboxes" and instance.Name == "Head")

		if isHeadshot then
			local helmet, knockable = Util.check_for_helmet(hitCharacter)
			-- A helmet absorbs only its first non-penetrating headshot. It may remain
			-- visibly attached, but no longer protects a second hit.
			if helmet and helmet:GetAttribute("HelmetSpent") then helmet = nil end

			if helmet then
				-- AMR defeats every helmet at every distance. Judgement does the same
				-- inside its close-range penetration band.
				if isAMR then
					if not helmet:GetAttribute("Knocked") then module.pop_helmet(hitCharacter, helmet, true, player) end
					humanoid:TakeDamage(humanoid.MaxHealth)
					return
				end
				-- Union's weak 9mm knocks ordinary helmets only at point-blank range.
				-- At 30 studs and beyond, the helmet deflects the shot untouched.
				if isUnion then
					if distance < 30 and knockable and not helmet:GetAttribute("Knocked") then
						module.pop_helmet(hitCharacter, helmet, true, player)
					end
					return
				end
				local hellionCannotPenetrate = isHellion and (not knockable or distance > 35)
				if hellionCannotPenetrate and type(hitData.ShotId) == "string" then
					local shotKey = tostring(player.UserId) .. ":" .. hitData.ShotId .. ":" .. tostring(hitCharacter)
					local pelletHits = (hellionHelmetHits[shotKey] or 0) + 1
					hellionHelmetHits[shotKey] = pelletHits
					if pelletHits == 1 then
						task.delay(2, function() hellionHelmetHits[shotKey] = nil end)
					end
					if pelletHits >= 4 then
						hellionHelmetHits[shotKey] = nil
						-- Four close pellets strip a resistant Shock Trooper helmet. At
						-- long range ordinary helmets deflect the pattern and stay on.
						if not knockable and distance <= 35 and not helmet:GetAttribute("Knocked") then
							module.pop_helmet(hitCharacter, helmet, true, player)
						end
						humanoid:TakeDamage(100)
						if hitPlayer then
							status_service.GiveStatus(hitPlayer, "RagdollStatus", direction)
							task.delay(2, function()
								if hitPlayer.Parent then status_service.RemoveStatus(hitPlayer, "RagdollStatus") end
							end)
						end
					end
					return
				end

				-- Judgement's .577 Alloy round punches through any helmet inside 60 studs.
				if isJudgement and distance < 60 then
					if not helmet:GetAttribute("Knocked") then module.pop_helmet(hitCharacter, helmet, true, player) end
					humanoid:TakeDamage(humanoid.MaxHealth)
					player:SetAttribute("RoundKills", (player:GetAttribute("RoundKills") or 0) + 1)
					return
				end

				-- Standard rounds are absorbed once. Close/high-energy hits are more
				-- likely to knock it off, while a distant shot can leave it visibly on.
				helmet:SetAttribute("HelmetSpent", true)
				local popChance = math.clamp(0.8 - (distance / 250), 0.2, 0.8)
				if knockable and not helmet:GetAttribute("Knocked") and math.random() < popChance then
					module.pop_helmet(hitCharacter, helmet, true, player)
				end

				if hitPlayer then
					status_service.GiveStatus(hitPlayer, "ConcussionStatus")
					task.delay(3, function()
						if hitPlayer.Character and
							hitPlayer.Character:FindFirstChildOfClass("Humanoid") and
							hitPlayer.Character.Humanoid.Health >= 100 then
							status_service.RemoveStatus(hitPlayer, "ConcussionStatus")
						end
					end)
				end
				return
			elseif isHellion then
				humanoid:TakeDamage((damage or 0) * 1.2)
				if humanoid.Health <= 0 then
					player:SetAttribute("RoundKills", (player:GetAttribute("RoundKills") or 0) + 1)
				end
				return
			else
				humanoid.Health = 0
				player:SetAttribute("RoundKills", player:GetAttribute("RoundKills") + 1)
				return
			end
		end

		-- Normal damage
		humanoid:TakeDamage(damage or 0)
		
		if humanoid.Health < 100 and hitPlayer then
			status_service.GiveStatus(hitPlayer, "WoundStatus", nil, instance.Name)
			status_service.GiveStatus(hitPlayer, "ConcussionStatus")
		end
		
		if humanoid.Health <= 0 then
			player:SetAttribute("RoundKills", player:GetAttribute("RoundKills") + 1)
		end
	end)
	
	heal_connection.OnServerEvent:Connect(function(sender, healed, wound)
		if typeof(healed) ~= "Instance" then return end
		if not healed:IsA("Player") then healed = player_service:GetPlayerFromCharacter(healed) end
		if not healed or not sender.Team or sender.Team ~= healed.Team then return end
		local character, target = sender.Character, healed.Character
		local medic = character and character:FindFirstChildOfClass("Humanoid")
		local humanoid = target and target:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
		if not medic or medic.Health <= 0 or not humanoid or humanoid.Health <= 0
			or not root or not targetRoot or not character:FindFirstChild("Medkit")
			or (root.Position - targetRoot.Position).Magnitude > 12 then return end
		status_service.RemoveStatus(healed, "WoundStatus")
		status_service.RemoveStatus(healed, "ConcussionStatus")
		local health = if sender ~= healed then character:GetAttribute("AllyHealHealth") or 100 else 100
		humanoid.Health = math.max(humanoid.Health, math.min(humanoid.MaxHealth, health))
	end)

	healnotify_connection.OnServerEvent:Connect(function(healer, healee:Player)
		print("Received healnotify_connection from", healer.Name, "for healee:", healee.Name)
		local notify_ui = require(healee.PlayerGui.Notifications.Utils)
		
		notify_ui.send_notification(healee, healer.Name .. ": Stand still while I heal you.")
	end)
	
	status_connection.OnServerEvent:Connect(function(player, status, enabled: boolean)
		if enabled then
			status_service.GiveStatus(player, status)
		else
			status_service.RemoveStatus(player, status)
		end
	end)

	drop_connection.OnServerEvent:Connect(function(player, tool, model, remove_tool: boolean)
		if not player or type(tool) ~= "string" or not model or not model:IsA("Model") then
			warn("[ReplicantManager::] Invalid player or model in drop_connection")
			return
		end
		print("Received drop_connection from", player.Name, "for tool:", tool, "model:", model.Name, "remove_tool:", remove_tool)
		
		if remove_tool == true then
			item_service.remove_item(player, tool, model.Name)
			print("Removed tool from player:", player.Name)
		end
		
		local model_clone = model:Clone()
		model_clone.Parent = workspace
		
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

		if root and model_clone.PrimaryPart then
			-- Move the clone slightly in front of the player
			local spawnOffset = root.CFrame.LookVector * 3 -- distance in studs
			local spawnCFrame = root.CFrame + spawnOffset

			model_clone:PivotTo(spawnCFrame)

			model_clone.PrimaryPart.CanCollide = true

			local forward = root.CFrame.LookVector
			local upward = root.CFrame.UpVector

			local force = (forward * 10) + (upward * 5)

			local velocity = Instance.new("BodyVelocity")
			velocity.Velocity = force
			velocity.MaxForce = Vector3.new(100, 100, 100)
			velocity.Parent = model_clone.PrimaryPart

			task.delay(0.1, function()
				velocity:Destroy()
			end)
		end
	end)
	
	melee_connection.OnServerEvent:Connect(function(player, targetCharacter, meleeRange, damage, weaponName)
		print("Received melee_connection from", player.Name, "target:", targetCharacter.Name, "range:", meleeRange, "damage:", damage)
		
		if player.Name == targetCharacter.Name then
			return
		end

		local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
		if targetPlayer and targetPlayer.Team == player.Team then
			return
		end
		
		if (player.Character.HumanoidRootPart.Position - targetCharacter.HumanoidRootPart.Position).Magnitude > meleeRange * 1.5 then
			return
		end
		
		local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
		local attackerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local isCavalrySword = weaponName == "CavalrySword"
			and player.Character and player.Character:FindFirstChild("CavalrySword") ~= nil
		local fromBehind = false
		if isCavalrySword and targetRoot and attackerRoot then
			fromBehind = targetRoot.CFrame.LookVector:Dot((attackerRoot.Position - targetRoot.Position).Unit) < -0.5
		end

		local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local healthBefore = humanoid.Health
		local appliedDamage = if isCavalrySword then math.min(120, damage or 0) else (damage or 0)
		-- Instant kills retain their behavior; normal melee receives class armor.
		if not fromBehind and appliedDamage < humanoid.MaxHealth then
			appliedDamage *= targetCharacter:GetAttribute("MeleeDamageMultiplier") or 1
		end
		humanoid:TakeDamage(fromBehind and humanoid.MaxHealth or appliedDamage)
		if isCavalrySword and healthBefore > 0 and humanoid.Health <= 0 then
			local factionName = targetPlayer and targetPlayer.Team and targetPlayer.Team.Name or "Unknown"
			local dogtagName = string.find(string.lower(factionName), "empire", 1, true) and "Empire" or "Nation"
			local data = player:FindFirstChild("PlayerData")
			local playerData = data and data:FindFirstChild("PlayerData")
			local dogtags = playerData and playerData:FindFirstChild("Dogtags")
			local counter = dogtags and dogtags:FindFirstChild(dogtagName)
			if counter and counter:IsA("NumberValue") then counter.Value += 1 end
			player:SetAttribute(dogtagName .. "Dogtags", (player:GetAttribute(dogtagName .. "Dogtags") or 0) + 1)
		end
		print("Applied damage to", targetCharacter.Name)
	end)

	dualWieldEvent.OnServerEvent:Connect(function(player, enabled, handgunName)
		local character = player.Character
		if not character then return end
		local existing = character:FindFirstChild("DualWieldModel")
		if existing then existing:Destroy() end
		local oldMotor = character:FindFirstChild("DualWieldMotor", true)
		if oldMotor then oldMotor:Destroy() end
		if enabled ~= true or type(handgunName) ~= "string" then return end
		local backpack = player:FindFirstChild("Backpack")
		if not character:FindFirstChild("CavalrySword") and not (backpack and backpack:FindFirstChild("CavalrySword")) then return end
		local handgunTool = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(handgunName)
		if not handgunTool then return end

		local classScript = ReplicatedStorage.Shared.Library.Classes.GunClasses:FindFirstChild(handgunName)
		if not classScript or not classScript:IsA("ModuleScript") then return end
		local ok, handgunClass = pcall(require, classScript)
		if not ok then return end
		local handgun = handgunClass.new({ name = handgunName })
		if handgun.WeaponCategory ~= "Pistol" or not handgun.model_reference then return end

		local model = handgun.model_reference:Clone()
		model.Name = "DualWieldModel"
		model.Parent = character.CharacterData.Equipment
		model:PivotTo(character:GetPivot())
		local leftArm = character:FindFirstChild("Left Arm")
		local sourcePart = handgun.motor_6d_data and handgun.motor_6d_data.Part1
		local partName = sourcePart and sourcePart.Name
		local part1 = partName and model:FindFirstChild(partName, true)
		if not leftArm or not leftArm:IsA("BasePart") or not part1 or not part1:IsA("BasePart") then
			model:Destroy()
			return
		end
		local motor = Instance.new("Motor6D")
		motor.Name = "DualWieldMotor"
		motor.Part0 = leftArm
		motor.Part1 = part1
		motor.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.rad(-90), math.rad(90))
		motor.C1 = handgun.motor_6d_data.C1 or CFrame.identity
		motor.Parent = leftArm
		model:SetAttribute("WeaponClass", handgunName)
	end)
	
	ammo_connection.OnServerEvent:Connect(function(player, tool, count)
		print("Received ammo_connection from", tool.Name, "count:", count)
		tool.Reserve_Ammo.Value -= count
	end)
	
	local ammoCharges = setmetatable({}, {__mode = "k"})
	AmmoPackEvent.OnServerEvent:Connect(function(player, target)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not humanoid or humanoid.Health <= 0 or not player.Team
			or character:GetAttribute("Class") ~= "Soldat" or character:GetAttribute("Equipment") ~= "AmmoPack" then return end
		local recipient
		if target ~= nil then
			if typeof(target) ~= "Instance" or not target:IsA("Model") then return end
			recipient = player_service:GetPlayerFromCharacter(target)
			local targetRoot = target:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
			if not recipient or recipient.Team ~= player.Team or not targetRoot
				or not targetHumanoid or targetHumanoid.Health <= 0
				or (root.Position - targetRoot.Position).Magnitude > 30 or Util.hasfullammo(recipient) then return end
		end
		local now = os.clock()
		local state = ammoCharges[character]
		if not state then state = {count = 2, time = now}; ammoCharges[character] = state end
		local restored = math.floor((now - state.time) / 30)
		if restored > 0 then state.count = math.min(2, state.count + restored); state.time += restored * 30 end
		if state.count <= 0 then return end
		if state.count == 2 then state.time = now end
		state.count -= 1
		if recipient then Util.setammo(recipient); return end
		-- Untargeted pouch can be collected by its owner or any living ally.
		local clone = AmmoPack:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 0, -4)
		clone.Anchored = false; clone.CanCollide = true; clone.CanTouch = true
		clone.Parent = workspace
		clone.AssemblyLinearVelocity = root.CFrame.LookVector * 20 + Vector3.new(0, 8, 0)
		-- Soldat's thrown pouch gets one of the authored ammo-pouch throw sounds.
		local choices = {}
		if AmmoPouchSounds then
			for _, sound in AmmoPouchSounds:GetChildren() do
				if sound:IsA("Sound") then table.insert(choices, sound) end
			end
		end
		if #choices > 0 then
			local sound = choices[math.random(1, #choices)]:Clone()
			sound.Parent = clone
			sound:Play()
			Debris:AddItem(sound, math.max(sound.TimeLength + 0.25, 2))
		else
			warn("[AmmoPack] Missing Assets.Equipment.Sounds.ammopouch ammo1/ammo2/ammo3")
		end
		local consumed = false
		local team = player.Team
		clone.Touched:Connect(function(hit)
			if consumed then return end
			local targetCharacter = hit:FindFirstAncestorOfClass("Model")
			local ally = targetCharacter and player_service:GetPlayerFromCharacter(targetCharacter)
			local health = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
			if not ally or ally.Team ~= team or not health or health.Health <= 0 or Util.hasfullammo(ally) then return end
			consumed = true
			Util.setammo(ally)
			clone:Destroy()
		end)
		Debris:AddItem(clone, 30)
	end)

	GiveCompassEvent.OnServerEvent:Connect(function(player, arm)
		print("Received CompassEvent")
		
		local armPart, compass = getCompassData(player, arm)
		if not armPart then
			return
		end

		local existing = player.Character:FindFirstChild(compass.Name, true)
		if existing then
			existing:Destroy()
		end
		
		local clone = compass:Clone()
		clone.Parent = armPart
		clone:PivotTo(armPart.CFrame)

		local weld = Util.quick_weld(
			armPart,
			clone.base,
			clone,
			"Weld"
		)

		if arm == "Right Arm" then
			weld.C0 =
				CFrame.new(-0.6, -0.5, 0)
				* CFrame.fromOrientation(math.rad(180), 0, math.rad(90))
		else
			weld.C0 =
				CFrame.new(0.6, -0.5, 0)
				* CFrame.fromOrientation(0, 0, math.rad(-90))
		end

		local lidRotate = clone.base:FindFirstChild("lid_rotate")
		if lidRotate then
			task.delay(0.3, function()
				tweenLid(lidRotate, -90)
			end)
		end
	end)

	RemoveCompass.OnServerEvent:Connect(function(player, arm)
		local armPart, compass = getCompassData(player, arm)
		if not armPart then
			return
		end

		local existingCompass = armPart:FindFirstChild(compass.Name)
		if not existingCompass then
			return
		end

		print("Destroying Existing Compass")

		local lidRotate = existingCompass.base:FindFirstChild("lid_rotate")
		if lidRotate then
			local tween = tweenLid(lidRotate, 0)
			tween.Completed:Wait()
		end

		existingCompass:Destroy()
	end)
	
	Helmet_RemoteEvent.OnServerEvent:Connect(function(player, lift: boolean)
		local character = player.Character
		local helmet, _ = Util.check_for_helmet(character)
		
		if helmet then
			print("Removing Helmet")
			
			if lift then
				local HelmetWeld = helmet.Head:FindFirstChild("Helmet")
				local tween = TweenService:Create(HelmetWeld, TweenInfo.new(0.5), {C0 = helmet.Offsets.lifted.Value})
				tween:Play()
				print("Lifting Helmet")
			else
				local HelmetWeld = helmet.Head:FindFirstChild("Helmet")
				local tween = TweenService:Create(HelmetWeld, TweenInfo.new(0.5), {C0 = helmet.Offsets.lowered.Value})
				tween:Play()
				print("Wearing Helmet")
			end
		end
	end)
	
	InputChange.OnServerEvent:Connect(function(player,inputName, Key)
		player.PlayerData['Settings Data'].Inputs.Binds:FindFirstChild(inputName).Current.Value = Key
		print("Updated Input")
	end)
	
	SettingChange.OnServerEvent:Connect(function(player, Category, Setting, value)
		player.PlayerData['Settings Data'][Category][Setting].Current.Value = value
		print("Updated Setting")
	end)
end

return module
