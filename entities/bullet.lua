local Entity = require "entities/entity"

local Bullet = Entity:extend()

function Bullet:new(x, y, direction)
    self.x = x
    self.y = y
    self.w = 8
    self.h = 8
    self.direction = direction
    self.lifespan = 0
    self.sprite = spriteTable["bullet.png"]
end

function Bullet:update(dt)
    local moveSpeed = 200*dt
    self.lifespan = self.lifespan + dt
    if self.direction == "left" then
        self:move(self.x - moveSpeed, self.y)
    elseif self.direction == "right" then
        self:move(self.x + moveSpeed, self.y)
    elseif self.direction == "up" then
        self:move(self.x, self.y - moveSpeed)
    elseif self.direction == "down" then
        self:move(self.x, self.y + moveSpeed)
    end

    if self.lifespan > 3 then
        self.alive = false
    end

    for _, _ in ipairs(self.collisions) do
        self.alive = false
    end
end

function Bullet:draw(dt)
    love.graphics.draw(self.sprite, self.x, self.y)
end

return Bullet
