local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ServerComm
local ClientComm

local animationFolder -- will contain the animation folder from the "Animations" module

local animationTracks = {}
local playAnimationSignal

local function getPlayerKey(player: Player)
    return tostring(player.UserId)
end

local Animation = {}

--[=[
    Plays an animation on a player's character.

    @param options table -- dictionary of arguements given to the function (player, animationName, priority, yield)
    @return nil -- returns nothing
]=]
function Animation:PlayAnimation(options: table)
    options.speedMultiplier = options.speedMultiplier or 1

    if RunService:IsServer() then
        local track: AnimationTrack = animationTracks[tostring(options.player.UserId)][options.animationName]
        playAnimationSignal:Fire(options.player, options)

        if options.yield then
            task.wait(track.Length/options.speedMultiplier)
        end

        return track
    elseif RunService:IsClient() then
        local track: AnimationTrack = animationTracks[options.animationName]

        if options.priority then
            track.Priority = options.priority
        end

        track:Play(.1, 1, options.speedMultiplier)
        
        if options.yield then
            track.Stopped:Wait()
        end

        return track
    end
end

if RunService:IsServer() then
    ServerComm = require(ReplicatedStorage.Packages.Comm).ServerComm.new(ReplicatedStorage)
    playAnimationSignal = ServerComm:CreateSignal("PlayAnimation")
    animationFolder = require(ReplicatedStorage.Common.Animations)()

    local function playerAdded(player)
        animationTracks[getPlayerKey(player)] = {}

        local function characterAdded(char)
            local humanoid = char:WaitForChild("Humanoid")
            humanoid.AncestryChanged:Wait()
        
            for _, animation in ipairs(animationFolder:GetChildren()) do
                animationTracks[getPlayerKey(player)][animation.Name] = humanoid:LoadAnimation(animation)
            end
        end
        
        if player.Character then
            characterAdded(player.Character)
        end

        player.CharacterAdded:Connect(characterAdded)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerAdded:Connect(playerAdded)
elseif RunService:IsClient() then
    ClientComm = require(ReplicatedStorage.Packages.Comm).ClientComm.new(ReplicatedStorage)
    playAnimationSignal = ClientComm:GetSignal("PlayAnimation")
    animationFolder = ReplicatedStorage:WaitForChild("Animations")
    animationTracks = {}
    
    local player = Players.LocalPlayer
    
    local function characterAdded(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        for _, animation in ipairs(animationFolder:GetChildren()) do
            animationTracks[animation.Name] = humanoid:LoadAnimation(animation)
        end
    end
    
    if player.Character then
        characterAdded(player.Character)
    end

    player.CharacterAdded:Connect(characterAdded)

    playAnimationSignal:Connect(function(options: table)
        Animation:PlayAnimation(options)
    end)
end


return Animation