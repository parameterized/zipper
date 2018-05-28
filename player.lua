
player = {}

player.body = love.physics.newBody(physWorld, 0, 0, 'dynamic')
player.shape = love.physics.newRectangleShape(50, 50)
player.fixture = love.physics.newFixture(player.body, player.shape, 1)
player.fixture:setUserData{type='player'}
player.body:setLinearDamping(10)
player.body:setAngularDamping(10)

function player.update(dt)
    local mx, my = love.mouse.getPosition()

    local dx, dy = 0, 0
	dx = dx + (love.keyboard.isDown('d') and 1 or 0)
	dx = dx + (love.keyboard.isDown('a') and -1 or 0)
	dy = dy + (love.keyboard.isDown('w') and -1 or 0)
	dy = dy + (love.keyboard.isDown('s') and 1 or 0)
    if not (dx == 0 and dy == 0) then
        local a = math.atan2(dx, dy) - math.pi/2
        player.body:applyForce(math.cos(a)*2e3, -math.sin(a)*2e3)
    end

    player.body:applyTorque(-player.body:getAngle()*1e5)

    --camera.x = math.floor(player.body:getX() + math.floor((mx-ssx/2)/6) + (mx-ssx/2 < 0 and 1 or 0))
	--camera.y = math.floor(player.body:getY() + math.floor((my-ssy/2)/6) + (my-ssy/2 < 0 and 1 or 0))
    camera.x = player.body:getX() + math.floor((mx-ssx/2)/6)
    camera.y = player.body:getY() + math.floor((my-ssy/2)/6)
end

function player.mousepressed(mx, my, btn)
    local mx, my = camera:screen2world(mx, my)
    local a = math.atan2(mx - player.body:getX(), my - player.body:getY()) - math.pi/2
    local d = 40*(1/math.cos((a+math.pi/4-player.body:getAngle())%(math.pi/2) - math.pi/4))
    bullets.spawn(true, player.body:getX() + math.cos(a)*d, player.body:getY() - math.sin(a)*d, a, 1200)
end

function player.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.polygon('fill', player.body:getWorldPoints(player.shape:getPoints()))
    local mx, my = camera:screen2world(love.mouse.getPosition())
    local a = math.atan2(mx - player.body:getX(), my - player.body:getY()) - math.pi/2
    local d = 40*(1/math.cos((a+math.pi/4-player.body:getAngle())%(math.pi/2) - math.pi/4))
    print(d)
    love.graphics.circle('fill', player.body:getX() + math.cos(a)*d, player.body:getY() - math.sin(a)*d, 10)
    --[[
    love.graphics.push()
    love.graphics.translate(math.floor(player.body:getX()), math.floor(player.body:getY()))
    love.graphics.rotate(-a)
    love.graphics.rectangle('fill', 0, -8, 40, 16)
    love.graphics.pop()
    ]]
end
