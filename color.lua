
-- adapted from https://github.com/yuri/lua-colors/blob/master/lua/colors.lua

local color = {}
color.__index = color

local function new(opts)
    local obj = {}
    if type(opts) == 'string' then
        obj.r, obj.g, obj.b = color.hex2rgb(opts)
    elseif type(opts) == 'table' then
        if opts.hex then
            obj.r, obj.g, obj.b = color.hex2rgb(opts.hex)
        elseif opts.r and opts.g and opts.b then
            obj.r, obj.g, obj.b = opts.r, opts.g, opts.b
        elseif #opts == 3 then
            obj.r, obj.g, obj.b = opts[1], opts[2], opts[3]
        else
            obj.r, obj.g, obj.b = 0, 0, 0
        end
    end
    return setmetatable(obj, color)
end

function color.hex2rgb(hex)
    local hex = hex:gsub('#', '')
    if hex:len() == 3 then
        return (tonumber('0x' .. hex:sub(1, 1))*17)/255, (tonumber('0x' .. hex:sub(2, 2))*17)/255, (tonumber('0x' .. hex:sub(3, 3))*17)/255
    else
        return tonumber('0x' .. hex:sub(1, 2))/255, tonumber('0x' .. hex:sub(3, 4))/255, tonumber('0x' .. hex:sub(5, 6))/255
    end
end

function color.rgb2hsl(r, g, b)
    local min = math.min(r, g, b)
    local max = math.max(r, g, b)
    local delta = max - min

    local h, s, l = 0, 0, ((min+max)/2)

    if l > 0 and l < 0.5 then s = delta/(max+min) end
    if l >= 0.5 and l < 1 then s = delta/(2-max-min) end

    if delta > 0 then
        if max == r and max ~= g then h = h + (g-b)/delta end
        if max == g and max ~= b then h = h + 2 + (b-r)/delta end
        if max == b and max ~= r then h = h + 4 + (r-g)/delta end
        h = h / 6;
    end

    if h < 0 then h = h + 1 end
    if h > 1 then h = h - 1 end

    return h * 360, s, l
end

function color.hsl2rgb(h, s, l)
    h = h/360
    local m1, m2
    if l <= 0.5 then
        m2 = l*(s + 1)
    else
        m2 = l + s - l*s
    end
    m1 = l*2 - m2

    local function _h2rgb(m1, m2, h)
        if h < 0 then h = h + 1 end
        if h > 1 then h = h - 1 end
        if h*6 < 1 then
            return m1 + (m2 - m1)*h*6
        elseif h*2 < 1 then
            return m2
        elseif h*3 < 2 then
            return m1 + (m2 - m1)*(2/3 - h)*6
        else
            return m1
        end
    end

    return _h2rgb(m1, m2, h + 1/3), _h2rgb(m1, m2, h), _h2rgb(m1, m2, h - 1/3)
end

function color:spin(delta)
    local h, s, l = color.rgb2hsl(self.r, self.g, self.b)
    self.r, self.g, self.b = color.hsl2rgb((h + delta) % 360, s, l)
end

function color:saturation(s)
    local h, _s, l = color.rgb2hsl(self.r, self.g, self.b)
    self.r, self.g, self.b = color.hsl2rgb(h, s, l)
    return self
end

function color:saturate(r)
    local h, s, l = color.rgb2hsl(self.r, self.g, self.b)
    self.r, self.g, self.b = color.hsl2rgb(h, s*r, l)
    return self
end

function color:lightness(l)
    local h, s, _l = color.rgb2hsl(self.r, self.g, self.b)
    self.r, self.g, self.b = color.hsl2rgb(h, s, l)
    return self
end

function color:lighten(r)
    local h, s, l = color.rgb2hsl(self.r, self.g, self.b)
    self.r, self.g, self.b = color.hsl2rgb(h, s, l*r)
    return self
end

function color:rgb()
    return self.r, self.g, self.b
end

function color:clone()
    return new{self:rgb()}
end

return setmetatable({new=new}, {__call = function(_, ...) return new(...) end})
