local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Module = {}
local pages = {
	{"Movement", "Move through the tunnels, sprint when you need speed, and crouch to keep a low profile."},
	{"Weapons", "Aim before firing. Check your ammunition and reload before advancing. Use alternate mode for weapons that support it."},
	{"Class equipment", "Each class has its own equipment. Select your class, weapons and perk in Loadout, then use your Class Equipment bind in battle."},
	{"Mining and supplies", "Mine eligible rock with your pickaxe. Rooks maintain their heavy pickaxe with sharpening stones. Resupply at an ammunition cache."},
	{"Objectives", "Fight alongside your team and capture the active objectives. Medkits help keep your allies alive."},
}
function Module.Play(menu)
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui")
	local old = gui:FindFirstChild("MenuTutorial")
	if old then old:Destroy() end
	local authored = RS.Shared.Library.UI:FindFirstChild("Tutorial")
	if authored then
		local clone=authored:Clone(); clone.Name="MenuTutorial"; clone.Parent=gui
		if clone:IsA("ScreenGui") then clone.Enabled=true end
		menu.Close(); return true
	end
	local screen=Instance.new("ScreenGui")
	screen.Name="MenuTutorial"; screen.ResetOnSpawn=false; screen.DisplayOrder=100
	local frame=Instance.new("Frame")
	frame.AnchorPoint=Vector2.new(0.5,0.5); frame.Position=UDim2.fromScale(0.5,0.5)
	frame.Size=UDim2.fromScale(0.65,0.6); frame.BackgroundColor3=Color3.new(); frame.BackgroundTransparency=0.15; frame.Parent=screen
	local function label(name,y,height)
		local item=Instance.new("TextLabel"); item.Name=name; item.BackgroundTransparency=1
		item.Position=UDim2.fromScale(0.05,y); item.Size=UDim2.fromScale(0.9,height)
		item.Font=Enum.Font.Garamond; item.TextSize=24; item.TextColor3=Color3.new(1,1,1)
		item.TextWrapped=true; item.Parent=frame; return item
	end
	local title=label("Title",0.05,0.1)
	local body=label("Body",0.2,0.3)
	local controls=label("Controls",0.53,0.25); controls.TextSize=18
	local nextButton=Instance.new("TextButton")
	nextButton.Position=UDim2.fromScale(0.55,0.85); nextButton.Size=UDim2.fromScale(0.4,0.1)
	nextButton.Font=Enum.Font.Garamond; nextButton.TextSize=22; nextButton.Parent=frame
	nextButton.Modal=true
	local back=nextButton:Clone(); back.Position=UDim2.fromScale(0.05,0.85); back.Text="Back"; back.Parent=frame
	local page=1
	local function refresh()
		title.Text=pages[page][1]; body.Text=pages[page][2]
		nextButton.Text=page==#pages and "Finish" or "Next"; back.Visible=page>1
		local root=player:FindFirstChild("PlayerData")
		local settings=root and root:FindFirstChild("Settings Data")
		local binds=settings and settings:FindFirstChild("Inputs") and settings.Inputs:FindFirstChild("Binds")
		local lines={}
		for _, name in {"Sprint", "Crouch", "Aim", "Reload", "Check Ammo", "Class Equipment", "Menu"} do
			local bind=binds and binds:FindFirstChild(name)
			local current=bind and bind:FindFirstChild("Current")
			if current then table.insert(lines,name .. ": " .. current.Value) end
		end
		controls.Text=table.concat(lines,"   ")
	end
	nextButton.Activated:Connect(function() if page==#pages then screen:Destroy(); menu.Open("Settings") else page+=1; refresh() end end)
	back.Activated:Connect(function() page=math.max(1,page-1); refresh() end)
	menu.Close()
	local wasLocked=player:GetAttribute("MenuLocked")
	player:SetAttribute("MenuLocked",true)
	local removing=player.CharacterRemoving:Connect(function() screen:Destroy() end)
	screen.Destroying:Connect(function() removing:Disconnect(); player:SetAttribute("MenuLocked",wasLocked) end)
	screen.Parent=gui; refresh()
	return true
end
return Module
