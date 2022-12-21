return function(className: string)
    return function(properties: table)
        local instance = Instance.new(className)

        for name, value in pairs(properties) do
            if name == "Parent" then continue end
            instance[name] = value
        end

        if properties.Parent then
            instance.Parent = properties.Parent
        end
        
        return instance
    end
end