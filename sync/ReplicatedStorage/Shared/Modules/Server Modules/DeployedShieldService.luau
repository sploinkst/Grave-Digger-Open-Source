local RS=game:GetService("ReplicatedStorage")
local V=require(script.Parent.MasterActions.Validation)
local Audio=require(RS.Shared.Library.ConstructAudio)
local Service={}
local remote=V.Remote("ShieldAction")
local names={"shield","Shield","VanguardShield","vanguardshield"}
local function modelFor(character,tool)
	local ref=tool:FindFirstChild("model")
	if ref and ref:IsA("ObjectValue") then return ref.Value end
	local data=character:FindFirstChild("CharacterData"); local equipment=data and data:FindFirstChild("Equipment")
	return equipment and ref and equipment:FindFirstChild(ref.Value)
end
local function segmentHealth(segment)
	local health=segment:FindFirstChild("health")
	local maximum=health and (health:FindFirstChild("max") or health:FindFirstChild("maxhealth"))
	return health,maximum
end
local function showBroken(segment)
	for _,child in ipairs(segment:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Transparency=child.Name=="damagepart" and 0 or 1
			child.CanCollide=false; child.CanQuery=child.Name=="damagepart"
		end
	end
end
function Service.RestoreSegments(tool,model)
	for _,name in ipairs({"leftshield","rightshield","topshield","mainshield"}) do
		local segment=model:FindFirstChild(name,true)
		local health=segment and segmentHealth(segment)
		if health then
			local key="SegmentHealth_"..name
			local saved=tool:GetAttribute(key)
			if type(saved)=="number" then health.Value=math.max(0,math.min(health.Value,saved)) end
			tool:SetAttribute(key,health.Value)
			if health.Value<=0 then showBroken(segment) end
			health:GetPropertyChangedSignal("Value"):Connect(function() tool:SetAttribute(key,health.Value) end)
		end
	end
end
function Service.Damage(player,part,amount)
	if typeof(part)~="Instance" or not part:IsA("BasePart") or type(amount)~="number" or amount~=amount or amount<=0 then return false end
	local segment=part
	while segment and not segment:FindFirstChild("health") do segment=segment.Parent end
	if not segment then return false end
	local c=segment:FindFirstAncestorOfClass("Model")
	while c and not game:GetService("Players"):GetPlayerFromCharacter(c) do c=c:FindFirstAncestorOfClass("Model") end
	local owner=c and game:GetService("Players"):GetPlayerFromCharacter(c)
	if not owner or owner.Team==player.Team or not (segment.Name=="leftshield" or segment.Name=="rightshield" or segment.Name=="topshield" or segment.Name=="mainshield") then return false end
	local health=segmentHealth(segment)
	health.Value=math.max(0,health.Value-amount)
	Audio.Impact(segment,part,health.Value<=0)
	if health.Value<=0 then
		showBroken(segment)
	end
	return true
end
function Service.Restock(player)
	local c=player.Character; local bag=player:FindFirstChildOfClass("Backpack")
	if not c or not bag then return end
	for _,container in ipairs({c,bag}) do
		for _,tool in ipairs(container:GetChildren()) do if tool:IsA("Tool") and table.find(names,tool.Name) then tool:SetAttribute("ShieldSupplies",2) end end
	end
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	remote.OnServerEvent:Connect(function(player,tool,action,segmentName)
		local c,root,h=V.Tool(player,tool,names)
		if not c or not V.Cooldown(player,"Shield:"..tostring(action),1) then return end
		local model=modelFor(c,tool)
		if action=="Plant" then
			Audio.Play("shield_ready",root)
			local captured=c
			task.delay(1,function()
				if player.Character~=captured or tool.Parent~=captured or h.Health<=0 then return end
				local deployment=require(script.Parent.ConstructionService).Place(player,"Vanguard Shield",root.CFrame*CFrame.new(0,-2.5,-3),{free=true})
				if not deployment then return end
				Service.RestoreSegments(tool,deployment)
				deployment:SetAttribute("RetrievableShield",true)
				tool.Parent=deployment
				if model then model:Destroy() end
				local click=deployment:FindFirstChildWhichIsA("ClickDetector",true)
				if not click then click=Instance.new("ClickDetector"); click.MaxActivationDistance=8; click.Parent=deployment.core end
				click.MouseClick:Connect(function(owner)
					local current,r=V.Living(owner)
					local backpack=owner:FindFirstChildOfClass("Backpack")
					if owner~=player or not current or not deployment.Parent or deployment:GetAttribute("Retrieving")
						or not backpack or (r.Position-deployment.core.Position).Magnitude>8 then return end
					deployment:SetAttribute("Retrieving",true)
					Audio.Play("shield_ready",r)
					Audio.Play("shield_pickup",r)
					tool.Parent=backpack
					deployment:Destroy()
				end)
			end)
		elseif action=="Remove" and model and table.find({"leftshield","rightshield","topshield"},segmentName) then
			local segment=model:FindFirstChild(segmentName,true)
			local health=segment and segmentHealth(segment)
			local damagepart=segment and segment:FindFirstChild("damagepart")
			if not health or not damagepart or damagepart.Transparency~=0 then return end
			if segmentName~="topshield" and health.Value>0 then return end
			Audio.Play("destroy_subtle",segment)
			damagepart.Transparency=1; damagepart.CanQuery=false
		elseif action=="Replace" and model and table.find({"leftshield","rightshield","topshield"},segmentName) then
			local segment=model:FindFirstChild(segmentName,true)
			local health,maximum
			if segment then health,maximum=segmentHealth(segment) end
			local supplies=tool:GetAttribute("ShieldSupplies") or 2
			if not health or not maximum or health.Value>=maximum.Value or supplies<=0 then return end
			Audio.Play("repair",root)
			tool:SetAttribute("ShieldSupplies",supplies-1); health.Value=maximum.Value
			for _,part in ipairs(segment:GetDescendants()) do
				if part:IsA("BasePart") then part.Transparency=part.Name=="damagepart" and 1 or 0; part.CanQuery=part.Name~="damagepart" end
			end
		end
	end)
end
return Service
