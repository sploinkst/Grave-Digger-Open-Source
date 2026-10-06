local UserInputService = game:GetService("UserInputService")

local Roact = require(script.Parent.Roact.Roact)

local SEEK_BAR_IMAGE = "rbxassetid://9848284952"
local DRAG_BUTTON = "rbxassetid://9848422708"

local SeekBar = Roact.Component:extend("SeekBar")

function SeekBar:render()
	return Roact.createElement("ImageButton", {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(0, 66),
		[Roact.Ref] = self.props.seekBarRef,
		[Roact.Event.InputBegan] = self.props.currentScene and not self.props.isLoading and function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.props.scrubbingBegan()
				self.props.updateSeekBar(input)
			end
		end,
		[Roact.Event.InputEnded] = self.props.currentScene and not self.props.isLoading and function(_, input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.props.scrubbingEnded()
			end
		end,
		LayoutOrder = 2,
	}, {
		MobileTouchBox = UserInputService.TouchEnabled and Roact.createElement("ImageButton", {
			Selectable = false,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 10,
			[Roact.Event.InputBegan] = function(_, input)
				if input.UserInputType == Enum.UserInputType.Touch then
					self.props.scrubbingBegan()
					self.props.updateSeekBar(input)
				end
			end,
			[Roact.Event.InputEnded] = function(_, input)
				if input.UserInputType == Enum.UserInputType.Touch then
					self.props.scrubbingEnded()
				end
			end,
		}),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = self.props.isCollapsed and UDim.new(0, 0) or UDim.new(0, 16),
		}),
		SeekBarBackground = Roact.createElement("ImageLabel", {
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 74),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = SEEK_BAR_IMAGE,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.75,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(0, -66),
			ZIndex = 1,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = self.props.isCollapsed and UDim.new(0, 0) or UDim.new(0, 16),
			}),
		}),
		SeekBarFill = Roact.createElement("ImageLabel", {
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 74),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Image = SEEK_BAR_IMAGE,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(0, -66),
			ZIndex = 2,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = self.props.isCollapsed and UDim.new(0, 0) or UDim.new(0, 16),
			}),
			Clipping = Roact.createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.001, 0),
					NumberSequenceKeypoint.new(0.002, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Offset = self.props.timeBinding:map(function(value)
					local range = math.clamp(value / (self.props.sceneLength or math.huge), 0, 1)

					return Vector2.new(range, 0)
				end),
			}),
		}),
		SeekBarDragButton = Roact.createElement("ImageLabel", {
			Image = DRAG_BUTTON,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(16, 16),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = self.props.timeBinding:map(function(value)
				return UDim2.new(value / (self.props.sceneLength or math.huge), -8, 0.5, 0)
			end),
			ZIndex = 3,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
	})
end

return SeekBar
