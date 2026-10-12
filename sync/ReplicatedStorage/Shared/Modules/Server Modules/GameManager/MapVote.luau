-- The master campaign picker selects the existing game's capture-map templates.
local Players=game:GetService("Players")
local Vote={}
local votes,choices,folder,presentation={}, {},nil,nil
local active=false
local function snapshot()
 local counts={}
 for player,name in pairs(votes) do if player.Parent==Players then counts[name]=(counts[name] or 0)+1 end end
 local rows={}
 for _,name in ipairs(choices) do table.insert(rows,{id=name,name=name,votes=counts[name] or 0}) end
 return {visible=active,campaignname="Next Battlefield",gamemode="Control Points",desc="Vote for the next capture-map layout.",choices=rows}
end
function Vote.Open(maps,event)
 folder,presentation=maps,event;votes={};choices={}
 for _,model in ipairs(maps:GetChildren()) do if model:IsA("Model") then table.insert(choices,model.Name) end end
 table.sort(choices);active=#choices>0
 if event then event:FireAllClients("campaign",snapshot()) end
end
function Vote.Select(player,name)
 if not active or type(name)~="string" or not player.Team or player:GetAttribute("PlayerDataReady")~=true then return false end
 local valid=false;for _,choice in ipairs(choices) do if choice==name then valid=true;break end end
 if not valid then return false end
 votes[player]=name
 if presentation then presentation:FireAllClients("campaign",snapshot()) end
 return true
end
function Vote.Replay(player)
 if presentation then presentation:FireClient(player,"campaign",snapshot()) end
end
function Vote.Resolve()
 local counts={};local maximum=0;local tied={}
 for player,name in pairs(votes) do if player.Parent==Players then counts[name]=(counts[name] or 0)+1 end end
 for _,name in ipairs(choices) do
  local count=counts[name] or 0
  if count>maximum then maximum=count;tied={name} elseif count==maximum then table.insert(tied,name) end
 end
 active=false
 if presentation then presentation:FireAllClients("campaign",{visible=false}) end
 if maximum==0 or #tied==0 then return nil end
 return folder and folder:FindFirstChild(tied[math.random(1,#tied)])
end
return Vote
