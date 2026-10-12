local module = {}

local Players = game:GetService("Players")

local Base = require(game:GetService("ReplicatedStorage").Shared.Library.MasterReference.Base)
local HEALTH_WAIT = Base.health_regen_tick
local HEALTH_TICK = Base.health_regen
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

		if humanoid.Parent and newHealth > 0 and newHealth < 100 then
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

			-- The character can be destroyed while the regeneration task is waiting.
			local character = humanoid.Parent
			if not character or humanoid.Health <= 0 then break end
			local player = Players:GetPlayerFromCharacter(character)
			local regenerationBlocked = (character:GetAttribute("InjuryRegenerationBlocked") == true and not character:GetAttribute("LancerPainSuppressed"))
			or (player and (player:GetAttribute("Clotting") or player:GetAttribute("Sickness")))
			if not regenerationBlocked and humanoid.Health >= 100 and humanoid.Health < humanoid.MaxHealth then
				if os.clock() - lastDamageTime >= HEALTH_DELAY then
					humanoid.Health = math.min(
						humanoid.Health + HEALTH_TICK * ((character:GetAttribute("ChemicalRegenerationMultiplier") or 1) + (character:GetAttribute("ChemicalRegenerationBonus") or 0)),
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
