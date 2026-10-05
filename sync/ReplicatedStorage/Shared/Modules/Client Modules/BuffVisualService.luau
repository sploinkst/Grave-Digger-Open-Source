--!strict
local Players = game:GetService("Players")
local Service = {}
local FLASH_DURATION = 2
local connections: {[Player]: {RBXScriptConnection}} = {}
local flashes: {[Player]: {[string]: number}} = {}

-- Rally has no outline in the master behavior. Bulwark's Hope is orange.
local visualPriority = {
	{"RadioFocus", Color3.fromRGB(80,150,255)},
	{"BulwarkHope", Color3.fromRGB(255,140,40)},
	{"Morale", Color3.fromRGB(255,235,120)},
	{"Bloodlust", Color3.fromRGB(190,35,35)},
}

local function refresh(player: Player)
	local character = player.Character
	if not character then return end
	local highlight = character:FindFirstChild("BuffHighlight") :: Highlight?
	local selected: Color3? = nil
	local deadlines = flashes[player]
	local now = os.clock()
	for _, entry in visualPriority do
		if deadlines and (deadlines[entry[1]] or 0) > now and player:GetAttribute(entry[1]) == true then
			selected = entry[2]
			break
		end
	end
	if not selected then
		if highlight then highlight:Destroy() end
		return
	end
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "BuffHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = .8
		highlight.OutlineTransparency = .1
		highlight.Parent = character
	end
	highlight.FillColor = selected
	highlight.OutlineColor = selected
end

local function changed(player: Player, name: string)
	local deadlines = flashes[player]
	if not deadlines then return end
	if player:GetAttribute(name) == true then
		local deadline = os.clock() + FLASH_DURATION
		deadlines[name] = deadline
		task.delay(FLASH_DURATION, function()
			-- An old timer must not cancel a newer application or another buff.
			if flashes[player] == deadlines and deadlines[name] == deadline then
				deadlines[name] = nil
				refresh(player)
			end
		end)
	else
		deadlines[name] = nil
	end
	refresh(player)
end

local function bind(player: Player)
	if connections[player] then return end
	connections[player] = {}
	flashes[player] = {}
	for _, entry in visualPriority do
		local name = entry[1]
		table.insert(connections[player], player:GetAttributeChangedSignal(name):Connect(function()
			changed(player, name)
		end))
		if player:GetAttribute(name) == true then changed(player, name) end
	end
	table.insert(connections[player], player.CharacterAdded:Connect(function()
		-- Respawning does not restart outlines for buffs that are still active.
		task.defer(refresh, player)
	end))
end

function Service.start_module()
	for _, player in Players:GetPlayers() do bind(player) end
	Players.PlayerAdded:Connect(bind)
	Players.PlayerRemoving:Connect(function(player)
		for _, connection in connections[player] or {} do connection:Disconnect() end
		connections[player] = nil
		flashes[player] = nil
	end)
end
return Service
