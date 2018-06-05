
entities = {
    container = {},
    culledContainer = {},
    defs = {},
    loadedChunks = {}
}

entities.maxInfluenceRadius = 50
entities.freezeRange = entities.maxInfluenceRadius*2.5
entities.cullRange = entities.maxInfluenceRadius*3.5

--entities.freezeRange = entities.maxInfluenceRadius*-3.5
--entities.cullRange = entities.maxInfluenceRadius*-1.5

entities.chunkSize = 512

entities.defs.hex = require 'entityDefs.hex'

function entities.spawn(type, x, y)
    local def = entities.defs[type]
    if def then
        def:new{type=type, x=x, y=y}:spawn()
    end
end

function entities.loadChunk(i, j)
    for k=1, 3 do
        entities.spawn('hex', (i + math.random())*entities.chunkSize, (j + math.random())*entities.chunkSize)
    end
end

function entities.update(dt)
    local bx, by, bw, bh = camera:getAABB()
    local cbx = bx - entities.cullRange
    local cby = by - entities.cullRange
    local cbw = bw + entities.cullRange*2
    local cbh = bh + entities.cullRange*2
    for i=math.floor(cbx/entities.chunkSize), math.floor((cbx + cbw)/entities.chunkSize) do
        for j=math.floor(cby/entities.chunkSize), math.floor((cby + cbh)/entities.chunkSize) do
            if not entities.loadedChunks[i .. ',' .. j] then
                entities.loadChunk(i, j)
                entities.loadedChunks[i .. ',' .. j] = true
            end
        end
    end
    for _, v in pairs(entities.culledContainer) do
        if v.x > cbx and v.x < cbx + cbw and v.y > cby and v.y < cby + cbh then
            v:uncull()
        end
    end
    local fbx = bx - entities.freezeRange
    local fby = by - entities.freezeRange
    local fbw = bw + entities.freezeRange*2
    local fbh = bh + entities.freezeRange*2
    for _, v in pairs(entities.container) do
        repeat
            if v.x < cbx or v.x > cbx + cbw or v.y < cby or v.y > cby + cbh then
                if not v.culled then v:cull() end
                break
            elseif (v.x < fbx or v.x > fbx + fbw or v.y < fby or v.y > fby + fbh) then
                if not v.frozen then v:freeze() end
                break
            else
                if v.frozen then v:unfreeze() end
            end
            v:update(dt)
        until true
    end
end

function entities.draw()
    for _, v in pairs(entities.container) do
        v:draw()
    end
end
