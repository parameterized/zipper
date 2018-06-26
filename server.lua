
server = {}

function server.start(port, singleplayer)
    port = tonumber(port)
    server.singleplayer = singleplayer
    server.players = {}
    server.playerNames = {}
    server.nutServer = nut.server{port=port}
    server.nutServer:addRPCs{
        disconnect = function(self, data, clientId)
            local pname = server.players[clientId].name
            if not server.singleplayer then
                self:sendRPC('chatMsg', string.format('Server: %s disconnected', pname))
            end
            server.playerNames[pname] = false
            server.players[clientId] = nil

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
            server.addPlayer(buildName(data, postfix), clientId)
        end,
        chatMsg = function(self, data, clientId)
            local pname = server.players[clientId].name
            self:sendRPC('chatMsg', string.format('%s: %s', pname, data))
        end
    }
    server.nutServer:start()
    server.running = true
    if not server.singleplayer then
        chat.addMsg('server started')
    end
end

function server.addPlayer(name, clientId)
    local p = {name=name}
    server.players[clientId] = p
    server.playerNames[name] = true
    -- todo: return serialized spawn info (name, position)
    server.nutServer:sendRPC('returnPlayerName', p.name, clientId)
    if not server.singleplayer then
        server.nutServer:sendRPC('chatMsg', p.name .. ' connected')
    end
end

function server.update(dt)
    server.nutServer:update(dt)
end

function server.close()
    server.nutServer:sendRPC('serverClosed')
    server.nutServer:close()
    server.running = false
end
