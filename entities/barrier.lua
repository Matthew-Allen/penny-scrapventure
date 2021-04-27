local Entity = require "entities/entity"

local Barrier = Entity:extend()

function Barrier:new(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

return Barrier
