Service.start_module()
local attacker = character(Vector3.new(0,0,0), "lance")
local p = player(attacker, "A")
local a = character(Vector3.new(0,0,-5)); player(a,"B")
local b = character(Vector3.new(2,0,-5)); player(b,"B")
local friend = character(Vector3.new(0,0,-5)); player(friend,"A")
local behind = character(Vector3.new(0,0,5)); player(behind,"B")
local far = character(Vector3.new(0,0,-8)); player(far,"B")
parts = {a.children.Head,a.children.HumanoidRootPart,b.children.Head,friend.children.Head,behind.children.Head,far.children.Head}
remote.OnServerEvent.callback(p, "Sweep", facing)
equal(a.children.Humanoid.Health,500,"windup delays damage")
advance(.15)
equal(a.children.Humanoid.Health,370,"sweep hits once per target")
equal(b.children.Humanoid.Health,370,"sweep hits multiple enemies")
equal(friend.children.Humanoid.Health,500,"sweep excludes teammates")
equal(behind.children.Humanoid.Health,500,"sweep excludes rear targets")
equal(far.children.Humanoid.Health,500,"sweep range")
remote.OnServerEvent.callback(p,"Sweep",facing); advance(.15)
equal(a.children.Humanoid.Health,370,"swing cooldown enforced")
advance(1)
castResult = {Instance = a.children.HumanoidRootPart}
remote.OnServerEvent.callback(p,"Stab",facing); advance(.15)
equal(a.children.Humanoid.Health,180,"stab body damage 190")
equal(b.children.Humanoid.Health,370,"stab only one target")
advance(1)
castResult = nil
remote.OnServerEvent.callback(p,"Stab",facing); advance(.15)
equal(b.children.Humanoid.Health,370,"missed stab has no sweep fallback")
advance(1)
castResult = {Instance = b.children.Head}
remote.OnServerEvent.callback(p,"Stab",facing); advance(.15)
equal(b.children.Humanoid.Health,0,"unhelmeted headshot kills")
advance(1)
a.helmet = node("Helmet","Model")
castResult = {Instance = a.children.Head}
a.children.Humanoid.Health = 500
remote.OnServerEvent.callback(p,"Stab",facing); advance(.15)
equal(a.children.Humanoid.Health,310,"helmet prevents instant kill")
equal(a.helmet:GetAttribute("Knocked"),true,"stab knocks helmet")
advance(1)
castResult = nil
remote.OnServerEvent.callback(p,"Sweep",facing)
attacker.children.lance.Parent = nil
advance(.15)
equal(a.children.Humanoid.Health,310,"unequip cancels windup")
attacker.children.lance.Parent = attacker
local guard = character(Vector3.new(0,0,-5),"shield"); player(guard,"B")
guard.children.HumanoidRootPart.CFrame.LookVector = Vector3.new(0,0,1)
guard:SetAttribute("ShieldRaised",true)
equal(Service.Blocks(guard,attacker.children.Head.Position),true,"raised frontal shield blocks")
equal(Service.Blocks(guard,Vector3.new(0,0,-10)),false,"rear attack bypasses shield")
guard:SetAttribute("ShieldRaised",false)
equal(Service.Blocks(guard,attacker.children.Head.Position),false,"lowered shield does not block")
attacker:SetAttribute("Class","Lancer")
attacker:SetAttribute("Equipment","ThrowingAxes")
RunService.Heartbeat.callback()
equal(attacker:GetAttribute("ThrowingAxesCount"),4,"initial axe supply")
local state = stateFor(attacker)
state.prepared = now - .25
remote.OnServerEvent.callback(p,"ThrowAxe",facing)
equal(state.axes,3,"throw consumes one axe")
equal(state.regen,now+20,"axe regen scheduled")
remote.OnServerEvent.callback(p,"ThrowAxe",facing)
equal(state.axes,3,"repeat throw cannot consume without preparing")
-- Avoid simulating visuals; exercise the regeneration clock directly.
scheduled = {}
advance(20); RunService.Heartbeat.callback()
equal(state.axes,4,"one axe returns after 20 seconds")
local duration,cooldown,count = Rules.ChargePerks(false,false)
equal(duration,3,"default charge duration"); equal(cooldown,3,"default charge cooldown"); equal(count,1,"default one target")
duration,cooldown,count = Rules.ChargePerks(true,true)
equal(duration,5,"perk charge duration"); equal(cooldown,2,"Butcher cooldown"); equal(count,3,"Veteran targets")
equal(validDirection(Vector3.new(0/0,0,0)),false,"reject NaN direction")
equal(validDirection(Vector3.new(math.huge,0,0)),false,"reject infinite direction")
local regenTick = RunService.Heartbeat.callback
local axeTarget = character(Vector3.new(0,0,-5)); player(axeTarget,"B")
local function axeHit(part)
	advance(1)
	state.prepared = now - .25
	remote.OnServerEvent.callback(p,"ThrowAxe",facing)
	advance(.2)
	castResult = {Instance = part, Position = part.Position}
	RunService.Heartbeat.callback(.05)
	RunService.Heartbeat.callback = regenTick
