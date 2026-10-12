local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Teleport = game:GetService("TeleportService")
local MemoryStore = game:GetService("MemoryStoreService")
local Service = {}
local startedAt = os.time()
local directory = MemoryStore:GetSortedMap("MenuServers:" .. game.PlaceId)
local cache, cacheAt, requests = {}, 0, {}
local function current()
	local stuff = workspace:FindFirstChild("serverStuff")
	local values = stuff and stuff:FindFirstChild("values")
	local mode = values and values:FindFirstChild("gamemode")
	return {id=game.JobId, name=workspace:GetAttribute("ServerName") or "Grave Digger", region=workspace:GetAttribute("ServerRegion") or "Unknown", players=#Players:GetPlayers(), maximum=Players.MaxPlayers, mission=mode and mode.Value or "control", lifetime=os.time()-startedAt, updated=os.time()}
end
local function list()
	if not RunService:IsStudio() and os.clock()-cacheAt >= 10 then
		local ok, entries = pcall(function() return directory:GetRangeAsync(Enum.SortDirection.Descending, 100) end)
		if ok then
			cache = {}
			for _, entry in entries do
				local value = entry.value
				if type(value)=="table" and type(value.id)=="string" and type(value.updated)=="number"
					and os.time()-value.updated <= 90 then table.insert(cache,value) end
			end
		end
		cacheAt = os.clock()
	end
	local result = {}
	for _, entry in cache do if entry.id ~= game.JobId then table.insert(result,entry) end end
	table.insert(result,current())
	return result
end
function Service.start_module()
	if Service.started then return end
	Service.started = true
	local events = RS.Shared.Library.Events
	local remote = events:FindFirstChild("MenuServers") or Instance.new("RemoteFunction")
	remote.Name = "MenuServers"; remote.Parent = events
	remote.OnServerInvoke = function(player, action, id)
		local now = os.clock()
		if now-(requests[player] or -10) < 2 then return {error="Please wait before trying again."} end
		requests[player] = now
		if action=="List" then return {servers=list()} end
		if action~="Join" or type(id)~="string" or #id>100 or id==game.JobId then return {error="Choose another server."} end
		if RunService:IsStudio() then return {error="Server travel is available in the published game."} end
		local found
		for _, entry in list() do if entry.id==id and entry.players<entry.maximum then found=entry; break end end
		if not found then return {error="That server is no longer available."} end
		local options = Instance.new("TeleportOptions"); options.ServerInstanceId = id
		local ok = pcall(function() Teleport:TeleportAsync(game.PlaceId,{player},options) end)
		return ok and {joining=true} or {error="Could not join that server. Please try again."}
	end
	Players.PlayerRemoving:Connect(function(player) requests[player]=nil end)
	if RunService:IsStudio() or game.PrivateServerId~="" then return end
	task.spawn(function()
		while true do
			local value = current()
			pcall(function() directory:SetAsync(game.JobId,value,90,value.players) end)
			task.wait(15)
		end
	end)
	game:BindToClose(function() pcall(function() directory:RemoveAsync(game.JobId) end) end)
end
return Service
