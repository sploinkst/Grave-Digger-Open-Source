local RunService = game:GetService("RunService")

local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)

local ARROW_BUTTON_COLLAPSED = "rbxassetid://9856232200"
local ARROW_BUTTON = "rbxassetid://9856441579"
local LOADING_CIRCLE = "rbxassetid://9921440907"

local LoadingHeader = Roact.Component:extend("LoadingHeader")

function LoadingHeader:init()
	self.loadingRotationBinding, self.updateLoadingRotationBinding = Roact.createBinding(0)

	self.loadingRotationConnection = RunService.Heartbeat:Connect(function()
		self.updateLoadingRotationBinding(self.loadingRotationBinding:getValue() + 5)
	end)
end

function LoadingHeader:render()
	return Roact.createElement("Frame", {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 66),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		ZIndex = 4,
		LayoutOrder = 1,
	}, {
		HugLeft = Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, 0, 0, 66),
			ZIndex = 5,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Margin1 = Roact.createElement("Frame", {
				LayoutOrder = 0,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 1, 0),
			}),
			ArrowButton = Roact.createElement("ImageButton", {
				LayoutOrder = 1,
				AutoButtonColor = false,
				Image = self.props.isCollapsed and ARROW_BUTTON_COLLAPSED or ARROW_BUTTON,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 40, 0, 40),
				[Roact.Event.InputBegan] = function(_, input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						self.props.toggleCollapseClicked()
					end
				end,
			}),
			Margin2 = Roact.createElement("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 1, 0),
			}),
			TitleTimeFrame = Roact.createElement("Frame", {
				LayoutOrder = 3,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.428, 0, 1, 0),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Title = Roact.createElement("TextLabel", {
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 19),
					Font = Enum.Font.GothamBlack,
					TextScaled = true,
					Text = self.props.currentScene or "Loading...",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),
			}),
		}),
		HugRight = Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, 0, 0, 66),
			ZIndex = 5,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			Margin1 = Roact.createElement("Frame", {
				LayoutOrder = 6,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 1, 0),
			}),
			LoadingCircleFrame = Roact.createElement("Frame", {
				LayoutOrder = 5,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 32, 0, 32),
			}, {
				LoadingCircle = Roact.createElement("ImageLabel", {
					Image = LOADING_CIRCLE,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Rotation = self.loadingRotationBinding:map(function(value)
						return value
					end),
				}),
			}),
		}),
	})
end

return LoadingHeader
