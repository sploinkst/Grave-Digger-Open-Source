local Players=game:GetService("Players"); local Service={}; local localPlayer=Players.LocalPlayer; local connections={}
local colors={RadioFocus=Color3.fromRGB(80,150,255),Morale=Color3.fromRGB(255,235,120),BulwarkHope=Color3.fromRGB(255,140,40),Rally=Color3.fromRGB(120,210,120),Bloodlust=Color3.fromRGB(190,35,35)}
local function refresh(player)
	local c=player.Character; if not c then return end; local h=c:FindFirstChild("BuffHighlight"); local selected
	for name,color in pairs(colors) do if player:GetAttribute(name) then selected=color; break end end
	if not selected then if h then h:Destroy() end; return end
	if not h then h=Instance.new("Highlight"); h.Name="BuffHighlight"; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.FillTransparency=.8; h.OutlineTransparency=.1; h.Parent=c end
	h.FillColor=selected; h.OutlineColor=selected
end
local function bind(player) for name in pairs(colors) do table.insert(connections,player:GetAttributeChangedSignal(name):Connect(function() refresh(player) end)) end; player.CharacterAdded:Connect(function() task.defer(refresh,player) end); refresh(player) end
function Service.start_module() for _,p in Players:GetPlayers() do bind(p) end; Players.PlayerAdded:Connect(bind) end
return Service
