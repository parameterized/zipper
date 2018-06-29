
bullets = {
    server = {
        container = {}
    },
    client = {}
}

function bullets.reset()
    for i, v in pairs(bullets.server.container) do
        bullets.server.destroy(i)
    end
end

function bullets.server.spawn(data)
    data.type = 'bullet'
    data.id = uuid()
    data.spawnTime = gameTime
    data.body = love.physics.newBody(physics.server.world, data.x, data.y, 'dynamic')
    data.shape = love.physics.newCircleShape(8)
    data.fixture = love.physics.newFixture(data.body, data.shape, 20)
    data.fixture:setMask(2)
    data.body:setBullet(true)
    data.body:setLinearVelocity(math.cos(data.angle)*data.speed, -math.sin(data.angle)*data.speed)
    data.fixture:setUserData(data)
    bullets.server.container[data.id] = data
    local state = {
        id = data.id, x = data.x, y = data.y
    }
    server.currentState.bullets[data.id] = state
    table.insert(server.added.bullets, state)
end

function bullets.server.destroy(i)
    local v = bullets.server.container[i]
    if v then
        v.fixture:destroy()
        v.body:destroy()
        bullets.server.container[i] = nil
        server.currentState.bullets[v.id] = nil
        table.insert(server.removed.bullets, v.id)
    end
end

function bullets.server.update(dt)
    for i, v in pairs(bullets.server.container) do
        local sv = server.currentState.bullets[v.id]
        if sv then
            sv.x, sv.y = v.body:getPosition()
        end
        if gameTime - v.spawnTime > v.life then
            bullets.server.destroy(i)
        end
    end
end



function bullets.client.draw()
    for _, v in pairs(client.currentState.bullets) do
        if v.startedMoving then
            love.graphics.setColor(colors.p2:rgb())
            love.graphics.circle('fill', v.x, v.y, 8)
            love.graphics.setColor(colors.p5:rgb())
            love.graphics.circle('fill', v.x, v.y, 6)
        end
    end
end
