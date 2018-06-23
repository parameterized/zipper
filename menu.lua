
menu = {
    state = 'main',
    btns = {}
}

function menu.addBtn(t)
    t.state = t.state or 'main'
    t.text = t.text or 'Button'
    t.font = t.font or fonts.f32
    t.type = t.type or 'default'
    t.action = t.action or function() end

    t.x = t.x or ssx/2
    t.x = math.floor(t.x)
    t.y = t.y or ssy/2
    t.y = math.floor(t.y)
    if t.type == 'cycle' then
        t.bw, t.bh = 0, 0
        t.items = t.items or {'<item>'}
        for _, v in pairs(t.items) do
            t.bw = math.max(math.floor(t.font:getWidth(v)) + 40, t.bw)
            t.bh = math.max(math.floor(t.font:getHeight(v)) + 20, t.bh)
        end
    else
        t.bw = math.floor(t.font:getWidth(t.text)) + 40
        t.bh = math.floor(t.font:getHeight(t.text)) + 20
    end
    t.bx = t.x - t.bw/2
    t.by = t.y - t.bh/2
    if not menu.btns[t.state] then menu.btns[t.state] = {} end
    table.insert(menu.btns[t.state], t)
end

menu.addBtn{text='Zipper', font=fonts.f48, y=120, type='static'}
menu.addBtn{text='Play', y=360, action=function()
    gameState = 'playing'
    love.mouse.setCursor(cursors.crosshairUp)
    love.mouse.setGrabbed(true)
end}
menu.addBtn{text='Options', y=440, action=function()
    menu.state = 'options'
end}
menu.addBtn{text='Exit', y=580, action=function()
    love.event.quit()
end}

menu.addBtn{state='options', text='Resolution', y=200,
    type='cycle', items={'960x540', '1280x720', '1600x900', '1920x1080'}, active=2, action=function(v)
        fullscreen, fstype = love.window.getFullscreen()
        if fullscreen and fstype == 'desktop' then
            return
        end
        local w, h, flags = love.window.getMode()
        w, h = v:match('(%d+)x(%d+)')
        local wd, hd = love.window.getDesktopDimensions()
        flags.x = wd/2 - w/2
        flags.y = hd/2 - h/2
        love.window.setMode(w, h, flags)
        graphicsScale = w/1280
    end, draw=function(v, mx, my)
        if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
            love.graphics.setColor(colors.p5_1:rgb())
        else
            love.graphics.setColor(colors.p5_2:rgb())
        end
        fullscreen, fstype = love.window.getFullscreen()
        if fullscreen and fstype == 'desktop' then
            love.graphics.setColor(colors.p5_2:clone():lighten(1.5):rgb())
        end
        love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
        love.graphics.setColor(colors.p1_1:clone():lighten(0.8):rgb())
        love.graphics.setFont(v.font)
        love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), v.by - v.font:getHeight() + 2)
        love.graphics.setColor(colors.p1_1:rgb())
        love.graphics.setFont(v.font)
        local text = v.items[v.active]
        if fullscreen and fstype == 'desktop' then
            local w, h = love.graphics.getDimensions()
            text = w .. 'x' .. h
        end
        love.graphics.print(text, math.floor(v.x - v.font:getWidth(text)/2), math.floor(v.y - v.font:getHeight(text)/2))
    end}
menu.addBtn{state='options', text='Fullscreen', y=300,
    type='cycle', items={'Windowed', 'Borderless Fullscreen Windowed', 'Fullscreen'}, active=1, action=function(v)
        if v == 'Windowed' then
            love.window.setFullscreen(false)
            local w, h = love.graphics.getDimensions()
            graphicsScale = w/1280
        elseif v == 'Borderless Fullscreen Windowed' then
            love.window.setFullscreen(true, 'desktop')
            local w, h = love.graphics.getDimensions()
            graphicsScale = w/1280
        elseif v == 'Fullscreen' then
            love.window.setFullscreen(true, 'exclusive')
            local w, h = love.graphics.getDimensions()
            graphicsScale = w/1280
        end
    end}
menu.addBtn{state='options', text='Vsync', y=380, type='toggle', active=true, action=function(v)
    local w, h, flags = love.window.getMode()
    flags.vsync = v
    love.window.setMode(w, h, flags)
end}
menu.addBtn{state='options', text='Back', y=580, action=function()
    menu.state = 'main'
end}

function menu.mousepressed(mx, my, btn)
    for _, v in pairs(menu.btns[menu.state]) do
        if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
            if v.type == 'toggle' then
                v.active = not v.active
                v.action(v.active)
            elseif v.type == 'cycle' then
                v.active = (v.active % #v.items) + 1
                v.action(v.items[v.active])
            else
                v.action()
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
    mx = mx/graphicsScale
    my = my/graphicsScale
    love.graphics.clear(colors.p5:rgb())
    for _, v in pairs(menu.btns[menu.state]) do
        if v.draw then
            v.draw(v, mx, my)
        else
            if v.type == 'static' then
                love.graphics.setColor(colors.p1_1:rgb())
                love.graphics.setFont(v.font)
                love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), math.floor(v.y - v.font:getHeight(v.text)/2))
            elseif v.type == 'toggle' then
                if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                    love.graphics.setColor(colors.p5_1:rgb())
                else
                    if v.active then
                        love.graphics.setColor(colors.p5_1:clone():lighten(0.8):rgb())
                    else
                        love.graphics.setColor(colors.p5_2:rgb())
                    end
                end
                love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
                love.graphics.setColor(colors.p1_1:rgb())
                love.graphics.setFont(v.font)
                love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), math.floor(v.y - v.font:getHeight(v.text)/2))
            elseif v.type == 'cycle' then
                if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                    love.graphics.setColor(colors.p5_1:rgb())
                else
                    love.graphics.setColor(colors.p5_2:rgb())
                end
                love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
                love.graphics.setColor(colors.p1_1:clone():lighten(0.8):rgb())
                love.graphics.setFont(v.font)
                love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), v.by - v.font:getHeight() + 2)
                love.graphics.setColor(colors.p1_1:rgb())
                love.graphics.setFont(v.font)
                local text = v.items[v.active]
                love.graphics.print(text, math.floor(v.x - v.font:getWidth(text)/2), math.floor(v.y - v.font:getHeight(text)/2))
            else
                if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                    love.graphics.setColor(colors.p5_1:rgb())
                else
                    love.graphics.setColor(colors.p5_2:rgb())
                end
                love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
                love.graphics.setColor(colors.p1_1:rgb())
                love.graphics.setFont(v.font)
                love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), math.floor(v.y - v.font:getHeight(v.text)/2))
            end
        end
        --[[
        if not (v.type == 'static') then
            if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                love.graphics.setColor(colors.p5_1:rgb())
            else
                love.graphics.setColor(colors.p5_2:rgb())
                if v.type == 'toggle' then
                    if v.active then
                        love.graphics.setColor(colors.p5_1:clone():lighten(0.8):rgb())
                    end
                end
            end
            love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
        end
        love.graphics.setColor(colors.p1_1:rgb())
        love.graphics.setFont(v.font)
        love.graphics.print(v.text, v.x, v.y)
        ]]
    end
end
