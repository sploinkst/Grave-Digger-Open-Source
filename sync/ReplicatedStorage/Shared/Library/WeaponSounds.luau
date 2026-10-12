-- Resolve Studio sound folders and retain the exported audio when a clip is missing.
local Assets = game:GetService("ReplicatedStorage").Shared.Assets
local WeaponIds = require(script.Parent.WeaponIds)
local WeaponSounds = {}
local drawClips = {
	["atgrenade"] = {PlaybackSpeed = 2, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://7127178040"},
	["autosg"] = {RollOffMaxDistance = 200, TimePosition = 0.3, Volume = 1.5, SoundId = "rbxassetid://126195404852887"},
	["binocs"] = {PlaybackSpeed = 2, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://1334782302"},
	["bottle"] = {RollOffMaxDistance = 200, Volume = 1.5, SoundId = "rbxassetid://120636087363770"},
	["browningmg"] = {RollOffMaxDistance = 200, Volume = 2, SoundId = "rbxassetid://92524829654375"},
	["cavsword"] = {PlaybackSpeed = 1.1, RollOffMaxDistance = 200, Volume = 2, SoundId = "rbxassetid://15561433666"},
	["club"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://18906163315"},
	["conscriptlantern"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://6605240024"},
	["crossbow"] = {RollOffMaxDistance = 200, SoundId = "rbxassetid://132334634306960"},
	["dbgun"] = {RollOffMaxDistance = 200, Volume = 0.75, SoundId = "rbxassetid://2390787884"},
	["enfield"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://136996343357131"},
	["firstaid"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://17447821164"},
	["flagpole"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://9120869782"},
	["hammer"] = {PlaybackSpeed = 1.25, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://15407142377"},
	["henry"] = {RollOffMaxDistance = 200, Volume = 0.75, SoundId = "rbxassetid://18726458370"},
	["jaegerkit"] = {RollOffMaxDistance = 100, Volume = 1, SoundId = "rbxassetid://98433191887198"},
	["knife"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://17570020388"},
	["lance"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 2, SoundId = "rbxassetid://15561433578"},
	["lancerstim"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://17447821164"},
	["lebel"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://7405483764"},
	["lever"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://18248158047"},
	["lewis"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://110528269025035"},
	["machete"] = {PlaybackSpeed = 1.2, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://121603689781159"},
	["mares"] = {RollOffMaxDistance = 200, Volume = 1.2, SoundId = "rbxassetid://83525942222306"},
	["mauser"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://1788528435"},
	["mausercarbine"] = {RollOffMaxDistance = 200, TimePosition = 0.1, Volume = 1, SoundId = "rbxassetid://105361287800609"},
	["mgturret"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://81827882224064"},
	["mondragon"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://76790039123553"},
	["mosin"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://18352227172"},
	["mpgun"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://106976567288874"},
	["mpistol"] = {RollOffMaxDistance = 200, TimePosition = 0.1, Volume = 1, SoundId = "rbxassetid://111464047595861"},
	["nebel"] = {PlaybackSpeed = 2, RollOffMaxDistance = 200, Volume = 0.8, SoundId = "rbxassetid://240784215"},
	["pick"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://1334782302"},
	["pickaxe"] = {PlaybackSpeed = 1.1, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://609342907"},
	["pieper"] = {RollOffMaxDistance = 200, Volume = 1.5, SoundId = "rbxassetid://76007387341222"},
	["pugsley"] = {RollOffMaxDistance = 200, Volume = 1.5, SoundId = "rbxassetid://86612060093892"},
	["remington"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://107647910855387"},
	["rooklauncher"] = {RollOffMaxDistance = 200, Volume = 0.75, SoundId = "rbxassetid://8169246285"},
	["rsc"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://75195485385818"},
	["saa"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://18784071508"},
	["scho"] = {PlaybackSpeed = 1.1, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://609342351"},
	["springfield"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://119323830054045"},
	["steyr"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://75453151661154"},
	["stimbottle"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://17447821164"},
	["throwaxe"] = {RollOffMaxDistance = 200, SoundId = "rbxassetid://3746956704"},
	["trench"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://121207803224450"},
	["vanguardshield"] = {RollOffMaxDistance = 200, SoundId = "rbxassetid://121018108740879"},
	["walker"] = {PlaybackSpeed = 0.9, RollOffMaxDistance = 200, SoundId = "rbxassetid://106755257396951"},
	["weldingtool"] = {PlaybackSpeed = 2, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://86676256326641"},
	["wex"] = {RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://91250910383365"},
	["whistle"] = {PlaybackSpeed = 2, RollOffMaxDistance = 200, Volume = 1, SoundId = "rbxassetid://1334782302"},
	["wrench"] = {RollOffMaxDistance = 200, TimePosition = 0.5, Volume = 2, SoundId = "rbxassetid://9125969487"},
}
local variantClips = {
	["autosg"] = {RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.2, SoundId = "rbxassetid://77493917047052"},
	["dbgun"] = {RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.3, SoundId = "rbxassetid://111248852739102"},
	["henry"] = {RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1, SoundId = "rbxassetid://81920410035143"},
	["lever"] = {RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.2, SoundId = "rbxassetid://128129693719090"},
	["pieper"] = {PlaybackSpeed = 1.1, RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1, SoundId = "rbxassetid://115947175970308"},
	["remington"] = {PlaybackSpeed = 1.05, RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.2, SoundId = "rbxassetid://93747056336206"},
	["saa"] = {RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.25, SoundId = "rbxassetid://81683409926643"},
	["springfield"] = {PlaybackSpeed = 1.1, RollOffMaxDistance = 200, RollOffMinDistance = 40, Volume = 1.2, SoundId = "rbxassetid://75401156667300"},
}
local cache = {}

local function clip(folder, name)
 local found = folder and folder:FindFirstChild(name, true)
 if found and found:IsA("Sound") then return found end
 return nil
end

function WeaponSounds.Find(tool, name)
 local found = clip(tool.SoundFolder, name)
 if found then return found end
 local sounds = Assets:FindFirstChild("Sounds")
 local aliases = {tool.className, WeaponIds.AssetName(tool.className)}
 for _, alias in ipairs(WeaponIds.Aliases(tool.className)) do table.insert(aliases, alias) end
 for _, groupName in ipairs({"Guns", "Tools", "tools", "Utility", "Equipment", "equipments"}) do
  local group = sounds and sounds:FindFirstChild(groupName)
  for _, alias in ipairs(aliases) do
   found = clip(group and group:FindFirstChild(alias), name)
   if found then return found end
  end
 end
 local exported = name == "draw" and drawClips or name == "variantfire" and variantClips
 if not exported then return nil end
 for _, alias in ipairs(aliases) do
  local properties = exported[alias]
  if properties then
   local key = alias .. "/" .. name
   if not cache[key] then
    local sound = Instance.new("Sound")
    sound.Name = name
    for property, value in pairs(properties) do sound[property] = value end
    cache[key] = sound
   end
   return cache[key]
  end
 end
 return nil
end

return WeaponSounds
