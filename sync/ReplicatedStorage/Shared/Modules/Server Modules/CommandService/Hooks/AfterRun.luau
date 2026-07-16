local RunService = game:GetService("RunService")

return function(registry)
	if RunService:IsClient() then
		return
	end

	local HttpService = game:GetService("HttpService")

	-- Replace this with your Discord webhook URL
	local WEBHOOK_URL = "https://discord.com/api/webhooks/1526146854574624810/OhDohQGVg82edWGG589K4SXHcZAc3UOTxZSP5JZOE1yiz4UzEfORBmrqem9vqQ8MeOuY"

	registry:RegisterHook("AfterRun", function(context)
		local function serializeArg(arg)
			if typeof(arg) == "Instance" then
				return string.format("%s (%s)", arg.Name, arg.ClassName)
			elseif typeof(arg) == "table" then
				local result = {}

				for k, v in pairs(arg) do
					result[tostring(k)] = serializeArg(v)
				end

				return HttpService:JSONEncode(result)
			else
				return tostring(arg)
			end
		end

		local formattedArgs = {}

		for _, arg in ipairs(context.Args or {}) do
			table.insert(formattedArgs, serializeArg(arg))
		end

		local executorName = "Server"
		local executorId = 0

		if context.Executor and context.Executor:IsA("Player") then
			executorName = context.Executor.Name
			executorId = context.Executor.UserId
		end

		local embed = {
			title = ("Command Executed: %s"):format(context.Name or "Unknown"),
			color = context.Error and 16711680 or 65280,
			fields = {
				{
					name = "Executor",
					value = ("%s (UserId: %d)"):format(executorName, executorId),
					inline = true
				},
				{
					name = "Command",
					value = ("Raw: `%s`\nArguments: %s"):format(
						context.RawText or "",
						#formattedArgs > 0 and table.concat(formattedArgs, ", ") or "None"
					),
					inline = false
				},
				{
					name = "Context",
					value = ("PlaceId: %d\nJobId: %s\nEnvironment: %s"):format(
						game.PlaceId,
						game.JobId,
						RunService:IsStudio() and "Studio" or "Live"
					),
					inline = false
				},
				{
					name = "Result",
					value = context.Error and tostring(context.Error) or tostring(context.Response or "Success"),
					inline = false
				},
				{
					name = "Timestamp",
					value = os.date("!%Y-%m-%d %H:%M:%S UTC"),
					inline = false
				}
			},
			footer = {
				text = "CMDR Command Logger"
			}
		}

		local payload = {
			embeds = { embed }
		}

		local success, err = pcall(function()
			HttpService:PostAsync(
				WEBHOOK_URL,
				HttpService:JSONEncode(payload),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not success then
			warn("[CMDR Webhook] Failed to send webhook:", err)
		end
	end)
end