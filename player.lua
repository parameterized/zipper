
player = {
	x=0, y=0, xv=0, yv=0, w=32, h=56,
    spd=320, accel=2, friction=1080
}

function player.update(dt)
    local mx, my = love.mouse.getPosition()

    if love.keyboard.isDown('d') then
        player.xv = math.min(player.xv + player.friction*player.accel*dt, player.spd)
    end
    if love.keyboard.isDown('a') then
        player.xv = math.max(player.xv - player.friction*player.accel*dt, -player.spd)
    end
    if love.keyboard.isDown('w') then
        player.yv = math.max(player.yv - player.friction*player.accel*dt, -player.spd)
    end
    if love.keyboard.isDown('s') then
        player.yv = math.min(player.yv + player.friction*player.accel*dt, player.spd)
    end

    player.x = player.x + player.xv*dt
    player.y = player.y + player.yv*dt

    player.xv = player.xv > 0 and math.max(player.xv - player.friction*dt, 0)
        or math.min(player.xv + player.friction*dt, 0)
    player.yv = player.yv > 0 and math.max(player.yv - player.friction*dt, 0)
        or math.min(player.yv + player.friction*dt, 0)

    camera.x = math.floor(player.x + math.floor((mx-ssx/2)/6) + (mx-ssx/2 < 0 and 1 or 0))
	camera.y = math.floor(player.y - player.h/2 + math.floor((my-ssy/2)/6) + (my-ssy/2 < 0 and 1 or 0))
end

function player.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.rectangle('fill', math.floor(player.x - player.w/2),
        math.floor(player.y - player.h), player.w, player.h)
end
