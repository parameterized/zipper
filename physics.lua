
function beginContact(a, b, coll)
    for _, v in pairs({{a, b}, {b, a}}) do
        local va = v[1]
        local vb = v[2]
        uda = va:getUserData() or {}
        udb = vb:getUserData() or {}
        if uda.type == 'bullet' then
            if udb.type == 'enemy' then
                bullets.container[uda.id].destroy = true
                local ecv = enemies.container[udb.id]
                ecv.hp = ecv.hp - 1
            end
            break
        end
    end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalImpulse, tangentImpulse)

end

love.physics.setMeter(64)
physWorld = love.physics.newWorld(0, 0, true)
physWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
