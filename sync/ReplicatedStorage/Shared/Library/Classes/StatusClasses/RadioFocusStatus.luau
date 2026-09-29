local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="RadioFocus"}); setmetatable(self,C); self.className="RadioFocusStatus"; self.duration=2; return self end
function C:_apply(player,duration) self.duration=duration or 2; local c=player.Character; if c then c:SetAttribute("RadioFocusFireRateMultiplier",1.25) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("RadioFocusFireRateMultiplier",nil) end end
return C
