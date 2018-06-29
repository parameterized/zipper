
entities = {
    server = {
        defs = {},
        static = {
            container = {},
            culledContainer = {}
        },
        dynamic = {
            container = {},
            culledContainer = {}
        },
        loadedChunks = {}
    },
    client = {
        defs = {}
    }
}
-- ...container[etype][id]
-- ...culledContainer[chunk][etype][id]

local hex = require 'entityDefs.hex'
local obstacle = require 'entityDefs.obstacle'

for _, v in pairs{'server', 'client'} do
    -- entities.server.defs.hex = hex.server
    entities[v].defs.hex = hex[v]
    entities[v].defs.obstacle = obstacle[v]
end

entities.chunkSize = 512
entities.staticInfluenceRadius = 0 --170
entities.dynamicInfluenceRadius = 0 --40
for _, v in pairs(entities.server.defs) do
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

function entities.reset()
    for etype, _ in pairs(entities.server.defs) do
        for _, v in pairs(entities.server.static.container[etype] or {}) do
            v:destroy()
        end
        for _, v in pairs(entities.server.dynamic.container[etype] or {}) do
            v:destroy()
        end
    end
    entities.server.static.culledContainer = {}
    entities.server.dynamic.culledContainer = {}
    entities.server.loadedChunks = {}
end

function entities.server.loadChunk(i, j)
    if not entities.server.loadedChunks[i .. ',' .. j] then
        for k=1, 3 do
            local x = (i + hash2(i + k/5, j))*entities.chunkSize
            local y = (j + hash2(i, j + k/5))*entities.chunkSize
            entities.server.defs.hex:new{x=x, y=y}:spawn()
        end
        if hash2(i + 1/3, j) < 0.5 then
            local x = (i + hash2(i + 1/3, j + 1/3))*entities.chunkSize
            local y = (j + hash2(i + 2/3, j + 2/3))*entities.chunkSize
            entities.server.defs.obstacle:new{x=x, y=y}:spawn()
        end
        entities.server.loadedChunks[i .. ',' .. j] = true
    end
end

function entities.server.update(dt)
    local uncullCheckCtr = 0
    local activeChunks = {}
    local inSimRange = {}
    local inFreezeRange = {}
    local inCullRange = {}
    for _, v in pairs(server.currentState.players) do
        -- todo: larger bbx to compensate for movement
        local cam = Camera{ssx=ssx, ssy=ssy}
        cam:setPosition(v.x, v.y)

        local camBX, camBY, camBW, camBH = cam:getAABB()

        local ar = entities.activeRadius
        local chunkBX = camBX - ar
        local chunkBY = camBY - ar
        local chunkBW = camBW + ar*2
        local chunkBH = camBH + ar*2
        for i=math.floor(chunkBX/entities.chunkSize), math.floor((chunkBX + chunkBW)/entities.chunkSize) do
            for j=math.floor(chunkBY/entities.chunkSize), math.floor((chunkBY + chunkBH)/entities.chunkSize) do
                activeChunks[i .. ',' .. j] = true
                entities.server.loadChunk(i, j)
            end
        end

        for type, typev in pairs(entities.server.defs) do
            local cullBX, cullBY, cullBW, cullBH
            local freezeBX, freezeBY, freezeBW, freezeBH
            local culledContainer, container
            if typev.static then
                cullBX = camBX - entities.staticCullRadius
                cullBY = camBY - entities.staticCullRadius
                cullBW = camBW + entities.staticCullRadius*2
                cullBH = camBH + entities.staticCullRadius*2

                culledContainer = entities.server.static.culledContainer
                container = entities.server.static.container
            else
                cullBX = camBX - entities.dynamicCullRadius
                cullBY = camBY - entities.dynamicCullRadius
                cullBW = camBW + entities.dynamicCullRadius*2
                cullBH = camBH + entities.dynamicCullRadius*2

                freezeBX = camBX - entities.dynamicFreezeRadius
                freezeBY = camBY - entities.dynamicFreezeRadius
                freezeBW = camBW + entities.dynamicFreezeRadius*2
                freezeBH = camBH + entities.dynamicFreezeRadius*2

                culledContainer = entities.server.dynamic.culledContainer
                container = entities.server.dynamic.container
            end

            for chunk, _ in pairs(activeChunks) do
                -- culledContainer[chunk][type]
                for _, v in pairs(safeIndex(culledContainer, chunk, type) or {}) do
                    uncullCheckCtr = uncullCheckCtr + 1
                    if v.x > cullBX and v.x < cullBX + cullBW
                    and v.y > cullBY and v.y < cullBY + cullBH then
                        v:uncull()
                    end
                end
            end

            if typev.static then
                for _, v in pairs(container[type] or {}) do
                    repeat
                        if v.x < cullBX or v.x > cullBX + cullBW
                        or v.y < cullBY or v.y > cullBY + cullBH then
                            inCullRange[v.id] = v
                            break
                        end
                        inSimRange[v.id] = v
                    until true
                end
            else
                for _, v in pairs(container[type] or {}) do
                    repeat
                        if v.x < cullBX or v.x > cullBX + cullBW
                        or v.y < cullBY or v.y > cullBY + cullBH then
                            inCullRange[v.id] = v
                            break
                        end
                        if v.x < freezeBX or v.x > freezeBX + freezeBW
                        or v.y < freezeBY or v.y > freezeBY + freezeBH then
                            inFreezeRange[v.id] = v
                            break
                        end
                        inSimRange[v.id] = v
                    until true
                end
            end
        end
    end

    for k, v in pairs(inCullRange) do
        if not inFreezeRange[k] and not inSimRange[k] and not v.culled then
            v:cull()
        end
    end
    for k, v in pairs(inFreezeRange) do
        if not inSimRange[k] and not v.frozen then
            v:freeze()
        end
    end
    for k, v in pairs(inSimRange) do
        if v.frozen then v:unfreeze() end
        v:update(dt)
    end

    debugger.logVal('server entity uncull check count', uncullCheckCtr)
end



function entities.client.draw()
    for _, v in pairs(client.currentState.entities) do
        v:draw()
    end
    if debugger.show and server.running then
        love.graphics.push()
        love.graphics.origin()
        activeCam:set()
        love.graphics.setCanvas(canvases.temp)
        love.graphics.clear(0, 0, 0, 0)
        for type, typev in pairs(entities.server.static.container) do
            for _, v in pairs(typev) do
                entities.client.defs[type].draw(v)
            end
        end
        for type, typev in pairs(entities.server.dynamic.container) do
            for _, v in pairs(typev) do
                entities.client.defs[type].draw(v)
            end
        end
        activeCam:reset()
        love.graphics.scale(graphicsScale)
        love.graphics.setCanvas()
        love.graphics.setColor(1, 0, 0.5, 0.4)
        love.graphics.draw(canvases.temp)
        love.graphics.pop()
    end
end
