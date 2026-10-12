local selected='f'
local data={FindFirstChild=function() return {Value=selected} end}
local player={}
local shared={Library={CosmeticAppearance='cosmetics'},Assets={}}
game={GetService=function(_,name) if name=='Players' then return {GetPlayerFromCharacter=function() return player end} else return {Shared=shared} end end}
script={Parent={SoundPlayback='playback'}}
require=function(name) if name=='cosmetics' then return {Data=function() return data end} else return {} end end
typeof=type
local now=0;os={clock=function() now=now+2;return now end}
local voice=dofile('sync/ReplicatedStorage/Shared/Library/CharacterVoice.luau')
local character={GetAttribute=function() return nil end,FindFirstChild=function() return nil end}
assert(voice.Prefix(character)=='f');selected='m';assert(voice.Prefix(character)=='m')
assert(voice.DamageKind(20,30,character)=='hurt')
assert(voice.DamageKind(100,150,character)=='hurt')
assert(voice.DamageKind(101,150,character)=='heavy')
assert(voice.DamageKind(5,195,character)=='hurt')
assert(voice.DamageKind(150,0,character)==nil)
print('Character voices: loadout gender wins, damage amount selects hurt/heavy, fatal hits do not play surviving-hit voices')
