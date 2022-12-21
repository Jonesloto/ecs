-- HUDController
-- Jonesloto
-- 2022-12-01

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Common.Format)

local textCooldown = false

local textGrouping = {}
textGrouping.__index = textGrouping

function textGrouping.New(textObjects: table)
    local self = setmetatable({}, textGrouping)
    self._textObjects = textObjects
    return self
end

function textGrouping:Set(text: string)
    for _, textObject: TextLabel in ipairs(self._textObjects) do
        textObject.Text = text
    end
end

local HUDController = {}

function HUDController:Main()
    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui

    local kiLevelObjectvalue: NumberValue = player:WaitForChild(string.format("FighterData (%d)", player.UserId)).KiLevel
    local maxKiLevelObjectvalue: NumberValue = player:WaitForChild(string.format("FighterData (%d)", player.UserId)).MaxKiLevel
    local currentEXP: NumberValue = player:WaitForChild("LevelData").CurrentEXP
    local maxEXP: NumberValue = player:WaitForChild("LevelData").MaxEXP

    local function characterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")

        local screenGui: ScreenGui = playerGui:WaitForChild("MainHUD")

        local kiLevelText = textGrouping.New({
            screenGui.KiUI.Text,
            screenGui.KiUI.Shadow
        })
        local healthText = textGrouping.New({
            screenGui.HealthUI.Text,
            screenGui.HealthUI.Shadow
        })

        local function updateKiBar()
            screenGui.KiUI.Bar.Size = UDim2.fromScale(1, kiLevelObjectvalue.Value/maxKiLevelObjectvalue.Value)
            
            if textCooldown then return end
            textCooldown = true

            kiLevelText:Set(Format:FormatNum(kiLevelObjectvalue.Value))
            task.wait(0.5)
            kiLevelText:Set(Format:FormatNum(kiLevelObjectvalue.Value))
            textCooldown = false
        end

        local function updateHealthBar()
            screenGui.HealthUI.Bar.Size = UDim2.fromScale(1, humanoid.Health/humanoid.MaxHealth)
            healthText:Set(string.format("%d%%", math.floor(humanoid.Health/humanoid.MaxHealth*100)))
        end

        local function updateEXPBar()
            screenGui.EXPUI.Bar.Size = UDim2.fromScale(currentEXP.Value/maxEXP.Value, 1)
        end

        updateKiBar()
        updateHealthBar()
        updateEXPBar()

        kiLevelObjectvalue:GetPropertyChangedSignal("Value"):Connect(updateKiBar)
        maxKiLevelObjectvalue:GetPropertyChangedSignal("Value"):Connect(updateKiBar)

        currentEXP:GetPropertyChangedSignal("Value"):Connect(updateEXPBar)
        maxEXP:GetPropertyChangedSignal("Value"):Connect(updateEXPBar)

        humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealthBar)
        humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealthBar)
    end
    
    if player.Character then
        characterAdded(player.Character)
    end

    player.CharacterAdded:Connect(characterAdded)
end

return HUDController