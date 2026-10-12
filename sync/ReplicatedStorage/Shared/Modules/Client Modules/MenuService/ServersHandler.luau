local RS = game:GetService("ReplicatedStorage")
local UI = require(script.Parent.UI)
local Scope = require(script.Parent.Scope)
local Rules = require(RS.Shared.Library.MenuRules)
local Service, started = {}, false
function Service.start_module(menu)
	if started then return end
	started = true
	UI.Mount("Servers", function(scene, scope)
		local frame = scene:FindFirstChild("serversframe")
		local list = frame and UI.Find(frame,"menu/scroll")
		local template = list and (list:FindFirstChild("ex") or list:FindFirstChild("Example"))
		if not template then warn("[Menu/Servers] Missing serversframe.menu.scroll.ex"); return end
		template.Visible = false
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		local filters, regions, rows, snapshot = {}, {}, nil, {}
		local busy = false
		local regionList = UI.Find(frame,"regionfilter/scroll")
		local regionTemplate = regionList and regionList:FindFirstChild("ex")
		if regionTemplate then regionTemplate.Visible = false end
		local regionScope = Scope.new(); scope:Own(function() regionScope:Destroy(); if rows then rows:Destroy() end end)
		local function status(message) UI.Text(frame,"menu/status",message); UI.Text(frame,"status",message) end
		local function render()
			if rows then rows:Destroy() end
			rows = Scope.new()
			for _, server in snapshot do
				local row = UI.Clone(template,list,rows,server.id~="" and server.id or "CurrentServer")
				row.Visible = Rules.ShowServer(server,filters,regions)
				row.LayoutOrder = 100-server.players
				UI.Text(row,"playercount","Soldiers: " .. server.players .. " / " .. server.maximum)
				UI.Text(row,"servermission","Mission: " .. (Rules.Missions[server.mission] or "Unknown"))
				UI.Text(row,"servertitle",string.format("%s - %s - %02d:%02d",server.name,server.region,math.floor(server.lifetime/60)%60,server.lifetime%60))
				local join = row:FindFirstChild("join")
				if join and join:IsA("GuiButton") then
					join.Active = server.id~=game.JobId and server.players<server.maximum
					rows:Connect(join.Activated,function()
						if not join.Active or busy then return end
						busy=true; status("Joining...")
						task.spawn(function()
							local remote = RS.Shared.Library.Events:FindFirstChild("MenuServers")
							local ok, reply = pcall(function() return remote:InvokeServer("Join",server.id) end)
							busy=false
							if scope.alive then status(ok and reply.error or "Could not join this server.") end
						end)
					end)
				end
			end
		end
		local function updateRegions()
			for _, server in snapshot do
				if regions[server.region]==nil then
					regions[server.region]=false
					if regionTemplate then
						local button=UI.Clone(regionTemplate,regionList,regionScope,server.region)
						UI.Text(button,"inner",server.region)
						UI.Selected(button,false)
						regionScope:Connect(button.Activated,function() regions[server.region]=not regions[server.region]; UI.Selected(button,regions[server.region]); render() end)
					end
				end
			end
		end
		local function refresh()
			if busy or not scene.Enabled then return end
			busy=true; status("Loading servers...")
			task.spawn(function()
				local remote=RS.Shared.Library.Events:WaitForChild("MenuServers",10)
				local ok, reply=pcall(function() return remote:InvokeServer("List") end)
				busy=false
				if not scope.alive then return end
				if ok and reply.servers then snapshot=reply.servers; updateRegions(); render(); status("")
				else status(ok and reply.error or "Servers are temporarily unavailable.") end
			end)
		end
		local filterFrame=frame:FindFirstChild("filters")
		for _, button in filterFrame and filterFrame:GetChildren() or {} do
			if button:IsA("GuiButton") then
				filters[button.Name]=false; UI.Selected(button,false)
				scope:Connect(button.Activated,function() filters[button.Name]=not filters[button.Name]; UI.Selected(button,filters[button.Name]); render() end)
			end
		end
		UI.Bind(scope,frame,"filterregiontab",function() local panel=frame:FindFirstChild("regionfilter"); if panel then panel.Visible=not panel.Visible end end)
		UI.Bind(scope,frame,"menu/refresh",refresh)
		scope:Connect(scene:GetPropertyChangedSignal("Enabled"),refresh)
		task.spawn(function() while scope.alive do refresh(); task.wait(30) end end)
	end)
end
return Service
