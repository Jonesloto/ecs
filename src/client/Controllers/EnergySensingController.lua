-- EnergySensingController
-- Jonesloto
-- 2022-11-23

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LOCAL_PLAYER = Players.LocalPlayer

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FighterConstants = require(ReplicatedStorage.Common.ComponentConstants.FighterConstants)

local EnergySensingController = {}

function EnergySensingController:Main()
    local sensingJantior = Janitor.new()
    local sensing = false
    local db

    -- energy sensing
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if db then return end

        db = true

        if input.KeyCode == Enum.KeyCode.K then
            if not sensing then
                local localPowerLevel = LOCAL_PLAYER:FindFirstChild(string.format(FighterConstants.PLR_FOLDER_NAME, LOCAL_PLAYER.UserId)):FindFirstChild("KiLevel")

                for _, plr in ipairs(Players:GetPlayers()) do
                    local softLight = sensingJantior:Add(ReplicatedStorage.SoftLight:Clone())

                    local character = plr.Character
                    local powerLevel = plr:FindFirstChild(string.format(FighterConstants.PLR_FOLDER_NAME, plr.UserId)):FindFirstChild("KiLevel")

                    local function updateSize()
                        local scale = math.clamp(7.5 * (powerLevel.Value / localPowerLevel.Value), 0.01, 5000)
                        softLight.Size = UDim2.fromScale(scale, scale)
                    end

                    updateSize()

                    sensingJantior:Add(localPowerLevel:GetPropertyChangedSignal("Value"):Connect(updateSize), "Disconnect")
                    sensingJantior:Add(powerLevel:GetPropertyChangedSignal("Value"):Connect(updateSize), "Disconnect")

                    softLight.Parent = character.HumanoidRootPart
                end
            else
                sensingJantior:Cleanup()
            end

            sensing = not sensing
        end

        db = false
    end)
end

return EnergySensingController