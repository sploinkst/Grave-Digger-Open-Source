local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Sickness"}); setmetatable(self,C); self.className="SicknessStatus"; return self end
function C:_apply(player,duration) self.duration=duration; local c=player.Character; if c then c:SetAttribute("DebuffRecoilMultiplier",1.35); c:SetAttribute("PositiveStimulantsPaused",true) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("DebuffRecoilMultiplier",nil); c:SetAttribute("PositiveStimulantsPaused",nil) end end
return C
