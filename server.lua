
server = {}

function server.start(port)
    server.nutServer = nut.server{port=port}
    server.nutServer:addRPCs{
        connect = function(self, data, clientId)
            self:sendRPC('chatMsg', 'client connected')
        end,
        disconnect = function(self, data, clientId)
            self:sendRPC('chatMsg', 'client disconnected')
        end,
        chatMsg = function(self, data, clientId)
            self:sendRPC('chatMsg', data)
        end
    }
    server.nutServer:start()
    server.running = true
    chat.addMsg('server started')
end

function server.update(dt)
    server.nutServer:update(dt)
end

function server.close()
    server.nutServer:sendRPC('serverClosed')
    server.nutServer:close()
end
