
hud = {}

function hud.draw()
    love.graphics.setColor(colors.p2:rgb())
    love.graphics.setFont(fonts.f32)
    local text = 'Score: ' .. player.score
    love.graphics.print(text, ssx - (fonts.f32:getWidth(text) + 20), 10)
end
