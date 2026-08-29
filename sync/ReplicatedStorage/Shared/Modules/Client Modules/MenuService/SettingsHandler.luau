local module = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService 		= game:GetService("UserInputService")
local Players 			= game:GetService("Players")

-- // Constants
-- UI
local LocalPlayer = nil
local PlayerData = nil
local SettingsData = nil
local InputsData = nil 

local PlayerGui = nil 
local MenuScenes = nil 
local SettingsUI  = nil 

local KeybindsScrollingFrame = nil 
local KeybindsExample = nil 

local SettingsScrolling = nil 
local CategoryExample = nil 
local SettingsExample = nil 

local MouseHover = nil

local MouseConn = nil
local Mouse:Mouse = nil
-- Event
local InputChange = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("InputChange")
local SettingChange = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("SettingChange")

local function CreateKeybinds()
	for _, child in pairs(InputsData.Binds:GetChildren()) do
		local ExampleClone = KeybindsExample:Clone()
		ExampleClone.Parent = KeybindsScrollingFrame
		ExampleClone.Name = child.Name
		ExampleClone:FindFirstChild("label").Text = child.Name .. " - Default [" .. child.Default.Value .. "]"
		ExampleClone:FindFirstChild("button"):FindFirstChild("label").Text = child.Current.Value
		ExampleClone.Visible = true 
		
		ExampleClone.button.Activated:Connect(function()
			ExampleClone:FindFirstChild("button"):FindFirstChild("label").Text = "Input a key or press [Delete] to Unbound"
			
			local inputConn

			inputConn = InputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

				ExampleClone.button.label.Text = input.KeyCode.Name
				InputChange:FireServer(child.Name, input.KeyCode.Name)

				inputConn:Disconnect()
			end)
		end)
	end
end

local function CreateSettings()
	for _, category in pairs(SettingsData:GetChildren()) do
		if category.Name == "Inputs" then continue end
		local ExampleClone = CategoryExample:Clone()
		ExampleClone.Parent = CategoryExample.Parent
		ExampleClone.Name = category.Name
		ExampleClone:FindFirstChild("title").Text = category.Name
		ExampleClone.Visible = true
		ExampleClone.LayoutOrder = #CategoryExample.Parent:GetChildren() + 1
		
		for _, setting in pairs(category:GetChildren()) do
			if not setting:FindFirstChild("DisplayName") then warn("No displayName found for:", setting.Name) continue end
			
			local SettingClone = SettingsExample:Clone()
			SettingClone.Parent = SettingsExample.Parent
			SettingClone:FindFirstChild("label").Text = setting:FindFirstChild("DisplayName").Value
			
			if setting:FindFirstChild("DisplayText") then
				SettingClone:FindFirstChild("label").Text = SettingClone:FindFirstChild("label").Text .. " (?)"
			end
			
			SettingClone.Visible = true
			SettingClone.LayoutOrder = #CategoryExample.Parent:GetChildren() + 1
			
			if setting:FindFirstChild("Current").Value == false then
				SettingClone.settingsframe.label.Text = "OFF"
				SettingClone.settingsframe.ImageColor3 = Color3.fromRGB(0, 0, 0)
				SettingClone.settingsframe.label.TextColor3 = Color3.fromRGB(255,255,255)
			else
				SettingClone.settingsframe.label.Text = "ON"
				SettingClone.settingsframe.ImageColor3 = Color3.fromRGB(255,255,255)
				SettingClone.settingsframe.label.TextColor3 = Color3.fromRGB(0,0,0)
			end
			
			SettingClone.settingsframe.Activated:Connect(function()
				if setting:FindFirstChild("Current").Value == false then
					SettingClone.settingsframe.label.Text = "ON"
					SettingChange:FireServer(category.Name, setting.Name, true)
					SettingClone.settingsframe.ImageColor3 = Color3.fromRGB(255,255,255)
					SettingClone.settingsframe.label.TextColor3 = Color3.fromRGB(0,0,0)
				else
					SettingClone.settingsframe.label.Text = "OFF"
					SettingChange:FireServer(category.Name, setting.Name, false)
					SettingClone.settingsframe.ImageColor3 = Color3.fromRGB(0, 0, 0)
					SettingClone.settingsframe.label.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end)

			SettingClone.label.MouseEnter:Connect(function()
				print("Hovering over:", setting.Name)

				local displayText = setting:FindFirstChild("DisplayText")
				if not displayText then
					print("No DisplayText")
					return
				end

				MouseHover.Visible = true
				MouseHover.Text = displayText.Value

				local function UpdatePosition()
					local mousePos = InputService:GetMouseLocation()
					MouseHover.Position = UDim2.fromOffset(
						mousePos.X, -- offset so it isn't directly under the cursor
						mousePos.Y
					)
				end

				UpdatePosition()

				if MouseConn then
					MouseConn:Disconnect()
				end

				MouseConn = InputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						UpdatePosition()
					end
				end)
			end)

			SettingClone.label.MouseLeave:Connect(function()
				MouseHover.Visible = false

				if MouseConn then
					MouseConn:Disconnect()
					MouseConn = nil
				end
			end)
		end
	end
end

function module.start_module()
	LocalPlayer 				= Players.LocalPlayer
	PlayerData 					= LocalPlayer:WaitForChild("PlayerData")
	SettingsData 				= PlayerData:WaitForChild("Settings Data")
	InputsData 					= SettingsData:WaitForChild("Inputs")
	
	PlayerGui					= LocalPlayer.PlayerGui
	MenuScenes					= PlayerGui:WaitForChild("Menu_Scenes")
	SettingsUI					= MenuScenes:WaitForChild("Settings").settingsframe
	
	KeybindsScrollingFrame		= SettingsUI.keybinds
	KeybindsExample				= KeybindsScrollingFrame.example
	
	SettingsScrolling			= SettingsUI.settings
	CategoryExample				= SettingsScrolling.category
	SettingsExample				= SettingsScrolling.example
	
	MouseHover					= SettingsUI.Parent.MouseHover
	
	Mouse						= LocalPlayer:GetMouse()
	CreateKeybinds()
	CreateSettings()
end

return module
