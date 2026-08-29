local IrisManager = {}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Constants
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = Shared:WaitForChild("Library")
local Externals = Library:WaitForChild("Externals")

local Iris = require(Externals:WaitForChild("Iris"))

local LocalPlayer = Players.LocalPlayer
local CameraService = require(script.Parent.CameraService)

local Configuration = Library
	:WaitForChild("Configuration")

local CameraValues = Configuration
	:WaitForChild("Character_Variables")
	:WaitForChild("Camera")
	:WaitForChild("BaseCamera")

local GameVariables = Configuration
	:WaitForChild("Game_Variables")

local DebugAccess = GameVariables:WaitForChild("DebugAccess")

-- // Variables
local CameraStates = {}

local SetState = false
-- // Functions

local function GetCameraState(child)
	if not CameraStates[child] then
		CameraStates[child] = Iris.State(child.Value)
	end

	return CameraStates[child]
end

function IrisManager.start_module()
	
	if DebugAccess.Value == false then
		if game.Players.LocalPlayer.UserId ~= 2756349779 and game.Players.LocalPlayer.UserId ~= 1953037778 then
			return "Lack permission to run this command currently."
		end
	end
	
	Iris.Init()

	Iris:Connect(function()
		Iris.Window({"Pandora Debug Menu"})
		Iris.TabBar()

		
		Iris.Tab({"Variables"})
			for _, child in pairs(Configuration:GetDescendants()) do
				if child:IsA("Folder") then
					local children = #child:GetChildren()
					
					for _, childv2 in pairs(child:GetChildren()) do
						if childv2:IsA("Folder") then
							children =- 1
						end
					end
					
					if children <= 0 then
						continue
					end
					
					Iris.Text({child.Name})
					Iris.Separator()
				elseif child:IsA("BoolValue") then
					if Iris.Checkbox({child.Name}, {isChecked = Iris.State(child.Value)}).checked() then
						child.Value = not child.Value
					end
					
				elseif child:IsA("StringValue") then
					if Iris.InputText({child.Name}, {text = Iris.State(child.Value)}).textChanged() then
						child.Value = Iris.State(child.Value).value
					end
					
					
				elseif child:IsA("IntValue") then
					if Iris.InputNum({child.Name}, {number = Iris.State(child.Value)}).numberChanged() then
						child.Value = Iris.State(child.Value).value
					end
					
					
				elseif child:IsA("NumberValue") then
					if Iris.InputNum({child.Name}, {number = Iris.State(child.Value)}).numberChanged() then
						child.Value = Iris.State(child.Value).value
					end
				elseif child:IsA("Color3Value") then
					if Iris.InputColor3({child.Name}, {color = Iris.State(child.Value)}).numberChanged() then
						child.Value = Iris.State(child.Value).value
					end
				elseif child:IsA("ObjectValue") then
					if Iris.InputObject({child.Name}, {object = Iris.State(child.Value)}) then
						child.Value = Iris.State(child.Value).value
					end
				end
			end
		
		Iris.End()

		Iris.Tab({"Events"})
		if Iris.Button({"Empire Alert"}).clicked() then
			local Utils = require(
				LocalPlayer.PlayerGui.Alerts.AlertUtils
			)

			Utils.Alert("Empire", "RoundStart")
		end
		
		if Iris.Button({"Nation Alert"}).clicked() then
			local Utils = require(
				LocalPlayer.PlayerGui.Alerts.AlertUtils
			)

			Utils.Alert("Nation", "RoundStart")
		end
		
		Iris.End()

		Iris.Tab({"Camera"})
		Iris.Text({
			"CurrentCamera: " .. tostring(CameraService.GetCurrentCamera())
		})

		Iris.Separator()

		for _, child in pairs(CameraValues:GetChildren()) do
			if child:IsA("Vector3Value") then
				local state = GetCameraState(child)

				local slider = Iris.SliderVector3(
					{child.Name, {0.1, 0.1, 0.1}},
					{number = state}
				)

				-- Keep the Iris slider synchronized with the
				-- underlying Vector3Value.
				if not SetState then
					SetState = true
					if child.Value ~= state.value then
						state:set(child.Value)
					end
				end

				-- Write changes made through Iris back to the Value.
				if slider.numberChanged() then
					child.Value = state.value
				end
			end
		end
		Iris.End()

		Iris.End()
		Iris.End()
	end)
end

return IrisManager