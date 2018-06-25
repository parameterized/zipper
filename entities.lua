
entities = {
    defs = {},
    static = {
        container = {},
        culledContainer = {}
    },
    dynamic = {
        container = {},
        frozenContainer = {},
        culledContainer = {}
    },
    loadedChunks = {}
}
-- entities.dynamic.container[etype][id]
-- entities.dynamic.frozenContainer[etype][id]
-- entities.dynamic.culledContainer[chunk][etype][id]

entities.defs.hex = require 'entityDefs.hex'
entities.defs.obstacle = require 'entityDefs.obstacle'

entities.chunkSize = 512
entities.staticInfluenceRadius = 0 --170
entities.dynamicInfluenceRadius = 0 --40
for _, v in pairs(entities.defs) do
    if v.static then
        entities.staticInfluenceRadius = math.max(entities.staticInfluenceRadius, v.influenceRadius)
    else
        entities.dynamicInfluenceRadius = math.max(entities.dynamicInfluenceRadius, v.influenceRadius)
    end
end
entities.staticCullRadius = entities.dynamicInfluenceRadius*5 + entities.staticInfluenceRadius
entities.dynamicFreezeRadius = entities.dynamicInfluenceRadius*2
entities.dynamicCullRadius = entities.dynamicInfluenceRadius*4
entities.activeRadius = math.max(entities.staticCullRadius, entities.dynamicCullRadius)

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
    entities.loadedChunks[i .. ',' .. j] = true
end

function entities.update(dt)
    local camBX, camBY, camBW, camBH = camera:getAABB()

    local ar = entities.activeRadius
    local chunkBX = camBX - ar
    local chunkBY = camBY - ar
    local chunkBW = camBW + ar*2
    local chunkBH = camBH + ar*2
    local activeChunks = {}
    for i=math.floor(chunkBX/entities.chunkSize), math.floor((chunkBX + chunkBW)/entities.chunkSize) do
        for j=math.floor(chunkBY/entities.chunkSize), math.floor((chunkBY + chunkBH)/entities.chunkSize) do
            activeChunks[i .. ',' .. j] = true
            if not entities.loadedChunks[i .. ',' .. j] then
                entities.loadChunk(i, j)
            end
        end
    end

    local staticCullBX = camBX - entities.staticCullRadius
    local staticCullBY = camBY - entities.staticCullRadius
    local staticCullBW = camBW + entities.staticCullRadius*2
    local staticCullBH = camBH + entities.staticCullRadius*2

    local dynamicCullBX = camBX - entities.dynamicCullRadius
    local dynamicCullBY = camBY - entities.dynamicCullRadius
    local dynamicCullBW = camBW + entities.dynamicCullRadius*2
    local dynamicCullBH = camBH + entities.dynamicCullRadius*2

    local dynamicFreezeBX = camBX - entities.dynamicFreezeRadius
    local dynamicFreezeBY = camBY - entities.dynamicFreezeRadius
    local dynamicFreezeBW = camBW + entities.dynamicFreezeRadius*2
    local dynamicFreezeBH = camBH + entities.dynamicFreezeRadius*2

    local uncullCheckCtr = 0
    for type, typev in pairs(entities.defs) do
        local cullBX, cullBY, cullBW, cullBH
        local freezeBX, freezeBY, freezeBW, freezeBH
        local culledContainer, container
        if typev.static then
            cullBX = camBX - entities.staticCullRadius
            cullBY = camBY - entities.staticCullRadius
            cullBW = camBW + entities.staticCullRadius*2
            cullBH = camBH + entities.staticCullRadius*2

            culledContainer = entities.static.culledContainer
            container = entities.static.container
        else
            cullBX = camBX - entities.dynamicCullRadius
            cullBY = camBY - entities.dynamicCullRadius
            cullBW = camBW + entities.dynamicCullRadius*2
            cullBH = camBH + entities.dynamicCullRadius*2

            freezeBX = camBX - entities.dynamicFreezeRadius
            freezeBY = camBY - entities.dynamicFreezeRadius
            freezeBW = camBW + entities.dynamicFreezeRadius*2
            freezeBH = camBH + entities.dynamicFreezeRadius*2

            culledContainer = entities.dynamic.culledContainer
            container = entities.dynamic.container
        end

        for chunk, _ in pairs(activeChunks) do
            -- culledContainer[chunk][type]
            for _, v in pairs(safeIndex(culledContainer, chunk, type) or {}) do
                uncullCheckCtr = uncullCheckCtr + 1
                if v.x > staticCullBX and v.x < staticCullBX + staticCullBW
                and v.y > staticCullBY and v.y < staticCullBY + staticCullBH then
                    v:uncull()
                end
            end
        end

        if typev.static then
            for _, v in pairs(container[type] or {}) do
                repeat
                    if v.x < cullBX or v.x > cullBX + cullBW or v.y < cullBY or v.y > cullBY + cullBH then
                        if not v.culled then v:cull() end
                        break
                    end
                until true
            end
        else
            for _, v in pairs(container[type] or {}) do
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
    debugger.logVal('entity uncull check count', uncullCheckCtr)
end

function entities.draw()
    for type, typev in pairs(entities.static.container) do
        for _, v in pairs(typev) do
            v:draw()
        end
    end
    for type, typev in pairs(entities.dynamic.container) do
        for _, v in pairs(typev) do
            v:draw()
        end
    end
end
