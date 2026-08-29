local AlertUtils = {}
-- // Services
local TweenService = game:GetService("TweenService")
-- // Constants
local Alerts = script.Parent
local holder = Alerts.alert
local icons = holder.icons
local scroll = holder.scroll
local toptext = scroll.toptext
local maintext = holder.maintext
local empireleft = icons.empireleft
local empireright = icons.empireright
local nationleft = icons.nationleft
local nationright = icons.nationright

local MessagesModule = require(script.Messages)

-- // Variables
local Working = false
local Positions = {
	["In"] = {
		[1] = UDim2.new(0, 0, 0.6, 0),
	},
	["Out"] = {
		[1] = UDim2.new(0.5, 0, 0.6, 0),
	}
}
local TweenInfo = TweenInfo.new(1)
local IconsIn = TweenService:Create(icons, TweenInfo, {
	Size = Positions["In"][1]
})
local IconsOut = TweenService:Create(icons, TweenInfo, {
	Size = Positions["Out"][1]
})
local ScrollIn = TweenService:Create(scroll, TweenInfo, {
	Size = Positions["In"][1]
})
local ScrollOut = TweenService:Create(scroll, TweenInfo, {
	Size = Positions["Out"][1]
})
-- // Functions
local function SetTransparency(value: number)
	maintext.TextTransparency = value
	for _, icon in ipairs({
		empireleft,
		empireright,
		nationleft,
		nationright,
		}) do
		icon.ImageTransparency = value
	end
end

local function FadeIn()
	TweenService:Create(maintext, TweenInfo, {
		TextTransparency = 0
	}):Play()
	for _, icon in ipairs({
		empireleft,
		empireright,
		nationleft,
		nationright,
		}) do
		TweenService:Create(icon, TweenInfo, {
			ImageTransparency = 0
		}):Play()
	end
end

local function FadeOut()
	TweenService:Create(maintext, TweenInfo, {
		TextTransparency = 1
	}):Play()
	for _, icon in ipairs({
		empireleft,
		empireright,
		nationleft,
		nationright,
		}) do
		TweenService:Create(icon, TweenInfo, {
			ImageTransparency = 1
		}):Play()
	end
end
-- // Connections
function AlertUtils.Alert(team: string, event: string)
	if team == "Select" then
		local player = game.Players.LocalPlayer
		team = player.Team and player.Team.Name == "Golden Empire" and "Empire" or "Nation"
	end
	
	if not MessagesModule[team] or not MessagesModule[team][event] then
		warn("Alert does not exist", event)
		return
	end

	local messages = MessagesModule[team][event]
	local message = messages[math.random(1, #messages)]

	if Working then
		return
	end

	Working = true

	-- Start fully transparent
	SetTransparency(1)

	-- Hide all icons
	empireleft.Visible = false
	empireright.Visible = false
	nationleft.Visible = false
	nationright.Visible = false

	-- Set team-specific information
	if team == "Empire" or not team then
		team = "Empire"

		empireleft.Visible = true
		empireright.Visible = true

		toptext.Text = "QUEENS WILL"

	elseif team == "Nation" then
		nationleft.Visible = true
		nationright.Visible = true

		toptext.Text = "KINGS DECREE"
	end

	maintext.Text = message

	-- Fade text and icons in
	FadeIn()

	-- Expand into view
	IconsOut:Play()
	ScrollOut:Play()

	IconsOut.Completed:Wait()

	task.delay(5, function()
		-- Shrink
		IconsIn:Play()
		ScrollIn:Play()

		-- Wait until the icons finish shrinking
		IconsIn.Completed:Wait()

		-- Fade out
		FadeOut()

		-- Wait for fade to finish
		task.delay(1, function()
			Working = false
		end)
	end)
end

return AlertUtils