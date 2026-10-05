local Players=game:GetService("Players"); local Lighting=game:GetService("Lighting"); local Service={}; local localPlayer=Players.LocalPlayer
local firstWarnings={"A chill is running up my spine..","It's cold all of the sudden..","I don't feel safe here..","Something is hiding in the shadows.."}
local secondWarnings={"I'm being tracked..","I feel like someone is watching me..","I'm being hunted..","Someone is tracking me.."}
local Audio = require(game:GetService("ReplicatedStorage").Shared.Library.GameAudio)
local RunService = game:GetService("RunService")
local hunting = {}
local hunted=false
local huntGeneration = 0
local started = false
local function setting(name)
    local root = localPlayer:FindFirstChild("PlayerData")
    local settings = root and root:FindFirstChild("Settings Data")
    local entry = settings and settings:FindFirstChild(name, true)
    local current = entry and entry:FindFirstChild("Current")
    return current and current:IsA("BoolValue") and current.Value or false
end
local function inPingRange(source)
    local a = source and source.Character and source.Character:FindFirstChild("HumanoidRootPart")
    local b = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    return a and b and (a.Position-b.Position).Magnitude <= Audio.PingRadius
end
local function popup(key,text,duration) if _G.popupmsg and _G.popupmsg(key,text,duration) ~= false then Audio.Whisper() end end
local function refreshLocal()
	local now=localPlayer:GetAttribute("Hunted")==true
	if now ~= hunted then huntGeneration += 1 end
	local generation = huntGeneration
	if now and not hunted then popup("hunted_warning",firstWarnings[math.random(#firstWarnings)],3); task.delay(2.5,function() if generation == huntGeneration and localPlayer:GetAttribute("Hunted") then popup("hunted_tracking",secondWarnings[math.random(#secondWarnings)],4) end end) end
	hunted=now
	local sick=localPlayer:GetAttribute("Sickness")==true; local effect=Lighting:FindFirstChild("SicknessColor")
	if sick and not effect then effect=Instance.new("ColorCorrectionEffect"); effect.Name="SicknessColor"; effect.Saturation=-1; effect.Contrast=.08; effect.Parent=Lighting elseif not sick and effect then effect:Destroy() end
end
local function refreshMark(player)
	local c=player.Character; if not c then return end; local old=c:FindFirstChild("DebuffHighlight"); local marker=c:FindFirstChild("DebuffMarker"); local show=false; local color=Color3.fromRGB(210,35,35); local symbol="◆"
	if player:GetAttribute("Spotted") then local source=Players:GetPlayerByUserId(player:GetAttribute("SpottedByUserId") or 0); show=player~=localPlayer and player.Team~=localPlayer.Team and source and source.Team==localPlayer.Team and inPingRange(source) and not setting("HideDangerPings"); if player:GetAttribute("SpottedEnhanced") and player.Team then color=player.Team.TeamColor.Color end end
	local isHunting = player:GetAttribute("Hunted") and player:GetAttribute("HuntedByUserId")==localPlayer.UserId
    if isHunting and not hunting[player] then popup("hunting_" .. player.UserId, "You are hunting " .. player.DisplayName .. ".", 4) end
    hunting[player] = isHunting or nil
    if isHunting then show=true; color=Color3.fromRGB(235,235,235); symbol="☠" end
	if not show then if old then old:Destroy() end; if marker then marker:Destroy() end; return end
	if not old then old=Instance.new("Highlight"); old.Name="DebuffHighlight"; old.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; old.FillTransparency=.75; old.OutlineTransparency=0; old.Parent=c end; old.FillColor=color; old.OutlineColor=color
	if not marker then local head=c:FindFirstChild("Head"); if head then marker=Instance.new("BillboardGui"); marker.Name="DebuffMarker"; marker.AlwaysOnTop=true; marker.Size=UDim2.fromOffset(32,32); marker.StudsOffset=Vector3.new(0,2.2,0); marker.Adornee=head; local label=Instance.new("TextLabel"); label.Name="Icon"; label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.TextScaled=true; label.Font=Enum.Font.GothamBold; label.Parent=marker; marker.Parent=c end end
	local label=marker and marker:FindFirstChild("Icon"); if label and label:IsA("TextLabel") then label.Text=symbol; label.TextColor3=color; label.TextStrokeTransparency=.2 end
end
local function bind(player) for _,name in {"Spotted","SpottedEnhanced","SpottedByUserId","Hunted","HuntedByUserId"} do player:GetAttributeChangedSignal(name):Connect(function() refreshMark(player); if player==localPlayer then refreshLocal() end end) end; player.CharacterAdded:Connect(function() task.defer(refreshMark,player) end); refreshMark(player) end
function Service.start_module() if started then return end; started=true; localPlayer:GetAttributeChangedSignal("Sickness"):Connect(refreshLocal); refreshLocal(); for _,p in Players:GetPlayers() do bind(p) end; Players.PlayerAdded:Connect(bind); Players.PlayerRemoving:Connect(function(p) hunting[p]=nil end)
    local elapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < 0.25 then return end
        elapsed = 0
        for _, p in Players:GetPlayers() do refreshMark(p) end
    end)
    game:GetService("ReplicatedStorage").Shared.Library.Events:WaitForChild("Presentation").OnClientEvent:Connect(function(action, payload)
        if action == "morale" then Audio.Play("Game", "morale")
        elseif action == "pinged_by" then Audio.Play("Game", "pinged_by")
        elseif action == "enemy_ping" and type(payload) == "table" then
            local source = Players:GetPlayerByUserId(payload.sourceUserId)
            local target = Players:GetPlayerByUserId(payload.targetUserId)
            if source and target and source.Team == localPlayer.Team and target.Team ~= localPlayer.Team and inPingRange(source) and not setting("HideDangerPings") then
                refreshMark(target)
                if not setting("MuteOfficerPings") then Audio.Play("Game", "ping_enemy") end
            end
        end
    end)
end
return Service
