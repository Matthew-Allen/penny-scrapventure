local Entity = require "entities/entity"

local Obstacle = Entity:extend()

function Obstacle:new(x, y)
    self.name = "Obstacle"
    self.w = 32
    self.h = 32
    self.x = x
    self.y = y
end

function Obstacle:update(dt)
end

function Obstacle:draw(dt)
    love.graphics.draw(spriteTable["32box.png"], self.x, self.y)
end

return Obstacle