end
axeHit(axeTarget.children.HumanoidRootPart)
equal(axeTarget.children.Humanoid.Health,301,"axe deals 199")
axeTarget.children.Humanoid.Health = 500
axeTarget.helmet = node("Helmet","Model")
axeHit(axeTarget.children.Head)
equal(axeTarget.children.Humanoid.Health,301,"helmeted axe headshot deals 199")
equal(axeTarget.helmet:GetAttribute("Knocked"),true,"axe knocks helmet off")
axeHit(axeTarget.children.Head)
equal(axeTarget.children.Humanoid.Health,0,"unhelmeted axe headshot kills")
advance(1)
state.prepared = now
local axesBefore = state.axes
remote.OnServerEvent.callback(p,"ThrowAxe",facing)
remote.OnServerEvent.callback(p,"CancelAxe")
advance(.25)
equal(state.axes,axesBefore,"cancel during draw prevents throw")
local survivor = character(Vector3.new(0,0,0))
survivor:SetAttribute("Class","Lancer")
survivor.children.CharacterData = node("CharacterData","Folder", {Perks = node("Perks","Folder", {Survivalist = node("Survivalist","BoolValue")})})
survivor.children.CharacterData.children.Perks.children.Survivalist.Value = true
player(survivor,"A"); regenTick()
equal(survivor:GetAttribute("ThrowingAxesCount"),6,"Survivalist axe supply")
local shieldUser = player(character(Vector3.new(0,0,0),"shield"),"A")
castResult = nil; parts = {a.children.Head}
local before = a.children.Humanoid.Health
remote.OnServerEvent.callback(shieldUser,"ShieldSwing",facing); advance(.15)
equal(a.children.Humanoid.Health,before-90,"shield strike deals damage")
remote.OnServerEvent.callback(shieldUser,"Block",true)
equal(shieldUser.Character:GetAttribute("ShieldRaised"),false,"cannot block during shield strike")
advance(1); remote.OnServerEvent.callback(shieldUser,"Block",true)
equal(shieldUser.Character:GetAttribute("ShieldRaised"),true,"can raise shield after strike")
local charger = player(character(Vector3.new(0,0,0),"lance"),"A")
charger.Character.children.HumanoidRootPart.AssemblyLinearVelocity = facing * 18
local victim = character(Vector3.new(0,0,-5)); player(victim,"B")
castResult = nil
remote.OnServerEvent.callback(charger,"Charge",facing)
equal(charger.Character:GetAttribute("charging"),true,"full sprint starts charge")
castResult = {Instance = victim.children.Head}
RunService.Heartbeat.callback(.05)
equal(victim.children.Humanoid.Health,0,"charge collision kills")
equal(charger.Character:GetAttribute("charging"),nil,"charge ends after first target")
equal(charger.Character:GetAttribute("CombatStunned"),true,"charge kill recovery")
advance(1)
equal(charger.Character:GetAttribute("CombatStunned"),nil,"charge recovery clears")
remote.OnServerEvent.callback(charger,"Charge",facing)
equal(charger.Character:GetAttribute("charging"),nil,"charge cooldown enforced")
advance(3); castResult = nil
remote.OnServerEvent.callback(charger,"Charge",facing)
local wall = node("Wall","Part"); wall.CanCollide = true; wall.Parent = workspace
castResult = {Instance = wall}
RunService.Heartbeat.callback(.05)
equal(charger.reply,"ChargeStop","obstacle stops charge")
equal(charger.Character:GetAttribute("CombatStunned"),true,"obstacle recovery")
advance(4); castResult = nil
remote.OnServerEvent.callback(charger,"Charge",facing)
charger.Character.children.lance.Parent = nil
RunService.Heartbeat.callback(.05)
equal(charger.Character:GetAttribute("charging"),nil,"unequip cancels charge")
print("Class combat behavior checks passed")
