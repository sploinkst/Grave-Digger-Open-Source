local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Playback = require(script.Parent.SoundPlayback)
local Voice = {}
local missingClips = {}
local damageVoices = setmetatable({}, {__mode = "k"})

function Voice.Prefix(character)
	-- The appearance menu's saved choice wins over a stale character value.
	local player = character and Players:GetPlayerFromCharacter(character)
	local data = player and require(Shared.Library.CosmeticAppearance).Data(player)
	local value = data and data:FindFirstChild("Gender")
	local selected = value and value.Value
	if typeof(selected) ~= "string" or selected == "" then
		local gender = character and character:FindFirstChild("gender")
		selected = gender and gender:IsA("StringValue") and gender.Value
	end
	return typeof(selected) == "string" and selected:lower():sub(1, 1) == "f" and "f" or "m"
end

function Voice.DamageKind(damage, health, character)
	-- Master ingameScript health listener: meaningful surviving hits only.
	if type(damage) ~= "number" or type(health) ~= "number" or not (damage > 0 and health > 0) or not character then return nil end
	if character:GetAttribute("IsDreadnought") or character:FindFirstChild("dreadnought") then return nil end
	local legacyPerk = character:FindFirstChild("perk")
	if legacyPerk and legacyPerk.Value == "leather" then return nil end
	local data = character:FindFirstChild("CharacterData")
	local perks = data and data:FindFirstChild("Perks")
	local leather = perks and perks:FindFirstChild("Leatherneck")
	if leather and (not leather:IsA("BoolValue") or leather.Value) then return nil end
	local state = damageVoices[character]
	if not state then
		state = {voice = -math.huge, heavy = -math.huge}
		damageVoices[character] = state
	end
	local now = os.clock()
	local kind = damage > 100 and "heavy" or "hurt"
	if now - state.voice < 1 then return nil end
	state.voice = now
	return kind
end

function Voice.Choose(character, kind)
	local sounds = Shared.Assets:FindFirstChild("Sounds")
	local folders = {}
	for _, name in ipairs({"PlayerSounds", "voices"}) do
		local folder = sounds and sounds:FindFirstChild(name)
		if folder then table.insert(folders, folder) end
	end
	if sounds then table.insert(folders,sounds) end
	if #folders == 0 then
		if not missingClips.PlayerSounds then
			missingClips.PlayerSounds = true
			warn("[CharacterVoice] Missing Shared.Assets.Sounds.PlayerSounds or voices")
		end
		return nil
	end
	local gender = Voice.Prefix(character)
	local prefix = gender .. "_" .. kind
	local ordered = {}
	for _, folder in ipairs(folders) do
		local grouped = folder:FindFirstChild(gender == "f" and "female" or "male")
		if grouped then table.insert(ordered, grouped) end
		table.insert(ordered, folder)
	end
	for _, folder in ipairs(ordered) do
		local choices = {}
		-- The master banks group pain, breath, burns, and other voice categories.
		for _, sound in ipairs(folder:GetDescendants()) do
			if sound:IsA("Sound") and (sound.Name:lower() == prefix or sound.Name:lower():match("^" .. prefix .. "[_%s%-]*%d+$") or sound.Parent.Name:lower()==prefix) then table.insert(choices, sound) end
		end
		if #choices > 0 then return choices[math.random(1, #choices)] end
	end
	if not missingClips[prefix] then
		missingClips[prefix] = true
		warn("[CharacterVoice] No Sound clips named " .. prefix .. "1, " .. prefix .. "2, etc. in the player voice banks")
	end
	return nil
end

-- Master cough and burn timers, independent of the health-hit voice cooldown.
function Voice.StatusStep(state, input, now)
	if not input.alive then return false, false end
	if not state.coughAt then state.coughAt = now + math.random(2, 4) end
	if not state.lastBurn then state.lastBurn = now end
	local cough, fire = false, false
	if (input.sick or input.gas) and not input.holding and not input.drinking and now > state.coughAt then
		cough = true
		state.coughAt = now + (input.intoxicated and math.random(15, 20) / 10 or math.random(2, 4))
	end
	if input.burning then
		fire = not input.dreadnought and now - state.lastBurn >= 1
		state.lastBurn = now
	end
	return cough, fire
end

function Voice.Origin(character)
	if not character then return nil end
	for _, name in ipairs({"Torso", "UpperTorso", "HumanoidRootPart", "Head"}) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then return part end
	end
end

function Voice.Play(character, kind, emitterCharacter)
	local sound = Voice.Choose(character, kind)
	local torso = Voice.Origin(emitterCharacter or character)
	if not sound or not torso then return nil end
	local volume = math.max(sound.Volume * 1.5, 1)
	if game:GetService("RunService"):IsClient() then
		-- The relay echoes to the sender too; play once through that shared path.
		Shared.Library.Events.Sounds:FireServer(sound, torso, sound.PlaybackSpeed, volume, 0, 0, 100)
		return nil
	end
	return Playback.Play(sound, torso, {Volume=volume, FollowParent=true, RollOffMinDistance=15, RollOffMaxDistance=100})
end
return Voice
