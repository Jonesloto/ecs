local ParticleInfo = {}
ParticleInfo.__index = ParticleInfo

function ParticleInfo.new(particleObject: ParticleEmitter)
    local self = setmetatable({}, ParticleInfo)

    self.Object = particleObject:Clone()
    self.ParentName = particleObject.Parent.Name

    return self
end

function ParticleInfo:Destroy()
    
end


return ParticleInfo
