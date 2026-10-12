local f=assert(io.open("sync/ReplicatedStorage/Shared/Library/Classes/BaseTool.luau","rb"))
local source=f:read("*a");f:close()
source=assert(source:match("(function BaseTool:_waitAnimation.-)\n%-%- The master waits"))
local now=0;local interrupt
local base={}
local env=setmetatable({BaseTool=base,os={clock=function() return now end},task={wait=function(dt) now=now+dt; if interrupt then interrupt() end end}}, {__index=_G})
assert(load(source,"gun animation wait","t",env))()
local weapon=setmetatable({Equipped=true,_equipGeneration=1},{__index=base})
local function track(length)
 local t={IsPlaying=true,Length=length,Speed=1}
 function t:Stop() self.IsPlaying=false end
 return t
end
local failed=track(0)
weapon:_waitAnimation(failed)
assert(not failed.IsPlaying and now>=4 and now<4.1)
now=0
local working=track(1)
interrupt=function() if now>=.5 then working.IsPlaying=false end end
weapon:_waitAnimation(working)
assert(now>=.5 and now<.55)
now=0
interrupt=function() weapon._equipGeneration=2 end
weapon:_waitAnimation(track(20))
assert(now<.1)
weapon:_waitAnimation(nil)
print("Gun animation waits: failed assets time out, normal completion and replacement cancellation passed")
