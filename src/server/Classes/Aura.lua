local Aura = {}
Aura.__index = Aura

function Aura.new(template: Model)
    local self = setmetatable({}, Aura)

    self._rigtype = template.Humanoid.RigType
    self._applied = false
    self._appliedCharacter = nil

    if self._rigtype == Enum.HumanoidRigType.R15 then
        self._auramap = {
            ["LeftUpperArm"] = {};
            ["LeftLowerArm"] = {};
            ["LeftHand"] = {};
            ["RightUpperArm"] = {};
            ["RightLowerArm"] = {};
            ["RightHand"] = {};
            ["Head"] = {};
            ["UpperTorso"] = {};
            ["LowerTorso"] = {};
            ["HumanoidRootPart"] = {};
            ["LeftUpperLeg"] = {};
            ["LeftLowerLeg"] = {};
            ["LeftFoot"] = {};
            ["RightUpperLeg"] = {};
            ["RightLowerLeg"] = {};
            ["RightFoot"] = {};
        }
    elseif self._rigtype == Enum.HumanoidRigType.R6 then
        self._auramap = {
            ["Left Arm"] = {};
            ["Right Arm"] = {};
            ["Head"] = {};
            ["Torso"] = {};
            ["HumanoidRootPart"] = {};
            ["Left Leg"] = {};
            ["Right Leg"] = {};
        }
    end
    

    for _, part in ipairs(template:GetChildren()) do
        if self._auramap[part.Name] then
            for _, particle in ipairs(part:GetChildren()) do
                if particle:IsA("ParticleEmitter") or particle:GetAttribute("AuraEmitter") then
                    table.insert(self._auramap[part.Name], particle:Clone())
                end
            end
        end
    end

    return self
end

function Aura:ToR15()
    if self._rigtype == Enum.HumanoidRigType.R15 then return end

    local newAuraMap = {
        ["LeftUpperArm"] = {};
        ["LeftLowerArm"] = {};
        ["LeftHand"] = {};
        ["RightUpperArm"] = {};
        ["RightLowerArm"] = {};
        ["RightHand"] = {};
        ["Head"] = {};
        ["UpperTorso"] = {};
        ["LowerTorso"] = {};
        ["HumanoidRootPart"] = {};
        ["LeftUpperLeg"] = {};
        ["LeftLowerLeg"] = {};
        ["LeftFoot"] = {};
        ["RightUpperLeg"] = {};
        ["RightLowerLeg"] = {};
        ["RightFoot"] = {};
    }

    for _, particle in ipairs(self._auramap.Head) do
        table.insert(newAuraMap.Head, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap["Right Arm"]) do
        table.insert(newAuraMap.RightUpperArm, particle:Clone())
        table.insert(newAuraMap.RightLowerArm, particle:Clone())
        table.insert(newAuraMap.RightHand, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.Torso) do
        table.insert(newAuraMap.UpperTorso, particle:Clone())
        table.insert(newAuraMap.LowerTorso, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.HumanoidRootPart) do
        table.insert(newAuraMap.HumanoidRootPart, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap["Left Arm"]) do
        table.insert(newAuraMap.LeftUpperArm, particle:Clone())
        table.insert(newAuraMap.LeftLowerArm, particle:Clone())
        table.insert(newAuraMap.LeftHand, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap["Left Leg"]) do
        table.insert(newAuraMap.LeftUpperLeg, particle:Clone())
        table.insert(newAuraMap.LeftLowerLeg, particle:Clone())
        table.insert(newAuraMap.LeftFoot, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap["Right Leg"]) do
        table.insert(newAuraMap.RightUpperLeg, particle:Clone())
        table.insert(newAuraMap.RightLowerLeg, particle:Clone())
        table.insert(newAuraMap.RightFoot, particle:Clone())
        particle:Destroy()
    end
    
    self._auramap = newAuraMap

    self._rigtype = Enum.HumanoidRigType.R15
end

function Aura:ToR6()
    if self._rigtype == Enum.HumanoidRigType.R6 then return end

    local newAuraMap = {
        ["Left Arm"] = {};
        ["Right Arm"] = {};
        ["Head"] = {};
        ["Torso"] = {};
        ["HumanoidRootPart"] = {};
        ["Left Leg"] = {};
        ["Right Leg"] = {};
    }

    for _, particle in ipairs(self._auramap.Head) do
        table.insert(newAuraMap.Head, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.RightUpperArm) do
        table.insert(newAuraMap["Right Arm"], particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.UpperTorso) do
        table.insert(newAuraMap.Torso, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.HumanoidRootPart) do
        table.insert(newAuraMap.HumanoidRootPart, particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.LeftUpperArm) do
        table.insert(newAuraMap["Left Arm"], particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.LeftUpperLeg) do
        table.insert(newAuraMap["Left Leg"], particle:Clone())
        particle:Destroy()
    end

    for _, particle in ipairs(self._auramap.RightUpperLeg) do
        table.insert(newAuraMap["Right Leg"], particle:Clone())
        particle:Destroy()
    end


    for _, component in pairs(self._auramap) do
        for _, particle in ipairs(component) do
            particle:Destroy()
        end
    end

    self._auramap = newAuraMap

    self._rigtype = Enum.HumanoidRigType.R6
end

--[=[
    Applies the aura to a character model. Does not work in the following conditions:
    - If the humanoid rigtypes of the aura object and character do not match.
    - If the aura has been applied on a character already.
    

    @param character Model -- The object to attach to the entity.
    @return nil -- Returns the object that was attached to the entity.
]=]
function Aura:Apply(character: Model)
    if character.Humanoid.RigType ~= self._rigtype then return warn("rig types do not match.") end
    if self._applied then return warn("Aura object is already applied on a character.") end

    for componentName, component in pairs(self._auramap) do
        for _, particle in ipairs(component) do
            particle.Parent = character[componentName]
        end
    end

    self._appliedCharacter = character
    self._applied = true
end

--[=[
    Removes the aura from the current character model so that it can be reapplied to another. Does not work in the following conditions:
    - If the aura has not been applied on a character yet.

    @return nil -- Returns the object that was attached to the entity.
]=]
function Aura:Remove()
    if not self._applied then return end

    for _, component in pairs(self._auramap) do
        for _, particle in ipairs(component) do
            particle.Parent = nil
        end
    end

    self._appliedCharacter = nil
    self._applied = false
end

function Aura:GetCharacter()
    return self._appliedCharacter
end

--[=[
    Destroys the object.
    
    @return nil -- Returns the object that was attached to the entity.
]=]
function Aura:Destroy()
    for _, component in pairs(self._auramap) do
        for _, particle in ipairs(component) do
            particle:Destroy()
        end
    end
    
    self = nil
end


return Aura
