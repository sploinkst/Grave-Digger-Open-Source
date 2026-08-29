local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)

local ScrubbingHeader = Roact.Component:extend("ScrubbingHeader")

function ScrubbingHeader:render()
	return Roact.createElement("Frame", {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 66),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		ZIndex = 4,
		LayoutOrder = 1,
	}, {
		Time = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Time1 = Roact.createElement("TextLabel", {
				LayoutOrder = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 120, 0, 29),
				Font = Enum.Font.GothamBlack,
				TextScaled = false,
				TextSize = 24,
				Text = self.props.timeBinding:map(function(value)
					return self.props.formatTime(value)
				end),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			Margin1 = Roact.createElement("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 2, 1, 0),
			}),
			Time2 = Roact.createElement("TextLabel", {
				LayoutOrder = 3,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 14, 0, 29),
				Font = Enum.Font.GothamBlack,
				TextScaled = false,
				TextSize = 24,
				Text = "/",
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			Margin2 = Roact.createElement("Frame", {
				LayoutOrder = 4,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 2, 1, 0),
			}),
			Time3 = Roact.createElement("TextLabel", {
				LayoutOrder = 5,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 120, 0, 29),
				Font = Enum.Font.GothamBlack,
				TextScaled = false,
				TextSize = 24,
				Text = self.props.sceneLength and self.props.formatTime(self.props.sceneLength)
					or self.props.formatTime(0),
				TextTransparency = 0.25,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		}),
	})
end

return ScrubbingHeader
