
client = {}

function client.connect(ip, port)
    port = tonumber(port)
    client.nutClient = nut.client()
    client.nutClient:addRPCs{
        returnPlayer = function(self, data)
            local p = json.decode(data)
            client.startGame(p)
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
        end,
        add = function(self, data)
            data = json.decode(data)
            for _, v in pairs(data.players) do
                if v.id ~= player.id then
                    client.currentState.players[v.id] = v
                end
            end
        end,
        remove = function(self, data)
            data = json.decode(data)
            for _, v in pairs(data.players) do
                if v.id ~= player.id then
                    client.currentState.players[v.id] = nil
                end
            end
        end
    }
    client.nutClient:connect(ip, port)
    client.connected = true
    client.nutClient:sendRPC('requestPlayer', menu.nameInput.value)
    -- client.players indexed by uuid (player.id), don't send ips
    client.currentState = {players={}}
end

function client.startGame(p)
    player.id = p.id
    player.name = p.name
    player.body:setPosition(p.x, p.y)
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
