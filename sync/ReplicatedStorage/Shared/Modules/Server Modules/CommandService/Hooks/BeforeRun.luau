local RunService = game:GetService("RunService")

local GameVariables = game:GetService("ReplicatedStorage")
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Configuration")
	:WaitForChild("Game_Variables")

local DebugAccess = GameVariables:WaitForChild("DebugAccess")

return function(registry)
	registry:RegisterHook("BeforeRun", function(context)
		local playerData = context.Executor:WaitForChild("PlayerData"):WaitForChild("PlayerData")
		local cmdrLevel = playerData:WaitForChild("CMDRLevel")

		local commandLevel = tonumber(context.Group) or 0

		if commandLevel > tonumber(cmdrLevel.Value) then
			return string.format(
				"You have (%d) CMDR Level. This command requires (%d) CMDR Level.",
				cmdrLevel.Value,
				commandLevel
			)
		end

		if RunService:IsClient() then
			return
		end

		if DebugAccess.Value == false then
			if context.Executor.UserId ~= 2756349779 and context.Executor.UserId ~= 1953037778 then
				return "Lack permission to run this command currently."
			end
		end
	end)
end