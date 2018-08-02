
hud = {}

function hud.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.setFont(fonts.f32)
    local text = 'Score: ' .. player.score
    love.graphics.print(text, ssx - (fonts.f32:getWidth(text) + 20), 10)
    -- xp bar
    local barW = ssx/2
    local barH = 80
    local barX = ssx/2 - barW/2
    local barY = ssy - barH - 10

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', barX, barY, barW, barH)
    love.graphics.setColor(1, 1, 1)
    --love.graphics.rectangle('fill', barX, barY, barW, barH/2)
    local padX = 10
    local padY = 10
    local pMax = 5 + player.level*2
    local percent = (player.xp % pMax)/pMax
    love.graphics.rectangle('fill',
        barX + padX, barY + padY,
        (barW - padX*2)*percent, barH - padY*2
    )
    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line',
        barX + padX, barY + padY,
        barW - padX*2, barH - padY*2
    )
    local font = fonts.f32
    love.graphics.setFont(font)
    local text = tostring(player.level)
    love.graphics.print(text,
        barX + barW/2 - font:getWidth(text)/2,
        barY + barH/2 - font:getHeight(text)/2 - 12
    )
    font = fonts.f14
    love.graphics.setFont(font)
    text = tostring(player.xp)
    love.graphics.print(text,
        barX + barW/2 - font:getWidth(text)/2,
        barY + barH/2 - font:getHeight(text)/2 + 15
    )
end
