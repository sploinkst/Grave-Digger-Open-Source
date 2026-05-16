local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local player_service = game:GetService("Players")

local replicant_folder = ReplicatedStorage.Shared.Library.Events.Replicant_Communication

local fastcast_replicant = replicant_folder.FastCast_Connection
local vfx_replicant = replicant_folder.VFX_Connection
local sfx_replicant = replicant_folder.SFX_Connection
local texture_replicant = replicant_folder.Texture_Connection
local hit_connection = replicant_folder.Hit_Connection
local heal_connection = replicant_folder.Heal_Connection
local healnotify_connection = replicant_folder.HealNotify_Connection

local status_connection = replicant_folder.Parent.Status_Communication.Status_Connection

local gun_communication = replicant_folder.Parent.Gun_Communication
local drop_connection = gun_communication.Drop_Connection


local status_service = require(script.Parent.StatusService)

local item_service = require(script.Parent.ItemsService)

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

function module.check_for_helmet(character)
	local character_head = character.Head
	
	print("Checking for helmet for:", character.Name)
	for _, weld:Instance in character_head:GetChildren() do
		if not weld:IsA("Weld") and not weld:IsA("Motor6D") then print(weld.Name, "Not a weld or motor6d") continue end
		
		if weld.Name == "AccessoryWeld" then
			print("Accessory found")
			
			local part_1 = weld.Part1
			
			if part_1.Parent:FindFirstChild("Helmet") then
				print("Helmet found")
				-- // check to see if its welded, if it isnt welded assume it was knocked off
				if part_1.Parent:FindFirstChild("Head") then
					if part_1.Parent.Head:FindFirstChild("Helmet") then
						return part_1.Parent
					else
						return false
					end
				end
				
				return part_1.Parent
				
				
			else
				print("Helmet not found")
				return false
			end
		end
	end
end

function module.pop_helmet(character, helmet_model)
	local Debris = game:GetService("Debris")

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
	end
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

	texture_replicant.OnServerEvent:Connect(function(...)
		texture_replicant:FireAllClients(...)
	end)

	hit_connection.OnServerEvent:Connect(function(player, hitData, damage: number, knockback_force: number)
		if not hitData then
			return
		end

		local instance: BasePart = hitData.Instance
		local position: Vector3 = hitData.Position
		local direction: Vector3 = hitData.Direction

		if not instance or not instance:IsDescendantOf(workspace) then
			return
		end

		if not direction then
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local model = getModelFromInstance(instance)
		local humanoid = getHumanoid(model)

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local hitCharacter = model
		local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)

		-- // Knockback
		local forceDirection = (direction.Unit + Vector3.new(0, 0.1, 0)).Unit

		local baseForce = knockback_force or 5
		local distance = (hrp.Position - position).Magnitude
		local finalForce = getDistanceScaledForce(baseForce, distance)

		local knockbackTarget = if instance:IsA("BasePart")
			then instance
			else model and model.PrimaryPart

		if knockbackTarget then
			applyKnockback(knockbackTarget, forceDirection, finalForce)
		end

		-- // Headshot / helmet logic
		if hitPlayer and instance.Name == "Head" then
			local helmet = module.check_for_helmet(hitCharacter)

			if helmet then
				module.pop_helmet(hitCharacter, helmet)

				status_service.give_status(hitPlayer, "ConcussionStatus")

				task.delay(3, function()
					status_service.remove_status(hitPlayer, "ConcussionStatus")
				end)
				
				return
			else
				-- No helmet = instant kill
				humanoid.Health = 0
				return
			end
		end

		-- // Damage
		humanoid:TakeDamage(damage or 0)

		-- // Injury states
		if humanoid.Health < 100 and hitPlayer then
			status_service.give_status(hitPlayer, "WoundStatus", nil, instance.Name)
			status_service.give_status(hitPlayer, "ConcussionStatus")
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
			velocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			velocity.Parent = model_clone.PrimaryPart

			game:GetService("Debris"):AddItem(velocity, 0.25)
		end
	end)
end

return module