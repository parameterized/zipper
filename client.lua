
client = {}

function client.connect(ip, port)
    port = tonumber(port)
    client.nutClient = nut.client()
    client.nutClient:addRPCs{
        returnPlayerName = function(self, data)
            client.startGame(data)
        end,
        chatMsg = function(self, data)
            chat.addMsg(data)
        end,
        serverClosed = function(self, data)
            -- todo: show message in game
            print('server closed')
            gameState = 'menu'
            menu.state = 'main'
            menu.overlayActive = false
            client.close()
        end
    }
    client.nutClient:connect(ip, port)
    client.connected = true
    client.nutClient:sendRPC('requestPlayer', menu.nameInput.value)
end

function client.startGame(playerName)
    player.name = playerName
    gameState = 'playing'
    menu.state = 'overlay'
    love.mouse.setCursor(cursors.crosshairUp)
    if menu.cursorLockBtn.active then love.mouse.setGrabbed(true) end
    player.lastFireTime = gameTime
end

function client.update(dt)
    client.nutClient:update(dt)
end

function client.close()
    client.nutClient:close()
    client.connected = false
end
