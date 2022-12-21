-- LevelService
-- Jonesloto
-- 2022-12-13

-- exp equation: next(level) = math.floor(45 * (level - 1)^2.837391)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local DataService = require(ServerScriptService.Server.Services.DataService)
local New = require(ReplicatedStorage.Common.Instance)

local STARTING_EXP = 45 -- exp required to get from level 1 to 2
local EXPONENT = 2.837391 -- rate of growth for each level.

local LevelService = {}

function LevelService:GetPlayerLevel(player: Player)
    local totalEXP = self:GetTotalEXP(player)

    return self:GetLevelFromEXP(totalEXP)
end

function LevelService:GetPlayerCurrentEXP(player: Player)
    local totalEXP = self:GetTotalEXP(player)

    return self:GetCurrentEXP(totalEXP)
end

function LevelService:GetPlayerEXPToNext(player: Player)
    local totalEXP = self:GetTotalEXP(player)

    return self:GetEXPToNext(totalEXP)
end

function LevelService:GetPlayerMaxEXP(player: Player)
    local totalEXP = self:GetTotalEXP(player)

    return self:GetMaxEXP(totalEXP)
end

function LevelService:SetEXP(player: Player, amount: number)
    local _, profile = DataService:GetProfile(player):await()

    DataService:SetData(profile, "exp", amount)
end

function LevelService:IncrementEXP(player: Player, amount: number)
    local _, profile = DataService:GetProfile(player):await()

    DataService:IncrementData(profile, "exp", amount)
end

function LevelService:GetTotalEXP(player: Player)
    local _, profile = DataService:GetProfile(player):await()

    return DataService:GetData(profile, "exp")
end

function LevelService:GetLevelFromEXP(exp: number)
    return math.floor(((exp/STARTING_EXP)^(1/EXPONENT)) + 1)
end

function LevelService:GetEXPFromLevel(level: number)
    return math.floor(STARTING_EXP * (level - 1)^EXPONENT)
end

function LevelService:GetEXPToNext(totalEXP: number)
    return self:GetEXPFromLevel(self:GetLevelFromEXP(totalEXP) + 1) - totalEXP
end

function LevelService:GetMaxEXP(totalEXP: number)
    return self:GetEXPToNext(totalEXP) + self:GetCurrentEXP(totalEXP)
end

function LevelService:GetCurrentEXP(totalEXP: number)
    return totalEXP - self:GetEXPFromLevel(self:GetLevelFromEXP(totalEXP))
end

function LevelService:Main()
    local function playerAdded(player)
        local levelData: Folder = New "Folder" {
            Name = "LevelData"
        }

        local TotalEXP: NumberValue = New "NumberValue" {
            Name = "TotalEXP",
            Value = self:GetTotalEXP(player),
            Parent = levelData
        }

        local EXPToNext: NumberValue = New "NumberValue" {
            Name = "EXPToNext",
            Value = self:GetPlayerEXPToNext(player),
            Parent = levelData
        }

        local MaxEXP: NumberValue = New "NumberValue" {
            Name = "MaxEXP",
            Value = self:GetPlayerMaxEXP(player),
            Parent = levelData
        }

        local CurrentEXP: NumberValue = New "NumberValue" {
            Name = "CurrentEXP",
            Value = self:GetPlayerCurrentEXP(player),
            Parent = levelData
        }

        local Level: NumberValue = New "NumberValue" {
            Name = "Level",
            Value = self:GetPlayerLevel(player),
            Parent = levelData
        }

        DataService:GetDataChangedSignal(player):Connect(function(dataName)
            if dataName == "exp" then
                TotalEXP.Value = self:GetTotalEXP(player)
                EXPToNext.Value = self:GetPlayerEXPToNext(player)
                MaxEXP.Value = self:GetPlayerMaxEXP(player)
                CurrentEXP.Value = self:GetPlayerCurrentEXP(player)
                Level.Value = self:GetPlayerLevel(player)
            end
        end)

        levelData.Parent = player
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerAdded:Connect(playerAdded)
end

return LevelService