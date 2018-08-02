
local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

local socket = require 'socket'
local http = require 'socket.http'

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

function nut.getIP()
    local res = http.request('http://myip.dnsomatic.com/')
    return res
end

function nut.getLocalIP()
    local s = socket.udp()
    s:setpeername('8.8.8.8', 80)
    local ip, port = s:getsockname()
    return ip
end


local client = {}

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
    o.thread = love.thread.newThread(_PACKAGE .. 'clientThread.lua')
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
            nut.log(clientId .. ' disconnected')
        end
    }
    defaults.updates = {}
    for k, v in pairs(defaults) do
        if not o[k] then o[k] = v end
    end
    o.updateTimer = 0
    o.thread = love.thread.newThread(_PACKAGE .. 'serverThread.lua')
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
