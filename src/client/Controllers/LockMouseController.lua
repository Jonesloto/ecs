local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local MIN_ZOOM = 8
local MAX_ZOOM = 16

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character

local cameraOffsetX = 2
local cameraOffsetY = 3
local cameraAngleX = 0
local cameraAngleY = 0
local smoothCamera = true

local characterAdded: any
local focusControl: any
local lockedMouse: boolean = false
local lockMouseJanitor = Janitor.new()

local function lockMouseCenter()
    if lockedMouse then return end
    lockedMouse = true

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    local zPos = (MAX_ZOOM + MIN_ZOOM) / 2

    local function updateCamera()
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        local start = CFrame.new(humanoidRootPart.CFrame.Position)
            * CFrame.Angles(0, math.rad(cameraAngleX), 0)
            * CFrame.Angles(math.rad(cameraAngleY), 0, 0)
        local cameraCFrame = start:PointToWorldSpace(Vector3.new(cameraOffsetX, cameraOffsetY, zPos))
        local cameraFocus = start:PointToWorldSpace(Vector3.new(cameraOffsetX, cameraOffsetY, -9e6))

        local cf = CFrame.lookAt(cameraCFrame, cameraFocus)

        if smoothCamera then
            TweenService:Create(
                camera,

                TweenInfo.new(0.2),

                {CFrame = cf}
            ):Play()
        else
            camera.CFrame = cf
        end
    end

    camera.CameraType = Enum.CameraType.Scriptable
    
    camera.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(cameraOffsetX, cameraOffsetY, zPos))

    lockMouseJanitor:Add(UserInputService.InputChanged:Connect(function(input, gpe)
        if gpe then return end
        if not (input.UserInputType == Enum.UserInputType.MouseWheel) then return end

        zPos = math.clamp(zPos - (input.Position.Z * 2), MIN_ZOOM, MAX_ZOOM)
    end))

    lockMouseJanitor:Add(UserInputService.InputChanged:Connect(function(input, gpe)
        if gpe then return end
        if not (input.UserInputType == Enum.UserInputType.MouseMovement) then return end
        
        cameraAngleX -= input.Delta.X
        cameraAngleY = math.clamp(cameraAngleY - input.Delta.Y * .4, -75, 75)
    end))

    RunService:BindToRenderStep("CamUpdate", Enum.RenderPriority.Camera.Value, updateCamera)

    lockMouseJanitor:Add(function()
        RunService:UnbindFromRenderStep("CamUpdate")
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        lockedMouse = false
    end)

    humanoid.Died:Connect(function()
        lockMouseJanitor:Cleanup()
    end)
end

local function freeMouseCenter()
    if not lockedMouse then return end
    
    lockMouseJanitor:Cleanup()
end


local function characterAdded(char: Model)
    character = char

    lockMouseCenter()

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if not (input.KeyCode == Enum.KeyCode.M) then return end

        if lockedMouse then
            freeMouseCenter()
        else
            lockMouseCenter()
        end
    end)
end

local LockMouseController = {}

function LockMouseController:Main()
    player.CameraMinZoomDistance = MIN_ZOOM
    player.CameraMaxZoomDistance = MAX_ZOOM

    player.CharacterAdded:Connect(characterAdded)
end

return LockMouseController