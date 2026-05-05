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
		if not hitData then return end

		local position = hitData.Position
		local instance = hitData.Instance
		local direction = hitData.Direction


		if not instance or not instance:IsDescendantOf(workspace) then return end
		if not direction then return end

		local character = player.Character
		if not character then return end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		local hit_player = game.Players:GetPlayerFromCharacter(instance.Parent)
		
		local forceDir = (direction.Unit + Vector3.new(0, 0.1, 0)).Unit

		local baseForce = knockback_force or 5
		local distance = (hrp.Position - position).Magnitude
		local finalForce = getDistanceScaledForce(baseForce, distance)

		local model = getModelFromInstance(instance)
		local humanoid = getHumanoid(model)

		if instance:IsA("BasePart") then
			applyKnockback(instance, forceDir, finalForce)
		elseif model and model.PrimaryPart then
			applyKnockback(model.PrimaryPart, forceDir, finalForce)
		end

		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(damage or 0)
			
			
			if humanoid.Health < 100 then
				status_service.give_status(hit_player, "WoundStatus")
				status_service.give_status(hit_player, "ConcussionStatus")
			end
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