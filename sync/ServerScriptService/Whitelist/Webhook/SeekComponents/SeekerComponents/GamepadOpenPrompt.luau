local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RunService = game:GetService("RunService")

local GamepadOpenPrompt = Roact.Component:extend("GamepadOpenPrompt")

function GamepadOpenPrompt:init()
	local timestarted = os.clock()

	self.ageBindingConnection = RunService.Heartbeat:Connect(function()
		if os.clock() - timestarted > 5 then
			self.props.hideGamepadOpenPrompt()

			self.ageBindingConnection:Disconnect()
		end
	end)
end

function GamepadOpenPrompt:render()
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = UDim2.fromScale(0.328, 0.096),
		Size = UDim2.fromOffset(444, 56),
	}, {
		uICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 16),
		}),

		textLabel = Roact.createElement("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "Hold",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(50, 30),
		}),

		uIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		margin1 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 18, 1, 0),
		}),

		lB = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://10066991289",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			Size = UDim2.fromOffset(29, 20),
		}),

		margin2 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Size = UDim2.new(0, 7, 1, 0),
		}),

		margin3 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			Size = UDim2.new(0, 7, 1, 0),
		}),

		plus = Roact.createElement("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "+",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 6,
			Size = UDim2.fromOffset(14, 30),
		}),

		margin4 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 7,
			Size = UDim2.new(0, 7, 1, 0),
		}),

		rB = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://10066992835",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 8,
			Size = UDim2.fromOffset(29, 20),
		}),

		margin5 = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 9,
			Size = UDim2.new(0, 7, 1, 0),
		}),

		endText = Roact.createElement("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "to enter developer tools",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			LayoutOrder = 10,
			Position = UDim2.fromScale(0.378, 0.5),
			Size = UDim2.fromOffset(256, 30),
		}),
	})
end

return GamepadOpenPrompt
