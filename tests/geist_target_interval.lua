local players,applied,removed={},{},{}
local function position(n) return setmetatable({n=n},{__sub=function(a,b) return {Magnitude=math.abs(a.n-b.n)} end}) end
local function player(id,team,n,elite)
 local attrs={};local root={Position=position(n)};local humanoid={Health=100}
 local char={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return humanoid end,GetAttribute=function(_,name) return name=='EliteClass' and elite end}
 return {UserId=id,Team=team,Character=char,root=root,humanoid=humanoid,attrs=attrs,GetAttribute=function(_,key) return attrs[key] end}
end
local hunter=player(1,'A',0,'Geist Trooper');local near=player(2,'B',10);local far=player(3,'B',20)
players={hunter,near,far}
game={GetService=function() return {GetPlayers=function() return players end} end}
script={Parent={StatusService='status'}}
require=function() return {
 GiveStatus=function(target,name,duration,source) applied[#applied+1]={target,duration};target.attrs.HuntedByUserId=source.UserId end,
 RemoveStatus=function(target) removed[#removed+1]=target;target.attrs.HuntedByUserId=nil end,
} end
local service=dofile('sync/ReplicatedStorage/Shared/Modules/Server Modules/DebuffService.luau')
service.Tick(0);assert(#applied==1 and applied[1][1]==near and applied[1][2]==15)
far.root.Position=position(1)
service.Tick(7);service.Tick(14.99);assert(#applied==1)
service.Tick(15);assert(#applied==2 and applied[2][1]==far and removed[1]==near)
far.humanoid.Health=0;service.Tick(16);assert(#applied==2)
service.Tick(30);assert(#applied==3 and applied[3][1]==near)
hunter.humanoid.Health=0;service.Tick(31);assert(near.attrs.HuntedByUserId==nil)
print('Geist: nearest enemy selected at 15-second intervals, no mid-interval replacement, hunter death clears target')
