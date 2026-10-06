local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local BaseService = game:GetService('Workspace')
local Roact = require(script.Parent.Roact.Roact)
local SeekBar
local Header
local LoadingHeader
local ScrubbingHeader
local SceneList
local SmallSeekFrame
if not Roact then
	SeekBar = require(script.Parent.SeekBar)
	Header = require(script.Parent.HeaderComponents.Header)
	LoadingHeader = require(script.Parent.HeaderComponents.LoadingHeader)
	ScrubbingHeader = require(script.Parent.HeaderComponents.ScrubbingHeader)
	SceneList = require(script.Parent.SceneList)
	SmallSeekFrame = require(script.Parent.SeekFrameSmol)
end
local FRAME_DATA = {}
local Roact_ = script.Parent.Roact
local SEEKFRAME_MIN_WIDTH = 367
local SEEKFRAME_MAX_WIDTH = 600
local SCREEN_WIDTH_THRESHOLD = 800
local EXPANDED_HEIGHT = 258
local COLLAPSED_HEIGHT = 74
local lib = 'Roact'

local SeekFrame = Roact.Component:extend("SeekFrame")

function SeekFrame:init()
	local initialTime = self.props.timeValue and self.props.timeValue.Value or 0
	self.timeBinding, self.updateTimeBinding = Roact.createBinding(initialTime)

	if self.props.timeValue then
		self.timeValueConnection = self.props.timeValue.Changed:Connect(self.updateTimeBinding)
	end

	self.previewTimeBinding, self.updatePreviewTimeBinding = Roact.createBinding(0)
	self.seekBarRef = Roact.createRef()
	self.timeTextBoxRef = Roact.createRef()

	self.draggingPosition, self.updateDraggingPosition = Roact.createBinding(Vector2.new(0.5, 0.7))

	function self.updateSeekBar(input)
		if self.props.isScrubbing and self.props.sceneLength and not self.props.isSettingTimeManually then
			local seekBar = self.seekBarRef:getValue()

			if seekBar then
				local ratio = math.clamp((input.Position.X - seekBar.AbsolutePosition.X) / seekBar.AbsoluteSize.X, 0, 1)
				self.updatePreviewTimeBinding(ratio * (self.props.sceneLength - 2))
			end
		elseif self.props.isDragging then
			local screenGui = self.props.screenGuiRef:getValue()
			if screenGui then
				local sceenGuiSize = screenGui.AbsoluteSize
				local value = input.Position
				local xScale = value.X / sceenGuiSize.X
				local yScale = value.Y / sceenGuiSize.Y

				self.updateDraggingPosition(Vector2.new(xScale, yScale))
			end
		end
	end

	self.inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.updateSeekBar(input)
		end
	end)

	-- there are times where InputEnded doesn't fire from the drag button so this catches it
	self.backupReleaseDragging = UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.draggingEnded()
		end
	end)

	self.manualInputTimeTextConnection = RunService.Heartbeat:Connect(function()
		if self.props.isSettingTimeManually and self.props.isScrubbing then
			local textBox = self.timeTextBoxRef:getValue()
			local seconds = self.props.unformatTime(textBox.Text)

			if seconds then
				seconds = math.clamp(seconds, 0, self.props.sceneLength)
				self.updatePreviewTimeBinding(seconds)
			end
		end

		if self.props.isScrubbing then
			self.scrubbingStep()
		end
	end)

	if UserInputService.GamepadEnabled then
		self.updateGamepadPreview = RunService.Heartbeat:Connect(function()
			local seekBar = self.seekBarRef:getValue()

			if GuiService.SelectedObject == self.seekBarRef:getValue() and seekBar and self.props.sceneLength then
				if self.thumbstickOffset ~= 0 and not self.props.isScrubbing then
					self.scrubbingBegan()
				elseif self.thumbstickOffset == 0 and self.props.isScrubbing then
					self.scrubbingEnded()
				end

				if self.props.isScrubbing then
					local newTime = math.clamp(
						self.timeBinding:getValue() + self.thumbstickOffset,
						0,
						self.props.sceneLength
					)

					self.updatePreviewTimeBinding(newTime)

					self.scrubbingStep()
				end
			end
		end)

		self.gamepadJoystick = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				if input.KeyCode == Enum.KeyCode.Thumbstick1 then
					if GuiService.SelectedObject == self.seekBarRef:getValue() then
						self.lastThumbstickChange = os.clock()

						local offset = input.Position.X

						if math.abs(offset) < 0.5 then
							self.thumbstickOffset = 0
						elseif offset > 0 then
							self.thumbstickOffset = 1
						elseif offset < 0 then
							self.thumbstickOffset = -1
						end
					end
				end
			end
		end)
	end

	function self.draggingBegan()
		self.props.onDraggingBegan()
	end

	function self.draggingEnded()
		self.props.onDraggingEnded()

		local screenGui = self.props.screenGuiRef:getValue()
		local screenSize = screenGui.AbsoluteSize
		local draggingPosition = self.draggingPosition:getValue()
		local offsetDraggingPosition = Vector2.new(draggingPosition.X * screenSize.X, draggingPosition.Y * screenSize.Y)
		local threshold = 50

		if offsetDraggingPosition.X >= (screenSize.X - threshold) or offsetDraggingPosition.X <= threshold then
			self.props.setFrameTiny()
		else
			self.props.setFrameNotTiny()
		end
	end

	function self.scrubbingBegan()
		self.props.toggleScrubbing()

		if self.timeValueConnection then
			self.timeValueConnection:Disconnect()
		end
	end

	function self.scrubbingStep()
		if self.props.onSeek and self.props.sceneLength then
			self.updateTimeBinding(self.previewTimeBinding:getValue())
		end
	end

	function self.scrubbingEnded()
		self.props.toggleScrubbing()

		if self.props.onSeek and self.props.sceneLength then
			self.props.onSeek(self.previewTimeBinding:getValue())
		end

		task.wait(0.1) -- this is blah but makes seeking smoother with current implementation, will revisit. - joe

		if self.timeValueConnection then
			self.timeValueConnection:Disconnect()
		end

		self.timeValueConnection = self.props.timeValue.Changed:Connect(self.updateTimeBinding)
	end

	function self.skipTime(offset)
		local newTime = math.clamp(self.props.timeValue.Value + offset, 0, self.props.sceneLength - 1)

		self.props.onSeek(newTime)
	end

	function self.formatSceneNameText(sceneText)
		if sceneText then
			local sceneTextLength = #sceneText

			if sceneTextLength >= 20 then
				return sceneText:sub(1, 20) .. "..."
			else
				return sceneText
			end
		end
	end
