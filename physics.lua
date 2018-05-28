
function beginContact(a, b, coll)

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
