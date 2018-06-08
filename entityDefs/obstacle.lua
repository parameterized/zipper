
local base = require 'entityDefs._base'
local obstacle = base:new()

obstacle.type = 'obstacle'
obstacle.static = true
-- max with chunkSize
obstacle.influenceRadius = 140

function obstacle:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = 280
    o.angle = hash2(o.x + 1/3, o.y)*2*math.pi
    return o
end

function obstacle:spawn()
    self.body = love.physics.newBody(physics.world, self.x, self.y, 'static')
    self.shape = love.physics.newRectangleShape(self.width, 40)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setAngle(self.angle)
    base.spawn(self)
end

function obstacle:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    local points = {self.body:getWorldPoints(self.shape:getPoints())}
    love.graphics.polygon('fill', points)
end

function obstacle:destroy()
    self.fixture:destroy()
    self.body:destroy()
    base.destroy(self)
end

return obstacle
