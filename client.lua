
client = {}

function client.connect(ip, port)
    port = tonumber(port)
    client.nutClient = nut.client()
    client.nutClient:addRPCs{
        returnPlayer = function(self, data)
            if pcall(function() data = json.decode(data) end) then
                client.startGame(data)
            else
                debugger.log('err decoding client rpc returnPlayer')
            end
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
            if pcall(function() data = json.decode(data) end) then
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
            else
                debugger.log('error decoding client rpc add')
            end
        end,
        remove = function(self, data)
            if pcall(function() data = json.decode(data) end) then
                for _, v in pairs(data.players) do
                    if v.id ~= player.id then
                        client.currentState.players[v.id] = nil
                    end
                end
            else
                debugger.log('error decoding client rpc remove')
            end
        end,
        stateUpdate = function(self, data)
            if pcall(function() data = json.decode(data) end) then
                client.serverTime = math.max(client.serverTime, data.time)
                -- todo: delete old states (or make replay feature)
                table.insert(client.states, data)
            else
                debugger.log('error decoding client rpc stateUpdate')
            end
        end
    }
    client.nutClient:addUpdate(function(self)
        self:sendRPC('setPlayer', json.encode(player.serialize()))
    end)
    client.nutClient:connect(ip, port)
    client.connected = true
    client.nutClient:sendRPC('requestPlayer', menu.nameInput.value)

    client.serverTime = 0
    client.states = {}
    client.stateIdx = 1
    client.stateTime = 0
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
    client.serverTime = client.serverTime + dt
    client.nutClient:update(dt)
    -- interpolate states
    if client.states[#client.states] and client.states[#client.states-1] then
        client.stateTime = clamp(client.stateTime + dt,
            client.states[#client.states-1].time, client.states[#client.states].time)
        debugger.logVal('smoothing delay', client.serverTime - client.stateTime)
        while client.states[client.stateIdx+1] and client.states[client.stateIdx+2]
        and client.states[client.stateIdx+1].time < client.stateTime do
            client.stateIdx = client.stateIdx + 1
        end
        local t = (client.stateTime - client.states[client.stateIdx].time)
            / (client.states[client.stateIdx+1].time - client.states[client.stateIdx].time)
        for k, v in pairs(client.states[client.stateIdx].players) do
            local v2 = client.states[client.stateIdx+1].players[k]
            if v2 then
                local p = client.currentState.players[k]
                if p then
                    p.x = lerp(v.x, v2.x, t)
                    p.y = lerp(v.y, v2.y, t)
                    p.angle = lerp(v.angle, v2.angle, t)
                    p.cursor.x = lerp(v.cursor.x, v2.cursor.x, t)
                    p.cursor.y = lerp(v.cursor.y, v2.cursor.y, t)
                    p.body:setPosition(p.x, p.y)
                    p.body:setAngle(p.angle)
                end
            end
        end
    end
end

function client.close()
    client.nutClient:close()
    client.connected = false
end
