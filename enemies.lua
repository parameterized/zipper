
enemies = {
    container = {}
}

function enemies.spawn(type, x, y)
    local obj = {}
    obj.type = type
    obj.body = love.physics.newBody(physWorld, x, y, 'dynamic')
    obj.shape = love.physics.newCircleShape(40)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1)
    obj.fixture:setUserData{type='enemy'}
    obj.body:setLinearDamping(10)
    obj.body:setAngularDamping(10)
    table.insert(enemies.container, obj)
end

for i=1, 18 do
    enemies.spawn('hex', (math.random()*2 - 1)*ssx/2, (math.random()*2 - 1)*ssy/2)
end

function enemies.update(dt)
    for i, v in pairs(enemies.container) do
        v.body:applyForce((math.random()*2 - 1)*1e4, (math.random()*2 - 1)*1e4)
    end
end

function enemies.draw()
    for _, v in pairs(enemies.container) do
        love.graphics.setColor(0, 0, 1, 0.1)
        love.graphics.circle('fill', v.body:getX(), v.body:getY(), v.shape:getRadius() + 1)
        love.graphics.push()
        love.graphics.translate(math.floor(v.body:getX()), math.floor(v.body:getY()))
        love.graphics.rotate(v.body:getAngle())
        for i=1, 6 do
            love.graphics.setColor(colors.p5:rgb())
            love.graphics.polygon('fill', 0, 0, math.sin(math.pi/6)*40,
                math.cos(math.pi/6)*40, math.sin(-math.pi/6)*40, math.cos(math.pi/6)*40)
            love.graphics.rotate(math.pi/3)
        end
        love.graphics.pop()
    end
end
