-- TestCommandService
-- Jonesloto
-- 2022-12-07

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Fighter = require(ServerScriptService.Server.Classes.Fighter)
local LevelService = require(ServerScriptService.Server.Services.LevelService)

local SSJ = require(ServerScriptService.Server.Transformations.SSJ)

local transforms = {}

local cmdlist = {
    setki = function(player: Player, amount: number)
        if (not typeof(amount)) == "number" then return end
        local fighter: Fighter.Type = Fighter.fromPlayer(player)

        fighter:SetBaseKiLevel(amount)
    end,

    setexp = function(player: Player, amount: number)
        if (not typeof(amount)) == "number" then return end

        LevelService:SetEXP(player, amount)
    end,

    transform = function(player: Player)
        local fighter: Fighter.Type = Fighter.fromPlayer(player)
        local ssj = SSJ.new(fighter)

        ssj:Transform()

        transforms[player] = ssj
    end,

    off = function(player: Player)
        if transforms[player] then
            print(transforms[player])
            transforms[player]:Destroy()
        end
    end
}

local TestCommandService = {}

function TestCommandService:Main()
    local function playerAdded(player: Player)
        player.Chatted:Connect(function(message)
            local parts = message:split(" ")

            if cmdlist[parts[1]] then
                cmdlist[parts[1]](player, parts[2])
            end
        end)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end
    Players.PlayerAdded:Connect(playerAdded)
end

return TestCommandService