local Roact = require(script.Parent.Roact.Roact)
local Otter = require(script.Parent.Parent.Packages.Otter)
local t = require(script.Parent.Parent.Packages.t)
local Interface = require(script.Parent.Parent.constants).Interface

local MINIMIZED_SIZE = Interface.CollapseButtonSize + Interface.Padding * 2

local CollapsibleWindow = Roact.Component:extend("CollapsibleWindow")

CollapsibleWindow.validateProps = t.strictInterface({
	isCollapsed = t.boolean,
	size = t.UDim2,
	title = t.string,
	anchorPoint = t.optional(t.Vector2),
	position = t.optional(t.UDim2),
	minSize = t.optional(t.Vector2),
	onButtonClicked = t.optional(t.callback),
})

function CollapsibleWindow:init()
	self:setState({
		collapseAnimationFinished = self.props.isCollapsed,
	})

	self.collapsedBinding, self.updateCollapsedBinding = Roact.createBinding(if self.props.isCollapsed then 1 else 0)
	self.collapsedMotor = Otter.createSingleMotor(self.collapsedBinding:getValue())
	self.collapsedMotor:onStep(self.updateCollapsedBinding)
	self.collapsedMotor:onComplete(function()
		if self.props.isCollapsed then
			self:setState({ collapseAnimationFinished = true })
		end
	end)
end

function CollapsibleWindow:render()
	return Roact.createElement("Frame", {
		AnchorPoint = self.props.anchorPoint,
		Position = self.props.position,
		Size = self.collapsedBinding:map(function(value)
			return self.props.size:Lerp(UDim2.fromOffset(MINIMIZED_SIZE, MINIMIZED_SIZE), value)
		end),
		BackgroundColor3 = Color3.fromRGB(23, 23, 23),
		ClipsDescendants = true,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, Interface.Padding),
			PaddingRight = UDim.new(0, Interface.Padding),
			PaddingTop = UDim.new(0, Interface.Padding),
			PaddingBottom = UDim.new(0, Interface.Padding),
		}),

		SizeConstraint = self.props.minSize and Roact.createElement("UISizeConstraint", {
			MinSize = self.collapsedBinding:map(function(value)
				return self.props.minSize:Lerp(Vector2.new(), value)
			end),
		}),

		CaretButton = Roact.createElement("ImageButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(Interface.CollapseButtonSize, Interface.CollapseButtonSize),
			Image = "rbxassetid://7913177089",
			Rotation = self.collapsedBinding:map(function(value)
				return 180 * value
			end),

			[Roact.Event.Activated] = self.props.onButtonClicked,
		}),

		TitleLabel = self.props.title and Roact.createElement("TextLabel", {
			Size = UDim2.new(1, -Interface.CollapseButtonSize, 0, Interface.CollapseButtonSize),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = Interface.TextSizeLarge,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextTransparency = self.collapsedBinding,
			RichText = true,
			Text = self.props.title,
			ClipsDescendants = true,
			LayoutOrder = 1,
		}),

		Container = not self.state.collapseAnimationFinished and Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -Interface.CollapseButtonSize - Interface.Padding),
			Position = UDim2.fromOffset(0, Interface.CollapseButtonSize + Interface.Padding),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, self.props[Roact.Children]),
	})
end

function CollapsibleWindow:didUpdate(previousProps)
	if previousProps.isCollapsed ~= self.props.isCollapsed then
		self:setState({ collapseAnimationFinished = false })
		local target = if self.props.isCollapsed then 1 else 0
		self.collapsedMotor:setGoal(Otter.spring(target, Interface.SpringConfiguration))
	end
end

return CollapsibleWindow
