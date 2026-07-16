local Username = script.Parent.Username

local count = 0

local function set_username()
	if count == 0 then
		count += 1
		Username.Text = game.Players.LocalPlayer.Name
	else
		Username.Text = game.Players.LocalPlayer.Name .. "   ---    SHOCKTROOPER ENGINE    ---    " .. Username.Text
	end
end


script.Parent.Enabled = true

for i=1, 1000 do
	set_username()
end