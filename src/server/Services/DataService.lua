-- DataService
-- Jonesloto
-- 2022-11-29

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Net = require(ReplicatedStorage.Packages.Net)
local DataPrefab = require(ReplicatedStorage.Common.DataPrefab)

local dataChangedEvent = Net:RemoteEvent("DataChangedEvent")
local getDataFromServer = Net:RemoteFunction("GetData")
local dataChangedSignals = {}
local profileCache = {}

local DataService = {}

getDataFromServer.OnServerInvoke = function(player: Player, data_type: string)
    local _, profile = DataService:GetProfile(player):await()

    return DataService:GetData(profile, data_type)
end

function DataService:GetProfile(player)
    return Promise.new(function(resolve, reject, _onCancel)
        if Players:FindFirstChild(player.Name) then
            while not profileCache[player] do
                RunService.Heartbeat:Wait()

                if not Players:FindFirstChild(player.Name) then
                    reject("Player is no longer in the game.")
                    
                    break
                end
            end
            
            resolve(profileCache[player])
        else
            reject("Player is no longer in the game.")
        end
    end)
end

function DataService:IncrementData(profile, data_name: string, amount: number)
    if profile.Data[data_name] then
        local player = Players:GetPlayerByUserId(profile.UserIds[1])
        
        assert(typeof(profile.Data[data_name]) == "number", "Increment datatype needs to be a number.")
        
        profile.Data[data_name] += amount

        self:GetDataChangedSignal(player):Fire(data_name, profile.Data[data_name])
        dataChangedEvent:FireClient(player, data_name, profile.Data[data_name])
    end
end

function DataService:SetData(profile, data_name: string, value)
    if profile.Data[data_name] then
        local player = Players:GetPlayerByUserId(profile.UserIds[1])

        profile.Data[data_name] = value

        self:GetDataChangedSignal(player):Fire(data_name, profile.Data[data_name])
        dataChangedEvent:FireClient(player, data_name, profile.Data[data_name])
    end
end

function DataService:GetData(profile, data_name: string)
    return profile.Data[data_name] or warn(string.format("'%s' does not exist for profile.", data_name))
end

function DataService:GetDataChangedSignal(player: Player)
    return dataChangedSignals[player]
end

function DataService:Main()
    local PROFILE_STORE = ProfileService.GetProfileStore(
        "PlayerData",
        DataPrefab
    )

    local function playerAdded(player)
        local profile

        if RunService:IsStudio() then
            profile = PROFILE_STORE.Mock:LoadProfileAsync("Player_" .. tostring(player.UserId))
        else
            profile = PROFILE_STORE:LoadProfileAsync("Player_" .. tostring(player.UserId))
        end

        if profile ~= nil then
            profile:AddUserId(player.UserId) -- GDPR compliance
            profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
            profile:ListenToRelease(function()
                profileCache[player] = nil
                -- The profile could've been loaded on another Roblox server:
                player:Kick()
            end)
            if player:IsDescendantOf(Players) == true then
                profileCache[player] = profile
                dataChangedSignals[player] = Signal.new()
                -- A profile has been successfully loaded:
            else
                -- Player left before the profile loaded:
                profile:Release()
            end
        else
            -- The profile couldn't be loaded possibly due to other
            --   Roblox servers trying to load this profile at the same time:
            player:Kick()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(playerAdded, player)
    end

    Players.PlayerAdded:Connect(playerAdded)

    Players.PlayerRemoving:Connect(function(player)
        local profile = profileCache[player]
        if profile ~= nil then
            profile:Release()
        end
    end)
end

return DataService