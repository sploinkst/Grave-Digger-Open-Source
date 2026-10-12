local RS = game:GetService("ReplicatedStorage")
local Rules = require(RS.Shared.Library.KingslayerRules)
local Validation = require(script.Parent.MasterActions.Validation)
local Service = {}
local states = setmetatable({}, {__mode = "k"})
local events = RS.Shared.Library.Events
local remote = events:FindFirstChild("KingslayerAction")
if not remote then remote = Instance.new("RemoteFunction"); remote.Name = "KingslayerAction"; remote.Parent = events end
local durations = {Cap = 0.75, Ball = 0.75, Pour = 1.5, Ram = 1.5, Dump = 1, Rotate = 0.3, Close = 0.5, Fire = 1.4, Open = 0.5}
local function get(tool)
	if not states[tool] then states[tool] = {state = Rules.New(), ready = 0, shots = {}, sequence = 0} end
	return states[tool]
end
function Service.ResolveHit(tool, token)
	local record = states[tool]
	local shot = record and record.shots[token]
	if not shot or os.clock() - shot.time > 4 then return nil end
	return shot.factor
end
function Service.start_module()
	if Service.started then return end; Service.started = true
	remote.OnServerInvoke = function(player, tool, action, amount)
		local character = Validation.Tool(player, tool, {"KingslayerRevolver"})
		if not character then return nil end
		local record = get(tool)
		local reserve = tool:FindFirstChild("Reserve_Ammo")
		if not reserve then return nil end
		if action == "Get" then return {state = record.state, reserve = reserve.Value} end
		local duration = durations[action]
		local now = os.clock()
		if not duration or now < record.ready then return {state = record.state, error = "Busy."} end
		local shot, ok, remaining, message
		if action == "Fire" then
			if record.loading then return {state = record.state, error = "Close the cylinder first."} end
			shot = Rules.Fire(record.state); ok = true
		elseif action == "Open" then
			if record.state.broken then return {state = record.state, error = "The cylinder is broken."} end
			record.loading = true; ok = true
		else
			if not record.loading then return {state = record.state, error = "Open the cylinder first."} end
			if action == "Pour" then
				if type(amount) ~= "number" or amount ~= amount or amount < 0.1 or amount > 1 then return nil end
				duration += amount
			end
			ok, remaining, message = Rules.Load(record.state, action, reserve.Value, amount)
			if ok then reserve.Value = remaining end
			if action == "Close" and ok then record.loading = false end
		end
		if not ok then return {state = record.state, error = message} end
		local factor = character:GetAttribute("Veteran") == true and action ~= "Fire" and action ~= "Rotate" and 0.8 or 1
		record.ready = now + duration * factor
		if shot and shot.projectile then
			record.sequence += 1; shot.token = record.sequence
			record.shots[shot.token] = {time = now, factor = shot.factor}
			for token, entry in record.shots do if now - entry.time > 4 then record.shots[token] = nil end end
		end
		return {state = record.state, reserve = reserve.Value, shot = shot, duration = duration * factor}
	end
end
return Service
