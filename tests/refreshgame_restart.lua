local path='sync/ReplicatedStorage/Shared/Modules/Server Modules/CommandService/Commands/03 - Executives/refreshGameServer.luau'
local calls,timers={},{}
local function signal() return {Connect=function(self,callback) self.callback=callback end} end
local players={PlayerAdded=signal(),PlayerRemoving=signal()}
local one={Parent=players};local two={Parent=players}
function one:Kick(message) self.kicked=message end
function two:Kick(message) self.kicked=message end
function players:GetPlayers() return {one,two} end
local studio=false
local teleport={TeleportInitFailed=signal(),ReserveServerAsync=function(_,place) assert(place==123);return 'fresh-code' end,
 TeleportAsync=function(_,place,group,options) calls[#calls+1]={place=place,group=group,options=options} end}
game={PlaceId=123,JobId='old-job',GetService=function(_,service)
 if service=='Players' then return players elseif service=='TeleportService' then return teleport
 elseif service=='RunService' then return {IsStudio=function() return studio end}
 else return {Shared={Library={Events={FindFirstChild=function() return nil end}}}} end
end}
local attributes={};workspace={SetAttribute=function(_,key,value) attributes[key]=value end}
Instance={new=function() return {SetTeleportData=function(self,data) self.data=data end} end}
task={wait=function() end,spawn=function(callback,...) callback(...) end,delay=function(seconds,callback) timers[#timers+1]={seconds,callback} end}
local command=dofile(path)
assert(command():find('Restarting'))
assert(#calls==1 and calls[1].place==123 and #calls[1].group==2)
assert(calls[1].options.ReservedServerAccessCode=='fresh-code' and attributes.ServerRefreshing)
assert(command():find('already'))
teleport.TeleportInitFailed.callback(one,nil,nil,123,calls[1].options)
timers[#timers][2]();assert(#calls==2 and calls[2].group[1]==one)
assert(calls[2].options.ReservedServerAccessCode=='fresh-code')
for _,timer in ipairs(timers) do if timer[1]==45 then timer[2]() end end
assert(one.kicked and two.kicked)
studio=true;command=dofile(path);assert(command():find('Studio') and #calls==2)
print('Refreshgame: fresh same-place destination, shared reservation, retry, duplicate protection, drain deadline and Studio guard passed')
