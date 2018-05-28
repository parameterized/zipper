
Color = require 'color'
require 'utils'
require 'loadassets'
Camera = require 'camera'
camera = Camera()
require 'menu'
require 'physics'
require 'world'
require 'player'
require 'bullets'
require 'enemies'
require 'hud'

gameState = 'menu'
time = 0
showDebug = false
freeFire = false

function love.load()

end

function love.update(dt)
    if gameState == 'menu' then

    elseif gameState == 'playing' then
        time = time + dt
        physWorld:update(dt)
        world.update(dt)
        player.update(dt)
        bullets.update(dt)
        enemies.update(dt)
    end
end

function love.mousepressed(x, y, btn, isTouch)
    if gameState == 'menu' then
        menu.mousepressed(x, y, btn)
    elseif gameState == 'playing' then
        player.mousepressed(x, y, btn)
    end
end

function love.keypressed(k, scancode, isrepeat)
    if gameState == 'menu' then
        menu.keypressed(k)
    elseif gameState == 'playing' then
        if k == 'escape' then
            gameState = 'menu'
        end
    end
    if k == 'f1' then
        showDebug = not showDebug
    elseif k == 'f2' then
        freeFire = not freeFire
    end
end

function love.draw()
    if gameState == 'menu' then
        menu.draw()
    elseif gameState == 'playing' then
        camera:set()
        world.draw()
        enemies.draw()
        bullets.draw()
        player.draw()
        camera:reset()
        hud.draw()
    end
    if showDebug then
        love.graphics.setColor(0, 0.8, 0)
        love.graphics.setFont(fonts.f14)
        love.graphics.print(love.timer.getFPS(), 4, 2)
    end
end
