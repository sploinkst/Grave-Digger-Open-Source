local voiceCalls,deferred={},{}
local crunches=0
local deaths={FindFirstChild=function(_,name) return {Name=name,IsA=function() return true end} end}
local sounds={FindFirstChild=function() return deaths end}
local voice={Play=function(character,kind,emitter) voiceCalls[#voiceCalls+1]={character,kind,emitter} end}
local shared={Library={SoundPlayback='playback',DeathAudioRules='rules',CharacterVoice='voice'},Assets={FindFirstChild=function() return sounds end}}
game={GetService=function() return {Shared=shared} end}
require=function(name) if name=='voice' then return voice elseif name=='rules' then return {Category=function() return 'gib' end} else return {Play=function() crunches=crunches+1 end} end end
task={defer=function(callback) deferred[#deferred+1]=callback end}
local service=dofile('sync/ReplicatedStorage/Shared/Modules/Server Modules/DeathAudioService.luau')
local function humanoid() return {Health=200,Died={Once=function(self,callback) self.callback=callback end}} end
local character={FindFirstChild=function() return nil end}
local corpse={FindFirstChild=function() return {IsA=function() return true end} end}
local h=humanoid();service.RecordDamage(character,h,'Torso',250,false)
h.Health=0;h.Died.callback();assert(#voiceCalls==0)
service.AttachCorpse(character,h,corpse)
assert(#voiceCalls==1 and voiceCalls[1][1]==character and voiceCalls[1][3]==corpse)
deferred[1]();service.AttachCorpse(character,h,corpse);assert(#voiceCalls==1)
local head=humanoid();service.RecordDamage(character,head,'Head',250,false)
head.Health=0;head.Died.callback();service.AttachCorpse(character,head,corpse)
assert(#voiceCalls==1 and crunches==0)
local destructive=humanoid();service.RecordDamage(character,destructive,'Torso',250,false,'JudgementRifle')
destructive.Health=0;service.AttachCorpse(character,destructive,corpse)
assert(crunches==3)
print('Corpse death audio: corpse emitter, original gender source, single playback and headshot suppression passed')
