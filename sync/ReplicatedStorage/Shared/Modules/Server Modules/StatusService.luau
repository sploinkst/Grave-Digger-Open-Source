local StatusService = {}

local StatusFolder = game.ReplicatedStorage.Shared.Library.Classes.StatusClasses

-- // [player] = { [statusName] = statusInstance }
local StatusTable = {}
local ExpirationTokens = {}

function StatusService.GiveStatus(player, status, ...)
	local args = { ... }
	print("Giving status:", player.Name, status, args)
	if status ~= "DreadnoughtStatus" then
		local character = player.Character
		if character and character:GetAttribute("StatusImmune") == true then
			return
		end
	end

	local statusModuleScript = StatusFolder:FindFirstChild(status)
	if not statusModuleScript then
		warn("StatusService: Status not found:", status)
		return
	end

	local statusModule = require(statusModuleScript)
	StatusTable[player] = StatusTable[player] or {}
	ExpirationTokens[player] = ExpirationTokens[player] or {}

	-- Reapplying a status refreshes it. Unapplying the old instance first also
	-- prevents movement/handling modifiers from being permanently compounded.
	local existing = StatusTable[player][status]
	if existing and status == "MinorBurnStatus" then
		StatusService.RemoveStatus(player, status)
		StatusService.GiveStatus(player, "LethalBurningStatus")
		return
	end
	if existing and status ~= "WoundStatus" then
		local requestedDuration = args[1]
		if existing.duration == nil then
			return
		end
		if type(requestedDuration) == "number" and type(existing.expiresAt) == "number"
			and existing.expiresAt - os.clock() >= requestedDuration then
			return
		end
	end
	if existing and not existing._remove_interception then
		existing:un_apply(player)
	end
	StatusTable[player][status] = nil
	ExpirationTokens[player][status] = nil

	local statusInstance = statusModule.new()
	statusInstance:apply(player, ...)
	if not statusInstance:is_applied(player) then
		if next(StatusTable[player]) == nil then
			StatusTable[player] = nil
			ExpirationTokens[player] = nil
		end
		return
	end

	-- // Initialize player table if needed
	-- // Store by status name
	StatusTable[player][status] = statusInstance

	local duration = statusInstance.duration
	if type(duration) == "number" and duration > 0 then
		statusInstance.expiresAt = os.clock() + duration
		local token = {}
		ExpirationTokens[player][status] = token
		task.delay(duration, function()
			if ExpirationTokens[player] and ExpirationTokens[player][status] == token then
				StatusService.RemoveStatus(player, status)
			end
		end)
	end
	print("StatusService: Status applied:", status)
end

function StatusService.RemoveStatus(player, status)
	print("Removing status:", player.Name, status)

	local statusModuleScript = StatusFolder:FindFirstChild(status)
	if not statusModuleScript then
		warn("StatusService: Status not found:", status)
		return
	end

	local playerStatuses = StatusTable[player]
	if not playerStatuses then
		warn("No statuses found for player:", player.Name)
		return
	end

	local statusInstance = playerStatuses[status]
	if not statusInstance then
		warn("Status not applied to player:", status)
		return
	end

	statusInstance:un_apply(player)
	if ExpirationTokens[player] then
		ExpirationTokens[player][status] = nil
	end

	-- // Only remove if fully unapplied
	if not statusInstance:is_applied(player) then
		playerStatuses[status] = nil
		-- // Cleanup empty table
		if next(playerStatuses) == nil then
			StatusTable[player] = nil
			ExpirationTokens[player] = nil
		end
		print("StatusService: Status removed:", status)
	end
end

function StatusService.RemoveAllStatuses(player)
	print("Removing all statuses for player:", player.Name)

	for _, status in pairs(StatusTable[player] or {}) do
		if status:is_applied(player) then
			status:un_apply(player)
		end
	end
	StatusTable[player] = nil
	ExpirationTokens[player] = nil
end

function StatusService.HasStatus(player, status)
	return StatusTable[player] ~= nil and StatusTable[player][status] ~= nil
end

function StatusService.start_module()
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		StatusService.RemoveAllStatuses(player)
	end)
end
return StatusService
