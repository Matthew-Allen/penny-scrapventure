local Diggable = require "entities/diggable"

local Dirt = Diggable:extend()

function Dirt:new(x, y, diggableTable)
    Dirt.super.new(self,x, y, diggableTable)
    self.diggableType = "dirt"
end

function Dirt:draw(dt)
    love.graphics.draw(spriteTable["Diggable Dirt.png"],self.x, self.y)
end
return Dirt
