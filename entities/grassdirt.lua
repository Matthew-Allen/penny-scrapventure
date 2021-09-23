local Dirt = require "entities/dirt"

local Grass = Dirt:extend()

function Grass:new(x, y, diggableTable)
    Grass.super.new(self,x, y, diggableTable)
    self.name = "grassdirt"
end

function Grass:draw(dt)
    love.graphics.draw(spriteTable["Diggable GrassDirt.png"],self.x, self.y)
end

return Grass
