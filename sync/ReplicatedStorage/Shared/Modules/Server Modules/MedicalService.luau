local module = {}

local Players = game:GetService("Players")

local HEALTH_WAIT = 0.15
local HEALTH_TICK = 1
local HEALTH_DELAY = 5

local ActiveHumanoids = {}

local function health_loop(humanoid)
	if ActiveHumanoids[humanoid] then
		return
	end

	ActiveHumanoids[humanoid] = true

	local lastDamageTime = os.clock()
	local lastHealth = humanoid.Health
	if lastHealth > 0 and lastHealth < 100 then
		humanoid.Parent:SetAttribute("InjuryRegenerationBlocked", true)
	end

	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			lastDamageTime = os.clock()
		end

		if newHealth > 0 and newHealth < 100 then
			humanoid.Parent:SetAttribute("InjuryRegenerationBlocked", true)
		end
		lastHealth = newHealth
	end)

	humanoid.Destroying:Connect(function()
		ActiveHumanoids[humanoid] = nil
	end)

	task.spawn(function()
		while humanoid.Parent and humanoid.Health > 0 do
			task.wait(HEALTH_WAIT)

			local player = Players:GetPlayerFromCharacter(humanoid.Parent)
			local regenerationBlocked = humanoid.Parent:GetAttribute("InjuryRegenerationBlocked") == true
			or (player and (player:GetAttribute("Clotting") or player:GetAttribute("Sickness")))
			if not regenerationBlocked and humanoid.Health >= 100 and humanoid.Health < humanoid.MaxHealth then
				if os.clock() - lastDamageTime >= HEALTH_DELAY then
					humanoid.Health = math.min(
						humanoid.Health + HEALTH_TICK * (humanoid.Parent:GetAttribute("ChemicalRegenerationMultiplier") or 1),
						humanoid.MaxHealth
					)
				end
			end
		end

		ActiveHumanoids[humanoid] = nil
	end)
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	health_loop(humanoid)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

module.TrackHumanoid = health_loop

function module.start_module()
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

return module
