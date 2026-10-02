--!strict
local Players = game:GetService("Players")
local Service = {}
local connections: {RBXScriptConnection} = {}

-- Rally has no outline in the master behavior. Bulwark's Hope is orange.
local visualPriority = {
	{"RadioFocus", Color3.fromRGB(80,150,255)},
	{"BulwarkHope", Color3.fromRGB(255,140,40)},
	{"Morale", Color3.fromRGB(255,235,120)},
	{"Bloodlust", Color3.fromRGB(190,35,35)},
}

local function refresh(player: Player)
	local character=player.Character; if not character then return end
	local highlight=character:FindFirstChild("BuffHighlight") :: Highlight?
	local selected: Color3? = nil
	for _,entry in visualPriority do if player:GetAttribute(entry[1])==true then selected=entry[2]; break end end
	if not selected then if highlight then highlight:Destroy() end; return end
	if not highlight then
		highlight=Instance.new("Highlight"); highlight.Name="BuffHighlight"
		highlight.DepthMode=Enum.HighlightDepthMode.Occluded; highlight.FillTransparency=.8
		highlight.OutlineTransparency=.1; highlight.Parent=character
	end
	highlight.FillColor=selected; highlight.OutlineColor=selected
end

local function bind(player: Player)
	for _,entry in visualPriority do table.insert(connections,player:GetAttributeChangedSignal(entry[1]):Connect(function() refresh(player) end)) end
	table.insert(connections,player.CharacterAdded:Connect(function() task.defer(refresh,player) end))
	refresh(player)
end

function Service.start_module()
	for _,player in Players:GetPlayers() do bind(player) end
	Players.PlayerAdded:Connect(bind)
end
return Service
