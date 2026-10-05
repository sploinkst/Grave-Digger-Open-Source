local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Morale"}); setmetatable(self,C); self.className="MoraleStatus"; return self end
function C:_apply(player,duration) local c=player.Character; if c and c:GetAttribute("Veteran") then player:SetAttribute(self.name,nil); return end; self.duration=duration; if c then c:SetAttribute("MoraleSprintMultiplier",1.1); c:SetAttribute("MoraleReloadMultiplier",1/0.7) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("MoraleSprintMultiplier",nil); c:SetAttribute("MoraleReloadMultiplier",nil) end end
return C
