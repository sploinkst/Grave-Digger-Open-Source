local BaseStatus=require(script.Parent.Parent.BaseStatus); local C={}; C.__index=C; setmetatable(C,{__index=BaseStatus})
function C.new() local self=BaseStatus.new({name="Clotting"}); setmetatable(self,C); self.className="ClottingStatus"; self.duration=5; return self end
function C:_apply(player,duration) if player.Character and (player.Character:GetAttribute("ClottingImmune") or player.Character:GetAttribute("ChemicalClottingImmune")) then player:SetAttribute(self.name,nil); self.duration=0; return end; self.duration=duration or 5 end
return C
