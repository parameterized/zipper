
player = {}

player.name = 'Player'
player.score = 0
player.fireRate = 5
player.lastFireTime = 0
player.freeFire = false
player.spd = 2e3

player.body = love.physics.newBody(physics.world, 0, 0, 'dynamic')
player.shape = love.physics.newRectangleShape(50, 50)
player.fixture = love.physics.newFixture(player.body, player.shape, 1)
player.fixture:setUserData{type='player'}
player.fixture:setCategory(2)
player.fixture:setMask(2)
player.body:setLinearDamping(10)
player.body:setAngularDamping(10)

player.cursor = {x=0, y=0}

function player.serialize()
    local p = {
        id = player.id, name = player.name,
        x = player.body:getX(), y = player.body:getY(), angle = player.body:getAngle(),
        cursor = {x=player.cursor.x, y=player.cursor.y}
    }
    return p
end

function player.getHandPos(px, py, pa, wmx, wmy)
    if not (px and py and pa and wmx and wmy) then
        px = player.body:getX()
        py = player.body:getY()
        pa = player.body:getAngle()
        local mx, my = love.mouse.getPosition()
        mx = mx/graphicsScale
        my = my/graphicsScale
        wmx, wmy = camera:screen2world(mx, my)
    end
    local a = math.atan2(wmx - px, wmy - py) - math.pi/2
    local d = 40*(1/math.cos((a + math.pi/4 + pa) % (math.pi/2) - math.pi/4))
    return px + math.cos(a)*d, py - math.sin(a)*d
end

function player.update(dt)
    local mx, my = love.mouse.getPosition()
    mx = mx/graphicsScale
    my = my/graphicsScale
    local wmx, wmy = camera:screen2world(mx, my)
    player.cursor.x, player.cursor.y = wmx, wmy

    if not debugger.console.active and not chat.active then
        local dx, dy = 0, 0
    	dx = dx + (love.keyboard.isDown('d') and 1 or 0)
    	dx = dx + (love.keyboard.isDown('a') and -1 or 0)
    	dy = dy + (love.keyboard.isDown('w') and -1 or 0)
    	dy = dy + (love.keyboard.isDown('s') and 1 or 0)
        local spd = player.spd*(love.keyboard.isDown('lshift') and 2.5 or 1)
        if not (dx == 0 and dy == 0) then
            local a = math.atan2(dx, dy) - math.pi/2
            player.body:applyForce(math.cos(a)*spd, -math.sin(a)*spd)
        end
    end

    player.body:applyTorque(-player.body:getAngle()*1e5)

    if love.mouse.isDown(1) and (gameTime - player.lastFireTime > 1/player.fireRate or player.freeFire) then
        local a = math.atan2(wmx - player.body:getX(), wmy - player.body:getY()) - math.pi/2
        local hx, hy = player.getHandPos(player.body:getX(), player.body:getY(),
            player.body:getAngle(), wmx, wmy)
        bullets.spawn(true, hx, hy, a, 1200)
        player.lastFireTime = gameTime
    end

    camera.x = player.body:getX() + math.floor((mx-ssx/2)/6)
    camera.y = player.body:getY() + math.floor((my-ssy/2)/6)
end

function player.mousepressed(mx, my, btn)

end

function player.draw()
    -- other players
    for _, v in pairs(client.currentState.players) do
        if v.id ~= player.id then
            love.graphics.setColor(colors.p2:rgb())
            love.graphics.polygon('fill', v.body:getWorldPoints(v.shape:getPoints()))
            local hx, hy = player.getHandPos(v.x, v.y, v.angle, v.cursor.x, v.cursor.y)
            love.graphics.circle('fill', hx, hy, 10)
            love.graphics.setColor(colors.p5:clone():lighten(0.5):rgb())
            local font = fonts.f32
            love.graphics.setFont(font)
            love.graphics.print(v.name, v.x - font:getWidth(v.name)/2, v.y + 50)
        end
    end
    -- local player
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.polygon('fill', player.body:getWorldPoints(player.shape:getPoints()))
    local hx, hy = player.getHandPos()
    love.graphics.circle('fill', hx, hy, 10)
    love.graphics.setColor(colors.p5:clone():lighten(0.5):rgb())
    local font = fonts.f32
    love.graphics.setFont(font)
    love.graphics.print(player.name, player.body:getX() - font:getWidth(player.name)/2,
        player.body:getY() + 50)
end
