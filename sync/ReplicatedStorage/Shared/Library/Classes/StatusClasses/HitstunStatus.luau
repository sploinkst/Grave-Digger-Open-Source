local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Hitstun"}); setmetatable(self,C); self.className="HitstunStatus"; self.duration=1; return self end
function C:_apply(player,duration) self.duration=duration or 1; local c=player.Character; if c then c:SetAttribute("SprintBlocked",true); c:SetAttribute("JumpBlocked",true) end end
function C:_un_apply(player) local c=player.Character; if c and not player:GetAttribute("Cripple") and not player:GetAttribute("Knockdown") then c:SetAttribute("SprintBlocked",nil); c:SetAttribute("JumpBlocked",nil) end end
return C
