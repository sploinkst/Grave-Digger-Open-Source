-- Executes the real playback and phase-wait methods with recording tracks.
local checks=0
local function check(value) assert(value,"Animation check "..(checks+1).." failed"); checks+=1 end
local function close(a,b) check(math.abs(a-b)<0.00001) end
local function loadRules()
__ANIMATION_RULES__
end
local MasterAnimationRules=loadRules()
local gun={IsFirearm=true,MasterAssetName="lebel",FireInterval=0.3,cycle=0.55,
	reload_start=1.6,reload_empty=1.45,reload_loop=0.65,reload_end=1.45,reload_full=1.8,
	Capacity=3,RegisteredAnimations={Cycle={}}}
close(MasterAnimationRules.Playback(gun,"Fire").speed,1)
gun.RegisteredAnimations.Cycle=nil
close(MasterAnimationRules.Playback(gun,"Fire_Left").speed,1/0.27)
gun.MasterAssetName="enfield"; gun.RegisteredAnimations.Cycle={}
close(MasterAnimationRules.Playback(gun,"Fire").speed,1/0.27)
gun.MasterAssetName="crossbow"; close(MasterAnimationRules.Playback(gun,"Fire_Left").speed,3)
close(MasterAnimationRules.CheckDuration(gun),1)
gun.MasterAssetName="mpgun"; close(MasterAnimationRules.CheckDuration(gun),2.5)
gun.MasterAssetName="pugsley"; close(MasterAnimationRules.Playback(gun,"Check_Empty").speed,0.4)
gun.MasterAssetName="springfield"; gun.PedersenMode=true
close(MasterAnimationRules.Playback(gun,"Fire").speed,2)
close(MasterAnimationRules.Playback(gun,"Pedersen_Device_On").speed,0.5)
close(MasterAnimationRules.Playback(gun,"Pedersen_Charge").speed,1)
gun.MasterAssetName="enfield"
close(MasterAnimationRules.Playback(gun,"Load_Grenade").speed,2/3)
close(MasterAnimationRules.Playback(gun,"Load_Blank_Vet").speed,2/3)
close(MasterAnimationRules.Playback(gun,"Cutoff_On").speed,2)
close(MasterAnimationRules.Playback(gun,"Cycle_Left").speed,1/0.55)
gun.MasterAssetName="lebel"; gun.IsVeteran=true
close(MasterAnimationRules.Playback(gun,"Reload_Start_Vet").speed,1/(1.6*1.2))
local variants={Reload_Start_Vet={},Reload_Empty_Vet={}}
check(MasterAnimationRules.SelectName(gun,"Reload_Start",variants)=="Reload_Start_Vet")
check(MasterAnimationRules.SelectName(gun,"Reload_Empty",variants)=="Reload_Empty")
gun.MasterAssetName="rooklauncher"; check(MasterAnimationRules.SelectName(gun,"Reload_Start",variants)=="Reload_Start")
gun.MasterAssetName="springfieldvariant"; check(MasterAnimationRules.SelectName(gun,"Reload_Start",variants)=="Reload_Start")
for name,speed in pairs({Hold=0.25,Aim=0.5,Sprint=0.8,Drink=0.5,DrinkMotion=0.5,DrinkDone=0.5,
	Clean=0.5,ThrowUnder=2,ThrowOver=2,Choosing=0.5,Telescope=1.2,Tag_Look=0.5}) do
	close(MasterAnimationRules.Playback(gun,name).speed,speed)
end

close(MasterAnimationRules.CycleDuration(1,{conscript=true,training=true}),1.2)
close(MasterAnimationRules.CycleDuration(1,{rally=true,eliteBuff=true,quickdraw=true,restoration=true,conscript=true,rookHeavy=true}),0.9*0.8*0.955*1.2*1.2*0.85)
local actualPrint=print
local print=function() end
local warn=function() end
local attributes={}
local character={GetAttribute=function(_,name) return attributes[name] end,FindFirstChild=function() return nil end}
local LOCAL_PLAYER={Character=character}
local CUT=0.06
local NON_RESTARTING_ANIMATIONS={Hold=true,Aim=true,Aim_Left=true}
local ACTION_FALLBACK_NAMES={Fire_Last_Left={"Fire_Left","Fire"},Check_Empty={"Check"}}
local function default_animation_fade() return 0.1 end
local WeaponHandling={CycleDuration=function(_,duration) return duration end}
local BaseTool={}
__PLAYBACK_METHODS__
local BaseFirearm={}; setmetatable(BaseFirearm,{__index=BaseTool})
__FIREARM_WRAPPER__
__PHASE_METHODS__
local function track(name)
	return {Name=name,IsPlaying=false,Length=10,Speed=1,stops=0,
		Play=function(self,fade,weight,speed) self.fade=fade; self.weight=weight; self.Speed=speed; self.IsPlaying=true end,
		Stop=function(self,fade) self.stops+=1; self.cutFade=fade; self.IsPlaying=false end}
