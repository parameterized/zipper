
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
                    v.body = love.physics.newBody(physics.world, v.x, v.y, 'dynamic')
                    v.shape = love.physics.newRectangleShape(50, 50)
                    v.fixture = love.physics.newFixture(v.body, v.shape, 1)
                    v.fixture:setUserData{type='otherPlayer'}
                    v.fixture:setCategory(3)
                    v.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
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
        end,
        stateUpdate = function(self, data)
            data = json.decode(data)
            for _, v in pairs(data.players) do
                if v.id ~= player.id and client.currentState.players[v.id] then
                    local p = client.currentState.players[v.id]
                    p.x = v.x
                    p.y = v.y
                    p.angle = v.angle
                    p.cursor = v.cursor
                    p.body:setPosition(p.x, p.y)
                    p.body:setAngle(p.angle)
                end
            end
        end
    }
    client.nutClient:addUpdate(function(self)
        self:sendRPC('setPlayer', json.encode(player.serialize()))
    end)
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
