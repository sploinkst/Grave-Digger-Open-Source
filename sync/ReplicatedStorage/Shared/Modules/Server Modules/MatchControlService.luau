local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Rules=require(RS.Shared.Library.MasterPortRules)
local V=require(script.Parent.MasterActions.Validation)
local Service={}
local remote=V.Remote("MatchControl")
local votes={}
local voteGeneration=-1
function Service.Surrender(player,forced)
	local manager=require(script.Parent.GameManager)
	local state=manager.ControlState(player)
	local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
	local immune=c and (c:GetAttribute("IsDreadnought") or c:GetAttribute("NoSurrender"))
	local burning=c and c:GetAttribute("Burning")
	if not Rules.CanSurrender(state.losing or forced and manager.IsDeserter(player),h and h.Health>0,c and c:GetAttribute("Surrendered"),immune,burning) then return false end
	if forced and not manager.IsDeserter(player) then return false end
	c:SetAttribute("Surrendered",true); c:SetAttribute("DamageDealingBlocked",true)
	c:SetAttribute("ActionBlocked",true)
	h:UnequipTools()
	-- Preserve configured rewards; the source client does not specify medal amounts.
	local reward=RS.Shared.Library.Configuration.Scoring_Variables:GetAttribute("SurrenderMedals")
	local data=player:FindFirstChild("PlayerData"); local medals=data and data:FindFirstChild("Medals",true)
	if type(reward)=="number" and reward>0 and medals and medals:IsA("NumberValue") then medals.Value+=reward end
	remote:FireClient(player,"Surrendered",forced==true)
	h.Health=0
	return true
end
function Service.start_module()
	if Service.started then return end; Service.started=true
	remote.OnServerEvent:Connect(function(player,action,choice)
		if not V.Cooldown(player,"MatchControl",0.25) then return end
		if action=="Surrender" then Service.Surrender(player,false); return end
		if action=="ForcedSurrender" then Service.Surrender(player,true); return end
		if action~="Vote" then return end
		local manager=require(script.Parent.GameManager); local state=manager.ControlState(player)
		if state.generation~=voteGeneration then votes={}; voteGeneration=state.generation end
		local c=V.Living(player)
		if not Rules.CanVote(state.mode,state.active,c~=nil and player.Team~=nil,votes[player]~=nil,choice) then return end
		votes[player]={choice=choice,team=player.Team}; player:SetAttribute("TruceVote",choice)
		remote:FireClient(player,"Voted",choice)
		local truce,fight,eligible=0,0,0
		for _,p in ipairs(Players:GetPlayers()) do
			if p.Team then
				eligible+=1
				local vote=votes[p]
				if vote and vote.team==p.Team then if vote.choice=="truce" then truce+=1 else fight+=1 end end
			end
		end
		remote:FireAllClients("Votes",truce,fight,eligible)
		if eligible>0 and truce+fight==eligible then manager.ResolveTruce(truce>fight) end
	end)
	Players.PlayerRemoving:Connect(function(player) votes[player]=nil end)
	task.spawn(function()
		while true do
			for _,player in ipairs(Players:GetPlayers()) do
				local manager=require(script.Parent.GameManager)
				local c=player.Character
				if c then
					if manager.ControlState(player).active and manager.OutOfBounds(player) then
						if not c:GetAttribute("SurrenderDeadline") then c:SetAttribute("SurrenderDeadline",workspace:GetServerTimeNow()+20) end
						if manager.IsDeserter(player) then Service.Surrender(player,true) end
					else c:SetAttribute("SurrenderDeadline",nil) end
				end
			end
			task.wait(1)
		end
	end)
end
return Service
