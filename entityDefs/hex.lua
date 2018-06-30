
local base = require 'entityDefs._base'
local hex = {
    server = base.server:new(),
    client = base.client:new()
}

for _, v in pairs{'server', 'client'} do
    hex[v].type = 'hex'
    hex[v].static = false
    hex[v].influenceRadius = 40
    hex[v].enemy = true
end

function hex.server:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    o.xv = o.xv or 0
    o.yv = o.yv or 0
    o.angle = o.angle or hash2(o.x + 1/3, o.y)*2*math.pi
    o.hp = o.hp or 6
    setmetatable(o, self)
    self.__index = self
    return o
end

function hex.server:spawn()
    self.body = love.physics.newBody(physics.server.world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newCircleShape(40)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setLinearDamping(10)
    self.body:setAngularDamping(10)
    self.body:setAngle(self.angle)
    return base.server.spawn(self)
end

function hex.server:serialize()
    return {
        id = self.id, type = self.type,
        x = self.x, y = self.y,
        xv = self.xv, yv = self.yv,
        angle = self.angle, hp = self.hp
    }
end

function hex.server:setState(state)
    for _, v in pairs{'x', 'y', 'xv', 'yv', 'angle', 'hp'} do
        self[v] = state[v]
    end
    if self.body and not self.body:isDestroyed() then
        self.body:setPosition(self.x, self.y)
        self.body:setLinearVelocity(self.xv, self.yv)
        self.body:setAngle(self.angle)
    end
end

function hex.server:lerpState(a, b, t)
    for _, v in pairs{'x', 'y', 'xv', 'yv'} do
        self[v] = lerp(a[v], b[v], t)
    end
    for _, v in pairs{'angle'} do
        self[v] = lerpAngle(a[v], b[v], t)
    end
    for _, v in pairs{'hp'} do
        self[v] = b[v]
    end
    if self.body and not self.body:isDestroyed() then
        self.body:setPosition(self.x, self.y)
        self.body:setLinearVelocity(self.xv, self.yv)
        self.body:setAngle(self.angle)
    end
end

function hex.server:update(dt)
    self.body:applyForce((math.random()*2 - 1)*1e4, (math.random()*2 - 1)*1e4)
    self.x, self.y = self.body:getPosition()
    self.xv, self.yv = self.body:getLinearVelocity()
    self.angle = self.body:getAngle()
    base.server.update(self, dt)
end

function hex.server:damage(d, clientId)
    self.hp = self.hp - d
    if self.hp <= 0 and not self.destroyed then
        server.addPoints(clientId, 1)
        local x = self.x + (math.random()*2 - 1)*ssx/2
        local y = self.y + (math.random()*2 - 1)*ssy/2
        self:new{x=x, y=y}:spawn()
        self:destroy()
    end
end

function hex.server:destroy()
    if self.fixture and not self.fixture:isDestroyed() then
        self.fixture:destroy()
    end
    if self.body and not self.body:isDestroyed() then
        self.body:destroy()
    end
    base.server.destroy(self)
end

function hex.server:freeze()
    self.body:setType('static')
    base.server.freeze(self)
end

function hex.server:unfreeze()
    self.body:setType('dynamic')
    base.server.unfreeze(self)
end



function hex.client:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    o.xv = o.xv or 0
    o.yv = o.yv or 0
    o.angle = o.angle or hash2(o.x + 1/3, o.y)*2*math.pi
    o.hp = o.hp or 6
    setmetatable(o, self)
    self.__index = self
    return o
end

function hex.client:spawn()
    self.body = love.physics.newBody(physics.client.world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newCircleShape(40)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setLinearDamping(10)
    self.body:setAngularDamping(10)
    self.body:setAngle(self.angle)
    return base.client.spawn(self)
end

function hex.client:setState(state)
    for _, v in pairs{'x', 'y', 'xv', 'yv', 'angle', 'hp'} do
        self[v] = state[v]
    end
    if self.body and not self.body:isDestroyed() then
        self.body:setPosition(self.x, self.y)
        self.body:setLinearVelocity(self.xv, self.yv)
        self.body:setAngle(self.angle)
    end
end

function hex.client:lerpState(a, b, t)
    for _, v in pairs{'x', 'y', 'xv', 'yv'} do
        self[v] = lerp(a[v], b[v], t)
    end
    for _, v in pairs{'angle'} do
        self[v] = lerpAngle(a[v], b[v], t)
    end
    for _, v in pairs{'hp'} do
        self[v] = b[v]
    end
    if self.body and not self.body:isDestroyed() then
        self.body:setPosition(self.x, self.y)
        self.body:setLinearVelocity(self.xv, self.yv)
        self.body:setAngle(self.angle)
    end
end

function hex.client:update(dt)
    -- todo: simulate with future action prediction from server
    --[[
    self.body:applyForce((math.random()*2 - 1)*1e4, (math.random()*2 - 1)*1e4)
    self.x, self.y = self.body:getPosition()
    self.xv, self.yv = self.body:getLinearVelocity()
    self.angle = self.body:getAngle()
    ]]
    base.client.update(self, dt)
end

function hex.client:draw()
    love.graphics.setColor(0, 0, 1, 0.1)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.shape:getRadius() + 1)
    love.graphics.push()
    love.graphics.translate(math.floor(self.body:getX()), math.floor(self.body:getY()))
    love.graphics.push()
    love.graphics.rotate(self.body:getAngle())
    local p = {1, 3, 5, 2, 4, 6}
    for i=1, 6 do
        if p[i] > self.hp then
            love.graphics.setColor(colors.p5:clone():lighten(0.4):rgb())
        else
            love.graphics.setColor(colors.p5:rgb())
        end
        love.graphics.polygon('fill', 0, 0, math.sin(math.pi/6)*40,
        math.cos(math.pi/6)*40, math.sin(-math.pi/6)*40, math.cos(math.pi/6)*40)
        love.graphics.rotate(math.pi/3)
    end
    love.graphics.pop()
    if debugger.show then
        love.graphics.setColor(1, 0, 0)
        love.graphics.setLineWidth(5)
        love.graphics.line(0, 0, self.xv, self.yv)
    end
    love.graphics.pop()
end

function hex.client:destroy()
    if self.fixture and not self.fixture:isDestroyed() then
        self.fixture:destroy()
    end
    if self.body and not self.body:isDestroyed() then
        self.body:destroy()
    end
    base.client.destroy(self)
end



return hex
