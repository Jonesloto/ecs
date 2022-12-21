local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local FighterConstants = require(ReplicatedStorage.Common.ComponentConstants.FighterConstants)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local DEFAULT_KI_LEVEL = 10
local HEALTH_RATIO = 14.286

local fighters = {}

local function getRatio(current: number, max: number)
    return current/max
end

--[=[
    @class Fighter

    A fighter component which can be used on an entity.
]=]
local Fighter = {}
Fighter.__index = Fighter

--[=[
    Constructs a new instance of Fighter.

    @param player Player -- The Player which will be used to construct the fighter.
    @return Fighter -- returns a new instance of Fighter.
]=]
function Fighter.new(player: Player)
    assert(not Fighter.fromPlayer(player), "This player already has a fighter object, use .fromPlayer()")

    local self = setmetatable({}, Fighter)
    local kilevelUpdateJanitor = Janitor.new()
    
    self._player = player
    self._character = player.Character or player.CharacterAdded:Wait()

    self._charging = false

    self._fighterdata = Instance.new("Folder")
    self._fighterdata.Name = string.format(FighterConstants.PLR_FOLDER_NAME, player.UserId)

    self._basekilevel = Instance.new("NumberValue")
    self._basekilevel.Name = "BaseKiLevel"
    self._basekilevel.Value = DEFAULT_KI_LEVEL
    self._basekilevel.Parent = self._fighterdata

    self._maxkilevel = Instance.new("NumberValue")
    self._maxkilevel.Name = "MaxKiLevel"
    self._maxkilevel.Value = DEFAULT_KI_LEVEL
    self._maxkilevel.Parent = self._fighterdata
    
    self._kilevel = Instance.new("NumberValue")
    self._kilevel.Name = "KiLevel"
    self._kilevel.Value = self._maxkilevel.Value
    self._kilevel.Parent = self._fighterdata

    self._additiveBuffs = Instance.new("Folder")
    self._additiveBuffs.Name = "AdditiveBuffs"
    self._additiveBuffs.Parent = self._fighterdata

    self._multiplicativeBuffs = Instance.new("Folder")
    self._multiplicativeBuffs.Name = "MultiplicativeBuffs"
    self._multiplicativeBuffs.Parent = self._fighterdata

    self._maxkilevel:GetPropertyChangedSignal("Value"):Connect(function()
        if kilevelUpdateJanitor then return end

        while self._kilevel.Value < math.floor(self._maxkilevel.Value * .2) do
            self._kilevel.Value += self._maxkilevel.Value * .005
            task.wait(1)
        end

        kilevelUpdateJanitor:Destroy()
        kilevelUpdateJanitor = nil
    end)

    self._fighterdata.Parent = player

    self._hair = {}

    for _, hair in ipairs(self._character:GetChildren()) do
        if ((hair:IsA("Accessory")) and (hair.AccessoryType == Enum.AccessoryType.Hair)) or (hair:IsA("Hat")) then
            table.insert(self._hair, hair)
        end
    end

    fighters[tostring(player.UserId)] = self

    return self
end

function Fighter.fromPlayer(player: Player)
    return fighters[tostring(player.UserId)]
end

function Fighter:GetHair()
    return self._hair
end

function Fighter:GetCharacter()
    return self._character
end

function Fighter:SetCharging(value: boolean)
    self._charging = value
end

function Fighter:IsCharging()
    return self._charging
end

--[=[
    Sets the base powerlevel for the fighter.

    @param value number -- The value to set the fighter's base powerlevel.
    @return nil -- does not return anything.
]=]
function Fighter:SetBaseKiLevel(value: number)
    self._basekilevel.Value = value
    self:UpdateMaxKiLevel()

    return {
        WriteToDataStore = function(_this, player: Player)
            DataService:GetProfile(player):andThen(function(profile)
                DataService:SetData(profile, "basekilevel", self._basekilevel.Value)
            end)
        end
    }
end

function Fighter:SetCurrentKiLevel(value: number)
    self._kilevel.Value = value
end

function Fighter:IncrementCurrentKiLevel(value: number)
    self._kilevel.Value += value
end

--[=[
    Adds a buff to the fighter attached with a given tag. The given value will add to the current powerlevel of
    the fighter.

    @param tag string --  The tag used to identify the buff later.
    @param value number -- The value to add to the powerlevel of the fighter as a result of the buff.
    @return nil -- does not return anything.
]=]
function Fighter:AddBuff(tag: string, value: number, bufftype: string)
    assert((self._additiveBuffs:FindFirstChild(tag) == nil) and (self._multiplicativeBuffs:FindFirstChild(tag) == nil),
            string.format("This multiplier of tag \"%s\" already exists!", tag))

    local buff = Instance.new("NumberValue")
    buff.Name = tag
    buff.Value = value

    if bufftype == "additive" then
        buff.Parent = self._additiveBuffs
    elseif bufftype == "multiplicative" then
        buff.Parent = self._multiplicativeBuffs
    end

    self:UpdateMaxKiLevel()
end

--[=[
    Removes a buff from the fighter with the given tag if it exists.

    @param tag string -- The tag which identifies the buff to be removed.
    @return nil -- does not return anything.
]=]
function Fighter:RemoveBuff(tag: string)
    local buff = self._additiveBuffs:FindFirstChild(tag) or self._multiplicativeBuffs:FindFirstChild(tag)

    if buff then
        buff:Destroy()
        self:UpdateMaxKiLevel()
    end
end

--[=[
    Returns a table of the current buffs on the fighter

    @return table -- returns a table of numbervalues that buff the current powerlevel.
]=]
function Fighter:GetBuffs()
    return {self._additiveBuffs:GetChildren():unpack(), self._multiplicativeBuffs:GetChildren():unpack()}
end

--[=[
    Updates the maximum powerlevel of the fighter.

    @return nil -- does not return anything.
]=]
function Fighter:UpdateMaxKiLevel()
    local baseKi: number = self:GetBaseKiLevel()
    local oldMaxKi: number = self:GetMaxKiLevel()
    local oldKi: number = self:GetCurrentKiLevel()
    local ratio: number = oldKi/oldMaxKi

    for _, value_object in ipairs(self._multiplicativeBuffs:GetChildren()) do
        baseKi *= value_object.Value
    end

    for _, value_object in ipairs(self._additiveBuffs:GetChildren()) do
        baseKi += value_object.Value
    end

    self._maxkilevel.Value = baseKi

    self._kilevel.Value = self._maxkilevel.Value * ratio
end

--[=[
    Gets the base powerlevel of the fighter absent of any buffs.

    @return number -- returns the value of the base powerlevel.
]=]
function Fighter:GetBaseKiLevel()
    return self._basekilevel.Value
end

--[=[
    Gets the current powerlevel of the fighter including all buffs.

    @return number -- returns the value of the current powerlevel.
]=]
function Fighter:GetCurrentKiLevel()
    return self._kilevel.Value
end

function Fighter:GetMaxKiLevel()
    return self._maxkilevel.Value
end

function Fighter:Destroy()
    
end

export type Type = typeof(Fighter.new())

return Fighter