end
local function weapon()
	return setmetatable({className="JesseRifle",MasterAssetName="enfield",IsFirearm=true,Equipped=true,
		Capacity=2,FireInterval=0.2,cycle=0.55,reload_start=1.2,reload_empty=1.7,reload_loop=0.7,
		RegisteredAnimations={Fire=track("fire"),Fire_Left=track("fire_left"),Reload_Loop=track("reload_loop"),
			Reload_Start=track("reload_start"),Reload_Empty=track("reload_empty"),Draw=track("draw")},
		_drawDuration=function() return 0.1 end}, {__index=BaseFirearm})
end
local w=weapon()
local played=w:_playAnim("Reload_Loop",false,{fade=0,cutFade=0,restart=true,speed=3})
close(played.fade,0); close(played.Speed,3)
w:_playAnim("Reload_Loop",false,{fade=0.05})
close(played.fade,0.05); close(played.Speed,1/0.7); check(played.stops==1)
w.AnimationPlayback={Reload_Loop={speed=2,weight=0.4}}
w:_playAnim("Reload_Loop",false,{fade=0})
close(played.Speed,2); close(played.weight,0.4); close(played.fade,0)
w.Capacity=0
played=w:_playAnim("Reload_Start",false,{speed=4,fade=0.2})
check(played==w.RegisteredAnimations.Reload_Empty); close(played.Speed,4); close(played.fade,0.2)
w.Equipped=false; played=w:_playAnim("Draw",true)
check(played.IsPlaying); close(played.Speed,1.5)
w=weapon(); w.IsVeteran=true; attributes.OrderReloadMultiplier=1.1; attributes.MoraleReloadMultiplier=1/0.7
played=w:_playAnim("Reload_Loop")
close(played.Speed,1/0.7*1.1/0.7)
w.MasterAssetName="rooklauncher"; close(w:_reloadSpeedMultiplier(),1.1)
attributes={}
w=weapon(); played=w:_playAnim("Fire_Last_Left")
check(played==w.RegisteredAnimations.Fire_Left); close(played.Speed,1/0.18)

local now=0
local os={clock=function() return now end}
-- Methods close over these fixture globals, declared before reloading them.
local task={wait=function(seconds) now+=seconds end}
__PHASE_METHODS__
w=weapon(); played=track("long_asset"); played.IsPlaying=true; played.Speed=0.5
check(w:_waitReloadPhase(played,10)); close(now,2); check(played.stops==1)
attributes.OrderReloadMultiplier=2; now=0
check(w:_waitReloadPhase(nil,0.8)); close(now,0.4)
now=0; w._equipGeneration=1
task.wait=function(seconds) now+=seconds; w._equipGeneration+=1 end
check(not w:_waitReloadPhase(played,10)); check(now<2)
local function loadIds()
__WEAPON_IDS__
end
local ids=loadIds()
check(ids.MasterSourceName("WhisperFlyboyRifle")=="springfieldvariant")
check(ids.MasterSourceName("JessePrecisionRifle")=="enfieldvariant")
check(ids.MasterSourceName("AntiMaterialRifle")=="pugsley")
check(ids.AssetName("JessePrecisionRifle")=="enfield")
local deferred={}; local actions={}; local requests=0
task.delay=function(seconds,callback) table.insert(deferred,{seconds=seconds,callback=callback}) end
local Players={LocalPlayer={Character=character}}
local UIS={GetMouseLocation=function() return {X=0,Y=0} end}
local HttpService={JSONDecode=function() return {"test chemical"} end}
local direction={}
local workspace={CurrentCamera={ScreenPointToRay=function() return {Direction={Unit=direction}} end}}
local Compounds={}
__STIM_ACTIVATE__
local function bottle()
	return setmetatable({Equipped=true,tool={Parent=character},View={Selecting=false},RegisteredAnimations={Throw={Stop=function() end}},
		_ready=function() return true end,
		_playAnim=function(_,name) table.insert(actions,name) end,
		_remote=function() return {FireServer=function(_,action,value) check(action=="Throw" and value==direction); requests+=1 end} end},
		{__index=Compounds})
end
local b=bottle(); b:activate(); check(actions[1]=="Ready" and requests==0)
close(deferred[1].seconds,0.7); deferred[1].callback()
check(actions[2]=="Throw" and requests==1)
close(deferred[2].seconds,0.5); deferred[2].callback(); check(actions[3]=="Discard")
actions={}; deferred={}; requests=0; b=bottle(); b:activate()
b.Equipped=false; deferred[1].callback(); check(requests==0 and #actions==1)
actualPrint("Passed "..checks.." animation playback, variant, timing, and cancellation checks")
