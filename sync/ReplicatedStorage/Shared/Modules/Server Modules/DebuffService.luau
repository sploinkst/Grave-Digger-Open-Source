local Players=game:GetService("Players"); local Service={}; local status=require(script.Parent.StatusService)
local function root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function alive(p) local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
local function distance(a,b) local x,y=root(a),root(b); return x and y and (x.Position-y.Position).Magnitude or math.huge end
function Service.start_module()
	task.spawn(function() while true do task.wait(.75); for _,source in Players:GetPlayers() do
		if not alive(source) then continue end; local c=source.Character; local elite=c:GetAttribute("EliteClass")
		if elite=="Geist Trooper" then local choices={}; for _,enemy in Players:GetPlayers() do if enemy.Team~=source.Team and alive(enemy) and distance(source,enemy)<75 then table.insert(choices,enemy) end end; table.sort(choices,function(a,b) local ac,bc=a.Character,b.Character; local ash=ac and ac:GetAttribute("IsShockTrooper"); local bsh=bc and bc:GetAttribute("IsShockTrooper"); if ash~=bsh then return ash==true end; return distance(source,a)<distance(source,b) end); if choices[1] then status.GiveStatus(choices[1],"HuntedStatus",2,source) end end
		if elite=="Radio Trooper" then for _,enemy in Players:GetPlayers() do if enemy.Team~=source.Team and alive(enemy) and distance(source,enemy)<75 then status.GiveStatus(enemy,"SpottedStatus",1.5,true,source) end end end
	end end end)
end
return Service
