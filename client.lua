
client = {}

function client.connect(ip, port)
    client.nutClient = nut.client()
    client.nutClient:addRPCs{
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
end

function client.update(dt)
    client.nutClient:update(dt)
end

function client.close()
    client.nutClient:close()
end
