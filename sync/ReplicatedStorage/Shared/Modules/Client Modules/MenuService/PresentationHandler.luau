-- No interface is created here, strictly acts as a controller to port over old code
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Scope = require(script.Parent.Scope)

local module, started = {}, false
local scope

local function labelText(object, value)
	if object and (object:IsA("TextLabel") or object:IsA("TextButton")) then object.Text = tostring(value or "") end
end

local function bindMain(main)
	if scope then scope:Destroy() end
	scope = Scope.new()
	local playerList = main:FindFirstChild("playerlist")
	local template = playerList and playerList:FindFirstChild("ex")
	if template then template.Visible = false end

	local function refreshPlayerList()
		if not playerList or not template then return end
		for _, listName in {"empirelist", "royallist"} do
			local list = playerList:FindFirstChild(listName)
			if list then for _, row in list:GetChildren() do
				if row:GetAttribute("MenuServiceRow") then row:Destroy() end
			end end
		end
		for _, player in Players:GetPlayers() do
			local listName = player.Team and player.Team.Name == "Golden Empire" and "empirelist" or "royallist"
			local list = playerList:FindFirstChild(listName)
			if not list then continue end
			local row = template:Clone()
			row.Name = player.Name; row.Visible = true; row:SetAttribute("MenuServiceRow", true); row.Parent = list
			labelText(row:FindFirstChild("playername"), player.DisplayName)
			local rank = row:FindFirstChild("rankbg") and row.rankbg:FindFirstChild("rank")
			local data = player:FindFirstChild("PlayerData")
			local profile = data and data:FindFirstChild("PlayerData")
			local progress = profile and profile:FindFirstChild("Progression")
			labelText(rank, progress and progress:FindFirstChild("Rank") and progress.Rank.Value or "")
		end
	end

	local showing = false
	local function setList(value)
		showing = value
		if playerList then playerList.Visible = value end
		local darken = main:FindFirstChild("playerlistdarken")
		if darken then darken.Visible = value end
		if value then refreshPlayerList() end
	end
	setList(false)
	scope:Connect(UserInputService.InputBegan, function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.DPadDown then setList(true) end
	end)
	scope:Connect(UserInputService.InputEnded, function(input)
		if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.DPadDown then setList(false) end
	end)
	scope:Connect(Players.PlayerAdded, function() if showing then refreshPlayerList() end end)
	scope:Connect(Players.PlayerRemoving, function() if showing then task.defer(refreshPlayerList) end end)

	_G.popupmsg = function(_, message, duration)
		local alert = main:FindFirstChild("globalmessage")
		local text = alert and alert:FindFirstChild("maintext")
		if not alert or not text then return end
		labelText(text, message); alert.Visible = true
		task.delay(tonumber(duration) or 4, function() if alert.Parent then alert.Visible = false end end)
	end
	_G.flash_hitmarker = function()
		local hitmarkers = main:FindFirstChild("core_game") and main.core_game:FindFirstChild("hitmarkers")
		if not hitmarkers then return end
		hitmarkers.Visible = true
		for _, image in hitmarkers:GetDescendants() do
			if image:IsA("ImageLabel") then
				image.ImageTransparency = 0
				TweenService:Create(image, TweenInfo.new(.35), {ImageTransparency = 1}):Play()
			end
		end
		task.delay(.4, function() if hitmarkers.Parent then hitmarkers.Visible = false end end)
	end
end

function module.start_module()
	if started then return end
	started = true
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local function refresh(child)
		if child and child.Name ~= "main" then return end
		local main = gui:FindFirstChild("main")
		if main then bindMain(main) end
	end
	gui.ChildAdded:Connect(refresh)
	refresh()
end

return module
