local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Spotted"}); setmetatable(self,C); self.className="SpottedStatus"; self.duration=10; return self end
function C:_apply(player,duration,enhanced,source) local c=player.Character; if c and c:GetAttribute("Apparition") and not enhanced then player:SetAttribute(self.name,nil); self.duration=0; return end; self.duration=duration or 10; player:SetAttribute("SpottedEnhanced",enhanced==true); player:SetAttribute("SpottedByUserId",source and source.UserId or nil) end
function C:_un_apply(player) player:SetAttribute("SpottedEnhanced",nil); player:SetAttribute("SpottedByUserId",nil) end
return C
