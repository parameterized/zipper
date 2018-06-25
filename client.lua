
client = {}

function client.connect(ip, port)
    client.nutClient = nut.client()
    client.nutClient:connect(ip, port)
    client.connected = true
end

function client.update(dt)
    if client.connected then
        client.nutClient:update(dt)
    end
end

function client.close()
    if client.connected then
        client.nutClient:close()
    end
end
