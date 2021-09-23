local Object = require "lib/classic"

local Camera = Object:extend()

-- Takes any table with x and y values, and focuses the love camera on it.
-- Can be used to track either an entity in the game-world,
-- or set to track a single point by simply passing a 'dummy table' to it
function Camera:new(focus)
    self.winX, self.winY = love.graphics.getDimensions()
    self.focus = focus
    self.x = focus.x
    self.y = focus.y
    self.acc = 0
    self.speed = 2
end

function Camera:setFocus(focus)
    self.focus = focus
end

-- Will move the camera towards the focus point at a speed
-- dictated by distance from the focus point and the camera's speed.
function Camera:update(dt)
    self.x = math.ceil(self.x - (self.x - self.focus.x)*self.speed*dt)
    self.y = math.ceil(self.y - (self.y - self.focus.y)*self.speed*dt)
    love.graphics.translate(-self.x*2 + self.winX/2, -self.y*2 + self.winY/2)
end

return Camera
