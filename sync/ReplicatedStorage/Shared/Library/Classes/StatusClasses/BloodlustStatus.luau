local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Bloodlust"}); setmetatable(self,C); self.className="BloodlustStatus"; self.duration=2; return self end
function C:_apply(player,duration) self.duration=duration or 2; local c=player.Character; if c then c:SetAttribute("BloodlustSprintMultiplier",1.2); c:SetAttribute("BloodlustWalkMultiplier",1.3) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("BloodlustSprintMultiplier",nil); c:SetAttribute("BloodlustWalkMultiplier",nil) end end
return C
