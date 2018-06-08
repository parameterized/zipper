
entities = {
    container = {},
    culledContainer = {},
    defs = {},
    loadedChunks = {}
}
-- entities.container[type][id]
-- entities.culledContainer[chunk][type][id]

entities.influenceMargin = 10
-- should be larger than max entity influence radius * 3.5 (much larger is fine)
entities.chunkSize = 512

entities.defs.hex = require 'entityDefs.hex'
entities.defs.obstacle = require 'entityDefs.obstacle'

function entities.loadChunk(i, j)
    for k=1, 3 do
        local x = (i + hash2(i + k/5, j))*entities.chunkSize
        local y = (j + hash2(i, j + k/5))*entities.chunkSize
        entities.defs.hex:new{x=x, y=y}:spawn()
    end
    if hash2(i + 1/3, j) < 0.5 then
        local x = (i + hash2(i + 1/3, j + 1/3))*entities.chunkSize
        local y = (j + hash2(i + 2/3, j + 2/3))*entities.chunkSize
        entities.defs.obstacle:new{x=x, y=y}:spawn()
    end
end

function entities.update(dt)
    local camBX, camBY, camBW, camBH = camera:getAABB()

    local chunkBX = camBX - entities.chunkSize
    local chunkBY = camBY - entities.chunkSize
    local chunkBW = camBW + entities.chunkSize*2
    local chunkBH = camBH + entities.chunkSize*2
    local activeChunks = {}
    for i=math.floor(chunkBX/entities.chunkSize), math.floor((chunkBX + chunkBW)/entities.chunkSize) do
        for j=math.floor(chunkBY/entities.chunkSize), math.floor((chunkBY + chunkBH)/entities.chunkSize) do
            activeChunks[i .. ',' .. j] = true
            if not entities.loadedChunks[i .. ',' .. j] then
                entities.loadChunk(i, j)
                entities.loadedChunks[i .. ',' .. j] = true
            end
        end
    end

    for type, _ in pairs(entities.defs) do
        local influenceRadius = entities.defs[type].influenceRadius + entities.influenceMargin
        local freezeRadius = influenceRadius*2.5
        local cullRadius = influenceRadius*3.5

        local cullBX = camBX - cullRadius
        local cullBY = camBY - cullRadius
        local cullBW = camBW + cullRadius*2
        local cullBH = camBH + cullRadius*2

        local ctr = 0
        for chunk, _ in pairs(activeChunks) do
            if entities.culledContainer[chunk] then
                for _, v in pairs(entities.culledContainer[chunk][type] or {}) do
                    ctr = ctr + 1
                    if v.x > cullBX and v.x < cullBX + cullBW and v.y > cullBY and v.y < cullBY + cullBH then
                        v:uncull()
                    end
                end
            end
        end
        debugger.logVal('entity uncull check count - ', ctr)

        local freezeBX = camBX - freezeRadius
        local freezeBY = camBY - freezeRadius
        local freezeBW = camBW + freezeRadius*2
        local freezeBH = camBH + freezeRadius*2
        for _, v in pairs(entities.container[type] or {}) do
            repeat
                if v.x < cullBX or v.x > cullBX + cullBW or v.y < cullBY or v.y > cullBY + cullBH then
                    if not v.culled then v:cull() end
                    break
                elseif (v.x < freezeBX or v.x > freezeBX + freezeBW or v.y < freezeBY or v.y > freezeBY + freezeBH) then
                    if not v.frozen then v:freeze() end
                    break
                else
                    if v.frozen then v:unfreeze() end
                end
                v:update(dt)
            until true
        end
    end
end

function entities.draw()
    for type, _ in pairs(entities.defs) do
        for _, v in pairs(entities.container[type] or {}) do
            v:draw()
        end
    end
end
