
menu = {
    state = 'main',
    btns = {},
    inputs = {},
    activeInput = nil
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
            t.bh = math.max(math.floor(t.font:getHeight()) + 20, t.bh)
        end
    else
        t.bw = math.floor(t.font:getWidth(t.text)) + 40
        t.bh = math.floor(t.font:getHeight()) + 20
    end
    t.bx = t.x - t.bw/2
    t.by = t.y - t.bh/2
    if not menu.btns[t.state] then menu.btns[t.state] = {} end
    table.insert(menu.btns[t.state], t)
    return t
end

function menu.addInput(t)
    t.state = t.state or 'main'
    t.text = t.text or 'Input'
    t.font = t.font or fonts.f32
    t.value = t.value or ''
    t.action = t.action or function() end
    t.x = t.x or ssx/2
    t.x = math.floor(t.x)
    t.y = t.y or ssy/2
    t.y = math.floor(t.y)
    t.w = t.w or 320
    t.bw = t.w
    t.bh = t.font:getHeight() + 4
    t.bx = t.x - t.bw/2
    t.by = t.y - t.bh/2
    if not menu.inputs[t.state] then menu.inputs[t.state] = {} end
    table.insert(menu.inputs[t.state], t)
    return t
end
local menuDefaults
function menu.readDefaults()
    menuDefaults = dofile(love.filesystem.getRealDirectory('menuDefaults.lua') .. '/menuDefaults.lua')
end
if not pcall(menu.readDefaults) then
    -- write default if not exist or malformed
    local str = string.format("return {name='%s',ip='%s',port='%s'}", 'Player', '127.0.0.1', '1357')
    love.filesystem.write('menuDefaults.lua', str)
    menu.readDefaults()
end

function menu.writeDefaults()
    local str = string.format("return {name='%s',ip='%s',port='%s'}", menu.nameInput.value, menu.ipInput.value, menu.portInput.value)
    love.filesystem.write('menuDefaults.lua', str)
end

menu.addBtn{text='Zipper', font=fonts.f48, y=120, type='static'}
menu.addBtn{text='Play', y=360, action=function()
    menu.state = 'play'
end}
menu.addBtn{text='Options', y=440, action=function()
    menu.state = 'options'
end}
menu.addBtn{text='Exit', y=580, action=function()
    love.event.quit()
end}

menu.nameInput = menu.addInput{state='play', text='Player Name', value=menuDefaults.name, x=ssx/2 - 180, y=380}
menu.addBtn{state='play', text='Singleplayer', x=ssx/2 - 180, y=460, action=function()
    menu.writeDefaults()
    player.name = menu.nameInput.value
    gameState = 'playing'
    love.mouse.setCursor(cursors.crosshairUp)
    love.mouse.setGrabbed(true)
end}
menu.ipInput = menu.addInput{state='play', text='IP', value=menuDefaults.ip, x=ssx/2 + 180, y=300}
menu.portInput = menu.addInput{state='play', text='Port', value=menuDefaults.port, x=ssx/2 + 180, y=380}
menu.addBtn{state='play', text='Host', x=ssx/2 + 180 - 60, y=460, action=function()
    menu.writeDefaults()
    print('host on port ' .. menu.portInput.value)
end}
menu.addBtn{state='play', text='Join', x=ssx/2 + 180 + 60, y=460, action=function()
    menu.writeDefaults()
    print(string.format('connect to %s:%s', menu.ipInput.value, menu.portInput.value))
end}
menu.addBtn{state='play', text='Back', y=580, action=function()
    menu.state = 'main'
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
    menu.activeInput = nil
    for _, v in pairs(menu.btns[menu.state] or {}) do
        if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
            if v.type == 'toggle' then
                v.active = not v.active
                v.action(v.active)
            elseif v.type == 'cycle' then
                v.active = ((v.active - 1 + (btn == 2 and -1 or 1)) % #v.items) + 1
                v.action(v.items[v.active])
            else
                v.action()
            end
            return
        end
    end
    for _, v in pairs(menu.inputs[menu.state] or {}) do
        if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
            menu.activeInput = v
            return
        end
    end
end

function menu.textinput(t)
    if menu.activeInput then
        menu.activeInput.value = menu.activeInput.value .. t
    end
end

function menu.keypressed(k, scancode, isrepeat)
    if menu.state == 'main' then
        if k == 'escape' then
            --love.event.quit()
        end
    elseif menu.state == 'play' then
        if k == 'escape' then
            menu.state = 'main'
            menu.activeInput = nil
        end
    elseif menu.state == 'options' then
        if k == 'escape' then
            menu.state = 'main'
            menu.activeInput = nil
        end
    end
    if menu.activeInput then
        if k == 'return' then
			menu.activeInput = nil
		elseif k == 'backspace' then
			menu.activeInput.value = menu.activeInput.value:sub(0, math.max(menu.activeInput.value:len()-1, 0))
		elseif k == 'v' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
			local paste = love.system.getClipboardText()
			for v in paste:gmatch('.') do
				menu.activeInput.value = menu.activeInput.value .. v
			end
		end
    end
end

function menu.draw()
    local mx, my = love.mouse.getPosition()
    mx = mx/graphicsScale
    my = my/graphicsScale
    love.graphics.clear(colors.p5:rgb())
    for _, v in pairs(menu.btns[menu.state] or {}) do
        if v.draw then
            v.draw(v, mx, my)
        else
            if not (v.type == 'static') then
                if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh then
                    love.graphics.setColor(colors.p5_1:rgb())
                else
                    if v.type == 'toggle' and v.active then
                        love.graphics.setColor(colors.p5_1:clone():lighten(0.8):rgb())
                    else
                        love.graphics.setColor(colors.p5_2:rgb())
                    end
                end
                love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
            end
            local text = v.text
            if v.type == 'cycle' then
                love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
                love.graphics.setColor(colors.p1_1:clone():lighten(0.8):rgb())
                love.graphics.setFont(v.font)
                love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), v.by - v.font:getHeight())
                text = v.items[v.active]
            end
            love.graphics.setColor(colors.p1_1:rgb())
            love.graphics.setFont(v.font)
            love.graphics.print(text, math.floor(v.x - v.font:getWidth(text)/2), math.floor(v.y - v.font:getHeight()/2))
        end
    end
    for _, v in pairs(menu.inputs[menu.state] or {}) do
        if v.draw then
            v.draw(v, mx, my)
        else
            if mx > v.bx and mx < v.bx + v.bw and my > v.by and my < v.by + v.bh
            and (menu.activeInput == v or menu.activeInput == nil) or menu.activeInput == v then
                love.graphics.setColor(colors.p5_1:clone():lighten(1.5):rgb())
            else
                love.graphics.setColor(colors.p5_2:clone():lighten(1.5):rgb())
            end
            love.graphics.rectangle('fill', v.bx, v.by, v.bw, v.bh)
            love.graphics.setColor(colors.p1_1:clone():lighten(0.8):rgb())
            love.graphics.setFont(v.font)
            love.graphics.print(v.text, math.floor(v.x - v.font:getWidth(v.text)/2), v.by - v.font:getHeight())
            text = v.value
            if menu.activeInput == v then text = text .. (time % 1 < 0.5 and '' or '|') end
            love.graphics.setColor(colors.p1_1:rgb())
            love.graphics.setFont(v.font)
            love.graphics.print(text, math.floor(v.x - v.font:getWidth(text)/2), math.floor(v.y - v.font:getHeight()/2))
        end
    end
end
