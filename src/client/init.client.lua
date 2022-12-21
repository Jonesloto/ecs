local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(Loader.LoadDescendants(StarterPlayerScripts.Client.Controllers, Loader.MatchesName("Controller$")), "Main")

