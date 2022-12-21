local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fighter = require(game:GetService("ServerScriptService").Server.Classes.Fighter)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Aura = require(game:GetService("ServerScriptService").Server.Classes.Aura)

-- assume we are working with an NPC
local TAG: string = "supersaiyan1buff"
local SPIKEY_HAIR: Hat = ReplicatedStorage.SuperSpikes
local HAIR_COLOR = Color3.fromRGB(245, 205, 48)

local SSJ = {}
SSJ.__index = SSJ


function SSJ.new(fighter: Fighter.Type)
    local self = setmetatable({}, SSJ)

    self._janitor = Janitor.new()
    self._fighter = fighter

    return self
end

function SSJ:Transform()
    local spikeyHair = self._janitor:Add(SPIKEY_HAIR:Clone())
    local aura = self._janitor:Add(Aura.new(workspace.Aura_SuperSaiyan))
    local fighter: Fighter.Type = self._fighter

    spikeyHair.Handle.Color = HAIR_COLOR

    spikeyHair.Parent = fighter:GetCharacter()

    for _, hair in ipairs(fighter:GetHair()) do
        hair.Handle.Color = HAIR_COLOR
    end

    aura:Apply(fighter:GetCharacter())

    fighter:AddBuff(TAG, 50, "multiplicative")

    self._janitor:Add(function()
        aura:Destroy()
        spikeyHair:Destroy()
        fighter:RemoveBuff(TAG)

        for _, hair in ipairs(fighter:GetHair()) do
            hair.Handle.BrickColor = BrickColor.new("Really black")
        end
    end)
end


function SSJ:Revert()
    self._janitor:Destroy()
end

function SSJ:Destroy()
    self:Revert()
end

return SSJ