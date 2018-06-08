
debugger = {
    logs = {},
    logVals = {},
    show = false,
    console = {active=false, val='', lastVal=''}
}

function debugger.log(msg)
    table.insert(debugger.logs, msg)
end

function debugger.logVal(k, v)
    debugger.logVals[k] = {v=v, time=time}
end

function debugger.console.textinput(t)
    if not (t == '`') then
        debugger.console.val = debugger.console.val .. t
    end
end

function debugger.console.keypressed(k, scancode, isrepeat)
    if k == 'return' then
		debugger.console.submit()
	elseif k == 'backspace' then
		local lcv = debugger.console.val
		debugger.console.val = lcv:sub(0, math.max(lcv:len()-1, 0))
	elseif k == 'up' then
		debugger.console.val = debugger.console.lastVal
	elseif k == 'down' then
		debugger.console.val = ''
	elseif k == 'escape' then
		debugger.console.val = ''
		debugger.console.active = false
	end
end

function debugger.console.submit()
	debugger.console.active = false
	debugger.console.lastVal = debugger.console.val
    -- handle debugger.console.val here
	debugger.console.val = ''
end

function debugger.draw()
    debugger.logVal('FPS', love.timer.getFPS())
    debugger.log(time)
    local ctr = 0
    for _, typev in pairs(entities.container) do
        for _, _ in pairs(typev) do ctr = ctr + 1 end
    end
    debugger.logVal('entity container count - ', ctr)
    ctr = 0
    for _, chunkv in pairs(entities.culledContainer) do
        for _, typev in pairs(chunkv) do
            for _, _ in pairs(typev) do ctr = ctr + 1 end
        end
    end
    debugger.logVal('entity culled container count - ', ctr)

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
end
