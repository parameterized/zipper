
physics = {
    postUpdateQueue = {}
}

function physics.postUpdate()
    for i, v in pairs(physics.postUpdateQueue) do
        v()
        physics.postUpdateQueue[i] = nil
    end
end

function physics.postUpdatePush(f)
    local id = #physics.postUpdateQueue + 1
    physics.postUpdateQueue[id] = f
end

function physics.beginContact(a, b, coll)
    for _, v in pairs({{a, b}, {b, a}}) do
        local va = v[1]
        local vb = v[2]
        uda = va:getUserData() or {}
        udb = vb:getUserData() or {}
        if uda.type == 'bullet' then
            if udb.type == 'enemy' then
                physics.postUpdatePush(function() bullets.destroy(uda.id) end)
                local ecv = entities.container[udb.id]
                physics.postUpdatePush(function() ecv:damage(1) end)
            end
            break
        end
    end
end

function physics.endContact(a, b, coll)

end

function physics.preSolve(a, b, coll)

end

function physics.postSolve(a, b, coll, normalImpulse, tangentImpulse)

end

love.physics.setMeter(64)
physics.world = love.physics.newWorld(0, 0, true)
physics.world:setCallbacks(physics.beginContact, physics.endContact, physics.preSolve, physics.postSolve)
