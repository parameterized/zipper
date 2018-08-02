
local channelIn, channelOut, updateRate, connectionLimit = ...

require 'love.timer'
local socket = require 'socket'

local udp, tcp
local clients

local updateTimer = 0
local running = false

function accept()
    local sock, msg = tcp:accept()
    if sock then
        sock:settimeout(0)
        sock:setoption('reuseaddr', true)
        sock:setoption('tcp-nodelay', true)
        local ip, port = sock:getpeername()
        local clientId = ip .. ':' .. tostring(port)
        if clients[clientId] then
            nutLogError(clientid .. ' already connected')
            return nil
        else
            clients[clientId] = {tcp=sock}
        end
        channelOut:push{
            cmd='callRPC', name='connect', data='$', clientId=clientId
        }
    elseif msg ~= 'timeout' then
        nutLogError('server tcp accept err: ' .. tostring(msg))
    end
    return sock, msg
end

function sendRPC(name, data, clientId)
    if not data or data == '' then data = '$' end
    local dg = name .. ' ' .. data
    dg = dg:gsub('\r', ''):gsub('\n', '')
    dg = dg .. '\r\n'
    if clientId then
        if clients[clientId] then
            --local ip, port = clientId:match("^(.-):(%d+)$")
            clients[clientId].tcp:send(dg)
        else
            nutLogError(clientId .. ' not in client list')
        end
    else
        for clientId, v in pairs(clients) do
            v.tcp:send(dg)
        end
    end
end

function nutLog(msg)
    channelOut:push{
        cmd='nutLog', msg=msg
    }
end

function nutLogError(err)
    channelOut:push{
        cmd='nutLogError', err=err
    }
end

local lastTime = love.timer.getTime()
local dt = 0

while true do
    local time = love.timer.getTime()
    dt = time - lastTime
    lastTime = time

    updateTimer = updateTimer + dt
    if updateTimer > updateRate then
        updateTimer = updateTimer - updateRate
        if running then
            repeat
                local sock
                if connectionLimit then
                    local ctr = 0
                    for _, _ in pairs(clients) do ctr = ctr + 1 end
                    if ctr < connectionLimit then
                        sock = accept()
                    end
                else
                    sock = accept()
                end
            until not sock
            repeat
                local data, msg_or_ip, port_or_nil = udp:receivefrom()
                if data then
                    local ip, port = msg_or_ip, port_or_nil
                    nutLog('server received udp: ' .. data)
                    local clientid = ip .. ':' .. tostring(port)
                elseif msg_or_ip ~= 'timeout' then
                    nutLogError('server udp recv err: ' .. tostring(msg_or_ip))
                end
            until not data
            for clientId, v in pairs(clients) do
                repeat
                    local data, msg = v.tcp:receive()
                    if data then
                        nutLog('server received tcp: ' .. data)
                        local rpcName, rpcData = data:match('^(%S*) (.*)$')
                        channelOut:push{
                            cmd='callRPC', name=rpcName, data=rpcData, clientId=clientId
                        }
                        if rpcName == 'disconnect' then
                            clients[clientId] = nil
                        end
                    elseif msg ~= 'timeout' then
                        nutLogError('server tcp recv err: ' .. tostring(msg_or_ip))
                    end
                until not data
            end
        end
    end

    repeat
        local packet = channelIn:pop()
        if packet then
            if packet.cmd == 'start' then
                local port = packet.port
                udp = socket.udp()
                udp:settimeout(0)
                udp:setsockname('0.0.0.0', port)
                tcp = socket.tcp()
                tcp:settimeout(0)
                tcp:setoption('reuseaddr', true)
                tcp:setoption('tcp-nodelay', true)
                tcp:bind('0.0.0.0', port)
                tcp:listen(5)
                clients = {}
                nutLog('started server')
                running = true
            elseif packet.cmd == 'sendRPC' then
                sendRPC(packet.name, packet.data, packet.clientId)
            elseif packet.cmd == 'close' then
                udp:close()
                tcp:close()
                break
            end
        end
    until not packet
end