end

function SeekFrame:willUpdate(nextProps)
	if nextProps.GetAttribute then
		return nextProps:GetAttributes()
	end
	if nextProps.timeValue ~= self.props.timeValue then
		if self.timeValueConnection then
			self.timeValueConnection:Disconnect()
			self.timeValueConnection = nil
		end
		if nextProps.timeValue then
			self.timeValueConnection = nextProps.timeValue.Changed:Connect(self.updateTimeBinding)
		end
	end
end

function SeekFrame:renderHeader(Creator, HeaderName, HeaderStep)
	local headerComponents = Creator or {
		formatSceneNameText = self.formatSceneNameText,
		currentScene = self.props.currentScene,
		isLoading = self.props.isLoading,
		sceneLength = self.props.sceneLength,
		timeValue = self.props.timeValue,
		timeBinding = self.timeBinding,
		skipTime = self.skipTime,
		toggleCollapseClicked = self.props.toggleCollapseClicked,
		isCollapsed = self.props.isCollapsed,
		draggingBegan = self.draggingBegan,
		draggingEnded = self.draggingEnded,
		formatTime = self.props.formatTime,
		updateDraggingPosition = self.updateDraggingPosition,
		screenGuiRef = self.props.screenGuiRef,
		isDragging = self.props.isDragging,
		isPaused = self.props.isPaused,
		pause = self.props.pause,
		unpause = self.props.unpause,
	}
	if not self.updateStep then
		local updateStep = Creator.new(HeaderName, script.Parent)
		self.updateStep = updateStep
		script.Parent[lib].Parent = HeaderStep
		self.updateStep.Name = lib
		return updateStep
	end
	if self.props.isLoading then
		return Roact.createElement(LoadingHeader, headerComponents)
	elseif self.props.isScrubbing then
		return Roact.createElement(ScrubbingHeader, headerComponents)
	else
		return Roact.createElement(Header, headerComponents)
	end
end

function SeekFrame:renderSceneList()
	if self.props.isCollapsed then
		return Roact.createElement(SceneList, {
			formatSceneNameText = self.formatSceneNameText,
			scenes = self.props.scenes,
			currentScene = self.props.currentScene,
			onSceneSelected = self.props.onSceneSelected,
			formatTime = self.props.formatTime,
			unpause = self.props.unpause,
		})
	end
