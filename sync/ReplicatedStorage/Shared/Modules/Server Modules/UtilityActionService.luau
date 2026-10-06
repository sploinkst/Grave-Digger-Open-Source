local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local V=require(script.Parent.MasterActions.Validation)
local Definitions=require(RS.Shared.Library.MasterToolDefinitions)
local Audio=require(RS.Shared.Library.ConstructAudio)
local Service={}
local remote=V.Remote("UtilityAction")
local actions={
	Repair={names={"Wrench","WeldingTool","wrench","weldingtool"},cooldown=0.5},
	FlagPlace={names={"Flagpole","RallyBanner"},cooldown=2},
	FlagWave={names={"Flagpole","RallyBanner"},cooldown=5},
	LancerStim={names={"LancerStim","PainkillerInjector"},cooldown=2},
	Throw={names={"AntiArmourGrenades","NebelGrenade"},cooldown=0.5},
	Drink={names={"Bottle"},cooldown=1},
	CleanMachete={names={"Machete"},cooldown=1},
	Lantern={names={"ConscriptLantern"},cooldown=0.5},
	Melee={names={"Knife","Club","Machete","Bottle"},cooldown=0.7},
}
local function toolModel(character,tool)
	local ref=tool:FindFirstChild("model")
	if ref and ref:IsA("ObjectValue") then return ref.Value end
	local data=character:FindFirstChild("CharacterData"); local equipment=data and data:FindFirstChild("Equipment")
	return equipment and ref and equipment:FindFirstChild(ref.Value)
end
function Service.Restock(player)
	local c=player.Character; if not c then return end
	local backpack=player:FindFirstChildOfClass("Backpack")
	if not backpack then return end
	for _,container in ipairs({c,backpack}) do
		for _,tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name=="LancerStim" or tool.Name=="PainkillerInjector") then tool:SetAttribute("Charges",tool:GetAttribute("MaxCharges") or 1) end
		end
	end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	remote.OnServerEvent:Connect(function(player,tool,action,argument)
		local config=actions[action]
		if not config then return end
		local c,root,h=V.Tool(player,tool,config.names)
		if not c then return end
		local cooldown=config.cooldown
		if action=="Repair" then
			local legacyClass=c:FindFirstChild("class")
			local role=string.lower(tostring(legacyClass and legacyClass.Value or c:GetAttribute("Class") or ""))
			if role=="rook" or role=="engineer" then cooldown/=1.5 end
		end
		if not V.Cooldown(player,"Utility:"..action,cooldown) then return end
		if action=="Repair" then
			local hit=V.Ray(c,argument,3); if not hit then return end
			if require(script.Parent.ConstructionService).Repair(player,hit.Instance,tool:GetAttribute("RepairAmount") or 10) then return end
			-- The master's wrench targets the outside of a train carriage.
			local carriage=hit.Instance
			while carriage and carriage.Parent and carriage.Parent.Name~="trains" do carriage=carriage.Parent end
			local stuff=workspace:FindFirstChild("serverStuff"); local values=stuff and stuff:FindFirstChild("values")
			local specific=values and values:FindFirstChild("gamemode_specific"); local train=specific and specific:FindFirstChild("train_track_on")
			local health=train and train:FindFirstChild("trainhealth"); local maximum=train and train:FindFirstChild("trainhealthmax")
			if carriage and carriage.Parent and health and maximum and not c:GetAttribute("InsideTrain") then
				local previous=health.Value
				health.Value=math.min(maximum.Value,health.Value+(tool:GetAttribute("RepairAmount") or 10))
				if health.Value>previous then Audio.Play("repair",root) end
			end
		elseif action=="FlagPlace" then
			require(script.Parent.BuffService).DeployBanner(player)
		elseif action=="FlagWave" then
			Audio.Play("flag",root)
			for _,ally in ipairs(Players:GetPlayers()) do
				local r=ally.Character and ally.Character:FindFirstChild("HumanoidRootPart")
				if player.Team and ally.Team==player.Team and r and (r.Position-root.Position).Magnitude<=35 then require(script.Parent.StatusService).GiveStatus(ally,"MoraleStatus",5) end
			end
		elseif action=="LancerStim" then
			local charges=tool:GetAttribute("Charges"); if charges==nil then charges=1 end
			if charges<=0 then return end
			tool:SetAttribute("Charges",charges-1)
			-- Server behavior was not supplied: these overrides are explicit tuning.
			h.Health=math.min(h.MaxHealth,math.max(h.Health,tool:GetAttribute("HealTo") or 100))
			local duration=tool:GetAttribute("Duration") or 20
			c:SetAttribute("LancerStimUntil",workspace:GetServerTimeNow()+duration)
			require(script.Parent.ChemicalService).ApplyMixture(player,c,player,{"Hydrocodone"})
			local captured=c
			task.delay(duration,function() if player.Character==captured then captured:SetAttribute("LancerStimUntil",nil) end end)
		elseif action=="Throw" then
			if type(argument)=="table" and V.Direction(argument.direction) then
				require(script.Parent.OrdnanceService).Fire(player,tool.Name,argument.direction,tool,argument.underhand==true)
			end
		elseif action=="Drink" then
			if not player:GetAttribute("Sickness") then require(script.Parent.StatusService).GiveStatus(player,"MoraleStatus",3) end
		elseif action=="CleanMachete" then
			tool:SetAttribute("Bloody",false)
			local model=toolModel(c,tool)
			for _,child in ipairs(model and model:GetDescendants() or {}) do if (child.Name=="blood" or child.Name:match("^blood%d+$")) and child:IsA("Decal") then child.Transparency=1 end end
		elseif action=="Lantern" then
			local enabled=not tool:GetAttribute("LanternEnabled"); tool:SetAttribute("LanternEnabled",enabled)
			local model=toolModel(c,tool)
			for _,child in ipairs(model and model:GetDescendants() or {}) do if child:IsA("Light") or child:IsA("ParticleEmitter") then child.Enabled=enabled end end
		elseif action=="Melee" then
			local asset=string.lower(tool.Name); local stats=Definitions[asset] or Definitions.knife
			local hit=V.Ray(c,argument,stats.melee_range or 5)
			local target=hit and hit.Instance:FindFirstAncestorOfClass("Model")
			local enemy=target and Players:GetPlayerFromCharacter(target)
			local health=target and target:FindFirstChildOfClass("Humanoid")
			if enemy and player.Team and enemy.Team~=player.Team and health and health.Health>0
				and not require(script.Parent.ClassCombatService).Blocks(target,root.Position) then
				health:TakeDamage(stats.melee_damage or stats.damage or 80)
				if tool.Name=="Machete" then tool:SetAttribute("Bloody",true) end
			end
		end
	end)
end
return Service
