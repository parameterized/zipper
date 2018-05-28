
player = {
	x=0, y=0, xv=0, yv=0, w=32, h=56,
    spd=320, accel=3, friction=1080
}

function player.update(dt)
    local mx, my = love.mouse.getPosition()

    local dx, dy = 0, 0
	dx = dx + (love.keyboard.isDown('d') and 1 or 0)
	dx = dx + (love.keyboard.isDown('a') and -1 or 0)
	dy = dy + (love.keyboard.isDown('w') and -1 or 0)
	dy = dy + (love.keyboard.isDown('s') and 1 or 0)
    if not (dx == 0 and dy == 0) then
        local a = math.atan2(dx, dy)
        player.xv = clamp(player.xv + math.sin(a)*player.friction*player.accel*dt, -player.spd, player.spd)
        player.yv = clamp(player.yv + math.cos(a)*player.friction*player.accel*dt, -player.spd, player.spd)
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

function player.mousepressed(mx, my, btn)
    local mx, my = camera:screen2world(mx, my)
    local a = math.atan2(mx - player.x, my - (player.y - player.h/2))
    bullets.spawn(true, player.x, player.y - player.h/2, a, 800)
end

function player.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.rectangle('fill', math.floor(player.x - player.w/2),
        math.floor(player.y - player.h), player.w, player.h)
    local mx, my = camera:screen2world(love.mouse.getPosition())
    local a = math.atan2(mx - player.x, my - (player.y - player.h/2)) - math.pi/2
    love.graphics.push()
    love.graphics.translate(math.floor(player.x), math.floor(player.y - player.h/2))
    love.graphics.rotate(-a)
    love.graphics.rectangle('fill', 0, -8, 40, 16)
    love.graphics.pop()
end
