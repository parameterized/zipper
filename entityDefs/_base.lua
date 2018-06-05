
local base = {}

function base:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.type = 'base'
    o.x = o.x or 0
    o.y = o.y or 0
    o.hp = o.hp or 1
    return o
end

function base:spawn()
    self.destroyed = false
    local id = #entities.container + 1
    self.id = id
    entities.container[id] = self
end

function base:update(dt)

end

function base:draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.circle('fill', v.x, v.y, 10)
end

function base:damage(d)
    self.hp = self.hp - d
    if self.hp <= 0 and not self.destroyed then
        player.score = player.score + 1
        self:destroy()
    end
end

function base:destroy()
    self.destroyed = true
    entities.container[self.id] = nil
end

function base:freeze()
    self.frozen = true
end

function base:unfreeze()
    self.frozen = false
end

function base:cull()
    self:destroy()
    local id = #entities.culledContainer + 1
    self.id = id
    entities.culledContainer[id] = self
    self.culled = true
end

function base:uncull()
    entities.culledContainer[self.id] = nil
    self:spawn()
    self.culled = false
end

function base.__call(_, ...)
    return base:new(...)
end

return base