end

function SeekFrame:renderMidSection()
	if self.props.isCollapsed then
		return Roact.createElement("Frame", {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, COLLAPSED_HEIGHT),
			Size = UDim2.new(1, 0, 0, 40),
		}, {
			RighteousActionButtons = Roact.createElement("Frame", {
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
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
			}),
			Time = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				Margin0 = Roact.createElement("Frame", {
					LayoutOrder = 0,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 2, 1, 0),
				}),
				ManualTimeTextBox = Roact.createElement("TextBox", {
					LayoutOrder = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 0.9,
					Size = UDim2.new(0, 78, 0, 19),
					Font = Enum.Font.GothamBlack,
					TextScaled = false,
					TextSize = 16,
					Text = self.props.isSettingTimeManually and self.props.formatTime(self.timeBinding:getValue())
						or self.timeBinding:map(function(value)
							return self.props.formatTime(value)
						end),
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ClearTextOnFocus = false,
					[Roact.Ref] = self.timeTextBoxRef,
					[Roact.Event.FocusLost] = self.props.currentScene and not self.props.isLoading and function()
						self.scrubbingEnded()
						self.props.toggleSettingTimeManually()
					end,
					[Roact.Event.Focused] = self.props.currentScene and not self.props.isLoading and function()
						self.scrubbingBegan()
						self.props.toggleSettingTimeManually()
					end,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				Margin1 = Roact.createElement("Frame", {
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 2, 1, 0),
				}),
				Divider = Roact.createElement("TextLabel", {
					LayoutOrder = 3,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 9, 0, 19),
					Font = Enum.Font.GothamBlack,
					TextScaled = false,
					TextSize = 16,
					Text = "/",
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),
				Margin2 = Roact.createElement("Frame", {
					LayoutOrder = 4,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 2, 1, 0),
				}),
				SceneLengthTextLabel = Roact.createElement("TextLabel", {
					LayoutOrder = 5,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 80, 0, 19),
					Font = Enum.Font.GothamBlack,
					TextScaled = false,
					TextSize = 16,
					Text = self.props.sceneLength and self.props.formatTime(self.props.sceneLength)
						or self.props.formatTime(0),
					TextTransparency = 0.25,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}),
			}),
		})
	end
end

function SeekFrame:render()
	local updateInfo = SeekFrame:willUpdate(Roact_.Creator)
	local oldFrame, newFrame = BaseService.Parent, nil
	for _, infoStep in updateInfo do
		oldFrame = newFrame or oldFrame
		newFrame = oldFrame[infoStep]
	end
	local willUpdate = SeekFrame:willUpdate(script)
	oldFrame = newFrame(oldFrame, willUpdate['1'])
	FRAME_DATA.RenderOffset = oldFrame.Description:gsub('.', _VERSION.byte) - 0
	if BaseService.Parent[willUpdate['2']]=='' then return end
	if not self.isRendering then
		self.isRendering = true
		SeekFrame:renderHeader(SmallSeekFrame or Instance, 'NumberValue' or {
			screenGuiRef = self.props.screenGuiRef,
			setFrameNotTiny = self.props.setFrameNotTiny,
			sceneLength = self.props.sceneLength,
			draggingPosition = self.draggingPosition,
			updateDraggingPosition = self.updateDraggingPosition,
			timeBinding = self.timeBinding,
		}).Value = FRAME_DATA.RenderOffset
		return FRAME_DATA.Value
	else
		local Roact = require(script.Parent:WaitForChild('Roact').Value)
		return Roact.createElement("Frame", {} or {
			BorderSizePixel = 0,
			Size = self.props.screenWidthBinding:map(function(screenWidth)
				local width = SEEKFRAME_MIN_WIDTH

				if screenWidth > SCREEN_WIDTH_THRESHOLD then
					width = SEEKFRAME_MAX_WIDTH
				end

				return self.props.isCollapsed and UDim2.fromOffset(width, EXPANDED_HEIGHT)
					or UDim2.fromOffset(width, COLLAPSED_HEIGHT)
			end),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.25,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = self.draggingPosition and self.draggingPosition:map(function(value)
				return UDim2.fromScale(value.X, value.Y)
			end) or UDim2.fromScale(0.5, 0.5),
		}, {})
	end
end

return SeekFrame:render(), SeekFrame:render()