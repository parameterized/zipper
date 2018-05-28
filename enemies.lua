
enemies = {
    container = {}
}

function enemies.spawn(type, x, y)
    local obj = {}
    obj.type = type
    obj.hp = 6
    obj.body = love.physics.newBody(physWorld, x, y, 'dynamic')
    obj.shape = love.physics.newCircleShape(40)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1)
    obj.body:setLinearDamping(10)
    obj.body:setAngularDamping(10)
    obj.body:setAngle(math.random()*2)
    local id = #enemies.container + 1
    obj.fixture:setUserData{type='enemy', id=id}
    enemies.container[id] = obj
end

for i=1, 18 do
    enemies.spawn('hex', (math.random()*2 - 1)*ssx/2, (math.random()*2 - 1)*ssy/2)
end

function enemies.update(dt)
    for i, v in pairs(enemies.container) do
        repeat
            if v.hp <= 0 then
                player.score = player.score + 1
                v.fixture:destroy()
                v.body:destroy()
                enemies.container[i] = nil
                enemies.spawn('hex', (math.random()*2 - 1)*ssx/2, (math.random()*2 - 1)*ssy/2)
                break
            end
            v.body:applyForce((math.random()*2 - 1)*1e4, (math.random()*2 - 1)*1e4)
        until true
    end
end

function enemies.draw()
    for _, v in pairs(enemies.container) do
        love.graphics.setColor(0, 0, 1, 0.1)
        love.graphics.circle('fill', v.body:getX(), v.body:getY(), v.shape:getRadius() + 1)
        love.graphics.push()
        love.graphics.translate(math.floor(v.body:getX()), math.floor(v.body:getY()))
        love.graphics.rotate(v.body:getAngle())
        local p = {1, 3, 5, 2, 4, 6}
        for i=1, 6 do
            if p[i] > v.hp then
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
end
