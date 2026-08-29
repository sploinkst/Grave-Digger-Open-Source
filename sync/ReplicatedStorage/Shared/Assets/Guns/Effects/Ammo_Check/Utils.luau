local module = {}
local Ammo_Check_Part = script.Parent
local billboard_main = Ammo_Check_Part.BillBoard_Main
local max_ammo = billboard_main.Max_Ammo
local inner_bar = max_ammo.Inner_Bar
local ammo_bar = inner_bar.Ammo_Bar
local background = max_ammo.Background
local Ammo_TextLabel = billboard_main.Ammo
local Count_TextLabel = billboard_main.Count
local Revolver_TextLabel = billboard_main.Revolver_Text

local TweenService = game:GetService("TweenService")
local FADE_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
local FADE_OUT_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
local DISPLAY_TIME = 1.5

local hideThread = nil

local function fadeIn(obj, property)
	TweenService:Create(obj, FADE_INFO, { [property] = 0 }):Play()
end

local function fadeOut(obj, property)
	TweenService:Create(obj, FADE_OUT_INFO, { [property] = 1 }):Play()
end

local function hide()
	fadeOut(Ammo_TextLabel, "TextTransparency")
	fadeOut(Count_TextLabel, "TextTransparency")
	fadeOut(background, "ImageTransparency")
	fadeOut(ammo_bar, "BackgroundTransparency")
	fadeOut(Revolver_TextLabel, "TextTransparency")
	task.wait(FADE_OUT_INFO.Time)
	billboard_main.Enabled = false
end

function module.utils(Ammo_Type: string, Ammo_Percentage: number, Revolver: boolean, bar_size: UDim2?)
	print("Ammo Check: ", Ammo_Type, Ammo_Percentage, Revolver, bar_size)
	bar_size = UDim2.new(1, 0, bar_size, 0)
	if hideThread then
		task.cancel(hideThread)
		hideThread = nil
	end

	billboard_main.Enabled = true
	max_ammo.Visible = true
	inner_bar.Visible = true
	ammo_bar.Visible = true
	background.Visible = true
	Ammo_TextLabel.Visible = true
	Count_TextLabel.Visible = true
	Revolver_TextLabel.Visible = Revolver

	-- set values
	ammo_bar.Size = bar_size
	Ammo_TextLabel.Text = Ammo_Type

	-- map percentage to status text
	local status
	if Ammo_Percentage == 0 then
		status = "Empty."
	elseif Ammo_Percentage <= 0.2 then
		status = "Almost empty.."
	elseif Ammo_Percentage <= 0.45 then
		status = "Less than half.."
	elseif Ammo_Percentage <= 0.55 then
		status = "About half.."
	elseif Ammo_Percentage <= 0.75 then
		status = "More than half.."
	elseif Ammo_Percentage <= 0.99 then
		status = "Almost full.."
	else
		status = "Full."
	end
	Count_TextLabel.Text = status

	-- fade in
	fadeIn(Ammo_TextLabel, "TextTransparency")
	fadeIn(Count_TextLabel, "TextTransparency")
	fadeIn(background, "ImageTransparency")
	fadeIn(ammo_bar, "BackgroundTransparency")
	if Revolver then
		fadeIn(Revolver_TextLabel, "TextTransparency")
	end

	-- schedule hide after display time
	hideThread = task.delay(DISPLAY_TIME, hide)
end

return module