
bullets = {
    container = {}
}

function bullets.spawn(fromPlayer, x, y, a, s)
    local obj = {
        fromPlayer=fromPlayer,
        spawnTime=time, life=3,
        x=x, y=y, xv=math.sin(a)*s, yv=math.cos(a)*s
    }
    table.insert(bullets.container, obj)
end

function bullets.update(dt)
    for i, v in pairs(bullets.container) do
        v.x = v.x + v.xv*dt
        v.y = v.y + v.yv*dt
        if time - v.spawnTime > v.life then
            bullets.container[i] = nil
        end
    end
end

function bullets.draw()
    for _, v in pairs(bullets.container) do
        love.graphics.setColor(colors.p2:rgb())
        love.graphics.circle('fill', v.x, v.y, 8)
        love.graphics.setColor(colors.p5:rgb())
        love.graphics.circle('fill', v.x, v.y, 6)
    end
end
