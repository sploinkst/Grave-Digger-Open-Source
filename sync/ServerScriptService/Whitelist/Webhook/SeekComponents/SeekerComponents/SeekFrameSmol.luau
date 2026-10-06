local Roact = require(script.Parent.Parent.Parent.Packages.Roact)

local RIGHT_SIDE_FRAME = "rbxassetid://9921794212"
local LEFT_SIDE_FRAME = "rbxassetid://9921796518"
local PLAY_ICON = "rbxassetid://9903258563"
local PROGRESS_FRAME = "rbxassetid://9903309611"
local LEFT_PROGRESS_CIRCLE = "rbxassetid://9903467430"
local RIGHT_PROGRESS_CIRCLE = "rbxassetid://9903469709"

local SeekFrameSmol = Roact.Component:extend("SeekFrameSmol")

function SeekFrameSmol:render()
	if self.props.screenGuiRef and self.props.screenGuiRef:getValue() == nil then
		return
	end

	local currentPosition = self.props.draggingPosition:getValue()
	local screenGui = self.props.screenGuiRef:getValue()
	local screenSize = screenGui.AbsoluteSize
	local offsetDraggingPosition = Vector2.new(currentPosition.X * screenSize.X, currentPosition.Y * screenSize.Y)
	local position = nil
	local anchorPoint = nil
	local image = nil

	if offsetDraggingPosition.X >= screenSize.X / 2 then
		position = UDim2.new(1, 0, 0, offsetDraggingPosition.Y)
		anchorPoint = Vector2.new(1, 0.5)
		image = RIGHT_SIDE_FRAME
	else
		position = UDim2.new(0, 0, 0, offsetDraggingPosition.Y)
		anchorPoint = Vector2.new(0, 0.5)
		image = LEFT_SIDE_FRAME
	end

	return Roact.createElement("ImageButton", {
		Image = image,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(60, 60),
		ImageTransparency = 0.25,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		AnchorPoint = anchorPoint,
		Position = position,
		[Roact.Event.InputBegan] = function(_, input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self.props.setFrameNotTiny()

				if screenGui then
					screenGui.SeekFrame.Position = UDim2.fromScale(0.5, 0.5)
				end

				self.props.updateDraggingPosition(Vector2.new(0.5, 0.5))
			end
		end,
	}, {
		PlayIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(20, 20),
			Image = PLAY_ICON,
			ImageTransparency = 0,
			ZIndex = 5,
		}),
		ProgressFrame = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(32, 32),
			Image = PROGRESS_FRAME,
			ImageTransparency = 0.75,
			ZIndex = 2,
		}),
		LeftProgressCircle = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 32),
			Image = LEFT_PROGRESS_CIRCLE,
			ZIndex = 3,
			Visible = self.props.timeBinding:map(function(value)
				if not value then
					return false
				end

				if not self.props.sceneLength then
					return false
				end

				local progress = value / self.props.sceneLength
				local isOverHalf = progress >= 0.5

				return isOverHalf
			end),
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Offset = Vector2.new(0.5, 0),
				Rotation = self.props.timeBinding:map(function(value)
					if not value then
						return 0
					end

					if not self.props.sceneLength then
						return 0
					end

					local progress = value / self.props.sceneLength
					local gradientRotation = progress * 360

					return gradientRotation
				end),
				Enabled = self.props.timeBinding:map(function(value)
					if not value then
						return false
					end

					if not self.props.sceneLength then
						return false
					end

					local progress = value / self.props.sceneLength
					local isOverHalf = progress >= 0.5

					return isOverHalf
				end),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.49, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
		RightProgressCircle = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 32),
			Image = RIGHT_PROGRESS_CIRCLE,

			ZIndex = 3,
		}, {
			UIGradient = Roact.createElement("UIGradient", {
				Offset = Vector2.new(-0.5, 0),
				Rotation = self.props.timeBinding:map(function(value)
					if not value then
						return 0
					end

					if not self.props.sceneLength then
						return 0
					end

					local progress = value / self.props.sceneLength
					local gradientRotation = progress * 360

					return gradientRotation
				end),
				Enabled = self.props.timeBinding:map(function(value)
					if not value then
						return false
					end

					if not self.props.sceneLength then
						return false
					end

					local progress = value / self.props.sceneLength
					local isOverHalf = progress >= 0.5

					return not isOverHalf
				end),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.49, 0),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}),
	})
end

return SeekFrameSmol
