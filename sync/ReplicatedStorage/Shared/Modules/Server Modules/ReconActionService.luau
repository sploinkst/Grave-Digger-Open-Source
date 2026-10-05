local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local V=require(script.Parent.MasterActions.Validation)
local Service={}
local remote=V.Remote("ReconAction")
local intel=V.Remote("ClassIntel")
function Service.Mark(player,target)
	local c,root=V.Living(player)
	local enemy=target and Players:GetPlayerFromCharacter(target)
	local h=target and target:FindFirstChildOfClass("Humanoid")
	if not c or not enemy or not player.Team or enemy.Team==player.Team or not h or h.Health<=0 then return end
	for _,ally in ipairs(Players:GetPlayers()) do
		local r=ally.Character and ally.Character:FindFirstChild("HumanoidRootPart")
		if r and ally.Team==player.Team and (r.Position-root.Position).Magnitude<=200 then intel:FireClient(ally,"Mark",target,10) end
	end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	remote.OnServerEvent:Connect(function(player,tool,action,direction)
		local c,root=V.Tool(player,tool,{"Binoculars","ReconKit","binocs"})
		if not c or not V.Cooldown(player,"Recon:"..tostring(action),action=="Flare" and 30 or 1) then return end
		if action=="Mark" or action=="Ping" then
			local hit=V.Ray(c,direction,500); if not hit then return end
			if action=="Mark" then
				local target=hit.Instance:FindFirstAncestorOfClass("Model")
				while target and not Players:GetPlayerFromCharacter(target) do target=target:FindFirstAncestorOfClass("Model") end
				Service.Mark(player,target)
			else
				for _,ally in ipairs(Players:GetPlayers()) do if player.Team and ally.Team==player.Team then remote:FireClient(ally,"Ping",hit.Position,player) end end
			end
		elseif action=="Telescope" then
			local model=require(script.Parent.ConstructionService).Place(player,"Telescope",root.CFrame*CFrame.new(0,-2.5,-3),{free=true})
			if not model then return end
			local look=root.CFrame.LookVector
			task.spawn(function()
				while model.Parent and player.Character==c do
					for _,enemy in ipairs(Players:GetPlayers()) do
						local r=enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
						local delta=r and r.Position-model.core.Position
						if delta and delta.Magnitude>0 and delta.Magnitude<=500 and look:Dot(delta.Unit)>0.8 then
							local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={model,c}
							local hit=workspace:Raycast(model.core.Position,delta,params)
							if not hit or hit.Instance:IsDescendantOf(enemy.Character) then Service.Mark(player,enemy.Character) end
						end
					end
					task.wait(1)
				end
			end)
		elseif action=="Flare" and V.Direction(direction) then
			local source=RS.Shared.Assets.Guns.Effects:FindFirstChild("Bullet")
			if not source then return end
			require(script.Parent.MasterActions.Projectile).Launch(c,source,direction,100,function(hit,flare)
				local part=flare:IsA("BasePart") and flare or flare:FindFirstChildWhichIsA("BasePart",true)
				if not part then flare:Destroy(); return end
				local light=Instance.new("PointLight"); light.Range=60; light.Brightness=3; light.Parent=part
				for _,enemy in ipairs(Players:GetPlayers()) do local r=enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart"); if r and (r.Position-hit.Position).Magnitude<=60 then Service.Mark(player,enemy.Character) end end
				Debris:AddItem(flare,15)
			end,{retain=true})
		end
	end)
end
return Service
