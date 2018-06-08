
Color = require 'color'
require 'utils'
require 'loadassets'
Camera = require 'camera'
camera = Camera()
require 'debugger'
require 'menu'
require 'physics'
require 'world'
require 'player'
require 'bullets'
require 'entities'
require 'hud'

gameState = 'menu'
time = 0

function love.load()

end

function love.update(dt)
    if gameState == 'menu' then

    elseif gameState == 'playing' then
        time = time + dt
        physics.world:update(dt)
        physics.postUpdate()
        world.update(dt)
        player.update(dt)
        bullets.update(dt)
        entities.update(dt)
    end
end

function love.mousepressed(x, y, btn, isTouch)
    if gameState == 'menu' then
        menu.mousepressed(x, y, btn)
    elseif gameState == 'playing' then
        love.mouse.setCursor(cursors.crosshairDown)
        player.mousepressed(x, y, btn)
    end
end

function love.mousereleased(x, y, btn, isTouch)
    if gameState == 'menu' then

    elseif gameState == 'playing' then
        love.mouse.setCursor(cursors.crosshairUp)
    end
end

function love.textinput(t)
    if debugger.console.active then
        debugger.console.textinput(t)
    else

    end
end

function love.keypressed(k, scancode, isrepeat)
    if k == '`' and not debugger.console.active then
        debugger.console.active = true
    end
    if debugger.console.active then
        debugger.console.keypressed(k, scancode, isrepeat)
    else
        if gameState == 'menu' then
            menu.keypressed(k)
        elseif gameState == 'playing' then
            if k == 'escape' then
                gameState = 'menu'
                love.mouse.setCursor()
                love.mouse.setGrabbed(false)
            end
        end
        if k == 'f1' then
            debugger.show = not debugger.show
        elseif k == 'f2' then
            player.freeFire = not player.freeFire
        elseif k == 'f3' then
            for _, v in pairs(entities.container['hex'] or {}) do
                v.body:setLinearVelocity((math.random()*2-1)*4e3, (math.random()*2-1)*4e3)
            end
        end
    end
end

function love.draw()
    if gameState == 'menu' then
        menu.draw()
    elseif gameState == 'playing' then
        camera:set()
        world.draw()
        entities.draw()
        bullets.draw()
        player.draw()
        camera:reset()
        hud.draw()
    end
    debugger.draw()
end
