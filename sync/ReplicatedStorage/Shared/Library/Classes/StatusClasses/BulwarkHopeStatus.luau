local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="BulwarkHope"}); setmetatable(self,C); self.className="BulwarkHopeStatus"; self.duration=2; return self end
function C:_apply(player,duration) local c=player.Character; if c and c:GetAttribute("Class")=="Vanguard" then player:SetAttribute(self.name,nil); return end; self.duration=duration or 2; if c then c:SetAttribute("BulwarkFireRateMultiplier",1.1); c:SetAttribute("BulwarkSurgeryMultiplier",1.15) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("BulwarkFireRateMultiplier",nil); c:SetAttribute("BulwarkSurgeryMultiplier",nil) end end
return C
