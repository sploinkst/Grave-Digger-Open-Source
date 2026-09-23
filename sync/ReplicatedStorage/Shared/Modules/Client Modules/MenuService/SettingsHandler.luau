local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local UI = require(script.Parent.UI)
local module, started = {}, false

local function text(object, value)
	if object and (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then object.Text = tostring(value) end
end

function module.start_module(menu)
	if started then return end
	started = true
	local player = Players.LocalPlayer
	local settings = player:WaitForChild("PlayerData"):WaitForChild("Settings Data")
	local events = ReplicatedStorage.Shared.Library.Events
	UI.Mount("Settings", function(scene, scope)
		local frame = scene:FindFirstChild("settingsframe")
		if not frame then return end
		local keyList, optionList = frame:FindFirstChild("keybinds"), frame:FindFirstChild("settings")
		local keyTemplate = keyList and keyList:FindFirstChild("example")
		local optionTemplate = optionList and optionList:FindFirstChild("example")
		local categoryTemplate = optionList and optionList:FindFirstChild("category")
		if keyTemplate then keyTemplate.Visible = false end
		if optionTemplate then optionTemplate.Visible = false end
		if categoryTemplate then categoryTemplate.Visible = false end

		local capturing, captureRefresh
		local function stopCapture()
			capturing = nil
			player:SetAttribute("RebindingInput", false)
			if captureRefresh then captureRefresh() end
			captureRefresh = nil
		end
		scope:Own(stopCapture)
		local binds = settings:FindFirstChild("Inputs") and settings.Inputs:FindFirstChild("Binds")
		if binds and keyTemplate and keyList then
			for _, bind in binds:GetChildren() do
				local current = bind:FindFirstChild("Current")
				if not current then continue end
				local row = UI.Clone(keyTemplate, keyList, scope, bind.Name)
				local button, label = row:FindFirstChild("button"), row:FindFirstChild("label")
				local function refresh()
					text(label, bind.Name)
					text(button, capturing == bind and "PRESS A KEY" or current.Value)
				end
				if button and button:IsA("GuiButton") then
					scope:Connect(button.Activated, function()
						stopCapture(); capturing, captureRefresh = bind, refresh
						player:SetAttribute("RebindingInput", true); refresh()
					end)
				end
				scope:Connect(current.Changed, refresh); refresh()
			end
		end
		scope:Connect(Input.InputBegan, function(input)
			if not capturing or input.KeyCode == Enum.KeyCode.Unknown then return end
			if input.KeyCode == Enum.KeyCode.Escape then stopCapture() return end
			local name = capturing.Name
			local key = input.KeyCode == Enum.KeyCode.Delete and "None" or input.KeyCode.Name
			stopCapture(); events.InputChange:FireServer(name, key)
		end)

		if optionTemplate and optionList then
			for _, category in settings:GetChildren() do
				if category.Name == "Inputs" then continue end
				if categoryTemplate then
					local heading = UI.Clone(categoryTemplate, optionList, scope, category.Name .. "Category")
					text(heading and heading:FindFirstChild("title"), string.upper(category.Name))
				end
				for _, setting in category:GetChildren() do
					local current = setting:FindFirstChild("Current")
					if not current or not current:IsA("BoolValue") then continue end
					local row = UI.Clone(optionTemplate, optionList, scope, setting.Name)
					local button = row and row:FindFirstChild("settingsframe")
					local display = setting:FindFirstChild("DisplayName")
					local function refresh()
						text(row and row:FindFirstChild("label"), display and display.Value or setting.Name)
						text(button and button:FindFirstChild("label"), current.Value and "ON" or "OFF")
						UI.Selected(button, current.Value)
					end
					if button and button:IsA("GuiButton") then scope:Connect(button.Activated, function()
						events.SettingChange:FireServer(category.Name, setting.Name, not current.Value)
					end) end
					scope:Connect(current.Changed, refresh); refresh()
				end
			end
		end

		local function sensitivity(path, settingName)
			local box, folder = UI.Find(frame, path), settings:FindFirstChild("Sensitivity")
			local setting = folder and folder:FindFirstChild(settingName)
			local current = setting and setting:FindFirstChild("Current")
			if not box or not box:IsA("TextBox") or not current then return end
			box.Text = tostring(current.Value)
			scope:Connect(box.FocusLost, function()
				local value = tonumber(box.Text)
				if value then events.SettingChange:FireServer("Sensitivity", settingName, value) end
				box.Text = tostring(current.Value)
			end)
			scope:Connect(current.Changed, function() box.Text = tostring(current.Value) end)
		end
		sensitivity("aim_sens/inputbox", "AimSensitivity")
		sensitivity("scope_sens/inputbox", "ScopeSensitivity")
		UI.Bind(scope, frame, "playtut", function() if menu.PlayTutorial then menu.PlayTutorial() end end)
	end)
end
return module
