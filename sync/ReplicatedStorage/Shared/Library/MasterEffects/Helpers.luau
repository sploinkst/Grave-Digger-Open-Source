-- Native implementations of every bFunctions helper used by the master effects.
local Runtime = require(script.Parent.Runtime)
local Playback = require(script.Parent.Parent.SoundPlayback)
local Helpers = {}
function Helpers:fast_spawn(callback, ...) return Runtime.Spawn(callback, ...) end
function Helpers:s_wait(seconds) return task.wait(math.max(seconds or 0, 0)) end
function Helpers:lerp(a, b, fraction) return a * (1 - fraction) + b * fraction end
function Helpers:handle_perc(value, percent) return value * percent / 100 end
function Helpers:randomiseTbl(values)
 local result = {}
 for _, value in ipairs(values) do table.insert(result, math.random(1, #result + 1), value) end
 return result
end
function Helpers:deepCopy(value, seen)
 if type(value) ~= "table" then return value end
 seen = seen or {}
 if seen[value] then return seen[value] end
 local result = {}; seen[value] = result
 for key, child in pairs(value) do result[self:deepCopy(key, seen)] = self:deepCopy(child, seen) end
 return result
end
function Helpers:soundHandler(options)
 local source = Runtime.Assets("sound_library")
 for _, name in ipairs(options.directory or {}) do source = source and source:FindFirstChild(name) end
 source = source and source:FindFirstChild(options.soundfile, true)
 if not source or not source:IsA("Sound") then return nil end
 local sound = Playback.Play(source, options.location, {
  PlaybackSpeed = (options.pitch or source.PlaybackSpeed) + (options.pitch_adjust or 0),
  PitchVariation = options.pitchvariation,
  Volume = math.max(0, source.Volume + (options.volume_adjust or 0) + (options.client_volume or 0)) * (options.gun_volume and Runtime.Setting("reducegunvolume") and 0.7 or 1),
  RollOffMaxDistance = options.force_max_dist,
 })
 if sound and options.soundgroup then sound.SoundGroup = game:GetService("SoundService"):FindFirstChild(options.soundgroup) end
 return sound
end
function Helpers:raycastline(options)
 local direction = options.destination
 if not direction or direction.Magnitude <= 0 then return nil end
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 local excluded = table.clone(options.layermask or {})
 table.insert(excluded, Runtime.World("notarget")); table.insert(excluded, Runtime.World("throwables"))
 for _, player in game:GetService("Players"):GetPlayers() do
  if player.Character then table.insert(excluded, player.Character) end
 end
 local length = options.range or 999.999
 for _ = 1, 20 do
  params.FilterDescendantsInstances = excluded
  local hit = workspace:Raycast(options.point, direction.Unit * length, params)
  if not hit then return nil, options.point + direction.Unit * length, Vector3.zero, Enum.Material.Air end
  local part = hit.Instance
  local skip = part:IsA("TrussPart") or part.Name == "click" or (part.Name == "bullet_whizz" and not options.get_whizzbox)
   or (part:IsA("BasePart") and part.Locked and not options.hit_locked)
   or (options.get_clicker and not part:FindFirstChild("clicker"))
   or (options.flamer and (part.Parent.Name == "Barbed Wire" or part.Parent.Parent and part.Parent.Parent.Name == "Barbed Wire"))
  if not skip then return part, hit.Position, hit.Normal, hit.Material end
  table.insert(excluded, part)
 end
 return nil
end
function Helpers:inLoS(options)
 return self:raycastline({point = options.pointB, destination = options.pointA - options.pointB, range = options.range, layermask = options.mask, hit_locked = options.hit_locked})
end
function Helpers:debugline(a, b, lifetime)
 local part = Instance.new("Part")
 part.Name = "DebugRay"; part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false
 part.Material = Enum.Material.Neon; part.Color = Color3.new(1, 0, 0)
 part.Size = Vector3.new(0.25, 0.25, (a - b).Magnitude)
 part.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -(a - b).Magnitude / 2)
 part.Parent = Runtime.World("notarget")
 game:GetService("Debris"):AddItem(part, lifetime or 1)
 return part
end
return Helpers
