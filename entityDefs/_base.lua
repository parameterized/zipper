
local base = {
    server = {},
    client = {}
}

for _, v in pairs{'server', 'client'} do
    -- entities.defs[type]
    base[v].type = 'base'
    base[v].static = true
    -- max collider radius
    base[v].influenceRadius = 10
end

function base.server:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    setmetatable(o, self)
    self.__index = self
    return o
end

function base.server:spawn(state)
    self.destroyed = false
    local container = self.static and entities.server.static.container
        or entities.server.dynamic.container
    local type = self.type
    local id = self.id
    container[type] = container[type] or {}
    container[type][id] = self
    self:freeze()
    state = state or {id=self.id, type=self.type, x=self.x, y=self.y}
    server.currentState.entities[self.id] = state
    table.insert(server.added.entities, state)
    return self
end

function base.server:update(dt)
    local sv = server.currentState.entities[self.id]
    if sv then
        sv.x, sv.y = self.x, self.y
    end
end

function base.server:destroy()
    self.destroyed = true
    local container = self.static and entities.server.static.container
        or entities.server.dynamic.container
    container[self.type][self.id] = nil
    server.currentState.entities[self.id] = nil
    table.insert(server.removed.entities, self.id)
end

function base.server:freeze()
    self.frozen = true
end

function base.server:unfreeze()
    self.frozen = false
end

function base.server:cull()
    self:destroy()
    self.culled = true
    local container = self.static and entities.server.static.culledContainer
        or entities.server.dynamic.culledContainer
    local cs = entities.chunkSize
    local chunk = math.floor(self.x/cs) .. ',' .. math.floor(self.y/cs)
    self.culledChunk = chunk
    local type = self.type
    local id = self.id
    container[chunk] = container[chunk] or {}
    container[chunk][type] = container[chunk][type] or {}
    container[chunk][type][id] = self
end

function base.server:uncull()
    local container = self.static and entities.server.static.culledContainer
    or entities.server.dynamic.culledContainer
    container[self.culledChunk][self.type][self.id] = nil
    self.culled = false
    self.culledChunk = nil
    self:spawn()
end



function base.client:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    setmetatable(o, self)
    self.__index = self
    return o
end

function base.client:spawn()
    self.destroyed = false
    client.currentState.entities[self.id] = self
    return self
end

function base.client:draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle('fill', v.x, v.y, 10)
end

function base.client:destroy()
    self.destroyed = true
    client.currentState.entities[self.id] = nil
end

return base
