
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
    local padX = 10
    local padY = 10
    local pMax = 5 + player.level*2
    local percent = (player.xp % pMax)/pMax
    love.graphics.rectangle('fill',
        barX + padX, barY + padY,
        (barW - padX*2)*percent, barH - padY*2
    )
--todo: perks/level up menu

--[==[
    shows perkPoint for debugging
    font = fonts.f14
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0, 1)
    love.graphics.print(player.perkPoint, ssx/2, ssy/2)
]==]

--gives player a perkPoint upon level up
    if (player.level ~= player.perkPoint) then
      player.perkPoint = player.perkPoint+1
    end

--draws perkBox when player has any perkPoints
local perkBoxW = ssx*.3
local perkBoxH = ssy*.4
local perkBoxX = ssx*.05
local perkBoxY = ssy/5
    if player.perkPoint >= 1 then
      local perkActive = 1
      font = fonts.f14
      love.graphics.setFont(font)
      love.graphics.setColor(1, 0, 1)
      love.graphics.rectangle('line', perkBoxX, perkBoxY,
          perkBoxW, perkBoxH
        )
      local perkBoxW = ssx*.3
      local perkBoxH = ssy*.4
      local perkBoxX = ssx*.05
      local perkBoxY = ssy/5
      local perkTextX = perkBoxX+(perkBoxX*.20)
      local perkTextY = perkBoxY+(perkBoxY*.20)
      local text = 'Remaining: ' .. tostring(player.perkPoint)
            love.graphics.print(text, perkTextX, perkTextY)
    else
      perkActive = 0
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
end
