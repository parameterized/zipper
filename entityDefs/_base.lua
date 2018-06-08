
local base = {
    type = 'base',
    static = true,
    influenceRadius = 10
}

function base:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.x = o.x or 0
    o.y = o.y or 0
    return o
end

function base:spawn()
    local type = self.type
    entities.container[type] = entities.container[type] or {}
    local id = #entities.container[type] + 1
    entities.container[type][id] = self
    self.destroyed = false
    self.id = id
end

function base:update(dt)

end

function base:draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle('fill', v.x, v.y, 10)
end

function base:destroy()
    entities.container[self.type][self.id] = nil
    self.destroyed = true
end

function base:freeze()
    self.frozen = true
end

function base:unfreeze()
    self.frozen = false
end

function base:cull()
    self:destroy()
    local cs = entities.chunkSize
    local chunk = math.floor(self.x/cs) .. ',' .. math.floor(self.y/cs)
    local type = self.type
    entities.culledContainer[chunk] = entities.culledContainer[chunk] or {}
    entities.culledContainer[chunk][type] = entities.culledContainer[chunk][type] or {}
    local id = #entities.culledContainer[chunk][type] + 1
    entities.culledContainer[chunk][type][id] = self
    self.culledChunk = chunk
    self.id = id
    self.culled = true
end

function base:uncull()
    entities.culledContainer[self.culledChunk][self.type][self.id] = nil
    self.culledChunk = nil
    self:spawn()
    self.culled = false
end

return base
