local attrs={SpawnChoice='engineer'}
workspace={}
game={GetService=function() return {GetTagged=function() return {} end} end}
local player={Team={Name='Golden Empire'},GetAttribute=function(_,key) return attrs[key] end,SetAttribute=function(_,key,value) attrs[key]=value end}
local selection=dofile('sync/ReplicatedStorage/Shared/Modules/Server Modules/GameManager/SpawnSelection.luau')
assert(selection.Options(player).engineer==false)
assert(not selection.Select(player,'engineer'))
assert(selection.CFrame(player)==nil and attrs.SpawnChoice=='base')
assert(selection.Select(player,'base'))
print('Engineer respawns: requests rejected and old engineer selections fall back to base')
