
pg = {}

function pg.hash(x)
	local z = math.sin(x)*43758.5453
	return z - math.floor(z)
end

function pg.hash2(x, y)
	local z = math.sin(x*12.9898 + y*78.233)*43758.5453
    return z - math.floor(z)
end
