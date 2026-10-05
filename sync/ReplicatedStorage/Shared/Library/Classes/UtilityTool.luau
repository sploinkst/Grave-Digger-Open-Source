-- Utility behavior adapters share lifecycle, not a single growing BaseTool branch.
local Players=game:GetService("Players")
local Tool=require(script.Parent.MasterTool)
local Factory={}
function Factory.create(name,asset,kind)
	local Class={}; Class.__index=Class; setmetatable(Class,{__index=Tool})
	Class.Weight=0; Class.Designation=if kind=="Melee" or kind=="Machete" then "Melee" else "Equipment"; Class.Medal_Cost=0
	function Class.new(info)
		local self=setmetatable(Tool.new(info,name,asset),Class)
		self.Kind=kind; self.Designation=Class.Designation; return self
	end
	function Class:activate()
		if not self:Ready() then return end
		if kind=="Repair" then
			if not self.Aiming or self.Repairing then return end
			local character=Players.LocalPlayer.Character
			local legacyClass=character and character:FindFirstChild("class")
			local role=string.lower(tostring(legacyClass and legacyClass.Value or character and character:GetAttribute("Class") or ""))
			local duration=(role=="rook" or role=="engineer") and 1/1.5 or 1
			self.Repairing=true; self:_playAnim("Repair",false,{fade=0.2,speed=asset=="weldingtool" and 1/3 or 1/duration})
			local generation=self._masterGeneration or 0
			task.spawn(function()
				while self.Repairing and self.Equipped and (self._masterGeneration or 0)==generation do
					task.wait(duration/2)
					if not self.Repairing or not self.Equipped or (self._masterGeneration or 0)~=generation then break end
					self:Request("UtilityAction","Repair",self:Direction())
				end
			end)
		elseif kind=="Flag" then
			self.FlagStartedAt=os.clock()
			self:Action("Flag",1.5,function()
				self.FlagStartedAt=nil; self:_playAnim("ThrowOver",false,{speed=1})
				self:Request("UtilityAction","FlagPlace")
			end)
		elseif kind=="Lancer" then
			self:Action("Use",0.4,function() self:Request("UtilityAction","LancerStim") end)
		elseif kind=="Grenade" then
			self.PrimedAt=os.clock()
			self:Action("Prime",self.PrimeTime or 1,function()
				self.PrimedAt=nil
				local underhand=self.Aiming==true
				self:_playAnim(underhand and "ThrowUnder" or "ThrowOver")
				self:Request("UtilityAction","Throw",{direction=self:Direction(),underhand=underhand})
			end)
		elseif kind=="Lantern" then return
		else self:Action("Melee1",0.15,function() self:Request("UtilityAction","Melee",self:Direction()) end) end
	end
	function Class:_on_give()
		self.Deactivation=self.tool.Deactivated:Connect(function()
			if kind=="Grenade" and self.PrimedAt and os.clock()-self.PrimedAt<=0.2 then
				self:CancelAction(); self.PrimedAt=nil
				local prime=self.RegisteredAnimations and self.RegisteredAnimations.Prime
				if prime then prime:Stop(0.2) end
			end
			if kind=="Flag" and self.FlagStartedAt and os.clock()-self.FlagStartedAt<=1.3 then
				self:CancelAction()
				self.FlagStartedAt=nil
				local flag=self.RegisteredAnimations and self.RegisteredAnimations.Flag
				if flag then flag:Stop(0.2) end
			end
			self.Repairing=false
			local track=self.RegisteredAnimations and self.RegisteredAnimations.Repair
			if track then track:Stop(0.2) end
			self:_restoreBaseDeferred()
		end)
	end
	function Class:_onAltInput(pressed)
		if kind=="Bottle" then
			if not pressed then self.Drinking=false; return end
			if not self:Ready() or self.Drinking then return end
			self.Drinking=true
			self:Action("Drink",2,function()
				if not self.Drinking then return end
				self:_playAnim("DrinkMotion")
				local generation=self._masterGeneration
				task.spawn(function()
					while self.Drinking and self.Equipped and self._masterGeneration==generation do
						self:Request("UtilityAction","Drink"); task.wait(2)
					end
					local track=self.RegisteredAnimations and self.RegisteredAnimations.DrinkMotion
					if track then track:Stop(0.1) end
					if self.Equipped and self._masterGeneration==generation then
						self:Action("DrinkDone",2,function() end)
					end
				end)
			end)
		elseif pressed then self:setAltMode() end
	end
	function Class:setAltMode()
		if not self:Ready() then return end
		if kind=="Flag" then self:Action("RaiseFlag",0,function() self:Request("UtilityAction","FlagWave") end,1)
		elseif kind=="Lantern" then self:Request("UtilityAction","Lantern")
		elseif kind=="Machete" then self:Action("Clean",2,function() self:Request("UtilityAction","CleanMachete") end) end
	end
	function Class:_on_unequip()
		self.Repairing=false; self.Drinking=false; Tool._on_unequip(self)
	end
	function Class:destroy()
		self.Repairing=false; self.Drinking=false
		if self.Deactivation then self.Deactivation:Disconnect() end
		Tool.destroy(self)
	end
	return Class
end
return Factory
