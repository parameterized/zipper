
server = {}

function server.start(port, singleplayer)
    port = tonumber(port)
    server.singleplayer = singleplayer
    server.players = {}
    server.added = {players={}}
    server.removed = {players={}}
    server.playerNames = {}
    server.uuid2clientId = {}
    local connectionLimit = server.singleplayer and 1 or nil
    server.nutServer = nut.server{port=port, connectionLimit=connectionLimit}
    server.nutServer:addRPCs{
        disconnect = function(self, data, clientId)
            local pname = server.players[clientId].name
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
            local add = {players={}}
            for _, v in pairs(server.players) do
                table.insert(add.players, v)
            end
            self:sendRPC('add', json.encode(add), clientId)
            server.addPlayer(buildName(data, postfix), clientId)
        end,
        chatMsg = function(self, data, clientId)
            local pname = server.players[clientId].name
            self:sendRPC('chatMsg', string.format('%s: %s', pname, data))
        end,
        setPlayer = function(self, data, clientId)
            -- todo: more validation (value types)
            if pcall(function() data = json.decode(data) end) then
                server.players[clientId] = data
            else
                debugger.log('error decoding server rpc setPlayer')
            end
        end
    }
    server.nutServer:addUpdate(function(self)
        local addStr = json.encode(server.added)
        if addStr ~= '{"players":[]}' then
            self:sendRPC('add', addStr)
        end
        server.added = {players={}}
        local removeStr = json.encode(server.removed)
        if removeStr ~= '{"players":[]}' then
            self:sendRPC('remove', removeStr)
        end
        server.removed = {players={}}
        local stateUpdate = {players={}, time=gameTime}
        for _, v in pairs(server.players) do
            -- don't send clientIds - index by uuid
            stateUpdate.players[v.id] = v
        end
        self:sendRPC('stateUpdate', json.encode(stateUpdate))
    end)
    server.nutServer:start()
    server.running = true
    if not server.singleplayer then
        chat.addMsg('server started')
    end
end

function server.addPlayer(name, clientId)
    local p = {
        id = uuid(), name = name,
        x = (math.random()*2-1)*256, y = (math.random()*2-1)*256, angle = 0,
        cursor = {x=0, y=0}
    }
    server.players[clientId] = p
    server.playerNames[name] = true
    server.uuid2clientId[p.id] = clientId
    table.insert(server.added.players, p)
    server.nutServer:sendRPC('returnPlayer', json.encode(p), clientId)
    if not server.singleplayer then
        server.nutServer:sendRPC('chatMsg', p.name .. ' connected')
    end
end

function server.removePlayer(clientId)
    local p = server.players[clientId]
    table.insert(server.removed.players, p)
    server.uuid2clientId[p.id] = nil
    server.playerNames[p.name] = nil
    server.players[clientId] = nil
end

function server.update(dt)
    server.nutServer:update(dt)
end

function server.close()
    server.nutServer:sendRPC('serverClosed')
    server.nutServer:close()
    server.running = false
end
