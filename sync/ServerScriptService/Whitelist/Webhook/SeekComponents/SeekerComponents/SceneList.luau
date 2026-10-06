local Roact = require(script.Parent.Parent.Parent.Packages.Roact)

local PLAY_ICON = "rbxassetid://9903258563"

local SceneListGui = Roact.Component:extend("SceneListGui")

function SceneListGui:render()
	local children = {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for _, scene in pairs(self.props.scenes) do
		children[scene.Name] = Roact.createElement("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.new(1, 0, 0, 60),
			[Roact.Event.Activated] = function()
				self.props.unpause()
				self.props.onSceneSelected(scene.Name)
			end,
		}, {
			Divider = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 0.9,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.new(1, -24, 0, 1),
				BorderSizePixel = 0,
			}),
			SceneName = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(0, 254, 0, 19),
				Font = Enum.Font.GothamMedium,
				TextSize = 19,
				TextTransparency = 0.3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = scene.Name and self.props.formatSceneNameText(scene.Name),
			}),
			HugRight = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 5,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Margin1 = Roact.createElement("Frame", {
					LayoutOrder = 4,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 12, 1, 0),
				}),
				SceneTime = Roact.createElement("TextLabel", {
					LayoutOrder = 3,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0, 84, 0, 19),
					Font = Enum.Font.GothamMedium,
					TextSize = 19,
					TextTransparency = 0.3,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Text = self.props.formatTime(scene.Length),
				}),
				Margin2 = Roact.createElement("Frame", {
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 12, 1, 0),
				}),
				PlayIcon = scene.Name == self.props.currentScene and Roact.createElement("ImageLabel", {
					LayoutOrder = 1,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 16, 0, 16),
					Image = PLAY_ICON,
				}),
			}),
		})
	end

	local numberOfChildren = 0

	for _, _ in pairs(children) do
		numberOfChildren += 1
	end

	return Roact.createElement("ScrollingFrame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0.403, 40),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 60 * numberOfChildren),
		Selectable = false,
	}, children)
end

return SceneListGui
