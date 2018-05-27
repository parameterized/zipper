
local camera = {}
camera.__index = camera

local function new(opts)
	local obj = {
		x=0, y=0, scale=1, rotation=0
	}
	opts = opts or {}
	for k, v in pairs(opts) do obj[k] = v end
	local cam = setmetatable(obj, camera)
	return cam
end

function rotate(x, y, a)
	local s = math.sin(a);
	local c = math.cos(a);
	local x2 = x*c + y*s
	local y2 = y*c - x*s
	return x2, y2
end

function camera:set()
	local ssx, ssy = love.graphics.getDimensions()
	love.graphics.push()
	love.graphics.translate(ssx/2, ssy/2)
	love.graphics.scale(self.scale)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.x, -self.y)
end

function camera:reset()
	love.graphics.pop()
end

function camera:draw(f)
	self:set()
	f()
	self:reset()
end

function camera:screen2world(x, y)
	local ssx, ssy = love.graphics.getDimensions()
	x = x - ssx/2
	y = y - ssy/2
	x = x / self.scale
	y = y / self.scale
	x, y = rotate(x, y, self.rotation)
	x = x + self.x
	y = y + self.y
	return x, y
end

function camera:getAABB()
	-- probably optimizable
	local ssx, ssy = love.graphics.getDimensions()
	local pts = {
		{x=ssx, y=0},
		{x=ssx, y=ssy},
		{x=0, y=ssy},
		{x=0, y=0}
	}
	local minx, maxx, miny, maxy
	for _, v in pairs(pts) do
		local x, y = self:screen2world(v.x, v.y)
		minx = minx and math.min(x, minx) or x
		maxx = maxx and math.max(x, maxx) or x
		miny = miny and math.min(y, miny) or y
		maxy = maxy and math.max(y, maxy) or y
	end
	local x, y, w, h = minx, miny, maxx - minx, maxy - miny
	return x, y, w, h
end

return setmetatable({new=new}, {__call = function(_, ...) return new(...) end})
