
local base = require 'entityDefs._base'
local hex = base:new()

function hex:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.type = 'hex'
    o.x = o.x or 0
    o.y = o.y or 0
    o.hp = 6
    o.angle = math.random()*2*math.pi
    return o
end

function hex:spawn()
    self.destroyed = false
    self.body = love.physics.newBody(physics.world, self.x, self.y, 'dynamic')
    self.shape = love.physics.newCircleShape(40)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.body:setLinearDamping(10)
    self.body:setAngularDamping(10)
    self.body:setAngle(self.angle)
    local id = #entities.container + 1
    self.id = id
    self.fixture:setUserData{type='enemy', id=id}
    entities.container[id] = self
end

function hex:update(dt)
    self.x, self.y = self.body:getPosition()
    self.angle = self.body:getAngle()
    self.body:applyForce((math.random()*2 - 1)*1e4, (math.random()*2 - 1)*1e4)
end

function hex:draw()
    love.graphics.setColor(0, 0, 1, 0.1)
    love.graphics.circle('fill', self.body:getX(), self.body:getY(), self.shape:getRadius() + 1)
    love.graphics.push()
    love.graphics.translate(math.floor(self.body:getX()), math.floor(self.body:getY()))
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
end

function hex:damage(d)
    self.hp = self.hp - d
    if self.hp <= 0 and not self.destroyed then
        player.score = player.score + 1
        entities.spawn('hex', self.x + (math.random()*2 - 1)*ssx/2, self.y + (math.random()*2 - 1)*ssy/2)
        self:destroy()
    end
end

function hex:destroy()
    self.fixture:destroy()
    self.body:destroy()
    base.destroy(self)
end

function hex:freeze()
    self.body:setType('static')
    base.freeze(self)
end

function hex:unfreeze()
    self.body:setType('dynamic')
    base.unfreeze(self)
end

--[[
return setmetatable(
    {new = function(_, ...) return hex:new(...) end},
    {__call = function(_, ...) return hex:new(...) end}
)
]]

function hex.__call(_, ...)
    return hex:new(...)
end

return hex
