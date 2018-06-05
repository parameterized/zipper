
debugger = {
    show = false
}

function debugger.draw()
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.setFont(fonts.f14)
    love.graphics.print('FPS - ' .. love.timer.getFPS(), 4, 4 + 0*16)
    local ctr = 0
    for _, _ in pairs(entities.container) do ctr = ctr + 1 end
    love.graphics.print('entity container count - ' .. ctr, 4, 4 + 1*16)
    ctr = 0
    for _, _ in pairs(entities.culledContainer) do ctr = ctr + 1 end
    love.graphics.print('entity culled container count - ' .. ctr, 4, 4 + 2*16)
end
