local Players=game:GetService("Players"); local Lighting=game:GetService("Lighting"); local Service={}; local localPlayer=Players.LocalPlayer
local firstWarnings={"A chill is running up my spine..","It's cold all of the sudden..","I don't feel safe here..","I don't feel normal..","My fingers are getting cold..","I can't stop shaking..","I feel like a prey..","Something is hiding in the shadows.."}
local secondWarnings={"I'm being hunted..","I'm being tracked..","Someone is tracking me..","I feel like someone is watching me..","I feel like I'm being watched..","I feel like I'm being followed..","I feel like someone sees me.."}
local Audio = require(game:GetService("ReplicatedStorage").Shared.Library.GameAudio)
local RunService = game:GetService("RunService")
local Voice = require(game:GetService("ReplicatedStorage").Shared.Library.CharacterVoice)
local voiceCharacter, voiceState
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
local function popup(key,text,duration)
    local shown = _G.popupmsg and _G.popupmsg(key,text,duration)
    if not shown then
        local core = require(game:GetService("ReplicatedStorage").Shared.Library.AuthoredAssets).CoreGame()
        local holder = core and core:FindFirstChild("textpopups")
        local template = holder and holder:FindFirstChild("ex")
        if holder and not holder:FindFirstChild(key) and template and template:IsA("TextLabel") then
            local row = template:Clone()
            row.Name=key; row.Text=text; row.Visible=true; row.TextTransparency=0; row.TextStrokeTransparency=0
            row.Parent=holder
            task.delay(duration or 4,function() if row.Parent then row:Destroy() end end)
            shown=true
        end
    end
    if shown then Audio.Whisper() end
