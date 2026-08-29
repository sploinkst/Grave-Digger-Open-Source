local StatusService = {}

local StatusFolder = game.ReplicatedStorage.Shared.Library.Classes.StatusClasses

-- // [player] = { [statusName] = statusInstance }
local StatusTable = {}

function StatusService.GiveStatus(player, status, ...)
	local args = { ... }
	print("Giving status:", player.Name, status, args)

	local statusModuleScript = StatusFolder:FindFirstChild(status)
	if not statusModuleScript then
		warn("StatusService: Status not found:", status)
		return
	end

	local statusModule = require(statusModuleScript)
	local statusInstance = statusModule.new()
	statusInstance:apply(player, ...)

	-- // Initialize player table if needed
	StatusTable[player] = StatusTable[player] or {}
	-- // Store by status name
	StatusTable[player][status] = statusInstance
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

	-- // Only remove if fully unapplied
	if not statusInstance:is_applied(player) then
		playerStatuses[status] = nil
		-- // Cleanup empty table
		if next(playerStatuses) == nil then
			StatusTable[player] = nil
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
end

function StatusService.start_module()
	
end
return StatusService