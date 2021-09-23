local Object = require "lib/classic"

-- Entity class to serve as a basis for other entities within the game system
-- All entities must have x and y coordinates, bounding rect dimensions, an update function, and a draw function

local Entity = Object:extend()

Entity.alive = true
function Entity:new(x, y, w, h)
    Entity.entityType = "generic"
    self.name = "DefaultEntity"
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Entity:move(x, y)
    self.x, self.y, self.collisions = self.world:move(self, x, y)
end

function Entity:update(dt)
end

function Entity:draw(dt)
end

function Entity:handleKeyPress(key)
end

function Entity:onMessage(message)
end

return Entity
