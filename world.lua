
world = {}

function world.update(dt)

end

function world.draw()
    love.graphics.setBackgroundColor(colors.p3:rgb())
    local freq = 64
    local bx, by, bw, bh = camera:getAABB()
    for i=-1, math.floor(bw/freq)+1 do
		for j=-1, math.floor(bh/freq)+1 do
            local bi, bj = math.floor(bx/freq), math.floor(by/freq)
			local x = bi*freq + i*freq + freq*(hash2(bi + i + 1/3, bj + j) - 1/2)
			local y = bj*freq + j*freq + freq*(hash2(bi + i + 2/3, bj + j) - 1/2)
            local l = (hash2(bi + i, bj + j + 1/5)*2 - 1)*0.1 + 1
            love.graphics.setColor(colors.p3_1:clone():lighten(l):rgb())
			love.graphics.circle('fill', x + freq/2, y + freq/2, freq/4 + hash2(bi + i, bj + j + 4/5)*freq/16)
		end
	end
end
