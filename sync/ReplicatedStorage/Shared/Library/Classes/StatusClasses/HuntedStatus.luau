local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Hunted"}); setmetatable(self,C); self.className="HuntedStatus"; self.duration=2; return self end
function C:_apply(player,duration,hunter) self.duration=duration or 2; player:SetAttribute("HuntedByUserId",hunter and hunter.UserId or nil) end
function C:_un_apply(player) player:SetAttribute("HuntedByUserId",nil) end
return C
