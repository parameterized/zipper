
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

fonts = {
    f14 = love.graphics.newFont(14),
    f18 = love.graphics.newFont(18),
    f32 = love.graphics.newFont(32),
    f48 = love.graphics.newFont(48)
}

-- palette
-- https://coolors.co/7a7265-c0b7b1-8e6e53-c69c72-433e3f\
colors = {
    p1 = Color('7A7265'),
    p2 = Color('C0B7B1'),
    p3 = Color('8E6E53'),
    p4 = Color('C69C72'),
    p5 = Color('433E3F')
}
colors.p1_1 = colors.p1:clone():lighten(1.5)
colors.p3_1 = colors.p3:clone():lighten(0.8)
colors.p5_1 = colors.p5:clone():lighten(0.5)
colors.p5_2 = colors.p5:clone():lighten(0.8)