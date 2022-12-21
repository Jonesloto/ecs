--[[
    Basically the game is a fist/magic shoot fight with other players.

    Ideas:
    - 3 hit combos for heavy, 5 hit combos for standard, 8 hit combos for strikers (still considering this)
    - before you can get to another combo part, the animation has to finish
    - combat tool ^
    - magic tool (light attack, heavy attack, q, r)
        - fire icon for now
    - lock mouse is fine (done)
    - final stand type combat
        - left mouse for light attacks (need to work on kicks)
        - right mouse for heavy attacks (3 heavys)
        - combo starts with the right (later on there will be a customization option where you can start with the left)
        - combo cooldown is 1.5 seconds?
        - wom walk/run anim (find out how to modularize it later on)
        - lean anims (left/right)
--]]


--[[
    Dragon Ball: lvl 1-10
    Saiyan Saga: lvl 11-20
    Frieza Saga: lvl 21-30
    Cell Saga: lvl 31-40
    Buu Saga: lvl 41-50
    BoG: lvl 51-60
    Return of Frieza: 61-70
    Universe Tournament 1: 71-80
    Zamasu: 81-90
    Tournament of Power: 91-100

    Moro: 101-110
    Granolah: 111-120
    Super Hero: 121-130

    Alternate Stories (side missions):
    The Dead Zone: lvl 1-10
    The World's Strongest: lvl 11-15
    The Tree of Might: lvl 15-20
    Lord Slug: lvl 21-25
    Cooler's Revenge: lvl 26-30
    Return of Cooler: lvl 31-33
    Super Android 13: lvl 34-36
    Broly the Legendary Super Saiyan: lvl 36-40
    Bojack Unbound: lvl 41-43
    Broly the Second Coming: lvl 43-45
    Bio Broly: lvl 43-45
    Fusion Reborn: lvl 46-48
    Wrath of the Dragon: lvl 48+
    Alternate Universe Saga (lvl 50-90):
        Black Star Dragon Ball Saga: 51-60
        Baby Saga: 61-70
        Super 17 Saga: 71-80
        Shadow Dragon Saga: 81-90
    Dragon Ball Super - Broly: lvl 90+
    Dragon Ball Super Hero: lvl 108+

    Superbosses:
    The Legend (Goku SSJ Full Power): lvl 25+
    Gohan Unleashed! (Gohan SSJ2 Full Power): lvl 35+
    Super Vegito!: lvl 45+
    Gogeta SSJ4: lvl 75+
    Goku Post Tournament of Power! (SSJ, SSJ2, SSJG, SSJB, SSJBKKx20, UI Omen, MUI): lvl 95+
    Ultra Vegito (SSJ, SSJ2, SSJB, MUI, MUE, Ultra form-MUI&MUE, Final Form): lvl 120+
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Net = require(ReplicatedStorage.Packages.Net)
local Composition = require(ServerScriptService.Server.Lib.Composition)
local Fighter = require(ServerScriptService.Server.Classes.Fighter)
local Aura = require(ServerScriptService.Server.Classes.Aura)
local GameServiceConstants = require(ReplicatedStorage.Common.GameServiceConstants)
local Animation = require(ReplicatedStorage.Common.Animation)
local DataService = require(ServerScriptService.Server.Services.DataService)
-- local LevelService = require(script.Parent.LevelService)

local GameService = {}

local saves: table = {}
local characterCompositions: table = {}
local m1Signal = Net:RemoteEvent("M1")
local m2Signal = Net:RemoteEvent("M2")
local chargeBegin = Net:RemoteEvent("ChargeBegin")
local chargeEnd = Net:RemoteEvent("ChargeEnd")

local function getSaveKey(player: Player)
    return tostring(player.UserId)
end

local function getSaveComposition(player: Player)
    if (not saves[getSaveKey(player)]) then
        saves[getSaveKey(player)] = Composition.new()
    end

    return saves[getSaveKey(player)]
end

local function getCharacterComposition(player: Player)
    if (not characterCompositions[getSaveKey(player)]) then
        characterCompositions[getSaveKey(player)] = Composition.new()
    end

    return characterCompositions[getSaveKey(player)]
end

local function m1Attack(player: Player)
    local characterComposition = getCharacterComposition(player)
    local humanoid = player.Character:WaitForChild("Humanoid")
    if (not characterComposition.toolEquipped) then return end
    if characterComposition.attackDeb then return end
    if humanoid.Jump then return end

    characterComposition.attackDeb = true

    if characterComposition.combo == 1 then
        characterComposition.combo = 2
        animName = "straightRight"
    elseif characterComposition.combo == 2 then
        characterComposition.combo = 3
        animName = "straightLeft"
    elseif characterComposition.combo == 3 then
        characterComposition.combo = 4
        animName = "rightKick"
    elseif characterComposition.combo == 4 then
        characterComposition.combo = 1
        animName = "leftKick"
    end

    Animation:PlayAnimation({player=player, animationName=animName, priority=Enum.AnimationPriority.Action4, yield=true, speedMultiplier=1})
    characterComposition.attackDeb = nil
end

local function beginCharging(player: Player)
    local fighter: Fighter.Type = Fighter.fromPlayer(player)

    if fighter:IsCharging() then return end

    fighter:SetCharging(true)

    while fighter:IsCharging() and (fighter:GetCurrentKiLevel() < fighter:GetMaxKiLevel()) do
        fighter:IncrementCurrentKiLevel(fighter:GetMaxKiLevel() * .001)
        RunService.Heartbeat:Wait()
    end

    fighter:SetCharging(false)
end

local function endCharging(player: Player)
    local fighter: Fighter.Type = Fighter.fromPlayer(player)

    if not fighter:IsCharging() then return end

    fighter:SetCharging(false)
end

local function m2Attack(player: Player)
    local characterComposition = getCharacterComposition(player)
    local humanoid = player.Character:WaitForChild("Humanoid")
    if (not characterComposition.toolEquipped) then return end
    if characterComposition.attackDeb then return end
    if humanoid.Jump then return end

    characterComposition.attackDeb = true

    if characterComposition.combo2 == 1 then
        characterComposition.combo2 = 2
        animName = "bigRightKick"
    elseif characterComposition.combo2 == 2 then
        characterComposition.combo2 = 1
        animName = "upperCut"
    end

    Animation:PlayAnimation({player=player, animationName=animName, priority=Enum.AnimationPriority.Action4, yield=true, speedMultiplier=1.5})
    characterComposition.attackDeb = nil
end

local function characterAdded(char: Model)
    local humanoid = char:WaitForChild("Humanoid")
    local player = Players:GetPlayerFromCharacter(char)
    local characterComposition = getCharacterComposition(player)
    local tool = Instance.new("Tool")
    
    tool.Name = "Test"
    tool.CanBeDropped = false
    tool.RequiresHandle = false
    tool.Equipped:Connect(function()
        characterComposition.toolEquipped = true
    end)
    tool.Unequipped:Connect(function()
        characterComposition.toolEquipped = false
    end)

    characterComposition.combo = 1
    characterComposition.combo2 = 1
    
    tool.Parent = player.Backpack
end

local function playerAdded(player)
    local fighter = Fighter.new(player)

    DataService:GetProfile(player)
    :andThen(function(profile)
        fighter:SetBaseKiLevel(DataService:GetData(profile, "basekilevel"))
        fighter:SetCurrentKiLevel(fighter:GetMaxKiLevel() / 2)
    end)

    if player.Character then
        characterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(characterAdded)
end

-- where the main code will run
function GameService:Main()
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerAdded:Connect(playerAdded)
    m1Signal.OnServerEvent:Connect(m1Attack)
    m2Signal.OnServerEvent:Connect(m2Attack)
    chargeBegin.OnServerEvent:Connect(beginCharging)
    chargeEnd.OnServerEvent:Connect(endCharging)
end

return GameService