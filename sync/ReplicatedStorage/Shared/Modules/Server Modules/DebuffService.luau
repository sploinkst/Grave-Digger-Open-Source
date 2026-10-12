local Players=game:GetService("Players")
local Service={}
local status=require(script.Parent.StatusService)
local hunts={}
local INTERVAL=15
local RANGE=75
local function root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function alive(p) local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");return h and h.Health>0 end
local function distance(a,b) local x,y=root(a),root(b);return x and y and (x.Position-y.Position).Magnitude or math.huge end
local function clear(source,state)
 if state.target and state.target:GetAttribute("HuntedByUserId")==source.UserId then status.RemoveStatus(state.target,"HuntedStatus") end
end
function Service.Tick(now)
 local present={}
 local players=Players:GetPlayers()
 for _,source in ipairs(players) do
  present[source]=true
  local c=source.Character
  local elite=c and c:GetAttribute("EliteClass")
  local geist=alive(source) and (elite=="Geist Trooper" or elite=="GeistTrooper")
  local state=hunts[source]
  if state and (not geist or state.character~=c) then clear(source,state);hunts[source]=nil;state=nil end
  if geist and source.Team then
   if not state or now>=state.nextSelection then
    if state then clear(source,state) end
    local nearest,best=nil,RANGE
    for _,enemy in ipairs(players) do
     if enemy~=source and enemy.Team and enemy.Team~=source.Team and alive(enemy) then
      local d=distance(source,enemy)
      if d<best then nearest,best=enemy,d end
     end
    end
    hunts[source]={character=c,target=nearest,nextSelection=now+INTERVAL}
    if nearest then status.GiveStatus(nearest,"HuntedStatus",INTERVAL,source) end
   end
  end
  if alive(source) and (elite=="Radio Trooper" or elite=="RadioTrooper") then
   for _,enemy in ipairs(players) do
    if enemy.Team~=source.Team and alive(enemy) and distance(source,enemy)<RANGE then status.GiveStatus(enemy,"SpottedStatus",1.5,true,source) end
   end
  end
 end
 for source,state in pairs(hunts) do if not present[source] then clear(source,state);hunts[source]=nil end end
end
function Service.start_module()
 if Service.started then return end;Service.started=true
 task.spawn(function() while true do Service.Tick(os.clock());task.wait(.75) end end)
end
return Service
