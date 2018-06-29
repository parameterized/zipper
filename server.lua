
server = {}

function server.start(port, singleplayer)
    port = tonumber(port)
    server.singleplayer = singleplayer
    local connectionLimit = server.singleplayer and 1 or nil
    server.nutServer = nut.server{port=port, connectionLimit=connectionLimit}
    server.nutServer:addRPCs{
        disconnect = function(self, data, clientId)
            local pname = server.currentState.players[clientId].name
            if not server.singleplayer then
                self:sendRPC('chatMsg', string.format('Server: %s disconnected', pname))
            end
            server.removePlayer(clientId)

            self.clients[clientId] = nil
            nut.log(clientId .. ' disconnected')
        end,
        requestPlayer = function(self, data, clientId)
            local postfix = 0
            local reservedNames = {}
            for _, v in pairs{'Server', 'server'} do reservedNames[v] = true end
            while server.playerNames[buildName(data, postfix)]
            or reservedNames[buildName(data, postfix)] do
                postfix = postfix + 1
            end
            -- send current state to new player
            local add = server.newState()
            for _, v in pairs(server.currentState.players) do
                table.insert(add.players, v)
            end
            for _, v in pairs(server.currentState.bullets) do
                table.insert(add.bullets, v)
            end
            for _, v in pairs(server.currentState.entities) do
                table.insert(add.entities, v)
            end
            self:sendRPC('add', json.encode(add), clientId)
            server.addPlayer(buildName(data, postfix), clientId)
        end,
        chatMsg = function(self, data, clientId)
            local pname = server.currentState.players[clientId].name
            self:sendRPC('chatMsg', string.format('%s: %s', pname, data))
        end,
        setPlayer = function(self, data, clientId)
            -- todo: more validation (value types)
            if pcall(function() data = json.decode(data) end) then
                server.currentState.players[clientId] = data
            else
                debugger.log('error decoding server rpc setPlayer')
            end
        end,
        spawnBullet = function(self, data, clientId)
            if pcall(function() data = json.decode(data) end) then
                bullets.server.spawn(data)
            else
                debugger.log('error decoding server rpc spawnBullet')
            end
        end
    }
    server.nutServer:addUpdate(function(self)
        local addStr = json.encode(server.added)
        if addStr ~= json.encode(server.newState()) then
            self:sendRPC('add', addStr)
        end
        server.added = server.newState()
        local removeStr = json.encode(server.removed)
        if removeStr ~= json.encode(server.newState()) then
            self:sendRPC('remove', removeStr)
        end
        server.removed = server.newState()
        local stateUpdate = server.newState()
        stateUpdate.time = gameTime
        for _, v in pairs(server.currentState.players) do
            -- don't send clientIds - index by uuid
            stateUpdate.players[v.id] = v
        end
        for _, v in pairs(server.currentState.bullets) do
            stateUpdate.bullets[v.id] = v
        end
        for _, v in pairs(server.currentState.entities) do
            -- don't update static entities
            if not entities.server.defs[v.type].static then
                stateUpdate.entities[v.id] = v
            end
        end
        self:sendRPC('stateUpdate', json.encode(stateUpdate))
    end)
    server.nutServer:start()
    server.running = true
    if not server.singleplayer then
        chat.addMsg('server started')
    end

    server.playerNames = {}
    server.uuid2clientId = {}
    -- added[type][id] = obj
    -- removed[type] = {id1, id2, ...}
    server.added = server.newState()
    server.removed = server.newState()
    server.currentState = server.newState()

    physics.server.load()
end

function server.newState()
    return {players={}, bullets={}, entities={}}
end

function server.addPlayer(name, clientId)
    local p = {
        id = uuid(), name = name,
        x = (math.random()*2-1)*256, y = (math.random()*2-1)*256, angle = 0,
        cursor = {x=0, y=0}
    }
    server.currentState.players[clientId] = p
    server.playerNames[name] = true
    server.uuid2clientId[p.id] = clientId
    table.insert(server.added.players, p)
    server.nutServer:sendRPC('returnPlayer', json.encode(p), clientId)
    if not server.singleplayer then
        server.nutServer:sendRPC('chatMsg', p.name .. ' connected')
    end
end

function server.removePlayer(clientId)
    local p = server.currentState.players[clientId]
    table.insert(server.removed.players, p.id)
    server.uuid2clientId[p.id] = nil
    server.playerNames[p.name] = nil
    server.currentState.players[clientId] = nil
end

function server.addPoints(playerId, pts)
    local clientId = server.uuid2clientId[playerId]
    if clientId then
        server.nutServer:sendRPC('setScore', player.score + pts, clientId)
    else
        print('clientId not found in server.addPoints()');
    end
end

function server.update(dt)
    server.nutServer:update(dt)

    physics.server.update(dt)
    bullets.server.update(dt)
    entities.server.update(dt)
end

function server.close()
    server.nutServer:sendRPC('serverClosed')
    server.nutServer:close()
    server.running = false
end
