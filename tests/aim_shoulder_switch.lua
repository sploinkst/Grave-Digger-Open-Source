local f=assert(io.open('sync/ReplicatedStorage/Shared/Library/Classes/BaseTool.luau','rb'))
local source=f:read('*a');f:close()
local aim=assert(source:match('(function BaseTool:_aimTrack.-)\nfunction BaseTool:_getFireAnim')):gsub(': AnimationTrack%?','')
local change=assert(source:match('(function BaseTool:_onShoulderChanged.-)\n%-%- // Aim system'))
local env=setmetatable({BaseTool={}},{__index=_G})
assert(load(aim..'\n'..change,'aim shoulder switch','t',env))()
local right,left={},{}
local controller=setmetatable({Equipped=true,Aiming=true,Firing=true,current_shoulder='Left',RegisteredAnimations={Aim=right,Aim_Left=left}}, {__index=env.BaseTool})
local selected,killed
controller._blendAim=function(_,track) selected=track end
controller._killAimTracks=function() killed=true end
controller._stopFireAnimations=function() error('Shoulder switch must not interrupt firing') end
controller:_onShoulderChanged();assert(killed and selected==left)
controller.current_shoulder='Right';controller:_onShoulderChanged();assert(selected==right)
controller.RegisteredAnimations.Aim_Left=nil;controller.current_shoulder='Left'
assert(controller:_aimTrack()==right)
controller.Reloading=true;selected=nil;controller:_onShoulderChanged();assert(selected==nil)
controller.Reloading=false;controller:_onShoulderChanged();assert(selected==right)
print('Aim shoulder: immediate side changes preserve firing, missing clips retain a pose and reloads defer the swap')
