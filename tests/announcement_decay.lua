local rows,delays,tweens={},{},{}
local layout={}
local example={Visible=true}
function example:Clone()
 local row={}
 function row:Destroy() self.Parent=nil;self.destroyed=true end
 rows[#rows+1]=row;return row
end
local main={Example=example,FindFirstChildWhichIsA=function() return layout end}
local env=setmetatable({script={Parent={Main=main}},Enum={SortOrder={LayoutOrder='order'},VerticalAlignment={Bottom='bottom'},EasingStyle={Linear='linear'}},
 TweenInfo={new=function() return {} end},task={delay=function(time,callback) delays[#delays+1]={time,callback} end}}, {__index=_G})
env.math=setmetatable({clamp=function(n,lo,hi) return math.max(lo,math.min(hi,n)) end},{__index=math})
env.game={GetService=function() return {Create=function(_,row,info,props)
 tweens[#tweens+1]=props;return {Play=function() end,Completed={Wait=function() end}}
end} end}
local f=assert(io.open('sync/ReplicatedStorage/Shared/Library/UI/Notifications/Utils.luau','rb'))
local source=f:read('*a');f:close();source=source:gsub('serial%+=1','serial=serial+1')
local notifications=assert(load(source,'announcement decay','t',env))()
notifications.send_notification({},'First',5);notifications.send_notification({},'Second',5)
assert(not example.Visible and layout.VerticalAlignment=='bottom')
assert(rows[1].LayoutOrder<rows[2].LayoutOrder and delays[1][1]==5)
delays[1][2]();assert(rows[1].destroyed and not rows[2].destroyed)
assert(tweens[#tweens].TextTransparency==1 and tweens[#tweens].TextStrokeTransparency==1)
delays[2][2]();assert(rows[2].destroyed)
print('Announcements: ordered upward stack, independent expiry and text/stroke fade passed')
