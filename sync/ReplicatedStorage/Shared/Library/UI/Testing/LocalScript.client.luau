-- Authored username watermark; build the repeated text once.
local player=game:GetService("Players").LocalPlayer
local label=script.Parent:WaitForChild("Username")
local prefix=player.Name.."   ---    SHOCKTROOPER ENGINE    ---"
label.Text=string.rep(prefix,999)..player.Name
label.Visible=true
script.Parent.Enabled=true
