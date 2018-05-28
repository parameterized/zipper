
function clamp(x, a, b)
	if a < b then
		return math.min(math.max(x, a), b)
	else
		return math.min(math.max(x, b), a)
	end
end

function lerp(a, b, t)
	if math.abs(b-a) < 1e-9 then return b end
    return clamp((1-t)*a + t*b, a, b)
end

function lerpAngle(a, b, t)
	local theta = b - a
	if theta > math.pi then
		a = a + 2*math.pi
	elseif theta < -math.pi then
		a = a - 2*math.pi
	end
	return lerp(a, b, t)
end

function hash(x)
	local z = math.sin(x)*43758.5453
	return z - math.floor(z)
end

function hash2(x, y)
	local z = math.sin(x*12.9898 + y*78.233)*43758.5453
    return z - math.floor(z)
end