end
local function refreshLocal()
	local now=localPlayer:GetAttribute("Hunted")==true
	if now ~= hunted then huntGeneration += 1 end
	local generation = huntGeneration
	if not now and hunted then popup("hunted_lost", "I'm no longer being hunted.", 3) end
	if now and not hunted then popup("hunted_warning",firstWarnings[math.random(#firstWarnings)],3); task.delay(2.5,function() if generation == huntGeneration and localPlayer:GetAttribute("Hunted") then popup("hunted_tracking",secondWarnings[math.random(#secondWarnings)],4) end end) end
	hunted=now
	local sick=localPlayer:GetAttribute("Sickness")==true; local effect=Lighting:FindFirstChild("SicknessColor")
	if sick and not effect then effect=Instance.new("ColorCorrectionEffect"); effect.Name="SicknessColor"; effect.Saturation=-1; effect.Contrast=.08; effect.Parent=Lighting elseif not sick and effect then effect:Destroy() end
end
local function updateStatusVoices()
    local character = localPlayer.Character
    if character ~= voiceCharacter then voiceCharacter, voiceState = character, {} end
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return end
    local gas = false
    local throwables = workspace:FindFirstChild("throwables")
    if throwables and not character:FindFirstChild("gasmask") and not character:GetAttribute("HasGasMask") then
        for _, cloud in ipairs(throwables:GetChildren()) do
            if cloud.Name == "smokespread" or (cloud.Name == "nebel" and cloud:FindFirstChild("body") and cloud:FindFirstChild("smoke_active")) then
                local hitbox = cloud.Name == "nebel" and cloud:FindFirstChild("hitbox") or cloud
                if hitbox and hitbox:IsA("BasePart") and (root.Position - hitbox.Position).Magnitude <= 6.5 then gas = true; break end
            end
        end
    end
    local drinking = character:FindFirstChild("drinking") ~= nil or character:GetAttribute("Drinking") == true
    if not drinking then
        local held = character:FindFirstChildOfClass("Tool")
        local tools = require(script.Parent.ToolService)
        local instance = held and tools.RegisteredTools[held]
        drinking = instance and instance.Drinking == true or false
    end
    local chems = character:FindFirstChild("chems")
    local cough, fire = Voice.StatusStep(voiceState, {
        alive = humanoid.Health > 0,
        sick = localPlayer:GetAttribute("Sickness") == true,
        gas = gas,
        holding = character:GetAttribute("HoldBreathe") == true,
        drinking = drinking,
        intoxicated = chems and chems:FindFirstChild("int") ~= nil,
        burning = character:GetAttribute("Burning") == true or humanoid:FindFirstChild("burning_light") ~= nil or humanoid:FindFirstChild("burning_heavy") ~= nil,
        dreadnought = character:GetAttribute("IsDreadnought") == true or character:FindFirstChild("dreadnought") ~= nil,
    }, os.clock())
    if cough then Voice.Play(character, "cough") end
    if fire then Voice.Play(character, "fire") end
end

local function showEnemyMarker(character, color, symbol)
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local gui = character:FindFirstChild("DebuffMarker")
	if not head or not humanoid or humanoid.Health <= 0 then
		if gui then gui:Destroy() end
		return nil
	end
	if not gui then
		gui = Instance.new("BillboardGui")
		gui.Name = "DebuffMarker"
		gui.AlwaysOnTop = true
		gui.Size = UDim2.fromOffset(32, 32)
		gui.StudsOffset = Vector3.new(0, 2.2, 0)
		local label = Instance.new("TextLabel")
		label.Name = "Icon"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.TextStrokeTransparency = .2
		label.Parent = gui
		gui.Parent = character
	end
	gui.Adornee = head
	gui.Icon.Text = symbol or "\u{25C6}"
	gui.Icon.TextColor3 = color
	return gui
end

local function refreshMark(player)
	local c=player.Character; if not c then return end
	local old=c:FindFirstChild("DebuffHighlight")
	local marker=c:FindFirstChild("DebuffMarker")
	local show=false; local color=Color3.fromRGB(210,35,35); local symbol="\u{25C6}"
	if player:GetAttribute("Spotted") then local source=Players:GetPlayerByUserId(player:GetAttribute("SpottedByUserId") or 0); show=player~=localPlayer and player.Team~=localPlayer.Team and source and source.Team==localPlayer.Team and inPingRange(source) and not setting("HideDangerPings"); if player:GetAttribute("SpottedEnhanced") and player.Team then color=player.Team.TeamColor.Color end end
	local hunterCharacter=localPlayer.Character
    local elite=hunterCharacter and hunterCharacter:GetAttribute("EliteClass")
    local targetHumanoid=c:FindFirstChildOfClass("Humanoid")
    local isHunting = player~=localPlayer and (elite=="GeistTrooper" or elite=="Geist Trooper")
        and player:GetAttribute("Hunted")==true and player:GetAttribute("HuntedByUserId")==localPlayer.UserId
        and targetHumanoid and targetHumanoid.Health>0
    if isHunting and not hunting[player] then popup("hunting_" .. player.UserId, "You are hunting " .. player.DisplayName .. ".", 4) end
    hunting[player] = isHunting or nil
    if isHunting then
        if marker then marker:Destroy() end
        if not old then old=Instance.new("Highlight"); old.Name="DebuffHighlight"; old.Parent=c end
        old.Adornee=c; old.FillTransparency=1
        old.OutlineColor=Color3.fromRGB(90,90,90); old.OutlineTransparency=0.4
        old.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        return
    end
    if old then old:Destroy() end
	if not show then if marker then marker:Destroy() end; return end
	showEnemyMarker(c, color, symbol)
end
local function bind(player) for _,name in {"Spotted","SpottedEnhanced","SpottedByUserId","Hunted","HuntedByUserId"} do player:GetAttributeChangedSignal(name):Connect(function() refreshMark(player); if player==localPlayer then refreshLocal() end end) end; player.CharacterAdded:Connect(function() task.defer(refreshMark,player) end); refreshMark(player) end
function Service.start_module() if started then return end; started=true; localPlayer:GetAttributeChangedSignal("Sickness"):Connect(refreshLocal); refreshLocal(); for _,p in Players:GetPlayers() do bind(p) end; Players.PlayerAdded:Connect(bind); Players.PlayerRemoving:Connect(function(p) hunting[p]=nil end); localPlayer.CharacterAdded:Connect(function() hunted=false; huntGeneration+=1; task.defer(refreshLocal) end)
    local elapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < 0.25 then return end
        elapsed = 0
        updateStatusVoices()
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
