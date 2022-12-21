--[=[
    Howe this module works:

    When this module is required, it returns a function that gets a Folder of animation objets. These animation objects are generated
    from the dictionary "animations". Each key in the dictionary is the name of the animation and each value is the animationId.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local animations = {
    straightRight = "rbxassetid://11461131612";
    straightLeft = "rbxassetid://11461178607";
    rightKick = "rbxassetid://11645588326";
    leftKick = "rbxassetid://11646136207";
    bigRightKick = "rbxassetid://11646516705";
    upperCut = "rbxassetid://11646644259";
}

local function generateAnimationFolder()
    local folder = ReplicatedStorage:FindFirstChild("Animations") or Instance.new("Folder")
    folder:ClearAllChildren()
    folder.Name = "Animations"
    folder.Parent = ReplicatedStorage

    for index, value in pairs(animations) do
        local animationObject = Instance.new("Animation")
        animationObject.Name = index
        animationObject.AnimationId = value
        animationObject.Parent = folder
    end

    return folder
end

return generateAnimationFolder