local Roact = require(script.Parent.Roact.Roact)
local RunService = game:GetService("RunService")

local GamepadClosePrompt = Roact.Component:extend("GamepadClosePrompt")

function GamepadClosePrompt:init()
	local timestarted = os.clock()

	self.ageBindingConnection = RunService.Heartbeat:Connect(function()
		if os.clock() - timestarted > 5 then
			self.props.hideGamepadClosePrompt()

			self.ageBindingConnection:Disconnect()
		end
	end)
end

function GamepadClosePrompt:render()
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0.5, 0, 0, 22),
		Size = UDim2.fromOffset(377, 56),
	}, {
		uICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),

		uIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		hold = Roact.createElement("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "Press",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 20,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.374, 0.0536),
			Size = UDim2.fromOffset(57, 30),
		}),

		b = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://10295422882",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Position = UDim2.fromScale(0.177, 0.321),
			Size = UDim2.fromOffset(32, 32),
		}),

		toEnter = Roact.createElement("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "to exit developer tools",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 20,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 9,
			Position = UDim2.fromScale(0.374, 0.0536),
			Size = UDim2.fromOffset(240, 30),
		}),

		margin = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.new(0, 8, 1, 0),
		}),

		margin1 = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			Size = UDim2.new(0, 8, 1, 0),
		}),
	})
end

return GamepadClosePrompt
