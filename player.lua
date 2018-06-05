
player = {}

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

function player.getHandPos()
    local wmx, wmy = camera:screen2world(love.mouse.getPosition())
    local a = math.atan2(wmx - player.body:getX(), wmy - player.body:getY()) - math.pi/2
    local d = 40*(1/math.cos((a+math.pi/4-player.body:getAngle())%(math.pi/2) - math.pi/4))
    return player.body:getX() + math.cos(a)*d, player.body:getY() - math.sin(a)*d
end

function player.update(dt)
    local mx, my = love.mouse.getPosition()

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

    player.body:applyTorque(-player.body:getAngle()*1e5)

    if love.mouse.isDown(1) and (time - player.lastFireTime > 1/player.fireRate or player.freeFire) then
        local wmx, wmy = camera:screen2world(love.mouse.getPosition())
        local a = math.atan2(wmx - player.body:getX(), wmy - player.body:getY()) - math.pi/2
        local hx, hy = player.getHandPos()
        bullets.spawn(true, hx, hy, a, 1200)
        player.lastFireTime = time
    end

    camera.x = player.body:getX() + math.floor((mx-ssx/2)/6)
    camera.y = player.body:getY() + math.floor((my-ssy/2)/6)
end

function player.mousepressed(mx, my, btn)

end

function player.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.polygon('fill', player.body:getWorldPoints(player.shape:getPoints()))
    local hx, hy = player.getHandPos()
    love.graphics.circle('fill', hx, hy, 10)
end
