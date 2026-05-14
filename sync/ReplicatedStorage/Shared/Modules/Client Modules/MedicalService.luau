local module = {}

-- // Services
local player_service = game:GetService("Players")

-- // Variables
local local_player = player_service.LocalPlayer
local character = nil
local humanoid = nil

local health_wait = 0.15
local health_tick = 1
local health_delay = 5
-- // Functions
-- rebinds the variables
local function update_char_variables()
	character = player_service.LocalPlayer.Character
	humanoid = character:WaitForChild("Humanoid")
end

local function health_loop()
	local last_damage_time = tick()
	local is_running = false

	-- Detect damage
	humanoid.HealthChanged:Connect(function(new_health)
		if new_health < humanoid.MaxHealth then
			last_damage_time = tick()
		end
	end)

	-- Prevent duplicate loops
	if is_running then return end
	is_running = true

	task.spawn(function()
		while humanoid and humanoid.Parent do
			task.wait(health_wait)

			-- Only regen if above 100 and not full
			if humanoid.Health >= 100 and humanoid.Health < humanoid.MaxHealth then
				-- Check delay since last damage
				if tick() - last_damage_time >= health_delay then
					humanoid.Health = math.min(
						humanoid.Health + health_tick,
						humanoid.MaxHealth
					)
				end
			end
		end

		is_running = false
	end)
end


-- // Connections
function module.start_module()
	
	update_char_variables()
	health_loop()
	
	local_player.CharacterAdded:Connect(function()
		update_char_variables()
		health_loop()
	end)
end

return module
