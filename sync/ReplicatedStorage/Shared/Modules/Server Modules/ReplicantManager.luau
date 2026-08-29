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

local AmmoPackEvent = replicant_folder.Ammo
local AmmoPack = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Equipment"):WaitForChild("AmmoPack")
local Helmet_RemoteEvent        = ReplicatedStorage.Shared.Library.Events.Helmet
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

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

function module.pop_helmet(character, helmet_model, knockable: boolean)
	print("[POP_HELMET] Attempting to pop helmet for character:", character.Name, helmet_model.Name, knockable)

	if knockable then
		print("[POP_HELMET] Helmet is knockable.")
		local head_part = helmet_model:FindFirstChild("Head")
		if not head_part then
			warn("Helmet head part missing")
			return
		end

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
		


		
		-- Prevent self-damage
		if player.Team.Name == hitPlayer.Team.Name then return end
		if hitPlayer and hitPlayer == player then return end
		
		hitPlayer:SetAttribute("LastTagged", player.Name)
		
		-- Knockback
		local forceDirection = (direction.Unit + Vector3.new(0, 0.1, 0)).Unit
		local baseForce      = knockback_force or 5
		local distance       = (hrp.Position - position).Magnitude
		local finalForce     = getDistanceScaledForce(baseForce, distance)

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

			if helmet then
				-- Only pop if not already knocked
				if not helmet:GetAttribute("Knocked") then
					module.pop_helmet(hitCharacter, helmet, knockable)
				end

				if hitPlayer then
					status_service.give_status(hitPlayer, "ConcussionStatus")
					task.delay(3, function()
						if hitPlayer.Character and
							hitPlayer.Character:FindFirstChildOfClass("Humanoid") and
							hitPlayer.Character.Humanoid.Health >= 100 then
							status_service.remove_status(hitPlayer, "ConcussionStatus")
						end
					end)
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
			status_service.give_status(hitPlayer, "WoundStatus", nil, instance.Name)
			status_service.give_status(hitPlayer, "ConcussionStatus")
		end
		
		if humanoid.Health <= 0 then
			player:SetAttribute("RoundKills", player:GetAttribute("RoundKills") + 1)
		end
	end)
	
	heal_connection.OnServerEvent:Connect(function(sender, healed, wound)
		if not healed:IsA("Player") then
			local player = game.Players:GetPlayerFromCharacter(healed)
			if not player then return end
			healed = player
		end
		
		
		status_service.remove_status(healed, "WoundStatus")
		status_service.remove_status(healed, "ConcussionStatus")
		healed.Character.Humanoid.Health = 100
	end)
	
	healnotify_connection.OnServerEvent:Connect(function(healer, healee:Player)
		print("Received healnotify_connection from", healer.Name, "for healee:", healee.Name)
		local notify_ui = require(healee.PlayerGui.Notifications.Utils)
		
		notify_ui.send_notification(healee, healer.Name .. ": Stand still while I heal you.")
	end)
	
	status_connection.OnServerEvent:Connect(function(player, status, enabled: boolean)
		if enabled then
			status_service.give_status(player, status)
		else
			status_service.remove_status(player, status)
		end
	end)

	drop_connection.OnServerEvent:Connect(function(player, tool, model, remove_tool: boolean)
		print("Received drop_connection from", player.Name, "for tool:", tool, "model:", model.Name, "remove_tool:", remove_tool)
		
		if not player or not model then 
			warn("[ReplicantManager::] Invalid player or model in drop_connection")
		end
		
		if remove_tool == true then
			item_service.remove_item(player, model.Name)
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
	
	melee_connection.OnServerEvent:Connect(function(player, targetCharacter, meleeRange, damage)
		print("Received melee_connection from", player.Name, "target:", targetCharacter.Name, "range:", meleeRange, "damage:", damage)
		
		if player.Name == targetCharacter.Name then
			return
		end
		
		if (player.Character.HumanoidRootPart.Position - targetCharacter.HumanoidRootPart.Position).Magnitude > meleeRange * 1.5 then
			return
		end
		
		targetCharacter.Humanoid:TakeDamage(damage)
		print("Applied damage to", targetCharacter.Name)
	end)
	
	ammo_connection.OnServerEvent:Connect(function(player, tool, count)
		print("Received ammo_connection from", tool.Name, "count:", count)
		tool.Reserve_Ammo.Value -= count
	end)
	
	AmmoPackEvent.OnServerEvent:Connect(function(player, target)
		print("Received AmmoPackEvent from", player.Name)
		if not target then
			local character = player.Character
			if not character then
				return
			end

			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				return
			end

			local clone = AmmoPack:Clone()
			clone.Position = hrp.Position + hrp.CFrame.LookVector * 4
			clone.CanCollide = false
			clone.Parent = workspace

			local velocity = Instance.new("BodyVelocity")
			velocity.Velocity = hrp.CFrame.LookVector * 20 + Vector3.new(0, 8, 0)
			velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			velocity.Parent = clone
			

			clone.Touched:Connect(function(hit)
				if not hit.Parent:FindFirstChild("Humanoid") then return end
				local player = game.Players:GetPlayerFromCharacter(hit.Parent)
				if Util.hasfullammo(player) then return end
				
				Util.setammo(player)
				print("AmmoPackEvent destroyed")
				clone:Destroy()
			end)
			task.delay(0.1, function()
				velocity:Destroy()
				clone.CanCollide = true
				clone.CanTouch = true
			end)
			
			task.delay(0.5, function()
				clone.CanCollide = true
			end)
			
			task.delay(30, function()
				if clone then
					clone:Destroy()
				end
			end)
		else
			local clone = AmmoPack:Clone()
			clone.Parent = workspace
			clone.Position = player.Character.Torso.Position
			clone.Anchored = true
			-- // lerp towards the target.Torso
			local connection

			connection = RunService.Heartbeat:Connect(function()
				if not target:FindFirstChild("Torso") then
					connection:Disconnect()
					clone:Destroy()
					return
				end

				local torso = target:FindFirstChild("Torso")
					or target:FindFirstChild("HumanoidRootPart")

				if not torso then
					connection:Disconnect()
					clone:Destroy()
					return
				end

				clone.Position = clone.Position:Lerp(torso.Position, 0.1)

				if (clone.Position - torso.Position).Magnitude < 2 then
					connection:Disconnect()

					Util.setammo(game.Players:GetPlayerFromCharacter(target))
					clone:Destroy()
				end
			end)
			
			
		end
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
