
bullets = {
    container = {}
}

function bullets.spawn(fromPlayer, x, y, a, s)
    local obj = {
        fromPlayer=fromPlayer,
        spawnTime=gameTime, life=3,
        body = love.physics.newBody(physics.world, x, y, 'dynamic'),
        shape = love.physics.newCircleShape(8)
    }
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 20)
    obj.fixture:setMask(2)
    obj.body:setBullet(true)
    obj.body:setLinearVelocity(math.cos(a)*s, -math.sin(a)*s)
    local id = #bullets.container + 1
    obj.fixture:setUserData{type='bullet', id=id}
    bullets.container[id] = obj
end

function bullets.destroy(i)
    local v = bullets.container[i]
    if v then
        v.fixture:destroy()
        v.body:destroy()
        bullets.container[i] = nil
    end
end

function bullets.update(dt)
    for i, v in pairs(bullets.container) do
        if gameTime - v.spawnTime > v.life then
            bullets.destroy(i)
        end
    end
end

function bullets.draw()
    for _, v in pairs(bullets.container) do
        local x, y = v.body:getPosition()
        love.graphics.setColor(colors.p2:rgb())
        love.graphics.circle('fill', x, y, 8)
        love.graphics.setColor(colors.p5:rgb())
        love.graphics.circle('fill', x, y, 6)
    end
end
