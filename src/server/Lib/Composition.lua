export type Composition = {
    Components: table
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

--[=[
    @class Composition

    An Composition class that component classes can be "attached" to for an ECS framework.
]=]
local Composition = {}
Composition.__index = Composition

--[=[
    Constructs a new instance of Composition.

    @return Composition -- returns a new instance of Composition.
]=]
function Composition.new()
    local self = setmetatable({}, Composition)

    self._components = {}
    self._componentsJanitor = Janitor.new()

    return self
end

--[=[
    Adds a component to the composition.

    @param tag string -- The 'string' tag that's used to identify the component attached to the composition.
    @param object table -- The object to attach to the composition.
    @return table -- Returns the object that was attached to the composition.
]=]
function Composition:AddComponent(tag: string, object: table)
    assert(self._components[tag] == nil, "this Composition already has a component of this tag: (" .. tag .. ")")

    self._components[tag] = self._componentsJanitor:Add(object)

    return object
end

--[=[
    Removes a component from the composition.

    @param tag string -- The 'string' tag that's used to identify the component attached to the composition.
    @return table -- Returns the object that was attached to the composition.
]=]
function Composition:RemoveComponent(tag: string)
    self._components[tag] = nil
end

--[=[
    Gets the component indexed by the given tag.

    @return table -- Returns the component object indexed by the given tag.
]=]
function Composition:GetComponent(tag: string)
    return self._components[tag]
end

--[=[
    Gets all components attached to this composition.

    @return table -- Returns a table of all components attached to the composition.
]=]
function Composition:GetComponents()
    return self._components
end

--[=[
    Removes all components from the composition.

    @return nil -- Does not return anything.
]=]
function Composition:CleanComponents()
    self._componentsJanitor:CleanUp()
end

--[=[
    Removes access to the Composition by setting it's identifier to nil.

    @return nil -- Does not return anything.
]=]
function Composition:Destroy()
    self = nil
end

return Composition