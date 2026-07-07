local module = {}

local player_service = game:GetService("Players")

local health_wait  = 0.15
local health_tick  = 1
local health_delay = 5
local health_gate  = 99

local function health_loop(humanoid)
	local last_damage_time = tick()
	local last_health      = humanoid.Health

	humanoid.HealthChanged:Connect(function(new_health)
		if new_health < last_health then
			last_damage_time = tick()
		end
		last_health = new_health
	end)

	task.spawn(function()
		while humanoid and humanoid.Parent do
			task.wait(health_wait)
			if humanoid.Health > 0
				and humanoid.Health < humanoid.MaxHealth
				and humanoid.Health <= health_gate
			then
				if tick() - last_damage_time >= health_delay then
					humanoid.Health = math.min(
						humanoid.Health + health_tick,
						humanoid.MaxHealth
					)
				end
			end
		end
	end)
end

local function on_character_added(character)
	local humanoid = character:WaitForChild("Humanoid")
	health_loop(humanoid)
end

local function on_player_added(player)
	player.CharacterAdded:Connect(on_character_added)
	if player.Character then
		on_character_added(player.Character)
	end
end

function module.start_module()
	player_service.PlayerAdded:Connect(on_player_added)
	for _, player in ipairs(player_service:GetPlayers()) do
		on_player_added(player)
	end
end

return module