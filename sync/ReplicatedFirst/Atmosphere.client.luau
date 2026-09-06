-- Start ambience as soon as its replicated asset is available. This does not
-- wait for the intro, player data, UI creation, or a character spawn.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local music = require(modules:WaitForChild("Client Modules"):WaitForChild("MusicService"))
music.start_module()
