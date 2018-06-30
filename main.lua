
Color = require 'color'
require 'utils'
require 'loadassets'
Camera = require 'camera'
camera = Camera{ssx=ssx, ssy=ssy}
debugCam = Camera{ssx=ssx, ssy=ssy}
activeCam = camera
nut = require 'love_nut'
json = require 'json'
require 'server'
require 'client'
require 'debugger'
require 'menu'
require 'physics'
require 'world'
require 'player'
require 'bullets'
require 'entities'
require 'hud'
require 'chat'

function love.load()
    gameState = 'menu'
    time = 0
    gameTime = 0
    parallax = false
end

function love.update(dt)
    time = time + dt
    if server.running then
        server.update(dt)
    end
    if client.connected then
        client.update(dt)
    end
    if not (server.running and server.paused) and gameState == 'playing' then
        gameTime = gameTime + dt
        player.update(dt)
    end
end

function love.mousepressed(x, y, btn, isTouch)
    x = x/graphicsScale
    y = y/graphicsScale
    menu.mousepressed(x, y, btn)
    if gameState == 'playing' and not menu.overlayActive then
        love.mouse.setCursor(cursors.crosshairDown)
        player.mousepressed(x, y, btn)
    end
end

function love.mousereleased(x, y, btn, isTouch)
    x = x/graphicsScale
    y = y/graphicsScale
    if gameState == 'playing' and not menu.overlayActive then
        love.mouse.setCursor(cursors.crosshairUp)
    end
end

function love.textinput(t)
    if debugger.console.active then
        debugger.console.textinput(t)
    elseif chat.active then
        chat.textinput(t)
    else
        menu.textinput(t)
        if gameState == 'playing' then

        end
    end
end

function love.keypressed(k, scancode, isrepeat)
    -- don't open chat when console submit or menu when escape
    local consoleActive = debugger.console.active
    local chatActive = chat.active
    if consoleActive then
        debugger.console.keypressed(k, scancode, isrepeat)
    else
        if not chatActive and k == '`' and not isrepeat then
            debugger.console.active = true
        end
    end
    if chatActive then
        chat.keypressed(k, scancode, isrepeat)
    else
        if gameState == 'playing' and not consoleActive
        and k == 'return' and not isrepeat then
            chat.active = true
        end
    end
    if not consoleActive and not chatActive then
        menu.keypressed(k, scancode, isrepeat)
        if not isrepeat then
            if k == 'f1' then
                debugger.show = not debugger.show
            elseif k == 'f2' then
                if server.running then
                    for _, v in pairs(entities.server.dynamic.container['hex'] or {}) do
                        v.body:setLinearVelocity((math.random()*2-1)*4e3, (math.random()*2-1)*4e3)
                    end
                end
            end
        end
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(graphicsScale)
    if gameState == 'playing' then
        activeCam = camera
        if debugger.show then
            activeCam = debugCam
            debugCam.x, debugCam.y = camera.x, camera.y
            debugCam.scale = 0.5
        end
        activeCam:set()

        world.draw()

        entities.client.draw()

        if parallax then
            love.graphics.push()
            love.graphics.origin()
            local cam = activeCam:clone()
            cam:scaleBy(1.05)
            cam:set()
            love.graphics.setCanvas(canvases.parallax)
            love.graphics.clear(0, 0, 0, 0)

            entities.client.draw()

            cam:reset()
            love.graphics.scale(graphicsScale)
            love.graphics.setCanvas()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(canvases.parallax)
            love.graphics.pop()
        end

        bullets.client.draw()
        player.draw()

        activeCam:reset()
        hud.draw()
        chat.draw()
    end
    menu.draw()
    debugger.draw()
    local mx, my = love.mouse.getPosition()
    mx = mx/graphicsScale
    my = my/graphicsScale
    local wmx, wmy = camera:screen2world(mx, my)
    love.graphics.pop()
end

function love.quit()
    if server.running then
        server.close()
    end
    if client.connected then
        client.close()
    end
    menu.writeDefaults()
end
