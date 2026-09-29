local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Cripple"}); setmetatable(self,C); self.className="CrippleStatus"; self.duration=3; return self end
function C:_apply(player,duration) local c=player.Character; if c and c:GetAttribute("Greyhound") then player:SetAttribute(self.name,nil); self.duration=0; return end; self.duration=duration or 3; if c then c:SetAttribute("DebuffMovementMultiplier",.6); c:SetAttribute("DebuffAimSpeedMultiplier",.75); c:SetAttribute("SprintBlocked",true); c:SetAttribute("JumpBlocked",true) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("DebuffMovementMultiplier",nil); c:SetAttribute("DebuffAimSpeedMultiplier",nil); if not player:GetAttribute("Knockdown") and not player:GetAttribute("Hitstun") then c:SetAttribute("SprintBlocked",nil); c:SetAttribute("JumpBlocked",nil) end end end
return C
