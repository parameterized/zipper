
local socket = require 'socket'

local nut = {
    logMessages = false,
    logErrors = true,
    _VERSION = 'LoveNUT 0.1.1-dev'
}

function nut.log(msg)
    if nut.logMessages then print(msg) end
end

function nut.logError(err)
    if nut.logErrors then print(err) end
end

-- todo: replace with local/public functions
-- local ip
function nut.getIP()
    local s = socket.udp()
    s:setpeername('8.8.8.8', 80)
    local ip, port = s:getsockname()
    return ip
end


local client = {}

client.threadCode = [[
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
]]

function client:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local defaults = {updateRate=1/20}
    defaults.rpcs = {}
    defaults.updates = {}
    for k, v in pairs(defaults) do
        if not o[k] then o[k] = v end
    end
    o.updateTimer = 0
    o.connected = false
    o.thread = love.thread.newThread(self.threadCode)
    o.threadChannelIn = love.thread.newChannel()
    o.threadChannelOut = love.thread.newChannel()
    o.thread:start(o.threadChannelIn, o.threadChannelOut, o.updateRate)
    nut.log('created client')
    return o
end

function client:connect(ip, port)
    self.threadChannelIn:push{
        cmd='connect', ip=ip, port=port
    }
    self.connected = true
end

function client:addRPCs(t)
    for name, rpc in pairs(t) do
        self.rpcs[name] = rpc
    end
end

function client:addUpdate(f)
    table.insert(self.updates, f)
end

function client:update(dt)
    repeat
        local packet = self.threadChannelOut:pop()
        if packet then
            if packet.cmd == 'callRPC' then
                self:callRPC(packet.name, packet.data)
            elseif packet.cmd == 'nutLog' then
                nut.log(packet.msg)
            elseif packet.cmd == 'nutLogError' then
                nut.logError(packet.err)
            end
        end
    until not packet
    self.updateTimer = self.updateTimer + dt
    if self.updateTimer > self.updateRate then
        self.updateTimer = self.updateTimer - self.updateRate
        if self.connected then
            for _, v in pairs(self.updates) do
                v(self)
            end
        end
    end
end

function client:sendRPC(name, data)
    self.threadChannelIn:push{
        cmd='sendRPC', name=name, data=data
    }
end

function client:callRPC(name, data)
    local rpc = self.rpcs[name]
    if rpc then
        rpc(self, data)
    else
        nut.logError('client rpc "' .. tostring(name) .. '" not found')
    end
end

function client:close()
    self:sendRPC('disconnect')
    socket.sleep(0.1) -- todo: not good solution
    self.threadChannelIn:push{cmd='close'}
    client.connected = false
end

setmetatable(client, {__call = function(_, ...) return client:new(...) end})


local server = {}

server.threadCode = [[
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
]]

function server:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local defaults = {port=1357, updateRate=1/20, connectionLimit=nil}
    defaults.rpcs = {
        connect = function(self, data, clientId)
            nut.log(clientId .. ' connected')
        end,
        disconnect = function(self, data, clientId)
            self.clients[clientId] = nil
            nut.log(clientId .. ' disconnected')
        end
    }
    defaults.updates = {}
    for k, v in pairs(defaults) do
        if not o[k] then o[k] = v end
    end
    o.updateTimer = 0
    o.thread = love.thread.newThread(self.threadCode)
    o.threadChannelIn = love.thread.newChannel()
    o.threadChannelOut = love.thread.newChannel()
    o.thread:start(o.threadChannelIn, o.threadChannelOut, o.updateRate, o.connectionLimit)
    nut.log('created server')
    return o
end

function server:start()
    self.threadChannelIn:push{
        cmd='start', port=self.port
    }
end

function server:addRPCs(t)
    for name, rpc in pairs(t) do
        self.rpcs[name] = rpc
    end
end

function server:addUpdate(f)
    table.insert(self.updates, f)
end

function server:update(dt)
    repeat
        local packet = self.threadChannelOut:pop()
        if packet then
            if packet.cmd == 'callRPC' then
                self:callRPC(packet.name, packet.data, packet.clientId)
            elseif packet.cmd == 'nutLog' then
                nut.log(packet.msg)
            elseif packet.cmd == 'nutLogError' then
                nut.log(packet.err)
            end
        end
    until not packet
    self.updateTimer = self.updateTimer + dt
    if self.updateTimer > self.updateRate then
        self.updateTimer = self.updateTimer - self.updateRate
        for _, v in pairs(self.updates) do
            v(self)
        end
    end
end

function server:sendRPC(name, data, clientId)
    self.threadChannelIn:push{
        cmd='sendRPC', name=name, data=data, clientId=clientId
    }
end

function server:callRPC(name, data, clientId)
    local rpc = self.rpcs[name]
    if rpc then
        rpc(self, data, clientId)
    else
        nut.logError('server rpc "' .. tostring(name) .. '" not found')
    end
end

function server:close()
    self.threadChannelIn:push{cmd='close'}
end

setmetatable(server, {__call = function(_, ...) return server:new(...) end})


nut.client = client
nut.server = server

return nut
