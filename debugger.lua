
debugger = {
    logs = {},
    logVals = {},
    show = false,
    console = {active=false, val='', lastVal=''}
}

function debugger.log(msg)
    table.insert(debugger.logs, tostring(msg))
end

function debugger.logVal(k, v)
    debugger.logVals[k] = {v=tostring(v), time=time}
end

function debugger.console.textinput(t)
    if t ~= '`' then
        debugger.console.val = debugger.console.val .. t
    end
end

function debugger.console.keypressed(k, scancode, isrepeat)
    if k == 'return' then
		debugger.console.submit()
	elseif k == 'backspace' then
		local dcv = debugger.console.val
		debugger.console.val = dcv:sub(0, math.max(dcv:len()-1, 0))
	elseif k == 'up' then
		debugger.console.val = debugger.console.lastVal
	elseif k == 'down' then
		debugger.console.val = ''
	elseif k == 'escape' or k == '`' and not isrepeat then
		debugger.console.val = ''
		debugger.console.active = false
	end
end

function debugger.console.submit()
    local cmd = debugger.console.val
    if cmd == 'freefire' then
        player.freeFire = not player.freeFire
    elseif cmd == 'interpolate' then
        client.interpolate = not client.interpolate
    elseif cmd == 'parallax' then
        parallax = not parallax
    end

    debugger.console.lastVal = debugger.console.val
	debugger.console.val = ''
    debugger.console.active = false
end

function debugger.setVals()
    debugger.logVal('FPS', love.timer.getFPS())
    --debugger.log(time)

    local ctr
    if server.running then
        ctr = 0
        for _, typev in pairs(entities.server.static.container) do
            for _, _ in pairs(typev) do ctr = ctr + 1 end
        end
        debugger.logVal('server static entity container count', ctr)
        ctr = 0
        for _, chunkv in pairs(entities.server.static.culledContainer) do
            for _, typev in pairs(chunkv) do
                for _, _ in pairs(typev) do ctr = ctr + 1 end
            end
        end
        debugger.logVal('server static entity culled container count', ctr)

        ctr = 0
        for _, typev in pairs(entities.server.dynamic.container) do
            for _, _ in pairs(typev) do ctr = ctr + 1 end
        end
        debugger.logVal('server dynamic entity container count', ctr)
        ctr = 0
        for _, chunkv in pairs(entities.server.dynamic.culledContainer) do
            for _, typev in pairs(chunkv) do
                for _, _ in pairs(typev) do ctr = ctr + 1 end
            end
        end
        debugger.logVal('server dynamic entity culled container count', ctr)
    end
    if client.connected then
        ctr = 0
        local ctrB = 0
        for _, v in pairs(client.currentState.entities) do
            ctr = ctr + 1
            if not v.destroyed then ctrB = ctrB + 1 end
        end
        debugger.logVal('client entity container count', ctr)
        debugger.logVal('client entity alive count', ctrB)

        debugger.logVal('client state count', #client.states)
    end
end

function debugger.draw()
    debugger.setVals()

    if debugger.show then
		love.graphics.setFont(fonts.f14)
		love.graphics.setColor(0, 0.6, 0.8)
		local pos = 1
		for i=math.max(#debugger.logs-7, 1), #debugger.logs do
			local v = debugger.logs[i]
			love.graphics.print(v, 10, (pos+1)*16)
			pos = pos + 1
		end
		love.graphics.setColor(0, 0.8, 0.6)
		pos = 1
		for k, v in pairs(debugger.logVals) do
			if time - v.time < 6 then
				love.graphics.print(k .. ': ' .. v.v, 10, pos*16 + 10*16)
				pos = pos + 1
			else
				debugger.logVals[k] = nil
			end
		end
		love.graphics.setShader()
	end

	if debugger.console.active then
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle('fill', 6, 10, 200, 18)
		love.graphics.setFont(fonts.f14)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(debugger.console.val, 10, 12)
		love.graphics.setShader()
	end

    if not client.interpolate then
        love.graphics.setColor(0, 0, 0)
        local font = fonts.f18
        love.graphics.setFont(font)
        local text = 'client interpolation disabled'
        love.graphics.print(text, math.floor(ssx - font:getWidth(text) - 4), 60)
    end
end
