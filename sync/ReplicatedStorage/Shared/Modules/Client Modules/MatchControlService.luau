-- B confirmation and the authored spawn-room truce buttons; no generated GUI.
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Settings=require(script.Parent.SettingsManager)
local Assets=require(RS.Shared.Library.AuthoredAssets)
local Service={}
local remote=RS.Shared.Library.Events:WaitForChild("MatchControl")
local connections={}; local confirmUntil=0
local function bindTruce()
	for _,connection in ipairs(connections) do connection:Disconnect() end; table.clear(connections)
	local player=Players.LocalPlayer
	local gameDetails=workspace:FindFirstChild("Game_Details")
	local main=gameDetails and gameDetails:FindFirstChild("Main_Game")
	local roomName=player.Team and player.Team.Name=="Golden Empire" and "Empire" or "Nation"
	local stuff=workspace:FindFirstChild("serverStuff")
	local room=stuff and stuff:FindFirstChild(roomName=="Empire" and "empire_spawnroom" or "nation_spawnroom")
	if not room and main then room=main:FindFirstChild(roomName,true) end
	local gui=room and room:FindFirstChild("trucegui",true)
	if not gui then return end
	for _,choice in ipairs({"truce","fight"}) do
		local button=gui:FindFirstChild(choice.."vote",true)
		if button and button:IsA("GuiButton") then table.insert(connections,button.Activated:Connect(function() remote:FireServer("Vote",choice) end)) end
	end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	Settings.HookInput("Surrender",function(_,pressed)
		if not pressed then return end
		local player=Players.LocalPlayer; local c=player.Character
		if not c or player:GetAttribute("MenuOpen") then return end
		local now=os.clock()
		if now<=confirmUntil then confirmUntil=0; remote:FireServer("Surrender")
		else confirmUntil=now+1; if _G.popupmsg then _G.popupmsg("confirm_surrender","Confirm Surrender? Press again.",1) end end
	end)
	remote.OnClientEvent:Connect(function(action,choice)
		if action=="Voted" then
			local player=Players.LocalPlayer
			for _,button in ipairs(workspace:GetDescendants()) do
				if button:IsA("TextButton") and button.Name==choice.."vote" and button:FindFirstAncestor("trucegui") then button.Text="Voted" end
			end
		elseif action=="Surrendered" then
			local core=Assets.CoreGame(); local label=core and core:FindFirstChild("traitortext")
			if label then label.Visible=false end
		end
	end)
	Players.LocalPlayer.CharacterAdded:Connect(function() confirmUntil=0; task.defer(bindTruce) end)
	Players.LocalPlayer:GetPropertyChangedSignal("Team"):Connect(bindTruce)
	workspace.DescendantAdded:Connect(function(instance) if instance.Name=="trucegui" then task.defer(bindTruce) end end)
	bindTruce()
	game:GetService("RunService").Heartbeat:Connect(function()
		local c=Players.LocalPlayer.Character
		local deadline=c and c:GetAttribute("SurrenderDeadline")
		local core=Assets.CoreGame(); local label=core and core:FindFirstChild("traitortext")
		if label and deadline then
			label.Visible=true
			label.Text="Return to your objective!\nYou automatically surrender in "..math.max(0,math.ceil(deadline-workspace:GetServerTimeNow())).." seconds!"
		elseif label and label:GetAttribute("MasterPortCountdown") then label.Visible=false end
		if label then label:SetAttribute("MasterPortCountdown",deadline~=nil) end
	end)
end
return Service
