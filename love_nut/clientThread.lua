
local channelIn, channelOut, updateRate = ...

require 'love.timer'
local socket = require 'socket'

local udp, tpc

local updateTimer = 0
local connected = false;

function sendRPC(name, data)
    if not data or data == '' then data = '$' end
    local dg = name .. ' ' .. data
    dg = dg:gsub('\r', ''):gsub('\n', '')
    dg = dg .. '\r\n'
    nutLog('client tcp send: ' .. dg)
    --return self.tcp:send(dg)
    tcp:send(dg)
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
        if connected then
            repeat
                local data, msg = udp:receive()
                if data then
                    nutLog('client received udp: ' .. data)
                    -- todo: handle
                elseif msg ~= 'timeout' then
                    nutLogError('client udp recv err: ' .. tostring(msg))
                end
            until not data
            repeat
                local data, msg = tcp:receive()
                if data then
                    nutLog('client received tcp: ' .. data)
                    local rpcName, rpcData = data:match('^(%S*) (.*)$')
                    channelOut:push{
                        cmd='callRPC', name=rpcName, data=rpcData
                    }
                elseif msg ~= 'timeout' then
                    nutLogError('client tcp recv err: ' .. tostring(msg))
                end
            until not data
        end
    end

    repeat
        local packet = channelIn:pop()
        if packet then
            if packet.cmd == 'connect' then
                local ip, port = packet.ip, packet.port
                udp = socket.udp()
                udp:settimeout(0)
                tcp = socket.tcp()
                tcp:settimeout(0)
                tcp:setoption('reuseaddr', true)
                tcp:setoption('tcp-nodelay', true)
                nutLog('connecting to ' .. ip .. ':' .. tostring(port))
                port = tonumber(port)
                udp:setpeername(ip, port)
                tcp:settimeout(5)
                local success, msg = tcp:connect(ip, port)
                if success then
                    --self.connected = true
                    nutLog('connected')
                else
                    nutLogError('client connect err: ' .. tostring(msg))
                end
                tcp:settimeout(0)
                connected = true
            elseif packet.cmd == 'sendRPC' then
                sendRPC(packet.name, packet.data)
            elseif packet.cmd == 'close' then
                udp:close()
                tcp:close()
                break
            end
        end
    until not packet
end
