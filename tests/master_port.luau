local checks=0
local function check(condition)
	assert(condition,"Check "..(checks+1).." failed"); checks+=1
end
local function loadRules()
__RULES__
end
local rules=loadRules()
for _,invalid in ipairs({math.huge,-math.huge,0/0,"1"}) do check(not rules.Finite(invalid)) end
check(rules.CanSpend(2,2,1,2))
for _,args in ipairs({{1,2,0,2},{2,2,2,2},{2,-1,0,2},{0/0,1,0,2}}) do check(not rules.CanSpend(table.unpack(args))) end
check(rules.ConstructionState(0,100,100)=="unfinished")
check(rules.ConstructionState(100,100,100)=="finished")
check(rules.ConstructionState(100,0,100)=="damaged")
check(rules.CanVote("truce",true,true,false,"fight"))
for _,args in ipairs({{"capture",true,true,false,"truce"},{"truce",false,true,false,"fight"},{"truce",true,false,false,"fight"},{"truce",true,true,true,"fight"},{"truce",true,true,false,"other"}}) do check(not rules.CanVote(table.unpack(args))) end
check(rules.CanSurrender(true,true,false,false,false))
for _,args in ipairs({{false,true,false,false,false},{true,false,false,false,false},{true,true,true,false,false},{true,true,false,true,false},{true,true,false,false,true}}) do check(not rules.CanSurrender(table.unpack(args))) end

local now=0
local os={clock=function() return now end}
local function typeof(value) return type(value)=="table" and value.kind or type(value) end
local players={}
local rs={Shared={Library={MasterPortRules=rules}}}
local game={GetService=function(_,name) return name=="Players" and players or rs end}
local require=function() return rules end
local attributes={}
local character={Parent={},FindFirstChildOfClass=function() return {Health=100} end,
	FindFirstChild=function() return {} end,GetAttribute=function(_,name) return attributes[name] end}
local player={Parent=players,Character=character,GetAttribute=function() return false end}
local tool={kind="Instance",Name="ConstructHammer",Parent=character,IsA=function(_,name) return name=="Tool" end,
	FindFirstChild=function() return nil end,GetAttribute=function() return nil end}
local function loadValidation()
__VALIDATION__
end
local validation=loadValidation()
check(validation.Tool(player,tool,{"ConstructHammer"})~=nil)
check(validation.Tool(player,tool,{"Wrench"})==nil)
attributes.ActionBlocked=true; check(validation.Tool(player,tool,{"ConstructHammer"})==nil)
attributes.ActionBlocked=nil
tool.Parent={}; check(validation.Tool(player,tool,{"ConstructHammer"})==nil); tool.Parent=character
check(validation.Cooldown(player,"Place",0.5)); check(not validation.Cooldown(player,"Place",0.5))
now=0.5; check(validation.Cooldown(player,"Place",0.5))
player.Character={}; check(validation.Cooldown(player,"Place",0.5)); player.Character=character
for _,invalid in ipairs({0/0,math.huge}) do check(not validation.Vector({kind="Vector3",X=invalid,Y=0,Z=0})) end
check(validation.Vector({kind="Vector3",X=1,Y=2,Z=3}))

local callbacks={}
local task={delay=function(_,callback) table.insert(callbacks,callback) end,defer=function(callback) callback() end}
players.LocalPlayer={Character=character}
rs.Shared.Assets={Guns={Effects={}}}
local script={Parent={Parent={AuthoredAssets={},MasterToolDefinitions={}},BaseTool={}}}
local base={}
require=function(ref) return ref==script.Parent.BaseTool and base or {} end
local function loadTool()
__TOOL__
end
local controller=loadTool()
local function newTool()
	return setmetatable({Equipped=true,tool=tool,Ready=function() return true end,
		_playAnim=function() end,_restoreBaseDeferred=function() end},{__index=controller})
