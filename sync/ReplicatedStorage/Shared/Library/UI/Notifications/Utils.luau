local module = {}

local notifications_screengui = script.Parent
local main_frame = notifications_screengui.Main
local example = main_frame.Example

local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")

local serial=0
example.Visible=false
local layout=main_frame:FindFirstChildWhichIsA("UIListLayout")
if layout then layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.VerticalAlignment=Enum.VerticalAlignment.Bottom end

-- // rich text is enabled
function module.send_notification(players, text, duration)
	serial+=1
	local example_clone = example:Clone()
    example_clone.Name="FlavourText_"..serial
    example_clone.LayoutOrder=serial
	example_clone.Parent = main_frame
	example_clone.Visible = true
	example_clone.Text = text
	example_clone.TextTransparency = 1
	example_clone.TextStrokeTransparency = 1
	
	local tween = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextTransparency = 0})
	local tween1 = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextStrokeTransparency = 0})
	tween:Play()
	tween1:Play()
	
	task.delay(math.clamp(tonumber(duration) or 3,1,10), function()
        if not example_clone.Parent then return end
		local tween = tween_service:Create(example_clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1})
		tween:Play()
		tween.Completed:Wait()
		example_clone:Destroy()
	end)
end

return module
