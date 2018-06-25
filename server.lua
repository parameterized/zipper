
server = {}

function server.start(port)
    server.nutServer = nut.server{port=port}
    server.running = true
end

function server.update(dt)
    if server.running then
        server.nutServer.update(dt)
    end
end

function server.close()
    if server.running then
        server.nutServer:close()
    end
end
