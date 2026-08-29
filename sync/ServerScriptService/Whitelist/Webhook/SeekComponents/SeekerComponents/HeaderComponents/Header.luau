local Roact = require(script.Parent.Parent.Parent.Parent.Packages.Roact)

local GRAB_BUTTON = "rbxassetid://9856597911"
local ARROW_BUTTON_COLLAPSED = "rbxassetid://9856232200"
local ARROW_BUTTON = "rbxassetid://9856441579"
local SKIP_RIGHT_BUTTON = "rbxassetid://9856388208"
local SKIP_LEFT_BUTTON = "rbxassetid://9856382679"
local PAUSE_BUTTON = "rbxassetid://9856360167"
local UNPAUSE_BUTTON = "rbxassetid://10391710632"

local Header = Roact.Component:extend("Header")

function Header:render()
	return Roact.createElement("Frame", {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 66),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		ZIndex = 4,
		LayoutOrder = 1,
	}, {
		GrabButton = Roact.createElement("TextButton", {
			Selectable = false,
			AutoButtonColor = false,
			Text = "",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = self.props.isDragging and UDim2.new(1, 0, 0, 120) or UDim2.new(1, 0, 0, 20),
			ZIndex = 5,
			[Roact.Event.InputBegan] = function(_, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					self.props.draggingBegan()
				end
			end,
			[Roact.Event.InputEnded] = function(_, input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					self.props.draggingEnded()
				end
			end,
		}),
		GrabButtonIcon = Roact.createElement("ImageLabel", {
			Image = GRAB_BUTTON,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 367, 0, 10),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			ZIndex = 6,
		}),
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
				[Roact.Event.Activated] = function(_, input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.Gamepad1
					then
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
					Text = self.props.currentScene and self.props.formatSceneNameText(self.props.currentScene)
						or self.props.isLoading and "Loading Scene"
						or "Seek Bar",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),
				Margin1 = Roact.createElement("Frame", {
					LayoutOrder = 2,
					Visible = not self.props.isCollapsed,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 2),
				}),
				Time = Roact.createElement("Frame", {
					LayoutOrder = 3,
					Visible = not self.props.isCollapsed,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					Time1 = Roact.createElement("TextLabel", {
						LayoutOrder = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 60, 1, 0),
						Font = Enum.Font.GothamBlack,
						TextScaled = false,
						TextSize = 13,
						Text = self.props.timeBinding:map(function(value)
							return self.props.formatTime(value)
						end),
						TextXAlignment = Enum.TextXAlignment.Left,
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
						Size = UDim2.new(0, 7, 1, 0),
						Font = Enum.Font.GothamBlack,
						TextScaled = false,
						TextSize = 13,
						Text = "/",
						TextXAlignment = Enum.TextXAlignment.Left,
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
						Size = UDim2.new(0, 60, 1, 0),
						Font = Enum.Font.GothamBlack,
						TextScaled = false,
						TextSize = 13,
						Text = self.props.sceneLength and self.props.formatTime(self.props.sceneLength)
							or self.props.formatTime(0),
						TextTransparency = 0.25,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
					}),
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
			SkipRight15 = Roact.createElement("ImageButton", {
				LayoutOrder = 5,
				AutoButtonColor = false,
				Image = SKIP_RIGHT_BUTTON,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 32, 0, 32),
				[Roact.Event.Activated] = self.props.currentScene and not self.props.isLoading and function()
					self.props.skipTime(15)
				end,
			}),
			Margin2 = Roact.createElement("Frame", {
				LayoutOrder = 4,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 1, 0),
			}),
			SkipLeft15 = Roact.createElement("ImageButton", {
				LayoutOrder = 3,
				AutoButtonColor = false,
				Image = SKIP_LEFT_BUTTON,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 32, 0, 32),
				[Roact.Event.Activated] = self.props.currentScene and not self.props.isLoading and function()
					self.props.skipTime(-15)
				end,
			}),
			Margin3 = Roact.createElement("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 12, 1, 0),
			}),
			Pause = Roact.createElement("ImageButton", {
				LayoutOrder = 1,
				Image = self.props.isPaused and UNPAUSE_BUTTON or PAUSE_BUTTON,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 32, 0, 32),
				[Roact.Event.Activated] = self.props.currentScene and not self.props.isLoading and function()
					if self.props.isPaused then
						self.props.unpause()
					else
						self.props.pause()
					end
				end,
			}),
		}),
	})
end

return Header
