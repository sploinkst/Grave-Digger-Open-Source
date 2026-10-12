local function module(path) return dofile('sync/ReplicatedStorage/Shared/'..path..'.luau') end
local metadata=module('Library/ToolMetadata')
local child={Value=2,IsA=function(_,kind) return kind=='ValueBase' end}
local tool={Name='Display Name',FindFirstChild=function(_,name) if name=='slot' then return child end end,GetAttribute=function() return false end}
local key,designation=metadata.Slot(tool)
assert(key=='2' and designation=='Secondary')
child.Value='Mining';key,designation=metadata.Slot(tool);assert(key=='4' and designation=='Mining')
child.Value=1.5;key,designation=metadata.Slot(tool);assert(key==nil and designation==nil)
child.Value='Primary Sling';key,designation=metadata.Slot(tool);assert(key=='1' and designation=='Primary')
child.Value='unknown';key,designation=metadata.Slot(tool);assert(key==nil and designation==nil)
local marker={Value=false,IsA=function(_,kind) return kind=='BoolValue' end}
local hiddenTool={GetAttribute=function() return false end,FindFirstChild=function() return marker end}
assert(not metadata.Hidden(hiddenTool));marker.Value=true;assert(metadata.Hidden(hiddenTool))
assert(metadata.Weapon(tool)=='Display Name' and not metadata.Hidden(tool))
local settings=module('Library/MasterClientSettings')
local current={Value=false,IsA=function() return true end}
local data={GetDescendants=function() return {{Name='HideChat',FindFirstChild=function() return current end}} end}
assert(settings.Read(data,'hidechat',true)==false)
assert(settings.Read(nil,'hidechat',true)==true)
assert(settings.BindName('equipment')=='Class Equipment')
local players={}
game={GetService=function(_,name) assert(name=='Players');return players end}
local vote=module('Modules/Server Modules/GameManager/MapVote')
local models={{Name='A',IsA=function() return true end},{Name='B',IsA=function() return true end}}
local folder={GetChildren=function() return models end,FindFirstChild=function(_,name) for _,item in ipairs(models) do if item.Name==name then return item end end end}
local last
local event={FireAllClients=function(_,action,payload) last=payload end,FireClient=function(_,player,action,payload) last=payload end}
local p={Team={},Parent=players,GetAttribute=function() return true end}
local q={Team={},Parent=players,GetAttribute=function() return true end}
assert(not vote.Select(p,'A'))
vote.Open(folder,event);assert(last.visible and #last.choices==2)
assert(not vote.Select(p,'unknown'))
assert(vote.Select(p,'A') and vote.Select(p,'B'))
assert(last.choices[1].votes==0 and last.choices[2].votes==1)
assert(vote.Select(q,'A'));q.Parent=nil
assert(vote.Resolve()==models[2] and not last.visible)
assert(not vote.Select(p,'A'))
vote.Open(folder,event);assert(vote.Resolve()==nil)
vote.Replay(p);assert(not last.visible)
print('Master client port: slot metadata, false settings, vote validation, vote replacement, departed voters and replay passed')
