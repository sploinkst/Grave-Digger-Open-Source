local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Knockdown"}); setmetatable(self,C); self.className="KnockdownStatus"; self.duration=2; return self end
function C:_apply(player,duration) local c=player.Character; if c and c:GetAttribute("ExplosiveKnockdownImmune") then player:SetAttribute(self.name,nil); self.duration=0; return end; self.duration=duration or 2; if c then c:SetAttribute("SprintBlocked",true); c:SetAttribute("JumpBlocked",true); c:SetAttribute("ActionBlocked",true); local h=c:FindFirstChildOfClass("Humanoid"); if h then h.Sit=true end end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("ActionBlocked",nil); if not player:GetAttribute("Cripple") and not player:GetAttribute("Hitstun") then c:SetAttribute("SprintBlocked",nil); c:SetAttribute("JumpBlocked",nil) end end end
return C
