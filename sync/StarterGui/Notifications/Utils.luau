local module = {}

local notifications_screengui = script.Parent
local main_frame = notifications_screengui.Main
local example = main_frame.Example

local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")

-- // rich text is enabled
function module.send_notification(players, text)
	local example_clone = example:Clone()
	example_clone.Parent = main_frame
	example_clone.Visible = true
	example_clone.Text = text
	example_clone.TextTransparency = 1
	example_clone.TextStrokeTransparency = 1
	
	local tween = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextTransparency = 0})
	local tween1 = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextStrokeTransparency = 0})
	tween:Play()
	tween1:Play()
	
	task.delay(3, function()
		local tween = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextTransparency = 1})
		tween:Play()
		tween.Completed:Wait()
		example_clone:Destroy()
	end)
end

return module
