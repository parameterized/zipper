
server = {}

function server.start(port, singleplayer)
    port = tonumber(port)
    server.singleplayer = singleplayer
    server.players = {}
    server.added = {players={}}
    server.removed = {players={}}
    server.playerNames = {}
    server.nutServer = nut.server{port=port}
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
            -- don't send clientIds
            for _, v in pairs(server.players) do
                table.insert(add.players, v)
            end
            self:sendRPC('add', json.encode(add), clientId)
            server.addPlayer(buildName(data, postfix), clientId)
        end,
        chatMsg = function(self, data, clientId)
            local pname = server.players[clientId].name
            self:sendRPC('chatMsg', string.format('%s: %s', pname, data))
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
    end)
    server.nutServer:start()
    server.running = true
    if not server.singleplayer then
        chat.addMsg('server started')
    end
end

function server.addPlayer(name, clientId)
    local p = {id=uuid(), name=name, x=(math.random()*2-1)*256, y=(math.random()*2-1)*256}
    server.players[clientId] = p
    server.playerNames[name] = true
    table.insert(server.added.players, p)
    server.nutServer:sendRPC('returnPlayer',
        json.encode({id=p.id, name=p.name, x=p.x, y=p.y}), clientId)
    if not server.singleplayer then
        server.nutServer:sendRPC('chatMsg', p.name .. ' connected')
    end
end

function server.removePlayer(clientId)
    local p = server.players[clientId]
    table.insert(server.removed.players, p)
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
