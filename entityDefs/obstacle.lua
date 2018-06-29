
local base = require 'entityDefs._base'
local obstacle = {
    server = base.server:new(),
    client = base.client:new()
}

for _, v in pairs{'server', 'client'} do
    obstacle[v].type = 'obstacle'
    obstacle[v].static = true
    obstacle[v].influenceRadius = 170
end

function obstacle.server:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = o.width or 320
    o.height = o.height or 40
    o.angle = o.angle or hash2(o.x + 1/3, o.y)*2*math.pi
    setmetatable(o, self)
    self.__index = self
    return o
end

function obstacle.server:spawn()
    self.body = love.physics.newBody(physics.server.world, self.x, self.y, 'static')
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setAngle(self.angle)
    local state = {
        id = self.id, type = self.type, x = self.x, y = self.y,
        width = self.width, height = self.height, angle = self.angle
    }
    return base.server.spawn(self, state)
end

function obstacle.server:destroy()
    self.fixture:destroy()
    self.body:destroy()
    base.server.destroy(self)
end



function obstacle.client:new(o)
    o = o or {}
    o.id = o.id or uuid()
    o.x = o.x or 0
    o.y = o.y or 0
    o.width = o.width or 320
    o.height = o.height or 40
    o.angle = o.angle or hash2(o.x + 1/3, o.y)*2*math.pi
    setmetatable(o, self)
    self.__index = self
    return o
end

function obstacle.client:spawn()
    self.body = love.physics.newBody(physics.client.world, self.x, self.y, 'static')
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setAngle(self.angle)
    return base.client.spawn(self)
end

function obstacle.client:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    local points = {self.body:getWorldPoints(self.shape:getPoints())}
    love.graphics.polygon('fill', points)
end

function obstacle.client:destroy()
    self.fixture:destroy()
    self.body:destroy()
    base.client.destroy(self)
end

return obstacle
