local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer

local Animation = require(ReplicatedStorage.Common.Animation)

local m1Signal: RemoteEvent
local m2Signal: RemoteEvent
local chargeBegin: RemoteEvent
local chargeEnd: RemoteEvent

local function attack(inputObject, gpe: boolean)
    if gpe then return end

    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
        m1Signal:FireServer()
    end

    if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
        m2Signal:FireServer()
    end
end

local function charge(inputObject: InputObject)
    if not (inputObject.KeyCode == Enum.KeyCode.LeftShift) then return end

    if inputObject.UserInputState == Enum.UserInputState.Begin then
        chargeBegin:FireServer()
    end

    if inputObject.UserInputState == Enum.UserInputState.End then
        chargeEnd:FireServer()
    end
end

local GameController = {}

function GameController:Main()
    m1Signal = Net:RemoteEvent("M1")
    m2Signal = Net:RemoteEvent("M2")
    chargeBegin = Net:RemoteEvent("ChargeBegin")
    chargeEnd = Net:RemoteEvent("ChargeEnd")

    UserInputService.InputBegan:Connect(attack)
    UserInputService.InputBegan:Connect(charge)
    UserInputService.InputEnded:Connect(charge)
end

return GameController