end
local fired=0
local t=newTool(); t:Action("Use",1,function() fired+=1 end); t:CancelAction(); callbacks[1](); check(fired==0)
t=newTool(); t:Action("Use",1,function() fired+=1 end); t.Equipped=false; callbacks[2](); check(fired==0)
t=newTool(); t:Action("Use",1,function() fired+=1 end); callbacks[3](); check(fired==1)

local mouse={MouseBehavior="Default",MouseIconEnabled=true}
local gui={SelectedObject="button"}
game.GetService=function(_,name)
	if name=="UserInputService" then return mouse elseif name=="GuiService" then return gui elseif name=="Players" then return players else return rs end
end
local Enum={KeyCode={}}
local function loadSelection()
__SELECTION__
end
local viewClass=loadSelection()
local destroyed,disconnected,closed=0,0,0
local v=viewClass.new(function() end,function() return true end,"Selecting",function() closed+=1 end)
v.Selecting=true; v.Character={Parent={},SetAttribute=function() end}
v.Buttons={{Destroy=function() destroyed+=1 end}}
v.Connections={{Disconnect=function() disconnected+=1 end}}
v:Close(); v:Close()
check(destroyed==1); check(disconnected==1); check(closed==1)
local function loadCharges()
__CHARGES__
end
local charges=loadCharges()
local stock=charges.New(2)
check(charges.Consume(stock,2,30,100)); check(stock.count==1)
check(charges.Consume(stock,2,30,101)); check(stock.count==0)
check(not charges.Consume(stock,2,30,102))
check(charges.Refresh(stock,2,30,129)==0)
check(charges.Refresh(stock,2,30,130)==1)
check(charges.Refresh(stock,2,30,160)==2)
check(charges.Refresh(stock,2,30,1000)==2)
check(charges.Consume(stock,2,30,1000)); check(stock.recharge==1030)
local disposable=charges.New(1)
check(charges.Consume(disposable,1,0,100))
check(charges.Refresh(disposable,1,0,10000)==0)
check(not charges.Consume(disposable,1,0,10000))
script.Parent.MasterTool=controller
require=function() return controller end
local function loadUtility()
__UTILITY__
end
local utility=loadUtility()
local grenade=utility.create("NebelGrenade","nebel","Grenade")
local deactivated,requests,stops
local function grenadeInstance()
	requests=0; stops=0
	tool.Deactivated={Connect=function(_,callback) deactivated=callback; return {Disconnect=function() end} end}
	local instance=newTool(); setmetatable(instance,{__index=grenade})
	instance.PrimeTime=1; instance.Aiming=true
	instance.RegisteredAnimations={Prime={Stop=function() stops+=1 end}}
	instance.Direction=function() return "validated-direction" end
	instance.Request=function(_,remote,action,argument)
		check(remote=="UtilityAction" and action=="Throw")
		check(argument.underhand and argument.direction=="validated-direction")
		requests+=1
	end
	instance:_on_give(); return instance
end
now=0; local g=grenadeInstance(); g:activate()
local early=callbacks[#callbacks]
now=0.1; deactivated(); early(); check(requests==0 and stops==1)
now=10; g=grenadeInstance(); g:activate()
local committed=callbacks[#callbacks]
now=10.3; deactivated(); now=11; committed(); check(requests==1 and stops==0)
now=20; g=grenadeInstance(); g:activate()
local canceled=callbacks[#callbacks]
g:CancelAction(); now=21; canceled(); check(requests==0)
local restored=0
t=newTool(); t._restoreBaseDeferred=function() restored+=1 end
t:Action("Telescope",0.1,function() fired+=1 end,0.7)
local impact=callbacks[#callbacks]; check(t._masterAction)
impact(); check(t._masterAction and restored==0)
local recover=callbacks[#callbacks]; recover(); check(not t._masterAction and restored==1)
t:Action("Flare",0.5,function() fired+=1 end,0.5)
callbacks[#callbacks](); local staleRecovery=callbacks[#callbacks]
t:CancelAction(); staleRecovery(); check(restored==1)
print("Passed "..checks.." master-port rules, validation, cancellation, cleanup, recharge, and grenade checks")
