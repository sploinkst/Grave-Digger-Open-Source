local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local V=require(script.Parent.MasterActions.Validation)
local Flight=require(script.Parent.MasterActions.Projectile)
local Assets=require(RS.Shared.Library.AuthoredAssets)
local ChargeState=require(RS.Shared.Library.OrdnanceState)
local Service={}
local remote=V.Remote("OrdnanceAction")
local configs={
	SmokescreenBombs={asset="nebel",speed=65,reload=30,count=2,smoke=true},
	MiningBombLauncher={asset="rooklauncher",part="bomb",speed=450,reload=30,count=2,mining=true},
	AntiArmourGrenades={asset="atgrenade",speed=65,reload=0,count=1},
	NebelGrenade={asset="nebel",speed=65,reload=0,count=1,smoke=true},
	RookLauncher={asset="rooklauncher",part="bomb",speed=450,reload=2.5,count=1,mining=true},
	RifleGrenade={asset="enfield",part="riflegrenade",speed=100,reload=0,count=2},
	ThrownNegotiator={asset="remington",speed=65,reload=0,count=1,direct=true},
}
local stocks=setmetatable({}, {__mode="k"})
local function stock(character,name,config)
	local states=stocks[character]; if not states then states={}; stocks[character]=states end
	local state=states[name]; if not state then state=ChargeState.New(config.count); states[name]=state end
	ChargeState.Refresh(state,config.count,config.reload,os.clock())
	character:SetAttribute(name.."Charges",state.count)
	return state
end
function Service.Blast(player,character,position,damage,radius)
	for _,target in ipairs(Players:GetPlayers()) do
		local c=target.Character; local root=c and c:FindFirstChild("HumanoidRootPart"); local h=c and c:FindFirstChildOfClass("Humanoid")
		if root and h and h.Health>0 and target~=player and player.Team and target.Team~=player.Team and (root.Position-position).Magnitude<=radius then
			local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={character}
			local hit=workspace:Raycast(position,root.Position-position,params)
			if not hit or hit.Instance:IsDescendantOf(c) then h:TakeDamage(damage) end
		end
	end
	local folder=workspace:FindFirstChild("constructions")
	for _,model in ipairs(folder and folder:GetChildren() or {}) do
		local core=model:FindFirstChild("core")
		if core and (core.Position-position).Magnitude<=radius then require(script.Parent.ConstructionService).Damage(player,model,damage) end
	end
end
function Service.Fire(player,name,direction,tool,underhand)
	local config=configs[name]; local character=V.Living(player)
	if not config or not character or not V.Direction(direction) then return false end
	local source=Assets.Find(config.asset,{RS.Shared.Assets},"Model")
	if source and config.part then source=source:FindFirstChild(config.part,true) end
	if not source then warn("[Ordnance] Missing authored projectile: "..name); return false end
	local state=stock(character,name,config)
	local grenades=tool and name=="RifleGrenade" and tool:FindFirstChild("Grenades")
	if grenades then state.count=grenades.Value end
	if state.count<=0 or not V.Cooldown(player,"Ordnance:"..name,0.5) then return false end
	local speed=underhand and config.speed*0.5 or config.speed
	local launched=Flight.Launch(character,source,direction,speed,function(hit,projectile)
		if config.smoke then
			for _,child in ipairs(projectile:GetDescendants()) do
				if child:IsA("ParticleEmitter") then child.Enabled=true
				elseif child:IsA("Sound") then child:Play() end
			end
			Debris:AddItem(projectile,source:GetAttribute("Lifetime") or 30)
		elseif config.direct then
			local c=hit.Instance:FindFirstAncestorOfClass("Model"); local target=c and Players:GetPlayerFromCharacter(c)
			if target and player.Team and target.Team~=player.Team then local h=c:FindFirstChildOfClass("Humanoid"); if h then h:TakeDamage(source:GetAttribute("Damage") or 80) end end
		else
			Service.Blast(player,character,hit.Position+hit.Normal*0.1,source:GetAttribute("Damage") or 50,source:GetAttribute("Radius") or 12)
			if config.mining and hit.Instance==workspace.Terrain and hit.Material==Enum.Material.Rock then
				require(script.Parent.GameManager.TerrainService).MineImpact(player,hit.Position,direction,source:GetAttribute("MiningRadius") or 6)
			end
		end
	end,{retain=config.smoke})
	if not launched then return false end
	ChargeState.Consume(state,config.count,config.reload,os.clock())
	character:SetAttribute(name.."Charges",state.count)
	if grenades then grenades.Value=state.count end
	if config.reload>0 then
		local captured=character
		task.delay(config.reload,function()
			if player.Character==captured then stock(captured,name,config) end
		end)
	end
	if name=="ThrownNegotiator" and tool then
		local ref=tool:FindFirstChild("model")
		local data=character:FindFirstChild("CharacterData"); local equipment=data and data:FindFirstChild("Equipment")
		local model=equipment and ref and equipment:FindFirstChild(ref.Value)
		if model then model:Destroy() end
		tool:Destroy()
	end
	return true
end
function Service.Restock(player)
	local c=player.Character; if not c then return end
	stocks[c]=nil
	for name,config in pairs(configs) do c:SetAttribute(name.."Charges",config.count) end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	remote.OnServerEvent:Connect(function(player,tool,name,direction)
		if name=="SmokescreenBombs" or name=="MiningBombLauncher" then
			local c=V.Living(player)
			if not c or V.State(c,"Equipment")~=name then return end
		elseif name=="RookLauncher" then
			if not V.Tool(player,tool,{"RookLauncher","rooklauncher"}) then return end
		elseif name=="RifleGrenade" then
			if not V.Tool(player,tool,{"JesseRifle","JessePrecisionRifle","enfield","enfieldvariant"}) then return end
		elseif name=="ThrownNegotiator" then
			if not V.Tool(player,tool,{"NegotiatorShotgun","remington"}) then return end
		else return end
		Service.Fire(player,name,direction,tool)
	end)
	task.spawn(function()
		while true do
			for _,player in ipairs(Players:GetPlayers()) do
				local c=player.Character; local states=c and stocks[c]
				if states then for name in pairs(states) do stock(c,name,configs[name]) end end
			end
			task.wait(0.25)
		end
	end)
end
return Service
