
local base = {}

-- entities.defs[type]
base.type = 'base'
base.static = true
-- max collider radius
base.influenceRadius = 10

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
    local container = self.static and entities.static.container or entities.dynamic.container
    container[type] = container[type] or {}
    local id = #container[type] + 1
    self.id = id
    self.destroyed = false
    container[type][id] = self
    self:freeze()
end

function base:update(dt)

end

function base:draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle('fill', v.x, v.y, 10)
end

function base:destroy()
    local container = self.static and entities.static.container or entities.dynamic.container
    container[self.type][self.id] = nil
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
    local container = self.static and entities.static.culledContainer or entities.dynamic.culledContainer
    container[chunk] = container[chunk] or {}
    container[chunk][type] = container[chunk][type] or {}
    local id = #container[chunk][type] + 1
    self.culledChunk = chunk
    self.id = id
    self.culled = true
    container[chunk][type][id] = self
end

function base:uncull()
    local container = self.static and entities.static.culledContainer or entities.dynamic.culledContainer
    container[self.culledChunk][self.type][self.id] = nil
    self.culledChunk = nil
    self:spawn()
    self.culled = false
end

return base
