
menu = {
    state = 'main',
    btns = {}
}

function menu.addBtn(t)
    local state = t.state or 'main'
    local id = t.id
    local text = t.text or 'Button'
    local font = t.font or fonts.f32
    local type = t.type or 'default'
    local x = t.x and t.x - font:getWidth(text)/2 or ssx/2 - font:getWidth(text)/2
    x = math.floor(x)
    local y = t.y and t.y - font:getHeight(text)/2 or ssy/2 - font:getWidth(text)/2
    y = math.floor(y)
    bx = x - 20
    by = y - 10
    bw = math.floor(font:getWidth(text)) + 40
    bh = math.floor(font:getHeight(text)) + 20
    if not menu.btns[state] then menu.btns[state] = {} end
    table.insert(menu.btns[state], {id=id, text=text, font=font, type=type, x=x, y=y, bx=bx, by=by, bw=bw, bh=bh})
end

menu.addBtn{text='Zipper', font=fonts.f48, type='static', y=120}
menu.addBtn{id='play', text='Play', y=360}
menu.addBtn{id='options', text='Options', y=440}
menu.addBtn{id='exit', text='Exit', y=580}

menu.addBtn{state='options', id='back', text='Back', y=580}

function menu.mousepressed(mx, my, btn)
    for _, v in pairs(menu.btns[menu.state]) do
        if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
            if v.id == 'play' then
                gameState = 'playing'
                love.mouse.setCursor(cursors.crosshairUp)
                love.mouse.setGrabbed(true)
            elseif v.id == 'options' then
                menu.state = 'options'
            elseif v.id == 'exit' then
                love.event.quit()
            elseif v.id == 'back' then
                menu.state = 'main'
            end
        end
    end
end

function menu.keypressed(k)
    if menu.state == 'main' then
        if k == 'escape' then
            --love.event.quit()
        end
    end
end

function menu.draw()
    local mx, my = love.mouse.getPosition()
    love.graphics.clear(colors.p5:rgb())
    for _, v in pairs(menu.btns[menu.state]) do
        if not (v.type == 'static') then
            if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                love.graphics.setColor(colors.p5_1:rgb())
            else
                love.graphics.setColor(colors.p5_2:rgb())
            end
            love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
        end
        love.graphics.setColor(colors.p1_1:rgb())
        love.graphics.setFont(v.font)
        love.graphics.print(v.text, v.x, v.y)
    end
end
