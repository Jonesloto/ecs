local State = {}
State.__index = State


function State.new(value: any)
    local self = setmetatable({}, State)

    self._value = value
    
    return self
end

function State:Set(newValue: any)
    self._value = newValue
end

function State:Get()
    return self._value
end

function State:Destroy()
    
end


return State
