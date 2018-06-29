
chat = {
    log = {},
    active = false,
    val = '',
    lastMsgTime = 0
}

function chat.addMsg(v)
    table.insert(chat.log, v)
    chat.lastMsgTime = gameTime
end

function chat.submit()
    if chat.val ~= '' then
        client.sendMessage(chat.val)
    end
    chat.val = ''
    chat.active = false
end

function chat.textinput(t)
    chat.val = chat.val .. t
end

function chat.keypressed(k, scancode, isrepeat)
    if k == 'return' and not isrepeat then
        chat.submit()
    elseif k == 'backspace' then
        chat.val = chat.val:sub(0, math.max(chat.val:len()-1, 0))
    elseif k == 'escape' then
        chat.val = ''
        chat.active = false
    end
end

function chat.draw()
    if gameTime - chat.lastMsgTime < 4 or chat.active then
        local r, g, b = colors.p2:rgb()
        local a = 1
        if not chat.active and gameTime - chat.lastMsgTime > 3 then
            a = 4 - (gameTime - chat.lastMsgTime)
        end
        love.graphics.setColor(r, g, b, a)
        love.graphics.setFont(fonts.f18)
        local startIdx = math.max(#chat.log - (chat.active and 12 or 6) + 1, 1)
        local numMsgs = #chat.log - startIdx + 1
        for i=1, numMsgs do
            local v = chat.log[startIdx + (i-1)]
            local y = ssy - (numMsgs - (i-1) + 1)*20 - 6
            love.graphics.print(v, 4, y)
        end
    end
    if chat.active then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle('fill', 2, ssy - 24, 200, 22)
        love.graphics.setColor(colors.p2:rgb())
        love.graphics.print(chat.val, 4, ssy - 22)
    end
end
