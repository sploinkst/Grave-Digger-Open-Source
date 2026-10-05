local RS=game:GetService("ReplicatedStorage")
local Base=require(script.Parent.Parent.BaseEquipment)
local Factory={}
function Factory.create(name)
	local Class={}; Class.__index=Class; setmetatable(Class,{__index=Base})
	function Class.new()
		local self=setmetatable(Base.new({name=name}),Class)
		self.className=name; self.MaxEquipment=2; self.EquipmentReloadTime=30
		self.InstantActivate=true; self.UnequipHeldToolsOnActivate=true
		return self
	end
	function Class:GetCount() return self.Character and self.Character:GetAttribute(name.."Charges") or 2 end
	function Class:SpecialStart()
		local function refresh()
			local gui=self:_getEquipmentGui(); local label=gui and gui:FindFirstChild("count")
			if label then label.Text=tostring(self:GetCount()) end
		end
		self.ChargeConnection=self.Character:GetAttributeChangedSignal(name.."Charges"):Connect(refresh); refresh()
	end
	function Class:StartCount() end -- Server recharge owns the count.
	function Class:Activate()
		local camera=workspace.CurrentCamera
		if self.Stopped or not camera or self:GetCount()<=0 then return end
		RS.Shared.Library.Events:WaitForChild("OrdnanceAction"):FireServer(nil,name,camera.CFrame.LookVector)
	end
	function Class:Stop()
		if self.ChargeConnection then self.ChargeConnection:Disconnect(); self.ChargeConnection=nil end
		Base.Stop(self)
	end
	return Class
end
return Factory
