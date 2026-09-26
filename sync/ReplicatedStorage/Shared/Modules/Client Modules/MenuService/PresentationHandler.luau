--!strict
-- Legacy main-GUI presentation: player list, alerts, popups and server messages.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Scope = require(script.Parent.Scope)

local module, started = {}, false
local scope
local LocalPlayer = Players.LocalPlayer
local popupSerial, globalSerial = 0, 0
local alertQueue = {}
local alertWorking = false

local function labelText(object: Instance?, value: any)
	if object and (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then
		object.Text = tostring(value or "")
	end
end

local function tween(object: Instance, duration: number, properties)
	local animation = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
	animation:Play()
	return animation
end

local function setFade(root: Instance, transparency: number)
	for _, object in ipairs({root, table.unpack(root:GetDescendants())}) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			object.TextTransparency = transparency
			object.TextStrokeTransparency = transparency
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			object.ImageTransparency = transparency
		end
	end
end

local function tweenFade(root: Instance, duration: number, transparency: number)
	for _, object in ipairs({root, table.unpack(root:GetDescendants())}) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			tween(object, duration, {TextTransparency = transparency, TextStrokeTransparency = transparency})
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			tween(object, duration, {ImageTransparency = transparency})
		end
	end
end

local function playPopup(main: Instance, key: string, message: string, duration: number?)
	local core = main:FindFirstChild("core_game")
	local holder = core and core:FindFirstChild("textpopups")
	local template = holder and holder:FindFirstChild("ex")
	if not holder or not template or not template:IsA("TextLabel") or holder:FindFirstChild(key) then return end
	popupSerial += 1
	local row = template:Clone()
	row.Name = key ~= "" and key or ("popup_" .. popupSerial)
	row.Text, row.Visible, row.TextTransparency, row.TextStrokeTransparency = message, true, 1, 1
	row.Parent = holder
	tween(row, 0.35, {TextTransparency = 0, TextStrokeTransparency = 0})
	task.delay(math.max(0.1, tonumber(duration) or 4), function()
		if not row.Parent then return end
		local out = tween(row, 0.35, {TextTransparency = 1, TextStrokeTransparency = 1})
		out.Completed:Once(function() if row.Parent then row:Destroy() end end)
	end)
end

local function configureAlertTeam(alert: Instance)
	local icons, scroll = alert:FindFirstChild("icons"), alert:FindFirstChild("scroll")
	local empire = LocalPlayer.Team and LocalPlayer.Team.Name == "Golden Empire"
	if icons then
		for _, name in ipairs({"empireleft", "empireright", "nationleft", "nationright"}) do
			local icon = icons:FindFirstChild(name)
			if icon and icon:IsA("GuiObject") then icon.Visible = string.find(name, empire and "empire" or "nation") ~= nil end
		end
	end
	labelText(scroll and scroll:FindFirstChild("toptext"), empire and "QUEEN'S WILL" or "KING'S DECREE")
end

local function drainAlerts(main: Instance)
	if alertWorking or #alertQueue == 0 then return end
	alertWorking = true
	local item = table.remove(alertQueue, 1)
	local template = main:FindFirstChild("alert")
	if not template or not template:IsA("GuiObject") then
		alertWorking = false
		playPopup(main, "alert", item.message, 4)
		task.defer(drainAlerts, main)
		return
	end
	local alert = template:Clone()
	alert.Name, alert.Visible, alert.Parent = "active_alert", true, main
	configureAlertTeam(alert)
	local text, icons, scroll = alert:FindFirstChild("maintext"), alert:FindFirstChild("icons"), alert:FindFirstChild("scroll")
	if text and text:IsA("TextLabel") then text.Text, text.TextTransparency, text.TextStrokeTransparency = item.message, 1, 1 end
	for _, frame in ipairs({icons, scroll}) do
		if frame and frame:IsA("GuiObject") then frame.Size = UDim2.new(0, 0, 0.6, 0); tween(frame, 0.45, {Size = UDim2.new(0.3, 0, 0.6, 0)}) end
	end
	if text and text:IsA("TextLabel") then tween(text, 0.3, {TextTransparency = 0, TextStrokeTransparency = 0}) end
	task.delay(tonumber(item.duration) or 4, function()
		if text and text:IsA("TextLabel") then tween(text, 0.35, {TextTransparency = 1, TextStrokeTransparency = 1}) end
		for _, frame in ipairs({icons, scroll}) do if frame and frame:IsA("GuiObject") then tween(frame, 0.4, {Size = UDim2.new(0, 0, 0.6, 0)}) end end
		task.delay(0.45, function()
			if alert.Parent then alert:Destroy() end
			alertWorking = false
			drainAlerts(main)
		end)
	end)
end

local function showAlert(main: Instance, message: string, category: string?, duration: number?)
	table.insert(alertQueue, {message = message, category = category or "message", duration = duration})
	drainAlerts(main)
end

local function showGlobal(main: Instance, message: string, privateServer: boolean?, duration: number?)
	local frame = main:FindFirstChild("globalmessage")
	local text = frame and frame:FindFirstChild("maintext")
	if not frame or not frame:IsA("GuiObject") or not text then return end
	globalSerial += 1
	local serial = globalSerial
	labelText(text, message)
	local serverText = text:FindFirstChild("servertext")
	labelText(serverText, privateServer and "Private Server Message from Bandit Group" or "Server Message from Solace Coalition")
	if serverText and serverText:IsA("TextLabel") then serverText.TextColor3 = privateServer and Color3.fromRGB(50, 70, 200) or Color3.fromRGB(50, 200, 70) end
	frame.Visible = true
	setFade(frame, 1)
	tweenFade(frame, 0.25, 0)
	task.delay(tonumber(duration) or 15, function()
		if serial ~= globalSerial or not frame.Parent then return end
		tweenFade(frame, 0.35, 1)
		task.delay(0.36, function() if serial == globalSerial and frame.Parent then frame.Visible = false end end)
	end)
end

local function bindMain(main: Instance)
	if scope then scope:Destroy() end
	scope = Scope.new()
	local playerList = main:FindFirstChild("playerlist")
	local template = playerList and playerList:FindFirstChild("ex")
	if template and template:IsA("GuiObject") then template.Visible = false end
	local function refreshPlayerList()
		if not playerList or not template then return end
		for _, listName in {"empirelist", "royallist"} do
			local list = playerList:FindFirstChild(listName)
			if list then for _, row in list:GetChildren() do if row:GetAttribute("MenuServiceRow") then row:Destroy() end end end
		end
		for _, player in Players:GetPlayers() do
			local list = playerList:FindFirstChild(player.Team and player.Team.Name == "Golden Empire" and "empirelist" or "royallist")
			if not list then continue end
			local row = template:Clone(); row.Name = player.Name; row.Visible = true; row:SetAttribute("MenuServiceRow", true); row.Parent = list
			labelText(row:FindFirstChild("playername"), player.DisplayName)
			local rank = row:FindFirstChild("rankbg") and row.rankbg:FindFirstChild("rank")
			local data = player:FindFirstChild("PlayerData"); local profile = data and data:FindFirstChild("PlayerData"); local progress = profile and profile:FindFirstChild("Progression")
			labelText(rank, progress and progress:FindFirstChild("Rank") and progress.Rank.Value or "")
		end
	end
	local showing = false
	local function setList(value)
		showing = value
		if playerList and playerList:IsA("GuiObject") then playerList.Visible = value end
		local darken = main:FindFirstChild("playerlistdarken"); if darken and darken:IsA("GuiObject") then darken.Visible = value end
		if value then refreshPlayerList() end
	end
	setList(false)
	scope:Connect(UserInputService.InputBegan, function(input, processed) if not processed and not UserInputService:GetFocusedTextBox() and (input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.DPadDown) then setList(true) end end)
	scope:Connect(UserInputService.InputEnded, function(input) if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.DPadDown then setList(false) end end)
	scope:Connect(Players.PlayerAdded, function() if showing then refreshPlayerList() end end)
	scope:Connect(Players.PlayerRemoving, function() if showing then task.defer(refreshPlayerList) end end)

	_G.popupmsg = function(key, message, duration) playPopup(main, tostring(key or "message"), tostring(message or ""), duration) end
	_G.gamealert = function(message, category, duration) showAlert(main, tostring(message or ""), category, duration) end
	_G.globalalert = function(message, privateServer, duration) showGlobal(main, tostring(message or ""), privateServer, duration) end
	_G.flash_hitmarker = function()
		local hitmarkers = main:FindFirstChild("core_game") and main.core_game:FindFirstChild("hitmarkers")
		if not hitmarkers then return end
		hitmarkers.Visible = true
		for _, image in hitmarkers:GetDescendants() do if image:IsA("ImageLabel") then image.ImageTransparency = 0; tween(image, 0.35, {ImageTransparency = 1}) end end
		task.delay(0.4, function() if hitmarkers.Parent then hitmarkers.Visible = false end end)
	end

	local events = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events")
	local presentation = events:WaitForChild("Presentation", 15)
	if presentation and presentation:IsA("RemoteEvent") then scope:Connect(presentation.OnClientEvent, function(action, payload, extra)
		payload = type(payload) == "table" and payload or {message = tostring(payload or ""), extra = extra}
		local message = tostring(payload.message or payload.msg or "")
		if action == "alert" then showAlert(main, message, payload.category or payload.core, payload.duration or payload.dur)
		elseif action == "global_alert" then showGlobal(main, message, payload.privateServer == true or payload.extra == true, payload.duration)
		elseif action == "server_message" then playPopup(main, tostring(payload.key or payload.core or "server_message"), message, payload.duration or payload.dur)
		elseif action == "surrender" or action == "send_surrendermessage" then playPopup(main, "surrenderoption", message ~= "" and message or "You are given the option to Surrender for increased Medal Gain.", payload.duration or 5)
		elseif action == "enlistment" or action == "enlistmentmessage" then playPopup(main, "enlistmentoption", message ~= "" and message or "You may Enlist with the opposing side for increased Medal Gain.", payload.duration or 8)
		elseif action == "variant_unlock" or action == "variantunlock" then playPopup(main, "variantunlock", message ~= "" and message or ((payload.name or "Weapon") .. " Modification Acquired."), payload.duration or 4)
		elseif action == "dogtag" or action == "dogtag_got" then playPopup(main, "dogtag", message ~= "" and message or ((payload.name or "Enemy") .. "'s dogtag acquired."), payload.duration or 3)
		elseif action == "trap_triggered" then playPopup(main, "trap_triggered", message ~= "" and message or "Your mantrap has been triggered.", payload.duration or 3) end
	end) end
end

function module.start_module()
	if started then return end
	started = true
	local gui = LocalPlayer:WaitForChild("PlayerGui")
	local function refresh(child) if not child or child.Name == "main" then local main = gui:FindFirstChild("main"); if main then bindMain(main) end end end
	gui.ChildAdded:Connect(refresh); refresh()
end
return module
