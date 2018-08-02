
physics = {
    server = {
        postUpdateQueue = {}
    },
    client = {
        postUpdateQueue = {}
    }
}

love.physics.setMeter(64)

function physics.server.load()
    if physics.server.world then physics.server.world:destroy() end
    physics.server.world = love.physics.newWorld(0, 0, true)
    physics.server.world:setCallbacks(physics.server.beginContact,
    physics.server.endContact, physics.server.preSolve, physics.server.postSolve)
end

function physics.server.update(dt)
    physics.server.world:update(dt)
    for i, v in pairs(physics.server.postUpdateQueue) do
        v()
        physics.server.postUpdateQueue[i] = nil
    end
end

function physics.server.postUpdatePush(f)
    local id = #physics.server.postUpdateQueue + 1
    physics.server.postUpdateQueue[id] = f
end

function physics.server.beginContact(a, b, coll)
    for _, v in pairs({{a, b}, {b, a}}) do
        local va = v[1]
        local vb = v[2]
        local uda = va:getUserData() or {}
        local udb = vb:getUserData() or {}
        if uda.type == 'bullet' then
            if udb.enemy then
                physics.server.postUpdatePush(function() udb:damage(1, uda.playerId) end)
                physics.server.postUpdatePush(function() bullets.server.destroy(uda.id) end)
            end
            break
        end
    end
end

function physics.server.endContact(a, b, coll)

end

function physics.server.preSolve(a, b, coll)

end

function physics.server.postSolve(a, b, coll, normalImpulse, tangentImpulse)

end



function physics.client.load()
    if physics.client.world then physics.client.world:destroy() end
    physics.client.world = love.physics.newWorld(0, 0, true)
    physics.client.world:setCallbacks(physics.client.beginContact,
        physics.client.endContact, physics.client.preSolve, physics.client.postSolve)
end

function physics.client.update(dt)
    physics.client.world:update(dt)
    for i, v in pairs(physics.client.postUpdateQueue) do
        v()
        physics.client.postUpdateQueue[i] = nil
    end
end

function physics.client.postUpdatePush(f)
    local id = #physics.client.postUpdateQueue + 1
    physics.client.postUpdateQueue[id] = f
end

function physics.client.beginContact(a, b, coll)

end

function physics.client.endContact(a, b, coll)

end

function physics.client.preSolve(a, b, coll)

end

function physics.client.postSolve(a, b, coll, normalImpulse, tangentImpulse)

end
