
local socket = require 'socket'

local nut = {
    logMessages = false,
    logErrors = true,
    _VERSION = 'LoveNUT 0.1.0'
}

function nut.log(msg)
    if nut.logMessages then print(msg) end
end

function nut.logError(err)
    if nut.logErrors then print(err) end
end

-- local ip
function nut.getIP()
    local s = socket.udp()
    s:setpeername('8.8.8.8', 80)
    local ip, port = s:getsockname()
    return ip
end


local client = {}

client.rpcs = {}

function client:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local defaults = {updateRate=1/20}
    for k, v in pairs(defaults) do
        if not o[k] then o[k] = v end
    end
    o.updateTimer = 0
    o.connected = false
    nut.log('created client')
    return o
end

function client:connect(ip, port)
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.tcp = socket.tcp()
    self.tcp:settimeout(0)
    self.tcp:setoption('reuseaddr', true)
    self.tcp:setoption('tcp-nodelay', true)
    nut.log('connecting to ' .. ip .. ':' .. tostring(port))
    port = tonumber(port)
    self.udp:setpeername(ip, port)
    self.tcp:settimeout(5)
    local success, msg = self.tcp:connect(ip, port)
    if success then
        self.connected = true
        nut.log('connected')
    else
        nut.logError('client connect err: ' .. tostring(msg))
    end
    self.tcp:settimeout(0)
end

function client:addRPCs(t)
    for name, rpc in pairs(t) do
        self.rpcs[name] = rpc
    end
end

function client:update(dt)
    self.updateTimer = self.updateTimer + dt
    if self.updateTimer > self.updateRate then
        self.updateTimer = self.updateTimer - self.updateRate
        if self.connected then
            repeat
                local data, msg = self.udp:receive()
                if data then
                    nut.log('client received udp: ' .. data)
                    -- todo: handle
                elseif msg ~= 'timeout' then
                    nut.logError('client udp recv err: ' .. tostring(msg))
                end
            until not data
            repeat
                local data, msg = self.tcp:receive()
                if data then
                    nut.log('client received tcp: ' .. data)
                    local rpcName, rpcData = data:match('^(%S*) (.*)$')
                    local rpc = self.rpcs[rpcName]
                    if rpc then
                        rpc(self, rpcData)
                    else
                        nut.logError('client rpc "' .. rpcName .. '" not found')
                    end
                elseif msg ~= 'timeout' then
                    nut.logError('client tcp recv err: ' .. tostring(msg))
                end
            until not data
        end
    end
end

function client:sendRPC(name, data)
    if not data or data == '' then data = '$' end
    local dg = name .. ' ' .. data
    dg = dg:gsub('\r', ''):gsub('\n', '')
    dg = dg .. '\r\n'
    nut.log('client tcp send: ' .. dg)
    return self.tcp:send(dg)
end

function client:close()
    self:sendRPC('disconnect')
    self.tcp:close()
end

setmetatable(client, {__call = function(_, ...) return client:new(...) end})


local server = {}

server.rpcs = {
    disconnect = function(self, data, clientId)
        self.clients[clientId] = nil
        nut.log(clientId .. ' disconnected')
    end
}

function server:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local defaults = {port=1357, updateRate=1/20}
    for k, v in pairs(defaults) do
        if not o[k] then o[k] = v end
    end
    o.updateTimer = 0
    nut.log('created server')
    return o
end

function server:start()
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setsockname('0.0.0.0', self.port)
    self.tcp = socket.tcp()
    self.tcp:settimeout(0)
    self.tcp:setoption('reuseaddr', true)
    self.tcp:setoption('tcp-nodelay', true)
    self.tcp:bind('0.0.0.0', self.port)
    self.tcp:listen(5)
    self.clients = {}
    nut.log('started server')
    --nut.log('hosting on ' .. nut.getIP() .. ':' .. o.port)
end

function server:addRPCs(t)
    for name, rpc in pairs(t) do
        self.rpcs[name] = rpc
    end
end

function server:accept()
    local sock, msg = self.tcp:accept()
    if sock then
        sock:settimeout(0)
        sock:setoption('reuseaddr', true)
        sock:setoption('tcp-nodelay', true)
        local ip, port = sock:getpeername()
        local clientId = ip .. ':' .. tostring(port)
        if self.clients[clientId] then
            nut.logError(clientid .. ' already connected')
            return nil
        else
            self.clients[clientId] = {tcp=sock}
        end
        nut.log('server accepted ' .. clientId)
    elseif msg ~= 'timeout' then
        nut.logError('server tcp accept err: ' .. tostring(msg))
    end
    return sock, msg
end

function server:update(dt)
    self.updateTimer = self.updateTimer + dt
    if self.updateTimer > self.updateRate then
        self.updateTimer = self.updateTimer - self.updateRate
        repeat
            sock = self:accept()
        until not sock
        repeat
            local data, msg_or_ip, port_or_nil = self.udp:receivefrom()
            if data then
                local ip, port = msg_or_ip, port_or_nil
                nut.log('server received udp: ' .. data)
                local clientid = ip .. ':' .. tostring(port)
            elseif msg_or_ip ~= 'timeout' then
                nut.logError('server udp recv err: ' .. tostring(msg_or_ip))
            end
        until not data
        for clientId, v in pairs(self.clients) do
            repeat
                local data, msg = v.tcp:receive()
                if data then
                    nut.log('server received tcp: ' .. data)
                    local rpcName, rpcData = data:match('^(%S*) (.*)$')
                    local rpc = self.rpcs[rpcName]
                    if rpc then
                        rpc(self, rpcData, clientId)
                    else
                        nut.logError('server rpc "' .. rpcName .. '" not found')
                    end
                elseif msg ~= 'timeout' then
                    nut.logError('server tcp recv err: ' .. tostring(msg_or_ip))
                end
            until not data
        end
    end
end

function server:sendRPC(name, data, clientId)
    if not data or data == '' then data = '$' end
    local dg = name .. ' ' .. data
    dg = dg:gsub('\r', ''):gsub('\n', '')
    dg = dg .. '\r\n'
    if clientId then
        if self.clients[clientId] then
            --local ip, port = clientId:match("^(.-):(%d+)$")
            self.clients[clientId].tcp:send(dg)
        else
            nut.logError(clientId .. ' not in client list')
        end
    else
        for clientId, v in pairs(self.clients) do
            v.tcp:send(dg)
        end
    end
end

function server:close()
    self.tcp:close()
end

setmetatable(server, {__call = function(_, ...) return server:new(...) end})


nut.client = client
nut.server = server

return nut
