local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="MinorBurn"}); setmetatable(self,C); self.className="MinorBurnStatus"; self.duration=5; return self end
function C:_apply(player,duration) self.duration=duration or 5; local c=player.Character; if c then c:SetAttribute("BurnMovementMultiplier",.65); c:SetAttribute("SurgeryBlocked",true); c:SetAttribute("Burning",true); task.spawn(function() local h=c:FindFirstChildOfClass("Humanoid"); while player:GetAttribute("MinorBurn") and c.Parent and h and h.Health>0 do task.wait(1); if player:GetAttribute("MinorBurn") then h:TakeDamage(5) end end end) end end
function C:_un_apply(player) local c=player.Character; if c then c:SetAttribute("BurnMovementMultiplier",nil); c:SetAttribute("SurgeryBlocked",nil); c:SetAttribute("Burning",nil) end end
return C
