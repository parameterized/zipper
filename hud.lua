
hud = {}

local perkBoxW = ssx*.3
local perkBoxH = ssy*.4
local perkBoxX = ssx*.05
local perkBoxY = ssy/5

local perkButtonW = perkBoxW/3
local perkButtonH = perkBoxH/16

hud.perkButtons = {
    {
        x = perkBoxX+perkBoxW*.1,
        y = perkBoxY+perkBoxH*.2,
        w = perkButtonW,
        h = perkButtonH,
        action = function()
            player.perks.a = player.perks.a + 1
        end
    },
    {
        x = perkBoxX+perkBoxW*.1,
        y = perkBoxY+perkBoxH*.2 + perkButtonH*2,
        w = perkButtonW,
        h = perkButtonH,
        action = function()
            player.perks.b = player.perks.b + 1
        end
    },
    {
        x = perkBoxX+perkBoxW*.1,
        y = perkBoxY+perkBoxH*.2 + perkButtonH*4,
        w = perkButtonW,
        h = perkButtonH,
        action = function()
            player.perks.c = player.perks.c + 1
        end
    },
}

function hud.mousepressed(mx, my, btn)
    for _, v in pairs(hud.perkButtons) do
        if mx > v.x and mx < v.x + v.w and my > v.y and my < v.y + v.h then
            player.perkPoint = player.perkPoint - 1
            v.action()
            break
        end
    end
end

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
    local padX = 10
    local padY = 10
    local pMax = 5 + player.level*2
    local percent = (player.xp % pMax)/pMax
    love.graphics.rectangle('fill',
        barX + padX, barY + padY,
        (barW - padX*2)*percent, barH - padY*2
    )

    if player.perkPoint >= 1 then
        font = fonts.f14
        love.graphics.setFont(font)
        love.graphics.setColor(1, 0, 1)
        love.graphics.rectangle('line', perkBoxX, perkBoxY,
            perkBoxW, perkBoxH
        )
        local perkTextX = perkBoxX+(perkBoxX*.2)
        local perkTextY = perkBoxY+(perkBoxY*.2)
        local text = 'Remaining: ' .. tostring(player.perkPoint)
        love.graphics.print(text, perkTextX, perkTextY)


        local mx, my = love.mouse.getPosition()
        mx = mx/graphicsScale
        my = my/graphicsScale

        for _, v in pairs(hud.perkButtons) do
            love.graphics.setColor(0, 0, 1)
            if mx > v.x and mx < v.x + v.w and my > v.y and my < v.y + v.h then
                love.graphics.setColor(0, 0, 0.8)
            end
            love.graphics.rectangle('fill', v.x, v.y, v.w, v.h)
        end
    end

    --xp bar outline
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
    local text = tostring(player.xp) .. ' / ' .. tostring(pMax)
    love.graphics.print(text,
        barX + barW/2 - font:getWidth(text)/2,
        barY + barH/2 - font:getHeight(text)/2 + 15
    )

    -- draw perks

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(fonts.f24)
    love.graphics.print('Perks:', ssx/16, ssy*5/7)
    local perkNames = {'a', 'b', 'c'}
    local ctr = 0
    for _, perkName in pairs(perkNames) do
        ctr = ctr + 1
        local perkCount = player.perks[perkName]
        local text = tostring(perkName) .. ': ' .. tostring(perkCount)
        love.graphics.print(text, ssx/16, ssy*5/7 + ctr*30 + 6)
    end
end
