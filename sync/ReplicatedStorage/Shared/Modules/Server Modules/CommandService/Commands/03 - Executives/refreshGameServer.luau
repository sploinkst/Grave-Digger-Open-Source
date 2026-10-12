local TeleportService=game:GetService("TeleportService")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local refreshing=false

return function()
 if RunService:IsStudio() then return "Refresh requires a published server; Studio cannot teleport players." end
 if refreshing then return "This server is already restarting." end
 refreshing=true
 local reserved,code=pcall(function() return TeleportService:ReserveServerAsync(game.PlaceId) end)
 if not reserved then refreshing=false;return "Could not create a fresh server: "..tostring(code) end
 workspace:SetAttribute("ServerRefreshing",true)
 local attempts,inflight={},{}
 local teleport
 local function retry(player)
  inflight[player]=nil
  if player.Parent~=Players then return end
  if (attempts[player] or 0)>=5 then
   player:Kick("Server restarted for an update. Please rejoin the experience.")
   return
  end
  task.delay(2,function() if player.Parent==Players and not inflight[player] then teleport({player}) end end)
 end
 teleport=function(group)
  local ready={}
  for _,player in ipairs(group) do
   if player.Parent==Players and not inflight[player] then
    attempts[player]=(attempts[player] or 0)+1;inflight[player]=true;table.insert(ready,player)
   end
  end
  if #ready==0 then return end
  local options=Instance.new("TeleportOptions")
  options.ReservedServerAccessCode=code
  options:SetTeleportData({serverRefresh=true,previousJobId=game.JobId})
  local ok,problem=pcall(function() TeleportService:TeleportAsync(game.PlaceId,ready,options) end)
  if not ok then
   warn("[refreshgame] Teleport failed: "..tostring(problem))
   for _,player in ipairs(ready) do retry(player) end
  end
 end
 TeleportService.TeleportInitFailed:Connect(function(player,result,message,placeId,options)
  if placeId==game.PlaceId and options and options.ReservedServerAccessCode==code and inflight[player] then retry(player) end
 end)
 Players.PlayerAdded:Connect(function(player) task.spawn(teleport,{player}) end)
 Players.PlayerRemoving:Connect(function(player) attempts[player]=nil;inflight[player]=nil end)
 local presentation=game:GetService("ReplicatedStorage").Shared.Library.Events:FindFirstChild("Presentation")
 if presentation then presentation:FireAllClients("global_alert",{message="Server updating. Moving everyone to a fresh server...",duration=5}) end
 task.spawn(function()
  task.wait(2)
  local group={}
  for _,player in ipairs(Players:GetPlayers()) do
   table.insert(group,player)
   if #group==50 then teleport(group);group={} end
  end
  teleport(group)
 end)
 task.delay(45,function()
  for _,player in ipairs(Players:GetPlayers()) do player:Kick("Server restarted for an update. Please rejoin the experience.") end
 end)
 return "Restarting: everyone is being moved to a newly reserved server running the published version."
end
